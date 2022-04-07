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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tablView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")

        self.tablView.delegate = self
        self.tablView.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated: true)

        //MARK:- Adding navigation bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTapped))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // validateAuth()

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
        
        let chat = ChatViewController()
        chat.title = "Chat"
        self.navigationController?.pushViewController(chat, animated: true)
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
