# Analytics Engineering Project — Retail Orders, Payments & Loyalty Pipeline

**Author:** Hristina Todorova

A hands-on analytics engineering project built with dbt and DuckDB. It models a fictional retail loyalty program end-to-end — from raw CSV ingestion through staging, intermediate, and mart layers — producing clean dimensional models, KPI outputs, data quality tests, snapshots, and exposures.

---

## Tech Stack

- dbt Core
- DuckDB
- SQL
- VS Code
- Git/GitHub Actions

---

## About This Project

I built this project to deepen my hands-on experience with analytics engineering using dbt and DuckDB. The dataset simulates a retail business with orders, payments, and a loyalty card system — domains I find practical and interesting to model.

Key things I focused on:

- building a clean layered warehouse (staging → intermediate → marts → analytics)
- writing reusable intermediate models to keep mart logic simple
- implementing a loyalty points ledger with computed earn events
- writing custom SQL tests to surface real data quality issues rather than hiding them
- tracking customer segment changes over time with SCD-style snapshots
- setting up CI/CD with GitHub Actions to validate the pipeline on every push

---

## Project Architecture

```text
CSV Seeds / Sources
    ↓
Staging Models
    ↓
Intermediate Models
    ↓
Fact / Dimension Models
    ↓
Analytics Models
    ↓
Data Quality Tests, Exposures & Snapshots
```

---

## Project Structure

```text
retail_loyalty_dbt/
├── .github/workflows/
│   └── dbt.yml
├── assets/
├── models/
│   ├── staging/
│   ├── intermediate/
│   ├── marts/
│   ├── analytics/
│   ├── schema.yml
│   ├── sources.yml
│   └── exposures.yml
├── seeds/
├── snapshots/
├── tests/
├── dbt_project.yml
├── .gitignore
└── README.md
```

---

## Seed and Source Layer

Raw CSV files are loaded through dbt seeds and documented as sources.

Seed/source tables:

- customers
- customer_cards
- products
- orders_master
- order_details
- payments
- points_thresholds
- card_points_ledger

---

## Staging Layer

The staging layer performs:

- datatype normalization
- string cleanup
- null handling
- technical deduplication
- key validation
- business field standardization

Example transformations:

```sql
trim(lower(payment_status))
cast(order_date as date)
qualify row_number() over (...)
```

---

## Intermediate Layer

Intermediate models implement reusable business logic.

### int_order_amounts

Calculates:

```text
line_gross
line_net
order_expected_amount
```

### int_payment_events

Adds payment event flags and measures:

```text
is_successful_payment
is_refund
cash_collected_amount
refund_amount
```

### int_payment_aggregates

Aggregates payment events to one row per order.

### int_latest_payment_status

Tracks the latest payment status per order using a window function.

### int_order_revenue_status

Combines order, revenue, and payment status logic before publishing the final fact table.

### int_computed_earn_events

Computes loyalty earn events for valid revenue orders linked to active loyalty cards.

---

## Mart Layer

### Fact Tables

#### fact_orders

One row per order.

Includes:

- payment status flags
- valid revenue logic
- payment aggregation
- overpayment detection
- refund handling

#### fact_payments

One row per payment event. This model is configured as incremental using `payment_id` as the unique key.

#### fact_order_lines

One row per order line.

#### fact_card_points_ledger

Combined raw and computed loyalty point events.

### Dimension Tables

#### dim_customers

Customer dimension.

#### dim_products

Product dimension.

---

## Analytics Layer

Analytics models include:

- kpi_summary
- revenue_by_day
- revenue_by_customer_segment
- loyalty_card_summary

Generated KPIs include:

- total_orders
- valid_revenue_orders
- conversion_rate
- total_expected_revenue
- net_collected_revenue
- avg_order_value
- active_cards
- points_earned
- points_redeemed
- loyalty_revenue_share

---

## Data Quality

Rather than silently masking inconsistent raw data, I expose data quality issues through explicit dbt tests and monitoring models. The custom tests are configured as warnings so the pipeline surfaces real-world problems without breaking the full build.

Generic tests used:

- `unique`
- `not_null`
- `accepted_values`

Custom SQL tests:

- paid orders without a successful payment
- negative order amounts
- negative points balances

---

## Snapshots

The project implements SCD-style customer segment tracking using dbt snapshots.

Snapshot:

```text
customer_segments_snapshot
```

This tracks changes in customer segment over time.

---

## Exposures

The project defines a business exposure:

```text
retail_kpi_dashboard
```

The exposure depends on the analytics models that would power a retail KPI dashboard.

---

## CI/CD

The project includes a GitHub Actions workflow:

```text
.github/workflows/dbt.yml
```

The workflow runs:

- dbt seed
- dbt run
- dbt test
- dbt docs generate

---

## Running the Project

### Install dependencies

```bash
pip install dbt-core dbt-duckdb
```

### Seed raw data

```bash
python -m dbt.cli.main seed --full-refresh
```

### Build models

```bash
python -m dbt.cli.main run
```

### Run tests

```bash
python -m dbt.cli.main test
```

### Run snapshots

```bash
python -m dbt.cli.main snapshot
```

### Generate documentation

```bash
python -m dbt.cli.main docs generate
python -m dbt.cli.main docs serve
```

---

## Key Engineering Concepts

- layered warehouse architecture (staging / intermediate / marts / analytics)
- dimensional modeling (facts and dimensions)
- dbt workflows and best practices
- event-driven payment architecture
- loyalty ledger and earn event computation
- SQL window functions and deduplication
- data quality engineering with custom tests
- SCD-style snapshot tracking
- incremental model configuration
- exposures for downstream documentation
- CI/CD validation with GitHub Actions

---

## Future Improvements

Things I plan to explore next:

1. Deploy to a cloud warehouse (BigQuery or Snowflake)
2. Orchestrate with Airflow or Dagster
3. Implement the dbt semantic layer
4. Build a BI dashboard in Power BI or Tableau connected to the mart layer
5. Add source freshness checks
6. Integrate dbt-utils for cleaner macro usage
7. Dockerize the local dev environment
8. Add environment-specific profiles for staging vs. production
