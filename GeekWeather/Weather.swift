//
//  Weather.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Weather: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var date: Date = Date.distantPast
    @objc dynamic var temperature: Double = 0
    @objc dynamic var pressure: Double = 0
    @objc dynamic var city: String = ""
    
    @objc dynamic var icon: String = ""
    @objc dynamic var textDescription: String = ""
    
    var cities = LinkingObjects(fromType: City.self, property: "weathers")
    
    convenience init(_ json: JSON, city: String) {
        self.init()
        
        let date = json["dt"].doubleValue
        self.date = Date(timeIntervalSince1970: date)
        
        self.temperature = json["main"]["temp"].doubleValue
        self.pressure = json["main"]["pressure"].doubleValue
        
        self.icon = json["weather"][0]["icon"].stringValue
        self.textDescription = json["weather"][0]["main"].stringValue
        
        self.city = city
        self.id = city + String(date)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
