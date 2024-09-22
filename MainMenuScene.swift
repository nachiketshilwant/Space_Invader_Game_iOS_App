//
//  MainMenuScene.swift
//  spaceInvader
//
//  Created by Nachiket Shilwant on 26/08/24.
//

import SpriteKit

class MainMenuScene: SKScene {
    private let startGameLabel = SKLabelNode(fontNamed: "Billing Lottre")
    private let gameName1Label = SKLabelNode(fontNamed: "Billing Lottre")
    private let gameName2Label = SKLabelNode(fontNamed: "Billing Lottre")

    override func didMove(to view: SKView) {
        setupBackground()
        setupLabels()
    }
    
    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 0
        addChild(background)
    }
    
    private func setupLabels() {
        configureLabel(gameName1Label, text: "Solo", fontSize: 150, position: CGPoint(x: size.width / 2, y: size.height * 0.7))
        configureLabel(gameName2Label, text: "Mission", fontSize: 150, position: CGPoint(x: size.width / 2, y: size.height * 0.625))
        
        configureLabel(startGameLabel, text: "Start Game", fontSize: 100, position: CGPoint(x: size.width / 2, y: size.height * 0.4))
    }
    
    private func configureLabel(_ label: SKLabelNode, text: String, fontSize: CGFloat, position: CGPoint) {
        label.text = text
        label.fontSize = fontSize
        label.fontColor = .white
        label.position = position
        addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if startGameLabel.contains(touchLocation) {
                presentGameScene()
            }
        }
    }
    
    private func presentGameScene() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
