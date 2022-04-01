//
//  ProfileVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 01/04/22.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var tableView:UITableView!
    
    var  arrData : [String] = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        
    }
    
    
    
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        cell.textLabel?.text = arrData[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title:"Log Out", message:"Are you sure wants to Log Out", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let login = strongSelf.storyboard?.instantiateViewController(withIdentifier:"LoginVC")
                let nav = UINavigationController(rootViewController: login!)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
                
                
                
            } catch  {
                print("Error while singing Out ")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title:"Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
}
