//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

class RTActivitiesViewController : UIViewController {

    var activitiesModel : RTActivitiesModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
    }

// IBActions

    @IBAction func backTouched(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }

}
