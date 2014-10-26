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
@private
	NSTimer *checkTimer;
	NSString *customUserAgentString;
	SUHost *host;
	NSOperationQueue *requestQueue;
	IBOutlet id delegate;
}

+ (SilhouetteReporter *)sharedReporter;

- (void)setDelegate:(id)delegate;
- (id)delegate;

- (void)setUserAgentString:(NSString *)userAgent;
- (NSString *)userAgentString;

@end

@interface NSObject (SilhouetteReporterDelegateInformalProtocol)

- (BOOL)reporterMaySendProfile:(SilhouetteReporter *)reporter;

- (NSString *)URLStringForReporter:(SilhouetteReporter *)reporter;

- (NSArray *)extraParametersForReporter:(SilhouetteReporter *)reporter sendingSystemProfile:(BOOL)sendingProfile;

@end

#define SIL_DELAY 300