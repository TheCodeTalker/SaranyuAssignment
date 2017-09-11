//
//  APIService.swift
//  SaranyuAssignment
//
//  Created by Chitaranjan Sahu on 11/09/17.
//  Copyright © 2017 me.chitaranjan.in. All rights reserved.
//
import Foundation
import UIKit

class APIService: NSObject {
    
    let latitude = "12.9"
    let longitude = "77.5"
    lazy var endPoint: String = {
        return "http://api.openweathermap.org/data/2.5/find?lat=\(self.latitude)&lon=\(self.longitude)&cnt=5&appid=d32091b3739b5fd38c00f4b681ca4004"
    }()
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        let urlString = endPoint
        
        guard let url = URL(string: urlString) else { return completion(.Error("Invalid URL, we can't update your feed")) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else { return completion(.Error(error!.localizedDescription)) }
            guard let data = data else { return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let itemsJsonArray = json["list"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(itemsJsonArray))
                    }
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
            }.resume()
    }
}

enum Result<T> {
    case Success(T)
    case Error(String)
}
