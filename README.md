# SFSymbols.spoon

Render [SF Symbols](https://developer.apple.com/sf-symbols/) as template
`hs.image` icons for use in Hammerspoon menubars, canvases, and toolbars.

Hammerspoon has no native SF Symbol support (`hs.image.imageFromName` only
resolves classic `NS…` AppKit image names). This Spoon bridges the gap by
rendering a symbol to a cached template PNG via a small bundled Swift helper
(`gen-symbol.swift`, using `NSImage(systemSymbolName:)`) and returning it as an
`hs.image`. Because the images are templates, they inherit the menubar's
monochrome tint and adapt to light/dark automatically.

## Installation

Download [`SFSymbols.spoon.zip`](https://github.com/jayrhynas/SFSymbols.spoon/releases/latest),
unzip it, and double-click `SFSymbols.spoon` to install it into
`~/.hammerspoon/Spoons/`. Or clone it:

```sh
git clone https://github.com/jayrhynas/SFSymbols.spoon.git \
  ~/.hammerspoon/Spoons/SFSymbols.spoon
```

Or install and auto-update it with
[SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html):

```lua
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.repos.jayrhynas = {
    url = "https://github.com/jayrhynas/SFSymbols.spoon",
    desc = "SFSymbols spoon repository",
    branch = "main",
}
spoon.SpoonInstall:andUse("SFSymbols", { repo = "jayrhynas" })
```

## Usage

```lua
hs.loadSpoon("SFSymbols")

local icon = spoon.SFSymbols:image("cup.and.saucer.fill", { height = 16 })
someMenubar:setIcon(icon)
```

### `SFSymbols:image(name[, opts]) -> hs.image | nil`

* `name` — the SF Symbol name, e.g. `"cup.and.saucer.fill"`
* `opts` (all optional):
  * `height` — scale to this point height, preserving aspect ratio
  * `pointSize` — SF Symbol point size to render at (default `18`)
  * `scale` — pixel scale factor for retina crispness (default `3`)
  * `weight` — `ultralight|thin|light|regular|medium|semibold|bold|heavy|black`
  * `template` — mark as a template image for menubar tinting (default `true`)

Returns `nil` if the symbol doesn't exist on the current OS, so callers can
fall back (e.g. to an emoji or text title).

Rendered PNGs are cached on disk (`SFSymbols.cacheDir`, default
`<hs.configdir>/.cache/SFSymbols`) and memoised in memory, so repeated calls are
cheap. The cache key includes name, size, scale, and weight — changing any of
them regenerates automatically.

## Requirements

* macOS 11+ (SF Symbols) and the Swift toolchain (`/usr/bin/swift`, ships with
  the Command Line Tools / Xcode).
