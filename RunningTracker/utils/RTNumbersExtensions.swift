//
// Created by MIGUEL MOLDES on 15/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

extension Double {
    mutating func roundToPlaces(_ places:Int)->Double{
        let divisor = pow(10.0, Double(places))
        let multiple = self * divisor
        return multiple.rounded() / divisor
    }
}

extension TimeInterval {
    func timeFormat(_ format:String, milliseconds:Bool = false)->String{
        var elapsedTime:TimeInterval = self
        let hours = UInt(elapsedTime / 60 / 60)
        elapsedTime -= TimeInterval(hours) * 60 * 60
        let minutes = UInt64(elapsedTime / 60.0)
        elapsedTime -= TimeInterval(minutes) * 60
        let seconds = UInt64(elapsedTime)
        let strHours = String(format: format, hours, minutes, seconds)
        return strHours
    }

    func getHours()->String{
        let elapsedTime = self
        let hours = UInt64(elapsedTime / 60 / 60)
        return String(format:"%02d", hours)
    }

    func getMinutes()->String{
        var elapsedTime = self
        let hours = UInt64(elapsedTime / 60 / 60)
        elapsedTime -= TimeInterval(hours) * 60 * 60
        let minutes = UInt64(elapsedTime / 60.0)
        return String(format:"%02d", minutes)
    }

    func getSeconds()->String{
        var elapsedTime = self
        let hours = UInt64(elapsedTime / 60 / 60)
        elapsedTime -= TimeInterval(hours) * 60 * 60
        let minutes = UInt64(elapsedTime / 60.0)
        elapsedTime -= TimeInterval(minutes) * 60
        let seconds = UInt64(elapsedTime)
        return String(format:"%02d", seconds)
    }
}
