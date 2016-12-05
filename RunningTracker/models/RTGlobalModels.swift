//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTGlobalModels {

    static let sharedInstance = RTGlobalModels()

    let activitiesModel : RTActivitiesModel
    let storeActivitiesManager: RTStoreActivitiesManager
    let activitiesAndRecordsHelper : RTActivitiesAndRecordsHelper

    fileprivate init(){
        self.activitiesModel = RTActivitiesModel()
        self.storeActivitiesManager = RTStoreActivitiesManager()
        self.activitiesAndRecordsHelper = RTActivitiesAndRecordsHelper()
    }

}
