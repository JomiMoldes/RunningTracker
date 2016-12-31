//
// Created by MIGUEL MOLDES on 31/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTNotificationCenterFake : NotificationCenter {

    var removeObserverCalled = false

    override func removeObserver(_ observer: Any) {
        super.removeObserver(observer)
        self.removeObserverCalled = true
    }


}
