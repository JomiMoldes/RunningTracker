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
    case hour
    case minute
    case second
    case millisecond
}

class RTActiveMapViewController : UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var backButtonView: RTBackButtonView!
    @IBOutlet weak var chronometerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var paceDescLabel: UILabel!
    @IBOutlet weak var distDescLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!

    let initialZoom : Float = 18.0
    var lastZoom : Float = 18.0

    var locationManager : CLLocationManager!
    var locationsHistory : NSMutableArray!
    var activitiesModel: RTActivitiesModel!

    var mapView : GMSMapView!
    var timer : Timer!
    var mapMarkersManager : RTMapMarkersManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        self.setupLabels()
        addObservers()
        setupMap()
        setupMapMarkers()
        setupBackButton()
        setupTopBar()
        setupBottomBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationsHistory = NSMutableArray()
        setupLocationManager()
        setupTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mapView.frame = CGRect(x: 0,y: 0,width: self.mapContainer.frame.size.width, height: self.mapContainer.frame.size.height)
        let mapFrame = self.mapContainer.frame
        let bottomFrame = self.bottomBarView.frame
        let bottomYPos = mapFrame.origin.y + mapFrame.size.height - (bottomFrame.size.height / 2)
        self.bottomBarView.frame = CGRect(x: bottomFrame.origin.x, y: bottomYPos, width: bottomFrame.size.width, height: bottomFrame.size.height)

        let topFrame = self.topBarView.frame
        let topYPos = mapFrame.origin.y - (topFrame.size.height / 2)
        self.topBarView.frame = CGRect(x: topFrame.origin.x, y: topYPos, width: topFrame.size.width, height: topFrame.size.height)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker), name: NSNotification.Name(rawValue: "addKMMarker"), object: nil)
    }

    func setupBackButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backTouched))
        self.backButtonView.addGestureRecognizer(gesture)
    }

    func setupTopBar() {
        self.topBarView.isUserInteractionEnabled = false
        self.chronometerLabel.adjustsFontSizeToFitWidth = true
    }

    func setupBottomBar() {
        self.bottomBarView.isUserInteractionEnabled = false
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distDescLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true
    }

    func addMarker(_ notification:Notification) {
        let location = (notification as NSNotification).userInfo!["location"] as! CLLocation
        let index = (notification as NSNotification).userInfo!["km"] as! Int

        DispatchQueue.main.async {
            let image = UIImage(named: "Flag_icon_KM")
            self.mapMarkersManager.addMarkerWithLocation(location, km: index, markImage: image)
        }
    }

    func addEndFlagMarker(){
        let location = self.activitiesModel.getCurrentActivityCopy()!.getActivitiesCopy().last!.location
        DispatchQueue.main.async {
            let image = UIImage(named: "Flag_icon_end")
            self.mapMarkersManager.addMarkerWithLocation(location!, km: -1, markImage: image)
        }
    }

    fileprivate func setupMap(){
        let camera = GMSCameraPosition.camera(withLatitude: 52.52356, longitude: 13.45097995, zoom: initialZoom)
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0,y: 0,width: self.mapContainer.frame.size.width, height: self.mapContainer.frame.size.height), camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = kGMSTypeNormal
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = self
    }

    fileprivate func setupMapMarkers() {
        self.mapMarkersManager = RTMapMarkersManager(mapView: self.mapView)
    }

    fileprivate func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 20.0
        locationManager.activityType = CLActivityType.fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    fileprivate func setupTimer(){
        let aSelector:Selector = #selector(RTActiveMapViewController.updateTime)
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector: aSelector, userInfo: nil, repeats: true)
    }

    fileprivate func setupLabels() {
        self.distanceLabel.numberOfLines = 1
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.lineBreakMode = NSLineBreakMode.byClipping
        self.distanceLabel.text = "0.00"
    }

    func updateTime(){
        let elapsedTime:TimeInterval = activitiesModel.getElapsedTime()
        let elapsedStr = elapsedTime.getHours() + ":" + elapsedTime.getMinutes() + ":" + elapsedTime.getSeconds()
        self.chronometerLabel.text = elapsedStr

        let metersDone = activitiesModel.getDistanceDone()
        let strKMsDone:String = String(format:"%.2f", metersDone / 1000)

        self.distanceLabel.text = strKMsDone

        let paced:TimeInterval = activitiesModel.getPaceLastKM()
        self.paceLabel.text = paced.getMinutes() + ":" + paced.getSeconds()
    }

    func updatePaceLabel(){
        let currentActivity = self.activitiesModel.getCurrentActivityCopy()!
        let pace = currentActivity.getPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()
        self.paceLabel.text = paceString
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        invalidateTimer()
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func invalidateTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }

    fileprivate func drawPath() {
        if let activityToDraw = self.activitiesModel.getCurrentActivityCopy() {
            self.mapMarkersManager.drawPath(activityToDraw)
        }
    }

    fileprivate func drawCheckMarks() {
        if let activity = self.activitiesModel.getCurrentActivityCopy() {
            self.mapMarkersManager.redrawMarkers(activity.checkMarks)
        }
        if self.activitiesModel.activityRunning == false {
            self.addEndFlagMarker()
        }
    }

    fileprivate func endActivity() {
        if self.activitiesModel.endActivity() {
            showActivityIndicator()
            NotificationCenter.default.addObserver(self, selector: #selector(activitiesSaved), name: NSNotification.Name(rawValue: "activitiesSaved"), object: nil)
            self.activitiesModel.saveActivities(RTActivitiesModel.ArchiveURL.path, storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager2)
            self.addEndFlagMarker()
            updatePaceLabel()
        }
        invalidateTimer()
    }

    func activitiesSaved(_ notification:Notification) {
        hideActivityIndicator()
    }

    func showStopOptions() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to finish?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title:"No! Keep going!", style: .cancel) {
            (action) in
        }
        alert.addAction(cancelAction)

        let okAction = UIAlertAction(title:"Yes, I'm done.", style: .default) {
            (action) in
            self.endActivity()
        }
        alert.addAction(okAction)

        self.present(alert, animated: true, completion:nil)
    }

    func backTouched(_ sender:UITapGestureRecognizer){
        if self.activitiesModel.activityRunning {
            showStopOptions()
            return
        }
        self.navigationController!.popViewController(animated: true)
    }

// IBActions

    @IBAction func stopTouched(_ sender: UIButton) {
        if self.activitiesModel.activityRunning {
            showStopOptions()
        }
    }
    
    @IBAction func pauseTouched(_ sender: UIButton) {
        if !self.activitiesModel.activityRunning {
            return
        }
        if self.activitiesModel.currentActivityPaused {
            self.activitiesModel.resumeActivity()
            let bgImage = UIImage(named: "icon_controls_pause.png")
//            sender.setBackgroundImage(bgImage, forState: UIControlState.Disabled)
//            sender.setBackgroundImage(bgImage, forState: UIControlState.Selected)
//            sender.setBackgroundImage(bgImage, forState: UIControlState.Highlighted)
            sender.setBackgroundImage(bgImage, for: UIControlState())
            setupTimer()
        }else{
            self.activitiesModel.pauseActivity()
            let bgResumeImage = UIImage(named: "icon_controls_play.png")
//            sender.setBackgroundImage(bgResumeImage, forState: UIControlState.Disabled)
//            sender.setBackgroundImage(bgResumeImage, forState: UIControlState.Selected)
//            sender.setBackgroundImage(bgResumeImage, forState: UIControlState.Highlighted)
            sender.setBackgroundImage(bgResumeImage, for: UIControlState())
            invalidateTimer()
        }
    }

// Location Manager

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location:CLLocation = locations[locations.count - 1]

        self.mapView.animate(toLocation: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))

        if !self.activitiesModel.activityRunning {
           return
        }

        let activityLocation = RTActivityLocation(location: location, timestamp: Date().timeIntervalSince1970)

        if self.activitiesModel.addActivityLocation(activityLocation!) {
            self.drawPath()
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

// Map View Delegate

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = self.mapView.camera.zoom
        if zoom != lastZoom {
            lastZoom = zoom
            DispatchQueue.main.async {
                self.mapView.clear()
                self.drawPath()
                self.drawCheckMarks()
            }
        }
    }

}
