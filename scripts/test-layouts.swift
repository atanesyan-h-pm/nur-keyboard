#!/usr/bin/env swift
// Verify every Nur layout through macOS's own key translation (UCKeyTranslate) against
// docs/mapping-tables.md, the ground truth transcribed from upstream xkeyboard-config.
//
// usage: swift scripts/test-layouts.swift [--bundle PATH] [--tables PATH]
//
//   --bundle PATH   test this Nur.bundle (e.g. the checkout's Nur.bundle) instead of the installed one
//   --tables PATH   mapping tables to compare against (default: docs/mapping-tables.md)
//
// Without --bundle it tests the installed ~/Library/Keyboard Layouts/Nur.bundle as macOS has it
// loaded (what the user types with), or the checkout's Nur.bundle if nothing is installed.
//
// A bundle given with --bundle (or the checkout) is tested through a temporary copy,
// ~/Library/Keyboard Layouts/NurTest-<random>.bundle, with a unique bundle id
// ("am.nur.keyboardlayout.nurtest.<random>") and unique numeric layout ids. All three are needed:
// macOS caches input sources by id (a changed bundle registered under the installed ids silently
// returns the old layouts), rejects layouts whose numeric id is already loaded, and only registers
// bundles that live in a Keyboard Layouts folder. The copy is deleted on exit (also on Ctrl-C), and
// leftovers from an interrupted run are removed at start. The temporary sources stay known to macOS
// until you log out; they are never enabled.
//
// Checked per key and layout: base, Shift, Caps Lock, Option, Shift+Option, Command.
// Exit status: 0 = all match, 1 = mismatches or setup error.
import Carbon
import Foundation

// MARK: - helpers

/// The uniquely-named test copy in ~/Library/Keyboard Layouts (see uniqueCopy). Every exit path goes
/// through finish(), which deletes it: `atexit` alone is not enough, because it doesn't run when the
/// script is executed by the `swift` interpreter.
var tempBundle: String?
func removeTempBundle() { if let b = tempBundle { try? FileManager.default.removeItem(atPath: b) } }
func finish(_ code: Int32) -> Never { removeTempBundle(); exit(code) }

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("test-layouts: \(message)\n".utf8))
    finish(1)
}

func warn(_ message: String) {
    FileHandle.standardError.write(Data("warning: \(message)\n".utf8))
}

/// Repository root: the folder above scripts/ (from #filePath, which may be relative when compiled
/// with a relative path), else the nearest folder upwards from the current directory that has
/// docs/mapping-tables.md.
let repoRoot: URL = {
    let fm = FileManager.default
    let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)
    var candidates = [URL(fileURLWithPath: #filePath, relativeTo: cwd).deletingLastPathComponent().deletingLastPathComponent()]
    var dir = cwd
    while true {
        candidates.append(dir)
        let up = dir.deletingLastPathComponent()
        if up.path == dir.path { break }
        dir = up
    }
    return candidates.first { fm.fileExists(atPath: $0.appendingPathComponent("docs/mapping-tables.md").path) }
        ?? cwd
}()

func normalized(_ s: String) -> String {
    String(s.lowercased().unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) })
}

// MARK: - arguments

var bundleArg: String?
var tablesPath = repoRoot.appendingPathComponent("docs/mapping-tables.md").path
var argv = CommandLine.arguments.dropFirst().makeIterator()
while let a = argv.next() {
    switch a {
    case "--bundle": guard let v = argv.next() else { fail("--bundle needs a path") }; bundleArg = v
    case "--tables": guard let v = argv.next() else { fail("--tables needs a path") }; tablesPath = v
    case "-h", "--help":
        print("usage: swift scripts/test-layouts.swift [--bundle PATH] [--tables PATH]"); finish(0)
    default: fail("unknown argument '\(a)' (try --help)")
    }
}

// MARK: - ground truth from docs/mapping-tables.md

/// Split a markdown table row into cells, honouring `\|` escapes.
func cells(_ row: String) -> [String] {
    var out: [String] = [], cur = "", prevBackslash = false
    for ch in row {
        if ch == "|" && !prevBackslash { out.append(cur); cur = "" }
        else if ch == "|" { cur.removeLast(); cur.append(ch) }  // drop the escaping backslash
        else { cur.append(ch) }
        prevBackslash = (ch == "\\")
    }
    out.append(cur)
    // drop the empty edges outside the first and last pipe
    return Array(out.dropFirst().dropLast()).map { $0.trimmingCharacters(in: .whitespaces) }
}

/// Strip the surrounding single backticks of a code cell: `TLDE` -> TLDE, ``` -> `.
func code(_ cell: String) -> String {
    guard cell.count >= 3, cell.hasPrefix("`"), cell.hasSuffix("`") else { return cell }
    return String(cell.dropFirst().dropLast())
}

guard let markdown = try? String(contentsOfFile: tablesPath, encoding: .utf8) else {
    fail("cannot read \(tablesPath) (run from the repository, or pass --tables PATH)")
}
let lines = markdown.components(separatedBy: "\n")

// "## Key codes": | `xkb` | keycode | `US char` |
var keyCode: [String: UInt16] = [:]   // xkb name -> mac key code
var usChar: [UInt16: String] = [:]    // mac key code -> US QWERTY character (Command layer)
// "## Layouts": | `xkb` | base / Shift | … per layout column
var columns: [String] = []            // e.g. "Standard", "Phonetic Alt"
var expected: [String: [UInt16: (base: String, shift: String)]] = [:]

var section = ""
for line in lines {
    if line.hasPrefix("## ") { section = line; continue }
    guard line.hasPrefix("|"), !line.hasPrefix("|---") else { continue }
    let c = cells(line)
    if section.hasPrefix("## Key codes") {
        guard c.count == 3, let kc = UInt16(c[1]) else { continue }  // header row has no number
        keyCode[code(c[0])] = kc
        usChar[kc] = code(c[2])
    } else if section.hasPrefix("## Layouts") {
        if c.first == "xkb" {
            columns = c.dropFirst().map { $0.components(separatedBy: " (").first ?? $0 }
            continue
        }
        guard c.count == columns.count + 1 else { fail("row has \(c.count) cells, expected \(columns.count + 1): \(line)") }
        guard let kc = keyCode[code(c[0])] else { fail("unknown key \(c[0]) in layout table") }
        for (col, cell) in zip(columns, c.dropFirst()) where cell != "*(US)*" {
            // "a / b"; the separator is the first " / " (a cell like "/ / ՞" is "/" and "՞").
            guard let r = cell.range(of: " / ") else { fail("cannot read cell '\(cell)' for \(c[0])") }
            expected[col, default: [:]][kc] = (String(cell[..<r.lowerBound]), String(cell[r.upperBound...]))
        }
    }
}
guard !keyCode.isEmpty, !columns.isEmpty else { fail("no key-code or layout table found in \(tablesPath)") }

// MARK: - pick and register the bundle

let fm = FileManager.default
let installed = (NSHomeDirectory() as NSString).appendingPathComponent("Library/Keyboard Layouts/Nur.bundle")
let checkout = repoRoot.appendingPathComponent("Nur.bundle").path
let testInstalled = bundleArg == nil && fm.fileExists(atPath: installed)
let bundlePath = bundleArg.map { ($0 as NSString).standardizingPath } ?? (testInstalled ? installed : checkout)
guard fm.fileExists(atPath: bundlePath + "/Contents/Info.plist") else { fail("no Nur.bundle at \(bundlePath)") }

// Testing the installed copy? Warn if it isn't the same as the checkout, or the result says little
// about the files being edited.
if testInstalled, fm.fileExists(atPath: checkout) {
    let rel = (try? fm.contentsOfDirectory(atPath: checkout + "/Contents/Resources")) ?? []
    let differs = (["Contents/Info.plist"] + rel.filter { $0.hasSuffix(".keylayout") }.map { "Contents/Resources/" + $0 })
        .contains { !fm.contentsEqual(atPath: checkout + "/" + $0, andPath: installed + "/" + $0) }
    if differs {
        warn("the installed Nur.bundle differs from the checkout's; run scripts/install.sh, " +
             "or pass --bundle \(checkout) to test the checkout")
    }
}

// Remove the test copy on Ctrl-C / kill too (a hard SIGKILL leftover is removed at the next start).
atexit { removeTempBundle() }
signal(SIGINT) { _ in removeTempBundle(); exit(130) }
signal(SIGTERM) { _ in removeTempBundle(); exit(143) }

/// Copy `bundle` into ~/Library/Keyboard Layouts with a unique bundle id, unique TISInputSourceIDs and
/// unique numeric layout ids, so macOS compiles it fresh instead of returning cached layouts.
func uniqueCopy(of bundle: String) -> (path: String, idPrefix: String) {
    let layoutsDir = (NSHomeDirectory() as NSString).appendingPathComponent("Library/Keyboard Layouts")
    // Leftovers from a run that was killed hard (SIGKILL) would otherwise load at the next login.
    for stale in (try? fm.contentsOfDirectory(atPath: layoutsDir)) ?? [] where stale.hasPrefix("NurTest-") {
        try? fm.removeItem(atPath: (layoutsDir as NSString).appendingPathComponent(stale))
    }
    let token = UUID().uuidString.prefix(8).lowercased()
    let newID = "am.nur.keyboardlayout.nurtest.\(token)"
    let copy = (layoutsDir as NSString).appendingPathComponent("NurTest-\(token).bundle")
    do {
        try fm.createDirectory(atPath: layoutsDir, withIntermediateDirectories: true)
        tempBundle = copy
        try fm.copyItem(atPath: bundle, toPath: copy)

        let plistURL = URL(fileURLWithPath: copy + "/Contents/Info.plist")
        guard var info = try PropertyListSerialization.propertyList(from: Data(contentsOf: plistURL), format: nil)
                as? [String: Any], let oldID = info["CFBundleIdentifier"] as? String else {
            fail("cannot read \(bundle)/Contents/Info.plist")
        }
        info["CFBundleIdentifier"] = newID
        for (key, value) in info where key.hasPrefix("KLInfo_") {
            guard var kl = value as? [String: Any], let sid = kl["TISInputSourceID"] as? String else { continue }
            kl["TISInputSourceID"] = sid.hasPrefix(oldID) ? newID + sid.dropFirst(oldID.count) : newID + "." + sid
            info[key] = kl
        }
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0).write(to: plistURL)

        // Fresh numeric ids, in a range away from the shipped -21001…-21006.
        let resources = copy + "/Contents/Resources"
        var nextID = -29000 - Int.random(in: 0..<300) * 10
        for f in try fm.contentsOfDirectory(atPath: resources) where f.hasSuffix(".keylayout") {
            let path = (resources as NSString).appendingPathComponent(f)
            let xml = try String(contentsOfFile: path, encoding: .utf8)
            guard let r = xml.range(of: #"<keyboard [^>]*\bid="-?\d+""#, options: .regularExpression),
                  let idr = xml[r].range(of: #"id="-?\d+""#, options: .regularExpression) else {
                fail("no <keyboard id=…> in \(f)")
            }
            try xml.replacingCharacters(in: idr, with: "id=\"\(nextID)\"").write(toFile: path, atomically: true, encoding: .utf8)
            nextID -= 1
        }
    } catch {
        fail("cannot prepare a test copy of \(bundle): \(error.localizedDescription)")
    }
    return (copy, newID)
}

// Which input-source ids belong to the bundle under test.
let registerPath: String
let belongs: (String) -> Bool
if testInstalled {
    registerPath = bundlePath
    belongs = { $0.lowercased().contains("keyboardlayout.nur.") && !$0.lowercased().contains("nurtest") }
    print("Testing the installed \(bundlePath) (as macOS has it loaded)")
} else {
    let c = uniqueCopy(of: bundlePath)
    registerPath = c.path
    belongs = { $0.hasPrefix(c.idPrefix + ".") }
    print("Testing \(bundlePath) (via a temporary copy with id \(c.idPrefix))")
}

let status = TISRegisterInputSource(URL(fileURLWithPath: registerPath) as CFURL)
if status != noErr { warn("TISRegisterInputSource returned \(status); using whatever macOS already has loaded") }

// MARK: - find the Nur input sources

func property<T>(_ source: TISInputSource, _ key: CFString) -> T? {
    guard let p = TISGetInputSourceProperty(source, key) else { return nil }
    return Unmanaged<AnyObject>.fromOpaque(p).takeUnretainedValue() as? T
}

let all = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource] ?? []
var sources: [(id: String, data: CFData)] = []
for s in all {
    let id: String = property(s, kTISPropertyInputSourceID) ?? ""
    guard belongs(id), let data: CFData = property(s, kTISPropertyUnicodeKeyLayoutData) else { continue }
    sources.append((id, data))
}
guard !sources.isEmpty else {
    fail("macOS has no Nur input sources loaded (is \(bundlePath) a valid bundle? try scripts/validate.sh)")
}

/// The input source for a table column. Ids end with the variant, either as
/// "am.nur.keyboardlayout.nur.phonetic-alt" (from Info.plist) or "…keylayout.AMNurPhoneticAlt" (when
/// registered on the fly), so compare normalized suffixes: "phoneticalt" does not end with "phonetic".
func source(for column: String) -> (id: String, data: CFData)? {
    let want = normalized(column)
    return sources.first { normalized($0.id).hasSuffix(want) }
}

// MARK: - translate and compare

func translate(_ data: CFData, _ keyCode: UInt16, _ modifiers: Int) -> String {
    guard let bytes = CFDataGetBytePtr(data) else { return "<no data>" }
    let layout = UnsafeRawPointer(bytes).assumingMemoryBound(to: UCKeyboardLayout.self)
    var deadKeys: UInt32 = 0
    var length = 0
    var chars = [UniChar](repeating: 0, count: 8)
    let err = UCKeyTranslate(layout, keyCode, UInt16(kUCKeyActionDown), UInt32((modifiers >> 8) & 0xFF),
                             UInt32(LMGetKbdType()), OptionBits(kUCKeyTranslateNoDeadKeysBit),
                             &deadKeys, chars.count, &length, &chars)
    return err == noErr ? String(utf16CodeUnits: chars, count: length) : "<error \(err)>"
}

func show(_ s: String) -> String {
    s.unicodeScalars.map { $0.value < 0x20 || $0.value == 0x7F ? String(format: "U+%04X", $0.value) : String($0) }.joined()
}

let modifierSets: [(name: String, mask: Int)] = [
    ("base", 0), ("Shift", shiftKey), ("Caps Lock", alphaLock),
    ("Option", optionKey), ("Shift+Option", shiftKey | optionKey), ("Command", cmdKey),
]

var checked = 0, mismatches = 0, missing = 0
for column in columns {
    let name = "AM Nur \(column)"
    guard let src = source(for: column) else {
        print("MISSING  \(name): no loaded input source matches"); missing += 1; continue
    }
    var layoutMismatches = 0
    for (xkb, kc) in keyCode.sorted(by: { $0.value < $1.value }) {
        var want: [String: String] = ["Command": usChar[kc] ?? ""]
        if let pair = expected[column]?[kc] {
            let (a, b) = (pair.base, pair.shift)
            // Caps Lock gives the Shift letter only for letters (b is a's capital), base otherwise.
            let caps = (b != a && b == a.uppercased()) ? b : a
            want.merge(["base": a, "Shift": b, "Caps Lock": caps, "Option": a, "Shift+Option": b]) { $1 }
        }
        for (mod, mask) in modifierSets {
            guard let w = want[mod] else { continue }  // "*(US)*" keys: only Command is specified
            checked += 1
            let got = translate(src.data, kc, mask)
            if got != w {
                mismatches += 1; layoutMismatches += 1
                print("MISMATCH \(name)  key \(xkb) (code \(kc))  \(mod): expected '\(show(w))', got '\(show(got))'")
            }
        }
    }
    print("\(layoutMismatches == 0 ? "ok      " : "FAIL    ") \(name)  [\(src.id)]")
}

print("\n\(columns.count - missing)/\(columns.count) layouts, \(checked) key/modifier pairs checked, " +
      "\(mismatches) mismatches")
finish(mismatches == 0 && missing == 0 ? 0 : 1)
