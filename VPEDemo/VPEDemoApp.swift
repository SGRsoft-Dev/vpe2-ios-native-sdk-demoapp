import SwiftUI
import UIKit
import VPEPlayer

/// SDK의 OrientationManager가 회전을 트리거할 수 있게 해주는 AppDelegate.
/// 보안상 iOS는 앱의 supportedInterfaceOrientations를 통해서만 회전을 허용함.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        OrientationManager.currentMask
    }
}

@main
struct VPEDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
