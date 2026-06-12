#!/usr/bin/env python3
"""Validate Korean translation catalogs (.po) for okrbest-docs.

Checks that translated msgstr entries preserve the rST/MyST markup of their
msgid (roles, literals, substitutions, link URLs, surrounding whitespace),
and reports per-file translation statistics.

Untranslated and fuzzy entries are NOT errors: both render the English
source at build time (safe fallback). Only broken markup in a *translated*
entry is an error.

Usage:
    pipenv run python scripts/validate-ko-po.py [--stats-only] [--quiet] PATH [PATH...]

PATH is a .po file or a directory (searched recursively for *.po) under
source/locales/ko/LC_MESSAGES/.

Exit codes:
    0  all files parsed, no markup errors (untranslated entries allowed)
    1  markup-parity errors found in translated entries
    2  parse failure, missing file, or path outside the ko locales tree
    3  usage error
"""

import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

try:
    from babel.messages.pofile import read_po
except ImportError:
    print(
        "ERROR: babel을 찾을 수 없습니다. 'pipenv run python scripts/validate-ko-po.py ...'로 실행하세요.",
        file=sys.stderr,
    )
    sys.exit(2)

REPO_ROOT = Path(__file__).resolve().parents[1]
LOCALES_ROOT = REPO_ROOT / "source" / "locales" / "ko" / "LC_MESSAGES"

# Markup extraction patterns. Double-backtick literals are masked first so
# their contents never match the role/substitution patterns below.
RE_LITERAL = re.compile(r"``([^`]+)``")
RE_ROLE = re.compile(r":([a-zA-Z][a-zA-Z0-9_+:.-]*):`([^`]+)`")
RE_EXTLINK = re.compile(r"`[^`<]*<([^`>]+)>`__?")
RE_SUBSTITUTION = re.compile(r"\|[^|\s]+\|")
RE_MDLINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
RE_ROLE_TARGET = re.compile(r"^.*<([^>]+)>\s*$", re.DOTALL)


@dataclass
class Markup:
    roles: dict = field(default_factory=dict)        # (name, target) -> count
    literals: dict = field(default_factory=dict)     # content -> count
    substitutions: dict = field(default_factory=dict)
    urls: dict = field(default_factory=dict)
    bold_marks: int = 0
    lead_ws: str = ""
    trail_ws: str = ""


def _bump(d, key):
    d[key] = d.get(key, 0) + 1


def extract_markup(text):
    m = Markup()
    m.lead_ws = text[: len(text) - len(text.lstrip())]
    m.trail_ws = text[len(text.rstrip()):]

    def mask_literal(match):
        _bump(m.literals, match.group(1))
        return "\x00" * len(match.group(0))

    masked = RE_LITERAL.sub(mask_literal, text)

    def mask_role(match):
        name, body = match.group(1), match.group(2)
        tmatch = RE_ROLE_TARGET.match(body)
        # Roles whose body is a target (or text <target>): record the target;
        # the display text part is translatable and intentionally ignored.
        target = tmatch.group(1) if tmatch else (body if body.startswith(("/", "#")) else "")
        _bump(m.roles, (name, target))
        return "\x00" * len(match.group(0))

    masked = RE_ROLE.sub(mask_role, masked)

    for match in RE_EXTLINK.finditer(masked):
        _bump(m.urls, match.group(1))
    masked = RE_EXTLINK.sub(lambda mt: "\x00" * len(mt.group(0)), masked)

    for match in RE_MDLINK.finditer(masked):
        _bump(m.urls, match.group(1))

    for match in RE_SUBSTITUTION.finditer(masked):
        _bump(m.substitutions, match.group(0))

    m.bold_marks = masked.count("**")
    return m


def _diff_counts(kind, expected, actual, issues):
    for key, count in expected.items():
        have = actual.get(key, 0)
        if have < count:
            issues.append(f"{kind} 누락/변형: {key!r} (원문 {count}회, 번역 {have}회)")
    for key, count in actual.items():
        if key not in expected:
            issues.append(f"{kind} 원문에 없음: {key!r}")


def check_message(msgid, msgstr):
    issues = []
    src, dst = extract_markup(msgid), extract_markup(msgstr)
    _diff_counts("롤(:doc:/:ref: 등)", src.roles, dst.roles, issues)
    _diff_counts("리터럴(``...``)", src.literals, dst.literals, issues)
    _diff_counts("치환자(|...|)", src.substitutions, dst.substitutions, issues)
    _diff_counts("URL", src.urls, dst.urls, issues)
    if src.bold_marks != dst.bold_marks:
        issues.append(f"** 표식 개수 불일치 (원문 {src.bold_marks}, 번역 {dst.bold_marks})")
    if src.lead_ws != dst.lead_ws:
        issues.append("앞 공백 불일치")
    if src.trail_ws != dst.trail_ws:
        issues.append("뒤 공백 불일치")
    return issues


@dataclass
class FileReport:
    path: Path
    translated: int = 0
    fuzzy: int = 0
    untranslated: int = 0
    issues: list = field(default_factory=list)  # (lineno, text)
    parse_error: str = ""

    @property
    def total(self):
        return self.translated + self.fuzzy + self.untranslated


def validate_file(path, markup_checks=True):
    report = FileReport(path=path)
    try:
        with open(path, "rb") as f:
            catalog = read_po(f, locale="ko", abort_invalid=True)
    except Exception as exc:  # noqa: BLE001 - report any parse failure
        report.parse_error = str(exc)
        return report

    for msg in catalog:
        if not msg.id:
            continue  # header entry
        msgid = msg.id[0] if isinstance(msg.id, (list, tuple)) else msg.id
        msgstr = msg.string or ""
        if isinstance(msgstr, (list, tuple)):
            msgstr = msgstr[0] if msgstr else ""
        if msg.fuzzy:
            report.fuzzy += 1
            continue  # fuzzy renders English; markup checked after unfuzzying
        if not msgstr:
            report.untranslated += 1
            continue
        report.translated += 1
        if markup_checks:
            for issue in check_message(msgid, msgstr):
                report.issues.append((msg.lineno, issue))
    return report


def iter_po_files(paths):
    files, bad = [], []
    for raw in paths:
        p = Path(raw).resolve()
        try:
            p.relative_to(LOCALES_ROOT)
        except ValueError:
            bad.append(f"{raw}: source/locales/ko/LC_MESSAGES/ 외부 경로")
            continue
        if p.is_dir():
            found = sorted(p.rglob("*.po"))
            if not found:
                bad.append(f"{raw}: 디렉토리에 .po 파일 없음")
            files.extend(found)
        elif p.is_file() and p.suffix == ".po":
            files.append(p)
        else:
            bad.append(f"{raw}: .po 파일이 아니거나 존재하지 않음")
    return files, bad


def main(argv=None):
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("paths", nargs="*", metavar="PATH")
    parser.add_argument("--stats-only", action="store_true",
                        help="마크업 검사 생략, 번역 통계만 출력")
    parser.add_argument("--quiet", action="store_true", help="오류만 출력")
    try:
        args = parser.parse_args(argv)
    except SystemExit as exc:
        return 3 if exc.code not in (0,) else 0
    if not args.paths:
        parser.print_usage(sys.stderr)
        return 3

    files, bad = iter_po_files(args.paths)
    for line in bad:
        print(f"ERROR: {line}", file=sys.stderr)
    if bad:
        return 2

    totals = {"translated": 0, "fuzzy": 0, "untranslated": 0}
    has_parse_error = has_issues = False

    for path in files:
        report = validate_file(path, markup_checks=not args.stats_only)
        rel = path.relative_to(REPO_ROOT)
        if report.parse_error:
            has_parse_error = True
            print(f"ERROR {rel}: 파싱 실패 — {report.parse_error}")
            continue
        totals["translated"] += report.translated
        totals["fuzzy"] += report.fuzzy
        totals["untranslated"] += report.untranslated
        stat = f"번역 {report.translated}/{report.total}, fuzzy {report.fuzzy}, 미번역 {report.untranslated}"
        if report.issues:
            has_issues = True
            print(f"FAIL {rel} ({stat})")
            for lineno, issue in report.issues:
                print(f"  {rel}:{lineno}: {issue}")
        elif not args.quiet:
            print(f"OK   {rel} ({stat})")

    if not args.quiet or args.stats_only:
        done = totals["translated"]
        total = sum(totals.values())
        pct = (100 * done / total) if total else 0.0
        print(f"합계: 번역 {done}/{total} ({pct:.1f}%), fuzzy {totals['fuzzy']}, 미번역 {totals['untranslated']}")

    if has_parse_error:
        return 2
    if has_issues:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
