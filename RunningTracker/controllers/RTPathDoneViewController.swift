//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit


class RTPathDoneViewController : UIViewController {

    var pathDoneView : RTPathDoneView {
        get {
            return view as! RTPathDoneView
        }
    }

    var pathDoneViewModel : RTPathDoneViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        pathDoneView.model = pathDoneViewModel
        setupBackButton()
    }

    func setupBackButton() {
        pathDoneView.backButtonView.areaButton.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
    }

    func backTouched(_ sender:UIButton){
        self.navigationController!.popViewController(animated: true)
    }


}
