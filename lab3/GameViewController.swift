//
//  GameViewController.swift
//  lab3
//
//  Created by Brandon McFarland on 9/28/18.
//  Copyright © 2018 Saminator5. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup game scene
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
}

