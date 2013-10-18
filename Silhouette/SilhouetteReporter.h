//
//  SilhouetteReporter.h
//  Silhouette
//
//  Created by Fraser Hess on 10/16/13.
//  Copyright (c) 2013 Glencode LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUHost.h"

@interface SilhouetteReporter : NSObject {
	NSTimer *checkTimer;
	SUHost *host;
	IBOutlet id delegate;
}

+ (SilhouetteReporter *)sharedReporter;
- (void)setDelegate:(id)delegate;
- (id)delegate;

@end
