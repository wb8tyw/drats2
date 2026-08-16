# Monorepo Context - drats2 (wb8tyw_monorepo_migration)

## Current Architecture

* **`apps/`**: Individual application software binaries/packages
  (including GUI components).
* **`libs/`**: Internal libraries and helper modules required by the apps.
  Currently 2 directories, but design allows scaling to N libraries.

## Target Configuration Goals (Zero-Config Strategy)

* **Development Mode**:
  * Dependencies location: `local/<short_hostname>/libs/`
  * Configuration storage: `local/<short_hostname>/home/`
* **Production / Packaged Mode**:
  * Dependencies location: Application-isolated vendor/PyPI bundle directory.
  * Configuration storage: Standard user home directory (`~/.config/` or `AppData\Roaming\D-RATS`).

## Immediate Problem

* Unit tests for applications/GUI components (currently Hello World variants)
  fail when executed manually because local module trees and development
  paths (`local/<short_hostname>/...`) are not dynamically bound to `sys.path`.

## Execution & Test Environment Constraints

* **Test Runners**: Not currently using `pytest` or automated frameworks.
* **Execution Style**: Raw invocation via `python -m apps.path.to.module` or
  direct script execution (`python apps/gui/hello_world_kivy.py`).
* **Requirement**: System paths and dev home folders must auto-configure
  upon bare python initialization without code duplication in individual
  scripts or wrapper scripts.

## Dependencies Management

* **Legacy Files**: Platform-specific requirements files located across directories (`./build_python_rq/`, `./mobaxterm/`, `./windows/`, `./fedora/`, `./macos/`).
* **Target Behavior**: Target PyPI module installation paths dynamically to `local/<short_hostname>/libs/` instead of global or virtual environment site-packages.
* **Automation**: Requirements files remain clean text; wrappers calculate the target paths at runtime.

## Dependencies Management Tracks

1. **Development & Testing Track**:
   * Platform-specific requirements files: `./mobaxterm/`, `./windows/`,
     `./fedora/`, `./macos/`.
   * Targets local development hostnames: `local/<short_hostname>/libs/`
     for dependencies, `local/<short_hostname>/home/` for configs.
2. **Production Packaging Track**:
   * Stored in `./build_python_rq/requirements.txt`.
   * Contains only the bare-minimum dependencies required to compile, build,
     and package the final application distribution.

## Environment & Dependency Management

* **Unified Scripts**: `setup_dev.sh` (Unix/SSH) and `setup_dev.ps1`
 (Windows) serve two purposes.
  1. **First-time configuration**: Installs platform-matched PyPI requirements
     into `local/<short_hostname>/libs/`.
  2. **Session Recovery**: Restores lost terminal paths, checks files,
     and re-exports variables after unexpected reboots or dropped SSH sessions.

## Coding Style Rules

* Width Constraint: All script and code lines must fit within 80 columns.
* Text Encodings: Pure ASCII text only. Emojis and Unicode characters banned.
* Lint Checks: Code must cleanly pass shellcheck validation without errors.

## Known Infrastructure Roadblocks

* Sphinx Dependency Lock: PyPI Sphinx aggressively caps docutils bounds.
* Fix: Isolate testing runtimes from documentation build layers to
  prevent pip installation circular dependency blocks.

## Installation Infrastructure

* Environment Entry: `setup_dev.sh` (Sourced via terminal loop)
* Execution Delegate: Handed directly to `install_linux.sh` with parameter
  arguments ("dev") forwarded transparently.
* Responsibility: `setup_dev.sh` verifies local folders and maps active
  PYTHONPATH environments; platform-specific routing lives in the dispatcher.
* Routing: Automatically delegates to `install_fedora.sh`, `install_debian.sh`,
  `install_msys2.sh`, or `install_mobaxterm.sh`.
* Dispatcher (`install_linux.sh`): Left unchanged. Securely forwards all
  native arguments downstream via "$@".
* Child Scripts: Accept parameters forwarded by the parent, defaulting to
  "prod"
  if arguments are empty. They isolate PyPI tracking to local paths.*
  Parameter Flow: Forward `$1` ("dev" or "prod") to downstream variants.
* Mode Evaluation: Simulates Linux layout via translation layers.
* Dependency Strategy: Fallback to target-isolated PyPI execution since
  native system python wheels (like Kivy) are generally unavailable.

## Execution Methodology

* App Binaries (apps/): Launched natively via absolute path names on Linux
  (e.g., ./apps/gui/main.py) and via the generic python engine on Windows.
* Library Modules (libs/): Evaluated via 'python -m path.to.module'.
* Automation: setup_dev.sh automatically ensures all files inside the apps/
  directory tree possess valid executable permissions on POSIX hosts.

## Path Management

* Resolution: setup_dev.sh scans 'libs/' exclusively. It dynamically maps
  inner 'src/' directories into PYTHONPATH to ensure components like
  'version_git' resolve perfectly across all application platforms.

## Repeater Architecture Refactor (Headless)

* Target: Transform 'drats_repeater' into a lightweight background service.
* GUI Status: 100% Removed. No graphical framework hooks allowed.
* Core Interface: Exposes an internal REST API loop for state and execution.
* Frontend: Lightweight HTML/JS status dashboard reading data from the REST API.

## Current Status

* Core Libraries: All 9 modules in 'drats_common' successfully integrated.
* System Exit Status: All executions yield clean code tracks ($? = 0).

## Architectural Decisions

* Internationalization: Drop custom app settings. Prioritize host OS system
  environment variables natively via gettext and common_words.py.
* Legacy Parsing: Implement adaptive line splitting inside old_config.py to
  stop human-entered delimiter characters from crashing initialization.
* Refactoring Candidate: Rename 'comm_link_parameters' to 'link_profile' to
  permanently remove legacy hardware 'radio' naming confusions.
