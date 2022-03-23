//
//  ViewController.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 22/03/22.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tablView:UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tablView.delegate = self
        tablView.dataSource = self
    }


}

