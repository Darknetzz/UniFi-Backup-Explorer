#!/usr/bin/env python3
"""Upload backup-explorer.html to https://roste.org/unifi/ as index.html.

Reads SSH_DEPLOY_HOST, SSH_DEPLOY_PORT, SSH_DEPLOY_USERNAME, and
SSH_DEPLOY_PASSWORD from the environment. Missing values are filled from a
repo-root .env file, which is gitignored.
"""

import os
import sys
from pathlib import Path

import paramiko

ROOT = Path(__file__).resolve().parents[1]
LOCAL_FILE = ROOT / "backup-explorer.html"
DEFAULT_REMOTE = "/customers/f/8/1/civhnph62/webroots/www/unifi/index.html"


def load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def require(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        sys.exit(f"Missing {name}. Set it in the environment or .env.")
    return value


def main() -> None:
    load_dotenv(ROOT / ".env")
    host = require("SSH_DEPLOY_HOST")
    username = require("SSH_DEPLOY_USERNAME")
    password = require("SSH_DEPLOY_PASSWORD")
    port = int(os.environ.get("SSH_DEPLOY_PORT", "22"))
    remote = os.environ.get("SSH_DEPLOY_REMOTE", DEFAULT_REMOTE).strip()

    if not LOCAL_FILE.is_file():
        sys.exit(f"Missing {LOCAL_FILE}")

    local_size = LOCAL_FILE.stat().st_size
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(
        host,
        port=port,
        username=username,
        password=password,
        timeout=30,
        allow_agent=False,
        look_for_keys=False,
    )
    try:
        sftp = client.open_sftp()
        try:
            sftp.put(str(LOCAL_FILE), remote)
            remote_size = sftp.stat(remote).st_size
        finally:
            sftp.close()
    finally:
        client.close()

    if remote_size != local_size:
        sys.exit(f"Upload size mismatch: local {local_size}, remote {remote_size}")

    print(f"Uploaded {LOCAL_FILE.name} ({remote_size} bytes)")


if __name__ == "__main__":
    main()
