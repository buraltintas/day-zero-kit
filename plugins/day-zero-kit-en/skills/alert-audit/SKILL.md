---
name: alert-audit
description: >-
  Checks, against the Project Setup Guide (Proje Kurulum Rehberi), that every external dependency's
  and every budget's failure signal reaches the right person through the right channel in time; lists
  missing alarms, unowned signals and untested alerts, and sets up notify() routing and an end-to-end
  alarm test. Use it for external API errors (401, 402, 429, 5xx), credits or balance running out,
  token expiry, quotas, a scheduled job that did not run, backup verification, webhook failures, "why
  did nobody notice", alarms, observability, Sentry or error tracking.
---

# Alert audit

A warning nobody sees is not a warning. In our products most failures did signal, but the signal reached nobody: an API credit ran out and went unnoticed for 30 days, a payment webhook returned errors for at least 21 days. This skill checks that every signal has an owner, a threshold and a channel.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Read

- `references/alerts.md`: sources, levels (urgent, today, weekly), the "what, when, to whom" table, message-writing rules, notify() and the log filter, ready-made service or own setup.
- `references/layer-10-observability.md`, `references/backup-and-restore.md`, `references/analytics-and-admin.md`, `references/content-automation.md`, and `references/case-book.md` for the incidents behind these rules.

## Flow

1. Build the inventory (note any payment or store webhook without signature verification; that is security-audit's job): every external API, payment and store webhook, scheduled job, backup, token, quota, budget, and domain or certificate expiry.
2. For each, ask: what is the failure signal, the threshold, the level, the channel, who acts, are there at least two receivers, does the alarm depend on the very system that failed.
3. Write the gaps to a table and complete it from the guide's table.
4. Fire every alarm once end to end with a fake failure: in the test environment or behind a test flag, without touching live data. The test flag is the guide's recipe: add a temporary "TEST" to the policy name, make the job fail on purpose, restore the name after the alarm closes. An alarm that exists only in production is tested there the same way, without touching data or users, with the owner's approval. Confirm the receiver actually got it. Alert policy or production changes go through the owner's approval and a recorded script. For absence alarms, remember that Cloud Monitoring waits at most 23.5 hours.
5. Check that messages speak the owner's language: what happened, the effect on users, what to do, a link. Stack traces do not go to the owner.

## Report

```
Unowned signals: <list>
Missing alarms: <signal | proposed threshold | level | channel | owner>
Untested alarms: <list>
Set up this week: <ordered>
```
