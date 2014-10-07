#Swift by example: Optimizely A/B Testing
This post is part of an ongoing series of short tutorials on how to achieve various things in Swift, the new programming language by Apple. 

As product manager, A/B testing is an important part of my process to figure out what things work for best for our users.  On the web we run multiple experiments at any time using Optimizely. This week I decided to try out Optimizely for iOS to understand what kind of experiments one can run on mobile apps.

This article explains the required steps you need to take to successfully run your own A/B test on your iOS app written in Swift. We will first set up the environment, then integrate the Optimizely SDK into our app and finally create a simple test. You can find the code for this example on [GitHub](https://github.com/IAmMalte/swift-example-optimizely)


##1. Set up your environment
To install and run the [Optimizely SDK](http://developers.optimizely.com/ios/) we are going to use [Cocoapods](http://cocoapods.org/). The SDK as well as Cocoapods require Ruby. I'm using Homebrew and I assume that Homebrew and Ruby are already installed on your system. If not you, [learn more Homebrew here](http://brew.sh/) and here are some [installation instructions for Ruby](http://coolestguidesontheplanet.com/upgrading-ruby-osx/)

You will need the latest version of Ruby to run the Optimizely buildscripts.  For me, running the following shell commands did the trick. As we will be using Cocoapods you might need to reinstall it after upgrading Ruby.

```bash
brew update && brew upgrade
gem update --system
gem install cocoapods 
```

##2. Install and configure Optimizely

The Optimizely SDK is available from Cocoapods and there is an [in-depth article on how to install the SDK using Cocoapods](http://developers.optimizely.com/ios/#using-cocoapods-3
) so I won't go into too much detail here. Basically you navigate to your project directory on the command line and run `pod init`. Afterwards edit the *Podfile*, add Optimizely as a dependency and run `pod install`. You will need to open the *xcworkspace* file in Xcode instead of the project file.

Now comes the interesting part. As the Optimizely SDK is written in Objective-C we need to add an Objective-C bridging header. You can achieve this by creating a new file on your project, selecting Objective-C as the file type, give it a random name and then confirm that you do want to create a bridging header. You can then delete the file with the random name you just created but do keep the bridging header file.

Open the bridging header file and add the following lines to get Optimizely to work:
```Swift
#import <UIKit/UIKit.h>
#import <Optimizely/Optimizely.h>
```

Next we need to initialize Optimizely in our app for which we will need an API token. To get this token, go to your [Optimizely Dashboard](https://www.optimizely.com/dashboard) and create an new project. Select iOS as the project type.

![iOS Project](http://cl.ly/image/0n2x3y2u3U2h/Bildschirmfoto%202014-10-07%20um%2013.43.31.png)

In the top right corner under Project Settings you will find the code to embed for Objective-C. As we are using Swift we cannot just use it out of the box. Copy the part after `[Optimizely startOptimizelyWithAPIToken: @"`. This is your API token. You should also write down your Project ID as we will need this in the next step.
                                                                                                                                                                                  
                                                                                                                                                                                  ![API Token](http://cl.ly/image/0l343F2m0i13/Bildschirmfoto%202014-10-07%20um%2013.44.22.png%202014-10-07%2019-02-35.png)

In Xcode open your *AppDelgate.swift* file add the following lines to the `didFinishLaunchingWithOptions` function and replace `YOUR_TOKEN_GOES_HERE` with your own API token

```Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
// Override point for customization after application launch.

// Launch Optimizely
Optimizely.startOptimizelyWithAPIToken("YOUR_TOKEN_GOES_HERE", launchOptions: launchOptions)

return true
}
```



To allow Optimizely users to create an experiment without the need for Xcode we also need to add a custom URL. To do so go to the *Info* section of the app settings and open the *URL Types* section.

![URL settings](http://cl.ly/image/1b3Z0I2i2g0A/Bildschirmfoto%202014-10-07%20um%2013.48.50.png%202014-10-07%2019-08-28.png)


Add a new URL type and enter *com.optimizely* as the identifier. Use *optly{PROJECT_ID}* as the URL Scheme, e.g. optly1234567

Now you can run your project for the fist time. The Optimizely Build phase of your project will label automatically all views with user defined runtime attributes that Optimizely uses internally. However, with iOS 8 Apple introduced the feature to use a XIB file as the launch screen. Unfortunately, the LaunchScreen is not allowed to have any user defined runtime attributes. So we need to make sure that your LaunchScreen.xib does not use any. There are two solutions: Either you do not use the LaunchScreen and delete if from your project. Or you need to disable the Optimizely Build Script. Go to the Build Phases of settings of your project and select "Label Optimizely views". You can disable the script temporarily by adding `exit 0` as the first line of your script
(found [here](http://stackoverflow.com/questions/1727148/how-to-temporarily-disable-a-run-script-phase-in-xcode)). 

![Build settings](http://cl.ly/image/0e3o2N0q3n26/Bildschirmfoto%202014-10-07%20um%2013.38.22.png)

Please note that whenever you add new views or elements to your app you need to re-enable this build phase once or tag your view manually.


Now you are ready to create your first experiment.


##3. Run experiments

###Simple experiments
Optimizely provides a very nice [guide on running experiments](https://help.optimizely.com/hc/en-us/articles/202296994).

###Live Variables
Optimizely provides Objective-C macros for creating live variables. Unfortunately these do not work with Swift, so we need to take a few simple steps to get them to work.

####1. Register your variable

Open your AppDelegate.swift and add the following code to register a variable. In the example I am registering a String but you can use many types of variables.

```Swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
// Override point for customization after application launch.

// Launch Optimizely
Optimizely.startOptimizelyWithAPIToken("YOUR_TOKEN_GOES_HERE", launchOptions: launchOptions)

// Define and register live variable with type String
var liveVariableKey:OptimizelyVariableKey = OptimizelyVariableKey.optimizelyKeyWithKey("myKey", defaultNSString: "myValue")
Optimizely.preregisterVariableKey(liveVariableKey)

return true
}
```


####2. Use the variable

To use the variable you can load it again at any point in your code. The following example uses a button.

```Swift
@IBAction func pressMe(sender: AnyObject) {

// Load live variable
var key = OptimizelyVariableKey.optimizelyKeyWithKey("myKey", defaultNSString: "myValue")
var liveVariable:String = Optimizely.stringForKey(key)

// Use the liveVariable
if(liveVariable == "VarA") {
var alert:UIAlertView = UIAlertView(title: "AB Test", message: "This alert only shows if liveVariable equals VarA", delegate: self, cancelButtonTitle: "Close")
alert.show()
}
}
```


###Code Blocks
Unfortunately I have not figured out how to use Code Blocks in Swift, yet. I will update this tutorial as soon as I figured it out. I currently use live variables with and if/else statement to emulate the behavior.



#Conclusion

I hope this tutorial helps you with the step stones you might encounter when trying to set up Optimizely with a Swift-based iOS app. Let me know what kind of tests you run and how you run them. I am always looking for input.

Also make sure to checkout this working example in GitHub: https://github.com/IAmMalte/swift-example-optimizely
