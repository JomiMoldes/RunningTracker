//
// Created by MIGUEL MOLDES on 18/7/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class RTActivitiesViewController : UIViewController {

    var activitiesView:RTActivitiesView {
        get{
            return view as! RTActivitiesView
        }
    }

    var activitiesViewModel:RTActivitiesViewModel!
    let disposable = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        activitiesView.viewModel = activitiesViewModel
        setupBackButton()
        bind()
    }

    func bind() {
        activitiesViewModel.activitySelected
                .subscribe(onNext:{
                    activity in
                    self.activitySelected(activity: activity)
                })
                .addDisposableTo(self.disposable)
    }

    func activitySelected(activity:RTActivity) {
        let activityDoneMap = RTPathDoneViewController(nibName: "RTPathDoneView", bundle: nil)
        activityDoneMap.pathDoneViewModel = RTPathDoneViewModel(model:RTGlobalModels.sharedInstance.activitiesModel, activity: activity)
        self.navigationController!.pushViewController(activityDoneMap, animated:true)
    }

    func setupBackButton() {
        activitiesView.backButtonView.areaButton.addTarget(self, action: #selector(backTouched), for: .touchUpInside)
    }

    func backTouched(_ sender:UIButton){
        self.navigationController!.popViewController(animated: true)
    }

}
