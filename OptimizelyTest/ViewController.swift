//
//  ViewController.swift
//  OptimizelyTest
//
//  Created by Malte Schiebelmann on 06.10.14.
//  Copyright (c) 2014 Malte Schiebelmann. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    

    @IBAction func pressMe(sender: AnyObject) {
        
        // Load live variable
        var key = OptimizelyVariableKey.optimizelyKeyWithKey("myKey", defaultNSString: "myValue")
        var liveVariable:String = Optimizely.stringForKey(key)

        // Use the liveVariable
        if(liveVariable == "VarA") {
            var alert:UIAlertView = UIAlertView(title: "AB Test", message: "This alert only shows if liveVariable equals VarA", delegate: self, cancelButtonTitle: "Close")
            alert.show()
        }
        
        // Track custom event
        Optimizely.trackEvent("Pressed Button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

