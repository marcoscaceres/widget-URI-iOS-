//
//  WidgetURIAppDelegate.m
//  WidgetURI
//
//  Created by Jimmy Ti on 21/09/11.
//  Copyright 2011 Jimmy Ti. All rights reserved.
//

#import "WidgetURIAppDelegate.h"

@implementation WidgetURIAppDelegate

@synthesize 
window = _window,
webView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect appBounds = [[UIScreen mainScreen] bounds];
    self.window = [[[UIWindow alloc] initWithFrame:appFrame] autorelease];
    self.webView = [[[UIWebView alloc] initWithFrame:appBounds] autorelease];
    
    // Override point for customization after application launch.
    [self.window addSubview:webView];
    [self.window makeKeyAndVisible];
    
    /* register our special protocol with webkit */
	[SpecialProtocol registerSpecialProtocol];
    
    /* load our main webpage.  You'll notice that in that file we
     load all of our images using the 'widget':// scheme (which
     generates the image files on the fly in memory).  */
	NSURL *mainWebPageURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    
	[webView loadRequest:[NSURLRequest requestWithURL:mainWebPageURL]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
