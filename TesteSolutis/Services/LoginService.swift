//
//  LoginManager.swift
//  TesteSolutis
//
//  Created by Virtual Machine on 12/04/22.
//

import Foundation

protocol LoginServiceDelegate {
    func loginSuccess(user: User)
    func loginError(message: String)
}

class LoginService {
    
    var delegate: LoginServiceDelegate?
    
    let apiUrl = "https://api.mobile.test.solutis.xyz/";
    
    func doLogin(username: String, password: String) {
        let url = apiUrl + "login"
        let login = Login(username: username, password: password)
        
        performRequest(url: url, login: login)
    }
    
    func performRequest(url: String, login: Login) {
        if let url = URL(string: url) {
            do {
                let session = URLSession(configuration: .default)
                var request = URLRequest(url: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = try JSONEncoder().encode(login)
                
                let task = session.dataTask(with: request) { data, response, error in
                    if error != nil {
                        self.delegate?.loginError(message: "Usuário ou senha inválido")
                        return
                    }
                    
                    if (response as! HTTPURLResponse).statusCode > 299 {
                        self.delegate?.loginError(message: "Usuário ou senha inválido")
                        return
                    }
                    
                    if let safeData = data {
                        if let user = self.parseJson(safeData) {
                            self.delegate?.loginSuccess(user: user)
                        }
                    }
                }
                
                task.resume()
            } catch {
                delegate?.loginError(message: error.localizedDescription)
            }
        }
    }
    
    func parseJson(_ data: Data) -> User? {
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            delegate?.loginError(message: error.localizedDescription)
            return nil
        }
    }
}
