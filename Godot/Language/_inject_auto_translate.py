# -*- coding: utf-8 -*-
"""Ensure each scene node with translatable text has auto_translate once before first text.* line."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "UI"


def node_type_from_header(line: str) -> str | None:
    m = re.search(r'type="([^"]+)"', line)
    return m.group(1) if m else None


def first_translatable_line_index(lines: list[str]) -> int | None:
    for i, line in enumerate(lines):
        stripped = line.lstrip()
        if stripped.startswith("text = ") or stripped.startswith("placeholder_text = ") or re.match(
            r"popup/item_\d+/text = ", stripped
        ):
            return i
    return None


def patch_file(path: Path) -> bool:
    raw = path.read_text(encoding="utf-8")
    # Strip prior auto_translate lines; we re-insert deterministically
    stripped_lines = [ln for ln in raw.split("\n") if ln.strip() != "auto_translate = true"]
    text = "\n".join(stripped_lines)
    parts = re.split(r"(?=\[node )", text)
    out_parts: list[str] = []
    for part in parts:
        if not part.startswith("[node "):
            out_parts.append(part)
            continue
        lines = part.split("\n")
        header = lines[0]
        ntype = node_type_from_header(header)
        if ntype in ("Label3D",):
            out_parts.append(part)
            continue
        idx = first_translatable_line_index(lines)
        if idx is None:
            out_parts.append(part)
            continue
        head = "\n".join(lines[:idx])
        if "auto_translate = true" in head:
            out_parts.append(part)
            continue
        indent = lines[idx][: len(lines[idx]) - len(lines[idx].lstrip())]
        lines.insert(idx, f"{indent}auto_translate = true")
        out_parts.append("\n".join(lines))
    new_text = "".join(out_parts)
    if new_text != raw:
        path.write_text(new_text, encoding="utf-8")
        return True
    return False


def main() -> None:
    n = 0
    for tscn in sorted(ROOT.rglob("*.tscn")):
        if patch_file(tscn):
            print("patched", tscn.relative_to(ROOT))
            n += 1
    print("total files patched:", n)


if __name__ == "__main__":
    main()
