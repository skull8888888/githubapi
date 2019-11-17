//
//  TableViewController.swift
//  githubapi
//
//  Created by Robert Kim on 17/11/2019.
//  Copyright © 2019 Robert Kim. All rights reserved.
//

import UIKit
import Kingfisher

class TableViewController: UITableViewController {

    private enum Constants {
        static let cellIdentifier = "Cell"
        static let title = "Repo search"
        static let cellSpacing: CGFloat = 10.0
    }
    
    var repos: [Repo] = []
    var loadedPages: Int = 1
    var q: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = Constants.title
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Repos"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
        
        let ai = UIActivityIndicatorView()
        tableView.tableFooterView = ai
        
    }
    
}

// MARK: - Table view data source
extension TableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return repos.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! RepoTableViewCell
           
        let repo = repos[indexPath.section]

        let url = URL(string: repo.owner.avatarUrl)

        cell.avatarImageView.image = nil
        cell.avatarImageView.kf.setImage(with: url)

        cell.descriptionLabel.text = repo.description
        cell.nameLabel.text = repo.name
           
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.cellSpacing
    }
    
}

extension TableViewController {
        
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == self.repos.count - 1 {
            
            guard self.repos.count <= Model.shared.totalCount else { return }
            
            self.loadedPages += 1
            
            Model.shared.searchRepos(with: q, page: loadedPages) { (newRepos) in
                
                self.repos += newRepos
                
                self.tableView.reloadData()
                
            }
        }
    }
    
}


extension TableViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let q = searchBar.text else { return }
        
        loadedPages = 1
        self.q = q
        
        Model.shared.searchRepos(with: q, page: loadedPages) { (repos) in
            self.repos = repos
            self.tableView.reloadData()
        }
    }
    
    
}
