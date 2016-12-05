//
// Created by MIGUEL MOLDES on 26/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import CoreLocation
import GoogleMaps

class RTActiveMapViewModel : NSObject, RTLocationServiceDelegate, GMSMapViewDelegate {

    let model:RTActivitiesModel!
    var locationManager:RTLocationServiceProtocol?
    var locationManagerStarted = false
    var locationToAnimateVariable = Variable(CLLocationCoordinate2D())
    var activityToDrawVariable = Variable<[RTActivity]>([])
    var checkMarksVariable = Variable<[[Int:CLLocation]]>([])
    var endFlagLocation : CLLocation?
    var endFlagLocationVariable = Variable<[CLLocation]>([])
    var drawMapVariable = Variable<Bool>(false)
    let initialZoom : Float = 18.0
    var lastZoomVariable = Variable<Float>(18.0)
    var distanceVariable = Variable<String>("")
    var paceVariable = Variable<String>("")
    var chronometerVariable = Variable<String>("")
    var showActivityIndicatorVariable = Variable<Bool>(false)
    var pauseButtonImageVariable = Variable(UIImage(named: "icon_controls_pause.png"))
    var timer : Timer!
    var endFlagImage : UIImage? {
        get {
            return UIImage(named: "Flag_icon_end")
        }
    }
    var kmFlagImage : UIImage? {
        get {
            return UIImage(named: "Flag_icon_KM")
        }
    }

    let disposable = DisposeBag()

    init?(model:RTActivitiesModel, locationService: RTLocationServiceProtocol){
        self.model = model
        self.locationManager = locationService
        super.init()
    }

    func startLocation() {
        locationManager?.delegate = self
        locationManager?.requestPermissions()
        locationManagerStarted = true
    }

    func setupTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector: #selector(tickTimer), userInfo: nil, repeats: true)
    }

    @objc func tickTimer() {
        let elapsedTime:TimeInterval = model.getElapsedTime()
        let elapsedStr = elapsedTime.getHours() + ":" + elapsedTime.getMinutes() + ":" + elapsedTime.getSeconds()
        self.chronometerVariable.value = elapsedStr

        let metersDone = model.getDistanceDone()
        let strKMsDone:String = String(format:"%.2f", metersDone / 1000)
        self.distanceVariable.value = strKMsDone

        let paced:TimeInterval = model.getPaceLastKM()
        self.paceVariable.value = paced.getMinutes() + ":" + paced.getSeconds()
    }

    func killLocation() {
        locationManagerStarted = false
        locationManager?.delegate = nil
        locationManager = nil
    }

    func endActivity() {
        if self.model.endActivity() {
            showActivityIndicatorVariable.value = true
            NotificationCenter.default.addObserver(self, selector: #selector(activitiesSaved), name: NSNotification.Name(rawValue: "activitiesSaved"), object: nil)
            _ = self.model.saveActivities(getSavingPath(), storeManager: RTGlobalModels.sharedInstance.storeActivitiesManager)
            addEndFlagMarker()
            setFinalPaceLabel()
        }
        invalidateTimer()
    }

    func getSavingPath() -> String {
        return RTActivitiesModel.ArchiveURL.path
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func pauseTouched() {
        if !self.model.activityRunning {
            return
        }
        if self.model.currentActivityPaused {
            self.model.resumeActivity()
            self.pauseButtonImageVariable.value = UIImage(named: "icon_controls_pause.png")
            setupTimer()
        }else{
            self.model.pauseActivity()
            self.pauseButtonImageVariable.value = UIImage(named: "icon_controls_play.png")
            invalidateTimer()
        }
    }

    private func setFinalPaceLabel() {
        if let currentActivity = self.model.getCurrentActivityCopy() {
            let pace = currentActivity.getPace()
            self.paceVariable.value = pace.getMinutes() + ":" + pace.getSeconds()
        }
    }

    @objc private func activitiesSaved(_ notification:Notification) {
        showActivityIndicatorVariable.value = false
    }

    private func invalidateTimer(){
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }

    private func drawNewPath() {
        if let activityToDraw = self.model.getCurrentActivityCopy() {
            self.activityToDrawVariable.value = [activityToDraw]
        }
    }

    private func drawCheckMarks() {
        if let activity = self.model.getCurrentActivityCopy() {
            self.checkMarksVariable.value = [activity.checkMarks]
        }
        if self.model.activityRunning == false {
            self.addEndFlagMarker()
        }
    }

    private func addEndFlagMarker() {
        guard let activity = self.model.getCurrentActivityCopy() else {
            return
        }
        guard let activityLocation = activity.getActivitiesCopy().last else {
            return
        }
        self.endFlagLocationVariable.value = [activityLocation.location]
    }

//MARK  RTLocationServiceDelegate

    func didUpdateLocation(location:CLLocation) {
        self.locationToAnimateVariable.value = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)

        if !self.model.activityRunning {
            return
        }

        let activityLocation = RTActivityLocation(location: location, timestamp: self.model.getNow())

        if self.model.addActivityLocation(activityLocation!) {
            self.drawNewPath()
        }
    }

//MARK GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let zoom = mapView.camera.zoom
        if zoom != self.lastZoomVariable.value {
            self.lastZoomVariable.value = zoom
            DispatchQueue.main.async {
                mapView.clear()
                self.drawNewPath()
                self.drawCheckMarks()
            }
        }
    }

}
