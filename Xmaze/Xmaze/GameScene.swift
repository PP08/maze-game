//
//  GameScene.swift
//  maze
//
//  Created by Phuc Phuong on 7/8/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import SpriteKit
import AVFoundation

enum BodyType:UInt32 {
    case hero = 1
    case boundary = 2
    case sensorUp = 4
    case sensorDown = 8
    case sensorRight = 16
    case sensorLeft = 32
    case star = 64
    case enemy = 128
    case boundary2 = 256
    
    
}


class GameScene: SKScene, SKPhysicsContactDelegate, NSXMLParserDelegate{
    
    var currentSpeed:Float = 5
    var enemySpeed:Float = 4
    var heroLocation:CGPoint = CGPointZero
    var mazeWorld:SKNode?
    var hero:Hero?
    var useTMXFiles:Bool = false
    var heroIsDead:Bool = false
    var starsAcquired:Int = 0
    var starsTotal:Int = 0
    var starsLabel:SKLabelNode?
    var starsLeft:Int = 0
    var enemyCount:Int = 0
    var enemyDictionnary:[String : CGPoint] = [:]
    
    var currentTMXFile:String?
    var nextSKSFile:String?
    
    var bgImage:String?
    var enemyLogic:Double?
    var gameLabel:SKLabelNode?
    
    var parallaxBG:SKSpriteNode?
    var parallaxOffset:CGPoint = CGPointZero
    var bgSoundPlayer:AVAudioPlayer?
    
    var PauseButton:SKNode?
    var PlayButton:SKNode?
    var rsBackground:SKNode?
    var resetButton:SKNode?
    
    var exitMenu:SKNode?
    
    override func didMoveToView(view: SKView) {
        
        
        /* parse Property list*/
        
        
        
        
        
        //addChild(pauseMenu!)
        
        let path = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict:AnyObject = dict.objectForKey("HeroSettings")!
        let gameDict:AnyObject = dict.objectForKey("GameSettings")!
        let levelArray:AnyObject = dict.objectForKey("LevelSettings")!
        
        
        if let levelNSArray:NSArray = levelArray as? NSArray {
            
            
            //println(levelNSArray)
            
            var levelDict:AnyObject = levelNSArray[currentLevel]
            
            if let tmxFile = levelDict.valueForKey("TMXFile") as? String {
                
                
                currentTMXFile = tmxFile
                //println("specified a TMX file for this level")
                
            }
            if let sksFile = levelDict.valueForKey("NextSKSFile") as? String {

                nextSKSFile = sksFile
                //println("specified a next SKS file if this level is passed")
                
            }
            if let speed = levelDict.valueForKey("Speed") as? Float {
                
                currentSpeed = speed
                //println(currentSpeed)
                
            }
            
            if let espeed = levelDict.valueForKey("EnemySpeed") as? Float {
                
                enemySpeed = espeed
                //println(enemySpeed)
                
            }
            
            
            if let elogic = levelDict.valueForKey("EnemyLogic") as? Double {
                
                enemyLogic = elogic
                //println(enemyLogic)
                
            }
            
            if let bg = levelDict.valueForKey("Background") as? String {
                
                bgImage = bg
                
            }
            
            if let musicFile = levelDict.valueForKey("Music") as? String {
                
                playBackgroundSound(musicFile)
                
            }
            
            
        }
        
        /* initial properties */
        
        self.backgroundColor = SKColor.blackColor()
        //self.pausingMenu()
        view.showsPhysics = (gameDict.valueForKey("ShowPhysics") as? Bool)!
    
        let level = gameDict.valueForKey("Gravity") as? String
        
        
        if ( gameDict.valueForKey("Gravity") as? String != nil) {
            
            //println("has gravity from property list")
            let newGravity:CGPoint = CGPointFromString(gameDict.valueForKey("Gravity") as? String)
            physicsWorld.gravity = CGVector(dx: newGravity.x, dy: newGravity.y)
            
            
        } else {
            
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        }
        
        
        
        if ( gameDict.valueForKey("ParallaxOffset") as? String != nil) {
            
            let parallaxOffsetAsString = gameDict.valueForKey("ParallaxOffset") as? String
            parallaxOffset = CGPointFromString(parallaxOffsetAsString!)
            
            //println(parallaxOffset)
            
        }
        
        
        physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        useTMXFiles = (gameDict.valueForKey("UseTMXFile") as? Bool)!
        
        if(useTMXFiles == true) {
            
            //println("setup with tmx")
            
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
        
        
        
        /* hero and maze */
        
        
        hero = Hero(theDict: heroDict as! Dictionary)
        hero!.position = heroLocation
        mazeWorld!.addChild(hero!)
        hero!.currentSpeed = currentSpeed //wil get replaced later on per level basic
        
        
        
        
        
        //MARK: TOMORROW
        
        
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
        
        Pause()
        
        /* background */
        
        if(bgImage != nil) {
            
            createBackground(bgImage!)
            
        }
        
        
        
        
        /*set up based on TMX or SKS*/
        
        if(useTMXFiles==false){
            
            setUpBoundaryFromSKS()
            setUpEdgeFromSKS()
            setUpStarsFromSKS()
            setUpEnemiesFromSKS()
            
        } else {
            
            parseTMXFileWithName(currentTMXFile!)
        }
        
        
        tellEnemiesWhereHeroIs()
        createLabel()
        
        
    }
    
    
    
    func setUpEnemiesFromSKS () {
        
        mazeWorld!.enumerateChildNodesWithName("enemy*"){
            node, stop in
            
            if let enemy = node as? SKSpriteNode {
                
                self.enemyCount++
                
                let newEnemy:Enemy = Enemy(fromSKSWithImage: enemy.name!)
                self.mazeWorld!.addChild(newEnemy)
                newEnemy.position = enemy.position
                newEnemy.name = enemy.name!
                newEnemy.enemySpeed = self.enemySpeed
                
                self.enemyDictionnary.updateValue(newEnemy.position, forKey: newEnemy.name!)
                
                enemy.removeFromParent()
                
            }
            
            
        }
    }
    
    
    
    func setUpBoundaryFromSKS(){
        
        mazeWorld!.enumerateChildNodesWithName("boundary"){
            node, stop in
            
            
            
            if let boundary = node as? SKSpriteNode{
                
                //println("found boundary")
                let rect:CGRect = CGRect(origin: boundary.position, size: boundary.size)
                let newBoundary:Boundary = Boundary(fromSKSwithRect: rect, isEdge:false)
                self.mazeWorld!.addChild(newBoundary)
                newBoundary.position = boundary.position
                boundary.removeFromParent()
            }
        }
        
    }
    
    
    
    func setUpEdgeFromSKS(){
        
        mazeWorld!.enumerateChildNodesWithName("edge"){
            node, stop in
            
            
            
            if let edge = node as? SKSpriteNode{
                
                //println("found boundary")
                let rect:CGRect = CGRect(origin: edge.position, size: edge.size)
                let newEdge:Boundary = Boundary(fromSKSwithRect: rect, isEdge:true)
                self.mazeWorld!.addChild(newEdge)
                newEdge.position = edge.position
                
                edge.removeFromParent()
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
                //println(self.starsTotal)
                
                star.removeFromParent()
                
            }
        }
    }
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        var touch = touches as!  Set<UITouch>
        var location = touch.first!.locationInNode(self)
        var node = self.nodeAtPoint(location)
        if(node.name == "PauseButton") {
            
            var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("pauseGame"), userInfo: nil, repeats: false)
            
            if (bgSoundPlayer != nil) {
                
                bgSoundPlayer!.stop()
                bgSoundPlayer = nil
            }
            PauseButton!.removeFromParent()
            resumeBackground()
            Resume()
            resetMenu()
            exitToMenu()
        }
        
        if(node.name == "PlayButton") {
            
            self.scene!.view!.paused = false
            playBackgroundSound("BgSound")
            PlayButton!.removeFromParent()
            rsBackground!.removeFromParent()
            exitMenu!.removeFromParent()
            resetButton!.removeFromParent()
            
            /*if (bgSoundPlayer != nil) {
                
                bgSoundPlayer!.stop()
                bgSoundPlayer = nil
            }*/

            Pause()
        }
        
        else if(node.name == "resetButton") {
            
            self.scene!.view!.paused = false
            
            if (bgSoundPlayer != nil) {
                
                bgSoundPlayer!.stop()
                bgSoundPlayer = nil
            }

            
            rsBackground!.removeFromParent()
            exitMenu!.removeFromParent()
            resetButton!.removeFromParent()
            resetGame()
        }
            
        else if(node.name == "exitButton") {
            
            self.scene!.view!.paused = false
            
            if (bgSoundPlayer != nil) {
                
                bgSoundPlayer!.stop()
                bgSoundPlayer = nil
            }
            
            rsBackground!.removeFromParent()
            exitMenu!.removeFromParent()
            resetButton!.removeFromParent()
            
            var menuScene = Menu(size: self.size)
            var transition = SKTransition.doorsCloseHorizontalWithDuration(1)
            menuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(menuScene, transition: transition)
            livesLeft = 3
            
            
        }

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if(heroIsDead == false){
            
            hero!.update()
            
            
            mazeWorld!.enumerateChildNodesWithName("enemy*") {
                node, stop in
                
                if let enemy = node as? Enemy {
                    
                    if (enemy.isStuck == true) {
                        
                        enemy.heroLocationIs = self.reTurnTheDirection(enemy)
                        enemy.decideDirection()
                        enemy.isStuck = false
                    }
                    
                    
                    enemy.update()
                }
                
            }
            
 
        }else{
            // hero is dead
            
            resetEnemies()
            hero?.rightBlocked = false
            hero!.position = heroLocation
            heroIsDead = false
            hero!.currentDirection = .Right
            hero!.desiredDirection = .None
            hero!.goRight()
            
            hero!.runAnimation()
        }
        
        
    }
    
    // MARK: swiped gesture
    
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
    
    
    // MARK: contact related code
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch(contactMask){
            
        case BodyType.enemy.rawValue | BodyType.enemy.rawValue:
            
            if let enemy1 = contact.bodyA.node as? Enemy {
                
                
                enemy1.bumped()
                
            }else if let enemy2 = contact.bodyB.node as? Enemy {
                
                
                enemy2.bumped()
                
            }
            
        case BodyType.hero.rawValue | BodyType.enemy.rawValue:
            
            let collectSound:SKAction = SKAction.playSoundFileNamed("LoseLife.wav", waitForCompletion: false)
            self.runAction(collectSound)
            reLoadLevel()
            
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            
            hero!.upSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            
            hero!.downSensorContactStart()
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            
            hero!.leftSensorContactStart()
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            
            hero!.rightSensorContactStart()
        
        case BodyType.hero.rawValue | BodyType.boundary2.rawValue:
            let moveSound:SKAction = SKAction.playSoundFileNamed("Move.mp3", waitForCompletion: false)
            self.runAction(moveSound)
        
        case BodyType.hero.rawValue | BodyType.star.rawValue:
            
            let collectSound:SKAction = SKAction.playSoundFileNamed("Collecting.mp3", waitForCompletion: false)
            self.runAction(collectSound)
            
            if let star = contact.bodyA.node as? Star {
                
                
                star.removeFromParent()
                
            }else if let star = contact.bodyB.node as? Star {
                
                
                star.removeFromParent()
                
            }
            
            starsLabel?.removeFromParent()
            starsAcquired++
            starsLeft = starsTotal - starsAcquired
            countingStars()
            //println(starsAcquired)
            if (starsAcquired == starsTotal) {
                
                //println("got all the stars")
                loadNextLevel()
            }
            
        default:
            return
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask){
            
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            
            hero!.upSensorContactEnd()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            
            hero!.downSensorContactEnd()
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            
            hero!.leftSensorContactEnd()
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            
            hero!.rightSensorContactEnd()
            
            
        default:
            return
        }
        
    }
    
    
    // MARK: parse TMX file
    
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
            if (type as? String == "Boundary" || type as? String == "Boundary2") {
                
                
                var tmxDict = attributeDict
                tmxDict.updateValue("false", forKey: "isEdge")
                let newBoundary:Boundary = Boundary(theDict: tmxDict)
                mazeWorld!.addChild(newBoundary)

                if(type as? String == "Boundary2") {
                    
                    newBoundary.makeMoveable()
                }
                
                
            } else if (type as? String == "Edge") {
                
                var tmxDict = attributeDict
                tmxDict.updateValue("true", forKey: "isEdge")
                let newBoundary:Boundary = Boundary(theDict: tmxDict)
                mazeWorld!.addChild(newBoundary)
                
                
            }
            
            
            else if (type as? String == "Star") {
                
                let newStar:Star = Star(fromTMXFileWithDict: attributeDict)
                mazeWorld!.addChild(newStar)
                
                starsTotal++
                
            }
                
            else if (type as? String == "Portal") {
                
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
           
            
            else if (type as? String == "Enemy") {
                
                enemyCount++
                
                let theName:String = attributeDict["name"] as AnyObject? as! String
                
                let newEnemy:Enemy = Enemy(theDict: attributeDict)
                
                mazeWorld!.addChild(newEnemy)
                
                newEnemy.name = theName
                newEnemy.enemySpeed = enemySpeed
                
                let location:CGPoint = newEnemy.position
                
                enemyDictionnary.updateValue(location, forKey: newEnemy.name!)
                

                
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
        /* handle parallax */
        
        if (parallaxOffset.x != 0) {
            
            if ( Int(cameraPositionInScene.x) < 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x + parallaxOffset.x, y: parallaxBG!.position.y)//CGPoint(x: , y: )
            
            } else if ( Int(cameraPositionInScene.x) > 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x - parallaxOffset.x, y: parallaxBG!.position.y)//CGPoint(x: , y: )
            }
            
        }
        
        if (parallaxOffset.y != 0) {
            
            if ( Int(cameraPositionInScene.y) < 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x, y: parallaxBG!.position.y + parallaxOffset.y)
                
            } else if ( Int(cameraPositionInScene.y) > 0 ) {
                
                parallaxBG!.position = CGPoint(x: parallaxBG!.position.x, y: parallaxBG!.position.y - parallaxOffset.y)
            }
            
        }
        
    }
    
    //MARK: ENEMY STUFF
    
    func tellEnemiesWhereHeroIs () {
        
        
        
        let enemyAction:SKAction = SKAction.waitForDuration(enemyLogic!)
        
        self.runAction(enemyAction, completion: {
            
            self.tellEnemiesWhereHeroIs()
        })
        
        
        
        mazeWorld!.enumerateChildNodesWithName("enemy*") {
            node, stop in
        
            if let enemy = node as? Enemy {
            
                enemy.heroLocationIs = self.reTurnTheDirection(enemy)
            
            }
        }
    
    }
    
    
    func reTurnTheDirection(enemy:Enemy) -> HeroIs {
        
        if (self.hero!.position.x < enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            // southwest
            
            return HeroIs.Southwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y < enemy.position.y) {
            
            // southwest
            
            return HeroIs.Southeast
            
        } else if (self.hero!.position.x < enemy.position.x && self.hero!.position.y > enemy.position.y) {
            
            // southwest
            
            return HeroIs.Northwest
            
        } else if (self.hero!.position.x > enemy.position.x && self.hero!.position.y > enemy.position.y) {
            
            // southwest
            
            return HeroIs.Northeast
            
        } else {
            
            return HeroIs.Northeast
        }
        
    }
    
    
    // MARK: reload level
    
    func reLoadLevel() {
        
        loseLife()
        heroIsDead = true
        
    }
    
    
    func resetEnemies() {
        
        for (name, location) in enemyDictionnary {
            
            mazeWorld!.childNodeWithName(name)?.position = location
            
        }
        
    }
    
    func loadNextLevel() {
        
        currentLevel++
        
        if(currentLevel == 3) {
            playBackgroundSound("yay")
            gameLabel?.text = "CONGRATULATION! YOU'VE DONE SO WELL!"
            gameLabel!.position = CGPointZero
            
            gameLabel!.horizontalAlignmentMode = .Center
            
            //playBackgroundSound("GameOver")
            
            let scaleAction2:SKAction = SKAction.scaleTo(5, duration: 5)
            let fadeAction2:SKAction = SKAction.fadeAlphaTo(5, duration: 5)
            let group2:SKAction = SKAction.group([scaleAction2, fadeAction2])
            
            /*let wait:SKAction = SKAction.waitForDuration(2)
            let seq:SKAction = SKAction.sequence([group, wait])*/
            
            
            mazeWorld!.runAction(group2, completion: {
                
                //self.resetGame()
                
                if (self.bgSoundPlayer != nil) {
                    
                    self.bgSoundPlayer!.stop()
                    self.bgSoundPlayer = nil
                }
                
                var menuScene = Menu(size: self.size)
                var transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                menuScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(menuScene, transition: transition)
                livesLeft = 3
            })
        }
        
        else {

            
            if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
            }
        
            if ( useTMXFiles == true) {
                let collectSound:SKAction = SKAction.playSoundFileNamed("unbelievable.wav", waitForCompletion: false)
                self.runAction(collectSound)
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("loadNextTMXLevel"), userInfo: nil, repeats: false)
                //loadNextTMXLevel()
            
            } else {
            
                loadNextSKSLevel()
            }
        }
    }
    
    func loadNextTMXLevel() {
        
        
        var scene:GameScene = GameScene(size: self.size)
        
        scene.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(1))
        
    }
    
    func loadNextSKSLevel() {
        
        currentSKSFile = nextSKSFile!
        var scene = GameScene.unarchiveFromFile(nextSKSFile!) as? GameScene
        
        scene!.scaleMode = .AspectFill
        
        self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(1))
        
    }
    func loseLife() {
        
        livesLeft = livesLeft - 1
        
        if (livesLeft == 0) {
            // show text label with gameover
            
            PauseButton?.removeFromParent()
        
            gameLabel!.text = "GAME OVER"
            
            gameLabel!.position = CGPointZero
            
            gameLabel!.horizontalAlignmentMode = .Center
            
            playBackgroundSound("GameOver")
            
            let scaleAction:SKAction = SKAction.scaleTo(0.2, duration: 2)
            let fadeAction:SKAction = SKAction.fadeAlphaTo(0, duration: 2)
            let group:SKAction = SKAction.group([scaleAction, fadeAction])
            
            /*let wait:SKAction = SKAction.waitForDuration(2)
            let seq:SKAction = SKAction.sequence([group, wait])*/
            
            
            mazeWorld!.runAction(group, completion: {
            
                //self.resetGame()
                
                if (self.bgSoundPlayer != nil) {
                    
                    self.bgSoundPlayer!.stop()
                    self.bgSoundPlayer = nil
                }
       
                var menuScene = Menu(size: self.size)
                var transition = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                menuScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(menuScene, transition: transition)
                livesLeft = 3
                currentLevel = 0
            
            })
        }else {
            gameLabel!.text = "Live: " + String(livesLeft)
            //update text for lives label
        }
        
    }
    
    func resetGame() {
        
        livesLeft = 3
        currentLevel = 0
        
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
        }
        
        if (useTMXFiles == true) {
            
            loadNextTMXLevel()
            
        } else {
            
            currentSKSFile = firstSKSFile
            self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(0))
            
        }
        
    }
    
    func createLabel() {
        
        gameLabel = SKLabelNode(fontNamed: "BM germar")
        gameLabel!.horizontalAlignmentMode = .Left
        gameLabel!.verticalAlignmentMode = .Center
        gameLabel!.fontColor = SKColor.whiteColor()
        gameLabel!.text = "Lives: " + String(livesLeft)
        gameLabel!.name = "gameLabel"
        addChild(gameLabel!)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
            
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 2.3))
        } else {
            
            gameLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
        }
        
    }
    
    func countingStars() {
        
        starsLabel = SKLabelNode(fontNamed: "BM germar")
        
        starsLabel!.horizontalAlignmentMode = .Right
        starsLabel!.verticalAlignmentMode = .Center
        starsLabel!.fontColor = SKColor.whiteColor()
        starsLabel!.text = "Stars: " + String(starsLeft)
        
        addChild(starsLabel!)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            
            starsLabel!.position = CGPoint(x: (self.size.width / 2.3), y: -(self.size.height / 3))
            
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            
            starsLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 2.3))
        } else {
            
            starsLabel!.position = CGPoint(x: -(self.size.width / 2.3), y: -(self.size.height / 3))
        }
        
    }
    
    
    func createBackground(image:String) {
       
        parallaxBG = SKSpriteNode(imageNamed: image)
        mazeWorld!.addChild(parallaxBG!)
        parallaxBG!.position = CGPoint(x: parallaxBG!.size.width / 2, y: -parallaxBG!.size.height / 2)
        parallaxBG!.zPosition = -1
        parallaxBG!.alpha = 0.5
    }
    
    func playBackgroundSound(name:String) {
        
        if (bgSoundPlayer != nil) {
            
            bgSoundPlayer!.stop()
            bgSoundPlayer = nil
        }
        
        
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3")!
        bgSoundPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        
        bgSoundPlayer!.volume = 0.5 //haft volume
        bgSoundPlayer!.numberOfLoops = -1
        bgSoundPlayer!.prepareToPlay()

        bgSoundPlayer!.play()
        
    }
    
    
    func Pause() {
    
        PauseButton = SKSpriteNode(imageNamed: "pausebt.png") //[SKSpriteNode spriteNodeWithImageNamed: "Pause.png"]
        PauseButton!.position = CGPoint(x: -(self.size.width / 2.5), y: (self.size.height / 18))
        //PauseButton!.position = CGPointMake(0, -(self.size.height / 8))//#x: CGFloat#>, )//(x: -(self.size.width / 2.5), y: -(self.size.height / 8))
        //PauseButton!.zPosition = 3
        //PauseButton!.size = CGSizeMake(40, 40)
        PauseButton!.name = "PauseButton"
        PauseButton!.zPosition = 1000
        addChild(PauseButton!)
    
    }
    
    func Resume() {
    
        
        PlayButton = SKSpriteNode(imageNamed: "playbt.png") //[SKSpriteNode spriteNodeWithImageNamed: "Pause.png"]
        PlayButton!.position = CGPointZero//CGPointMake(0.5, 0.5)
        //PlayButton!.position = CGPoint(x: -(self.size.width / 2.5), y: -(self.size.height / 6))
        //PauseButton!.zPosition = 3
        //PauseButton!.size = CGSizeMake(40, 40)
        PlayButton!.name = "PlayButton"
        PlayButton!.zPosition = 999
        addChild(PlayButton!)
    
    }
    
    func pauseGame () {
        self.scene!.view!.paused = true
        //self.paused = true
    }
    
    func resumeBackground() {
        
        rsBackground = SKSpriteNode(imageNamed: "rsBackground.png")
        //let wiggleIn = SKAction.scaleXTo(1.0, duration: 0.2)
        //let wiggleOut = SKAction.scaleXTo(1.2, duration: 0.2)
        //let wiggle = SKAction.sequence([wiggleIn, wiggleOut])
        //let wiggleRepeat = SKAction.repeatActionForever(wiggle)
        
        //rsBackground!.runAction(wiggleRepeat, withKey: "wiggle")
        
        rsBackground!.position = CGPointZero
        rsBackground!.zPosition = 995
        addChild(rsBackground!)
    }
    
    func resetMenu() {
        resetButton = SKSpriteNode(imageNamed: "resetButton.png")
        resetButton!.position = CGPoint(x: -(self.size.width / 8), y: 0)
        resetButton!.name = "resetButton"
        resetButton!.zPosition = 998
        addChild(resetButton!)

    }
    
    func exitToMenu() {
        exitMenu = SKSpriteNode(imageNamed: "exitbt.png")
        exitMenu!.position = CGPoint(x: (self.size.width / 8), y: 0)
        exitMenu!.name = "exitButton"
        exitMenu!.zPosition = 997
        addChild(exitMenu!)
        
    }
    
}
