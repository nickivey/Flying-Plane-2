//
//  MyScene.m
//
//

#import "MyScene.h"
#import "ViewController.h"
#import <float.h>
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MyScene () <SKPhysicsContactDelegate> {
    
    SKSpriteNode* _bird;
    SKSpriteNode* building;
    SKSpriteNode* plane;
    SKSpriteNode* coin;
    SKColor* _skyColor;
    SKTexture* _buildTexture1;
    SKTexture* _buildTexture2;
    SKTexture* _buildTexture3;
    SKTexture* _YellowPlane;
    SKTexture* _BluePlane;
    SKTexture* _coinTexture1;
    SKTexture* _coinTexture2;
    SKTexture* _coinTexture3;
    SKTexture* _coinTexture4;
    SKTexture* _coinTexture5;
    SKTexture* _coinTexture6;
    SKTexture* _coinTexture7;
    SKTexture* _coinTexture8;
    SKTexture* _coinTexture9;
    SKTexture* _coinTexture10;
    SKAction* _movePipesAndRemove;
    SKAction* _movePlaneAndRemove;
    SKAction* _moveCoinAndRemove;
    SKNode* _moving;
    SKNode* _buildings;
    SKNode* _planes;
    SKNode* _coins;
    BOOL _canRestart;
    SKLabelNode* _scoreLabelNode;
    SKLabelNode* _recentScoreNode;
    SKLabelNode* _highScoreNode;
    SKSpriteNode* _playButton;
    SKLabelNode* _LabelNode;
    SKSpriteNode* _ScoreNode;
    SKSpriteNode* _ScoreNode2;
    SKSpriteNode* _tapNode;
    SKSpriteNode* _gameOverNode;
    SKSpriteNode* _playAgainNode;
    NSInteger _score;
    NSInteger _finalScore;
    
    UIView *flash;
}
@end

@implementation MyScene


static const uint32_t birdCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t pipeCategory = 1 << 2;
static const uint32_t scoreCategory = 1 << 3;




-(id)initWithSize:(CGSize)size {

    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        localPlayer.authenticateHandler = ^(UIViewController *receivedViewController, NSError *error){        if (error == nil)
        {
            // Insert code here to handle a successful authentication.
            NSLog(@"Logged in.");
        }
        else
        {
            // Your application can process the error parameter to report the error to the player.
            NSLog(@"%@", [error description]);
        }
        };

        self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
        self.physicsWorld.contactDelegate = self;
        
        _skyColor = [SKColor colorWithRed:159.0/255.0 green:201.0/255.0 blue:235.0/255.0 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        
        _moving = [SKNode node];
        [self addChild:_moving];
        
        _buildings = [SKNode node];
        [_moving addChild:_buildings];
        _buildings.speed = 2;
        
        _coins = [SKNode node];
        [_moving addChild:_coins];
        _coins.speed = 2;
        
        _planes = [SKNode node];
        [self addChild:_planes];
        _planes.speed = 4;
        
        
        // Create ground
        
        SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
        groundTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
        SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
        SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
        
        for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
            // Create the sprite
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
            [sprite setScale:2.0];
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
            [sprite runAction:moveGroundSpritesForever];
            [_moving addChild:sprite];
        }
        
        // Create skyline
        
        SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"cityscape"];
        skylineTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
        SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
        SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
        
        for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
            [sprite setScale:1];
            sprite.zPosition = -20;
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size.height * 2);
            [sprite runAction:moveSkylineSpritesForever];
            [_moving addChild:sprite];
        }
        
        // Create ground physics container
        
        SKNode* dummy = [SKNode node];
        dummy.position = CGPointMake(0, groundTexture.size.height);
        dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height * 2)];
        dummy.physicsBody.dynamic = NO;
        dummy.physicsBody.categoryBitMask = worldCategory;
        [self addChild:dummy];
        
        // Create buildings
        _buildTexture1 = [SKTexture textureWithImageNamed:@"building1"];
        _buildTexture1.filteringMode = SKTextureFilteringNearest;
        _buildTexture2 = [SKTexture textureWithImageNamed:@"building2"];
        _buildTexture2.filteringMode = SKTextureFilteringNearest;
        _buildTexture3 = [SKTexture textureWithImageNamed:@"building3"];
        _buildTexture3.filteringMode = SKTextureFilteringNearest;
        
        //Create plane textures
        _YellowPlane = [SKTexture textureWithImageNamed:@"yellowplane"];
        _YellowPlane.filteringMode = SKTextureFilteringNearest;
        _BluePlane = [SKTexture textureWithImageNamed:@"blueplane"];
        _BluePlane.filteringMode = SKTextureFilteringNearest;

        //COIN TEXTURES
        _coinTexture1 = [SKTexture textureWithImageNamed:@"coin1"];
        _coinTexture1.filteringMode = SKTextureFilteringNearest;
        _coinTexture2 = [SKTexture textureWithImageNamed:@"coin2"];
        _coinTexture2.filteringMode = SKTextureFilteringNearest;
        _coinTexture3 = [SKTexture textureWithImageNamed:@"coin3"];
        _coinTexture3.filteringMode = SKTextureFilteringNearest;
        _coinTexture4 = [SKTexture textureWithImageNamed:@"coin4"];
        _coinTexture4.filteringMode = SKTextureFilteringNearest;
        _coinTexture5 = [SKTexture textureWithImageNamed:@"coin5"];
        _coinTexture5.filteringMode = SKTextureFilteringNearest;
        _coinTexture6 = [SKTexture textureWithImageNamed:@"coin6"];
        _coinTexture6.filteringMode = SKTextureFilteringNearest;
        _coinTexture7 = [SKTexture textureWithImageNamed:@"coin7"];
        _coinTexture7.filteringMode = SKTextureFilteringNearest;
        _coinTexture8 = [SKTexture textureWithImageNamed:@"coin8"];
        _coinTexture8.filteringMode = SKTextureFilteringNearest;
        _coinTexture9 = [SKTexture textureWithImageNamed:@"coin9"];
        _coinTexture9.filteringMode = SKTextureFilteringNearest;
        _coinTexture10 = [SKTexture textureWithImageNamed:@"coin10"];
        _coinTexture10.filteringMode = SKTextureFilteringNearest;
        
        SKTexture* birdTexture1 = [SKTexture textureWithImageNamed:@"airplane"];
        birdTexture1.filteringMode = SKTextureFilteringNearest;
        
        
        
        _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture1];
        [_bird setScale:0.1];
        _bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        
        
        _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
        _bird.physicsBody.dynamic = YES;
        _bird.physicsBody.allowsRotation = NO;
        _bird.physicsBody.categoryBitMask = birdCategory;
        _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
        _bird.physicsBody.contactTestBitMask = worldCategory | pipeCategory;
        
        
        _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"playButton"];
        _playButton.position = CGPointMake( CGRectGetMidX( self.frame ) -80, 3 * self.frame.size.height / 4 - 105);
        _playButton.zPosition = 100;
        _playButton.name = @"play";
        [_playButton setScale:0.4];
        [self addChild:_playButton];
        
        _ScoreNode = [SKSpriteNode spriteNodeWithImageNamed:@"scoreButton"];
        _ScoreNode.position = CGPointMake( CGRectGetMidX( self.frame )+70, 3 * self.frame.size.height / 4 -105);
        _ScoreNode.zPosition = 100;
        _ScoreNode.name = @"score";
        [_ScoreNode setScale:0.4];
        
        [self addChild:_ScoreNode];
        
        _LabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _LabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 );
        _LabelNode.zPosition = 100;
        _LabelNode.fontSize = 40;
        _LabelNode.text = [NSString stringWithFormat:@"Flying Planes"];
        [self addChild:_LabelNode];
        
        
        _recentScoreNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _recentScoreNode.position = CGPointMake(CGRectGetMidX(self.frame) - 80, CGRectGetMidY(self.frame) + 80);
        _recentScoreNode.zPosition = 100;
        _recentScoreNode.fontSize = 28;
        

        _highScoreNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _highScoreNode.position = CGPointMake(CGRectGetMidX(self.frame) + 75, CGRectGetMidY(self.frame) + 80);
        _highScoreNode.zPosition = 100;
        _highScoreNode.fontSize = 28;
        _highScoreNode.text = [NSString stringWithFormat:@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"hiScore"]];
                               
        _tapNode = [SKSpriteNode spriteNodeWithImageNamed:@"tap"];
        _tapNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame
                                                                                 ));
        _tapNode.zPosition = 100;
        _tapNode.name = @"tap";
        
        _gameOverNode = [SKSpriteNode spriteNodeWithImageNamed:@"gameOver"];
        _gameOverNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame
                                                                                      ) + 80);
        _gameOverNode.zPosition = 99;
        [_gameOverNode setScale:.7];
        
        _ScoreNode2 = [SKSpriteNode spriteNodeWithImageNamed:@"scoreButton"];
        _ScoreNode2.position = CGPointMake(CGRectGetMidX(self.frame) + 70, CGRectGetMidY(self.frame) + 30);
        _ScoreNode2.zPosition = 100;
        _ScoreNode2.name = @"score";
        [_ScoreNode2 setScale: .35];
        
        _playAgainNode = [SKSpriteNode spriteNodeWithImageNamed:@"playAgainButton"];
        _playAgainNode.position = CGPointMake(CGRectGetMidX(self.frame) - 70, CGRectGetMidY(self.frame) + 30);
        _playAgainNode.zPosition = 100;
        _playAgainNode.name = @"Again";
        [_playAgainNode setScale: .35];
        
       
    }
    return self;
}
- (void) reportHighScore:(NSInteger) highScore {
    NSLog(@"reported");

    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKScore* Rscore = [[GKScore alloc] initWithLeaderboardIdentifier:@"hiScore"];
        Rscore.value = highScore;
        [GKScore reportScores:@[Rscore] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@",[error localizedDescription]);
            }
        }];
    }
}

-(void)startGame {
  
    _canRestart = NO;
    [self addChild:_bird];
    
    //MOVWE BIULDING
    CGFloat distanceToMove = self.frame.size.width + 2 * _buildTexture1.size.width;
    SKAction* movePipes = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
    SKAction* removePipes = [SKAction removeFromParent];
    _movePipesAndRemove = [SKAction sequence:@[movePipes, removePipes]];
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnBuilding) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:4.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
    
    //MOVE COIN
    
    
    CGFloat distanceToMoveCoin = self.frame.size.width + 2 * _buildTexture1.size.width + 90;//Changed so doesnt disappear
    SKAction* moveCoin = [SKAction moveByX:-distanceToMoveCoin y:0 duration:0.01 * distanceToMoveCoin];
    SKAction* removeCoin = [SKAction removeFromParent];
    _moveCoinAndRemove = [SKAction sequence:@[moveCoin, removeCoin]];
    
    SKAction* spawnCoin = [SKAction performSelector:@selector(spawnCoin) onTarget:self];
    SKAction* delayCoin = [SKAction waitForDuration:4.0];
    SKAction* spawnThenDelayCoin = [SKAction sequence:@[spawnCoin, delayCoin]];
    SKAction* spawnThenDelayForeverCoin = [SKAction repeatActionForever:spawnThenDelayCoin];
    [self runAction:spawnThenDelayForeverCoin];
    
    //MOVE PLANE
    float planeDelay = [self randomFloatBetween:2.4 :3.3];
    
    
    CGFloat distanceToMovePlane = self.frame.size.width + 2 * _buildTexture1.size.width;
    SKAction* movePlane = [SKAction moveByX:-distanceToMovePlane y:0 duration:0.01 * distanceToMovePlane];
    SKAction* removePlane = [SKAction removeFromParent];
    _movePlaneAndRemove = [SKAction sequence:@[movePlane, removePlane]];
    
    SKAction* spawnPlane = [SKAction performSelector:@selector(spawnPlane) onTarget:self];
    SKAction* delayPlane = [SKAction waitForDuration:planeDelay];
    SKAction* spawnThenDelayPlane = [SKAction sequence:@[spawnPlane, delayPlane]];
    SKAction* spawnThenDelayForeverPlane = [SKAction repeatActionForever:spawnThenDelayPlane];
    [self runAction:spawnThenDelayForeverPlane];
    
    // Initialize label and create a label which holds the score
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
    _scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 3 * self.frame.size.height / 4 + 75 );
    _scoreLabelNode.zPosition = 100;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabelNode];
}
-(float) randomFloatBetween:(float)smallNumber :(float)bigNumber
{
    float diff = bigNumber - smallNumber;
    return (((float) rand() / RAND_MAX) * diff) + smallNumber;
}
-(void)spawnBuilding {
    SKNode* buildingNode = [SKNode node];
    buildingNode.position = CGPointMake( self.frame.size.width + _buildTexture1.size.width, 0 );
    buildingNode.zPosition = -10;

    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 2.5 );
    int rand = arc4random() % 3;
    
    
    //Buildings
    if (rand == 0) {
        building = [SKSpriteNode spriteNodeWithTexture:_buildTexture1];
    } else if (rand == 1) {
        building = [SKSpriteNode spriteNodeWithTexture:_buildTexture2];
    } else {
        building = [SKSpriteNode spriteNodeWithTexture:_buildTexture3];
    }

        [building setScale:1];

    
    building.position = CGPointMake( 0, y );
    building.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:building.size]; //TODO test shorting it
    building.physicsBody.dynamic = NO;
    building.physicsBody.categoryBitMask = pipeCategory;
    building.physicsBody.contactTestBitMask = birdCategory;
    [buildingNode addChild:building];
    [buildingNode runAction:_movePipesAndRemove];
    [_buildings addChild:buildingNode];

}

-(void)spawnCoin {

    SKNode* coinNode = [SKNode node];
    coinNode.position = CGPointMake(self.frame.size.width + _buildTexture1.size.width + 180 + (arc4random() % 100), 0 );
    coinNode.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 2 ) + 140;
    
    SKAction* spin = [SKAction repeatActionForever:[SKAction animateWithTextures:@[ _coinTexture1, _coinTexture2, _coinTexture3, _coinTexture4, _coinTexture5, _coinTexture6, _coinTexture7, _coinTexture8, _coinTexture9, _coinTexture10] timePerFrame:0.05]];
    coin = [SKSpriteNode spriteNodeWithTexture:_coinTexture10];
    [coin runAction:spin];
   
    
    [coin setScale:1];
    coin.position = CGPointMake( 0, y );
    
     // NSLog(@"%f, %f", coin.position.x, coin.position.y);
    coin.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:coin.size];
    coin.physicsBody.dynamic = NO;
    coin.physicsBody.categoryBitMask = scoreCategory;
    coin.physicsBody.contactTestBitMask = birdCategory;
    [coinNode addChild:coin];
    [coinNode runAction:_moveCoinAndRemove];
    [_coins addChild:coinNode];

    
}

-(void)spawnPlane {
    NSLog(@"%f, %f", plane.position.x, plane.position.y);
 
    SKNode* planeNode = [SKNode node];
    planeNode.position = CGPointMake( self.frame.size.width + _buildTexture1.size.width, 0 );
    planeNode.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 2.5) + building.size.height + 40;
    int rand = arc4random() % 2;
    
    //PLane
    if (rand == 1) {
        plane = [SKSpriteNode spriteNodeWithTexture:_YellowPlane];
    }else {
        plane = [SKSpriteNode spriteNodeWithTexture:_BluePlane];
    }
    
    if (IS_WIDESCREEN) {
        [plane setScale:0.2];
    } else {
        [plane setScale:0.15];
    }
   

    
    plane.position = CGPointMake(0, y);
 //   NSLog(@"%f, %f", plane.position.x, plane.position.y);

    plane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:plane.size];
    plane.physicsBody.dynamic = NO;
    plane.physicsBody.categoryBitMask = pipeCategory;
    plane.physicsBody.contactTestBitMask = birdCategory;
    [planeNode addChild:plane];
    [planeNode runAction:_movePlaneAndRemove];
    [_planes addChild:planeNode];
    
    
}
-(void)resetScene {
    [_gameOverNode removeFromParent];
    [_ScoreNode2 removeFromParent];
    [_playAgainNode removeFromParent];
    [_recentScoreNode removeFromParent];
    [_highScoreNode removeFromParent];
    // Reset bird properties
    _bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
    _bird.physicsBody.velocity = CGVectorMake( 0, 0 );
    _bird.physicsBody.collisionBitMask = worldCategory | pipeCategory;
    _bird.speed = 1.0;
    _bird.zRotation = 0.0;
 
            _highScoreNode.text = [NSString stringWithFormat:@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"hiScore"]];
    
    // Remove all existing pipes
    [_buildings removeAllChildren];
    [_planes removeAllChildren];
    [_coins removeAllChildren];
    
    
    // Reset _canRestart
    _canRestart = NO;
    
    // Restart animation
    _moving.speed = 1;
    _planes.speed = 4;
    
    
    // Reset score
     [self addChild:_scoreLabelNode];
    _score = 0;
    _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:touchLocation];
    
    NSLog(@"node %@ was touched", node.name);
    
    if ([node.name hasPrefix:@"play"]) {
        //_playButtonNode.hidden = YES;
        [_playButton removeFromParent];
        [_LabelNode removeFromParent];
        [_ScoreNode removeFromParent];
        [self addChild:_tapNode];
        
    } else if ([node.name hasPrefix:@"tap"]) {
        [_tapNode removeFromParent];
           [self startGame];
    } else if ([node.name hasPrefix:@"Again"]) {
        [self resetScene];
    } else if ([node.name hasPrefix:@"score"]) {
        GKGameCenterViewController* gameCenterController = [[GKGameCenterViewController alloc] init];
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.gameCenterDelegate = (id)self;
        UIViewController *vc = self.view.window.rootViewController;
          [vc presentViewController: gameCenterController animated: YES completion:nil];
    }
    /* Called when a touch begins */
    if( _moving.speed > 0 ) {
        _bird.physicsBody.velocity = CGVectorMake(0, 0);
        [_bird.physicsBody applyImpulse:CGVectorMake(0, 8)];//6 before
    }
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if( _moving.speed > 0 ) {
             _bird.zRotation = clamp( -.9 , 0.1, _bird.physicsBody.velocity.dy * ( _bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
    }
}



- (void)didBeginContact:(SKPhysicsContact *)contact {
    if( _moving.speed > 0 ) {
        if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
            // Bird has contact with score entity
            
            SKNode* collectedCoin = contact.bodyA.node;
            [collectedCoin removeFromParent];
            
            _score++;
            _scoreLabelNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
            
            // Add a little visual feedback for the score increment
            [_scoreLabelNode runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
        } else {
            // Bird has collided with world
            [_scoreLabelNode removeFromParent];
             [self reportHighScore:_score];
            int hiScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"hiScore"];
            if (hiScore < _score) {
             [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"hiScore"];
               
            }
            _moving.speed = 0;
            
            _bird.physicsBody.collisionBitMask = worldCategory;
            
            [_bird runAction:[SKAction rotateByAngle:M_PI * _bird.position.y * 0.01 duration:_bird.position.y * 0.003] completion:^{
                _bird.speed = 0;
            }];
            _planes.speed = 0;
            
            
            flash = [[UIView alloc] initWithFrame:self.view.frame];
            flash.backgroundColor = [UIColor redColor];
            flash.alpha = .9;
            [self.view insertSubview:flash belowSubview:self.view];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setDuration:0.05];
            [animation setRepeatCount:4];
            [animation setAutoreverses:YES];
            [animation setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.view  center].x - 4.0f, [self.view  center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.view  center].x + 4.0f, [self.view  center].y)]];
            [[self.view layer] addAnimation:animation forKey:@"position"];
            
            
            [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
              
                // Display game over
                flash.alpha = 0;
              //  self.gameOverView.alpha = 1;
            //    self.gameOverView.transform = CGAffineTransformMakeScale(1, 1);
           //
               /* // Set medal
                if(scene.score >= 40){
                    self.medalImageView.image = [UIImage imageNamed:@"medal_platinum"];
                }else if (scene.score >= 30){
                    self.medalImageView.image = [UIImage imageNamed:@"medal_gold"];
                }else if (scene.score >= 20){
                    self.medalImageView.image = [UIImage imageNamed:@"medal_silver"];
                }else if (scene.score >= 10){
                    self.medalImageView.image = [UIImage imageNamed:@"medal_bronze"];
                }else{
                    self.medalImageView.image = nil;
                }
                
                // Set scores
                self.currentScore.text = F(@"%li",(long)scene.score);
                self.bestScoreLabel.text = F(@"%li",(long)[Score bestScore]);
                */
            } completion:^(BOOL finished) {
                _recentScoreNode.text = [NSString stringWithFormat:@"%ld", (long)_score];
                flash.userInteractionEnabled = NO;
                [self addChild:_playAgainNode];
                [self addChild:_ScoreNode2];
                [self addChild:_gameOverNode];
                [self addChild:_recentScoreNode];
                [self addChild:_highScoreNode];
                _canRestart = YES;
                
            }];
        }
    }
}
@end
