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

@interface SDViewController () {
    GLKMatrix4 _modelViewProjectionMatrix;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    int numParticles = 20000;
    NSMutableArray *mutableParticles = [NSMutableArray arrayWithCapacity:numParticles];
    for (int i = 0; i < numParticles; i++)
    {
        SDParticle *particle = [[SDParticle alloc] init];
//        particle.scales = GLKVector3MultiplyScalar([SPGLKitHelper randomGLKVector3], 0.1);
        float scale = 0.1 * (arc4random() / (float)0x100000000);
        particle.scales = GLKVector3Make(scale, scale, 1);
        particle.position = GLKVector3Add(GLKVector3Make(-0.5, -0.5, -0.5),
                                          [SPGLKitHelper randomGLKVector3]);
        particle.color = GLKVector4MakeWithVector3([SPGLKitHelper randomGLKVector3], 1.0);
        
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
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 orthoMatrix = GLKMatrix4MakeOrtho(-0.6, 0.6, -0.6, 0.6, -1.0, 1.0);
    [[SPEffectsManager sharedEffectsManager] setProjectionMatrix:orthoMatrix];
    [[SPEffectsManager sharedEffectsManager] setModelViewMatrix:GLKMatrix4Identity];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.95f, 0.95f, 0.95f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    [particleManager drawParticles:particles];
//    glDisable(GL_BLEND);
}

@end
