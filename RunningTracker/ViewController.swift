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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator()
    }

    func activityIndicator() {
        let size = self.view.frame.size
        let frame = CGRect(x: size.width / 2 , y: size.height / 2 + 120, width: size.width, height: size.height)
        showActivityIndicatorWithFrame(frame)
    }

    func loadInitialView() {
//        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
//        let initialViewController = storyBoard.instantiateViewController(withIdentifier: "InitialView") as? RTInitialViewController
//        self.navigationController?.pushViewController(initialViewController!, animated: true )
        let initialViewController2 = RTInitialViewController2(nibName:"RTInitialView", bundle:nil)
        self.navigationController?.pushViewController(initialViewController2, animated: true )
    }

    func iCloudReady() {
        NotificationCenter.default.addObserver(self, selector: #selector(activitiesFromICloudLoaded), name: NSNotification.Name(rawValue: "activitiesLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activitiesFromICloudLoaded), name: NSNotification.Name(rawValue: "activitiesSaved"), object: nil)
        activitiesModel.loadActivities(RTActivitiesModel.ArchiveURL.path, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager2)
    }

    func activitiesFromICloudLoaded(_ notification:Notification){
        NotificationCenter.default.removeObserver(self)
        var diff = Date().timeIntervalSinceReferenceDate - self.timeChecking
        diff = (diff > Double(ViewController.timeToShowInitialScreen)) ? 0 : Double(ViewController.timeToShowInitialScreen) - diff
        let delayTime = DispatchTime.now() + Double(Int64(diff * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.hideActivityIndicator()
            self.loadInitialView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkForICloud() {
        weak var myself = self
        self.timeChecking = Date().timeIntervalSinceReferenceDate
        let container = CKContainer.default()
        container.accountStatus(completionHandler: {
            status, error in

            let main = DispatchQueue.main
            main.async(execute: {
                switch status {
                case .available:
                    self.iCloudReady()
                    break
                case .restricted:
                    print("access to iCloud is restricted")
                    self.noAccessToICloud()
                    break
                case .noAccount, .couldNotDetermine:
                    let alertController = UIAlertController(
                            title: "iCloud off",
                            message: "In order to save your activities in iCloud, you should turn it on'",
                            preferredStyle: .alert)

                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                        (action) in
                        myself!.noAccessToICloud()
                    }
                    alertController.addAction(cancelAction)

                    let openAction = UIAlertAction(title: "Open", style: .default) {
                        (action) in
                        if let url = URL(string: "prefs:root=iCloud") {
                            UIApplication.shared.openURL(url)
                        }
                        NotificationCenter.default.addObserver(myself!, selector: #selector(myself!.appWillEnterForeground), name: NSNotification.Name(rawValue: "applicationWillEnterForeground"), object: nil)
                    }
                    alertController.addAction(openAction)

                    myself!.present(alertController, animated: true, completion: nil)
                    break
                }

            })

        })
    }

    func appWillEnterForeground(_ notification:Notification) {
        NotificationCenter.default.removeObserver(self)
        checkForICloud()
    }

    func noAccessToICloud() {
        iCloudReady()
    }

}

