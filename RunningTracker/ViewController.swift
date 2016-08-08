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

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForICloud()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    func loadInitialView() {
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewcontroller = storyBoard.instantiateViewControllerWithIdentifier("InitialView") as? RTInitialViewController
        self.navigationController?.pushViewController(initialViewcontroller!, animated: true )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func checkForICloud() {
        weak var myself = self
        let container = CKContainer.defaultContainer()
        container.accountStatusWithCompletionHandler({
            status, error in

            let main = dispatch_get_main_queue()
            dispatch_async(main, {
                switch status {
                case .Available:
                    container.requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: {
                        applicationPermissionStatus, error in
                        dispatch_async(dispatch_get_main_queue(), {
                            if error != nil {
                                print("couldn't request iCloud permission")
                                self.noAccessToICloud()
                                self.loadInitialView()
                                return
                            }
                            switch applicationPermissionStatus {
                            case .InitialState:
                                break
                            case .Denied:
                                print("user has denied iCloud permissions")
                                self.noAccessToICloud()
                                break
                            case .CouldNotComplete:
                                print("user could not complete iCloud permissions")
                                self.noAccessToICloud()
                                break
                            case .Granted:
                                print("all good with iCloud")
                                break
                            }

                            self.loadInitialView()
                        })
                    })
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

                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)

                    let openAction = UIAlertAction(title: "Open", style: .Default) {
                        (action) in
                        if let url = NSURL(string: "prefs:root=iCloud") {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                    alertController.addAction(openAction)

                    myself!.presentViewController(alertController, animated: true, completion: nil)
                    break
                }

            })

        })
    }

    func noAccessToICloud() {

    }


}

