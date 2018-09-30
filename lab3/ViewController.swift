//
//  ViewController.swift
//  lab3
//
//  Created by Samuel Lefcourt on 9/25/18.
//  Copyright © 2018 Saminator5. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var prevSteps: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tillGoal: UILabel!
    @IBOutlet weak var goal1: UILabel! {
        didSet {
            goal1.text = "0"
        }
    }
    @IBOutlet weak var currentActivity: UIImageView!
    @IBOutlet weak var gameStart: UIButton!
    
    let activityManager = CMMotionActivityManager()
    let customQueue = OperationQueue()
    let pedometer = CMPedometer()
    let startOfDay = NSCalendar.current.startOfDay(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
//        all textfield methods dont work unless below is included for some reason
        textField.delegate = self
//        make keyboard numpad type
        self.textField.keyboardType = UIKeyboardType.numberPad

//        tracks type of motion
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: customQueue)
            { (activity:CMMotionActivity?) -> Void in
                DispatchQueue.main.async {
                    if (activity!.unknown) {
//                        self.currentActivity.text = "Activity: Unknown"
                        self.currentActivity.image = UIImage(named: "Image-5")
                    }
                    if (activity!.stationary) {
//                        self.currentActivity.text = "Activity: Stationary"
                        self.currentActivity.image = UIImage(named: "Image-6")
                    }
                    if (activity!.walking) {
//                        self.currentActivity.text = "Activity: Walking"
                        self.currentActivity.image = UIImage(named: "Image")
                    }
                    if (activity!.running) {
//                        self.currentActivity.text = "Activity: Running"
                        self.currentActivity.image = UIImage(named: "Image-2")
                    }
                    if (activity!.automotive) {
//                        self.currentActivity.text = "Activity: In Car"
                        self.currentActivity.image = UIImage(named: "Image-4")
                    }
                    if (activity!.cycling) {
//                        self.currentActivity.text = "Activity: Cycling"
                        self.currentActivity.image = UIImage(named: "Image-1")
                    }
                    //        check if today's steps has reached the goal, difference now is that game time button does not show up immediately
                    if(Int(self.tillGoal.text!)! >= Int(self.goal1.text!)!){
                        DispatchQueue.main.async{
                            self.gameStart.isHidden = false
                        }
                        
                    }
                    else {
                        self.gameStart.isHidden = true
                    }
                }
            }
            
        }
//        load from user_defaults if possible
        if(isKeyPresentInUserDefaults(key: "goal")) {
            let temp = UserDefaults.standard.string(forKey: "goal")
            if(temp! == "") {
                goal1.text = "0"
            }
            else {
                goal1.text = UserDefaults.standard.string(forKey: "goal")
            }

        }
//        used for step counting
        if CMPedometer.isStepCountingAvailable(){
            //calculates number of steps real time
            pedometer.startUpdates(from: startOfDay, withHandler: {(data,error) in
                if let pedData = data {
                    DispatchQueue.main.async {
                        self.tillGoal.text = "\(pedData.numberOfSteps)"

                    }
                }

            })
        }
            //this causes pedometer to stop counting steps immediately, should be used elsewhere or not at all
//        if CMPedometer.isStepCountingAvailable(){
//            self.pedometer.stopUpdates()
//        }
        

        let from = startOfDay.addingTimeInterval(-60*60*24)
        self.pedometer.queryPedometerData(from: from, to: startOfDay)
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
//    closes text field numpad when tapped outside of
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        //can swap end editing with textfield resign first responder
        if(textField.text != "") {
            goal1.text = textField.text
        }
        UserDefaults.standard.set(self.goal1.text, forKey: "goal")
    }
    

    
//    check if goal exists from being saved
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
   

}


