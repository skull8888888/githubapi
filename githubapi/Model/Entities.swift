//
//  Entities.swift
//  githubapi
//
//  Created by Robert Kim on 17/11/2019.
//  Copyright © 2019 Robert Kim. All rights reserved.
//

import Foundation

struct Repo: Decodable {
    
    var id: Int
    var name: String
    var description: String?
    
    var owner: Owner
}

struct Owner: Decodable {
    
    var login: String
    var id: Int
    var avatarUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
    }
    
}

struct User: Decodable {
    
    var login: String
    var id: Int
    var avatarUrl: String
    var url: String
    
    var followers: Int
    var following: Int
    
    var publicRepos: Int
    var privateRepos: Int
    
    private enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case url
       
        case followers
        case following
        
        case publicRepos = "public_repos"
        case privateRepos = "total_private_repos"
        
    }
    
    
}
