//
// Created by MIGUEL MOLDES on 29/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

@testable import RunningTracker

class RTUITapGestureRecognizerFake : UITapGestureRecognizer {

    var testTarget : Any!
    var testAction : Selector?


    override init(target: Any?, action: Selector?) {
        self.testTarget = target
        self.testAction = action
        super.init(target: target, action: action)
    }


    func performAction() {
        let target = self.testTarget as! NSObjectProtocol
//        target.perform((self.testAction!)

    }



}
