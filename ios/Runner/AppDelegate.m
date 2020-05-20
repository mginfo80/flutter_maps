#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import GoogleMaps

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  GMSService.provider.APIKEY("AIzaSyDhSFWXgokw-bhKfHzCSZ6BbWerycKYJQU")
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
