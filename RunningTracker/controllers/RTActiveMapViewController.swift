import Foundation
import UIKit

class RTActiveMapViewController : UIViewController {

    var activeMapView : RTActiveMapView {
        get {
            return self.view as! RTActiveMapView
        }
    }

    var viewModel:RTActiveMapViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activeMapView.model = self.viewModel
        setupBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.startLocation()
        self.viewModel.setupTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.killLocation()
        self.viewModel.removeObservers()
    }

    private func setupBackButton() {
        activeMapView.backButtonView.areaButton.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
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

        self.navigationController!.present(alert, animated: true, completion:nil)
    }

    func backTouched(_ sender:UIButton){
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
        self.viewModel.pauseTouched()
    }

}
