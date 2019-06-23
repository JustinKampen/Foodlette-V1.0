//
//  YelpClient.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import Foundation

class YelpClient {
    
    // -------------------------------------------------------------------------
    // MARK: - API Properties
    
    static let clientId = "BZCpr2PAxWVNDVmgblzY8w"
    static let apiKey = "qIoNXdamWH33zF0trJMPnntEFwdFM55gXnE8ArwUf2xwJmtMxqAM5trJ4IWn1Wlcz6G3tcBeqo5ZdwdMSXqI2a_n_YghdmuERFZBqIer05L0cWFgKKzbhC0mHEGuXHYx"
    
    enum Endpoints {
        static let base = "https://api.yelp.com/v3/businesses/"
        
        case getBusinessDataFor(String, String, String)
        
        var stringValue: String {
            switch self {
            case .getBusinessDataFor(let categories, let latitude, let longitude):
                return Endpoints.base + "search?categories=\(categories)&latitude=\(latitude)&longitude=\(longitude)&limit=50"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - API Function Calls
    
    class func getBusinessDataFor(categories: String, latitude: String, longitude: String, completion: @escaping ([Business]?, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.getBusinessDataFor(categories, latitude, longitude).url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let businessData = try decoder.decode(YelpResponse.self, from: data)
                completion(businessData.businesses, nil)
            } catch {
                completion(nil, error)
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
