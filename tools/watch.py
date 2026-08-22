import time
import subprocess
import os
from pathlib import Path

SRC_DIR = Path("src")

last_mtime = {}
build_process = None


def scan():
    changed = []
    for f in SRC_DIR.rglob("*"):
        if f.suffix not in [".c", ".cpp", ".asm", ".h", ".hpp"]:
            continue
        try:
            mtime = f.stat().st_mtime
        except FileNotFoundError:
            continue
        old = last_mtime.get(str(f))
        if old is None:
            last_mtime[str(f)] = mtime
            continue
        if mtime != old:
            last_mtime[str(f)] = mtime
            changed.append(str(f))
    return changed


def kill_running():
    global build_process
    if build_process and build_process.poll() is None:
        print("[WATCH] killing old process...")
        build_process.kill()
        build_process = None


def get_exe_path():
    return "./index.exe" if os.name == "nt" else "./index"


def run_program():
    global build_process
    exe = get_exe_path()
    if not os.path.exists(exe):
        print(f"[RUN] executable not found: {exe}")
        return
    print(f"[RUN] starting: {exe}")
    build_process = subprocess.Popen([exe], stdout=None, stderr=None)


def build():
    print("\n[BUILD] change detected -> rebuilding...\n")
    result = subprocess.run(["make", "build"])
    if result.returncode == 0:
        print("[BUILD] success")
        return True
    print("[BUILD] failed")
    return False


def main():
    print("[WATCH] watching src/ ...")
    scan()
    run_program()
    while True:
        changed = scan()
        if changed:
            print("\n[WATCH] changed files:")
            for c in changed:
                print("   ", c)
            kill_running()
            if build():
                run_program()
        time.sleep(0.2)


if __name__ == "__main__":
    main()
