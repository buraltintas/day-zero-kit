---
name: project-setup
description: >-
  Sets up a new product's infrastructure from day 0 by following the Project Setup Guide (Proje
  Kurulum Rehberi) end to end; first asks the owner the decisions only they can make, then applies the
  setup plan phase by phase and verifies each phase. Use it for a new project or product, a
  from-scratch setup, "prepare the infrastructure", "we are starting a project", the Neon + Go +
  Next.js + Expo stack for a new product, day 0 or "where do we start", even when the user does not
  name the guide. Do not use it for a single setting or service in an existing project; the audit
  skills cover that.
---

# Project setup (day 0)

This skill does not write the product's code; it builds everything around it: accounts, environments, database, services, CI/CD, the bot door, alerts, backups, analytics and admin, the mobile remote-control kit and project memory. The goal is that the team can look only at product flows from the first day. The rules come from live products' bills, logs and incidents, and every rule carries an evidence tag: kanıtlı (proven in our production), ölçüldü (measured), or öneri (not tried by us). Öneri does not mean optional; it means "not yet tried by us".

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Read first

1. `references/how-to-use.md`: how the guide is used and who does what.
2. `references/decisions-and-setup-plan.md`: the decision list, "Day 0: accounts and versions", the agent's setup plan and the definition of done ("Bitti sayılır").
3. `references/project-memory.md`: templates for the files opened on day 0.
4. For the short path and checks: `references/fastest-setup-path.md`, `references/checklist.md`, `references/never.md`, and `references/day-zero-precautions.md` for risks not lived yet.
5. When needed, `references/full-guide.md` (the full guide, large; search by section heading, do not read it end to end).

## Flow

1. **Ask the decisions.** Ask each decision in the list one at a time, in order. If the owner has no preference, propose the guide's default with its reason and wait for approval. Write the answers to `docs/DECISIONS.md` with date and reason. Write a short product summary to `AGENTS.md`; `CLAUDE.md` holds only the line `@AGENTS.md`.
2. **Open the memory files.** `AGENTS.md`, `CHANGELOG.md`, `docs/STATUS.md`, `docs/TODO.md`, `docs/DECISIONS.md` are created in the first commit and updated with every piece of work. Templates are in `references/project-memory.md`.
3. **Apply the plan phase by phase.** Order: Day 0 (before any code), Before the first user, Before the first store release, Ongoing. For each step, produce, then run the step's check. Write the result to `docs/STATUS.md` and `CHANGELOG.md`.
4. **Stop where the plan says STOP (DUR).** Tell the owner in one line what is needed and wait.
5. **At the end,** tick the definition-of-done list item by item; write every unticked item to `docs/TODO.md`.

## Only the product owner does these

Stop and ask; never do them yourself: opening accounts, payments and cards, accepting terms or contracts, domain registration and registrar work, store accounts, approving a production deploy, mobile builds and store submission, version numbers, sending messages to real users, making anything public, granting IAM roles. Never approve on the owner's behalf or work around a permission.

## Fixed rules

- Start on the latest stable versions; never on a version with less than 6 months of support left. Re-read versions on the official pages that day; the guide's table is a snapshot of October 2026.
- Re-verify prices and quotas on the official page in the guide's sources before relying on them.
- A mobile app does not reach the stores without forced update, server-driven notices and in-place warnings, and flags with a kill switch. OTA is recommended but is not part of this rule.
- Public pages and lists that bots crawl (catalogue, detail pages, sitemaps) never hit the database: they are served from memory or ISR and refreshed by a change marker. Reads that do not fit a cache, such as search, filters and fast-changing content, may hit the database; then bot access to them is limited and database wake-ups are measured.
- The test environment and test data never touch production; the local default is always the test environment.
- A paid external API is not switched on before its alternatives and its worst-day bill are written down.
- If a request conflicts with the guide, state the conflict first, then apply the owner's decision and record it in `DECISIONS.md`.

## Report

At the end of each phase give a short report: what was done, check results, what waits on a STOP, and the next step. Keep it short; details belong in `docs/STATUS.md`.
