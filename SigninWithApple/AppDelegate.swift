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
        appleIDProvider.getCredentialState(forUserID: "currentUserFromKeychain") { (credentialState, error) in
            switch credentialState {
            case .authorized: break
            case .revoked: break
            case .notFound:
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: .main)
                    guard let viewController =
                        storyboard.instantiateViewController(
                            withIdentifier: "LoginViewController") as? LoginViewController else { return }
                    UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
}
