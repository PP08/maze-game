//
//  GameScene.swift
//  maze
//
//  Created by Phuc Phuong on 7/8/15.
//  Copyright (c) 2015 Phuc Phuong. All rights reserved.
//

import SpriteKit

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
    var enemyCount:Int = 0
    var enemyDictionnary:[String : CGPoint] = [:]
    
    var currentTMXFile:String?
    var nextSKSFile:String?
    
    var bgImage:String?
    var enemyLogic:Double = 5
    
    override func didMoveToView(view: SKView) {
        
        
        /* parse Property list*/
        
        
        let path = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)!
        let heroDict:AnyObject = dict.objectForKey("HeroSettings")!
        let gameDict:AnyObject = dict.objectForKey("GameSettings")!
        let levelArray:AnyObject = dict.objectForKey("LevelSettings")!
        
        
        if let levelNSArray:NSArray = levelArray as? NSArray {
            
            
            println(levelNSArray)
            
            var levelDict:AnyObject = levelNSArray[currentLevel]
            
            if let tmxFile = levelDict.valueForKey("TMXFile") as? String {
                
                
                currentTMXFile = tmxFile
                println("specified a TMX file for this level")
                
            }
            if let sksFile = levelDict.valueForKey("NextSKSFile") as? String {

                nextSKSFile = sksFile
                println("specified a next SKS file if this level is passed")
                
            }
            if let speed = levelDict.valueForKey("Speed") as? Float {
                
                currentSpeed = speed
                println(currentSpeed)
                
            }
            
            if let espeed = levelDict.valueForKey("EnemySpeed") as? Float {
                
                enemySpeed = espeed
                println(enemySpeed)
                
            }
            
            
            if let elogic = levelDict.valueForKey("EnemyLogic") as? Double {
                
                enemyLogic = elogic
                println(enemyLogic)
                
            }
            
            if (levelDict.valueForKey("Background") != nil) {
                
                bgImage = levelDict.valueForKey("Background") as? String
                
            }
        }
        
        /* initial properties */
        
        self.backgroundColor = SKColor.blackColor()
        
        view.showsPhysics = (gameDict.valueForKey("ShowPhysics") as? Bool)!
    
        let level = gameDict.valueForKey("Gravity") as? String
        
        
        if ( gameDict.valueForKey("Gravity") as? String != nil) {
            
            //println("has gravity from property list")
            let newGravity:CGPoint = CGPointFromString(gameDict.valueForKey("Gravity") as? String)
            physicsWorld.gravity = CGVector(dx: newGravity.x, dy: newGravity.y)
            
            
        } else {
            
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        }
        
        
        physicsWorld.contactDelegate = self
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        useTMXFiles = (gameDict.valueForKey("UseTMXFile") as? Bool)!
        
        if(useTMXFiles == true) {
            
            println("setup with tmx")
            
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
        
        
        
        /* Setup your scene here */
        
        
        hero = Hero(theDict: heroDict as! Dictionary)
        hero!.position = heroLocation
        mazeWorld!.addChild(hero!)
        hero!.currentSpeed = currentSpeed //wil get replaced later on per level basic
        
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
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            
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
            
            reLoadLevel()
            
        case BodyType.boundary.rawValue | BodyType.sensorUp.rawValue:
            
            hero!.upSensorContactStart()
            
        case BodyType.boundary.rawValue | BodyType.sensorDown.rawValue:
            
            hero!.downSensorContactStart()
        case BodyType.boundary.rawValue | BodyType.sensorLeft.rawValue:
            
            hero!.leftSensorContactStart()
        case BodyType.boundary.rawValue | BodyType.sensorRight.rawValue:
            
            hero!.rightSensorContactStart()
            
        case BodyType.hero.rawValue | BodyType.star.rawValue:
            
            if let star = contact.bodyA.node as? Star {
                
                
                star.removeFromParent()
                
            }else if let star = contact.bodyB.node as? Star {
                
                
                star.removeFromParent()
                
            }
            
            
            starsAcquired++
            println(starsAcquired)
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
            if (type as? String == "Boundary") {
                var tmxDict = attributeDict
                tmxDict.updateValue("false", forKey: "isEdge")
                let newBoundary:Boundary = Boundary(theDict: tmxDict)
                mazeWorld!.addChild(newBoundary)
                
                
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
    }
    
    //MARK: ENEMY STUFF
    
    func tellEnemiesWhereHeroIs () {
        
        
        
        let enemyAction:SKAction = SKAction.waitForDuration(enemyLogic)
        
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
        
        if ( useTMXFiles == true) {
            
            loadNextTMXLevel()
            
        } else {
            
            loadNextSKSLevel()
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
            
            let scaleAction:SKAction = SKAction.scaleTo(0.2, duration: 3)
            let fadeAction:SKAction = SKAction.fadeAlphaTo(0, duration: 3)
            let group:SKAction = SKAction.group([scaleAction, fadeAction])
            
            /*let wait:SKAction = SKAction.waitForDuration(2)
            let seq:SKAction = SKAction.sequence([group, wait])*/
            
            
            mazeWorld!.runAction(group, completion: {
            
                self.resetGame()
            
            })
        }else {
            
            //update text for lives label
        }
        
    }
    
    func resetGame() {
        
        livesLeft = 3
        currentLevel = 0
        
        if (useTMXFiles == true) {
            
            loadNextTMXLevel()
            
        } else {
            
            currentSKSFile = firstSKSFile
            self.view?.presentScene(scene, transition: SKTransition.fadeWithDuration(1))
            
        }
    }
    
}
