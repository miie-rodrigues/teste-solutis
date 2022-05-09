//
//  ViewController.swift
//  TesteSolutis
//
//  Created by Virtual Machine on 09/04/22.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var userTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    var loginService = LoginService()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTxt.text = "teste@teste.com.br"
        passwordTxt.text = "abc123@"
    
        loginService.delegate = self
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        // Validação campos do login
        guard let username = userTxt.text else { return }
        guard let password = passwordTxt.text else { return }
        
        SVProgressHUD.show()
        loginService.doLogin(username: username, password: password)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Atenção", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeController" {
            let controller = segue.destination as! HomeViewController
            controller.user = user
        }
    }
}

extension LoginViewController: LoginServiceDelegate {
    func loginSuccess(user: User) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.user = user
            self.performSegue(withIdentifier: "homeController", sender: self)
        }
    }
    
    func loginError(message: String) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.showAlert(message: message)
        }
    }
}

