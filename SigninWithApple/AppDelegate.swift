//
//  AppDelegate.swift
//  SigninWithApple
//
//  Created by Adhitya Surya Pratama on 24/08/19.
//  Copyright © 2019 Adhitya Surya Pratama. All rights reserved.
//

import UIKit
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkUserCredentialState()
        return true
    }
    
    private func checkUserCredentialState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainManager.currentUserIdentifier ?? "") { [weak self] (credentialState, error) in
            print(KeychainManager.currentUserIdentifier)
            if let error = error { print("##" + error.localizedDescription) }
            else {
                self?.handleCredentialState(credentialState)
            }
        }
    }
    
    private func handleCredentialState(_ credentialState: ASAuthorizationAppleIDProvider.CredentialState) {
        switch credentialState {
        case .authorized: openHome()
        case .revoked, .notFound: openLogin()
        default:break
        }
    }

    private func openLogin() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let viewController =
                storyboard.instantiateViewController(
                    withIdentifier: "LoginScreen") as? LoginViewController else { return }
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
    
    private func openHome() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let viewController =
                storyboard.instantiateViewController(
                    withIdentifier: "HomeScreen") as? HomeViewController else { return }
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
    }
}
