# Interview Prep — Credit Risk Analytics Platform

Organized by project phase. Each answer follows STAR (Situation, Task, Action, Result) —
this is the structure interviewers expect, and it forces a specific, credible answer
instead of a vague one.

---

## Phase 1: Environment & Database Setup

**Q: Walk me through how you set up this project.**
A: I set up a full local stack — Python, PostgreSQL, and Git — then designed a
relational schema across 4 tables (customers, credit_history, loan_applications,
transactions) connected by foreign keys on customer_id, loaded ~57,000 rows of
data via psql's \copy, and validated the data before doing any analysis.

**Q: What problems did you run into, and how did you solve them?**
A: The first real issue was that after installing PostgreSQL, my terminal couldn't
find the `psql` command — it said "not recognized." I diagnosed this as a PATH
problem: Windows didn't know where the PostgreSQL binaries lived. I found the
install directory (C:\Program Files\PostgreSQL\18\bin), added it to my system's
PATH environment variable, and restarted my terminal so the change would take
effect. That fixed it. It taught me that "command not found" errors are usually
a PATH issue, not a broken install.

**Q: Did you hit any errors loading data? How did you debug them?**
A: Yes — when I tried loading credit_history, loan_applications, and transactions
before customers, I got foreign key violation errors like "Key (customer_id)
is not present in table customers." This happened because those three tables
all reference customer_id in the customers table, and customers was still empty
(a file path issue on the first load attempt). Once I loaded customers first,
the rest loaded cleanly. It reinforced why load order matters when foreign keys
exist — you always load the "parent" table before any "child" tables that
reference it.

---

## Phase 2: Data Quality

**Q: How did you validate your data before modeling?**
A: I ran targeted SQL checks rather than assuming the data was clean: checked
for duplicate primary keys, confirmed age and income fell in realistic ranges,
checked categorical columns like gender and employment_type for inconsistent
values, and investigated NULLs in loan_default.

**Q: Tell me about a data quality issue you found.**
A: loan_default was NULL for about 4,000 of my 7,500 loan applications. Instead
of assuming this was bad data, I checked whether it correlated with something —
it turned out every NULL corresponded exactly to an undisbursed loan. That makes
sense logically: you can't default on money you never received. So I decided to
filter my model training data to disbursed_flag = 1 only, rather than dropping
rows or filling in a fake default value, which would have introduced bias.

---

## Phase 3: SQL Analysis
(add after finishing this phase — e.g. questions about JOIN vs subquery,
why GROUP BY, what insight surprised you)

## Phase 4: ML Model
(add after training — e.g. why this algorithm, how you handled imbalanced
classes, what feature mattered most)

## Phase 5: Risk Scoring
(add after this phase)

## Phase 6: Dashboard
(add after this phase)

## Learning New Tools / Documentation

**Q: If you don't know a command, how do you find out what it does?**
A: I follow a specific order rather than randomly searching. First, I check
the tool's built-in help — most CLI tools support --help, like `psql --help`
or `pip --help`, which prints every available flag right in the terminal. For
psql specifically, there's also a `\?` command that lists all of its
shortcut commands. If that's not enough, I go to official documentation —
for example postgresql.org/docs for SQL and psql, or scikit-learn.org for
model-specific questions. For quick "how do I do X" problems, I search with
specific phrasing — "psql copy csv" rather than just "psql" — which gets me
to the right doc page or Stack Overflow answer faster. I think this matters
more than memorizing every flag, since even experienced engineers look things
up constantly — the real skill is knowing where to look and how to read
what you find.

## Learning New Tools / Documentation

**Q: If you don't know a command, how do you find out what it does?**
A: I follow a specific order rather than randomly searching. First, I check
the tool's built-in help — most CLI tools support --help, like `psql --help`
or `pip --help`, which prints every available flag right in the terminal. For
psql specifically, there's also a `\?` command that lists all of its
shortcut commands. If that's not enough, I go to official documentation —
for example postgresql.org/docs for SQL and psql, or scikit-learn.org for
model-specific questions. For quick "how do I do X" problems, I search with
specific phrasing — "psql copy csv" rather than just "psql" — which gets me
to the right doc page or Stack Overflow answer faster. I think this matters
more than memorizing every flag, since even experienced engineers look things
up constantly — the real skill is knowing where to look and how to read
what you find.

## Python Virtual Environments

**Q: Why do you use a virtual environment?**
A: Without one, every pip install goes into a single global Python location
shared across all projects on the machine, which causes version conflicts —
if two projects need different versions of the same package, installing one
can break the other. A venv creates an isolated, project-specific copy of
Python and pip, so dependencies stay contained to that project. It also makes
the project reproducible — anyone else can recreate the exact same environment
from a requirements file, which matters for collaboration and deployment.
## Phase 4: ML Model — Feature Engineering & Baseline Model

**Q: Tell me about a bug you had to debug in this project.**
A: After merging my tables and one-hot encoding categorical columns, my feature
set jumped to 2,425 columns — way too many for ~3,400 rows of data. I isolated
it by checking the cardinality of each text column individually, and found
credit_id — a leftover ID column from one of my source tables — had over
2,300 unique values. Since I'd meant to drop ID columns but missed this one,
one-hot encoding created a near-useless column for almost every single row.
I added it to my drop list and the feature count dropped to a sane ~117.
It taught me to always check unique value counts on categorical columns before
encoding, not just column names.

**Q: Why did scaling matter for your model?**
A: My initial Logistic Regression threw a ConvergenceWarning and had a
modest ROC-AUC of 0.65. My features were on very different scales — income
in the hundreds of thousands versus ratios between 0 and 1 — which made the
optimizer struggle. After applying StandardScaler to normalize all numeric
features to mean 0 and standard deviation 1, the warning disappeared and
ROC-AUC improved to 0.71. It was a concrete example of how preprocessing
can matter as much as model choice.


## Phase 4: ML Model — Model Selection

**Q: How did you choose your final model?**
A: I trained three models — Logistic Regression, Random Forest, and XGBoost —
and compared them on ROC-AUC and recall for the default class, since that's
the outcome that matters most in lending. Logistic Regression actually
outperformed both tree-based models (0.71 vs 0.68 ROC-AUC). This made sense
given my dataset size — about 3,400 rows isn't enough for more complex models
to outperform a well-regularized linear model, and both tree models landed
in nearly the same place, suggesting they'd hit a similar ceiling on this data.
I picked based on validation results, not model complexity — and Logistic
Regression has the added benefit of interpretable coefficients, which matters
in lending where decisions need to be explainable to underwriters and regulators.

**Q: If you had more time or more data, what would you try next?**
A: I'd want more historical rows to see if the tree-based models start
outperforming Logistic Regression as data volume grows — that's the typical
pattern. I'd also try hyperparameter tuning with cross-validation rather than
a single train/test split, and look at feature engineering — like creating
interaction features between credit score and debt-to-income ratio — since
raw features alone may be underselling what the tree models could capture.

## Phase 5: Risk Scoring

**Q: How did you turn a model prediction into something usable?**
A: The model outputs a raw default probability, which isn't intuitive for an
underwriter to act on quickly. I converted it to a 0-100 score by inverting
the probability — (1 - probability) * 100 — so a higher score means lower
risk, matching how real credit scores like CIBIL work. I then bucketed scores
into Low/Medium/High risk bands with 70 and 40 as cutoffs. I was explicit that
these cutoffs are a business/design decision, not a statistically derived
threshold — in a real deployment, these would likely be tuned based on the
lender's risk appetite and approval capacity.