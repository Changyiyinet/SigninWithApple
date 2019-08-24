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
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print(">> error \(error)")
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        print(">> compelete \(authorization)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
