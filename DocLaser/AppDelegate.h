//
//  AppDelegate.h
//  DocLaser
//
//  Created by Chris Henderson on 10/30/12.
//  Copyright (c) 2012 Chris Henderson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    RootViewController *rootViewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
