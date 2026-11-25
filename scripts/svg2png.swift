// Rasterise an SVG to a PNG of the given pixel size using macOS's built-in SVG support.
//
// usage: swift scripts/svg2png.swift in.svg out.png width [height]
//        (or compile once: swiftc -O scripts/svg2png.swift -o svg2png)
//
// Every failure prints to stderr and exits 1, so a broken input never yields a blank PNG with exit code 0.
import AppKit

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("svg2png: \(message)\n".utf8))
    exit(1)
}

func pixels(_ text: String, _ name: String) -> Int {
    guard let n = Int(text), n > 0, n <= 16384 else {
        fail("\(name) must be a whole number of pixels between 1 and 16384, got '\(text)'")
    }
    return n
}

let args = CommandLine.arguments
guard args.count == 4 || args.count == 5 else {
    fail("usage: svg2png in.svg out.png width [height]")
}
let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])
let width = pixels(args[3], "width")
let height = args.count == 5 ? pixels(args[4], "height") : width

guard FileManager.default.isReadableFile(atPath: inputURL.path) else {
    fail("cannot read \(inputURL.path)")
}
guard let image = NSImage(contentsOf: inputURL), image.isValid, image.size.width > 0, image.size.height > 0 else {
    fail("\(inputURL.path) is not an image macOS can load")
}
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
                                 bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                 colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
    fail("cannot allocate a \(width)×\(height) bitmap")
}
guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
    fail("cannot create a drawing context for the bitmap")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
context.imageInterpolation = .none  // keep the 16×16 knot-grid icon crisp when scaled up
image.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    fail("cannot encode PNG")
}
do {
    try png.write(to: outputURL, options: .atomic)
} catch {
    fail("cannot write \(outputURL.path): \(error.localizedDescription)")
}
