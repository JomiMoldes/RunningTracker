//
//  ViewController.swift
//  RunningTracker
//
//  Created by MIGUEL MOLDES on 7/7/16.
//  Copyright © 2016 MIGUEL MOLDES. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let storyBoard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewcontroller = storyBoard.instantiateViewControllerWithIdentifier("InitialView") as? RTInitialViewController

//        self.presentViewController(initialViewcontroller, animated: true, completion: nil)
        self.navigationController?.pushViewController(initialViewcontroller!, animated: true )
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

