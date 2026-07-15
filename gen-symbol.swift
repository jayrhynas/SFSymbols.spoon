// Renders an SF Symbol to a template-friendly PNG (black glyph on transparent).
// usage: swift gen-symbol.swift <symbol> <out> [pointSize=18] [scale=3] [weight=regular]
import Cocoa

let a = CommandLine.arguments
guard a.count >= 3 else {
    FileHandle.standardError.write("usage: <symbol> <out> [pt] [scale] [weight]\n".data(using: .utf8)!)
    exit(2)
}
let name = a[1]
let out = a[2]
let pt = CGFloat(a.count > 3 ? Double(a[3]) ?? 18 : 18)
let scale = CGFloat(a.count > 4 ? Double(a[4]) ?? 3 : 3)
let weightName = (a.count > 5 ? a[5] : "regular").lowercased()

let weights: [String: NSFont.Weight] = [
    "ultralight": .ultraLight, "thin": .thin, "light": .light, "regular": .regular,
    "medium": .medium, "semibold": .semibold, "bold": .bold, "heavy": .heavy, "black": .black,
]
let cfg = NSImage.SymbolConfiguration(pointSize: pt, weight: weights[weightName] ?? .regular)
guard let sym = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(cfg) else {
    FileHandle.standardError.write("MISSING: \(name)\n".data(using: .utf8)!)
    exit(1)
}
let size = sym.size
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil,
        pixelsWide: Int((size.width * scale).rounded()),
        pixelsHigh: Int((size.height * scale).rounded()),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
rep.size = size
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.black.set()
sym.draw(in: NSRect(origin: .zero, size: size))
NSGraphicsContext.restoreGraphicsState()
guard let data = rep.representation(using: .png, properties: [:]) else { exit(1) }
try data.write(to: URL(fileURLWithPath: out))
print("OK \(name) -> \(out)")
