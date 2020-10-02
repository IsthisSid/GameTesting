//
//  GameScene.swift
//  Flappy Buns
//
//  Created by Sidany Walker on 9/26/20.
//
//Completed code for PART ONE OF FLAPPY BUN

import SpriteKit
import GameplayKit
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
    
let coinSound = SKAction.playSoundFileNamed("CoinSound.mp3", waitForCompletion: false)
    
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
   
     
    var score = Int(0)
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    var taptoplayLbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    var logoImg = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
     
    //CREATE THE BIRD ATLAS FOR ANIMATION
    let birdAtlas = SKTextureAtlas(named:"player")
    var birdSprites = Array<Any>()
    var bird = SKSpriteNode()
    var repeatActionBird = SKAction()
    
    var Ground = SKSpriteNode()
    var gameStarted = Bool()
    
    override func didMove(to view: SKView) {
        createScene()


    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameStarted == false{
            //1
            isGameStarted =  true
            bird.physicsBody?.affectedByGravity = true
            
            //2
            bird.physicsBody?.affectedByGravity = true
            createPauseBtn()
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                        self.logoImg.removeFromParent()
            })
                    taptoplayLbl.removeFromParent()
            
            self.bird.run(repeatActionBird)
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
                
            })
            
            let delay = SKAction.wait(forDuration: 3.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let SpawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(SpawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.move(to: CGPoint(x: -400, y: +70), duration: TimeInterval(0.012 * distance))
            let removePipes = SKAction.move(to: CGPoint(x: 100, y: -70), duration: TimeInterval(0.022 * distance))
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
        else {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        }
   
        
    
    for touch in touches{
                let location = touch.location(in: self)
                //1
                if isDied == true{
                    if restartBtn.contains(location){
                        if UserDefaults.standard.object(forKey: "highestScore") != nil {
                            let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                            if hscore < Int(scoreLbl.text!)!{
                                UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                            }
                            
                        } else {
                            UserDefaults.standard.set(0, forKey: "highestScore")
                        }
                        restartScene()
                    }

                } else {
                    //2
                    if pauseBtn.contains(location){
                        if self.isPaused == false{
                            self.isPaused = true
                            pauseBtn.texture = SKTexture(imageNamed: "play")
                        } else {
                            self.isPaused = false
                            pauseBtn.texture = SKTexture(imageNamed: "pause")
                        }
                        
                    }
                }

    }
        }
        
    
    
    override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
//            if isGameStarted == true{
//                if isDied == false{
//                    enumerateChildNodes(withName: "background", using: ({
//                        (node, error) in
//                        let bg = node as! SKSpriteNode
//                        bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
//                        if bg.position.x <= -bg.size.width {
//                            bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
//                        }
//                    }))
//                }
//            }
    }
    

    
    func createScene(){
       
        Ground = SKSpriteNode(imageNamed: "kittyBowl")
        Ground.size = CGSize(width: 320, height: 100)
        
        Ground.position = CGPoint(x: self.frame.width / 2, y: self.frame.width - 270)
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.birdCategory
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
       self.physicsBody?.categoryBitMask = PhysicsCategory.Ground
       self.physicsBody?.collisionBitMask = PhysicsCategory.birdCategory
       self.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory
       self.physicsBody?.isDynamic = false
       self.physicsBody?.affectedByGravity = false

       self.physicsWorld.contactDelegate = self

        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "kittyBg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }



        //SET UP THE BIRD SPRITES FOR ANIMATION
        birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))

        self.bird = createBird()
        self.addChild(bird)

        //PREPARE TO ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animateBird = SKAction.animate(with: self.birdSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
               let firstBody = contact.bodyA
               let secondBody = contact.bodyB
         
           if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.birdCategory || firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
                   
               enumerateChildNodes(withName: "wallPair", using: ({
                       (node, error) in
                       node.speed = 0
                       self.removeAllActions()
                   }))
                   if isDied == false{
                       isDied = true
                       createRestartBtn()
                       pauseBtn.removeFromParent()
                       self.bird.removeAllActions()
                   }
               } else if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.sushiCategory {
                   run(coinSound)
                   score += 1
                   scoreLbl.text = "\(score)"
                   
                   secondBody.node?.removeFromParent()
               } else if firstBody.categoryBitMask == PhysicsCategory.sushiCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
                   run(coinSound)
                   score += 1
                   scoreLbl.text = "\(score)"
             
                   firstBody.node?.removeFromParent()
               }
       }
       func restartScene(){
           self.removeAllChildren()
           self.removeAllActions()
           isDied = false
           isGameStarted = false
           score = 0
            createScene()
        
       }
   }
