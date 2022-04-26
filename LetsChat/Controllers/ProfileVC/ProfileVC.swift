//
//  ProfileVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 01/04/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SwiftUI

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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        
        guard let email = UserDefaults.standard.value(forKey:"email") as? String else{
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture_png"
        let path = "images/" + fileName
        print(path)
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150.0, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(path: path) {[weak self] result in
            switch result {
            case .success(let url):
                self?.downLoadImage(imageView: imageView, url: url)
            case.failure(let error):
                print("Failed to get download URL====\(error.localizedDescription)")
            }
        }
        
        return headerView
        
    }
    
    func downLoadImage(imageView:UIImageView, url:URL)
    {
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data , error == nil else {
                if  let error = error {
                    print("Error downloading image from URL\(error.localizedDescription)")
                }
                return
            }
           
            DispatchQueue.main.async {
                let image  =  UIImage(data:data)
                imageView.image = image
                
            }
        }.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title:"Log Out", message:"Are you sure wants to Log Out", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            
            //MARK:- Logout Facebook Session If User Logged via Facebook credentials
            
            FBSDKLoginKit.LoginManager().logOut()
            GIDSignIn.sharedInstance.signOut()
            
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
