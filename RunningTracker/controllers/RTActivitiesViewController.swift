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

        self.activities = self.activities.sorted(by: {$0.startTime > $1.startTime})
        setupTable()
        setupBackButton()
        noActivitiesLabel.isHidden = self.activities.count > 0
    }

    func setupBackButton() {
        backButtonView.areaButton.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
    }

    func backTouched(_ sender:UIButton){
        self.navigationController!.popViewController(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noActivitiesLabel.isHidden = self.activities.count > 0
    }


    func setupTable() {
        self.tableView.isHidden = self.activities.count == 0
        self.tableView.register(UINib(nibName:"RTActivityViewCell", bundle:nil), forCellReuseIdentifier: "activityViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func activityDeleted(_ notification:Notification) {
        self.hideActivityIndicator()
    }

// UITable delegate and source data

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
        let activityDoneMap = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "activityDoneMap") as? RTActivityPathDoneViewController
        activityDoneMap!.activity = activity
        self.navigationController!.pushViewController(activityDoneMap!, animated:true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.showActivityIndicator()
            NotificationCenter.default.addObserver(self, selector: #selector(activityDeleted), name: NSNotification.Name(rawValue: "activityDeleted"), object: nil)
            let activity = self.activities[(indexPath as NSIndexPath).item]
            self.activitiesModel.deleteActivity(activity, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager2)
            self.activities.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.view.setNeedsUpdateConstraints()
        }
    }

}
