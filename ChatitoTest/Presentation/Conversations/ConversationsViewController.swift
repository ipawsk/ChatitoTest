//
//  ConversationsViewController.swift
//  ChatitoTest
//
//  Created by iPaw on 21/10/25.
//

import UIKit
import FirebaseAuth

final class ConversationsViewController: UIViewController {
    
    private let viewModel: ConversationsViewModel
    private let tableView = UITableView()
    private var dataSource: UITableViewDiffableDataSource<Int, ConversationsViewModel.Row>!
    private var currentRows: [ConversationsViewModel.Row] = []
    
    var countChat = 0
    
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
        title = "Conversations"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(onNewConversation)
        )
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                style: .plain,
                target: self,
                action: #selector(onLogout)
            ),
            
            UIBarButtonItem(
                image: UIImage(systemName: "person.circle"),
                style: .plain,
                target: self,
                action: #selector(onProfile)
            )
        ]
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
                countChat += 1
                _ = try await viewModel.createConversation(memberIds: members, title: "New chat \(countChat)")
            }
        }
    }
    
    @objc private func onLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Log out failed:", error.localizedDescription)
        }
    }
    
    @objc private func onProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let repo = UserRepositoryFirebase()
        let vm = ProfileViewModel(repo: repo, uid: uid)
        let vc = ProfileViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ConversationsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let id = viewModel.conversationId(at: indexPath.row, in: currentRows)
        let repo = MessageRepositoryFB()
        let chatVM = ChatViewModel(repo: repo, conversationId: id)
        let chatVC = ChatViewController(viewModel: chatVM)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
