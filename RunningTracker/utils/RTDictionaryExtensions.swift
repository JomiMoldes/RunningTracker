//
// Created by MIGUEL MOLDES on 10/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import CoreLocation

extension Dictionary {

    static func customCompare<T:Equatable,K:Equatable>(dic1:[T:K], dic2:[T:K]) -> Bool {
        for (key, value) in dic1 {
            if value != dic2[key] {
                return false
            }
        }
        return true
    }

    func customCompareLocationsByDistance(dic2:[Int:CLLocation]) -> Bool {
        for key in self.keys {
            let location1 = self[key] as! CLLocation
            guard let location2 = dic2[key as! Int] else {
                return false
            }
            if !location2.distance(from: location1).isZero {
                return false
            }
        }
        return true
    }



}
