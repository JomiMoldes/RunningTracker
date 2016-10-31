//
// Created by MIGUEL MOLDES on 7/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreImage

class RTInitialViewController:UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var myActivitiesButton: UIButton!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var bestDistanceView: UIView!
    @IBOutlet weak var bestPaceView: UIView!

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceDescLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var paceDescLabel: UILabel!
    @IBOutlet weak var turnOnGPSLabel: UILabel!

    @IBOutlet weak var bestDistanceBGImageView: UIImageView!
    @IBOutlet weak var bestPaceBGImageView: UIImageView!
    @IBOutlet weak var gpsImageView: UIImageView!
    @IBOutlet weak var startViewBGImageView: UIImageView!

    var locationManager : CLLocationManager!
    var activitiesModel : RTActivitiesModel!

    override func viewDidLoad() {
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        super.viewDidLoad()
        setupButtons()
        updateTexts()
        self.turnOnGPSLabel.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startButton.isEnabled = false
        self.startLocation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupWhiteBackgrounds()
        updateTexts()
        updateButtonsLabels()
        updateButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        locationManager = nil
    }

    func setupWhiteBackgrounds() {
        let insetSize = CGFloat(20.0)
        let insets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
        let bgImage = UIImage(named: "white_background")
        self.startViewBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.bestDistanceBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.bestPaceBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
    }

    func updateTexts() {
        self.distanceDescLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true

        let pace = self.activitiesModel.getBestPace()
        let paceString = pace.getMinutes() + ":" + pace.getSeconds()
        self.paceLabel.text = paceString
        let distance = self.activitiesModel.getLongestDistance()
        let distanceString = String(format:"%.2f km", distance / 1000)
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.text = distanceString
        self.turnOnGPSLabel.adjustsFontSizeToFitWidth = true
    }

    func setupButtons(){
        self.myActivitiesButton.titleLabel?.numberOfLines = 1
        let sideInsetsForActivitiesButton = CGFloat(Int(55 * self.view.frame.size.width / 414))
        self.myActivitiesButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: sideInsetsForActivitiesButton, bottom: 0.0, right: sideInsetsForActivitiesButton)
        self.myActivitiesButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.myActivitiesButton.titleLabel?.textAlignment = NSTextAlignment.center

        self.startButton.isEnabled = false
        self.startButton.backgroundColor = UIColor.clear

        let sideInsets = CGFloat(Int(45 * self.view.frame.size.width / 414))
        self.startButton.titleEdgeInsets = UIEdgeInsets(top:15.0, left: sideInsets, bottom: 15.0, right: sideInsets)

        if let bgImage = self.startButton.currentBackgroundImage {
            let rect = CGRect(x: 0, y: 0, width: bgImage.size.width, height: bgImage.size.height)

            UIGraphicsBeginImageContextWithOptions(bgImage.size, true, 0)
            let context = UIGraphicsGetCurrentContext()

            context!.setFillColor(UIColor.white.cgColor)
            context!.fill(rect)
            bgImage.draw(in: rect, blendMode: .luminosity, alpha: 1)

            let newUIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            self.startButton.setBackgroundImage(newUIImage, for: UIControlState.disabled)
        }
    }

    func updateButtons() {
        let button = self.myActivitiesButton
        let insets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        button?.setBackgroundImage(UIImage(named: "white_borders_bg")!.resizableImage(withCapInsets: insets, resizingMode: .stretch), for: UIControlState())
    }

    func updateButtonsLabels() {
        let label = self.startButton.titleLabel!
        if label.frame.size.width > 0 {
            label.shrinkFont()
        }
        let activitiesLabel = self.myActivitiesButton.titleLabel!
        if activitiesLabel.frame.size.width > 0 {
            activitiesLabel.shrinkFont()
        }
    }

    func startLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        switch (CLLocationManager.authorizationStatus()){
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways, .restricted, .denied:
                let alertController = UIAlertController(
                title:"Location Access Disabled",
                        message:"In order to track your paths, please open this app's settings and set location access to 'While using the app'",
                        preferredStyle: .alert)

                let cancelAction = UIAlertAction(title:"Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)

                let openAction = UIAlertAction(title:"Open", style: .default) {
                    (action) in
                    if let url = URL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }
                alertController.addAction(openAction)

                self.present(alertController, animated:true, completion:nil)

                break
            default:
                break
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

//MARK IBActions

    @IBAction func myActivitiesTouched(_ sender: UIButton) {
        let activitiesController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "activitiesView") as? RTActivitiesViewController
        self.navigationController!.pushViewController(activitiesController!, animated:true)
    }

    @IBAction func startTouched(_ sender: UIButton) {
        let mapViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "activeMapView") as? RTActiveMapViewController

        do {
            try self.activitiesModel.startActivity()
        } catch {
            print("the activity was not possible to start")
            return
        }

        self.navigationController!.pushViewController(mapViewController!, animated:true)
    }

// MARK Location Manager

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.startButton.isEnabled = true
        gpsImageView.image = UIImage(named:"GPSgreen.png")
        self.turnOnGPSLabel.isHidden = true
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        self.startButton.isEnabled = false
        gpsImageView.image = UIImage(named:"GPSblack.png")
        self.turnOnGPSLabel.isHidden = false
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
           locationManager.startUpdatingLocation()
        }
    }

}
