//
//  DribbleShotViewModel.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 21/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import RealmSwift

class DribbleShotViewModel: NSObject {
    
    weak var cell: ShotsListTableViewCell?
    
    var name = ""
    var identity = 0
    var imageRef = ""
    var title = ""
    var descrip = ""
    
    var image: UIImage?
    private var _imageData: NSData?
    var imageData: NSData? {
        get {
           return _imageData
        }
        
        set {
            if newValue != nil {
                _imageData = newValue
                image = UIImage.init(data: _imageData as Data!)
                DispatchQueue.global(qos: .background).async {
                    let database = try! Realm()
                    let shot = database.object(ofType: DribbleShot.self, forPrimaryKey: self.identity)
                    try! database.write {
                        shot?.image = newValue
                    }
                }
                DispatchQueue.main.async {
                    if(self.cell != nil && self.cell!.shot!.identity == self.identity) {
                        self.cell?.imageLoaded(image: self.image)
                    }
                }
            }
            
        }
    }
    
    func loadImageFor(cell: ShotsListTableViewCell) {
        self.cell = cell
        ImageDownloader.shared.loadImageFor(model: self)
    }
    
    func fillFromDataModel(shot: DribbleShot) {
        name = shot.name
        identity = shot.identity
        title = shot.title
        descrip = shot.descrip
        imageData = shot.image
        imageRef = shot.imageRef
    }
    
}
