//
// Created by MIGUEL MOLDES on 20/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

class RTLoadingView : UIView {

    var indicatorView : UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupActivityIndicator()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupActivityIndicator()
    }

    func setupBackground() {
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)

    }

    func setupActivityIndicator() {
        if indicatorView == nil {
            indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            indicatorView.hidesWhenStopped = true
            indicatorView.center = self.center
            indicatorView.startAnimating()
            self.addSubview(indicatorView)
        }
    }

}
