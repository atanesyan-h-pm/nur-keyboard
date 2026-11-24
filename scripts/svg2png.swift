// Rasterise an SVG to a PNG of the given pixel size using macOS's built-in SVG support.
// usage: swift svg2png.swift in.svg out.png width [height]
import AppKit
let a = CommandLine.arguments
guard a.count >= 4, let w = Int(a[3]) else { fatalError("usage: in.svg out.png width [height]") }
let h = a.count > 4 ? Int(a[4])! : w
guard let img = NSImage(contentsOf: URL(fileURLWithPath: a[1])) else { fatalError("cannot read \(a[1])") }
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current?.imageInterpolation = .none
img.draw(in: NSRect(x: 0, y: 0, width: w, height: h))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
