//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

class RTActivityViewCell : UITableViewCell {


    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!


    func setupInfo(activity:RTActivity) {
        let formatter = CachedDateFormatter.sharedInstance.formatterWith("dd/MM/YY")
        self.dateLabel.text = formatter.getDateWithFormat("dd/MM/YY", time:activity.startTime)

        let duration = activity.getDuration()
        let durationString = duration.getHours() + ":" + duration.getMinutes() + ":" + duration.getSeconds()
        self.durationLabel.text = durationString

        let pace = activity.getPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()
        self.paceLabel.text = paceString

        let distanceString = String(format:"%.2f", activity.distance / 1000)
        self.distanceLabel.text = distanceString
    }


}
