import os
import sys
from pathlib import Path
from typing import Mapping


PROJECT_DIR = Path(__file__).resolve().parent.parent
APP_NAME = "文献管理系统"
APP_VERSION = "0.1.0"


def default_data_dir(
    platform_name: str | None = None,
    environ: Mapping[str, str] | None = None,
) -> Path:
    """Return a user-writable data directory for the current platform."""
    platform_name = platform_name or sys.platform
    environ = os.environ if environ is None else environ
    if platform_name == "win32":
        base = environ.get("LOCALAPPDATA")
        if base:
            return Path(base) / "LiteratureManager"
        return Path.home() / "AppData" / "Local" / "LiteratureManager"
    return PROJECT_DIR


def default_database_path(
    platform_name: str | None = None,
    environ: Mapping[str, str] | None = None,
    project_dir: Path | None = None,
) -> Path:
    """Resolve the database path without writing to the installation directory.

    LITERATURE_MANAGER_DB always wins. A source checkout that already has a
    database keeps using it, while a fresh Windows install stores user data in
    %LOCALAPPDATA% so an installed or packaged application remains writable.
    """
    environ = os.environ if environ is None else environ
    override = environ.get("LITERATURE_MANAGER_DB")
    if override:
        return Path(override).expanduser()
    checkout = (project_dir or PROJECT_DIR) / "paper_library.db"
    if checkout.exists():
        return checkout
    return default_data_dir(platform_name, environ) / "paper_library.db"


DEFAULT_DB_PATH = default_database_path()

CROSSREF_BASE = "https://api.crossref.org"
OPENALEX_BASE = "https://api.openalex.org"
NETWORK_TIMEOUT_SECONDS = 12
USER_AGENT = "LocalLiteratureManager/0.1 (mailto:local-user@example.invalid)"
