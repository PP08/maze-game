//
//  Menu.swift
//  Xmaze
//
//  Created by Phuc Phuong on 7/20/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import UIKit
import SpriteKit


class Menu: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //self.backgroundColor = SKColor(red: 0.15, green:0.15, blue:0.3, alpha: 1.0)
        //self.backgroundColor = SKColor(patternImage: pattern.png)
        self.backgroundColor = SKColor(red: 0.15, green:0.15, blue:0.3, alpha: 1.0)//(red: 0.22, green: 0.160, blue: 0.133, alpha: 1.0)
            //rgba(22, 160, 133,1.0)rgba(52, 152, 219,1.0)rgba(22, 160, 133,1.0)
        var button = SKSpriteNode(imageNamed: "nextButton.png")
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        button.name = "nextButton"
        
        self.addChild(button)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        
        // If next button is touched, start transition to second scene
        if (node.name == "nextButton") {
            var secondScene = GameScene(size: self.size)
            var transition = SKTransition.doorsCloseHorizontalWithDuration(1)
            secondScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(secondScene, transition: transition)
        }
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

