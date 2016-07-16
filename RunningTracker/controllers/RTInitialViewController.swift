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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startLocation()
    }

    func setupButtons(){
        self.myActivitiesButton.titleLabel?.numberOfLines = 1
        self.myActivitiesButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.myActivitiesButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        
        self.startButton.enabled = false
    }


    // IBActions

    @IBAction func myActivitiesTouched(sender: UIButton) {
    }

    @IBAction func startTouched(sender: UIButton) {
        let mapViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("activeMapView") as? RTActiveMapViewController
        RTActivitiesModel.sharedInstance.startActivity()
        self.navigationController!.pushViewController(mapViewController!, animated:true)
    }

    // Mark Location Manager

    func startLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        switch (CLLocationManager.authorizationStatus()){
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
            break
            case .AuthorizedAlways, .Restricted, .Denied:
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

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.startButton.enabled = true
        gpsImageView.image = UIImage(named:"GPSgreen.png")
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        self.startButton.enabled = false
        gpsImageView.image = UIImage(named:"GPSblack.png")
        if(CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse){
           locationManager.requestLocation()
        }
    }

}
