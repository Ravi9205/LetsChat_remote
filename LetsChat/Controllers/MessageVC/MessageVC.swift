//
//  MessageVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import UIKit

class MessageVC: UIViewController {
    
    @IBOutlet weak var tablView:UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tablView.delegate = self
        self.tablView.dataSource = self
        self.tablView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.string(forKey: "loggedIn")
        
        if (isLoggedIn == nil) {
            let login = LoginVC()
            let nav = UINavigationController(rootViewController: login)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        else
        {
            let message = MessageVC()
            let nav = UINavigationController(rootViewController: message)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

extension MessageVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Jhone Smith"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat = ChatViewController()
        chat.title = "Chat"
        self.navigationController?.pushViewController(chat, animated: true)
        // Show Chat Messages
    }
    
    
    
    
    
    
}
