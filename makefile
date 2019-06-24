.PHONY: xcodeproj

xcodeproj:
	swift package generate-xcodeproj --skip-extra-files --output CLI/CLI.xcodeproj

dev: xcodeproj
	xed Hyperdrive.xcworkspace
