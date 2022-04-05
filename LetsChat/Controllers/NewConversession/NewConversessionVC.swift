//
//  NewConversessionVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 05/04/22.
//

import UIKit
import JGProgressHUD

class NewConversessionVC: UIViewController {
    private var spinner = JGProgressHUD()
    
    
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
        
        self.view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel", style: .done, target: self, action: #selector(didCancelTapped))
        searchBar.becomeFirstResponder()
    }
    
    @objc private func didCancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewConversessionVC:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
