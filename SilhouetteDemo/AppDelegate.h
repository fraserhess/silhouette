//
//  AppDelegate.h
//  SilhouetteDemo
//
//  Created by Fraser Hess on 10/18/13.
//  Copyright (c) 2013 Glencode LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Silhouette/SilhouetteReporter.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) SilhouetteReporter *reporter;

@end
