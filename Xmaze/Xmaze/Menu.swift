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
        
        self.backgroundColor = SKColor.blackColor()
        var playButton = SKSpriteNode(imageNamed: "playbt.png")
        playButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)//CGPoint(x: 0, y: 0)//CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        playButton.name = "nextButton"
        
        var aboutButton = SKSpriteNode(imageNamed: "aboutbt.png")
        aboutButton.position = CGPoint(x: (self.size.width / 2), y: self.size.height / 4)//CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        aboutButton.name = "aboutButton"
        
        self.addChild(aboutButton)
        self.addChild(playButton)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        
        // If next button is touched, start transition to second scene
        if (node.name == "nextButton") {
            var secondScene = GameScene(size: self.size)
            var transition = SKTransition.doorsOpenHorizontalWithDuration(1)//doorsCloseHorizontalWithDuration(1)
            secondScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(secondScene, transition: transition)
        }
        
        if (node.name == "aboutButton") {
            var aboutScene = about(size: self.size)
            var transition = SKTransition.doorsOpenHorizontalWithDuration(1)//doorsCloseHorizontalWithDuration(1)
            aboutScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(aboutScene, transition: transition)
        }
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

