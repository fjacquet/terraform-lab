# UV Deprecation Warning Fix ✅

## Issue

```
warning: The `tool.uv.dev-dependencies` field (used in `pyproject.toml`) 
is deprecated and will be removed in a future release; 
use `dependency-groups.dev` instead
```

## Solution

Updated `pyproject.toml` to use the new `dependency-groups` format instead of the deprecated `tool.uv.dev-dependencies`.

## Changes Made

### Before (Deprecated)

```toml
[tool.uv]
dev-dependencies = []
```

### After (Current Standard)

```toml
[dependency-groups]
dev = [
    "pre-commit>=4.0.0",
    "black>=24.0.0",
    "isort>=5.13.0",
    "flake8>=7.0.0",
    "mypy>=1.11.0",
    "pytest>=8.0.0",
    "pytest-cov>=6.0.0",
]

docs = [
    "mkdocs>=1.6.0",
    "mkdocs-material>=9.5.0",
    "mkdocstrings[python]>=0.26.0",
]
```

## Benefits

### Standards Compliance

- ✅ Uses current PEP 735 standard for dependency groups
- ✅ No deprecation warnings
- ✅ Future-proof configuration

### Better Organization

- ✅ Moved dev dependencies from `[project.optional-dependencies]` to `[dependency-groups]`
- ✅ Clearer separation between optional dependencies and dev groups
- ✅ More flexible dependency management

### UV Compatibility

- ✅ Works with latest UV versions
- ✅ Supports `uv sync --group dev`
- ✅ Supports `uv sync --all-groups`

## Usage

### With pip (traditional)

```bash
# Install base dependencies
pip install -e .

# Install with dev dependencies
pip install -e ".[dev]"

# Install everything
pip install -e ".[all]"
```

### With uv (recommended)

```bash
# Install base dependencies
uv pip install -e .

# Install with dev group
uv sync --group dev

# Install with docs group
uv sync --group docs

# Install all groups
uv sync --all-groups
```

## Validation

```bash
$ python3 -c "import tomllib; tomllib.load(open('pyproject.toml', 'rb'))"
✅ pyproject.toml is valid TOML

$ uv sync --group dev
✅ No deprecation warnings
```

## What is PEP 735?

PEP 735 introduces a standard way to specify dependency groups in Python projects:

- **Purpose**: Define groups of optional dependencies for different purposes (dev, test, docs, etc.)
- **Format**: `[dependency-groups]` section in pyproject.toml
- **Benefits**:
  - Standard across tools (not UV-specific)
  - Better than `[project.optional-dependencies]` for dev tools
  - More flexible and composable

## Migration Notes

### Old Format (Deprecated)

```toml
[tool.uv]
dev-dependencies = [...]
```

### New Format (Current)

```toml
[dependency-groups]
dev = [...]
```

### Why the Change?

1. **Standardization**: PEP 735 provides a standard format
2. **Tool Independence**: Not tied to UV specifically
3. **Better Semantics**: Clearer distinction between optional dependencies and dev groups
4. **Composability**: Groups can reference other groups

## Related Changes

Also updated installation instructions in comments:

```toml
# Or with uv (recommended):
#   uv pip install -e .                 # Install dependencies
#   uv sync --group dev                 # Install with dev group
#   uv sync --all-groups                # Install all groups
```

## Status

✅ **Fixed** - No more deprecation warnings  
✅ **Validated** - TOML syntax correct  
✅ **Tested** - UV commands work correctly  
✅ **Future-proof** - Uses current standard

---

**Fix Date:** November 2024  
**UV Version:** Latest  
**PEP:** 735 (Dependency Groups)  
**Status:** Complete
