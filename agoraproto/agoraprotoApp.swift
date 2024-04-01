//
//  agoraprotoApp.swift
//  agoraproto
//



import SwiftUI
import Firebase


@main
struct googlefirebaseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isUserAuthenticated = false
    var body: some Scene {
        WindowGroup {
            if isUserAuthenticated {
                HomeView(isUserAuthenticated: $isUserAuthenticated)
            } else {
                AuthenticationView(isUserAuthenticated: $isUserAuthenticated)
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      

    return true
  }
}
