//
//  GameOverScene.swift
//  spaceInvader
//
//  Created by Nachiket Shilwant on 26/08/24.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let restartLabel = SKLabelNode(fontNamed: "Billing Lottre")

    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Billing Lottre")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 175
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Billing Lottre")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highestScore = defaults.integer(forKey: "highestScore")
        if gameScore > highestScore {
            highestScore = gameScore
            defaults.setValue(highestScore, forKey: "highestScore")
        }
        
        let highestScoreLabel = SKLabelNode(fontNamed: "Billing Lottre")
        highestScoreLabel.text = "High score: \(highestScore)"
        highestScoreLabel.fontSize = 100
        highestScoreLabel.fontColor = .white
        highestScoreLabel.zPosition = 1
        highestScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        self.addChild(highestScoreLabel)
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 80
        restartLabel.fontColor = .white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch) {
                gameScore = 0
                let sceneMoveTo = GameScene(size: self.size)
                sceneMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneMoveTo, transition: myTransition)
            }
        }
    }
}
