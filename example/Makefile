.PHONY: help get clean run run-release test analyze format codegen watch build-apk build-appbundle refetch-flutter_ads refetch-ads fcgb

help:
	@echo "Available commands:"
	@echo "  make get                  - Get flutter dependencies"
	@echo "  make clean                - Clean flutter build artifacts"
	@echo "  make run                  - Run debug app"
	@echo "  make run-release          - Run release app"
	@echo "  make test                 - Run flutter tests"
	@echo "  make analyze              - Run dart analyze"
	@echo "  make format               - Format dart code"
	@echo "  make codegen              - Run build_runner code generation"
	@echo "  make watch                - Run build_runner watch"
	@echo "  make build-apk            - Build Android APK"
	@echo "  make build-appbundle      - Build Android AppBundle"
	@echo "  make refetch-flutter_ads  - Refetch/update flutter_ads local package & regenerate DI"
	@echo "  make fcgb                 - Clean, pub get, and regenerate build_runner code"

get:
	flutter pub get

clean:
	flutter clean

run:
	flutter run

run-release:
	flutter run --release

test:
	flutter test

analyze:
	dart analyze

format:
	dart format lib test

codegen:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

build-apk:
	flutter build apk --split-per-abi

build-appbundle:
	flutter build appbundle

refetch-flutter_ads:
	@echo "🔄 Refetching flutter_ads package from ../flutter_ads..."
	flutter pub remove flutter_ads || true
	flutter pub add flutter_ads --path=../flutter_ads
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs
	dart analyze
	@echo "✅ flutter_ads package successfully updated & verified!"

refetch-ads: refetch-flutter_ads

fcgb:
	flutter clean
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs
