//
//  AppDelegate.m
//  SilhouetteDemo
//
//  Created by Fraser Hess on 10/18/13.
//  Copyright (c) 2013 Glencode LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <Silhouette/SilhouetteReporter.h>
#import <Silhouette/SUConstants.h>

@implementation AppDelegate

+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *defaultsDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:SUSendProfileInfoKey];
	[defaults registerDefaults:defaultsDict];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	SilhouetteReporter *reporter = [SilhouetteReporter sharedReporter];
}

@end
