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

class RTActiveMapViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapContainer: UIView!

    @IBOutlet weak var chronometerLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!

    let initialZoom : Float = 18.0
    var lastZoom : Float = 18.0

    var locationManager : CLLocationManager!
    var locationsHistory : NSMutableArray!
    var activitiesModel: RTActivitiesModel!

    var mapView : GMSMapView!
    var timer : NSTimer!
    var mapMarkersManager : RTMapMarkersManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        self.setupLabels()
        addObservers()
        setupMap()
        setupMapMarkers()
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

    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addMarker), name: "addKMMarker", object: nil)
    }

    func addMarker(notification:NSNotification) {
        let location = notification.userInfo!["location"] as! CLLocation
        let index = notification.userInfo!["km"] as! Int

        dispatch_async(dispatch_get_main_queue()) {
            let image = UIImage(named: "Km_icon")
            self.mapMarkersManager.addMarkerWithLocation(location, km: index, markImage: image)
        }
    }

    func addEndFlagMarker(){
        let location = self.activitiesModel.getCurrentActivityCopy()!.getActivitiesCopy().last!.location
        dispatch_async(dispatch_get_main_queue()) {
            let image = UIImage(named: "Flag_icon")
            self.mapMarkersManager.addMarkerWithLocation(location, km: -1, markImage: image)
        }
    }

    private func setupMap(){
        let camera = GMSCameraPosition.cameraWithLatitude(52.52356, longitude: 13.45097995, zoom: initialZoom)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = true
        self.mapView.mapType = kGMSTypeNormal
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = self
    }

    private func setupMapMarkers() {
        self.mapMarkersManager = RTMapMarkersManager(mapView: self.mapView)
    }

    private func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 20.0
        locationManager.activityType = CLActivityType.Fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    private func setupTimer(){
        let aSelector:Selector = #selector(RTActiveMapViewController.updateTime)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target:self, selector: aSelector, userInfo: nil, repeats: true)
    }

    private func setupLabels() {
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private func invalidateTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }

    private func drawPath() {
        if let activityToDraw = self.activitiesModel.getCurrentActivityCopy() {
            self.mapMarkersManager.drawPath(activityToDraw)
        }
    }

    private func drawCheckMarks() {
        if let activity = self.activitiesModel.getCurrentActivityCopy() {
            self.mapMarkersManager.redrawMarkers(activity.checkMarks)
        }
        if self.activitiesModel.activityRunning == false {
            self.addEndFlagMarker()
        }
    }

    private func endActivity() {
        if self.activitiesModel.endActivity() {
            self.activitiesModel.saveActivities(RTActivitiesModel.ArchiveURL.path!, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager)
            self.addEndFlagMarker()
        }
        invalidateTimer()
        self.pauseButton.enabled = false
    }

// IBActions

    @IBAction func backTouched(sender: UIButton) {
        if self.activitiesModel.isCurrentActivityDefined() {
            endActivity()
        }
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

        let activityLocation = RTActivityLocation(location: location, timestamp: NSDate().timeIntervalSince1970)

        if self.activitiesModel.addActivityLocation(activityLocation!) {
            self.drawPath()
        }

    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

// Map View Delegate

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let zoom = self.mapView.camera.zoom
        if zoom != lastZoom {
            lastZoom = zoom
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.clear()
                self.drawPath()
                self.drawCheckMarks()
            }
        }
    }

}
