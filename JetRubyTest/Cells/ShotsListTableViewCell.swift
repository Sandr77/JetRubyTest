//
//  ShotsListTableViewCell.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 21/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class ShotsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var shotImageView: UIImageView?
    
    @IBOutlet weak var heightLimitConstraint: NSLayoutConstraint?
    
    var shot: DribbleShotViewModel?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: Notification.Name(ORIENTATION_CHANGED_NOTIFICATION), object: nil)
    }
    
    func fillValues() {
        titleLabel?.text = shot?.title
        if let htmlString = shot!.descrip.data(using: String.Encoding.utf8)!.htmlAttributedString {
            let string = NSMutableAttributedString.init(attributedString: htmlString)
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(0, string.length))
            descriptionLabel?.attributedText = string
        }
        else {
            descriptionLabel?.attributedText = nil
            descriptionLabel?.text = ""
        }
        heightLimitConstraint?.constant = UIScreen.main.bounds.size.height / 2
        if(shot!.image != nil) {
            shotImageView?.image = shot!.image
        }
        else {
            shotImageView?.image = #imageLiteral(resourceName: "Placeholder")
            shot?.loadImageFor(cell: self)
        }
    }
    
    func imageLoaded(image: UIImage?) {
        shotImageView?.image = image
    }
    
    @objc private func orientationChanged() {
        heightLimitConstraint?.constant = UIScreen.main.bounds.size.width / 2
    }
    
}
