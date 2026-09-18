#!/usr/bin/env python3
from __future__ import annotations

import sys
import faulthandler


def main() -> int:
    # PyInstaller's windowed mode intentionally provides no stderr stream.
    # Enabling faulthandler in that environment raises before the GUI starts.
    if sys.stderr is not None:
        try:
            faulthandler.enable()
        except (OSError, RuntimeError):
            pass
    try:
        from literature_manager.gui import run
    except ImportError as exc:
        if exc.name == "PySide6":
            print(
                "缺少 PySide6。Windows 请双击“启动文献管理系统-Windows.bat”，"
                "或运行：py -m pip install -r requirements.txt",
                file=sys.stderr,
            )
            return 2
        raise
    return run()


if __name__ == "__main__":
    raise SystemExit(main())
