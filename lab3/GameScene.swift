//
//  GameScene.swift
//  lab3
//
//  Created by Brandon McFarland on 9/26/18.
//  Copyright © 2018 Saminator5. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //@IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
    }
    
    // MARK: View Hierarchy Functions
    //let goal = SKSpriteNode()
    let goal = SKSpriteNode(imageNamed: "goal")
    let left = SKSpriteNode()
    let right = SKSpriteNode()
    let top = SKSpriteNode()
    let bottom = SKSpriteNode()
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Light")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.green
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // add the goal
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        self.addGoalAtPoint(CGPoint(x: size.width * randNumber, y: size.height * randNumber))
        
        // add the ball
        self.addSprite()
        
        self.addScore()
        
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    // Code for the ball
    func addSprite(){
        let spriteA = SKSpriteNode(imageNamed: "ball")
        spriteA.name = "ball";
        
        spriteA.size = CGSize(width:size.width*0.15,height:size.height * 0.1)
        
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        spriteA.position = CGPoint(x: size.width * randNumber, y: size.height * randNumber)
    
        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
        spriteA.physicsBody?.restitution = 0
        spriteA.physicsBody?.isDynamic = true
        spriteA.physicsBody?.contactTestBitMask = 0x00000001
        spriteA.physicsBody?.collisionBitMask = 0x00000001
        spriteA.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(spriteA)
    }

    func addGoalAtPoint(_ point:CGPoint){
        goal.size = CGSize(width:size.width*0.15,height:size.height * 0.1)
        goal.position = point
        
        goal.physicsBody = SKPhysicsBody(rectangleOf:goal.size)
        goal.physicsBody?.contactTestBitMask = 0x00000001
        goal.physicsBody?.collisionBitMask = 0x00000001
        goal.physicsBody?.categoryBitMask = 0x00000001
        goal.physicsBody?.isDynamic = true
        goal.physicsBody?.pinned = true
        goal.physicsBody?.allowsRotation = false
        
        self.addChild(goal)
    }
    
    // Create the game boundaries
    func addSidesAndTop(){
//        let left = SKSpriteNode()
//        let right = SKSpriteNode()
//        let top = SKSpriteNode()
//        let bottom = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bottom.size = CGSize(width:size.width,height:size.height*0.1)
        bottom.position = CGPoint(x:size.width*0.5, y:0)
        
        for obj in [left,right,top, bottom]{
            obj.color = UIColor.white
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // add a new ball
        self.addSprite()
    }
    
    // Check for contact between sprites
    func didBegin(_ contact: SKPhysicsContact) {
        // Check with contact with out of bounds lines
        if contact.bodyA.node == left || contact.bodyB.node == left ||  contact.bodyA.node == right || contact.bodyB.node == right ||  contact.bodyA.node == top || contact.bodyB.node == top || contact.bodyA.node == bottom || contact.bodyB.node == bottom {
            // remove the ball and decrement score by 1 if score > 0
            if let child = self.childNode(withName: "ball") as? SKSpriteNode {
                if self.score > 0 {
                    self.score -= 1
                }
                child.removeFromParent()
            }
        }
        // Check for contact with goal
        if contact.bodyA.node == goal || contact.bodyB.node == goal {
            self.score += 1
            if let child = self.childNode(withName: "ball") as? SKSpriteNode {
                child.removeFromParent()
            }
            
        }
        
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    // Create a random number
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}

