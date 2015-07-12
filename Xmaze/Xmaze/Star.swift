//
//  Star.swift
//  Xmaze
//
//  Created by Phuc Phuong on 7/12/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import Foundation
import SpriteKit

class Star:SKNode {
    
    var starSprite:SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override init() {
        
        super.init()
        starSprite = SKSpriteNode(imageNamed: "Star")
        addChild(starSprite!)
        
        createPhysicsBody()
        
    }
    
    
    init(fromTMXFileWithDict theDict:Dictionary<NSObject, AnyObject> ) {
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int = theX.toInt()!
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int = theY.toInt()!
        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        
        starSprite = SKSpriteNode(imageNamed: "Star")
        addChild(starSprite!)
        
        self.position = CGPoint(x: location.x + (starSprite!.size.width / 2), y: location.y - (starSprite!.size.height / 2))
        
        createPhysicsBody()
    }
    
    
    func createPhysicsBody() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: starSprite!.size.width / 2 )
        
        self.physicsBody?.categoryBitMask = BodyType.star.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.hero.rawValue
        
        self.zPosition = 90
        
    }
    
}