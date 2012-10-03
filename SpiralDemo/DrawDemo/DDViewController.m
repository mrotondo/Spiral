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
    NSMutableArray *shapes;
    NSMutableArray *paths;
    SPBezierPath *currentPath;
    
    NSTimeInterval totalTimeElapsed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    shapes = [NSMutableArray array];
    
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
    
    self.preferredFramesPerSecond = 60;
    
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

    glEnable(GL_DEPTH_TEST);
    glClearColor(0.25, 0.25, 0.25, 1.0);
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
    [currentPath interpolateWithMinimumSpacing:0.01];
    [self startNewPath];
}

- (void)startNewPath
{
    currentPath = [[SPBezierPath alloc] init];
    currentPath.color = GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1);
    currentPath.lineWidth = 0.1;
    [paths addObject:currentPath];
}

- (void)addPointFromTouch:(UITouch *)touch
{
    CGPoint touchLocationCGPoint = [touch locationInView:self.view];
    GLKVector2 touchLocation = GLKVector2Make(touchLocationCGPoint.x, touchLocationCGPoint.y);
    GLKVector2 lowerLeftOriginTouchLocation = GLKVector2Make(touchLocation.x, self.view.bounds.size.height - touchLocation.y);
    
    float z = (arc4random() / (float)0x100000000);
    GLKVector3 windowLocationWithZ = GLKVector3Make(lowerLeftOriginTouchLocation.x, lowerLeftOriginTouchLocation.y, z);
    
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
    
    DDTouchShape *shape = [DDTouchShape shapeWithLocation:worldSpaceLocationWithCorrectedZ andColor:[SPGLKitHelper randomGLKVector3] andNumSides:10 * (arc4random() / (float)0x100000000)];
    
    [shapes addObject:shape];
    
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
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw the scene to the renderbuffer
    [self drawScene];
}

- (void)drawScene
{
//    [self drawShapes];
    [self drawPaths];
}

- (void)drawPaths
{
    for (SPBezierPath *path in [paths reverseObjectEnumerator]) {
        [path strokeUsingModelViewMatrix:[SPEffectsManager sharedEffectsManager].modelViewMatrix];
    }
}

- (void)drawShapes
{
    for (DDTouchShape *shape in shapes)
    {
        GLKVector4 location = GLKVector4MakeWithVector3(shape.location, 1);
        location.z *= -1; // For translating the world correctly (as opposed to translating the point) (I'm confused about why I need to do this, see above comment after unprojecting)
        
        GLKMatrix4 shapeTransform = GLKMatrix4Identity;
        shapeTransform = GLKMatrix4TranslateWithVector4(shapeTransform, location);
        shapeTransform = GLKMatrix4Scale(shapeTransform, 0.1, 0.1, 1.0);
        
        [SPGeometricPrimitives drawRegularPolygonWithNumSides:shape.numSides
                                                    withColor:GLKVector4MakeWithVector3(shape.color, 1.0)
                                           andModelViewMatrix:shapeTransform];

//        [SPGeometricPrimitives drawQuadWithColor:GLKVector4MakeWithVector3(shape.color, 1.0)
//                              andModelViewMatrix:shapeTransform];
    }
}

@end
