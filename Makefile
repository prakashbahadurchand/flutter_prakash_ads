# ==============================================================================
# flutter_prakash_ads - Developer & Release Automation Makefile
# ==============================================================================

.DEFAULT_GOAL := help
.PHONY: help info version get get-pkg get-example upgrade clean clean-all \
        format fmt format-check analyze analyze-all lint fix \
        test test-all test-coverage coverage-html \
        check verify ci pana dry-run publish-check publish publish-force tag \
        example-run example-run-release example-codegen example-watch \
        example-build-apk example-build-appbundle example-refetch

# ------------------------------------------------------------------------------
# Configuration & Metadata
# ------------------------------------------------------------------------------
PKG_NAME    := $(shell grep '^name:' pubspec.yaml | awk '{print $$2}')
PKG_VERSION := $(shell grep '^version:' pubspec.yaml | awk '{print $$2}')

# ANSI Colors for terminal output
BOLD  := \033[1m
GREEN := \033[32m
CYAN  := \033[36m
YELLOW:= \033[33m
RED   := \033[31m
RESET := \033[0m

# ------------------------------------------------------------------------------
# Help & Information
# ------------------------------------------------------------------------------
help:
	@echo "$(BOLD)$(CYAN)==============================================================================$(RESET)"
	@echo "$(BOLD)$(CYAN)  flutter_prakash_ads Developer & Release Tooling$(RESET)"
	@echo "  Package: $(BOLD)$(PKG_NAME)$(RESET) | Version: $(BOLD)v$(PKG_VERSION)$(RESET)"
	@echo "$(BOLD)$(CYAN)==============================================================================$(RESET)"
	@echo ""
	@echo "$(BOLD)📦 Dependencies & Setup:$(RESET)"
	@echo "  $(CYAN)make get$(RESET)               Get dependencies for package and example app"
	@echo "  $(CYAN)make get-pkg$(RESET)           Get dependencies for root package only"
	@echo "  $(CYAN)make get-example$(RESET)       Get dependencies for example app only"
	@echo "  $(CYAN)make upgrade$(RESET)           Upgrade dependencies across package and example"
	@echo "  $(CYAN)make clean$(RESET)             Clean build caches in package and example"
	@echo "  $(CYAN)make clean-all$(RESET)         Deep clean (caches, coverage, and dart_tools)"
	@echo ""
	@echo "$(BOLD)🎨 Code Quality & Linting:$(RESET)"
	@echo "  $(CYAN)make format$(RESET)            Format all Dart code (lib, test, example)"
	@echo "  $(CYAN)make format-check$(RESET)      Verify formatting without writing changes (CI mode)"
	@echo "  $(CYAN)make analyze$(RESET)           Run dart analyzer on root package"
	@echo "  $(CYAN)make analyze-all$(RESET)       Run dart analyzer on root and example app"
	@echo "  $(CYAN)make fix$(RESET)               Apply automated dart fixes"
	@echo ""
	@echo "$(BOLD)🧪 Testing & Coverage:$(RESET)"
	@echo "  $(CYAN)make test$(RESET)              Run package unit and widget tests"
	@echo "  $(CYAN)make test-all$(RESET)          Run all tests (root and example app)"
	@echo "  $(CYAN)make test-coverage$(RESET)     Run tests with LCOV coverage collection"
	@echo "  $(CYAN)make coverage-html$(RESET)     Generate and open HTML coverage report (needs lcov)"
	@echo ""
	@echo "$(BOLD)🔍 Local CI / Verification:$(RESET)"
	@echo "  $(CYAN)make check$(RESET)             Run complete CI pipeline locally (fmt, lint, test, dry-run)"
	@echo ""
	@echo "$(BOLD)📱 Example Application:$(RESET)"
	@echo "  $(CYAN)make example-run$(RESET)       Run example app in debug mode"
	@echo "  $(CYAN)make example-codegen$(RESET)   Run build_runner in example app"
	@echo "  $(CYAN)make example-watch$(RESET)     Run build_runner watch in example app"
	@echo "  $(CYAN)make example-build-apk$(RESET) Build split APK for example app"
	@echo "  $(CYAN)make example-refetch$(RESET)   Re-link package and recompile example DI"
	@echo ""
	@echo "$(BOLD)🚀 Publishing to pub.dev:$(RESET)"
	@echo "  $(CYAN)make info$(RESET)              Check current version & pub.dev release status"
	@echo "  $(CYAN)make dry-run$(RESET)           Run pub.dev publish dry-run validation"
	@echo "  $(CYAN)make pana$(RESET)              Run pana package health & score analysis"
	@echo "  $(CYAN)make publish-check$(RESET)     Run all pre-publish readiness verifications"
	@echo "  $(CYAN)make publish$(RESET)           Publish package interactively to pub.dev"
	@echo "  $(CYAN)make publish-force$(RESET)     Publish package non-interactively (--force)"
	@echo "  $(CYAN)make tag$(RESET)               Tag current version (v$(PKG_VERSION)) and push to git"
	@echo ""

info: version
version:
	@echo "$(BOLD)$(PKG_NAME)$(RESET) version: $(BOLD)$(GREEN)v$(PKG_VERSION)$(RESET)"
	@echo "Checking status on pub.dev..."
	@STATUS=$$(curl -s -o /dev/null -w "%{http_code}" "https://pub.dev/api/packages/$(PKG_NAME)/versions/$(PKG_VERSION)" || echo "000"); \
	if [ "$$STATUS" = "200" ]; then \
		echo "$(YELLOW)⚠️  Version $(PKG_VERSION) is ALREADY published on pub.dev$(RESET)"; \
	elif [ "$$STATUS" = "404" ]; then \
		echo "$(GREEN)✅ Version $(PKG_VERSION) is NEW and NOT yet published on pub.dev!$(RESET)"; \
	else \
		echo "$(CYAN)ℹ️  pub.dev returned HTTP $$STATUS$(RESET)"; \
	fi

# ------------------------------------------------------------------------------
# Dependencies & Setup
# ------------------------------------------------------------------------------
get: get-pkg get-example
	@echo "$(GREEN)✅ All dependencies installed successfully!$(RESET)"

get-pkg:
	@echo "$(CYAN)📦 Getting dependencies for $(PKG_NAME)...$(RESET)"
	flutter pub get

get-example:
	@echo "$(CYAN)📦 Getting dependencies for example app...$(RESET)"
	@cd example && flutter pub get

upgrade:
	@echo "$(CYAN)⬆️  Upgrading dependencies...$(RESET)"
	flutter pub upgrade
	@cd example && flutter pub upgrade
	@echo "$(GREEN)✅ Dependencies upgraded!$(RESET)"

clean:
	@echo "$(YELLOW)🧹 Cleaning package and example build artifacts...$(RESET)"
	flutter clean
	@cd example && flutter clean
	@rm -rf coverage
	@echo "$(GREEN)✅ Clean complete!$(RESET)"

clean-all: clean
	@echo "$(YELLOW)🧹 Removing .dart_tool and lock files...$(RESET)"
	@rm -rf .dart_tool
	@rm -rf example/.dart_tool
	@echo "$(GREEN)✅ Deep clean complete! Run 'make get' to restore dependencies.$(RESET)"

# ------------------------------------------------------------------------------
# Code Quality, Formatting & Linting
# ------------------------------------------------------------------------------
format: fmt

fmt:
	@echo "$(CYAN)🎨 Formatting Dart code in package and example...$(RESET)"
	dart format lib test example/lib example/test
	@echo "$(GREEN)✅ Formatting complete!$(RESET)"

format-check:
	@echo "$(CYAN)🔎 Checking Dart formatting (CI mode)...$(RESET)"
	dart format --output=none --set-exit-if-changed .
	@echo "$(GREEN)✅ Code formatting verified!$(RESET)"

lint: analyze

analyze:
	@echo "$(CYAN)🔎 Analyzing package $(PKG_NAME)...$(RESET)"
	flutter analyze
	@echo "$(GREEN)✅ Package analyzer passed!$(RESET)"

analyze-all: analyze
	@echo "$(CYAN)🔎 Analyzing example app...$(RESET)"
	@cd example && flutter analyze
	@echo "$(GREEN)✅ All analyzers passed!$(RESET)"

fix:
	@echo "$(CYAN)🛠️  Applying automatic Dart fixes...$(RESET)"
	dart fix --apply
	@cd example && dart fix --apply
	@echo "$(GREEN)✅ Fixes applied!$(RESET)"

# ------------------------------------------------------------------------------
# Testing & Coverage
# ------------------------------------------------------------------------------
test:
	@echo "$(CYAN)🧪 Running unit and widget tests for $(PKG_NAME)...$(RESET)"
	flutter test
	@echo "$(GREEN)✅ All package tests passed!$(RESET)"

test-all: test
	@echo "$(CYAN)🧪 Running example app tests...$(RESET)"
	@cd example && flutter test
	@echo "$(GREEN)✅ All root and example tests passed!$(RESET)"

test-coverage:
	@echo "$(CYAN)🧪 Running package tests with coverage...$(RESET)"
	flutter test --coverage
	@echo "$(GREEN)✅ Coverage data generated at coverage/lcov.info$(RESET)"

coverage-html: test-coverage
	@if command -v genhtml >/dev/null 2>&1; then \
		echo "$(CYAN)📊 Generating HTML coverage report...$(RESET)"; \
		genhtml coverage/lcov.info -o coverage/html; \
		echo "$(GREEN)✅ Report generated at coverage/html/index.html$(RESET)"; \
		open coverage/html/index.html || true; \
	else \
		echo "$(YELLOW)⚠️  genhtml (lcov) is not installed. Install via 'brew install lcov'.$(RESET)"; \
	fi

# ------------------------------------------------------------------------------
# CI & Full Local Verification
# ------------------------------------------------------------------------------
check: verify
ci: verify

verify: format-check analyze-all test-all dry-run
	@echo ""
	@echo "$(BOLD)$(GREEN)==============================================================================$(RESET)"
	@echo "$(BOLD)$(GREEN)  🎉 ALL CHECKS PASSED! Ready for commit, PR, or pub.dev release!$(RESET)"
	@echo "$(BOLD)$(GREEN)==============================================================================$(RESET)"

# ------------------------------------------------------------------------------
# Example Application Workflows
# ------------------------------------------------------------------------------
example-run:
	@cd example && flutter run

example-run-release:
	@cd example && flutter run --release

example-codegen:
	@echo "$(CYAN)⚙️  Running code generation in example...$(RESET)"
	@cd example && dart run build_runner build --delete-conflicting-outputs

example-watch:
	@cd example && dart run build_runner watch --delete-conflicting-outputs

example-build-apk:
	@cd example && flutter build apk --split-per-abi

example-build-appbundle:
	@cd example && flutter build appbundle

example-refetch:
	@cd example && make refetch-flutter_prakash_ads

# ------------------------------------------------------------------------------
# Publishing & Release Management
# ------------------------------------------------------------------------------
dry-run:
	@echo "$(CYAN)🚀 Running pub.dev publish dry-run validation...$(RESET)"
	dart pub publish --dry-run
	@echo "$(GREEN)✅ Publish dry-run validation passed!$(RESET)"

pana:
	@echo "$(CYAN)🩺 Running pana package health analysis...$(RESET)"
	@which pana >/dev/null 2>&1 || dart pub global activate pana
	dart pub global run pana . --no-ansi

publish-check: version format-check analyze-all test-all dry-run
	@echo ""
	@echo "$(BOLD)$(GREEN)✅ Pre-publish checklist completed successfully!$(RESET)"
	@echo "Ready to publish $(BOLD)$(PKG_NAME) v$(PKG_VERSION)$(RESET)."
	@echo "Run $(BOLD)make publish$(RESET) to publish interactively, or $(BOLD)make tag$(RESET) to release via GitHub Actions."

publish: publish-check
	@echo ""
	@echo "$(BOLD)$(YELLOW)⚠️  You are about to publish $(PKG_NAME) v$(PKG_VERSION) to pub.dev!$(RESET)"
	@read -p "Proceed with publishing? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(CYAN)🚀 Publishing to pub.dev...$(RESET)"; \
		dart pub publish; \
	else \
		echo "$(YELLOW)Publishing aborted.$(RESET)"; \
	fi

publish-force: publish-check
	@echo "$(CYAN)🚀 Force publishing $(PKG_NAME) v$(PKG_VERSION) to pub.dev...$(RESET)"
	dart pub publish --force

tag:
	@echo "$(CYAN)🏷️  Tagging version v$(PKG_VERSION)...$(RESET)"
	@git diff-index --quiet HEAD -- || (echo "$(RED)❌ Git working directory has uncommitted changes. Commit or stash first.$(RESET)" && exit 1)
	git tag "v$(PKG_VERSION)"
	git push origin "v$(PKG_VERSION)"
	@echo "$(GREEN)✅ Tag v$(PKG_VERSION) created and pushed! GitHub Actions will trigger publishing.$(RESET)"
