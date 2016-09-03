//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

class RTActivityViewCell : UITableViewCell {


    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var seeMapButton: UIButton!


    func setupInfo(activity:RTActivity) {
        let formatter = CachedDateFormatter.sharedInstance.formatterWith("dd/MM/YY")
        let dateString = formatter.getDateWithFormat("dd/MM/YY", time:activity.startTime)

        let duration = activity.getDuration()
        let durationString = duration.getHours() + ":" + duration.getMinutes() + ":" + duration.getSeconds()

        let pace = activity.getPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()

        let distanceString = String(format:"%.2f", activity.distance / 1000)

        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.text = "\(dateString) - Pace: \(paceString)"
        self.distanceLabel.text = "\(distanceString) km - \(durationString)"

        self.seeMapButton.enabled = false
    }


}
