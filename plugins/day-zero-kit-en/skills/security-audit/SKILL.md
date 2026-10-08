---
name: security-audit
description: >-
  Audits a project's security and bot protection against the Project Setup Guide (Proje Kurulum
  Rehberi) and produces findings and fixes for least privilege and service accounts, secrets,
  dependencies and the supply chain, authorization (reading someone else's record), the bot door and
  crawler lists, KVKK (Turkish data protection law) and the day-0 precautions. Use it for a security
  review, permissions, IAM, secrets, "someone is scraping our data", bots, scrapers (for example
  cloud-hosted scrapers on Alibaba or Tencent networks), AI crawlers, robots.txt, KVKK, a data breach,
  or a pre-release security check.
---

# Security audit

The goal is to find the gaps and give the order in which to close them. The audit is read-only; IAM, secret and production changes go to the product owner. Never write an open weakness in detail anywhere public (an issue, a PR description, a shared document); report it to the owner.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Read

- `references/layers-5-9-and-bots.md`: edge and DNS, Cloud Run, CI/CD, the security and bots layer, the stance on bots and the door skeleton.
- `references/day-zero-precautions.md`: risks we have not lived yet that must be prevented on day 0.
- `references/kvkk.md`, `references/repos-and-sizes.md` (new repo rules), `references/never.md`, `references/case-book.md`.

## Flow

1. **Identity and permissions:** does every service run with its own role-less account; is the default account with the Editor role in use; is the build account separate; do people have two-factor sign-in and at least two admins.
2. **Secrets:** are there secrets in the repo, plain environment variables, logs, error messages or URLs; does every secret have a single active version and a written rotation order.
3. **Application authorization:** is every read and write checked on the server against the session owner; with two test accounts, in the test environment only, try to read one account's record with the other. Never probe production.
4. **Dependencies:** install scripts, a release-age rule, the lockfile and only `npm ci` in CI; any known vulnerability in the framework version.
5. **Bots:** is the door on the first line of the proxy; are robots.txt and the door generated from the same list; did each new rule run in shadow first; are crawler IP lists refreshed monthly; do public reads wake the database.
6. **KVKK:** data location, the processor list, the transfer basis, and a "who saw what" record for a breach.

## Report

```
Critical (today): <finding | impact | fix>
High (this week): ...
Medium: ...
Owner must do: <IAM, accounts, payments and the like>
```

Never open a new bot rule as a blocking rule; run it in shadow first and decide with at least 7 days of logs.

**Emergency:** If a scraper or an attack is taking the service down, tell the owner; with their approval apply one temporary blocking rule (with an end time, logged). Then make it permanent the normal way, in shadow with at least 7 days of logs, or remove it.
