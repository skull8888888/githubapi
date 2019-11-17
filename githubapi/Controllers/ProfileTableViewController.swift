//
//  ProfileTableViewController.swift
//  githubapi
//
//  Created by Robert Kim on 17/11/2019.
//  Copyright © 2019 Robert Kim. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var loginButton: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var publicReposCountLabel: UILabel!
    @IBOutlet weak var privateReposCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    
    lazy var messageLabel: UILabel! = {
        let messageLabel = UILabel(frame: self.tableView.frame)
        messageLabel.text = Constants.message
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.sizeToFit()
        
        return messageLabel
    }()
    
    private enum Constants {
        static let cellIdentifier = "Cell"
        static let title = "Profile"
        static let cellHeight: CGFloat = 44
        static let mainCellHeight: CGFloat = 80
        static let message = "Please log in to GitHub"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = Constants.title
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
        
        
        if Model.Login.isLoggedIn() {
            
            Model.shared.getAuthUser { user in
                self.updateInfo(for: user)
            }
            
        } else {
            hideInfo()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Model.Login.isLoggedIn() ? 4 : 0
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        Model.Login.showLoginPage(from: self) {
            Model.shared.getAuthUser { user in
  
                self.updateInfo(for: user)
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
        let secItemClasses =  [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
        
        hideInfo()
        
    }
        
}

extension ProfileTableViewController {
    
    func hideInfo(){
        loginButton.isEnabled = true
        loginButton.title = "Login"
        
        tableView.backgroundView = messageLabel;
        
        UserDefaults.standard.removeObject(forKey: "token")
        
        tableView.reloadData()
    }
    
    func updateInfo(for user: User){
        
        tableView.backgroundView = nil
        
        loginButton.isEnabled = false
        loginButton.title = ""
        
        avatarImageView.kf.setImage(with: URL(string: user.avatarUrl))
        loginLabel.text = user.login
        
        followersCountLabel.text = "\(user.followers)"
        followingCountLabel.text = "\(user.following)"
        privateReposCountLabel.text = "\(user.privateRepos)"
        publicReposCountLabel.text = "\(user.publicRepos)"
        
    }
    
}


extension ProfileTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && Model.Login.isLoggedIn() {
            return Constants.mainCellHeight
        } else {
            return Constants.cellHeight
        }
        
    }
    
}
