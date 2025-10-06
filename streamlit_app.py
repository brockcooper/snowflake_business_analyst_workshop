import os
from pathlib import Path
from typing import Dict, Tuple

import pandas as pd
import streamlit as st
import altair as alt

# Optional: geocoding for map view
try:
    from geopy.geocoders import Nominatim
    from geopy.extra.rate_limiter import RateLimiter
except Exception:  # pragma: no cover
    Nominatim = None
    RateLimiter = None


BASE_DIR = Path(__file__).resolve().parent
ASSETS_CSV_PATH = BASE_DIR / "resources" / "assets.csv"
GEOCODED_CACHE_PATH = BASE_DIR / "resources" / "assets_geocoded.csv"


st.set_page_config(
    page_title="CO State Assets Explorer",
    page_icon="📍",
    layout="wide",
)


@st.cache_data(show_spinner=False)
def load_assets_dataframe(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    # Normalize columns and types
    df.columns = [c.strip().lower() for c in df.columns]
    expected = ["id", "name", "address", "city", "state", "zip"]
    missing = [c for c in expected if c not in df.columns]
    if missing:
        raise ValueError(f"CSV missing required columns: {missing}")

    # Clean up values
    df["id"] = pd.to_numeric(df["id"], errors="coerce").astype("Int64")
    df["zip"] = df["zip"].astype(str).str.replace("[^0-9]", "", regex=True).str.zfill(5)
    df["state"] = df["state"].astype(str).str.upper()

    # Build full address string
    df["full_address"] = (
        df["address"].astype(str).str.strip()
        + ", "
        + df["city"].astype(str).str.strip()
        + ", "
        + df["state"].astype(str).str.strip()
        + " "
        + df["zip"].astype(str).str.strip()
    )
    return df


def sidebar_filters(df: pd.DataFrame) -> pd.DataFrame:
    st.sidebar.header("Filters")

    # City filter
    city_options = sorted(df["city"].dropna().unique().tolist())
    selected_cities = st.sidebar.multiselect(
        "City", options=city_options, default=city_options
    )

    # ZIP filter
    zip_options = sorted(df["zip"].dropna().unique().tolist())
    selected_zips = st.sidebar.multiselect(
        "ZIP", options=zip_options, default=zip_options
    )

    # Search
    query = st.sidebar.text_input("Search name/address contains", value="").strip()

    filtered = df[df["city"].isin(selected_cities) & df["zip"].isin(selected_zips)]

    if query:
        q = query.lower()
        mask = (
            filtered["name"].astype(str).str.lower().str.contains(q)
            | filtered["address"].astype(str).str.lower().str.contains(q)
            | filtered["full_address"].astype(str).str.lower().str.contains(q)
        )
        filtered = filtered[mask]

    return filtered


@st.cache_data(show_spinner=True, ttl=24 * 3600)
def load_geocoded_cache(path: Path) -> pd.DataFrame:
    if path.exists():
        try:
            cached = pd.read_csv(path)
            # normalize
            cached.columns = [c.strip().lower() for c in cached.columns]
            return cached
        except Exception:
            return pd.DataFrame()
    return pd.DataFrame()


@st.cache_data(show_spinner=True, ttl=24 * 3600)
def geocode_addresses(addresses: pd.Series) -> pd.DataFrame:
    if Nominatim is None or RateLimiter is None:
        st.warning("Geocoding library not available; showing data without map.")
        return pd.DataFrame(columns=["full_address", "latitude", "longitude"])  

    geolocator = Nominatim(user_agent="co_state_assets_streamlit")
    rate_limited_geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)

    results: Dict[str, Tuple[float, float]] = {}

    unique_addresses = list(dict.fromkeys(addresses.dropna().tolist()))
    progress = st.progress(0.0, text="Geocoding addresses...")
    total = max(len(unique_addresses), 1)
    for idx, addr in enumerate(unique_addresses, start=1):
        try:
            location = rate_limited_geocode(addr)
            if location:
                results[addr] = (location.latitude, location.longitude)
        except Exception:
            # skip failed address
            pass
        progress.progress(idx / total, text=f"Geocoding {idx}/{total}")

    progress.empty()

    out = (
        pd.DataFrame.from_dict(results, orient="index", columns=["latitude", "longitude"])  
        .reset_index()
        .rename(columns={"index": "full_address"})
    )
    return out


def ensure_latlon(df: pd.DataFrame) -> pd.DataFrame:
    cached = load_geocoded_cache(GEOCODED_CACHE_PATH)
    merged = df.merge(
        cached[["full_address", "latitude", "longitude"]] if not cached.empty else cached,
        on="full_address",
        how="left",
    )

    missing_mask = merged["latitude"].isna() | merged["longitude"].isna()
    if missing_mask.any():
        to_geocode = merged.loc[missing_mask, "full_address"]
        newly = geocode_addresses(to_geocode)
        if not newly.empty:
            merged = merged.drop(columns=["latitude", "longitude"], errors="ignore").merge(
                newly, on="full_address", how="left"
            )
            # update cache on disk (union of old + new)
            combined = pd.concat([
                cached[["full_address", "latitude", "longitude"]] if not cached.empty else pd.DataFrame(columns=["full_address", "latitude", "longitude"]),
                newly,
            ], ignore_index=True)
            combined = combined.drop_duplicates(subset=["full_address"], keep="last")
            try:
                combined.to_csv(GEOCODED_CACHE_PATH, index=False)
            except Exception:
                pass

    return merged


def charts_section(df: pd.DataFrame) -> None:
    left, right = st.columns(2)

    with left:
        st.subheader("Facilities by City")
        counts_by_city = (
            df.groupby("city", dropna=False)["id"].count().reset_index(name="count")
        )
        chart_city = (
            alt.Chart(counts_by_city)
            .mark_bar()
            .encode(
                x=alt.X("count:Q", title="Count"),
                y=alt.Y("city:N", sort="-x", title="City"),
                tooltip=["city:N", "count:Q"],
            )
            .properties(height=400)
        )
        st.altair_chart(chart_city, use_container_width=True)

    with right:
        st.subheader("Facilities by ZIP")
        counts_by_zip = (
            df.groupby("zip", dropna=False)["id"].count().reset_index(name="count")
        )
        chart_zip = (
            alt.Chart(counts_by_zip)
            .mark_bar()
            .encode(
                x=alt.X("count:Q", title="Count"),
                y=alt.Y("zip:N", sort="-x", title="ZIP"),
                tooltip=["zip:N", "count:Q"],
            )
            .properties(height=400)
        )
        st.altair_chart(chart_zip, use_container_width=True)


def table_section(df: pd.DataFrame) -> None:
    st.subheader("Table")
    st.dataframe(
        df[["id", "name", "address", "city", "state", "zip"]].sort_values("name"),
        use_container_width=True,
    )

    csv_bytes = df.to_csv(index=False).encode("utf-8")
    st.download_button(
        label="Download filtered CSV",
        data=csv_bytes,
        file_name="assets_filtered.csv",
        mime="text/csv",
    )


def map_section(df: pd.DataFrame) -> None:
    st.subheader("Map")
    with st.expander("Show map", expanded=False):
        enable_map = st.checkbox("Enable geocoding and map", value=False)
        if not enable_map:
            st.info("Enable to geocode addresses and visualize points on a map.")
            return

        enriched = ensure_latlon(df)
        points = enriched.dropna(subset=["latitude", "longitude"]).copy()
        if points.empty:
            st.warning("No points could be geocoded.")
            return

        st.map(points.rename(columns={"latitude": "lat", "longitude": "lon"}))
        st.caption("Geocoding via OpenStreetMap Nominatim; cached locally to resources/assets_geocoded.csv")


def main() -> None:
    st.title("Colorado State-owned Facilities Explorer")
    st.caption("Browse, filter, chart, and map facilities from resources/assets.csv")

    if not ASSETS_CSV_PATH.exists():
        st.error(f"Could not find CSV at {ASSETS_CSV_PATH}")
        st.stop()

    df = load_assets_dataframe(ASSETS_CSV_PATH)

    st.sidebar.markdown("### Overview")
    st.sidebar.metric("Total facilities", len(df))

    filtered = sidebar_filters(df)
    st.markdown(
        f"**Showing {len(filtered)} of {len(df)} facilities** after applying filters."
    )

    charts_section(filtered)
    map_section(filtered)
    table_section(filtered)


if __name__ == "__main__":
    main()



