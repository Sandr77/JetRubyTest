//
//  DribbleShot.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 20/02/2018.
//Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import RealmSwift

class DribbleShot: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var identity = 0
    @objc dynamic var imageRef = ""
    @objc dynamic var title = ""
    @objc dynamic var descrip = ""
    @objc dynamic var image: NSData?
    @objc dynamic var sortIndex = 0
    
    override class func primaryKey() -> String? {
        return "identity"
    }
    
    func fillValuesFrom(dict: [String: Any]) {
        identity = dict["id"] as! Int
        if let name = (dict["user"] as? [String: Any])?["name"] as? String {
            self.name = name
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
        if let desc = dict["description"] as? String {
            self.descrip = desc
        }
        if let images = dict["images"] as? [String: String] {
            if let hidpi = images["hidpi"] {
                imageRef = hidpi
            }
            else if let normal = images["normal"] {
                imageRef = normal
            }
        }

    }
    
    func updateValuesFrom(dict: [String: Any]) {
        if let name = (dict["user"] as? [String: Any])?["name"] as? String {
            self.name = name
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
        if let desc = dict["description"] as? String {
            self.descrip = desc
        }
        if let images = dict["images"] as? [String: String] {
            var newImageRef = ""
            if let hidpi = images["hidpi"] {
                newImageRef = hidpi
            }
            else if let normal = images["normal"] {
                newImageRef = normal
            }
            if(imageRef != newImageRef) {
                image = nil
            }
            imageRef = newImageRef
        }
    }

}
