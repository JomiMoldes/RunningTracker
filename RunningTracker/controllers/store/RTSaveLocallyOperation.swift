//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

class RTSaveLocallyOperation {

    func execute(activities: [RTActivity], path:String) -> Bool {
        return NSKeyedArchiver.archiveRootObject(activities, toFile: path)
    }

}
