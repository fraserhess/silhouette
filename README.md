# Silhouette

## Sparkle profiling for the Mac App Store

### Background

Silhouette is a small framework that adds Sparkle profile reporting to a Mac App Store app with a single line of code.

The Sparkle software update framework optionally provides anonymous hardware profile reporting. Sparkle is not permitted in apps submitted to the Mac App Store but the hardware profiles of customer Macs are still of interest, especially to developers who use Sparkle's profiling in the non-MAS versions of their apps.

Silhouette provides the hardware profile reporting feature of Sparkle without the software update code that would get an app rejected from the MAS. Silhouette is designed to legitimately pass review for the MAS.

### How to

1. Download the code and build it yourself
1. Add to your Xcode project
1. link
1. Add this line of code
1. Add the SUFeedURL key to your Info.plist
1. Optionally, delegate blah, blah

### Notes

- Like Sparkle, Silhouette only sends hardware profiles once a week
- The webserver must return a non-zero length response to the profile submission
- While you can return the same appcast as you do to Sparkle, Silhouette will ignore it as it doesn't perform software updates.
- Runs on OS X Lion and later

### Credits

Silhouette was conceived of by Fraser Hess who is very much indebted to Andy Matuschak, who wrote Sparkle and to Tom Harrington, who added the hardware profiling features.