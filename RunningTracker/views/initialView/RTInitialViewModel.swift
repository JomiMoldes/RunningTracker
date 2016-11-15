//
// Created by MIGUEL MOLDES on 13/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTInitialViewModel : NSObject {

    var gpsRunning : Bool = false
    let model:RTActivitiesModel!

    init?(model:RTActivitiesModel){
        self.model = model
    }

    var paceText: String {
        get {
            let pace = self.model.getBestPace()
            return pace.getMinutes() + ":" + pace.getSeconds()
        }
    }

    var distanceText : String {
        get {
            let distance = self.model.getLongestDistance()
            return String(format:"%.2f km", distance / 1000)
        }
    }

}
