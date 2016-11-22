//
// Created by MIGUEL MOLDES on 12/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

class RTActivityLocation:NSObject , NSCoding {

    fileprivate(set) var location : CLLocation!
    fileprivate(set) var timestamp : Double = 0
    var distance : Double = 0
    var firstAfterResumed : Bool = false

    init?(location: CLLocation, timestamp: Double, firstAfterResumed:Bool = false, distance:Double = 0.0){
        self.location = location
        self.timestamp = timestamp
        self.firstAfterResumed = firstAfterResumed
        self.distance = distance
        super.init()
    }

//MARK NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let location = aDecoder.decodeObject(forKey: RecordProperty.location) as! CLLocation
        let timestamp = aDecoder.decodeDouble(forKey: RecordProperty.timestamp)
        let distance = aDecoder.decodeDouble(forKey: RecordProperty.distance)
        let firstAfterResumed = aDecoder.decodeBool(forKey: RecordProperty.firstAfterResumed)
        self.init(location: location, timestamp:timestamp, firstAfterResumed:firstAfterResumed, distance:distance)
    }

    internal func encode(with aCoder: NSCoder) {
        aCoder.encode(location!, forKey:RecordProperty.location)
        aCoder.encode(timestamp, forKey:RecordProperty.timestamp)
        aCoder.encode(distance, forKey:RecordProperty.distance)
        aCoder.encode(firstAfterResumed, forKey:RecordProperty.firstAfterResumed)
    }

}