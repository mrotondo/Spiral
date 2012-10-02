//
//  SDViewController.m
//  SpiralDemo
//
//  Created by Mike Rotondo on 6/15/12.
//  Copyright (c) 2012 Tree. All rights reserved.
//

#import "SDViewController.h"
#import "SPParticleManager.h"
#import "SDParticle.h"
#import "SPGLKitHelper.h"
#import "SPEffectsManager.h"
#import "SPGeometricPrimitives.h"
#import "SPOffscreenRenderTarget.h"
#import "SPSoftParticleEffect.h"

@interface SDViewController () {
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation SDViewController
{
    SPParticleManager *particleManager;
    GLKTextureInfo *particleTexture;
    NSArray *particles;
    
    SPOffscreenRenderTarget *depthTarget;
    
    NSTimeInterval totalTimeElapsed;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [self setupParticles];
    
    depthTarget = [[SPOffscreenRenderTarget alloc] initWithTextureSize:GLKVector2Make(256, 256) depthOnly:YES];
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
    
    NSLog(@"About to initialize shared effects manager");
    [SPEffectsManager initializeSharedEffectsManager];
    NSLog(@"Done initializing shared effects manager");
    
    [SPGeometricPrimitives initializeSharedGeometricPrimitives];
}

- (void)setupParticles
{
    particleTexture = [SDParticle loadTexture];
    
    particleManager = [[SPParticleManager alloc] initWithTexture:particleTexture.name];
    
    int numParticles = 1;
    NSMutableArray *mutableParticles = [NSMutableArray arrayWithCapacity:numParticles];
    for (int i = 0; i < numParticles; i++)
    {
        SDParticle *particle = [[SDParticle alloc] init];
//        particle.scales = GLKVector3MultiplyScalar([SPGLKitHelper randomGLKVector3], 0.1);
        float scale = 4.0 + 2.0 * (arc4random() / (float)0x100000000);
        particle.baseScales = GLKVector3Make(scale, scale, 1);
        particle.basePosition = GLKVector3Add(GLKVector3Make(-2.5, -2.5, 0.5),
                                          GLKVector3MultiplyScalar([SPGLKitHelper randomGLKVector3], 5));
        particle.basePosition = GLKVector3Make(2, 2, 0);
        particle.baseColor = GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1.0);
        
        [mutableParticles addObject:particle];
        
    }
    particles = mutableParticles;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [SPEffectsManager destroySharedEffectsManager];
    [SPGeometricPrimitives destroySharedGeometricPrimitives];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    totalTimeElapsed += self.timeSinceLastUpdate;
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 1.0f, 10.0f);
    [[SPEffectsManager sharedEffectsManager] setProjectionMatrix:perspectiveMatrix];
    [[SPEffectsManager sharedEffectsManager] setModelViewMatrix:GLKMatrix4Identity];
    
    for (SDParticle *particle in particles) {
        particle.position = GLKVector3Add(particle.basePosition, GLKVector3Make(0, 0, totalTimeElapsed * 0.7));
        particle.color = particle.baseColor; //GLKVector4MultiplyScalar(particle.baseColor, 0.5 * (1 + sinf(totalTimeElapsed)) );
        particle.scales = particle.baseScales;
    }
}

- (void)drawScene
{
    glEnable(GL_DEPTH_TEST);
    [self drawShapes];
    
    glDisable(GL_DEPTH_TEST);
    [self drawParticles];

    glEnable(GL_DEPTH_TEST);
    [self drawShapes];
}

- (void)drawParticles
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [particleManager drawParticles:particles];
    glDisable(GL_BLEND);
}

- (void)drawShapes
{
    float rotation = totalTimeElapsed * 0.5;
    GLKMatrix4 circleTransform = GLKMatrix4Identity;
    circleTransform = GLKMatrix4Translate(circleTransform, 0, 0, -4);
    circleTransform = GLKMatrix4Rotate(circleTransform, rotation, 0, 1, 0);
    
    [SPGeometricPrimitives drawCircleWithColor:GLKVector4Make(1, 0, 0, 1) andModelViewMatrix:circleTransform];
    
    GLKMatrix4 quadTransform = GLKMatrix4Identity;
    quadTransform = GLKMatrix4Translate(quadTransform, 0, 0, -4);
    quadTransform = GLKMatrix4Rotate(quadTransform, rotation * 2, 1, 0, 0);
    
    [SPGeometricPrimitives drawQuadWithColor:GLKVector4Make(0, 1, 0, 1) andModelViewMatrix:quadTransform];
    
    GLKMatrix4 triTransform = GLKMatrix4Identity;
    triTransform = GLKMatrix4Translate(triTransform, 0, 0, -4);
    triTransform = GLKMatrix4Rotate(triTransform, rotation * 4, 1, 0, 1);
    
    [SPGeometricPrimitives drawRegularPolygonWithNumSides:3 withColor:GLKVector4Make(0, 0, 1, 1) andModelViewMatrix:triTransform];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Draw the shapes in the center to the depth texture
    [depthTarget drawToTargetWithBlock:^{
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_DEPTH_BUFFER_BIT);

        glEnable(GL_DEPTH_TEST);
        [self drawShapes];
        glDisable(GL_DEPTH_TEST);
    }];
    
    // Set up the soft particle effect
    SPSoftParticleEffect *softParticleEffect = [SPSoftParticleEffect sharedInstance];
    softParticleEffect.viewportSize = GLKVector2MultiplyScalar(GLKVector2Make(self.view.bounds.size.width, self.view.bounds.size.height), self.view.contentScaleFactor);
    softParticleEffect.cameraRange = GLKVector2Make(1.0, 10.0);
    softParticleEffect.sceneDepthTexture.name = depthTarget.texture;
    
    // Draw the scene to the renderbuffer
    [self drawScene];

//    // Draw a quad displaying the depth texture
//    glDisable(GL_DEPTH_TEST);
//    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
//    [[SPEffectsManager sharedEffectsManager] setProjectionMatrix:orthoMatrix];
//
//    GLKMatrix4 textureQuadTransform = GLKMatrix4Identity;
//    textureQuadTransform = GLKMatrix4Translate(textureQuadTransform, -0.5, -0.5, 0);
//    
//    [SPGeometricPrimitives drawQuadWithTexture:depthTarget.texture andModelViewMatrix:textureQuadTransform];
}

@end
