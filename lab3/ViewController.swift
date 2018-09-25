//
//  ViewController.swift
//  lab3
//
//  Created by Samuel Lefcourt on 9/25/18.
//  Copyright © 2018 Saminator5. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let activityManager = CMMotionActivityManager()
    let customQueue = OperationQueue()
    let pedometer = CMPedometer()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: customQueue)
            { (activity:CMMotionActivity?) -> Void in
                NSLog("%@", activity!.description)
            }
            
        }
        
        if CMPedometer.isStepCountingAvailable(){
            pedometer.startUpdates(from: Date())
            {(pedData: CMPedometerData?, error: Error?) -> Void in
                print("%@", pedData?.description)
            }
        }
        
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.stopUpdates()
        }
        
        let now = Date()
        let from = now.addingTimeInterval(-60*60*24)
        
        self.pedometer.queryPedometerData(from: from, to: now as Date)
        {(pedData: CMPedometerData?, error: Error?) -> Void in
            if let unwrappedPedData = pedData{
            let aggr_string = """
            Steps: \(unwrappedPedData.numberOfSteps) \n
            Distance \(unwrappedPedData.distance)
                Floors: \(unwrappedPedData.floorsAscended?.intValue)
            """
            
            DispatchQueue.main.async(){
                 // self.activityLabel.text = aggr_string
            }
            
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.stopActivityUpdates()
        }
        super.viewWillDisappear(animated)
    }
    
   

}


