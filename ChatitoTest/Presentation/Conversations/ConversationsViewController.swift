//
//  ConversationsViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit
import FirebaseAuth

final class ConversationsViewController: UIViewController, UITableViewDelegate {
    
    private let viewModel: ConversationsViewModel
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Int, ConversationsViewModel.Row>!
    private var currentRows: [ConversationsViewModel.Row] = []
    
    init(viewModel: ConversationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNav()
        view.backgroundColor = .systemBackground
        buildTable()
        bind()
        viewModel.start()
    }
    
    func configNav() {
        title = "Conversaciones"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Salir",
            style: .plain,
            target: self,
            action: #selector(onLogout)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(onNewConversation)
        )
    }
    
    private func buildTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        dataSource = UITableViewDiffableDataSource<Int, ConversationsViewModel.Row>(tableView: tableView) {
            tableView, indexPath, row in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var conf = cell.defaultContentConfiguration()
            conf.text = row.title
            conf.secondaryText = [row.subtitle, row.time].filter { !$0.isEmpty }.joined(separator: " · ")
            conf.secondaryTextProperties.color = .secondaryLabel
            cell.contentConfiguration = conf
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        tableView.delegate = self
    }
    
    private func bind() {
        viewModel.onUpdate = { [weak self] rows in
            guard let self else { return }
            self.currentRows = rows
            var snap = NSDiffableDataSourceSnapshot<Int, ConversationsViewModel.Row>()
            snap.appendSections([0])
            snap.appendItems(rows)
            self.dataSource.apply(snap, animatingDifferences: true)
        }
    }
    
    @objc private func onNewConversation() {
        Task {
            do {
                guard let myUid = Auth.auth().currentUser?.uid else { return }
                let members = [myUid]
                _ = try await viewModel.createConversation(memberIds: members, title: "Nuevo chat de prueba")
            }
        }
    }
    
    @objc private func onLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(" Error al cerrar sesión:", error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let id = viewModel.conversationId(at: indexPath.row, in: currentRows)
        let repo = MessageRepositoryFB()
        let chatVM = ChatViewModel(repo: repo, conversationId: id)
        let chatVC = ChatViewController(viewModel: chatVM)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
