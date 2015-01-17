//
//  AppDelegate.h
//  SilhouetteTouchDemo
//
//  Created by Fraser Hess on 1/16/15.
//  Copyright (c) 2015 Glencode LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SilhouetteReporter.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) SilhouetteReporter *reporter;

@end

