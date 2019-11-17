//
//  Model.swift
//  githubapi
//
//  Created by Robert Kim on 17/11/2019.
//  Copyright © 2019 Robert Kim. All rights reserved.
//

import Alamofire
import SwiftyJSON
import OAuthSwift

class Model {
    
    private enum Constants {
        static let base = "https://api.github.com"
        static let tokenKey = "token"
        
        static let consumerKey =    "c6592a3df446267b2020"
        static let consumerSecret = "6b5cef440b9fa637af3c940c3a5d96fadff143e4"
        static let authorizeUrl =   "https://github.com/login/oauth/authorize"
        static let accessTokenUrl = "https://github.com/login/oauth/access_token"
        static let responseType =   "code"
        
        static let callbackURL = "githubapi://oauth-callback/github"
        
    }
    
    static let shared = Model()
    
    lazy var decoder = JSONDecoder()
        
    var totalCount = 0;
    
    func searchRepos(with q: String, page: Int, completion: @escaping ([Repo]) -> ()) {
    
        let link = "/search/repositories"
        let params: Parameters = [
            "q": q,
            "page": page
        ]
        
        AF.request(Constants.base + link, method: .get, parameters: params).responseJSON { res in
                      
            guard let data = res.data else { return }
                          
            let json = JSON(data)
            var repos: [Repo] = []
            
            let githubmax = 1000;
            self.totalCount = min(json["total_count"].intValue, githubmax);
            
            for repoJSON in json["items"].arrayValue {
                              
                if let repo = self.decode(from: repoJSON, type: Repo.self) {
                    repos.append(repo)
                }
                              
            }
                        
            completion(repos)
                          
        }
                
    }

    func getAuthUser(_ completion: @escaping (User) -> ()){
        
        guard let token = UserDefaults.standard.value(forKey: Constants.tokenKey) as? String else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "token \(token)"
        ]
        
        AF.request(Constants.base + "/user", method: .get, headers: headers).responseJSON { res in
            
            guard let data = res.data else { return }
                                     
            let json = JSON(data)
            if let user = self.decode(from: json, type: User.self) {
                completion(user)
            }
        }
    }
    
    private func decode<T: Decodable>(from json: JSON, type: T.Type) -> T? {
        
        do {
            let data = try json.rawData()
            let repo = try decoder.decode(T.self, from: data)
            
            return repo
            
        } catch {
            print(error)
        }
        
        return nil
    }
        
}


extension Model {
    
    enum Login {
        
        // required by the OAtuhSwift
        static var oauthswift: OAuth2Swift!
        
        static func showLoginPage(from viewController: UIViewController, completion: @escaping () -> ()){
           
            oauthswift = OAuth2Swift(
                consumerKey:    Constants.consumerKey,
                consumerSecret: Constants.consumerSecret,
                authorizeUrl:   Constants.authorizeUrl,
                accessTokenUrl: Constants.accessTokenUrl,
                responseType:   Constants.responseType
            )

                  
            oauthswift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthswift)
                      
            let state = generateState(withLength: 20)
            
            guard let callbackURL = URL(string: Constants.callbackURL) else { return }
                  
            oauthswift.authorize(withCallbackURL: callbackURL, scope: "user", state: state) { result in
                switch result {
                case .success(let res, _, _):
                    UserDefaults.standard.set(res.oauthToken, forKey: Constants.tokenKey)
                    completion()
                case .failure(let error):
                    print(error.description)
                }
                
            }
                          
        }
        
        static func isLoggedIn() -> Bool {
            return UserDefaults.standard.value(forKey: Constants.tokenKey) != nil
        }
    
        static func removeToken() {
            UserDefaults.standard.removeObject(forKey: Constants.tokenKey)
        }
        
    }
    
}
