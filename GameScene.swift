//
//  GameScene.swift
//  spaceInvader
//
//  Created by Nachiket Shilwant on 22/08/24.
//

import SpriteKit
import GameplayKit

var gameScore = 0


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "Billing Lottre")
    var levelNumber = 0
    var lives = 3
    let livesLabel = SKLabelNode(fontNamed: "Billing Lottre")
    
    let player = SKSpriteNode(imageNamed: "Spaceship")
    let bulletSound = SKAction.playSoundFileNamed("080879_bullet-39801.mp3", waitForCompletion: false)
    let gameArea: CGRect
    
    let tapToStartLabel = SKLabelNode(fontNamed: "Billing Lottre")
    
    func random() ->CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max:CGFloat) ->CGFloat{
        return random()*(max-min)+min
    }
    
    struct PhysicsCategories {
        static let None:UInt32 = 0
        static let Player:UInt32 = 0b1
        static let Bullet:UInt32 = 0b10
        static let Enemy:UInt32 = 0b100
    }
    enum gameState{
        case startGame
        case playgame
        case endgame
    }
    
    var currentGameState = gameState.startGame
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupPlayer()
        setUpScoreLabel()
        setUpLivesLabel()
        startGame()
        physicsWorld.contactDelegate = self
    }
    
    func startGame(){
        tapToStartLabel.text = "Tap to begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = .white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(tapToStartLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeIn)
    }
    
    func setupBackground() {
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width / 2, y: self.size.height * CGFloat(i))
            background.zPosition = 0
            self.addChild(background)
        }
    }
    
    func setupPlayer() {
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
    }
    
    func setUpScoreLabel(){
        scoreLabel.text = "Score : 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: self.size.width*0.2, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func setUpLivesLabel(){
        livesLabel.text = "Lives : \(lives)"
        livesLabel.fontSize = 70
        livesLabel.fontColor = .white
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.position = CGPoint(x: self.size.width*0.6, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
    }
    
    func lossALife(){
        lives -= 1
        livesLabel.text = "Live = \(lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if lives == 0 {
            runGameOver()
        }
    }
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 50 || gameScore == 100 || gameScore == 150 || gameScore == 200 || gameScore == 250 {
            startNewLevel()
        }
    }
    
    func startNewLevel(){
        levelNumber += 1
        
        if self.action(forKey: "spawingEnemies") != nil {
            self.removeAction(forKey: "spawingEnemies")
        }
        
        var levelDuaration = TimeInterval()
        
        switch levelNumber{
        case 1: levelDuaration = 1.5
        case 2: levelDuaration = 1.2
        case 3: levelDuaration = 1
        case 4: levelDuaration = 0.8
        default: levelDuaration = 0.5
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuaration)
        let spawnSequesnce = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequesnce)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(0.05)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveBy(x: 0, y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    private func spawnEnemy() {
        let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 1.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(0.25)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 3)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        if currentGameState == gameState.playgame{
            enemy.run(enemySequence)
        }
    }
    
    func startGameNow(){
        currentGameState = gameState.playgame
        
        let fadeOut = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, deleteAction])
        tapToStartLabel.run(deleteSequence	)
        
        let moveShipOntoScreen = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevel = SKAction.run(startNewLevel)
        let gameSequence = SKAction.sequence([moveShipOntoScreen, startLevel])
        player.run(gameSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.startGame {
            startGameNow()
        }
        
        else if currentGameState == gameState.playgame{
            fireBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let pointOfTouch = touch.location(in: self)
        let previousPointOfTouch = touch.previousLocation(in: self)
        
        let amountDragged = pointOfTouch.x - previousPointOfTouch.x
        if currentGameState == gameState.playgame{
            player.position.x += amountDragged
        }
        
        if player.position.x < CGRectGetMinX(gameArea) {
            player.position.x = CGRectGetMinX(gameArea)
        } else if player.position.x > CGRectGetMaxX(gameArea) {
            player.position.x = CGRectGetMaxX(gameArea)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if(body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy){
            
            spawnExplosion(spawnPosition: body1.node!.position)
            spawnExplosion(spawnPosition: body2.node!.position)
            
            lossALife()
            
            body2.node!.removeFromParent()
        }
        
        if(body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && body2.node!.position.y < self.size.height){
            
            spawnExplosion(spawnPosition: body2.node!.position)
            addScore()
            body1.node!.removeFromParent()
            body2.node!.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0.5)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(by: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSound = SKAction.playSoundFileNamed("explosion-91872", waitForCompletion: false)
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func runGameOver(){
        currentGameState = gameState.endgame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") { bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy") { enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSequence)
    }
    
    func changeScene(){
        let sceneMoveTo = GameOverScene(size: self.size)
        sceneMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneMoveTo, transition: myTransition)
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMoveperSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMoveperSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") { background, stop in
            
            if self.currentGameState == gameState.playgame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
    }
}
