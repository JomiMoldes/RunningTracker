//
// Created by MIGUEL MOLDES on 20/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func showActivityIndicator() {
        let loadingView = RTLoadingView(frame:self.view.frame)
        self.view.addSubview(loadingView)
    }

    func hideActivityIndicator() {
        for subView in self.view.subviews {
            if subView as? RTLoadingView != nil {
                subView.removeFromSuperview()
            }
            if subView as? UIActivityIndicatorView != nil {
                subView.removeFromSuperview()
            }
        }
    }

    func showActivityIndicatorWithFrame(_ frame:CGRect){
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        let size = indicatorView.frame.size
        indicatorView.frame = CGRect(x: frame.origin.x - (size.width / 2), y: frame.origin.y, width: size.width, height: size.height)
        self.view.addSubview(indicatorView)
    }

}
