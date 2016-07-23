//
// Created by MIGUEL MOLDES on 7/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class RTInitialViewController:UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myActivitiesButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var gpsImageView: UIImageView!
    var locationManager : CLLocationManager!
    var activitiesModel : RTActivitiesModel!

    override func viewDidLoad() {
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        super.viewDidLoad()
        self.setupButtons()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startLocation()
        activitiesModel.loadActivities(RTActivitiesModel.ArchiveURL.path!)
        self.myActivitiesButton.enabled = activitiesModel.activitiesLenght() > 0
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        locationManager = nil
    }

    func setupButtons(){
        self.myActivitiesButton.titleLabel?.numberOfLines = 1
        self.myActivitiesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.myActivitiesButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        self.myActivitiesButton.enabled = false
        self.startButton.enabled = false
    }

    func startLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        switch (CLLocationManager.authorizationStatus()){
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
            title:"Location Access Disabled",
                    message:"In order to track your paths, please open this app's settings and set location access to 'While using the app'",
                    preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title:"Open", style: .Default) {
                (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)

            self.presentViewController(alertController, animated:true, completion:nil)

            break
        default:
            break
        }

    }

//MARK IBActions

    @IBAction func myActivitiesTouched(sender: UIButton) {
        let activitiesController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("activitiesView") as? RTActivitiesViewController
        self.navigationController!.pushViewController(activitiesController!, animated:true)
    }

    @IBAction func startTouched(sender: UIButton) {
        let mapViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("activeMapView") as? RTActiveMapViewController

        do {
            try self.activitiesModel.startActivity()
        } catch {
            print("the activity was not possible to start")
            return
        }

        self.navigationController!.pushViewController(mapViewController!, animated:true)
    }

// MARK Location Manager

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.startButton.enabled = true
        gpsImageView.image = UIImage(named:"GPSgreen.png")
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        self.startButton.enabled = false
        gpsImageView.image = UIImage(named:"GPSblack.png")
        if(CLLocationManager.authorizationStatus() == .AuthorizedAlways){
           locationManager.startUpdatingLocation()
        }
    }

}
