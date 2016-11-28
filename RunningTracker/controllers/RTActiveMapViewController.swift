import Foundation
import UIKit
import CoreLocation
import GoogleMaps

class RTActiveMapViewController : UIViewController {

    var activeMapView : RTActiveMapView {
        get {
            return self.view as! RTActiveMapView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeMapView.model = RTActiveMapViewModel(model:RTGlobalModels.sharedInstance.activitiesModel, locationService: RTLocationService())
        setupBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activeMapView.model.startLocation()
        self.activeMapView.model.setupTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activeMapView.model.killLocation()
        self.activeMapView.model.removeObservers()
    }

    func setupBackButton() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(backTouched))
        activeMapView.backButtonView.addGestureRecognizer(gesture)
    }

    func showStopOptions() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to finish?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title:"No! Keep going!", style: .cancel) {
            (action) in
        }
        alert.addAction(cancelAction)

        let okAction = UIAlertAction(title:"Yes, I'm done.", style: .default) {
            (action) in
            self.activeMapView.model.endActivity()
        }
        alert.addAction(okAction)

        self.present(alert, animated: true, completion:nil)
    }

    func backTouched(_ sender:UITapGestureRecognizer){
        if self.activeMapView.model.model.activityRunning {
            showStopOptions()
            return
        }
        self.navigationController!.popViewController(animated: true)
    }

// IBActions

    @IBAction func stopTouched(_ sender: UIButton) {
        if self.activeMapView.model.model.activityRunning {
            showStopOptions()
        }
    }
    
    @IBAction func pauseTouched(_ sender: UIButton) {
        self.activeMapView.model.pauseTouched()
    }

}
