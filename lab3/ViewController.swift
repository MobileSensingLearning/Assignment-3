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

    @IBOutlet weak var prevSteps: UILabel!
    @IBOutlet weak var todaySteps: UILabel!
    let activityManager = CMMotionActivityManager()
    let customQueue = OperationQueue()
    let pedometer = CMPedometer()
    let startOfDay = NSCalendar.current.startOfDay(for: Date())
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: customQueue)
            { (activity:CMMotionActivity?) -> Void in
//                print("%@", activity!.description)
            }
            
        }
        
        if CMPedometer.isStepCountingAvailable(){
            //calculates number of steps real time
            pedometer.startUpdates(from: startOfDay, withHandler: {(data,error) in
                if let pedData = data {
                    DispatchQueue.main.async {
                        self.todaySteps.text = "\(pedData.numberOfSteps)"
                    }
                }

            })
        }
            //this causes pedometer to stop counting steps immediately, should be used elsewhere or not at all
//        if CMPedometer.isStepCountingAvailable(){
//            self.pedometer.stopUpdates()
//        }
        
        let now = NSDate()
        let from = now.addingTimeInterval(-60*60*24)
        
        self.pedometer.queryPedometerData(from: from as Date, to: now as Date)
        {(pedData: CMPedometerData?, error: Error?) -> Void in
            if let unwrappedPedData = pedData{
                let aggr_string = """
                \(unwrappedPedData.numberOfSteps)
                """
                DispatchQueue.main.async(){
                    self.prevSteps.text = aggr_string;
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


