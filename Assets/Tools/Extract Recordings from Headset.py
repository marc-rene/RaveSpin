import subprocess
import os
import logging
import pathlib

PACKAGE = "com.example.ravespin"
REMOTE_DIR = "files/Recordings"
LOCAL_DIR = str(pathlib.Path(__file__).parent.absolute()  / "All Extracted RaveSpin Recordings")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

logger = logging.getLogger(__name__)


def run_cmd(cmd):
    logger.debug(f"Running command: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    if result.returncode != 0:
        logger.error(f"Command failed: {cmd}")
        logger.error(result.stderr.strip())
        return None

    return result.stdout.strip()


def list_wav_files():
    logger.info("Listing .wav files in remote directory...")
    cmd = f'adb shell run-as {PACKAGE} ls {REMOTE_DIR}'
    output = run_cmd(cmd)

    if output is None:
        logger.warning("Failed to list files or directory does not exist.")
        return []

    files = output.splitlines()
    wavs = [f for f in files if f.lower().endswith(".wav")]

    logger.info(f"Found {len(wavs)} .wav file(s).")
    return wavs


def pull_file(filename):
    remote_path = f"{REMOTE_DIR}/{filename}"
    local_path = os.path.join(LOCAL_DIR, filename)

    cmd = f'adb exec-out run-as {PACKAGE} cat "{remote_path}" > "{local_path}"'

    logger.info(f"Pulling {filename}...")
    result = os.system(cmd)

    if result != 0:
        logger.error(f"Failed to pull {filename}")
    else:
        logger.debug(f"Saved to {local_path}")


def main():
    logger.info(f"Starting extraction to {LOCAL_DIR}")

    os.makedirs(LOCAL_DIR, exist_ok=True)

    wav_files = list_wav_files()

    if not wav_files:
        logger.warning("No .wav files found. Exiting.")
        return

    for f in wav_files:
        pull_file(f)

    logger.info("Extraction complete.")


if __name__ == "__main__":
    main()