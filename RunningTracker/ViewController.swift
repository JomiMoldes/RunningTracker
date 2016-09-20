//
//  ViewController.swift
//  RunningTracker
//
//  Created by MIGUEL MOLDES on 7/7/16.
//  Copyright © 2016 MIGUEL MOLDES. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var logoView: UIView!

    static let  timeToShowInitialScreen = 3

    var timeChecking = 0.0

    var activitiesModel : RTActivitiesModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel

        checkForICloud()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator()
    }

    func activityIndicator() {
        let size = self.view.frame.size
        let frame = CGRectMake(size.width / 2 , size.height / 2 + 120, size.width, size.height)
        showActivityIndicatorWithFrame(frame)
    }

    func loadInitialView() {
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewControllerWithIdentifier("InitialView") as? RTInitialViewController
        self.navigationController?.pushViewController(initialViewController!, animated: true )
    }

    func iCloudReady() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(activitiesFromICloudLoaded), name: "activitiesLoaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(activitiesFromICloudLoaded), name: "activitiesSaved", object: nil)
        activitiesModel.loadActivities(RTActivitiesModel.ArchiveURL.path!, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager2)
    }

    func activitiesFromICloudLoaded(notification:NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        var diff = NSDate().timeIntervalSinceReferenceDate - self.timeChecking
        diff = (diff > Double(ViewController.timeToShowInitialScreen)) ? 0 : Double(ViewController.timeToShowInitialScreen) - diff
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(diff * Double(NSEC_PER_SEC)))

        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.hideActivityIndicator()
            self.loadInitialView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkForICloud() {
        weak var myself = self
        self.timeChecking = NSDate().timeIntervalSinceReferenceDate
        let container = CKContainer.defaultContainer()
        container.accountStatusWithCompletionHandler({
            status, error in

            let main = dispatch_get_main_queue()
            dispatch_async(main, {
                switch status {
                case .Available:
                    self.iCloudReady()
                    break
                case .Restricted:
                    print("access to iCloud is restricted")
                    self.noAccessToICloud()
                    break
                case .NoAccount, .CouldNotDetermine:
                    let alertController = UIAlertController(
                            title: "iCloud off",
                            message: "In order to save your activities in iCloud, you should turn it on'",
                            preferredStyle: .Alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
                        (action) in
                        myself!.noAccessToICloud()
                    }
                    alertController.addAction(cancelAction)

                    let openAction = UIAlertAction(title: "Open", style: .Default) {
                        (action) in
                        if let url = NSURL(string: "prefs:root=iCloud") {
                            UIApplication.sharedApplication().openURL(url)
                        }
                        NSNotificationCenter.defaultCenter().addObserver(myself!, selector: #selector(myself!.appWillEnterForeground), name: "applicationWillEnterForeground", object: nil)
                    }
                    alertController.addAction(openAction)

                    myself!.presentViewController(alertController, animated: true, completion: nil)
                    break
                }

            })

        })
    }

    func appWillEnterForeground(notification:NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        checkForICloud()
    }

    func noAccessToICloud() {
        iCloudReady()
    }

}

