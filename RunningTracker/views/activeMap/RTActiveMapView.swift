//
// Created by MIGUEL MOLDES on 26/11/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps
import RxCocoa
import RxSwift

class RTActiveMapView : UIView {

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

    var mapView : GMSMapView!
    var mapMarkersManager : RTMapMarkersManager!

    let disposable = DisposeBag()

    var model:RTActiveMapViewModel! {
        didSet {
            self.setupMap()
            self.setupMapMarkers()
            self.bind()
            _ = self.refresh()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _ = self.refresh()
    }


    private func setup() {
        setupLabels()
        setupTopBar()
        setupBottomBar()
        addObservers()
    }

    private func bind() {
        model.locationToAnimateVariable.asObservable()
                .subscribe(onNext: {
                    coordinate in
                    self.mapView.animate(toLocation: coordinate)
                })
                .addDisposableTo(disposable)

        model.activityToDrawVariable.asObservable()
                .subscribe(onNext: {
                    activities in
                    if activities.count == 0 {
                        return
                    }
                    self.mapMarkersManager.drawPath(activities[0])
                })
                .addDisposableTo(disposable)

        model.checkMarksVariable.asObservable()
                .subscribe(onNext:{
                    checkMarks in
                    if checkMarks.count == 0 {
                        return
                    }
                    self.mapMarkersManager.redrawMarkers(checkMarks[0])
                })
                .addDisposableTo(disposable)

        model.pauseButtonImageVariable.asObservable()
                .subscribe(onNext:{
                    image in
                    self.pauseButton.setBackgroundImage(image, for: UIControlState())
                })
                .addDisposableTo(disposable)

        model.endFlagLocationVariable.asObservable()
                .subscribe(onNext:{
                    locations in
                    if locations.count == 0 {
                        return
                    }
                    self.addEndFlagMarker(location: locations[0])
                })
                .addDisposableTo(disposable)

        model.chronometerVariable.asObservable()
                .bindTo(self.chronometerLabel.rx.text)
                .addDisposableTo(disposable)

        model.distanceVariable.asObservable()
                .bindTo(self.distanceLabel.rx.text)
                .addDisposableTo(disposable)

        model.paceVariable.asObservable()
                .bindTo(self.paceLabel.rx.text)
                .addDisposableTo(disposable)

    }

    private func setupMap(){
        if self.mapView == nil {
            let camera = GMSCameraPosition.camera(withLatitude: 52.52356, longitude: 13.45097995, zoom: model.initialZoom)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0,y: 0,width: self.mapContainer.frame.size.width, height: self.mapContainer.frame.size.height), camera: camera)
        }
        self.mapView.isMyLocationEnabled = true
        self.mapView.mapType = kGMSTypeNormal
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = self.model
    }

    private func setupMapMarkers() {
        if self.mapMarkersManager == nil {
            self.mapMarkersManager = RTMapMarkersManager(mapView: self.mapView)
        }
    }

    private func setupTopBar() {
        self.topBarView.isUserInteractionEnabled = false
        self.chronometerLabel.adjustsFontSizeToFitWidth = true
    }

    private func setupLabels() {
        self.distanceLabel.numberOfLines = 1
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.lineBreakMode = NSLineBreakMode.byClipping
        self.distanceLabel.text = "0.00"
    }

    private func setupBottomBar() {
        self.bottomBarView.isUserInteractionEnabled = false
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distDescLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker), name: NSNotification.Name(rawValue: "addKMMarker"), object: nil)
    }

    func addMarker(_ notification:Notification) {
        let location = (notification as NSNotification).userInfo!["location"] as! CLLocation
        let index = (notification as NSNotification).userInfo!["km"] as! Int

        DispatchQueue.main.async {
            self.mapMarkersManager.addMarkerWithLocation(location, km: index, markImage: self.model.kmFlagImage)
        }
    }

    private func addEndFlagMarker(location:CLLocation){
        DispatchQueue.main.async {
            self.mapMarkersManager.addMarkerWithLocation(location, km: -1, markImage: self.model.endFlagImage)
        }
    }


//MARK refresh
    private func refresh() -> Bool {
        refreshMap()
        refreshBottomBar()
        refreshTopBar()
        return true
    }

    private func refreshTopBar() {
        let mapFrame = self.mapContainer.frame
        let topFrame = self.topBarView.frame
        let topYPos = mapFrame.origin.y - (topFrame.size.height / 2)
        self.topBarView.frame = CGRect(x: topFrame.origin.x, y: topYPos, width: topFrame.size.width, height: topFrame.size.height)
    }

    private func refreshBottomBar() {
        let mapFrame = self.mapContainer.frame
        let bottomFrame = self.bottomBarView.frame
        let bottomYPos = mapFrame.origin.y + mapFrame.size.height - (bottomFrame.size.height / 2)
        self.bottomBarView.frame = CGRect(x: bottomFrame.origin.x, y: bottomYPos, width: bottomFrame.size.width, height: bottomFrame.size.height)
    }

    private func refreshMap() {
        self.mapView.frame = CGRect(x: 0,y: 0,width: self.mapContainer.frame.size.width, height: self.mapContainer.frame.size.height)
    }


}
