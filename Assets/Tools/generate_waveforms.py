import os
import math
import time
import subprocess
from pathlib import Path

# Assuming we're in Ravespin / assets / tools
BASE_DIR = Path(__file__).resolve().parent.parent.parent
MUSIC_DIR = BASE_DIR / "Godot" / "Music" / "Song Data"

FFMPEG_BIN = "ffmpeg"
FFPROBE_BIN = "ffprobe"

PIXELS_PER_MINUTE = 1024 # 1024 pixels per minute of runtime

AUDIO_EXTS = {".wav", ".ogg", ".mp3"}


def get_duration_seconds(path: Path) -> float:
    """Use ffprobe to get the duration in seconds. Returns 0.0 if it fails."""
    try:
        result = subprocess.run(
            [
                FFPROBE_BIN,
                "-v",
                "error",
                "-show_entries",
                "format=duration",
                "-of",
                "default=noprint_wrappers=1:nokey=1",
                str(path),
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=False,  # bytes
            check=False,
        )
        duration_bytes = result.stdout or b""
        duration_str = duration_bytes.decode("utf-8", errors="ignore").strip()
        return float(duration_str) if duration_str else 0.0
    except Exception as e:
        print(f"Failed to get duration for {path}: {e}")
        return 0.0


def generate_waveform(path: Path) -> Path | None:
    """Generate one waveform PNG next to the audio file. Returns PNG path or None."""
    duration_sec = get_duration_seconds(path)
    if duration_sec <= 0:
        print(f"Skipping {path} (could not get duration)")
        return None

    duration_minutes = duration_sec / 60.0
    width = max(1, math.ceil(duration_minutes * PIXELS_PER_MINUTE))
    height = 240

    output_path = path.with_name(path.stem + "_WAVEFORM.png")

    filter_str = f"aformat=channel_layouts=mono,showwavespic=s={width}x{height}"

    cmd = [
        FFMPEG_BIN,
        "-y",
        "-i",
        str(path),
        "-filter_complex",
        filter_str,
        "-frames:v",
        "1",
        str(output_path),
    ]

    print(f"Generating waveform for {path} -> {output_path} (size {width}x{height})")
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=False)

    if result.returncode != 0:
        stderr_text = (result.stderr or b"").decode("utf-8", errors="ignore")
        print(f"ffmpeg failed for {path} (code {result.returncode})")
        print(stderr_text)
        return None

    if not output_path.is_file():
        print(f"Waveform PNG not created for {path}")
        return None

    return output_path

# By defualt, GOdot's going to try make its own .import file for our waveform...
# usually it's good enough but we need to tweak it, otherwise we will have a capacity and rendering disaster
def patch_import_file(import_path: Path) -> None:
    try:
        text = import_path.read_text(encoding="utf-8")
    except Exception as e:
        print(f"Could not read {import_path}: {e}")
        return

    lines = text.splitlines()
    new_lines: list[str] = []

    current_section = None
    in_remap = False
    in_params = False

    # Track whether we have seen/overridden certain keys so we can append if missing
    seen_importer = False
    seen_type = False
    seen_metadata = False

    # Keys to replace in [params]
    params_keys = {
        "compress/mode",
        "compress/high_quality",
        "compress/lossy_quality",
        "compress/uastc_level",
        "compress/rdo_quality_loss",
        "compress/hdr_compression",
        "compress/normal_map",
        "compress/channel_pack",
        "mipmaps/generate",
        "mipmaps/limit",
        "roughness/mode",
        "roughness/src_normal",
        "process/channel_remap/red",
        "process/channel_remap/green",
        "process/channel_remap/blue",
        "process/channel_remap/alpha",
        "process/fix_alpha_border",
        "process/premult_alpha",
        "process/normal_map_invert_y",
        "process/hdr_as_srgb",
        "process/hdr_clamp_exposure",
        "process/size_limit",
        "detect_3d/compress_to",
    }

    for line in lines:
        stripped = line.strip()

        if stripped.startswith("[") and stripped.endswith("]"):
            # Leaving a section; if it's [remap] or [params], we may need to append keys
            if in_remap:
                if not seen_importer:
                    new_lines.append('importer="texture"')
                if not seen_type:
                    new_lines.append('type="CompressedTexture2D"')
                if not seen_metadata:
                    new_lines.append(
                        'metadata={"imported_formats": ["s3tc_bptc", "etc2_astc"], "vram_texture": true}'
                    )

            if in_params:
                # Append our full desired params set after filtering
                new_lines.extend(
                    [
                        "compress/mode=2",
                        "compress/high_quality=false",
                        "compress/lossy_quality=0.7",
                        "compress/uastc_level=0",
                        "compress/rdo_quality_loss=0.0",
                        "compress/hdr_compression=0",
                        "compress/normal_map=2",
                        "compress/channel_pack=1",
                        "mipmaps/generate=false",
                        "mipmaps/limit=-1",
                        "roughness/mode=1",
                        'roughness/src_normal=""',
                        "process/channel_remap/red=8",
                        "process/channel_remap/green=8",
                        "process/channel_remap/blue=8",
                        "process/channel_remap/alpha=3",
                        "process/fix_alpha_border=false",
                        "process/premult_alpha=false",
                        "process/normal_map_invert_y=false",
                        "process/hdr_as_srgb=false",
                        "process/hdr_clamp_exposure=false",
                        "process/size_limit=0",
                        "detect_3d/compress_to=1",
                    ]
                )

            # Start new section
            current_section = stripped
            in_remap = stripped == "[remap]"
            in_params = stripped == "[params]"

            # Reset flags as we enter a new [remap]
            if in_remap:
                seen_importer = False
                seen_type = False
                seen_metadata = False

            new_lines.append(line)
            continue

        if in_remap:
            # Keep everything except importer/type/metadata, which we override
            if stripped.startswith("importer="):
                new_lines.append('importer="texture"')
                seen_importer = True
                continue
            if stripped.startswith("type="):
                new_lines.append('type="CompressedTexture2D"')
                seen_type = True
                continue
            if stripped.startswith("metadata="):
                new_lines.append(
                    'metadata={"imported_formats": ["s3tc_bptc", "etc2_astc"], "vram_texture": true}'
                )
                seen_metadata = True
                continue

            new_lines.append(line)
            continue

        if in_params:
            # Drop any param keys we control; we'll append our full set at section end
            if "=" in stripped:
                key = stripped.split("=", 1)[0].strip()
                if key in params_keys:
                    continue

            new_lines.append(line)
            continue

        # Any other section: keep line as-is
        new_lines.append(line)

    # End of file: if ended while still in remap/params, append our keys
    if in_remap:
        if not seen_importer:
            new_lines.append('importer="texture"')
        if not seen_type:
            new_lines.append('type="CompressedTexture2D"')
        if not seen_metadata:
            new_lines.append(
                'metadata={"imported_formats": ["s3tc_bptc", "etc2_astc"], "vram_texture": true}'
            )

    if in_params:
        new_lines.extend(
            [
                "compress/mode=2",
                "compress/high_quality=false",
                "compress/lossy_quality=0.7",
                "compress/uastc_level=0",
                "compress/rdo_quality_loss=0.0",
                "compress/hdr_compression=0",
                "compress/normal_map=2",
                "compress/channel_pack=1",
                "mipmaps/generate=false",
                "mipmaps/limit=-1",
                "roughness/mode=1",
                'roughness/src_normal=""',
                "process/channel_remap/red=8",
                "process/channel_remap/green=8",
                "process/channel_remap/blue=8",
                "process/channel_remap/alpha=3",
                "process/fix_alpha_border=false",
                "process/premult_alpha=false",
                "process/normal_map_invert_y=false",
                "process/hdr_as_srgb=false",
                "process/hdr_clamp_exposure=false",
                "process/size_limit=0",
                "detect_3d/compress_to=1",
            ]
        )

    try:
        import_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
        print(f"Patched import settings for {import_path}")
    except Exception as e:
        print(f"Could not write {import_path}: {e}")


def wait_for_import_files(import_paths: list[Path], poll_interval: float = 2.0, timeout: float | None = None):
    """
    Poll until all .import files exist.
    If timeout is provided, stop after that many seconds (but keep whatever exists).
    """
    start = time.time()
    remaining = set(import_paths)

    print("\nNow open the project in Godot so it scans and imports the new waveform PNGs.")
    print("This script will wait until all corresponding .import files are created.\n")

    while remaining:
        existing = [p for p in remaining if p.is_file()]
        for p in existing:
            print(f"Detected import file: {p}")
            remaining.remove(p)

        if not remaining:
            break

        if timeout is not None and (time.time() - start) > timeout:
            print("Timeout while waiting for all .import files. Continuing with whatever exists.")
            break

        missing_preview = ", ".join(str(p.name) for p in list(remaining)[:5])
        if missing_preview:
            print(f"Waiting for .import files ({len(remaining)} remaining)... e.g. {missing_preview}")
        time.sleep(poll_interval)


def main():
    if not MUSIC_DIR.is_dir():
        print(f"Music directory not found: {MUSIC_DIR}")
        return

    waveform_pngs: list[Path] = []

    for root, _, files in os.walk(MUSIC_DIR):
        for name in files:
            p = Path(root) / name
            if p.suffix.lower() in AUDIO_EXTS:
                out = generate_waveform(p)
                if out is not None:
                    waveform_pngs.append(out)

    if not waveform_pngs:
        print("No waveform PNGs generated; nothing to patch.")
        return

    import_paths = [p.with_suffix(p.suffix + ".import") for p in waveform_pngs]

    wait_for_import_files(import_paths)

    # Patch all .import files that exist
    for imp in import_paths:
        if imp.is_file():
            patch_import_file(imp)
        else:
            print(f"Skipping (no .import file yet): {imp}")


if __name__ == "__main__":
    main()