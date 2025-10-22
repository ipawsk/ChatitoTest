//
//  LoginViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit

final class LoginViewController: UIViewController {
    private let viewModel = LoginViewModel()
    
    private lazy var emailTF: UITextField = {
        let email = UITextField()
        email.placeholder = "Email"
        email.autocapitalizationType = .none
        email.keyboardType = .emailAddress
        email.borderStyle = .roundedRect
        email.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return email
    }()
    
    private lazy var passwordTF: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.isSecureTextEntry = true
        password.borderStyle = .roundedRect
        password.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return password
    }()
    
    private lazy var loginButton: UIButton = {
        let loginBtn =  UIButton()
        loginBtn.configuration = .filled()
        loginBtn.setTitle("Sign In", for: .normal)
        loginBtn.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        return loginBtn
    }()
    
    private lazy var signUpButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Sign Up", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        b.addTarget(self, action: #selector(onSignUp),
                    for: .touchUpInside)
        return b
    }()
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupUI() {
        spinner.hidesWhenStopped = true
        
        let stack = UIStackView(arrangedSubviews: [emailTF, passwordTF, loginButton, signUpButton, spinner])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emailTF.heightAnchor.constraint(equalToConstant: 44),
            passwordTF.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onLoading = { [weak self] loading in
            DispatchQueue.main.async {
                loading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
                self?.loginButton.isEnabled = !loading
                self?.signUpButton.isEnabled = !loading
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Logged.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func textChanged() {
        viewModel.email = emailTF.text ?? ""
        viewModel.password = passwordTF.text ?? ""
    }
    
    @objc private func onLogin() {
        view.endEditing(true)
        viewModel.login()
    }
    
    @objc private func onSignUp() {                                      navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

