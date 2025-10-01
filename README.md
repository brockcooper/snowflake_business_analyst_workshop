## Snowflake Business Analyst Workshop – Hands-on Lab

### What this is
This repository contains a hands-on SQL lab for business analysts learning Snowflake. It pairs with the slide deck in `resources/Snowflake Business Analyst Workshop.pdf` and uses the free Marketplace dataset “Snowflake Public Data (Free)”. The lab progressively teaches core SQL topics with runnable examples and practice prompts, then adds JOINs, VIEWS, and DYNAMIC TABLES.

### What’s included
- `hands_on_lab.sql`: Student file with topic sections, two examples per topic, and practice prompts with empty “Your answer:” placeholders.
- `resources/hands_on_lab_answers.sql`: Instructor key with filled answers for every practice prompt.

### Dataset used (Marketplace)
- Provider: Snowflake
- Listing: Snowflake Public Data (Free)
- Required database name in your account: `SNOWFLAKE_PUBLIC_DATA_FREE`

### Prerequisites
- A Snowflake account with access to the Snowflake Marketplace
- A compute warehouse (e.g., `COMPUTE_WH`)
- Roles: `ACCOUNTADMIN` (or equivalent) to install the Marketplace database, `SYSADMIN` for day‑to‑day lab use

### Subscribing to the dataset from Marketplace (UI)
1) In Snowsight, open Marketplace and search for “Snowflake Public Data (Free)”.
2) Click Get/Subscribe, and when prompted, set the database name to `SNOWFLAKE_PUBLIC_DATA_FREE`.
3) - During subscribing to the dataset, be sure to allow access to the `SYSADMIN` role


### How to run the lab
1) Open a new worksheet, then copy and paste the contents of `hands_on_lab.sql` into the worksheet.
2) Execute examples in each section, then attempt the practice prompts below the “Your answer:” comments.
3) For solutions, refer to `resources/hands_on_lab_answers.sql`.

Clean‑up examples:
```sql
DROP DATABASE IF EXISTS ANALYTICS;
```