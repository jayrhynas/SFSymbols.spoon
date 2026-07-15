--- === SFSymbols ===
---
--- Render SF Symbols as template `hs.image` icons.
---
--- Hammerspoon has no native SF Symbol support, so this Spoon renders a symbol
--- to a cached template PNG (via a bundled Swift helper) and returns it as an
--- `hs.image` suitable for menubars, canvases, toolbars, etc. Because the
--- images are marked as templates, they inherit the menubar's monochrome tint
--- and adapt to light/dark automatically.
---
--- # Usage
---
--- ```
--- hs.loadSpoon("SFSymbols")
--- local icon = spoon.SFSymbols:image("cup.and.saucer.fill", { height = 16 })
--- someMenubar:setIcon(icon)
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "SFSymbols"
obj.version = "1.0"
obj.author = "Jayson Rhynas <jayrhynas@gmail.com>"
obj.homepage = "https://github.com/jayrhynas/SFSymbols.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- SFSymbols.cacheDir
--- Variable
--- Directory where rendered template PNGs are cached. Defaults to
--- `<hs.configdir>/.cache/SFSymbols`. Set this before the first `:image()` call
--- to override.
obj.cacheDir = hs.configdir .. "/.cache/SFSymbols"

-- In-memory memoisation, keyed by the full render spec.
obj._cache = {}

local function safeName(name) return (name:gsub("[^%w]", "_")) end

function obj:_pngPath(name, pt, scale, weight)
    return string.format("%s/%s_%dpt_%dx_%s.png", self.cacheDir, safeName(name), pt, scale, weight)
end

-- Renders the template PNG for a symbol if it isn't already cached on disk.
function obj:_ensurePng(name, pt, scale, weight)
    local path = self:_pngPath(name, pt, scale, weight)
    if hs.fs.attributes(path) then return path end
    hs.execute(string.format('/bin/mkdir -p "%s"', self.cacheDir))
    local gen = hs.spoons.resourcePath("gen-symbol.swift")
    hs.execute(string.format('/usr/bin/swift "%s" %s "%s" %d %d %s',
        gen, name, path, pt, scale, weight))
    return hs.fs.attributes(path) and path or nil
end

--- SFSymbols:image(name[, opts]) -> hs.image | nil
--- Method
--- Returns a template `hs.image` for the named SF Symbol, or `nil` if it can't
--- be rendered (for example, the symbol doesn't exist on this OS). Results are
--- memoised per unique render spec.
---
--- Parameters:
---  * name - the SF Symbol name, e.g. `"cup.and.saucer.fill"`
---  * opts - an optional table of rendering options:
---    * height    - scale the image to this point height, preserving aspect ratio
---    * pointSize - SF Symbol point size to render at (default 18)
---    * scale     - pixel scale factor for retina crispness (default 3)
---    * weight    - `ultralight|thin|light|regular|medium|semibold|bold|heavy|black`
---    * template  - mark as a template image for menubar tinting (default true)
---
--- Returns:
---  * an `hs.image` object, or `nil` on failure
function obj:image(name, opts)
    opts = opts or {}
    local pt = opts.pointSize or 18
    local scale = opts.scale or 3
    local weight = opts.weight or "regular"
    local template = opts.template ~= false
    local key = string.format("%s|%d|%d|%s|%s|%s",
        name, pt, scale, weight, tostring(opts.height), tostring(template))
    if self._cache[key] ~= nil then return self._cache[key] or nil end

    local path = self:_ensurePng(name, pt, scale, weight)
    local img = path and hs.image.imageFromPath(path)
    if img then
        if opts.height then
            local sz = img:size()
            img = img:setSize({ w = opts.height * (sz.w / sz.h), h = opts.height })
        end
        if template then img = img:template(true) end
    end
    self._cache[key] = img or false
    return img or nil
end

return obj
