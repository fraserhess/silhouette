# Silhouette

## Sparkle profiling for the Mac App Store

### Background

Silhouette is a small framework that adds Sparkle hardware profile reporting to a Mac App Store app with a single line of code.

The Sparkle software update framework optionally provides anonymous hardware profile reporting. Sparkle is not permitted in apps submitted to the Mac App Store but the hardware profiles of customer Macs are still of interest, especially to developers who use Sparkle's profiling in the non-MAS versions of their apps.

Silhouette provides the hardware profile reporting feature of Sparkle without the software update code that would get an app rejected from the MAS. Silhouette is intended to legitimately pass review for the MAS.

### Server side

The server side is the same as [Sparkle's System Profiling](https://github.com/andymatuschak/Sparkle/wiki/system-profiling). I won't repeat the documentation for that here.

### Application side

1. Be sure to have a backup of your code and if possible branch before adding Silhouette
1. Download the code and build it yourself, signing it with your Mac App Store certificate
1. Drag the built framework into the Frameworks group of your app's Xcode project. Make sure your MAS target is selected and your non-MAS target isn't.
1. If you don't have a **Copy Frameworks** build phase for your MAS target, add one.
1. Add **Silhouette.framework** to your **Copy Frameworks** build phase
1. Add the following code, possibly using ```#ifdef``` to hide it from non-MAS builds:
    - In the app delegate's imports, ```#import <Silhouette/SilhouetteReporter.h>```
    - In the app delegate's properties, ```@property SilhouetteReporter *reporter;```
    - In the ```applicationDidFinishLaunching:```, ```_reporter = [SilhouetteReporter sharedReporter];```
1. Set the default _SUSendProfileInfo_ boolean preference
1. Add the _SUFeedURL_ key to your Info.plist. Alternatively, set a delegate and implement the ```URLStringForReporter:``` delegate method
1. Add **Allow Outgoing Network Connections** to your Sandbox Entitlements
1. Optionally, implement the other delegate methods
1. Make sure both MAS and non-MAS versions of your app still build and run successfully

### Notes

- Like Sparkle, Silhouette limits submitting a hardware profile to once a week
- The webserver must return a non-zero length response to the profile submission
- If the webserver returns the same appcast as it does to Sparkle, Silhouette will ignore the appcast as it doesn't perform software updates
- If you default _SUSendProfileInfo_ to NO, you'll have to provide an interface, perhaps in Preferences, for the customer to opt-in to hardware profiling
- Compiles with the OS X Mavericks SDK but should run on OS X Lion and later

### Delegate

#### ```- (BOOL)reporterMaySendProfile:(SilhouetteReporter *)reporter;```

Allows the delegate to prevent sending a profile at that moment. Sending is rescheduled for 5 minutes later.

#### ```- (NSString *)URLStringForReporter:(SilhouetteReporter *)reporter;```

Return the URL as a string. Can be used to configure the Silhouette endpoint or to override the _SUFeedURL_ value from the Info.plist.

#### ```- (NSArray *)extraParametersForReporter:(SilhouetteReporter *)reporter sendingSystemProfile:(BOOL)sendingProfile;```

Much like ```feedParametersForUpdater:sendingSystemProfile:``` in Sparkle, it adds extra values you wish to report on. This method should return an array of dictionaries with the keys, "key" and "value".

### Credits

Silhouette was conceived of by Fraser Hess who is very much indebted to Andy Matuschak, who wrote Sparkle and to Tom Harrington, who added the hardware profiling features.