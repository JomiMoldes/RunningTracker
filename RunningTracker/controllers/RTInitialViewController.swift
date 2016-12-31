import Foundation
import UIKit
import CoreLocation
import CoreImage
import RxSwift
import RxCocoa

class RTInitialViewController: UIViewController {

    var initialView:RTInitialView {
        get {
            return self.view as! RTInitialView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialView.model = RTInitialViewModel(model:RTGlobalModels.sharedInstance.activitiesModel, locationService: RTLocationService())
        self.initialView.model.permissionsDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initialView.model.startLocation()
        self.initialView.model.updateBestValues()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.initialView.model.killLocation()
    }

//MARK IBActions

    @IBAction func myActivitiesTouched(_ sender: UIButton) {
        let activitiesController = RTActivitiesViewController(nibName: "RTActivitiesView", bundle: nil)
        activitiesController.activitiesViewModel = RTActivitiesViewModel(model:RTGlobalModels.sharedInstance.activitiesModel, notificationCenter: NotificationCenter.default)
        self.navigationController!.pushViewController(activitiesController, animated:true)
    }

    @IBAction func startTouched(_ sender: UIButton) {
        let mapViewController = RTActiveMapViewController(nibName: "RTActiveMapView", bundle: nil)
        mapViewController.viewModel = RTActiveMapViewModel(model:RTGlobalModels.sharedInstance.activitiesModel, locationService: RTLocationService())
        do {
            try RTGlobalModels.sharedInstance.activitiesModel.startActivity()
        } catch {
            print("the activity was not possible to start")
            return
        }

        self.navigationController!.pushViewController(mapViewController, animated:true)
    }

}

extension RTInitialViewController : RTLocationServiceDelegate {

    func shouldChangePermissions() {
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

        DispatchQueue.main.async {
            self.navigationController?.present(alertController, animated: true, completion: nil)
        }

    }

}
