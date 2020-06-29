//
//  NetworkService.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class NetworkService {
    
    private let host = "https://api.openweathermap.org"
    
    static let session: Session = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        let session = Session(configuration: config)
        return session
    }()
    
    func weatherPromise(for city: String) -> Promise<Weather>  {
        let path = "/data/2.5/weather"
        let parameters: Parameters = [
            "q": city,
            "units": "metric",
            "appId": "8b32f5f2dc7dbd5254ac73d984baf306"
        ]
        
        return Promise { resolver in
            NetworkService.session.request(host+path, method: .get, parameters: parameters).responseJSON { response in
                switch response.result {
                case let .success(json):
                    let weather = Weather(JSON(json), city: city)
                    resolver.fulfill(weather)
                case let .failure(error):
                    resolver.reject(error)
                }
            }
        }
    }
    
    func weatherImagePromise(iconName: String) -> Promise<UIImage> {
        guard let url = URL(string: "https://api.openweathermap.org/img/w/\(iconName).png") else {
            return Promise.value(UIImage(named: "default_icon")!)
        }
        
        // Пользуемся расширением класса URLSession определенным в PromiseKit
        return URLSession.shared.dataTask(.promise, with: url)
            .then(on: DispatchQueue.global()) { response -> Promise<UIImage> in
                // В замыкании оператора then мы обязаны создать новый Promise
                let image = UIImage(data: response.data) ?? UIImage(named: "default_icon")!
                return Promise.value(image)
        }
        
    }
    
    func weather(for city: String, completionHandler: @escaping (Swift.Result<Weather, Error>) -> Void) {
        let path = "/data/2.5/weather"
        
        let parameters: Parameters = [
            "q": city,
            "units": "metric",
            "appId": "8b32f5f2dc7dbd5254ac73d984baf306"
        ]
        
        NetworkService.session.request(host+path, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case let .success(json):
                print(json)
                let weather = Weather(JSON(json), city: city)
                completionHandler(.success(weather))
                
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func weatherImage(iconName: String, completionHandler: @escaping (Swift.Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: "https://api.openweathermap.org/img/w/\(iconName).png") else {
            completionHandler(.failure(NSError()))
            
            return
        }
        
        NetworkService.session.request(url, method: .get, parameters: nil).response { response in
            switch response.result {
            case let .success(data):
                guard let uData = data else {
                    return completionHandler(.failure(NSError()))
                }
                
                let image = UIImage(data: uData)
                completionHandler(.success(image!))
                
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
    
}

