//
//  RTInitialView.swift
//  RunningTracker
//
//  Created by MIGUEL MOLDES on 13/11/16.
//  Copyright © 2016 MIGUEL MOLDES. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class RTInitialView : UIView {

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

    private let disposeBag = DisposeBag()

    var refreshedAfterGPS : Bool = false

    var model:RTInitialViewModel! {
        didSet {
            self.bind()
            _ = self.refresh()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _ = self.refresh()
    }

    private func bind() {
        _ = self.model.gpsRunningVariable.asObservable()
                .subscribe(onNext: { active in
                    self.refreshedAfterGPS = self.refresh()
                })

        self.model.distanceVariable.asObservable()
                .bindTo(self.distanceLabel.rx.text)
                .addDisposableTo(self.disposeBag)

        self.model.paceVariable.asObservable()
                .bindTo(self.paceLabel.rx.text)
                .addDisposableTo(self.disposeBag)

        self.model.gpsRunningVariable.asObservable()
                .bindTo(self.startButton.rx.isEnabled)
                .addDisposableTo(self.disposeBag)

        self.model.gpsRunningVariable.asObservable()
                .bindTo(self.turnOnGPSLabel.rx.isHidden)
                .addDisposableTo(self.disposeBag)

        self.model.gpsImageVariable.asObservable()
                .bindTo(self.gpsImageView.rx.image)
                .addDisposableTo(self.disposeBag)

    }

    private func setup(){
        setupButtons()
        setupWhiteBackgrounds()
        setupLabels()
    }

    private func setupButtons(){
        self.myActivitiesButton.titleLabel?.numberOfLines = 1
        let sideInsetsForActivitiesButton = CGFloat(Int(55 * self.frame.size.width / 414))
        self.myActivitiesButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: sideInsetsForActivitiesButton, bottom: 0.0, right: sideInsetsForActivitiesButton)
        self.myActivitiesButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.myActivitiesButton.titleLabel?.textAlignment = NSTextAlignment.center

        self.startButton.isEnabled = false
        self.startButton.backgroundColor = UIColor.clear

        let sideInsets = CGFloat(Int(45 * self.frame.size.width / 414))
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

    private func setupWhiteBackgrounds() {
        let insetSize = CGFloat(20.0)
        let insets = UIEdgeInsets(top: insetSize, left: insetSize, bottom: insetSize, right: insetSize)
        let bgImage = UIImage(named: "white_background")
        self.startViewBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.bestDistanceBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.bestPaceBGImageView.image = bgImage!.resizableImage(withCapInsets: insets, resizingMode: .stretch)
    }

    private func refresh() -> Bool {
        updateButtons()
        updateButtonsLabels()
        return true
    }

    private func setupLabels() {
        self.distanceDescLabel.adjustsFontSizeToFitWidth = true
        self.paceDescLabel.adjustsFontSizeToFitWidth = true
        self.distanceLabel.adjustsFontSizeToFitWidth = true
        self.turnOnGPSLabel.adjustsFontSizeToFitWidth = true
    }

    private func updateButtons() {
        let button = self.myActivitiesButton
        let insets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        button?.setBackgroundImage(UIImage(named: "white_borders_bg")!.resizableImage(withCapInsets: insets, resizingMode: .stretch), for: UIControlState())
    }

    private func updateButtonsLabels() {
        let label = self.startButton.titleLabel!
        if label.frame.size.width > 0 {
            label.shrinkFont()
        }
        let activitiesLabel = self.myActivitiesButton.titleLabel!
        if activitiesLabel.frame.size.width > 0 {
            activitiesLabel.shrinkFont()
        }
    }
    
    
    
}
