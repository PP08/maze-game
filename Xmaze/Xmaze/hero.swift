//
//  Hero.swift
//  maze
//
//  Created by Phuc Phuong on 7/8/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import Foundation
import SpriteKit


enum Direction {
    case Up, Down, Right, Left, None
}


enum DesiredDirection {
    case Up, Down, Right, Left, None
}





class Hero:SKNode {
    
    
    /* properties*/
    
    var currentSpeed:Float = 5
    var currentDirection = Direction.Right
    var desiredDirection = DesiredDirection.None
    
    var objectSprite:SKSpriteNode?
    
    required init(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override init (){
        
        super.init()
        println("hero was added")
        
        objectSprite = SKSpriteNode(imageNamed: "hero")
        addChild(objectSprite!)
        
        
        let largerSize:CGSize = CGSize(width: objectSprite!.size.width * 1.2, height: objectSprite!.size.height * 1.2)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: largerSize)
        
        self.physicsBody!.friction = 0
        self.physicsBody!.dynamic = true // true keep the object within boundaries better
        
        self.physicsBody!.restitution = 0 // bouncy
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.affectedByGravity = false
        
        
        self.physicsBody!.categoryBitMask = BodyType.hero.rawValue
        //self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = BodyType.boundary.rawValue
        
    }
    
    func update(){
        
        switch currentDirection {
            
        case .Right:
            self.position = CGPoint(x: self.position.x + CGFloat(currentSpeed), y: self.position.y)
            objectSprite!.zRotation = CGFloat( degreesToRadians(-90) )
        case .Left:
            self.position = CGPoint(x: self.position.x - CGFloat(currentSpeed), y: self.position.y)
            objectSprite!.zRotation = CGFloat( degreesToRadians(90) )
        case .Up:
            self.position = CGPoint(x: self.position.x, y: self.position.y + CGFloat(currentSpeed))
            objectSprite!.zRotation = CGFloat( degreesToRadians(0) )
        case .Down:
            self.position = CGPoint(x: self.position.x, y: self.position.y - CGFloat(currentSpeed))
            objectSprite!.zRotation = CGFloat( degreesToRadians(180) )
        case .None:
            self.position = CGPoint(x: self.position.x, y: self.position.y)
            
        default:
            println("none of the conditions were true")
        }
        
    }
    
    func degreesToRadians(degrees: Double) -> Double{
        return degrees / 180 * Double(M_PI)
    }
    
    
    func goUp(){
        
        currentDirection = .Up
        
    }
    
    func goDown(){
        currentDirection = .Down
        
    }
    
    func goRight(){
        
        currentDirection = .Right
        
    }
    
    func goLeft(){
        
        currentDirection = .Left
        
    }
    
}
