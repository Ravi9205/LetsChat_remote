//
//  MessageVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class MessageVC: UIViewController {
    
    @IBOutlet weak var tablView:UITableView!
    
    
    private let spinnner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private var loginObserver: NSObjectProtocol?
    
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tablView.register(ConversationTableCell.self, forCellReuseIdentifier:ConversationTableCell.identifier)
        
        view.addSubview(noConversationsLabel)
        
        startListeningForCOnversations()

        
        self.tablView.delegate = self
        self.tablView.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //MARK:- Adding navigation bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTapped))
        
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForCOnversations()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // validateAuth()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
    
    
    
    private func startListeningForCOnversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                guard !conversations.isEmpty else {
                    // self?.tableView.hide = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.noConversationsLabel.isHidden = true
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tablView.reloadData()
                    //self?.tableView.isHidden = false
                }
            case .failure(let error):
                //self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        })
    }
    
    @objc private func rightBarButtonTapped(){
        
        let vc = NewConversessionVC()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.present(vc, animated: true)
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
        
    }
    
    
    private func createNewConversation(result:SearchResult){
        
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        
        // check in datbase if conversation with these two users exists
        // if it does, reuse conversation id
        // otherwise use existing code
        
        DatabaseManager.shared.conversationExists(iwth: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
}

extension MessageVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier:ConversationTableCell.identifier, for: indexPath) as! ConversationTableCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let chat = ChatViewController(with:model.otherUserEmail,id:model.id)
        chat.title = model.name
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.pushViewController(chat, animated: true)
        // Show Chat Messages
    }
}
