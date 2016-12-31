//
// Created by MIGUEL MOLDES on 29/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import XCTest

@testable import RunningTracker

class RTNavigationControllerMock : UINavigationController {

    var lastViewController : UIViewController?
    var lastAlertController : UIViewController?

    var asyncExpectation : XCTestExpectation?
    var pushExpectation : XCTestExpectation?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        lastViewController = viewController

        pushExpectation?.fulfill()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        lastViewController = nil

        guard let expectation = asyncExpectation else {
            XCTFail("missing expectation")
            return super.popViewController(animated: false)
        }

        expectation.fulfill()

        return super.popViewController(animated: false)
    }


    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        self.lastAlertController = viewControllerToPresent

        guard let expectation = asyncExpectation else {
            XCTFail("missing expectation")
            return
        }

        expectation.fulfill()
    }


}
