//
//  PerfilViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let viewModel: ProfileViewModel
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 48
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(onChangePhoto))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    
    lazy var nameLbl: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var usernameTF : UITextField = {
        let name = UITextField()
        name.placeholder = "username"
        name.borderStyle = .roundedRect
        name.translatesAutoresizingMaskIntoConstraints = false
        name.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return name
    }()
    
    private let emailLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .secondaryLabel
        lbl.font = .systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 1
        return lbl
    }()
    
    lazy var saveButton : UIButton = {
        let saveBtn = UIButton()
        saveBtn.configuration = .filled()
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        return saveBtn
    }()
    
    
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Perfil"
        view.backgroundColor = .systemBackground
        buildUI()
        bind()
        viewModel.load()
    }
    
    private func buildUI() {
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(userImage)
        view.addSubview(nameLbl)
        view.addSubview(usernameTF)
        view.addSubview(emailLbl)
        view.addSubview(saveButton)
        view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            userImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            userImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImage.widthAnchor.constraint(equalToConstant: 96),
            userImage.heightAnchor.constraint(equalToConstant: 96),
            
            nameLbl.topAnchor.constraint(equalTo: userImage.bottomAnchor, constant: 12),
            nameLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            usernameTF.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 16),
            usernameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            usernameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            usernameTF.heightAnchor.constraint(equalToConstant: 44),
            
            emailLbl.topAnchor.constraint(equalTo: usernameTF.bottomAnchor, constant: 8),
            emailLbl.leadingAnchor.constraint(equalTo: usernameTF.leadingAnchor),
            emailLbl.trailingAnchor.constraint(equalTo: usernameTF.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: emailLbl.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: usernameTF.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: usernameTF.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            
            spinner.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func bind() {
        viewModel.onLoading = { [weak self] loading in
            DispatchQueue.main.async {
                loading ? self?.spinner.startAnimating() : self?.spinner.stopAnimating()
                self?.saveButton.isEnabled = !loading
            }
        }
        viewModel.onError = { [weak self] msg in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.onProfile = { [weak self] p in
            DispatchQueue.main.async {
                guard let self else { return }
                self.nameLbl.text = p.displayName
                self.usernameTF.text = p.username
                self.emailLbl.text = p.email
                
                if let url = p.photoURL {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data else { return }
                        DispatchQueue.main.async { self.userImage.image = UIImage(data: data) }
                    }.resume()
                } else {
                    self.userImage.image = UIImage(systemName: "person.crop.circle")
                }
            }
        }
        
        viewModel.onSaved = { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func textChanged() {
        viewModel.username = usernameTF.text ?? ""
    }
    
    @objc private func onChangePhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func onSave() {
        view.endEditing(true)
        viewModel.save()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage,
           let data = img.jpegData(compressionQuality: 0.85) {
            userImage.image = img
            viewModel.photoData = data
        }
    }
}
