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

@interface NSObject (SilhouetteReporterDelegateInformalProtocol)

- (BOOL)reporterMaySendProfile:(SilhouetteReporter *)reporter;

- (NSString *)feedURLStringForReporter:(SilhouetteReporter *)reporter;

- (NSArray *)feedParametersForReporter:(SilhouetteReporter *)reporter sendingSystemProfile:(BOOL)sendingProfile;

@end

#define SIL_DELAY 300