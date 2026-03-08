# Coffeetosh Makefile
# Used by the Homebrew formula to install pre-built binaries.
# For local development, use `swift build -c release` directly.

VERSION   ?= $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "1.2.0")
PREFIX    ?= /usr/local

BINDIR     = $(DESTDIR)$(PREFIX)/bin
LIBEXECDIR = $(DESTDIR)$(PREFIX)/libexec/coffeetosh
SHAREDIR   = $(DESTDIR)$(PREFIX)/share/coffeetosh

.PHONY: build universal install uninstall

# ── Local development build (native arch) ────────────────────────
build:
	swift build -c release

# ── Universal binary (arm64 + x86_64 via lipo) ───────────────────
universal:
	swift build -c release --arch arm64
	swift build -c release --arch x86_64
	mkdir -p .build/universal
	lipo -create -output .build/universal/coffeetosh \
		.build/arm64-apple-macosx/release/coffeetosh \
		.build/x86_64-apple-macosx/release/coffeetosh
	lipo -create -output .build/universal/coffeetosh-daemon \
		.build/arm64-apple-macosx/release/coffeetosh-daemon \
		.build/x86_64-apple-macosx/release/coffeetosh-daemon
	lipo -create -output .build/universal/coffeetosh-cleanup \
		.build/arm64-apple-macosx/release/coffeetosh-cleanup \
		.build/x86_64-apple-macosx/release/coffeetosh-cleanup

# ── Install pre-built binaries (called by Homebrew formula) ──────
# Expects binaries to be in $PWD (from the release tarball).
install:
	install -d "$(BINDIR)"
	install -d "$(LIBEXECDIR)"
	install -d "$(SHAREDIR)"
	install -m 755 coffeetosh         "$(BINDIR)/coffeetosh"
	install -m 755 coffeetosh-daemon  "$(LIBEXECDIR)/coffeetosh-daemon"
	install -m 755 coffeetosh-cleanup "$(LIBEXECDIR)/coffeetosh-cleanup"
	install -m 644 Resources/com.coffeetosh.daemon.plist  "$(SHAREDIR)/com.coffeetosh.daemon.plist"
	install -m 644 Resources/com.coffeetosh.cleanup.plist "$(SHAREDIR)/com.coffeetosh.cleanup.plist"

# ── Uninstall ─────────────────────────────────────────────────────
uninstall:
	rm -f  "$(BINDIR)/coffeetosh"
	rm -rf "$(LIBEXECDIR)"
	rm -rf "$(SHAREDIR)"
