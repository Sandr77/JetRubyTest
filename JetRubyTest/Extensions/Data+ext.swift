//
//  Data+ext.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 21/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation

extension Data {
    var htmlAttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
