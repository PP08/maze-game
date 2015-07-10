//
//  GameScene.swift
//  maze
//
//  Created by Phuc Phuong on 7/8/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import SpriteKit

enum BodyType:UInt32 {
    case hero = 1
    case boundary = 2
    case sensorUp = 4
    case sensorDown = 8
    case sensorRight = 16
    case sensorLeft = 32
    case pellet = 64
    case enemy = 124
    case boundary2 = 256
    
    
}


class GameScene: SKScene {
    
    var currentSpeed:Float = 5
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode?
    var hero:Hero?
    var useTMXFiles:Bool = false
    
    
    override func didMoveToView(view: SKView) {
        /* initial properties */
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
        /* Setup your scene here */
        
        mazeWorld = childNodeWithName("mazeWorld")
        heroLocation = mazeWorld!.childNodeWithName("StartingPoint")!.position
        
        hero = Hero()
        hero!.position = heroLocation
        mazeWorld!.addChild(hero!)
        hero!.currentSpeed = currentSpeed //wil get replaced later on per level basic
        
        //gestures
        
        let waitAction:SKAction = SKAction.waitForDuration(0.5)
        self.runAction(waitAction, completion:{
            
            let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedRight:"))
            swipeRight.direction = .Right
            view.addGestureRecognizer(swipeRight)
            
            let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedLeft:"))
            swipeLeft.direction = .Left
            view.addGestureRecognizer(swipeLeft)
            
            let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedUp:"))
            swipeUp.direction = .Up
            view.addGestureRecognizer(swipeUp)
            
            let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("swipedDown:"))
            swipeDown.direction = .Down
            view.addGestureRecognizer(swipeDown)
            
            
            }
        )
        
        
        if(useTMXFiles==true){
            println("setup with tmx")
        }else{
            println("setup with SKS")
            setUpBoundaryFromSKS()
        }
        
    }
    
    
    func setUpBoundaryFromSKS(){
        
        mazeWorld!.enumerateChildNodesWithName("boundary"){
            node, stop in
            
            
            
            if let boundary = node as? SKSpriteNode{
                
                println("found boundary")
                let rect:CGRect = CGRect(origin: boundary.position, size: boundary.size)
                let newBoundary:Boundary = Boundary(fromSKSwithRect: rect)
                self.mazeWorld!.addChild(newBoundary)
                newBoundary.position = boundary.position
                boundary.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        hero!.update()
        
    }
    
    
    func swipedRight(sender: UISwipeGestureRecognizer){
        
        hero!.goRight()
    }
    
    func swipedLeft(sender: UISwipeGestureRecognizer){
        
        hero!.goLeft()
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer){
        
        hero!.goUp()
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer){
        
        hero!.goDown()
    }
    
    
}
