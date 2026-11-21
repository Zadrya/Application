# SPDX-License-Identifier: GPL-3.0-or-later
#
# Local parity: the CI jobs call these targets. CodeQL, Scorecard and
# dependency review only run in CI. Flutter is pinned in .fvmrc and run through
# fvm; CI installs the same version and sets FLUTTER=flutter DART=dart.

SHELL := bash
.DEFAULT_GOAL := help

BASE ?= origin/main
FLUTTER ?= fvm flutter
DART ?= fvm dart
# Minimum line coverage of lib/**/domain/** and lib/**/data/** (docs/SPEC.md).
COVERAGE_MIN ?= 85
# Device for integration tests, empty for the only one connected.
DEVICE ?=
COMMITLINT := npx --yes --package @commitlint/cli@21.2.4 -- commitlint

.PHONY: help setup check ci lint format-check analyze licenses test test-scripts test-flutter coverage \
	integration-test build-android-debug build-ios-simulator build-ios-release \
	authorship commitlint commitlint-message commitlint-title

help: ## List the targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  %-20s %s\n", $$1, $$2}'

setup: ## Install the git hooks in this clone
	lefthook install

check: lint licenses test ## Fast checks, run before every commit

ci: check coverage authorship commitlint ## Everything CI runs on every pull request, except the builds

lint: format-check analyze ## Lint Dart, workflows, YAML, Markdown and shell scripts
	actionlint
	zizmor --no-progress .github/workflows
	yamllint --strict .
	markdownlint-cli2 "**/*.md"
	shellcheck scripts/*.sh tool/*.sh .lefthook/*/*.sh
	scripts/check-no-em-dash.sh

format-check: ## Check that the Dart code is formatted
	$(DART) format --output=none --set-exit-if-changed $(wildcard lib test integration_test)

analyze: ## Analyze the Dart code with the strict lints
	$(FLUTTER) pub get --enforce-lockfile
	$(FLUTTER) analyze --fatal-infos --fatal-warnings

licenses: ## Check that every file has license information (REUSE)
	reuse lint

test: test-scripts test-flutter ## Run the tests

test-scripts: ## Test the git hooks and the check scripts
	scripts/test-hooks.sh
	scripts/test-hooks-isolation.sh
	tool/test-tools.sh

test-flutter: ## Run the unit and widget tests, with coverage
	$(FLUTTER) pub get --enforce-lockfile
	$(FLUTTER) test --coverage

coverage: test-flutter ## Gate the coverage of the domain and data layers
	tool/check-coverage.sh coverage/lcov.info $(COVERAGE_MIN)

integration-test: ## Run the integration tests on a device or emulator (DEVICE=id)
	$(FLUTTER) test integration_test $(if $(DEVICE),-d $(DEVICE))

build-android-debug: ## Build the Android debug APK
	$(FLUTTER) build apk --debug

build-ios-simulator: ## Build the iOS app for the simulator, unsigned (macOS with Xcode)
	$(FLUTTER) build ios --simulator --no-codesign

build-ios-release: ## Build the iOS release app, unsigned (macOS with Xcode)
	$(FLUTTER) build ios --release --no-codesign

authorship: ## Check author, committer and attribution lines of BASE..HEAD
	scripts/check-authorship.sh $(BASE)..HEAD

commitlint: ## Check that the commits in BASE..HEAD are conventional
	$(COMMITLINT) --from $(BASE) --to HEAD --verbose

commitlint-message: ## Check one commit message file (FILE=path), used by the commit-msg hook
	$(COMMITLINT) --edit $(FILE)

commitlint-title: ## Check the pull request title in the PR_TITLE environment variable
	@[[ -n "$$PR_TITLE" ]] || { echo "error: PR_TITLE is empty" >&2; exit 1; }
	@printf '%s\n' "$$PR_TITLE" | $(COMMITLINT) --verbose
