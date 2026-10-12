#!/usr/bin/env python3
"""Builds a single-skill bundle of the English skill set, for marketplaces that take one SKILL.md per upload.

    python3 scripts/build_bundle.py [out_dir]

The bundle has SKILL.md (picks the right mode), modes/<skill>.md (each skill's instructions) and references/
(every guide section the skills use, plus the full guide). Writes <out_dir>/day-zero-kit/ and a zip next to it.
"""
import re
import shutil
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "plugins" / "day-zero-kit-en" / "skills"
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "dist"

MODES = [  # skill folder, when to use it
    ("project-setup", "starting a new product: ask the owner's decisions, open project memory, build the infrastructure phase by phase"),
    ("decision-support", "a technical or product decision: paid APIs, plans, analytics or error tools, real-time delivery, OTA, region, credits"),
    ("release-gate", "before a store release, a production deploy, a migration or any change that affects users"),
    ("cost-audit", "the bill went up, the monthly check, database wake-ups, instance caps, spend limits, quotas"),
    ("security-audit", "permissions, secrets, dependencies, scrapers and bots, KVKK, a pre-release security check"),
    ("project-memory", "a task or session ends, a changelog or handoff note, a newcomer starts, a design decision to record"),
    ("alert-audit", "external API errors, credits or quotas running out, jobs that did not run, alarms nobody saw"),
    ("seo-geo-routine", "SEO and GEO set-up and the weekly and monthly jobs, starting with keeping bots off the database"),
]

SKILL_MD = """---
name: day-zero-kit
description: >-
  Sets up a new product's infrastructure from day 0 and keeps checking it as it grows, using the Project Setup
  Guide (Proje Kurulum Rehberi): rules learned from five years of real production incidents on Neon Postgres,
  Go on Cloud Run, Next.js and Expo. Use it when starting a new product or when a decision, a release, a cost
  spike, a security question, an alert gap, SEO work or a handoff comes up; it picks the right mode, asks the
  owner what only the owner can decide, and stops before accounts, payments, production deploys or anything
  public.
---

# Day Zero Kit

This skill does not write the product's code; it builds and checks everything around it: accounts, environments,
database, services, CI/CD, the bot door, alerts, backups, analytics and admin, the mobile remote-control kit and
project memory. Every rule carries an evidence tag: kanıtlı (proven in production), ölçüldü (measured), öneri
(not tried by us; it does not mean optional).

The guide sections under `references/` are in Turkish. Read them as they are and answer in the language the
user writes in. Paths in the mode files are relative to this skill's folder.

## Pick the mode

Read the one mode file that fits the request, then the references it names. If two fit, start with the first
in this list.

{modes}

## Rules for every mode

- Only the product owner opens accounts, pays, accepts terms, registers domains, owns store accounts, approves a
  production deploy, builds and submits mobile apps, messages real users or makes anything public. Stop and ask;
  never do these yourself and never work around a permission.
- Say the daily and monthly cost before anything paid, and get approval.
- Tests and experiments run in the test environment; nothing touches production data.
- Re-read prices, quotas and versions on the official pages in the guide's sources before relying on them;
  the guide is a snapshot of October 2026.
- If a request conflicts with the guide, say so first; the owner decides, and the decision goes to
  `docs/DECISIONS.md`.

Source and full guide (PDF and Markdown): https://github.com/buraltintas/day-zero-kit. Guide text CC BY 4.0,
skills MIT. © 2026 Burak Altıntaş.
"""


def build():
    dest = OUT / "day-zero-kit"
    if dest.exists():
        shutil.rmtree(dest)
    (dest / "modes").mkdir(parents=True)
    (dest / "references").mkdir()
    lines = []
    for name, when in MODES:
        text = (SRC / name / "SKILL.md").read_text()
        body = re.sub(r"^---\n.*?\n---\n", "", text, count=1, flags=re.S).lstrip()
        (dest / "modes" / f"{name}.md").write_text(body)
        lines.append(f"- `modes/{name}.md`: {when}.")
        for ref in (SRC / name / "references").glob("*.md"):
            target = dest / "references" / ref.name
            if not target.exists():
                shutil.copyfile(ref, target)
    (dest / "SKILL.md").write_text(SKILL_MD.replace("{modes}", "\n".join(lines)))
    # every reference a mode names must exist in the bundle
    missing = sorted({m for f in (dest / "modes").glob("*.md")
                      for m in re.findall(r"references/([a-z0-9-]+\.md)", f.read_text())
                      if not (dest / "references" / m).exists()})
    if missing:
        raise SystemExit("missing references: " + ", ".join(missing))
    zpath = OUT / "day-zero-kit-skill.zip"
    with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(dest.rglob("*")):
            if f.is_file():
                z.write(f, f.relative_to(dest))
    print("wrote", dest, "and", zpath, zpath.stat().st_size, "bytes")


if __name__ == "__main__":
    build()
