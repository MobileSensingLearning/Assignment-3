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
    @IBOutlet weak var todaySteps: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tillGoal: UILabel!
    @IBOutlet weak var goal1: UILabel! {
        didSet {
            goal1.text = "\(filler)"
        }
    }
    @IBOutlet weak var goal2: UILabel! {
        didSet {
            goal2.text = "\(filler)"
        }
    }
    @IBOutlet weak var currentActivity: UILabel!
    @IBOutlet weak var gameStart: UIButton!
    
    let activityManager = CMMotionActivityManager()
    let customQueue = OperationQueue()
    let pedometer = CMPedometer()
    let startOfDay = NSCalendar.current.startOfDay(for: Date())
    let filler = 0
    
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
                        self.currentActivity.text = "Activity: Unknown"
                    }
                    if (activity!.stationary) {
                        self.currentActivity.text = "Activity: Stationary"
                    }
                    if (activity!.walking) {
                        self.currentActivity.text = "Activity: Walking"
                    }
                    if (activity!.running) {
                        self.currentActivity.text = "Activity: Running"
                    }
                    if (activity!.automotive) {
                        self.currentActivity.text = "Activity: In Car"
                    }
                    if (activity!.cycling) {
                        self.currentActivity.text = "Activity: Cycling"
                    }
                }
            }
            
        }
        
//        load from user_defaults if possible
        if(isKeyPresentInUserDefaults(key: "goal")) {
            let temp = UserDefaults.standard.string(forKey: "goal")
            if(temp! == "") {
                goal1.text = "0"
                goal2.text = "0"
            }
            else {
                goal1.text = UserDefaults.standard.string(forKey: "goal")
                goal2.text = UserDefaults.standard.string(forKey: "goal")
            }

        }
//        used for step counting
        if CMPedometer.isStepCountingAvailable(){
            //calculates number of steps real time
            pedometer.startUpdates(from: startOfDay, withHandler: {(data,error) in
                if let pedData = data {
                    DispatchQueue.main.async {
                        self.todaySteps.text = "\(pedData.numberOfSteps)"
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
            goal2.text = textField.text
        }

//        check if today's steps has reached the goal
        if(Int(todaySteps.text!)! >= Int(goal1.text!)!){
            DispatchQueue.main.async{
                self.gameStart.isHidden = false
            }
            
        }
        else {
            gameStart.isHidden = true
        }
        print(Int(todaySteps.text!)!)
        UserDefaults.standard.set(self.goal1.text, forKey: "goal")
    }
//    check if goal exists from being saved
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
   

}


