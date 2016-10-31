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

    func addMarkerWithLocation(_ location:CLLocation, km:Int, markImage: UIImage?){
        let icon = UIImageView()
        let maxHeight = CGFloat(getMaxMarkerSize())
        let markerWidth = maxHeight * markImage!.size.width / markImage!.size.height
        icon.frame = CGRect(x: 0, y: 0, width: markerWidth, height: maxHeight)
        icon.image = markImage!

        let marker = GMSMarker(position:location.coordinate)

        if km > -1 {
            let kmLabel = UILabel()
            kmLabel.frame = CGRect(x: 0, y: 2, width: icon.frame.size.width, height: CGFloat(icon.frame.size.height * 0.7))
            kmLabel.textAlignment = .center
            icon.addSubview(kmLabel)

            let labelFont =  UIFont(name: "OpenSans-Semibold", size: 20)
            let stringAttributes = [ NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: labelFont! ]
            let attString = NSAttributedString(string: String(format: "%ld", km), attributes: stringAttributes)
            kmLabel.attributedText = attString
        }
        marker.zIndex = km + 1

        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.iconView = icon

        marker.map = self.mapView
    }

    fileprivate func getMaxMarkerSize() -> Float {
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

    func redrawMarkers(_ markers:[Int:CLLocation]) {
        let image = UIImage(named: "Flag_icon_KM")
        for (km, location) in markers {
            addMarkerWithLocation(location, km: km, markImage: image)
        }
    }

    func drawPath(_ activity:RTActivity) {
        let path = GMSMutablePath()
        let activities = activity.getActivitiesCopy()

        for activityLocation in  activities{
            path.add(activityLocation.location.coordinate)
        }

        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 5.0
        polyline.map = self.mapView
    }

}
