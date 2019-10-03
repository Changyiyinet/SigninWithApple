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

    struct LoginResponse: Codable {
        let authorizationCode: String?
        let token: String?
    }

    @IBOutlet weak var buttonContainer: UIStackView!
    let requester = Requester()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appleButton = createAppleButton()
        buttonContainer.addArrangedSubview(appleButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
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
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print(">> error \(error)")
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            printCredential(appleCredential)
            requestToServer(code: appleCredential.authorizationCode,
                            token: appleCredential.identityToken)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            let username = passwordCredential.user
            let password = passwordCredential.password
            print("==From Keychain==")
            print("username: \(username)\n password: \(password)")
        }
    }
    
    private func requestToServer(code: Data?, token: Data?) {
        requester.requestToServer(code: code, token: token) { (data, response) in
            print(String(data: data, encoding: .utf8))
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController {
    
    private func printCredential(_ appleCredential: ASAuthorizationAppleIDCredential) {
        print("authorization code: \(String(data:appleCredential.authorizationCode!, encoding: .utf8))")
        print("user: " + appleCredential.user)
        print("state: \(appleCredential.state)")
        print("authorizedScopes: \(appleCredential.authorizedScopes)")
        print("identityToken( JWT ): \(String(data:appleCredential.identityToken!, encoding: .utf8))")
        print("email: \(appleCredential.email)")
        print("fullName: \(appleCredential.fullName)")
        print("realUserStatus: \(appleCredential.realUserStatus)")
    }
}
