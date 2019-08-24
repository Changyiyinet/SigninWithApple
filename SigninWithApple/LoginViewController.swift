//
//  LoginViewController.swift
//  SigninWithApple
//
//  Created by Adhitya Surya Pratama on 24/08/19.
//  Copyright © 2019 Adhitya Surya Pratama. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var buttonContainer: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let appleButton = createAppleButton()
        buttonContainer.addArrangedSubview(appleButton)
    }
    
    private func createAppleButton() -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(appleSigninButtonTapped),
                         for: .touchUpInside)
        button.frame(forAlignmentRect: buttonContainer.frame)
        return button
    }
    
    @objc
    private func appleSigninButtonTapped() {
    }
}
