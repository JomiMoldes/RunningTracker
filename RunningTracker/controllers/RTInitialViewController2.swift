import Foundation
import UIKit
import CoreLocation
import CoreImage

class RTInitialViewController2:UIViewController, CLLocationManagerDelegate {

    var initialView:RTInitialView {
        get {
            return self.view as! RTInitialView
        }
    }

    var activitiesModel : RTActivitiesModel!
    var locationManager : CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activitiesModel = RTGlobalModels.sharedInstance.activitiesModel
        self.initialView.model = RTInitialViewModel(model:self.activitiesModel)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startLocation()
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.delegate = nil
        locationManager = nil
    }

// MARK Location Manager

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        self.initialView.model.gpsRunning = true
        DispatchQueue.main.async {
            self.initialView.refresh()
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        self.initialView.model.gpsRunning = false
        DispatchQueue.main.async {
            self.initialView.refresh()
        }
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse){
            locationManager.startUpdatingLocation()
        }
    }



}
