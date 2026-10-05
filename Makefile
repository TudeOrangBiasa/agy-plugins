-include Makefile.harness

# Python base (landed agystack base: pyproject.toml + tests/). Harness
# target names (smoke|test|lint|typecheck|check|ci) are owned by
# Makefile.harness — new names only, never overrides.
UV ?= uv
.PHONY: test-py lint-py ci-py

test-py:
	$(UV) run --no-project --with "pytest>=8" --with pytest-timeout pytest tests/ --timeout=60 -q

lint-py:
	$(UV) tool run ruff check .

# Full stack: harness ci first, then Python suite + lint.
ci-py: ci test-py lint-py
