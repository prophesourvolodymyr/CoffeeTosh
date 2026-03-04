#!/bin/bash
set -e
RSVG="/opt/homebrew/bin/rsvg-convert"
ASSETS="/Users/volodymurvasualkiw/Desktop/Opensource/Coffeetosh/CoffeeTosh/CoffeeTosh/Assets.xcassets"
NOTES="/Users/volodymurvasualkiw/Desktop/Opensource/Coffeetosh/NOTES/Coffeetosh UI/ASSETS"

"$RSVG" -f pdf -w 64 -h 64 "$NOTES/logo-filled.svg"  -o "$ASSETS/logo-filled.imageset/logo-filled.pdf"
echo "filled PDF: $(stat -f '%z bytes, modified %Sm' "$ASSETS/logo-filled.imageset/logo-filled.pdf")"

"$RSVG" -f pdf -w 64 -h 64 "$NOTES/logo-outline.svg" -o "$ASSETS/logo-outline.imageset/logo-outline.pdf"
echo "outline PDF: $(stat -f '%z bytes, modified %Sm' "$ASSETS/logo-outline.imageset/logo-outline.pdf")"
