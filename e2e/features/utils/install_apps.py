"""iOS simulator + Example.app build/install helpers.

This is a pared-down port of mobile-automation-tests/install_apps.py, adapted
for the courier-ios repo. Only the iOS path is preserved (no Android, Flutter,
React Native, or Expo). The Example app is plain SPM (no CocoaPods), so the
Pods frameworks chmod step is gone.

Env vars consumed:
- DEVICE        — config key in features/config.json (default "ios")
- IOS_UDID      — overrides config.udid; required (no hardcoded UDID — runners
                  must export it)
- COURIER_AUTH_KEY — Courier API key written into Example/Example/Env.swift
                     before xcodebuild; this matches the repo's existing
                     Env.swift contract from EnvSample.swift.
- COURIER_USER_ID, COURIER_CLIENT_KEY, COURIER_BRAND_ID,
  COURIER_PREFERENCE_TOPIC_ID, COURIER_MESSAGE_TEMPLATE_ID — optional, also
  written into Env.swift if present (mirrors the repo's existing CI workflow).
"""
import json
import os
import shutil
import subprocess
import time
import uuid
from time import sleep


installed_app_path = ""
device = os.getenv('DEVICE', 'ios').lower()


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def load_config(platform):
    config_path = os.path.join(os.path.dirname(__file__), "..", "config.json")
    with open(config_path) as config_file:
        config = json.load(config_file)
        cfg = config.get(platform.lower())
        if cfg is None:
            raise ValueError(f"No config entry for device '{platform}'")
        env_udid = os.getenv("IOS_UDID")
        if env_udid:
            cfg["udid"] = env_udid
        if not cfg.get("udid"):
            raise ValueError(
                "Missing iOS simulator UDID. Set IOS_UDID env var or "
                "populate features/config.json."
            )
        return cfg


def wait_ios_simulator_to_be_booted(udid: str, timeout: int = 120):
    start_time = time.time()
    while True:
        result = subprocess.run(
            ["xcrun", "simctl", "list", "devices"],
            capture_output=True, text=True, check=False,
        )
        if f"({udid}) (Booted)" in result.stdout:
            print(f"Simulator with UDID {udid} is booted.")
            return
        if int(time.time()) - int(start_time) > timeout:
            if timeout > 0:
                raise TimeoutError(f"Simulator with UDID {udid} did not boot within {timeout} seconds.")
            raise Warning(f"Simulator with UDID {udid} is not booted.")
        print("Waiting for simulator to boot...")
        sleep(1)


def start_ios_simulator(udid: str):
    try:
        wait_ios_simulator_to_be_booted(udid, timeout=0)
    except Exception:
        print(f"Booting simulator with UDID: {udid}")
        subprocess.run(["open", "-a", "Simulator"], check=True)
        subprocess.run(["xcrun", "simctl", "boot", udid], check=True)
        wait_ios_simulator_to_be_booted(udid)


def stop_ios_simulator(udid: str):
    print(f"Stopping simulator with UDID: {udid}")
    subprocess.run(["xcrun", "simctl", "shutdown", udid], check=False)
    print(f"Simulator with UDID {udid} has been stopped.")


def find_xcode_project_or_workspace(search_path: str):
    workspace_file = None
    project_file = None
    for root, dirs, _ in os.walk(search_path):
        for d in dirs:
            if d.endswith(".xcworkspace") and ".xcodeproj" not in root:
                workspace_file = os.path.join(root, d)
            if d.endswith(".xcodeproj"):
                project_file = os.path.join(root, d)
            if workspace_file and project_file:
                return project_file, workspace_file
        # Don't descend into build/derived data
        dirs[:] = [d for d in dirs if d not in ("DerivedData", "build", "Build")]
    return project_file, workspace_file


def find_built_app(derived_data_path: str):
    products_path = os.path.join(derived_data_path, "Build", "Products")
    for root, dirs, _ in os.walk(products_path):
        for d in dirs:
            if d.endswith(".app") and "Debug-iphonesimulator" in root or "Release-iphonesimulator" in root:
                return os.path.join(root, d)
    return None


def _swift_string_literal(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def generate_swift_env_file():
    """Write Example/Example/Env.swift using the EnvSample.swift schema.

    The Example app reads `Env.COURIER_AUTH_KEY` etc. — keep the same field
    names so the repo's existing AuthViewController + ExampleServer keep
    working untouched.
    """
    auth_key = os.getenv("COURIER_AUTH_KEY") or os.getenv("COURIER_API_KEY")
    if not auth_key:
        raise ValueError(
            "Missing environment variable: COURIER_AUTH_KEY (or COURIER_API_KEY)"
        )

    fields = {
        "COURIER_USER_ID": os.getenv("COURIER_USER_ID", ""),
        "COURIER_AUTH_KEY": auth_key,
        "COURIER_CLIENT_KEY": os.getenv("COURIER_CLIENT_KEY", ""),
        "COURIER_BRAND_ID": os.getenv("COURIER_BRAND_ID", ""),
        "COURIER_PREFERENCE_TOPIC_ID": os.getenv("COURIER_PREFERENCE_TOPIC_ID", ""),
        "COURIER_MESSAGE_TEMPLATE_ID": os.getenv("COURIER_MESSAGE_TEMPLATE_ID", ""),
    }

    body = "\n".join(
        f'    static let {name} = "{_swift_string_literal(value)}"'
        for name, value in fields.items()
    )

    content = (
        "//\n"
        "//  Env.swift\n"
        "//\n"
        "//  Generated by e2e/features/utils/install_apps.py — do not edit by hand.\n"
        "//\n\n"
        "import Foundation\n\n"
        "class Env {\n\n"
        f"{body}\n\n"
        "}\n"
    )

    output_path = os.path.join(REPO_ROOT, "Example", "Example", "Env.swift")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as file:
        file.write(content)

    print(f"✅ Env.swift written at {output_path}")


def install_locally():
    """Build Example.app once per process, then install on the simulator."""
    global installed_app_path
    config = load_config(device)

    uploads_dir = os.path.join(REPO_ROOT, "e2e", "uploads")

    if installed_app_path == "":
        if os.path.exists(uploads_dir):
            shutil.rmtree(uploads_dir)
        os.makedirs(uploads_dir, exist_ok=True)
        session_id = str(uuid.uuid4())
        project_dir = os.path.join(uploads_dir, session_id)
        os.makedirs(project_dir, exist_ok=True)

        generate_swift_env_file()

        app_path = os.path.join(REPO_ROOT, config['app_path'])
        project_file, workspace_file = find_xcode_project_or_workspace(app_path)
        derived_data_path = os.path.join(project_dir, "DerivedData")
        os.makedirs(derived_data_path, exist_ok=True)

        build_cmd = [
            "xcodebuild",
            "-scheme", config['scheme'],
            "-destination", f"id={config.get('udid', '')}",
            "-configuration", "Debug",
            "-derivedDataPath", derived_data_path,
            "build",
        ]
        if workspace_file:
            build_cmd[1:1] = ["-workspace", workspace_file]
        else:
            build_cmd[1:1] = ["-project", project_file]

        print(" ".join(build_cmd))
        result = subprocess.run(build_cmd, capture_output=True, text=True, check=False)
        if result.returncode == 0:
            print("Successfully built Example app")
        else:
            print(result.stdout)
            print(result.stderr)
            raise RuntimeError("xcodebuild failed — see output above")

        installed_app_path = find_built_app(derived_data_path)
        if not installed_app_path:
            raise RuntimeError(f"Could not locate .app under {derived_data_path}")
        print(f"-- Built app: {installed_app_path} --")
    else:
        print(f"-- Reusing built app: {installed_app_path} --")

    subprocess.run(
        ["xcrun", "simctl", "uninstall", config.get('udid', ''), config['bundle_id']],
        capture_output=True, text=True, check=False,
    )
    install_cmd = ["xcrun", "simctl", "install", config.get('udid', ''), installed_app_path]
    print(" ".join(install_cmd))
    subprocess.run(install_cmd, capture_output=True, text=True, check=False)
    print("-- Installed app --")
