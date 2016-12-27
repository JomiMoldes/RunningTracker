//
// Created by MIGUEL MOLDES on 7/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RxCocoa
import RxSwift

class RTPathDoneView : UIView {

    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var backButtonView: RTBackButtonView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var chronometerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var paceDescLabel: UILabel!
    @IBOutlet weak var distDescLabel: UILabel!

    weak var model:RTPathDoneViewModel! {
        didSet {
            self.setupMap()
            self.setupMarkersManager()
            self.bind()
            self.updateLabels()
            self.redrawPath()
        }
    }

    var markersManager:RTMapMarkersManager!
    var mapView:GMSMapView!
    let disposable = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = CGRect(x: 0,y: 0,
                width: mapContainer.frame.size.width, height: mapContainer.frame.size.height)
    }

    private func setup() {
        setupTopBar()
        setupBottomBar()
    }

    private func setupMarkersManager() {
        if markersManager == nil {
            markersManager = RTMapMarkersManager(mapView:mapView)
        }
    }

    private func setupMap(){
        let activityLocation:RTActivityLocation = model.activity.getActivitiesCopy()[0]
        if self.mapView == nil {
            let camera = GMSCameraPosition.camera(withLatitude: activityLocation.location.coordinate.latitude, longitude: activityLocation.location.coordinate.longitude, zoom: model.initialZoom)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0,y: 0,width: self.mapContainer.frame.size.width, height: self.mapContainer.frame.size.height), camera: camera)
        }

        self.mapView.isMyLocationEnabled = false
        self.mapView.mapType = kGMSTypeNormal
        mapContainer.addSubview(self.mapView)
        self.mapView.delegate = model
    }

    private func setupTopBar() {
        self.topBarView.isUserInteractionEnabled = false
        self.chronometerLabel.adjustsFontSizeToFitWidth = true
    }

    private func setupBottomBar() {
        self.bottomBarView.isUserInteractionEnabled = false
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distDescLabel.adjustsFontSizeToFitWidth = true
        self.paceLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true
    }

    private func bind() {
        model.zoomChanged
            .subscribe(onNext:{
                zoom in
                self.redrawPath()
            })
            .addDisposableTo(self.disposable)
    }

    private func updateLabels() {
        distanceLabel.text = model.distance
        paceLabel.text = model.pace
        chronometerLabel.text = model.chronometer
    }

    private func redrawPath() {
        markersManager.redrawMarkers(model.checkMarks)
        markersManager.drawPath(model.activity)

        let location = model.activity.getActivitiesCopy().last!.location
        let image = UIImage(named: "Flag_icon_end")
        markersManager.addMarkerWithLocation(location!, km: -1, markImage: image)
    }

}
