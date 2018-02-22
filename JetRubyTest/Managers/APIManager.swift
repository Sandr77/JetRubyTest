//
//  APIManager.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 20/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit


class APIManager: NSObject {
    
    private static let shared: APIManager = {
        let instance = APIManager()
        return instance
    }()
    
    private func createRequest(api: String,  method: String, params: [String: String]?) -> URLRequest {
        return createRequest(url: API_URL + api, method: method, params: params)
    }
    
    private func createRequest(url: String,  method: String, params: [String: String]?) -> URLRequest {
        
        var paramString = ""
        if(params != nil) {
            for key in params!.keys {
                paramString += "&" + key + "=" + params![key]!
            }
          }
        paramString += "&" + "access_token=" + ACCESS_TOKEN
        let urlString = method == "GET" ? url + "?" + paramString : url
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        
        if(method == "POST" && paramString.count > 0) {
            request.httpBody = paramString.data(using: .utf8)
        }
       
        return request
    }
    
    private func sendDataRequest(request: URLRequest, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data)
        }
        task.resume()
    }
    
    private func sendRequest(request: URLRequest, completion: @escaping (Any) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var errorMessage = "Network error"

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(errorMessage);

                }
                  return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    if let m = dict?["message"] {
                        errorMessage = m as! String
                    }
                }
                catch {
                    
                }
                DispatchQueue.main.async {
                    completion(errorMessage)
                }
                return
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]]
                DispatchQueue.main.async {
                    completion(dict as Any)
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(errorMessage)
                }
            }
         }
        task.resume()
    }
    
    class func loadImageFrom(ref: String, completion: @escaping (Data?) -> Void) {
        let request = shared.createRequest(url: ref, method: "GET", params: nil)
        shared.sendDataRequest(request: request, completion: {data in
            completion(data)
        })
    }
    
    class func loadShots(page: Int, completion: @escaping (Any) -> Void) {
        let request = shared.createRequest(api: "shots", method: "GET", params: ["page":String(page)])
        shared.sendRequest(request: request, completion: {result in
            completion(result)
        })
    }
    
    
    
    
    
    
}
