from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def reveal_command(path: str | Path, platform_name: str | None = None) -> list[str]:
    """Build the native command that reveals path in the file manager."""
    platform_name = platform_name or sys.platform
    resolved = str(Path(path).resolve())
    if platform_name == "darwin":
        return ["open", "-R", resolved]
    if platform_name == "win32":
        # Explorer expects /select,<path> as a single argument. Passing a list
        # keeps spaces and non-ASCII characters safe without invoking a shell.
        return ["explorer.exe", f"/select,{os.path.normpath(resolved)}"]
    return ["xdg-open", str(Path(resolved).parent)]


def reveal_in_file_manager(path: str | Path) -> None:
    creation_flags = 0
    if sys.platform == "win32":
        creation_flags = getattr(subprocess, "CREATE_NO_WINDOW", 0)
    subprocess.Popen(reveal_command(path), creationflags=creation_flags)
