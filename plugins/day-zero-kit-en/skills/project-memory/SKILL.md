---
name: project-memory
description: >-
  Opens, updates and freshness-checks a project's memory files (AGENTS.md, CHANGELOG.md,
  docs/STATUS.md, docs/TODO.md, docs/DECISIONS.md, DESIGN.md, the handoff note) using the templates in
  the Project Setup Guide (Proje Kurulum Rehberi), so a new developer or AI agent can get productive
  fast. Use it when a task or session ends, for "what happened, what is done", "what is next", writing
  a changelog, preparing a handoff, a new developer starting, recording a design decision, or when
  docs have gone stale.
---

# Project memory

The code says what it does; only the memory files say why it is that way, where things stand and what comes next. This skill keeps them correct and current.

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the user writes in.

## Files and the question each answers

| File | Answers |
|---|---|
| `AGENTS.md` (CLAUDE.md holds only `@AGENTS.md`) | How to work here: product, commands, branches, deploy rule, never-do list |
| `CHANGELOG.md` | What happened: user-visible change first, dated, linked to the commit |
| `docs/STATUS.md` | Where things stand: what is live, what is in progress, what is blocked |
| `docs/TODO.md` | What is next: owner, priority; done items move to the CHANGELOG |
| `docs/DECISIONS.md` | Why it is this way: date, decision, reason, options, revisit date |
| `DESIGN.md` | Design rules and decisions; read before any UI work |
| Handoff note | Done, not done, next step, risks |

Templates are in `references/proje-hafizasi.md`, design decisions in `references/tasarim-sistemi.md`.

## Flow

- **When a task ends:** write the CHANGELOG entry in the same commit; update STATUS; remove the finished TODO item; add any decision to DECISIONS.
- **When a session ends:** write a handoff note. Never leave long work in a temp folder (/tmp and the like); commit it to a permanent folder and branch.
- **For a newcomer:** AGENTS.md first, then STATUS, TODO, DECISIONS, and the last two weeks of the CHANGELOG.
- **Freshness check (monthly):** run the commands in AGENTS.md; look for dead paths and stale rules; when the CHANGELOG passes 40 KB, move the old part to an archive; check that "Unreleased" gets closed.

## Take care

- Never write a secret's value to any file; write only where it lives.
- One session owns one repo and branch at a time; do not send work to another session unasked.
- Where a written rule is not enough (a skipped test, a forgotten CHANGELOG), enforce it with a hook or branch protection.
