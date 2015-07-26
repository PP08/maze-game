//
//  about.swift
//  Xmaze
//
//  Created by Phuc Phuong on 7/21/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import UIKit
import SpriteKit



class about: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = SKColor.blackColor()
        
        var closebt = SKSpriteNode(imageNamed: "exitbt.png")
        closebt.position = CGPoint(x: self.size.width / 2, y: self.size.height / 1.3)//CGPoint(x: self.size.width / (self.size.width * 0.5), y: self.size.height / 1.2)//CGPoint(x: 0, y: 0)//CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        var AboutText:SKNode = SKSpriteNode(imageNamed: "About.png")
        self.addChild(AboutText)
        AboutText.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        closebt.name = "exitbt"
        
        
        self.addChild(closebt)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        
        // If next button is touched, start transition to second scene
        if (node.name == "exitbt") {
            var secondScene = Menu(size: self.size)
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
