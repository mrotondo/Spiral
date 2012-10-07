//
//  DDViewController.m
//  DrawingDemo
//
//  Created by Mike Rotondo on 6/15/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "DDViewController.h"
#import "SPGLKitHelper.h"
#import "SPEffectsManager.h"
#import "SPGeometricPrimitives.h"
#import "SPBezierPath.h"
#import "SPBlurEffect.h"
#import "SPOffscreenRenderTarget.h"

@interface DDTouchShape : NSObject

@property (nonatomic) GLKVector3 location;
@property (nonatomic) GLKVector3 color;
@property (nonatomic) int numSides;

+ (id)shapeWithLocation:(GLKVector3)location andColor:(GLKVector3)color andNumSides:(int)numSides;

@end

@implementation DDTouchShape

+ (id)shapeWithLocation:(GLKVector3)location andColor:(GLKVector3)color andNumSides:(int)numSides
{
    DDTouchShape *shape = [[DDTouchShape alloc] init];
    shape.location = location;
    shape.color = color;
    shape.numSides = numSides;
    return shape;
}

@end

@interface DDViewController () {
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation DDViewController
{
    NSMutableArray *paths;
    SPBezierPath *currentPath;
    
    NSTimeInterval totalTimeElapsed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    paths = [NSMutableArray array];
    [self startNewPath];
    
    totalTimeElapsed = 0;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.preferredFramesPerSecond = 30;
    
    [self setupGL];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [SPEffectsManager initializeSharedEffectsManager];
    
    [SPGeometricPrimitives initializeSharedGeometricPrimitives];

//    glEnable(GL_DEPTH_TEST);
    
    GLKView *glView = (GLKView *)self.view;
    glView.drawableMultisample = GLKViewDrawableMultisample4X;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [SPEffectsManager destroySharedEffectsManager];
    [SPGeometricPrimitives destroySharedGeometricPrimitives];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        [self addPointFromTouch:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        [self addPointFromTouch:touch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentPath interpolateWithMinimumSpacing:0.001];
    [self startNewPath];
}

- (void)startNewPath
{
    currentPath = [[SPBezierPath alloc] init];
    currentPath.color = GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1);
    currentPath.lineWidth = 0.004;
    [paths addObject:currentPath];
}

- (void)addPointFromTouch:(UITouch *)touch
{
    CGPoint touchLocationCGPoint = [touch locationInView:self.view];
    GLKVector2 touchLocation = GLKVector2Make(touchLocationCGPoint.x, touchLocationCGPoint.y);
    GLKVector2 lowerLeftOriginTouchLocation = GLKVector2Make(touchLocation.x, self.view.bounds.size.height - touchLocation.y);
    GLKVector2 lowerLeftOriginTouchLocationInOpenGLPixels = GLKVector2MultiplyScalar(lowerLeftOriginTouchLocation, self.view.contentScaleFactor);
    
    float z = (arc4random() / (float)0x100000000);
    GLKVector3 windowLocationWithZ = GLKVector3Make(lowerLeftOriginTouchLocationInOpenGLPixels.x, lowerLeftOriginTouchLocationInOpenGLPixels.y, z);
    
    int viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    bool success;
    
    GLKVector3 worldSpaceLocation = GLKMathUnproject(windowLocationWithZ,
                                                     [SPEffectsManager sharedEffectsManager].modelViewMatrix,
                                                     [SPEffectsManager sharedEffectsManager].projectionMatrix,
                                                     viewport,
                                                     &success);
    
    // Why does GLKMathUnproject give me back a point with z between -nearPlane and -farPlane???
    GLKVector3 worldSpaceLocationWithCorrectedZ = GLKVector3Multiply(worldSpaceLocation, GLKVector3Make(1, 1, -1));
    
    [currentPath addPointAt:GLKVector2MakeWithArray(worldSpaceLocation.v)];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    totalTimeElapsed += self.timeSinceLastUpdate;
    
//    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
//    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);
//    [[SPEffectsManager sharedEffectsManager] setProjectionMatrix:perspectiveMatrix];
    
    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-1, 1, -1, 1, -1, 1);
    [[SPEffectsManager sharedEffectsManager] setProjectionMatrix:orthoMatrix];
    
    [[SPEffectsManager sharedEffectsManager] setModelViewMatrix:GLKMatrix4Identity];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw the scene to the renderbuffer
    [self drawScene];
}

- (void)drawScene
{
    [self drawPaths];

//    SPBlurEffect *effect = [SPBlurEffect sharedInstance];
//    effect.amount = 10;
//    effect.scale = 1;
//    effect.strength = 1;
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_ONE, GL_ONE);
//    [[SPBlurEffect sharedInstance] drawBlurredBlock:^{
//        [self drawPaths];
//    }];
//    glDisable(GL_BLEND);
}

- (void)drawPaths
{
    for (SPBezierPath *path in [paths reverseObjectEnumerator]) {
        [path strokeUsingModelViewMatrix:[SPEffectsManager sharedEffectsManager].modelViewMatrix];
    }
}

@end
