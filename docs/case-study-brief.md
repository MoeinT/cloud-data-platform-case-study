# Case Study Brief: Cloud Data Platform Engineer

> English translation of *"Évaluation candidat – RFP Onboarding Data Engineers"* (version 2026.05).

## Instructions for the candidate

This document contains several sections: **use cases**, **technical questions** and **behavioural questions**.

You **must cover the mandatory use case**, then **choose and cover at least 2 of the proposed use cases**. For the question sections, answer the ones that best match your experience. The goal is not perfect answers. They want to see **how you reason, prioritise and respond**.

> Note: the original says "at least 2 out of the 4 proposed", but the document actually lists **6** optional cases (2–7).

There is no right or wrong answer to the use cases. What they are interested in:

- How you reason when the problem is open or ambiguous
- Your approach: how you structure your thinking, which assumptions you make, in what order you proceed
- Your ability to make choices and justify them, including when information is incomplete
- Your analytical stance: do you identify the right constraints, trade-offs and risks?
- Your maturity across the topics covered: cloud, data engineering, orchestration, quality, tooling

Difficulty legend: ★★★ Hard · ★★ Medium · ★ Easy

---

## Mandatory use case

### Case 1: Data architecture for a startup

**Context**
A startup wants to analyse its users' behaviour. It collects **frontend** events (clicks, navigation) and **backend** events (API calls, errors). The source data is **already available on S3**. The startup wants to use this project to build a **new data stack from scratch**, with no legacy constraints.

**Need**
The CEO expects **operational dashboards within one week**. The BI team will handle the reporting layer. Your role is to provide **reliable, structured data, available in a data warehouse**.

Propose a technical stack that ingests the frontend and backend events from S3, transforms them and centralises them in a data warehouse accessible to the BI team.

Reporting (dashboards, visualisation) is **out of scope**.

- Which technical stack do you propose, and why?
- Which tools do you choose for each pipeline stage (ingestion, transformation, storage)?
- What are the trade-offs of your choices?
- How do you organise the work with your team to deliver on time?

**Functional constraints / additional information**
- 2 people on the team
- Data volume and format not specified
- Data must be available **early in the morning** for the BI teams

**Technical constraints**
- Provider: AWS or GCP
- Free choice of stack

---

## Optional use cases (choose at least 2)

### Case 2: Authentication & authorisation on S3 · `AWS`

**Context**
A large group exposes an S3 bucket to external partners who need to drop files into it. Some partners are on AWS (different account), others are not.

**Need**
1. For an **AWS partner (different account)**: which native mechanism grants access **without creating credentials**? How does it work concretely?
2. For a **non-AWS partner**: which solutions do you consider? Pros and cons of each?
3. In both cases, how do you guarantee the partner can do **strictly only what they need**?

### Case 3: Serverless architecture: webhook → S3 · `AWS`

**Context**
A partner can only send data via **HTTP calls**. The group triggers its pipelines when files land in S3. You need to build an entry point that receives these calls and writes the data as files to S3.

**Need**
1. Which AWS services do you use? Describe the data path, from receiving the call to writing to S3.
2. Which mechanisms do you put in place to secure this webhook (caller authentication, data validation)?

**Constraint**
- Serverless, scalable, low cost.

### Case 4: Snowflake performance & cost on an 8-billion-row fact table · `Snowflake`

**Context**
A fact table holds **8 billion rows** (e-commerce transactions, 3 years). **5 teams share one XL warehouse**. Queries (aggregations over time windows, filtered by country and category) take **45 seconds on average**.

**Need**
1. Which levers do you pull first to reduce latency, **without changing the data model**? In what order, and why?
2. Finance asks for a **cost allocation report per team**. How do you implement it in Snowflake? What are the limits of this approach?
3. A dbt model runs **hourly as INCREMENTAL** but **still scans the whole table** despite a filter on `updated_at`. What do you suspect, and how do you diagnose it?

### Case 5: Setting up DataOps for a dbt + Airflow team · `dbt + Airflow`

**Context**
A team of **6 people** maintains about **20 dbt + Airflow pipelines**. Deployments are manual (`dbt run` locally + direct push to `main`). No automated tests, no staging, and incidents are discovered by BI users. Management wants DataOps in place **by the end of the quarter**.

1. What do you start with concretely, and what do you **deliberately not do yet**?
2. How do you make sure a dbt model doesn't **silently break** something in production during a deployment?
3. The team is motivated but has **no CI/CD experience**. How do you keep this from becoming a blocker rather than an accelerator?
4. A pipeline fails in prod at **6 a.m.** How does your DataOps approach change the way the team detects and responds to it?

**Functional constraints / additional information**
- The team has never done formal CI/CD.

**Technical constraints**
- No stack constraint.

### Case 6: Heavy ML workload · `MLE + Snowflake`

**Context**
A Business Unit's Data Science team wants to deploy a **price prediction model per hotel**. The portfolio has **5,500 hotels**. Each hotel must have **its own model, retrained every week**.

**Need**
1. How do you architect this system on **AWS + Snowflake**?
2. How do you handle **storage, versioning and governance** of the 5,500 models?
3. What are your **FinOps** recommendations to keep costs under control?

### Case 7: GenAI & LLM in a hospitality context · `GenAI`

**Context**
Management wants to build an **intelligent assistant for the Reservation teams**, able to answer questions about **pricing policies, availability and internal procedures** from **internal PDF documents**.

1. Which architecture do you propose? (RAG, fine-tuning or other)
2. How do you guarantee the system doesn't generate **wrong or out-of-scope answers**?
3. How do you **industrialise and monitor** this system in production?

**Functional constraints / additional information**
- The team has never done formal CI/CD.

**Technical constraints**
- No stack constraint.

---

## Technical questions

Answer the questions in the domains that match your experience. No need to cover everything: **depth beats breadth**.

### DevOps
1. ★★★ A `terraform plan` wants to **destroy and recreate an RDS instance in prod** with no code change. What happened? How do you prevent the destruction?
2. ★★ When should you create a Terraform module? When is it over-engineering? Examples of a good and a bad module.
3. ★★★ How do you organise CI/CD for a **dbt + Airflow mono-repo**? CI steps, CD steps, environment management?
4. ★★ A secret was **accidentally committed 3 commits ago**. How do you handle the incident and prevent it in future?
5. ★★ A **Lambda times out after 15s** on files that can be up to **2 GB**. How do you redesign the system?

### SQL
1. ★★ Difference between `ROW_NUMBER()`, `RANK()` and `DENSE_RANK()`. Give an example where choosing the wrong one produces a silently wrong result.
2. ★★ `LAG` / `LEAD`: explain, and write a query computing **revenue for the current week vs the previous week, per product category, on the same row**.

### Snowflake
1. ★★★ `MERGE` vs `INSERT OVERWRITE`: differences in performance and cost. When do you choose one over the other?
2. ★★★ **Spill to disk** in the query profile: causes and remedies. Is upscaling the warehouse always the right answer?
3. ★★ **Materialized View vs Dynamic Table**: differences, use cases for each.

### dbt
1. ★★ An incremental model does a `MERGE` on **2 billion rows** and takes **40 min**. How do you reduce it without changing the business logic?
2. ★★ Difference between a **singular** and a **generic** dbt test. When do you write one rather than the other? Example of a useful singular test.
3. ★★★ dbt mono-repo with **400 models**, CI takes **35 min**. How do you architect the repo and the CI to reduce this durably?

### Airflow
1. ★★ Difference between `execution_date` and the actual run date. Why does this gap cause bugs, and how do you avoid them?
2. ★★★ A DAG with **80 tasks** runs for **3 hours**; some independent tasks run sequentially. How do you identify and fix the problem?

### Soft skills & posture
1. A manager says *"your dbt pipelines are a black box, I don't trust the numbers"*. How do you respond, and what do you change concretely?
2. A senior data scientist resists all your proposals. After 3 meetings, nothing moves. What do you do?
3. Your tech lead proposes an architecture you think is bad. They are convinced, and the team seems to agree. What do you do?
4. You're given a vague mission: *"improve data quality"*. No scope, no deadline, no budget. How do you start?

### AI-assisted
1. An LLM generates 80 lines of SQL that "look correct". How do you make sure the code is right before merging?
2. Which data engineering tasks does an LLM genuinely make you productive on? Where does it slow you down or put you at risk?

### MLOps & GenAI
1. Describe the full lifecycle of an ML model you put into production (from training to monitoring).
2. What does **experiment tracking** mean to you? Which tools have you used, and how do you ensure your experiments are reproducible?
3. How do you monitor a model in production? Which signals make you trigger a retraining?
4. What is your understanding of **RAG** architectures, and when do you use them rather than fine-tuning?
5. How do you evaluate the quality and reliability of an LLM system in production? Which risks do you identify?

---

## My selection

- [x] Case 1: Data architecture for a startup *(mandatory)*
- [x] Case 2: S3 authentication & authorisation
- [ ] Case 3: Serverless webhook → S3
- [ ] Case 4: Snowflake performance & cost
- [x] Case 5: DataOps for dbt + Airflow
- [ ] Case 6: Heavy ML workload
- [ ] Case 7: GenAI assistant
