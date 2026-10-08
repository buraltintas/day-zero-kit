---
name: decision-support
description: >-
  When a technical or product decision comes up, lays out the options, the default, the cost and the
  risk from the measured experience in the Project Setup Guide (Proje Kurulum Rehberi), and records
  the decision in DECISIONS.md. Use it for every "should we do this or that" question: switching on a
  paid API (maps, models, SMS, e-mail), upgrading a plan, choosing an analytics or error-tracking
  tool, real-time delivery (WebSocket, SSE, polling, push), OTA, region and data location, EAS or an
  own build pipeline, content automation, startup credits.
---

# Decision support

The owner makes the decision; this skill makes it easier. Match the question to the guide's decision list and section, put the options side by side with real numbers, and record what was decided.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Flow

1. Restate the question in one sentence: what is being decided and why now.
2. Find it in the decision list in `references/decisions-and-setup-plan.md`. If it is not there, find the closest section: cost in `cost.md`, `free-tiers.md`, `expensive-external-apis.md`; architecture in `principles.md`, `architecture.md`; messaging in `realtime-and-messaging.md`; analytics and admin in `analytics-and-admin.md`; mobile distribution in `mobile-distribution.md`; social posting in `content-automation.md`; credits in `startup-credits.md`.
3. Check `case-book.md` (the case book) for a lived case on the same topic. If there is one, put it first: experience comes before documentation.
4. Compare the options: what each gives, monthly and worst-day cost, quotas and caps, retention and data-location terms, the exit path, and our evidence level. If the call volume is unknown, write an explicit worst-day assumption (for example N requests a day) and have the owner confirm it.
5. State the guide's default and its reason. If the default does not fit this product, say why.
6. Re-verify prices and terms on the official page that day; mark what you could not verify.
7. When the owner decides, record it in `docs/DECISIONS.md`.

## Decision record

```
## K-<number> <decision title>
Date: <YYYY-MM-DD>. Status: in force.
Decided by: product owner.
Context: <why now>
Decision: <what>
Options: <why not chosen>
Cost: ~... a day, ~... a month, worst day ~...; cap and alarm: ...
Result: <what changes>
Revisit: <date or condition>
Link: <guide section, official page, commit>
```

The format is the guide's `docs/DECISIONS.md` template (`references/project-memory.md`); a changed decision is never deleted, it is linked as "replaced by: K-...".

## Take care

- Before proposing anything paid, give the daily and monthly figure; do not propose switching it on before a cap and an alarm are written.
- Do not choose the architecture for a credit; credits end, architecture stays.
- Do not present the uncertain as certain. Keep the evidence tag: kanıtlı if it runs in our production, ölçüldü if we measured it, otherwise öneri.
