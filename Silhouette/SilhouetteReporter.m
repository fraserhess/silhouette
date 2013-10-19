//
//  SilhouetteReporter.m
//  Silhouette
//
//  Created by Fraser Hess on 10/16/13.
//  Copyright (c) 2013 Glencode LLC. All rights reserved.
//

#import "SilhouetteReporter.h"
#import "SUConstants.h"

@implementation SilhouetteReporter

+ (SilhouetteReporter *)sharedReporter {
	static SilhouetteReporter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SilhouetteReporter alloc] init];
    });
    return sharedInstance;
}

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	host = [[SUHost alloc] initWithBundle:nil];
	[self performSelector:@selector(scheduleNextProfileSubmission) withObject:nil afterDelay:0];
	return self;
}

- (void)dealloc {
	[host release];
	if (checkTimer) { [checkTimer invalidate]; [checkTimer release]; checkTimer = nil; }		// UK 2009-03-16 Timer is non-repeating, may have invalidated itself, so we had to retain it.
	[super dealloc];
}

- (void)scheduleNextProfileSubmission
{
	if (checkTimer)
	{
		[checkTimer invalidate];
		[checkTimer release];		// UK 2009-03-16 Timer is non-repeating, may have invalidated itself, so we had to retain it.
		checkTimer = nil;
	}
	
	if (![self sendsSystemProfile]) {
		// If the user prefer we don't send a profile, schedule to check in 5 minutes if they changed the preference
		checkTimer = [[NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(scheduleNextProfileSubmission) userInfo:nil repeats:NO] retain];
		return;
	}

	// How long has it been since last we checked for an update?
	NSDate *lastCheckDate = [self lastUpdateCheckDate];
	if (!lastCheckDate) { lastCheckDate = [NSDate distantPast]; }
	NSTimeInterval intervalSinceCheck = [[NSDate date] timeIntervalSinceDate:lastCheckDate];
	
	// Now we want to figure out how long until we check again.
	NSTimeInterval delayUntilCheck, updateCheckInterval = [self updateCheckInterval];
	if (intervalSinceCheck < updateCheckInterval)
		delayUntilCheck = (updateCheckInterval - intervalSinceCheck); // It hasn't been long enough.
	else
		delayUntilCheck = 0; // We're overdue! Run one now.
	checkTimer = [[NSTimer scheduledTimerWithTimeInterval:delayUntilCheck target:self selector:@selector(submitProfile) userInfo:nil repeats:NO] retain];		// UK 2009-03-16 Timer is non-repeating, may have invalidated itself, so we had to retain it.
}

- (void)waitToSubmitAgain {
	[self performSelectorOnMainThread:@selector(scheduleNextProfileSubmission) withObject:nil waitUntilDone:NO];
}

- (void)submitProfile {
	NSURL *url = [self parameterizedFeedURL];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		if ([data length] > 0 && !error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[host setObject:[NSDate date] forUserDefaultsKey:SULastProfileSubmitDateKey];
				[self performSelector:@selector(scheduleNextProfileSubmission) withObject:nil afterDelay:0];
			});
		}
		if (([data length] == 0 && !error) ||
				 (!data && error)) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self performSelector:@selector(scheduleNextProfileSubmission) withObject:nil afterDelay:60];
			});
		}
	}];
}

- (NSURL *)feedURL // *** MUST BE CALLED ON MAIN THREAD ***
{
	// A value in the user defaults overrides one in the Info.plist (so preferences panels can be created wherein users choose between beta / release feeds).
	NSString *appcastString = [host objectForKey:SUFeedURLKey];
	if( [delegate respondsToSelector: @selector(feedURLStringForReporter:)] )
		appcastString = [delegate feedURLStringForReporter: self];
	if (!appcastString) // Can't find an appcast string!
		[NSException raise:@"SUNoFeedURL" format:@"You must specify the URL of the appcast as the SUFeedURL key in either the Info.plist or the user defaults!"];
	NSCharacterSet* quoteSet = [NSCharacterSet characterSetWithCharactersInString: @"\"\'"]; // Some feed publishers add quotes; strip 'em.
	NSString*	castUrlStr = [appcastString stringByTrimmingCharactersInSet:quoteSet];
	if( !castUrlStr || [castUrlStr length] == 0 )
		return nil;
	else
		return [NSURL URLWithString: castUrlStr];
}

- (NSURL *)parameterizedFeedURL
{
	NSURL *baseFeedURL = [self feedURL];
	
	// Determine all the parameters we're attaching to the base feed URL.
	BOOL sendingSystemProfile = [self sendsSystemProfile];
	
	
	NSArray *parameters = [NSArray array];
	if ([delegate respondsToSelector:@selector(feedParametersForReporter:sendingSystemProfile:)])
		parameters = [parameters arrayByAddingObjectsFromArray:[delegate feedParametersForReporter:self sendingSystemProfile:sendingSystemProfile]];
	if (sendingSystemProfile)
	{
		parameters = [parameters arrayByAddingObjectsFromArray:[host systemProfile]];
	}
	if ([parameters count] == 0) { return baseFeedURL; }
	
	// Build up the parameterized URL.
	NSMutableArray *parameterStrings = [NSMutableArray array];
	NSEnumerator *profileInfoEnumerator = [parameters objectEnumerator];
	NSDictionary *currentProfileInfo;
	while ((currentProfileInfo = [profileInfoEnumerator nextObject]))
		[parameterStrings addObject:[NSString stringWithFormat:@"%@=%@", [[[currentProfileInfo objectForKey:@"key"] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[[currentProfileInfo objectForKey:@"value"] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	NSString *separatorCharacter = @"?";
	if ([baseFeedURL query])
		separatorCharacter = @"&"; // In case the URL is already http://foo.org/baz.xml?bat=4
	NSString *appcastStringWithProfile = [NSString stringWithFormat:@"%@%@%@", [baseFeedURL absoluteString], separatorCharacter, [parameterStrings componentsJoinedByString:@"&"]];
	
	// Clean it up so it's a valid URL
	return [NSURL URLWithString:appcastStringWithProfile];
}

- (NSTimeInterval)updateCheckInterval
{
	return 60 * 60 * 24 * 7;
}

- (NSDate *)lastUpdateCheckDate
{
	return [host objectForUserDefaultsKey:SULastProfileSubmitDateKey];
}

- (BOOL)sendsSystemProfile
{
	return [host boolForUserDefaultsKey:SUSendProfileInfoKey];
}

- (void)setDelegate:aDelegate
{
	delegate = aDelegate;
}

- (id)delegate { return delegate; }

@end
