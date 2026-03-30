# Thanks ChatGPT

from __future__ import annotations

import argparse
import logging
import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Sequence

LOGGER_NAME: Final[str] = "convert_mp3_to_wav"
DEFAULT_FFMPEG_BIN: Final[str] = "ffmpeg"

# Assuming this script lives in RaveSpin/Assets/Tools.
BASE_DIR: Final[Path] = Path(__file__).resolve().parent.parent.parent
DEFAULT_GODOT_DIR: Final[Path] = BASE_DIR / "Godot"
MP3_MARKER_REGEX: Final[re.Pattern[str]] = re.compile(r"_mp3", flags=re.IGNORECASE)


@dataclass(frozen=True)
class ConversionResult:
    source: Path
    destination: Path
    success: bool
    stderr: str | None = None


def configure_logging(verbose: bool) -> logging.Logger:
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
    )
    return logging.getLogger(LOGGER_NAME)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Recursively convert all MP3 files in Godot to WAV using ffmpeg."
    )
    parser.add_argument(
        "--godot-dir",
        type=Path,
        default=DEFAULT_GODOT_DIR,
        help=f"Root folder to scan (default: {DEFAULT_GODOT_DIR})",
    )
    parser.add_argument(
        "--ffmpeg-bin",
        default=DEFAULT_FFMPEG_BIN,
        help=f"ffmpeg binary name or absolute path (default: {DEFAULT_FFMPEG_BIN})",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing WAV files.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable debug logging.",
    )
    return parser.parse_args()


def ensure_ffmpeg_available(ffmpeg_bin: str) -> bool:
    return shutil.which(ffmpeg_bin) is not None


def destination_name_for(source_stem: str) -> str:
    # Avoid misleading names like Song_MP3.wav.
    return MP3_MARKER_REGEX.sub("_WAV", source_stem)


def destination_path_for(source_mp3: Path) -> Path:
    return source_mp3.with_name(f"{destination_name_for(source_mp3.stem)}.wav")


def find_mp3_files(root: Path) -> list[Path]:
    return sorted(path for path in root.rglob("*") if path.is_file() and path.suffix.lower() == ".mp3")


def run_ffmpeg(ffmpeg_bin: str, source: Path, destination: Path, overwrite: bool) -> ConversionResult:
    overwrite_flag = "-y" if overwrite else "-n"
    cmd: Sequence[str] = (
        ffmpeg_bin,
        overwrite_flag,
        "-i",
        str(source),
        str(destination),
    )

    completed = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    success = completed.returncode == 0
    return ConversionResult(
        source=source,
        destination=destination,
        success=success,
        stderr=None if success else completed.stderr.strip() or "Unknown ffmpeg error",
    )


def main() -> int:
    args = parse_args()
    logger = configure_logging(verbose=args.verbose)

    godot_dir = args.godot_dir.resolve()
    logger.info("Scanning for MP3 files in: %s", godot_dir)

    if not godot_dir.is_dir():
        logger.error("Godot directory not found: %s", godot_dir)
        return 1

    if not ensure_ffmpeg_available(args.ffmpeg_bin):
        logger.error("Could not find ffmpeg binary: %s", args.ffmpeg_bin)
        logger.error("Install ffmpeg or pass --ffmpeg-bin with the full executable path.")
        return 1

    mp3_files = find_mp3_files(godot_dir)
    if not mp3_files:
        logger.info("No MP3 files found. Nothing to convert.")
        return 0

    logger.info("Found %d MP3 file(s).", len(mp3_files))

    converted = 0
    failed = 0
    skipped = 0

    for source in mp3_files:
        destination = destination_path_for(source)

        if destination.exists() and not args.overwrite:
            skipped += 1
            logger.info("Skipping existing WAV (use --overwrite): %s", destination)
            continue

        logger.info("Converting: %s -> %s", source, destination)
        result = run_ffmpeg(
            ffmpeg_bin=args.ffmpeg_bin,
            source=source,
            destination=destination,
            overwrite=args.overwrite,
        )

        if result.success:
            converted += 1
            logger.debug("Converted successfully: %s", result.destination)
            continue

        failed += 1
        logger.error("Conversion failed: %s", result.source)
        if result.stderr:
            logger.error("ffmpeg error: %s", result.stderr)

    logger.info("Done. converted=%d skipped=%d failed=%d", converted, skipped, failed)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
