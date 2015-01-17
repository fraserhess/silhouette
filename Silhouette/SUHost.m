//
//  SUHost.m
//  Sparkle
//
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUHost.h"

#import "SUConstants.h"
#import "SUSystemProfiler.h"
#import <sys/mount.h> // For statfs for isRunningOnReadOnlyVolume
#import "SULog.h"


@implementation SUHost

- (id)initWithBundle:(NSBundle *)aBundle
{
	if ((self = [super init]))
	{
		if (aBundle == nil) aBundle = [NSBundle mainBundle];
        bundle = [aBundle retain];
		if (![bundle bundleIdentifier])
			SULog(@"Sparkle Error: the bundle being updated at %@ has no CFBundleIdentifier! This will cause preference read/write to not work properly.", bundle);

		defaultsDomain = [[bundle objectForInfoDictionaryKey:SUDefaultsDomainKey] retain];
		if (!defaultsDomain)
			defaultsDomain = [[bundle bundleIdentifier] retain];

		// If we're using the main bundle's defaults we'll use the standard user defaults mechanism, otherwise we have to get CF-y.
		usesStandardUserDefaults = [defaultsDomain isEqualToString:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return self;
}

- (void)dealloc
{
	[defaultsDomain release];
	[bundle release];
	[super dealloc];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [self bundlePath]]; }

- (NSBundle *)bundle
{
    return bundle;
}

- (NSString *)bundlePath
{
    return [bundle bundlePath];
}

- (NSString *)name
{
	NSString *name = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if (name) return name;
	
	name = [self objectForInfoDictionaryKey:@"CFBundleName"];
	if (name) return name;
	
	return [[[NSFileManager defaultManager] displayNameAtPath:[bundle bundlePath]] stringByDeletingPathExtension];
}

- (NSString *)version
{
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (!version || [version isEqualToString:@""])
		[NSException raise:@"SUNoVersionException" format:@"This host (%@) has no CFBundleVersion! This attribute is required.", [self bundlePath]];
	return version;
}

- (NSString *)displayVersion
{
	NSString *shortVersionString = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (shortVersionString)
		return shortVersionString;
	else
		return [self version]; // Fall back on the normal version string.
}

- (NSArray *)systemProfile
{
	return [[SUSystemProfiler sharedSystemProfiler] systemProfileArrayForHost:self];
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [bundle objectForInfoDictionaryKey:key];
}

- (BOOL)boolForInfoDictionaryKey:(NSString *)key
{
	return [[self objectForInfoDictionaryKey:key] boolValue];
}

- (id)objectForUserDefaultsKey:(NSString *)defaultName
{
	// Under Tiger, CFPreferencesCopyAppValue doesn't get values from NSRegistrationDomain, so anything
	// passed into -[NSUserDefaults registerDefaults:] is ignored.  The following line falls
	// back to using NSUserDefaults, but only if the host bundle is the main bundle.
	if (usesStandardUserDefaults)
		return [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
	
	CFPropertyListRef obj = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)defaultsDomain);
	return [(id)CFMakeCollectable(obj) autorelease];
}

- (void)setObject:(id)value forUserDefaultsKey:(NSString *)defaultName;
{
	if (usesStandardUserDefaults)
	{
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
	}
	else
	{
		CFPreferencesSetValue((CFStringRef)defaultName, value, (CFStringRef)defaultsDomain,  kCFPreferencesCurrentUser,  kCFPreferencesAnyHost);
		CFPreferencesSynchronize((CFStringRef)defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	}
}

- (BOOL)boolForUserDefaultsKey:(NSString *)defaultName
{
	if (usesStandardUserDefaults)
		return [[NSUserDefaults standardUserDefaults] boolForKey:defaultName];
	
	BOOL value;
	CFPropertyListRef plr = CFPreferencesCopyAppValue((CFStringRef)defaultName, (CFStringRef)defaultsDomain);
	if (plr == NULL)
		value = NO;
	else
	{
		value = (BOOL)CFBooleanGetValue((CFBooleanRef)plr);
		CFRelease(plr);
	}
	return value;
}

- (void)setBool:(BOOL)value forUserDefaultsKey:(NSString *)defaultName
{
	if (usesStandardUserDefaults)
	{
		[[NSUserDefaults standardUserDefaults] setBool:value forKey:defaultName];
	}
	else
	{
		CFPreferencesSetValue((CFStringRef)defaultName, (CFBooleanRef)[NSNumber numberWithBool:value], (CFStringRef)defaultsDomain,  kCFPreferencesCurrentUser,  kCFPreferencesAnyHost);
		CFPreferencesSynchronize((CFStringRef)defaultsDomain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	}
}

- (id)objectForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self objectForUserDefaultsKey:key] : [self objectForInfoDictionaryKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
    return [self objectForUserDefaultsKey:key] ? [self boolForUserDefaultsKey:key] : [self boolForInfoDictionaryKey:key];
}

+ (NSString *)systemVersionString
{
	// This returns a version string of the form X.Y.Z
	NSString *verStr = nil;
    NSString *versionPlistPath = @"/System/Library/CoreServices/SystemVersion.plist";
    verStr = [[NSDictionary dictionaryWithContentsOfFile:versionPlistPath] objectForKey:@"ProductVersion"];
	// We may get less than 3 parts, "10.9" for example
	NSArray *versionComponents = [verStr componentsSeparatedByString:@"."];
	switch ([versionComponents count]) {
		case 1:
			verStr = [verStr stringByAppendingString:@".0.0"];
			break;
		case 2:
			verStr = [verStr stringByAppendingString:@".0"];
			break;
		default:
			break;
	}
	return verStr;
}

@end
