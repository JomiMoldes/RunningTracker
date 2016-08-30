//
// Created by MIGUEL MOLDES on 26/8/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import CoreLocation

class RTMapMarkersManager {

    let mapView : GMSMapView

    init?(mapView : GMSMapView) {
        self.mapView = mapView
    }

    func addMarkerWithLocation(location:CLLocation, km:Int, markImage: UIImage?){
        let icon = UIImageView()
        let maxHeight = CGFloat(getMaxMarkerSize())
        let markerWidth = maxHeight * markImage!.size.width / markImage!.size.height
        icon.frame = CGRectMake(0, 0, markerWidth, maxHeight)
        icon.image = markImage!

        let marker = GMSMarker(position:location.coordinate)

        if km > -1 {
            let kmLabel = UILabel()
            kmLabel.frame = CGRectMake(0, 0, icon.frame.size.width, CGFloat(icon.frame.size.height * 0.7))
            kmLabel.textAlignment = .Center
            icon.addSubview(kmLabel)

            let labelFont =  UIFont(name: "OpenSans-Bold", size: 40)
            let stringAttributes = [ NSForegroundColorAttributeName: UIColor.redColor(), NSFontAttributeName: labelFont! ]
            let attString = NSAttributedString(string: String(format: "%ld", km), attributes: stringAttributes)
            kmLabel.attributedText = attString
        }
        marker.zIndex = km + 1

        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.iconView = icon

        marker.map = self.mapView
    }

    private func getMaxMarkerSize() -> Float {
        let zoom = self.mapView.camera.zoom
        let maxZoom : Float = 21
        let minZoom : Float = 2
        let maxSize : Float = 100
        let minSize : Float = 10

        let zoomDif = maxZoom - minZoom
        let sizeDif = maxSize - minSize
        let currentZoomDif = zoom - minZoom

        let maxHeight : Float = minSize + (currentZoomDif * sizeDif / zoomDif)

        return maxHeight
    }

    func redrawMarkers(markers:[Int:CLLocation]) {
        let image = UIImage(named: "Km_icon")
        for (km, location) in markers {
            addMarkerWithLocation(location, km: km, markImage: image)
        }
    }

    func drawPath(activity:RTActivity) {
        let path = GMSMutablePath()
        let activities = activity.getActivitiesCopy()

        for activityLocation in  activities{
            path.addCoordinate(activityLocation.location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
    }

}
