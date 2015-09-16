# Eva Voice SDK - iOS 7+

Version 2.0

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Introduction](#introduction)
- [Step 1: Include the SDK in your Xcode project](#step-1-include-the-sdk-in-your-xcode-project)
- [Step 2: Initialize Eva Application](#step-2-initialize-eva-application)
- [Step 3: Add Chat Button to your GUI](#step-3-add-chat-button-to-your-gui)
  - [Method 1 - Interface Builder](#method-1---interface-builder)
  - [Method 2 - From Code using EVApplication](#method-2---from-code-using-evapplication)
  - [Method 3 - Use own button](#method-3---use-own-button)
- [Step 4: Implement one of Search Delegates](#step-4-implement-one-of-search-delegates)
- [More details](#more-details)
- [Support](#support)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

Voice enable your travel application in a couple of hours using the latest Eva Voice SDK.

With the new release you can add a cutting edge voice interface to your travel application with super simple integration.

Take advantage of the latest Deep Learning algorithms delivering near human precision.

The Eva Voice SDK comes batteries-included and has everything your application needs:

* Speech Recognition

* Natural Language Understanding

* Dialog Management

* Voice Chat user interface overlay

The beautiful user interface conforms to the latest Material Design guidelines and is fully customizable to match your application.

The SDK is open source. Fork us [on Github](https://github.com/evature/ios)!

## Step 1: Include the SDK in your Xcode project
1. Add EvaKit to your Podfile. If you don't need to deploy on iOS 7 then add `use_frameworks!` too.  
  ``` podfile
    pod 'EvaKit', :git => 'https://github.com/evature/ios.git', :branch => 'master'
  ```

2. Import EvaKit header in your App Delegate   
  ``` objc
  #import <EvaKit/EvaKit.h>
  ```

## Step 2: Initialize Eva Application
  ``` objc
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      // Set level of logging. See EVLogger.h.
      [EVLogger logger].logLevel = EVLoggerLogLevelInfo;
      // Provide API key and Site Code.
      [[EVApplication sharedApplication] setAPIKey:@"your-api-key" andSiteCode:@"your-site-code"];
      // Setup all needed Eva features here(text highlighting, connection timeouts and etc.). See EVApplication.h
      // Override point for customization after application launch.
      // < your initialization code here >
      return YES;
  }
  ```

## Step 3: Add Chat Button to your GUI  
### Method 1 - Interface Builder
  EvaKit uses new features of Xcode 6 so you can configure button and Chat View in Interface Builder.
  Add empty view inside your view and change its class to `EVVoiceChatButton`. You can setup all buttons and controller properties in Xcode. If no action added to button, button will show Chat View for current controller by default.

### Method 2 - From Code using EVApplication
  ``` objc
  - (void)viewDidLoad {
      [super viewDidLoad];
      // Create and add button to view of current controller
      EVVoiceChatButton* button = [[EVApplication sharedApplication] addButtonInController:self];
      //Pin button to bottom
      [button ev_pinToBottomCenteredWithOffset:90.0f];
      // Set some button or chat view settings. See EVVoiceChatButton.h
      button.micLineWidth = 3.0f;
      button.chatControllerSpeakEnabled = NO;
      button.chatToolbarCenterButtonMicLineWidth = 2.0f;
  }
  ```
  
### Method 3 - Use own button
  Call this method of EVApplication for Chat View popup
  ``` objc
  [[EVApplication sharedApplication] showChatViewController:self withViewSettings:@{}];
  ```
  Where View Settings is a `NSDictionary` with Chat View and Chat Toolbar settings.
  Chat View parameters can be provided with `controller.` prefix. Chat Toolbar parameters with `toolbar.` prefix. All parameters can be obtained in `EVVoiceChatViewController.h` and `EVChatToolbarContentView.h`

## Step 4: Implement one of Search Delegates
  You can implement it in current View Controller or in Application Delegate. Also you can provide own object for this. If you want own object then set it to `chatControllerDelegate` property of Chat Button or provide as `controller.delegate` value in Settings Dictionary.  
  All Search Delegate protocols can be found in `Core/SearchModels/SearchDelegates` folder.

## More details

  More info about Eva can be obtained in Android SDK repository [Android GitHub Repository](https://github.com/evature/android)

  More methods and properties can be found in `EVApplication.h`, `EVVoiceChatButton.h`, `EVLogger.h`, `EVVoiceChatViewController.h`, `EVChatToolbarContentView.h`.

## Support

  We would love to hear from you. Ask us anything at [info@evature.com](mailto:info@evature.com)
