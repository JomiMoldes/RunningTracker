//
// Created by MIGUEL MOLDES on 21/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

extension NSDateFormatter {

    func getDateWithFormat(format:String, time:NSTimeInterval) -> String {
        self.dateFormat = format
        let date = NSDate(timeIntervalSince1970: time)
        let str = stringFromDate(date)
        return str
    }

}
