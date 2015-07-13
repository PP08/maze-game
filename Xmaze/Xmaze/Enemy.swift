//
//  Enemy.swift
//  Xmaze
//
//  Created by Phuc Phuong on 7/13/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy: SKNode {
    
    
    required init (coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not implemented")
    }
    
    init (fromSKSWithImage image:String) {
        
        super.init()
        
        let enemySpite = SKSpriteNode ( imageNamed: image)
        
        addChild(enemySpite)
    }
    
    
    init (theDict:Dictionary<NSObject, AnyObject> ) {
        
        super.init()
        
        let theX:String = theDict["x"] as AnyObject? as! String
        let x:Int = theX.toInt()!
        
        let theY:String = theDict["y"] as AnyObject? as! String
        let y:Int = theY.toInt()!

        
        let location:CGPoint = CGPoint(x: x, y: y * -1)
        
        
        let image = theDict["name"] as AnyObject? as! String
        
        let enemySprite = SKSpriteNode ( imageNamed: image)
        
        self.position = CGPoint(x: location.x + (enemySprite.size.width / 2), y: location.y - (enemySprite.size.height / 2)) // must use this because Tiled uses position in the top left of the shape
        
        addChild(enemySprite)
        
    }
    
    
    
}