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

    var activity:RTActivity!
    var mapView : GMSMapView!
    var mapMarkersManager : RTMapMarkersManager!

    let initialZoom : Float = 15.0
    var lastZoom : Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupMapMarkers()
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
    }

    func setupMap() {
        let activityLocation:RTActivityLocation = activity.getActivitiesCopy()[0]

        let camera = GMSCameraPosition.cameraWithLatitude(activityLocation.location.coordinate.latitude, longitude: activityLocation.location.coordinate.longitude, zoom: initialZoom)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = false
        self.mapView.mapType = kGMSTypeSatellite
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = self
    }

    private func setupMapMarkers() {
        self.mapMarkersManager = RTMapMarkersManager(mapView: self.mapView)
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
        let image = UIImage(named: "Flag_icon")
        self.mapMarkersManager.addMarkerWithLocation(location, km: -1, markImage: image)
    }

    private func drawMarkers() {
        self.mapMarkersManager.redrawMarkers(self.activity.checkMarks)
    }

//IBActions

    @IBAction func backTouched(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
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
