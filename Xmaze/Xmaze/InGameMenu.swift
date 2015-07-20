//
//  InGameMenu.swift
//  Xmaze
//
//  Created by Phuc Phuong on 7/21/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import UIKit
import SpriteKit

class InGameMenu: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor(red: 0.15, green:0.15, blue:0.3, alpha: 1.0)
        var button = SKSpriteNode(imageNamed: "playbt.png")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        button.name = "previousButton"
        
        self.addChild(button)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        
        // If previous button is touched, start transition to previous scene
        if (node.name == "previousButton") {
            var gameScene = GameScene(size: self.size)
            var transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
            gameScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(gameScene, transition: transition)
            gameScene.paused = false
            
        }
    }
}