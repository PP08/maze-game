//
//  Boundary.swift
//  maze
//
//  Created by Phuc Phuong on 7/8/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import Foundation
import SpriteKit

class Boundary:SKNode {
    
    
    /* properties*/
    
    
    
    required init(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    init (fromSKSwithRect rect:CGRect){
        super.init()
        createBoundary(rect)
    }
    
    func createBoundary(rect:CGRect){
        let shape = SKShapeNode(rect: rect, cornerRadius: 19)
        shape.fillColor = SKColor.clearColor()
        shape.strokeColor = SKColor.whiteColor()
        shape.lineWidth = 1
        
        addChild(shape)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: rect.size)
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = BodyType.boundary.rawValue
        self.physicsBody!.friction = 0
        self.physicsBody!.allowsRotation = false
        
        self.zPosition = 100
    }
    
}