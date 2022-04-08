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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tablView.register(ConversationTableCell.self, forCellReuseIdentifier:ConversationTableCell.identifier)
        
        self.tablView.delegate = self
        self.tablView.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //MARK:- Adding navigation bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTapped))
        startListeningForConversations()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // validateAuth()
        
    }
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey:"email")as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result  in
            
            switch result {
                case .success( let conversations):
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tablView.reloadData()
                }
            case .failure(let error):
                print("Failed to get the resposnse ===\(error)")
            }
        }
    }
    
    @objc private func rightBarButtonTapped(){
        let vc = NewConversessionVC()
        let nav = UINavigationController(rootViewController: vc)
        vc.title = "New Conversession"
        vc.completion = {[weak self] result in
            print(result)
            self?.createNewConversation(result: result)
        }
        self.present(nav, animated: false, completion: nil)
    }
    
    
    private func createNewConversation(result:[String:String]){
        
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let chat = ChatViewController(with: email)
        chat.isNewConversation = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        chat.title = name
        self.navigationController?.pushViewController(chat, animated: true)
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

        let chat = ChatViewController(with:model.otherUserEmail)
        chat.title = model.name
        self.navigationController?.pushViewController(chat, animated: true)
        // Show Chat Messages
    }
}
