//
// Created by MIGUEL MOLDES on 5/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    func shrinkFont() {
        var success : Bool = false
        var fontSize : CGFloat = self.font!.pointSize
        var attributedString = NSAttributedString(string: self.text!, attributes: [NSFontAttributeName: UIFont(name: self.font!.familyName, size: fontSize)!])

        let currentSize = self.frame.size
        let constrainsSize = CGSizeMake(1000.0, 1000.0)

        var myFrame = attributedString.boundingRectWithSize(constrainsSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        success = myFrame.size.width <= currentSize.width

        while !success {
            fontSize = fontSize - 1
            attributedString = NSAttributedString(string: self.text!, attributes: [NSFontAttributeName: UIFont(name: self.font!.familyName, size: fontSize )!])
            myFrame = attributedString.boundingRectWithSize(constrainsSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
            success = myFrame.size.width <= currentSize.width
        }
        self.attributedText = attributedString
        self.frame = myFrame

    }

}
