---
name: cost-audit
description: >-
  Audits a project's cloud, database and external API cost against the measured rules in the Project
  Setup Guide (Proje Kurulum Rehberi) and produces a concrete fix list for a database that never
  sleeps, instance caps, spend caps, budget alarms, free tiers, build minutes, logs and image storage.
  Use it when the bill goes up, for the monthly check, or when someone asks "what does this cost",
  "why so much", about Neon CU-hours, the Cloud Run bill, budgets, quotas or "can we stay in the free
  tier".
---

# Cost audit

What inflates a bill is usually invisible repetition: database wake-ups, builds, bot requests, connections left open. This skill measures them and compares them with the guide's rules. It does not change settings itself; it lists the changes and their effect and leaves the decision to the owner.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Read

- `references/bots-and-cost-summary.md` and `references/cost.md`: what it costs, the line-by-line model.
- `references/layers-1-4.md`: Postgres settings (pool floor 0, 90 s idle close, wake budget).
- `references/free-tiers.md`: each service's limit, what happens when it is exceeded, monitoring.
- `references/performance.md`, `references/artifact-registry-and-build.md`, `references/expensive-external-apis.md`.
- `references/case-book.md`: cost cases and what each fix saved.

## Flow

1. Read the numbers (read-only; name the project explicitly in every command): the last 30 days' bill by SKU, Neon daily CU-hours and wake-ups, the Cloud Run instance peak and max-instances, build minutes, log volume, image repository size, external API call counts.
2. Compare each line with the guide's target. Examples: if the database wakes more than a few times a day, find what wakes it (a scheduler, a bot path, a public read); if max-instances is far above the 30-day peak, lower it; if there is no spend cap and no three-threshold budget alarm, add them.
3. Compute each fix's monthly effect and write its evidence. Re-read the exchange rate that day.
4. If a fix can affect users (a cap set too low, a free tier that stops when full), state the risk plainly.

## Report

```
This month: ~<amount>; target: ~<amount>
Fixes (by effect):
1. <what> | ~<monthly saving> | risk: <...> | evidence: <...>
Alarms and caps: <present/missing list>
Needs owner decision: <list>
```
