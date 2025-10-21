//
//  SceneDelegate.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var authHandle: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if Auth.auth().currentUser != nil {
            showMain()
        } else {
            showLogin()
        }
        
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            if user != nil { self.showMain() } else { self.showLogin() }
        }
        
        window.makeKeyAndVisible()
    }
    
    private func showLogin() {
        let vc = LoginViewController()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
    }
    
    private func showMain() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showLogin()
            return
        }
        let repo = ConversationRepositoryFB()
        let vm   = ConversationsViewModel(repo: repo, userId: uid)
        
        let vc   = ConversationsViewController(viewModel: vm)
        let nav  = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) }

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

