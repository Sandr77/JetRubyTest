//
//  ImageDownloader.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 22/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: NSObject {
    
    static let shared = ImageDownloader()
    
    var loadingNow = [Int: DribbleShotViewModel]()
    
    func loadImageFor(model: DribbleShotViewModel) {
        var loading = false
        if let _ = loadingNow[model.identity] {
            loading = true
        }
        loadingNow[model.identity] = model
        if(loading == true) {
            return
        }
        APIManager.loadImageFrom(ref: model.imageRef, completion: {data in
            if(data != nil) {
                if let _ = UIImage.init(data: data!) {
                    model.imageData = data as NSData?
                }
            }
            self.loadingNow.removeValue(forKey: model.identity)
        })
    }
    
}
