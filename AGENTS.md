# Agent Instructions

## General

The root repository is only for testing the `cmake/lib` submodule which is a project boilerplate.  
Follow the `cmake/lib` submodule documentation [`AGENTS.md`](cmake/lib/tpl/root/AGENTS.md).

## Scripting & Build Tool Development (`build.py` / Python)

### Architectural Alignment

- **Leverage Existing Infrastructure**: Before writing new helper functions or defensive fallbacks (such as custom file
  searches or ad-hoc section matching), verify if the script already provides native mechanisms (e.g.,
  `create_config_parser()`, `[__include__]`, `get_merged_config_section()`, `run_command()`).
- **Clean Conventions Over Heuristics**: Favor explicit, predictable mappings (such as uniform section prefixes
  `nexus-<section>` with a clean default like `develop`) over fuzzy/fallback naming heuristics.
- **Avoid Redundant Wrapping**: Utilize existing utilities as designed (e.g., `run_command` handles `dbg_mode`,
  verbosity, and error reporting natively; do not write manual `if DEBUG_FLAG:` branching wrappers).

### Configuration & Schema Changes

- **Evaluate End-to-End Schema Impact**: When refactoring configuration sections or inheritance hierarchies (such as
  splitting base credentials from environment-specific targets), always check how child defaults interact with required
  variable validations.
- **Maintain Clear Override Hierarchy**: Follow the strict precedence: `CLI Arguments` >
  `Process Environment (RUN_ENV)` > `Merged INI Configuration`.

### Verification Checklist for Subcommands & Scripts

- **Default Invocation Test**: Always test the default command line path with zero optional flags to ensure default
  values satisfy all validations.
- **All Config Target Sections**: Test resolution against all configured environments with dry-run mode (`-d`).
- **CLI & ENV Overrides**: Confirm explicit CLI options properly override INI defaults when applicable.
- **Windows / Cross-Platform Compatibility**: Ensure wildcard expansion (`glob.glob`) and URL/path separator
  normalization are accounted for when processing file paths or arguments.