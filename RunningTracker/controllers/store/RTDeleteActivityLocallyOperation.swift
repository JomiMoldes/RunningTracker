//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit

class RTDeleteActivityLocallyOperation {

    func execute(activities:[RTActivity], activity:RTActivity,  path:String) -> [RTActivity] {
        var activitiesToSave = activities
        for localActivity:RTActivity in activitiesToSave {
            if Int(localActivity.startTime) == Int(activity.startTime) {
                let index = activitiesToSave.indexOf(localActivity)
                activitiesToSave.removeAtIndex(index!)
                RTSaveLocallyOperation().execute(activitiesToSave, path: path)
                break
            }
        }
        return activitiesToSave
    }

}
