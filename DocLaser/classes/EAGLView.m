//
//  EAGLView.m
//  TwoFingerSpaceGod
//
//  Created by Chris Henderson on 2/17/10.
//  Copyright 2010 Massive Operations. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <mach/mach.h>
#import <mach/mach_time.h>

#import "EAGLView.h"
#import "AbstractScene.h"
#import "Director.h"
#import "TouchManager.h"

@interface EAGLView ()

//Not sure why this is the only thing that needs a getter/setter - because it's the only variable that is an instance of a class
@property (nonatomic, retain) EAGLContext *context;

@end

@implementation EAGLView

@synthesize context;

- (void) dealloc {
	
	if( [EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	[super dealloc];
}

//This method must be implemented
+ (Class)layerClass {
	
	return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark Init Functions

- (id)initWithFrame:(CGRect)frame {
	
	if(( self = [super initWithFrame:frame])) {
        
		//Layer setup
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		
		//I need to research what all of this means - looks like I can use this if I don't want to use the default options (it works just fine without this call)
		//eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
		//								[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,
		//								kEAGLDrawablePropertyColorFormat, nil];
		
		//Context setup
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
        
		[self initOpenGL];
		
        sharedBatchManager      = [BatchManager sharedBatchManager];
		sharedDirector			= [Director sharedDirector];
		sharedTouchManager		= [TouchManager sharedTouchManager];
		
		lastTime = CFAbsoluteTimeGetCurrent();
	}
	
	return self;
}

- (void) initOpenGL {
	
	screenBounds = [[UIScreen mainScreen] bounds];
	
	//Switch to GL_PROJECTION matrix mode and reset the current matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	/* Landscape Mode Transformation */
	//This game will always be played in landscape, so rotate the entire view 90 degrees to the left
	//This is kind of abstract - but it will help me visualize the placement of objects better
	glRotatef(-90.0f, 0.0f, 0.0f, 1.0f);
	
    glOrthof(0.0f, screenBounds.size.height, 0.0f, screenBounds.size.width, -1.0f, 1.0f);
    
	//Switch to GL_MODELVIEW so we can now draw our objects
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	//Not sure what this is used for - need to research the final parameter - it can be used for blending and more
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_LINEAR);
	
	//Always disabled when drawing only 2D graphics
	glDisable(GL_DEPTH_TEST);
	
	//Set the colour to use when clearing the screen with glClear()
	//This can be grabbed from an external file
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f); //** change back to black when done testing tile set
	
	//2D OpenGL enabling calls specific for texture drawing - All of my drawing will use this
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_BLEND);
}

#pragma mark -
#pragma mark Main Game Loop

- (void) mainGameLoop {
	
	//Used to calculate the time that has passed since the last update
	CFTimeInterval		time;
	float				delta;
	
	const unsigned int DRAW_FREQUENCY = 1;
	unsigned int timesUpdated = 0;
	
    NSAutoreleasePool *pool;
    
	while(YES) {
        
        pool = [[NSAutoreleasePool alloc] init];
        
		// This trick is from iDevGames.com.  The command below pumps events which take place
        // such as screen touches etc so they are handled and then runs our code.  This means
        // that we are always in sync with VBL rather than an NSTimer and VBL being out of sync
        while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002, TRUE) == kCFRunLoopRunHandledSource);
		
		time = CFAbsoluteTimeGetCurrent();
		delta = (time - lastTime);
		
		//Update the game logic
		[[sharedDirector currentScene] updateWithDelta:delta];
		
		//Render the game
		timesUpdated++;
		if (timesUpdated >= DRAW_FREQUENCY)	{
			[self renderGame];
			timesUpdated = 0;
		}
        
		// Calculate the FPS
		_FPSCounter += delta;
		if(_FPSCounter > 0.25f) {
			_FPSCounter = 0;
			float _fps = (1.0f / (time - lastTime));
			//NSLog(@"FPS = %g", _fps);
			[sharedTouchManager setFPS:_fps];
		}
		
		lastTime = time;
        
        [pool release];
	}
}


- (void) renderGame {
	
    [sharedBatchManager renderGame];
}

#pragma mark -
#pragma mark Touch Delegation

// Pass on all touch events to the game controller including a reference to this view so we can get data
// about this view if necessary
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[[sharedDirector currentScene] updateWithTouchLocationBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	[[sharedDirector currentScene] updateWithTouchLocationMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[[sharedDirector currentScene] updateWithTouchLocationEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark Standard OpenGL Setup Methods
/*  The following 3 functions seem to be standard with no differentiation in code between different tutorials I've used */

/* Not sure what calls this, but it always gets called */
- (void) layoutSubviews {
	[EAGLContext setCurrentContext:context];
	
    [sharedBatchManager destroyFramebuffer];
    [sharedBatchManager createFramebufferWithContext:context andLayer:(CAEAGLLayer *)self.layer andBackingWidth:backingWidth andBackingHeight:backingHeight];
    [self renderGame];
}

@end



