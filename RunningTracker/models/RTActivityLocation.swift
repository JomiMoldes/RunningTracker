//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

struct ActivityLocationPropertyKey{
    static let locationKey = "location"
    static let timestampKey = "timestamp"
}

class RTActivityLocation:NSObject , NSCoding {

    var location : CLLocation!
    var timestamp : Double = 0
    var distance : Double = 0

    init?(location: CLLocation, timestamp: Double){
        self.location = location
        self.timestamp = timestamp
    }

//MARK NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObjectForKey(ActivityLocationPropertyKey.locationKey) as! CLLocation
        let timestamp = aDecoder.decodeDoubleForKey(ActivityLocationPropertyKey.timestampKey)
        self.init(location: location, timestamp:timestamp)
    }

    internal func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location!, forKey:ActivityLocationPropertyKey.locationKey)
        aCoder.encodeDouble(timestamp, forKey:ActivityLocationPropertyKey.timestampKey)
    }

}
