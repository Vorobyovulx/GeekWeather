//
//  City.swift
//  GeekWeather
//
//  Created by Mad Brains on 29.06.2020.
//  Copyright © 2020 GeekTest. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class City: Object {
    
    @objc dynamic var name = ""
    let weathers = List<Weather>()
    
    convenience init(name: String, weathers: [Weather] = []) {
        self.init()
        
        self.name = name
        self.weathers.append(objectsIn: weathers)
    }
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}
