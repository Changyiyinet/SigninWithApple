//
//  Requester.swift
//  SigninWithApple
//
//  Created by Adhitya Surya Pratama on 30/09/19.
//  Copyright © 2019 Adhitya Surya Pratama. All rights reserved.
//

import Foundation

struct Param : Codable {
    let authorizationCode: String?
    let identityToken: String?
}

class Requester {
    func requestToServer(code: Data?, token: Data?, completion: @escaping (Data, URLResponse) -> Void) {
        let url = URL(string: "http://localhost:3000/login")!
        let authCode = String(data: code!, encoding: .utf8)!
        let identityToken = String(data: token!, encoding: .utf8)!
        let requestParam = Param(authorizationCode: authCode, identityToken: identityToken)
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestParam)
        
        URLSession.shared.dataTask(with: request) { data , response ,error in
            guard let data = data, let response = response else { return }
            if let error = error {
                print("error:\(error)")
            } else {
                completion(data, response)
            }
        }.resume()
    }
}
