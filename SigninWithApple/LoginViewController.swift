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
    
    private let requester = Requester()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonContainer.addArrangedSubview(createAppleButton())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
    }
    
    private func createAppleButton() -> ASAuthorizationAppleIDButton {
        let isDarkTheme = view.traitCollection.userInterfaceStyle == .dark
        let style: ASAuthorizationAppleIDButton.Style = isDarkTheme ? .white : .black
        let type = buttonType()
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.addTarget(self, action: #selector(appleSigninButtonTapped), for: .touchUpInside)
        button.frame(forAlignmentRect: buttonContainer.frame)
        
        return button
    }
    
    private func buttonType() -> ASAuthorizationAppleIDButton.ButtonType {
        guard let isLoggedIn = KeychainManager.currentUserIdentifier else { return .signIn }
        return isLoggedIn.isEmpty ? .signIn : .continue
    }
    
    @objc
    private func appleSigninButtonTapped() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        performAuthorization(requests: [request])
    }
    
    func performExistingAccountSetupFlows() {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        performAuthorization(requests: requests)
    }
    
    private func performAuthorization(requests: [ASAuthorizationRequest]) {
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
            handleAppleCredential(appleCredential)
//            requestToServer(code: appleCredential.authorizationCode,
//                            token: appleCredential.identityToken)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            handlePasswordCredential(passwordCredential)
        }
    }
    
    private func handleAppleCredential(_ appleCredential: ASAuthorizationAppleIDCredential) {
        saveToKeychain(appleCredential)
        openHome()
        printCredential(appleCredential)
    }
    
    private func handlePasswordCredential(_ credential: ASPasswordCredential) {
        let username = credential.user
        let password = credential.password
        print("== From Keychain ==")
        print("username: \(username)\n password: \(password)")
    }
    
    private func openHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "HomeScreen") as? HomeViewController else { return }
        view.window?.rootViewController = viewController
    }
    
    private func saveToKeychain(_ authCredential: ASAuthorizationAppleIDCredential) {
        KeychainManager.currentUserIdentifier = authCredential.user
        KeychainManager.currentUserEmail = authCredential.email
        KeychainManager.currentUserFirstName = authCredential.fullName?.givenName
        KeychainManager.currentUserLastName = authCredential.fullName?.familyName
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
        print("===== Credential From Apple ====")
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
