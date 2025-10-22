//
//  ChatViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit

final class ChatViewController: UIViewController {
    private let viewModel: ChatViewModel
    private let tableView = UITableView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var rows: [ChatViewModel.Row] = []
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        view.backgroundColor = .systemBackground
        setupUI()
        bind()
        viewModel.start()
    }
    
    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        inputField.placeholder = "Write a message.."
        inputField.borderStyle = .roundedRect
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        let inputStack = UIStackView(arrangedSubviews: [inputField, sendButton])
        inputStack.axis = .horizontal
        inputStack.spacing = 8
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputStack)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputStack.topAnchor, constant: -8),
            
            inputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inputStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            inputField.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        tableView.dataSource = self
    }
    
    private func bind() {
        viewModel.onUpdate = { [weak self] rows in
            guard let self else { return }
            self.rows = rows
            self.tableView.reloadData()
            if !rows.isEmpty {
                let index = IndexPath(row: rows.count - 1, section: 0)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
        viewModel.onError = { [weak self] msg in
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    @objc private func onSend() {
        let text = inputField.text ?? ""
        viewModel.sendMessage(text)
        inputField.text = ""
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = rows[indexPath.row]
        var conf = cell.defaultContentConfiguration()
        
        if !row.isMine, let name = row.username {
            conf.text = "\(name): \(row.text)"
        } else {
            conf.text = "me: \(row.text)"
        }
        
        conf.textProperties.color = row.isMine ? .white : .label
        cell.contentConfiguration = conf
        cell.backgroundColor = row.isMine ? .systemBlue : .secondarySystemBackground
        return cell
    }
    
}
