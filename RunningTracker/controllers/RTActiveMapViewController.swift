//
//  RTActiveMapViewController.swift
//
//
//  Created by MIGUEL MOLDES on 11/7/16.
//
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

enum TimeMeasurement {
    case Hour
    case Minute
    case Second
    case Millisecond
}

class RTActiveMapViewController : UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapContainer: UIView!

    @IBOutlet weak var chronometerLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    var locationManager : CLLocationManager!
    var locationsHistory : NSMutableArray!

    var mapView : GMSMapView!
    var timer : NSTimer!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationsHistory = NSMutableArray()
        setupMap()
        setupLocationManager()
        setupTimer()
    }

    func setupMap(){
        let camera = GMSCameraPosition.cameraWithLatitude(52.52356, longitude: 13.448896, zoom: 10)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = true
        self.mapView.mapType = kGMSTypeSatellite
        mapContainer.addSubview(self.mapView)
    }

    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func setupTimer(){
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target:self, selector: aSelector, userInfo: nil, repeats: true)
    }

    func updateTime(){
        let activitiesModel = RTActivitiesModel.sharedInstance
        let elapsedTime:NSTimeInterval = activitiesModel.getElapsedTime()
        let elapsedStr = elapsedTime.getHours() + ":" + elapsedTime.getMinutes() + ":" + elapsedTime.getSeconds()
        self.chronometerLabel.text = elapsedStr

        let metersDone = activitiesModel.getDistanceDone()
        let strKMsDone:String = String(format:"%.2f", metersDone / 1000)
        self.distanceLabel.text = strKMsDone

        let paced:NSTimeInterval = activitiesModel.getPaceLastKM()
        self.paceLabel.text = paced.getMinutes() + ":" + paced.getSeconds()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        invalidateTimer()
    }

    func invalidateTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }

// IBActions

    @IBAction func backTouched(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func stopTouched(sender: UIButton) {
        RTActivitiesModel.sharedInstance.endActivity()
        RTActivitiesModel.sharedInstance.saveActivities()
        invalidateTimer()
        self.pauseButton.enabled = false
    }
    
    @IBAction func pauseTouched(sender: UIButton) {
        let activities = RTActivitiesModel.sharedInstance
        if activities.isCurrentActivityPaused() {
            activities.resumeActivity()
            sender.setTitle("PAUSE", forState: UIControlState.Normal)
            setupTimer()
        }else{
            activities.pauseActivity()
            sender.setTitle("RESUME", forState: UIControlState.Normal)
            invalidateTimer()
        }
    }

// Location Manager

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location:CLLocation = locations[locations.count - 1]

        self.mapView.animateToLocation(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))

        if !RTActivitiesModel.sharedInstance.activityRunning {
           return
        }
        let path = GMSMutablePath()
        for location:CLLocation in locations {
            path.addCoordinate(location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView

        let activityLocation = RTActivityLocation(location: location, timestamp: NSDate().timeIntervalSinceReferenceDate)

        RTActivitiesModel.sharedInstance.addActivityLocation(activityLocation!)



    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

}
