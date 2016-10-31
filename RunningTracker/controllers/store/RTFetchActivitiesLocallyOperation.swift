//
// Created by MIGUEL MOLDES on 15/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import PromiseKit

class RTFetchActivitiesLocallyOperation {

    func execute(_ localPath:String) -> Promise<[RTActivity]> {
        return Promise { fulfill, reject in
            var activities = NSKeyedUnarchiver.unarchiveObject(withFile: localPath) as? [RTActivity]
            if activities == nil {
                activities = [RTActivity]()
            }
            fulfill(activities!)
        }
    }

}
