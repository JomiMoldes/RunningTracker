//
// Created by MIGUEL MOLDES on 28/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTActivitiesViewModelFake : RTActivitiesViewModel {


    var selectAsyncExpectation : XCTestExpectation?
    var activityDeletedExpectation : XCTestExpectation?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        selectAsyncExpectation?.fulfill()
    }

    override func activityWasDeleted(_ notification:Notification) {
        super.activityWasDeleted(notification)
        activityDeletedExpectation?.fulfill()
    }
}
