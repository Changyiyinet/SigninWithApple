//
//  HomeViewController.swift
//  SigninWithApple
//
//  Created by Adhitya Surya Pratama on 03/10/19.
//  Copyright © 2019 Adhitya Surya Pratama. All rights reserved.
//

import UIKit
import AuthenticationServices

class HomeViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var credentialRevokedNotification: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCredentialRevokedNotification()
    }
    @IBAction func logoutTapped(_ sender: Any) {
        signOut()
    }
    
    private func setupCredentialRevokedNotification() {
        let name = ASAuthorizationAppleIDProvider.credentialRevokedNotification
        credentialRevokedNotification =
            NotificationCenter.default
                .addObserver(forName: name, object: nil, queue: nil) { [weak self] (notification) in
                    print("revoked: \(notification)")
                    self?.signOut()
        }
    }
    
    private func signOut() {
        KeychainManager.removeAllUserCredential()
        presentLoginScreen()
    }
    
    private func presentLoginScreen() {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let viewController =
                storyboard.instantiateViewController(
                    withIdentifier: "LoginScreen") as? LoginViewController else { return }
            self?.view.window?.rootViewController = viewController
        }
    }
}
