//
//  ViewController.m
//  Flying Plane
//
//  Created by Nick Ivey on 2/26/14.
//  Copyright (c) 2014 Nick Ivey. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure the view.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    SKView * skView = (SKView *)self.view;
    skView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    skView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //skView.showsFPS = YES;
  //  skView.showsNodeCount = YES;
    [self.view sizeToFit];
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize: self.view.bounds.size];
    scene.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scene.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  //  scene.scaleMode = SKSceneScaleModeResizeFill;
   // scene.size = skView.bounds.size;
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



@end
