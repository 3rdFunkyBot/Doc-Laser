//
//  EAGLView.h
//  TwoFingerSpaceGod
//
//  Created by Chris Henderson on 2/17/10.
//  Copyright 2010 Massive Operations. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class BatchManager;
@class Director;
@class TouchManager;

/* This class is a UIView with the ability to render OpenGL ES. It will be responsible for:
 1. Running the main game loop (gameloop)
 2. Drawing the game to the scene.
 */
@interface EAGLView : UIView {
    
	// Pointer to the BatchManager Singleton
    BatchManager    *sharedBatchManager;
	
	// Pointer to the Director Singleton
	Director		*sharedDirector;
    
	// Pointer to the TouchManager Singleton
	TouchManager	*sharedTouchManager;
    
	// The bounds of the screen
	CGRect			screenBounds;
	
	// The pixel dimensions of the backbuffer - used in frame and view buffer initialization
	GLint			backingWidth;
	GLint			backingHeight;
	
	// A pointer to the OpenGL context all of our drawing will be referencing
	EAGLContext		*context;
	
	// Time since last frame was rendered
	CFTimeInterval	lastTime;
	
	// Used to calculate the game's current FPS
    float			_FPSCounter;
}

//**Put this function in BatchManager - which already handles all other OpenGL calls?
- (void) initOpenGL;

//The continually-running game loop
- (void) mainGameLoop;

//Draw everything to the screen. Ah yea.
- (void) renderGame;

@end

