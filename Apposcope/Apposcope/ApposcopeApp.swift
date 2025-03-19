import SwiftUI
import Foundation
import AppKit

struct AppInfo: Identifiable {
    let id = UUID()
    let icon: NSImage?
    let name: String
    let sandboxed: String
    let language: String
    let path: String
}

class AppScanner: ObservableObject {
    @Published var apps: [AppInfo] = []
    @Published var isScanning: Bool = true
    @Published var sortOrder: [KeyPathComparator<AppInfo>] = [
        KeyPathComparator(\AppInfo.name)
    ]
    
    init() {
        DispatchQueue.global(qos: .background).async {
            self.scanApplications()
        }
    }
    
    func scanApplications() {
        defer { DispatchQueue.main.async { self.isScanning = false } }
        let applicationsFolder = "/Applications"
        if let enumerator = FileManager.default.enumerator(atPath: applicationsFolder) {
            for case let path as String in enumerator {
                if path.hasSuffix(".app") {
                    let appPath = "\(applicationsFolder)/\(path)"
                    
                    // Ignore apps inside other apps
                    if path.contains(".app/") { continue }
                    
                    let appName = URL(fileURLWithPath: appPath).deletingPathExtension().lastPathComponent
                    let sandboxed = checkSandboxStatus(appPath)
                    let language = detectLanguage(appPath)
                    let icon = getAppIcon(appPath)
                    
                    DispatchQueue.main.async {
                        self.apps.append(AppInfo(icon: icon, name: appName, sandboxed: sandboxed, language: language, path: appPath))
                    }
                }
            }
        }
    }
    
    private func checkSandboxStatus(_ appPath: String) -> String {
        let binaryPath = "\(appPath)/Contents/MacOS"
        guard let binaries = try? FileManager.default.contentsOfDirectory(atPath: binaryPath),
              let binary = binaries.first else { return "Unknown" }
        let fullBinaryPath = "\(binaryPath)/\(binary)"
        
        let process = Process()
        process.launchPath = "/usr/bin/codesign"
        process.arguments = ["-d", "--entitlements", "-", fullBinaryPath]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.contains("com.apple.security.app-sandbox") ? "Yes" : "No"
        } catch {
            return "Unknown"
        }
    }
    
    private func detectLanguage(_ appPath: String) -> String {
        let binaryPath = "\(appPath)/Contents/MacOS"
        guard let binaries = try? FileManager.default.contentsOfDirectory(atPath: binaryPath),
              let binary = binaries.first else { return "Unknown" }
        let fullBinaryPath = "\(binaryPath)/\(binary)"
        
        let process = Process()
        process.launchPath = "/usr/bin/otool"
        process.arguments = ["-L", fullBinaryPath]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            if output.contains("libswiftCore.dylib") { return "Swift" }
            if output.contains("libobjc.A.dylib") { return "Objective-C" }
            if output.lowercased().contains("electron") ||
               output.lowercased().contains("nwjs") ||
               output.lowercased().contains("appjs") ||
               output.lowercased().contains("meteor") { return "JavaScript" }
            
            return "Unknown"
        } catch {
            return "Unknown" }
    }
    
    private func getAppIcon(_ appPath: String) -> NSImage? {
        let workspace = NSWorkspace.shared
        return workspace.icon(forFile: appPath)
    }
}

struct ContentView: View {
    @StateObject var scanner = AppScanner()
    
    var body: some View {
        ZStack {
            VStack {
                appsTable()
            }
            if scanner.isScanning {
                loadingOverlay()
            }
        }
        .padding()
    }

    @ViewBuilder
    private func appsTable() -> some View {
        Table(scanner.apps, sortOrder: $scanner.sortOrder) {
            TableColumn("") { app in
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            .width(25)
            TableColumn("App Name", value: \ .name)
            TableColumn("Sandboxed", value: \ .sandboxed)
            TableColumn("Language", value: \ .language)
        }
        .padding()
        .onChange(of: scanner.sortOrder) { newOrder in
            scanner.apps.sort(using: newOrder)
        }
    }

    @ViewBuilder
    private func loadingOverlay() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2)
            Text("Scanning applications...")
                .padding(.top, 8)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 5))
    }

    func revealInFinder(_ path: String) {
        let url = URL(fileURLWithPath: path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

@main
struct AppScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
