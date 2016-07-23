//
// Created by MIGUEL MOLDES on 22/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class RTActivityPathDoneViewController : UIViewController {

    @IBOutlet weak var mapContainer: UIView!

    var activity:RTActivity!
    var mapView : GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        drawPath()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.mapView.frame = CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height)
    }

    func setupMap() {
        let activityLocation:RTActivityLocation = activity.getActivities()[0]

        let camera = GMSCameraPosition.cameraWithLatitude(activityLocation.location.coordinate.latitude, longitude: activityLocation.location.coordinate.longitude, zoom: 15)
        self.mapView = GMSMapView.mapWithFrame(CGRectMake(0,0,self.mapContainer.frame.size.width, self.mapContainer.frame.size.height), camera: camera)
        self.mapView.myLocationEnabled = false
        self.mapView.mapType = kGMSTypeSatellite
        mapContainer.addSubview(self.mapView)
    }

    func drawPath() {
        let path = GMSMutablePath()
        let activities = activity.getActivities()
        
        for activityLocation in  activities{
            path.addCoordinate(activityLocation.location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
    }

    //IBActions

    @IBAction func backTouched(sender: UIButton) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
