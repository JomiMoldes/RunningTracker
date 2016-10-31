//
// Created by MIGUEL MOLDES on 9/9/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation

extension Array {

    func splitBy(_ subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in

            let endIndex = (startIndex + subSize >= self.count) ? self.count : startIndex + subSize
            return Array(self[startIndex ..< endIndex])
        }
    }

}
