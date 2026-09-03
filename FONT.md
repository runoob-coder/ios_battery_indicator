# Font Subsetting Notes (SF-Pro.ttf)

The battery percentage text in this package (the `fontFamily: 'SF Pro'` in
`DefaultTextStyle` within `lib/src/ios_battery_indicator.dart`) does not use the
complete SF Pro font, but a trimmed-down subset `fonts/SF-Pro.ttf` produced via
**subsetting**. This is done for the following reasons:

- **Reduce release size**: the full SF Pro is several MB, while only a handful of glyphs are
  actually used.
- **Preserve necessary OpenType features**: the battery digits rely on the `tnum` (tabular figures)
  feature to implement `FontFeature.tabularFigures()`, so the relevant layout features must be kept.
- **Strip unused glyphs**: only the digits, symbols, and a few SF Symbol glyphs needed for rendering
  are retained.

---

## 1. Prerequisites

Subsetting uses the Python `fonttools` toolchain, installed via [Homebrew](https://brew.sh/):

```bash
brew install fonttools
```

> `pyftsubset` is installed alongside `fonttools` and can be called directly in the terminal after
> installation.

---

## 2. Subsetting Command

Extract the minimal usable subset from the full system font `/Library/Fonts/SF-Pro.ttf`:

```bash
pyftsubset /Library/Fonts/SF-Pro.ttf \
  --text='1234567890%􀋦 ' \
  --layout-features=kern,tnum,pnum \
  --gids=9634,9635 \
  --output-file=$HOME/Downloads/SF-Pro.ttf
```

Copy the generated `SF-Pro.ttf` back into the repository's `fonts/` directory:

```bash
cp $HOME/Downloads/SF-Pro.ttf fonts/SF-Pro.ttf
```
