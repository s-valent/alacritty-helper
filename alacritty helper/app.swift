import SwiftUI
import Cocoa

@main
struct Opener: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if alacrittyPath() != nil {
            register()
        }
        
        if let application = notification.object as? NSApplication {
            application.terminate(self)
        }
    }
        
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            let url = url.absoluteString
            
            if url.starts(with: "ssh://") {
                let address = String(url.dropFirst("ssh://".count))
                run("ssh", address)
            } else if url.starts(with: "file://") {
                let filename = String(url.dropFirst("file://".count))
                run(filename)
            }
        }
        application.terminate(self)
    }
}


func alacrittyPath() -> String? {
    return NSWorkspace().urlForApplication(withBundleIdentifier: "org.alacritty")?.path()
}


func run(_ arguments: String...) {
    if let path = alacrittyPath() {
        let task = Process()
        task.launchPath = path + "Contents/MacOS/alacritty"
        var taskArguments = ["-e", Bundle.main.resourceURL!.path + "/wrapper.sh"]
        taskArguments.append(contentsOf: arguments)
        task.arguments = taskArguments
        try? task.run()
    }
}

func register() {
    let bundleID = Bundle.main.bundleIdentifier! as CFString
    LSSetDefaultHandlerForURLScheme("ssh" as CFString, bundleID)
    LSSetDefaultRoleHandlerForContentType("public.unix-executable" as CFString, LSRolesMask.all, bundleID)
}
