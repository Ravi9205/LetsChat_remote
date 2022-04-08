//
//  NewConversessionVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 05/04/22.
//

import UIKit
import JGProgressHUD
import SwiftUI

class NewConversessionVC: UIViewController {
    
    
    public var completion:(([String:String])->(Void))?
    
    private var spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String:String]]()
    private var results = [[String:String]]()
    private var isUserFetched = false
    private var  searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users....."
        return searchBar
    }()
    
    private var tableView:UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
        return table
    }()
    
    private var noDataLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No User Found"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noDataLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel", style: .done, target: self, action: #selector(didCancelTapped))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noDataLabel.frame = CGRect(x: view.width/4,
                                   y: (view.height-200)/2,
                                   width: view.width/2,
                                   height: 200)
        
    }
    
    @objc private func didCancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewConversessionVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text , !text.isEmpty, !text.replacingOccurrences(of:" ", with:"").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            results.removeAll()
            updateUI()
        }
    }
    
    
    
    func searchUsers(query:String){
        // Check Array has firebase results
        if isUserFetched {
            filterUsers(with: query)
        }
        else {
            DatabaseManager.shared.fetchAllUsers {[weak self] result in
                
                switch result {
                case.success(let userCollection):
                    self?.isUserFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case.failure(let error):
                    print("Error occuered while fetching users list\(error)")
                }
            }
        }
        
    }
    
    func filterUsers(with terms:String){
        guard isUserFetched else {
            return
        }
        self.spinner.dismiss()
        
        let results:[[String:String]] = self.users.filter({
            guard let name =   $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(terms.lowercased())
        })
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty {
            self.noDataLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noDataLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
            
        }
    }
    
}

// MARK:- TableView Delegate and data Source

extension NewConversessionVC:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userData = results[indexPath.row]
        self.dismiss(animated: true) {[weak self] in
            self?.completion?(userData)
        }
        
    }
    
}
