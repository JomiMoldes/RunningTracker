//
// Created by MIGUEL MOLDES on 21/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

extension DateFormatter {

    func getDateWithFormat(_ format:String, time:TimeInterval) -> String {
        self.dateFormat = format
        let date = Date(timeIntervalSince1970: time)
        let str = string(from: date)
        return str
    }

}
