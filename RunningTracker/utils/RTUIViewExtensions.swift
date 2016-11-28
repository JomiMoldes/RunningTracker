//
// Created by MIGUEL MOLDES on 27/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func showActivityIndicator() {
        let loadingView = RTLoadingView(frame:self.frame)
        self.addSubview(loadingView)
    }

    func hideActivityIndicator() {
        for subView in self.subviews {
            if subView as? RTLoadingView != nil {
                subView.removeFromSuperview()
            }
            if subView as? UIActivityIndicatorView != nil {
                subView.removeFromSuperview()
            }
        }
    }

}
