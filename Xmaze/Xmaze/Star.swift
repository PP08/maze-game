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
        starSprite = SKSpriteNode(imageNamed: "star")
        addChild(starSprite!)
        
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