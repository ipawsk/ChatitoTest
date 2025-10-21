//
//  RegisterViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit

final class RegisterViewController: UIViewController {
    private let vm = RegisterViewModel()
    
    private lazy var nameTF: UITextField = {
        let name = UITextField()
        name.placeholder = "Nombre"
        name.borderStyle = .roundedRect
        name.addTarget(self, action: #selector(onChange), for: .editingChanged)
        return name
    }()
    
    private lazy var emailTF: UITextField = {
        let email = UITextField()
        email.placeholder = "Correo"
        email.autocapitalizationType = .none
        email.keyboardType = .emailAddress
        email.borderStyle = .roundedRect
        email.addTarget(self, action: #selector(onChange), for: .editingChanged)
        return email
    }()
    
    private lazy var passwordTF: UITextField = {
        let password = UITextField()
        password.placeholder = "Contraseña (min 6)"
        password.isSecureTextEntry = true
        password.borderStyle = .roundedRect
        password.addTarget(self, action: #selector(onChange), for: .editingChanged)
        return password
    }()
    
    private lazy var registerButton: UIButton = {
        let registerBtn =  UIButton()
        registerBtn.configuration = .filled()
        registerBtn.setTitle("Crear cuenta", for: .normal)
        registerBtn.addTarget(self, action: #selector(onRegister), for: .touchUpInside)
        return registerBtn
    }()
    
    private let spinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crear cuenta"
        view.backgroundColor = .systemBackground
        setupUI()
        bind()
    }

    private func setupUI() {
        spinner.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [nameTF, emailTF, passwordTF, registerButton, spinner])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameTF.heightAnchor.constraint(equalToConstant: 44),
            emailTF.heightAnchor.constraint(equalToConstant: 44),
            passwordTF.heightAnchor.constraint(equalToConstant: 44),
            registerButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func bind() {
        vm.onLoading = { [weak self] loading in
            DispatchQueue.main.async {
                loading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
                self?.registerButton.isEnabled = !loading
            }
        }
        vm.onError = { [weak self] msg in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        vm.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    @objc private func onChange() {
        vm.displayName = nameTF.text ?? ""
        vm.email = emailTF.text ?? ""
        vm.password = passwordTF.text ?? ""
    }

    @objc private func onRegister() {
        view.endEditing(true)
        vm.register()
    }
}
