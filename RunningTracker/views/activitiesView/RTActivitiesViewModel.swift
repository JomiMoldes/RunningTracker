//
// Created by MIGUEL MOLDES on 13/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RTActivitiesViewModel : NSObject, UITableViewDelegate, UITableViewDataSource {

    let notificationCenter : NotificationCenter!
    var activities:[RTActivity] = [RTActivity]()
    let model : RTActivitiesModel!
    var activitySelected  = PublishSubject<RTActivity>()
    var deletingActivity  = PublishSubject<RTActivity>()
    var activityDeleted   = PublishSubject<String>()

    init?(model:RTActivitiesModel, notificationCenter:NotificationCenter) {
        self.model = model
        self.notificationCenter = notificationCenter
        self.activities = model.activitiesCopy()
        self.activities = self.activities.sorted(by: {$0.startTime > $1.startTime})
    }

    func activityWasDeleted(_ notification:Notification) {
        activityDeleted.onNext("activity deleted")
    }

    func removeObservers() {
        self.notificationCenter.removeObserver(self)
    }

//Protocol

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        let activity = self.activities[(indexPath as NSIndexPath).item]
        cell = tableView.dequeueReusableCell(withIdentifier: "activityViewCell", for: indexPath) as! RTActivityViewCell
        (cell as! RTActivityViewCell).setupInfo(activity)
        cell.backgroundColor = UIColor.clear

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = self.activities[(indexPath as NSIndexPath).item]
        activitySelected.onNext(activity)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.notificationCenter.addObserver(self, selector: #selector(activityWasDeleted), name: Notification.Name(rawValue: "activityDeleted"), object: nil)
            let activity = self.activities[(indexPath as NSIndexPath).item]
            self.model.deleteActivity(activity, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager)
            self.activities.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            deletingActivity.onNext(activity)
        }
    }


}
