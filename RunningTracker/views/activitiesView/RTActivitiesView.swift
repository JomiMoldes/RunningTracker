//
// Created by MIGUEL MOLDES on 13/12/16.
// Copyright (c) 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RTActivitiesView : UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButtonView: RTBackButtonView!
    @IBOutlet weak var noActivitiesLabel: UILabel!

    let disposable = DisposeBag()

    weak var viewModel : RTActivitiesViewModel! {
        didSet {
            self.bind()
            self.setupTable()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        noActivitiesLabel.isHidden = viewModel.activities.count > 0
    }

    private func setupTable() {
        tableView.isHidden = viewModel.activities.count == 0
        tableView.register(UINib(nibName:"RTActivityViewCell", bundle:nil), forCellReuseIdentifier: "activityViewCell")
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }

    private func bind() {
        viewModel.deletingActivity.subscribe(onNext:{
                activity in
                self.showActivityIndicator()
                self.needsUpdateConstraints()
            }).addDisposableTo(self.disposable)

        viewModel.activityDeleted.subscribe(onNext:{
                text in
                self.hideActivityIndicator()
            }).addDisposableTo(self.disposable)
    }

    override func removeFromSuperview() {
        self.viewModel.removeObservers()
        super.removeFromSuperview()
    }


}
