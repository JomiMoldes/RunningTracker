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


    func setupInfo(_ activity:RTActivity) {
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

        self.seeMapButton.isEnabled = false
    }

    override func layoutSubviews ()
    {
        super.layoutSubviews()
        let width = frame.width
        if width > 0 {
            let buttonSize = self.seeMapButton.frame.size
            let insetsSize = CGFloat(10.0)
            self.seeMapButton.titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: buttonSize.width - insetsSize * 2, height: buttonSize.height)

            let insets = UIEdgeInsets(top: 0.0, left: insetsSize, bottom: 0.0, right: insetsSize)
            self.seeMapButton.titleEdgeInsets = insets
            self.seeMapButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
            self.seeMapButton.titleLabel?.textAlignment = NSTextAlignment.center

            self.seeMapButton.titleLabel!.shrinkFont()

        }
    }


}
