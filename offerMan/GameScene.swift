//
//  GameScene.swift
//  offerMan
//
//  Created by 刘祥 on 9/17/18.
//  Copyright © 2018 shaneliu90. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var offerObj : SKSpriteNode?
    var offerTimer : Timer?
    var bugTimer : Timer?
    var top : SKSpriteNode?
    var scoreLabel : SKLabelNode?
    var yourScoreLabel : SKLabelNode?
    var finalScoreLabel : SKLabelNode?
    
    let offerManCategory : UInt32 = 0x1 << 1
    let offerCategory : UInt32 = 0x1 << 2
    let bugCategory : UInt32 = 0x1 << 3
    let topAndBottomrCategory : UInt32 = 0x1 << 4
    
    var score : Int = 0

    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        offerObj = childNode(withName: "offerObj") as? SKSpriteNode
        offerObj?.physicsBody?.categoryBitMask = offerManCategory
        offerObj?.physicsBody?.contactTestBitMask = offerCategory | bugCategory
        
        offerObj?.physicsBody?.collisionBitMask = topAndBottomrCategory
        
        var offerManRun : [SKTexture] = []
        for number in 1...6{
            offerManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        offerObj?.run(SKAction.repeatForever(SKAction.animate(with: offerManRun, timePerFrame: 0.1))) 
        
        
        top = childNode(withName: "top") as? SKSpriteNode
        top?.physicsBody?.categoryBitMask = topAndBottomrCategory
        top?.physicsBody?.collisionBitMask = offerManCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        startTimers()
        createWave()
    }
    
    func createWave(){
        
        let sizingWave = SKSpriteNode(imageNamed: "wave")
        let numberOfWave = Int(size.width / sizingWave.size.width) + 1
        for number in 0...numberOfWave{
            let wave = SKSpriteNode(imageNamed: "wave")
            wave.physicsBody = SKPhysicsBody(rectangleOf: wave.size)
            wave.physicsBody?.categoryBitMask = topAndBottomrCategory
            wave.physicsBody?.collisionBitMask = offerManCategory
            wave.physicsBody?.affectedByGravity = false
            wave.physicsBody?.isDynamic = false
            addChild(wave)
            
            let waveX = -size.width / 2 + wave.size.width / 2 + wave.size.width * CGFloat(number)
            wave.position = CGPoint(x: waveX, y: -size.height / 2 + wave.size.height / 2)
            let speed = 100.0
            let firstMoveLeft = SKAction.moveBy(x: -wave.size.width - wave.size.width * CGFloat(number), y: 0, duration: TimeInterval(wave.size.width + wave.size.width * CGFloat(number)) / speed)
            let resetWave = SKAction.moveBy(x: size.width + wave.size.width, y: 0, duration: 0)
            let waveFullMove = SKAction.moveBy(x: -size.width - wave.size.width, y: 0, duration: TimeInterval(size.width + wave.size.width) / speed)
            let waveMovingForever = SKAction.repeatForever(SKAction.sequence([waveFullMove,resetWave]))
            wave.run(SKAction.sequence([firstMoveLeft,resetWave,waveMovingForever]))
        }
    }
    
    func createOffer(){
        let offer = SKSpriteNode(imageNamed: "job")
        offer.physicsBody = SKPhysicsBody(rectangleOf: offer.size)
        offer.physicsBody?.affectedByGravity = false
        offer.physicsBody?.categoryBitMask = offerCategory
        offer.physicsBody?.contactTestBitMask = offerManCategory
        offer.physicsBody?.collisionBitMask = 0

        addChild(offer)
        
        let sizingWave = SKSpriteNode(imageNamed: "wave")
        
        let maxY = size.height / 2 - offer.size.height / 2
        let minY = -size.height / 2 + offer.size.height / 2 + sizingWave.size.height
        let range = maxY - minY
        let offerY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        
        offer.position = CGPoint(x: size.width / 2 + offer.size.width / 2, y: offerY)
        
        let moveleft = SKAction.moveBy(x: -size.width - offer.size.width, y: 0, duration: 4)
        offer.run(SKAction.sequence([moveleft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        
        if contact.bodyA.categoryBitMask == offerCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyB.categoryBitMask == offerCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyA.categoryBitMask == bugCategory{
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
        if contact.bodyB.categoryBitMask == bugCategory{
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
    }
    
    func startTimers(){
        offerTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createOffer()
        })
        
        bugTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createBugs()
        })
        
    }
    
    func gameOver(){
        
        offerTimer?.invalidate()
        bugTimer?.invalidate()
        
        scene?.isPaused = true
        yourScoreLabel = SKLabelNode(text: "Your Score :")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil{
            addChild(yourScoreLabel!)
        }
        
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
        
        
        
    }
    
    func createBugs(){
        let bug = SKSpriteNode(imageNamed: "bug")
        bug.physicsBody = SKPhysicsBody(rectangleOf: bug.size)
        bug.physicsBody?.affectedByGravity = false
        bug.physicsBody?.categoryBitMask = bugCategory
        bug.physicsBody?.contactTestBitMask = offerManCategory
        bug.physicsBody?.collisionBitMask = 0
        
        addChild(bug)
        
        let sizingWave = SKSpriteNode(imageNamed: "wave")
        let maxY = size.height / 2 - bug.size.height / 2
        let minY = -size.height / 2 + bug.size.height / 2 + sizingWave.size.height
        let range = maxY - minY
        let bugY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        
        bug.position = CGPoint(x: size.width / 2 + bug.size.width / 2, y: bugY)
        
        let moveleft = SKAction.moveBy(x: -size.width - bug.size.width, y: 0, duration: 4)
        bug.run(SKAction.sequence([moveleft, SKAction.removeFromParent()]))
    

    
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scene?.isPaused == false{
            offerObj?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100000))
        }
        
        
        let touch = touches.first
        if let location = touch?.location(in: self){
            let theNodes = nodes(at: location)
            
            for node in theNodes{
                if node.name == "play"{
                    //replay
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                    
                }
            }
        }
        
    }
    

}
