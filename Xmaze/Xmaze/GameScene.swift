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
    case star = 64
    case enemy = 124
    case boundary2 = 256
    
    
}


class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate{
    
    var currentSpeed:Float = 5
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode?
    var hero:Hero?
    var useTMXFiles:Bool = false
    var heroIsDead:Bool = false
    var starsAcquired:Int = 0
    var starsTotal:Int = 0
    
    
    
    override func didMoveToView(view: SKView) {
        /* initial properties */
        
        self.backgroundColor = SKColor.blackColor()
        view.showsPhysics = true
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        if(useTMXFiles == true) {
            
            println("setup with tmx")
            
            self.enumerateChildNodesWithName("*"){
                node, stop in
                
                node.removeFromParent()
                
            }
            
            mazeWorld = SKNode()
            addChild(mazeWorld!)
            
            
        } else {
            
            mazeWorld = childNodeWithName("mazeWorld")
            heroLocation = mazeWorld!.childNodeWithName("StartingPoint")!.position
        }
        
        
        
        /* Setup your scene here */
        
        
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
        
        
        /*set up based on TMX or SKS*/
        
        if(useTMXFiles==false){
            
            setUpBoundaryFromSKS()
            setUpStarsFromSKS()
            
        } else {
            
            parseTMXFileWithName("Maze")
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
    
    
    
    func setUpStarsFromSKS(){
        
        mazeWorld!.enumerateChildNodesWithName("star"){
            node, stop in
            
            
            
            if let star = node as? SKSpriteNode{
                
                let newStar:Star = Star()
                self.mazeWorld!.addChild(newStar)
                newStar.position = star.position
                
                self.starsTotal++
                println(self.starsTotal)
                
                star.removeFromParent()
                
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
        
        if(heroIsDead == false){
            
            hero!.update()
 
        }else{
            
            hero!.position = heroLocation
            heroIsDead = false
        }
        
        
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
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask){
            
        case BodyType.hero.rawValue | BodyType.star.rawValue:
            
            if let star = contact.bodyA.node as? Star {
                
                
                star.removeFromParent()
                starsAcquired++
                
            }else if let star = contact.bodyB.node as? Star {
                
                
                star.removeFromParent()
                
            }
            
            
            starsAcquired++
            
            if (starsAcquired == starsTotal) {
                
                println("got all the stars")
            }
            
        default:
            return
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask){
            
        case BodyType.hero.rawValue | BodyType.boundary.rawValue:
            println("is not touching the wall")
            
            
        default:
            return
        }
        
    }
    
    
    func parseTMXFileWithName(name:NSString) {
        
        let path:String = NSBundle.mainBundle().pathForResource(name as String, ofType: "tmx")!
        let data:NSData = NSData(contentsOfFile: path)!
        let parser:NSXMLParser = NSXMLParser(data: data)
         
        parser.delegate = self
        parser.parse()
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        
        if (elementName == "object") {
            
            let type:AnyObject? = attributeDict["type"]
            if (type as? String == "Boundary") {
                
                let newBoundary:Boundary = Boundary(theDict: attributeDict)
                mazeWorld!.addChild(newBoundary)
                
                
            } else if (type as? String == "Portal") {
                
                let theName:String = attributeDict["name"] as AnyObject? as! String
                
                if (theName == "StartingPoint") {
                    
                    let theX:String = attributeDict["x"] as AnyObject? as! String
                    let x:Int = theX.toInt()!
                    
                    let theY:String = attributeDict["y"] as AnyObject? as! String
                    let y:Int = theY.toInt()!
                    
                    
                    hero!.position = CGPoint(x: x, y: y * -1)
                    heroLocation = hero!.position
             
                }
                
                
            }
            
            
        }

    }
    
    
    override func didSimulatePhysics() {
        
        if (heroIsDead == false ) {
            
            self.centerOnNode(hero!)
            
        }
    }
    
    func centerOnNode(node:SKNode) {
        
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: mazeWorld!)
        mazeWorld!.position = CGPoint(x: mazeWorld!.position.x - cameraPositionInScene.x, y: mazeWorld!.position.y - cameraPositionInScene.y)
    }
}
