//
// Created by MIGUEL MOLDES on 22/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class RTActivityPathDoneViewController : UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var backButtonView: RTBackButtonView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var chronometerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var paceDescLabel: UILabel!
    @IBOutlet weak var distDescLabel: UILabel!

    var activity:RTActivity!
    var mapView : GMSMapView!
    var mapMarkersManager : RTMapMarkersManager!

    let initialZoom : Float = 15.0
    var lastZoom : Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupMapMarkers()
        setupBackButton()
        setupTopBar()
        setupBottomBar()
        updateInfo()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawPath()
        self.drawMarkers()
        self.drawEndFlag()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mapView.frame = CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height)

        let mapFrame = self.mapContainer.frame
        let bottomFrame = self.bottomBarView.frame
        let bottomYPos = mapFrame.origin.y + mapFrame.size.height - (bottomFrame.size.height / 2)
        self.bottomBarView.frame = CGRectMake(bottomFrame.origin.x, bottomYPos, bottomFrame.size.width, bottomFrame.size.height)

        let topFrame = self.topBarView.frame
        let topYPos = mapFrame.origin.y - (topFrame.size.height / 2)
        self.topBarView.frame = CGRectMake(topFrame.origin.x, topYPos, topFrame.size.width, topFrame.size.height)
    }

    func setupMap() {
        let activityLocation:RTActivityLocation = activity.getActivitiesCopy()[0]

        let camera = GMSCameraPosition.cameraWithLatitude(activityLocation.location.coordinate.latitude, longitude: activityLocation.location.coordinate.longitude, zoom: initialZoom)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = false
        self.mapView.mapType = kGMSTypeNormal
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = self
    }

    private func setupMapMarkers() {
        self.mapMarkersManager = RTMapMarkersManager(mapView: self.mapView)
    }

    func setupBackButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backTouched))
        self.backButtonView.addGestureRecognizer(gesture)
    }

    func setupTopBar() {
        self.topBarView.userInteractionEnabled = false
        self.chronometerLabel.adjustsFontSizeToFitWidth = true
    }

    func updateInfo() {
        let duration = activity.getDuration()
        let durationString = duration.getHours() + ":" + duration.getMinutes() + ":" + duration.getSeconds()
        self.chronometerLabel.text = durationString

        let pace = activity.getPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()

        let distanceString = String(format:"%.2f", activity.distance / 1000)

        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.text = paceString
        self.distanceLabel.text = distanceString
    }

    func setupBottomBar() {
        self.bottomBarView.userInteractionEnabled = false
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distDescLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true
    }

    func backTouched(sender:UITapGestureRecognizer){
        self.navigationController!.popViewControllerAnimated(true)
    }

    private func drawPath() {
        let path = GMSMutablePath()
        let activities = activity.getActivitiesCopy()
        
        for activityLocation in  activities{
            path.addCoordinate(activityLocation.location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
    }

    private func drawEndFlag() {
        let location = self.activity.getActivitiesCopy().last!.location
        let image = UIImage(named: "Flag_icon_end")
        self.mapMarkersManager.addMarkerWithLocation(location, km: -1, markImage: image)
    }

    private func drawMarkers() {
        self.mapMarkersManager.redrawMarkers(self.activity.checkMarks)
    }

// Map View Delegate

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        let zoom = self.mapView.camera.zoom
        if zoom != lastZoom {
            lastZoom = zoom
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.clear()
                self.mapMarkersManager.drawPath(self.activity)
                self.drawMarkers()
                self.drawEndFlag()
            }
        }
    }
}
