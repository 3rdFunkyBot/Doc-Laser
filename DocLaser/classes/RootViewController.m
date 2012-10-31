//
//  RootViewController.m
//  DocLaser
//
//  Created by Chris Henderson on 10/31/12.
//  Copyright (c) 2012 Chris Henderson. All rights reserved.
//

#import "RootViewController.h"
#import "EAGLView.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)dealloc {
    
    [super dealloc];
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        self.view = [[[EAGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
