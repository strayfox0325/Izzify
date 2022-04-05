//
//  AuthManager.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private var refreshingToken=false;
    
    struct Constants{
        static let clientID="850f71e8bdd44a5c8b2386c3021a8b01"
        static let clientSecret="22b311d98ead41d69375a8de010f64d9"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://cubes.edu.rs/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-library-modify%20user-follow-read%20user-library-read%20user-read-email"
        
    }
    
    private init()
    {}
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
        
    }
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken: String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    private var shouldRefreshToken: Bool{
        guard let expirationDate = tokenExpirationDate else{
            return false
        }
        let currentDate=Date()
        return currentDate.addingTimeInterval(300) >= expirationDate //5min
    }
    public func exchangeCodeForToken(
        code: String,
        completition: @escaping ((Bool) -> Void)
    ){
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken=Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get base64")
            completition(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            guard let data = data, error == nil else{
                completition(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self,from: data)
                self?.cacheToken(result: result)
                completition(true)
            }catch{
                print(error.localizedDescription)
                completition(false)
            }
        }
        task.resume()
    }
    
    private func cacheToken(result: AuthResponse)
    {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    private var onRefreshBlocks = [((String)->Void)]()
    
    //Supplies a valid token to be used with API calls
    public func withValidToken(completion: @escaping (String)->Void){
        guard !refreshingToken else{
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            refreshAccessToken {[weak self] success in
                if let token = self?.accessToken{
                    completion(token)
                }
            }
        }else if let token = accessToken{
            completion(token)
            return
        }
    }
    
    public func refreshAccessToken(completion: ((Bool) -> Void)?)
    {
        
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else{
            completion?(true)
            return
        }
        guard let refreshToken=self.refreshToken else {
            return
        }
        
        //Refresh Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        refreshingToken=true;
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken=Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failed to get base64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            self?.refreshingToken=false
            guard let data = data,
                  error == nil else{
                completion?(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self,from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    
    
    public func signOut(completion: (Bool)->Void){
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        completion(true)
    }
}
