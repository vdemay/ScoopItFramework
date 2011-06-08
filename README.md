# ScoopItFramework

## Description
A framework to use Scoop.it API on iOs

## Dependencies
ScoopItFramework uses 
*Three20 (https://github.com/facebook/three20 - more info here : http://three20.info/)

## How to create a new Project and use ScoopItFramework ?

### first of all check out the ScoopItFramework
Dowload or checkout ScoopItFramework 
	`git clone git://github.com/vdemay/ScoopItFramework.git`


Download or checkout Three20
	`git clone git://github.com/facebook/three20.git`


At this stage you should have something like that
	
	> ls
	ScoopItFramework	three20


Open XCode 4 and create a New Project (for the example "My App").
At this stage 
	
	>ls
	MyApp			ScoopItFramework	three20


Add three20 to your Project with the followed command
	
	>chmod u+x three20/src/scripts/ttmodule.py
	>three20/src/scripts/ttmodule.py -p MyApp/MyApp.xcodeproj Three20 --xcode-version=4


Then go back to XCode : your project has been updated with three20 dependencies
* Click on project name (My App)
* Choose the right Target
* Choose Build Phases Tab
* For each Three20*.a select Optional instead of Required

[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Three20Optional.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Three20Optional.png) 


Now import ScoopItFramework in your workspace drap'n'droping ScoopItFramework/ScoopItFramework/ScoopItFramework.xcodeproj onto the left xcode column. Xcode will ask you to create a workspace. Create it and save it. 
	$>ls 
	MyApp			MyWorspace.xcworkspace	ScoopItFramework	three20

[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Workspace.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Workspace.png)


Add the static library to the “Link Binary With Libraries” build phase.

[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/AddStatic.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/AddStatic.png)


We also need to make sure that our app’s build target can locate the public headers used in this static library. Open the “Build Settings” tab and locate the “User Header Search Paths” setting. Set this to “$(BUILT_PRODUCTS_DIR)”

[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/HeaderPath.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/HeaderPath.png)


While we are in "Build Setting" add -all_load in Other Linker Flag

[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Allload.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/Allload.png)


You can #import "ScoopItFramework/SIScoopIt.h" and build and start to play with the framework

#### MyAppAppDelegate.h
	#import <UIKit/UIKit.h>
	#import "ScoopItFramework/SIScoopIt.h"

	@interface MyAppAppDelegate : NSObject <UIApplicationDelegate, SIScoopItAuthorizationDelegate> {
	
	}	

	@property (nonatomic, retain) IBOutlet UIWindow *window;

	@end

#### MyAppAppDelegate.m
	<snip>
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
    		// Override point for customization after application launch.
    		[self.window makeKeyAndVisible];
    
   		 SIScoopIt *sis = [SIScoopIt sharedWithKey:@"my_key_getted_on_http://www.scoop.it/dev" 
                                    andSecret:@"my_secret_getted_on_http://www.scoop.it/dev"];
    		[sis getAuthorizationWithDelegate:self];
    
    		return YES;
	}
	<snip>


[![](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/iPad.png)](https://github.com/vdemay/ScoopItFramework/raw/master/Documents/iPad.png)


