//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit

class RTActivitiesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButtonView: RTBackButtonView!
    @IBOutlet weak var noActivitiesLabel: UILabel!

    var activitiesModel : RTActivitiesModel!
    var activities:[RTActivity] = [RTActivity]()
    var longPressGesture : UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        self.activities = self.activitiesModel.getActivitiesCopy()

        self.activities = self.activities.sort({$0.startTime > $1.startTime})
        setupTable()
        setupBackButton()
        noActivitiesLabel.hidden = self.activities.count > 0
    }

    func setupBackButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backTouched))
        self.backButtonView.addGestureRecognizer(gesture)
    }

    func backTouched(sender:UITapGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noActivitiesLabel.hidden = self.activities.count > 0
    }


    func setupTable() {
        self.tableView.hidden = self.activities.count == 0
        self.tableView.registerNib(UINib(nibName:"RTActivityViewCell", bundle:nil), forCellReuseIdentifier: "activityViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

// UITable delegate and source data

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        let activity = self.activities[indexPath.item]
        cell = tableView.dequeueReusableCellWithIdentifier("activityViewCell", forIndexPath: indexPath) as! RTActivityViewCell
        (cell as! RTActivityViewCell).setupInfo(activity)
        cell.backgroundColor = UIColor.clearColor()

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = backgroundView

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let activity = self.activities[indexPath.item]
        let activityDoneMap = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("activityDoneMap") as? RTActivityPathDoneViewController
        activityDoneMap!.activity = activity
        self.navigationController!.pushViewController(activityDoneMap!, animated:true)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let activity = self.activities[indexPath.item]
            self.activitiesModel.deleteActivity(activity, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager)
            self.activities.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.view.setNeedsUpdateConstraints()
        }
    }

}
