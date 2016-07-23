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
    var activitiesModel: RTActivitiesModel!

    var mapView : GMSMapView!
    var timer : NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        self.setupLabels()
        setupMap()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationsHistory = NSMutableArray()
        setupLocationManager()
        setupTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mapView.frame = CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height)
    }

    func setupMap(){
        let camera = GMSCameraPosition.cameraWithLatitude(52.52356, longitude: 13.45097995, zoom: 18)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = true
        self.mapView.mapType = kGMSTypeSatellite
        mapContainer.addSubview(self.mapView)
    }

    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 20.0
        locationManager.activityType = CLActivityType.Fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func setupTimer(){
        let aSelector:Selector = #selector(RTActiveMapViewController.updateTime)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target:self, selector: aSelector, userInfo: nil, repeats: true)
    }

    func setupLabels() {
        self.distanceLabel.numberOfLines = 1
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.lineBreakMode = NSLineBreakMode.ByClipping
        self.distanceLabel.text = "0.00"
    }

    func updateTime(){
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

    func drawPath() {
        let path = GMSMutablePath()
        for activityLocation in self.activitiesModel.currentActivityLocations() {
            path.addCoordinate(activityLocation.location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView

    }

    func endActivity() {
        self.activitiesModel.endActivity()
        self.activitiesModel.saveActivities(RTActivitiesModel.ArchiveURL.path!)
        invalidateTimer()
        self.pauseButton.enabled = false
    }

// IBActions

    @IBAction func backTouched(sender: UIButton) {
        endActivity()
        self.navigationController!.popViewControllerAnimated(true)
    }

    @IBAction func stopTouched(sender: UIButton) {
        endActivity()
    }
    
    @IBAction func pauseTouched(sender: UIButton) {
        if self.activitiesModel.currentActivityPaused {
            self.activitiesModel.resumeActivity()
            sender.setTitle("PAUSE", forState: UIControlState.Normal)
            setupTimer()
        }else{
            self.activitiesModel.pauseActivity()
            sender.setTitle("RESUME", forState: UIControlState.Normal)
            invalidateTimer()
        }
    }

// Location Manager

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location:CLLocation = locations[locations.count - 1]

        self.mapView.animateToLocation(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))

        if !self.activitiesModel.activityRunning {
           return
        }

        let activityLocation = RTActivityLocation(location: location, timestamp: NSDate().timeIntervalSinceReferenceDate)

        if self.activitiesModel.addActivityLocation(activityLocation!) {
            self.drawPath()
        }

    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

}
