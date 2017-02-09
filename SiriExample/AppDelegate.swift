//
//  AppDelegate.swift
//  PassDemo
//
//  Created by Parth Dubal on 12/21/16.
//  Copyright © 2016 Parth Dubal. All rights reserved.
//
//com.demo.PassDemo
//com.demo.SiriDemo
import UIKit
import Intents
import CoreSpotlight

 @objc protocol Speaker : NSObjectProtocol
{
    func Speak()
    @objc optional func TellJoke()
}

class AppDelegateObj: NSObject
{
    var block:(_ obj:AppDelegateObj) -> Void?
    
    init(completion:@escaping (_ obj:AppDelegateObj) -> Void)
    {
        self.block = completion;
    }
    func someOperation() -> Void
    {
        print(":: **** ::someoperations::: at \(Date())");
        
        let okay = DispatchQueue.main;
        
        okay.asyncAfter(deadline: .now() + 5) {
            print("::::someoperations::: at \(Date())");
            self.block(self);
        }
        
        
        
        
    }
    deinit {
        
        print("AppDelegateObj \(#function)");
    }
    
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appObj : AppDelegateObj!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        let object  = AppDelegateObj { (obj:AppDelegateObj) in
            print("\(self.window)executing after completion at \(Date())");
            self.appObj = obj;
            self.okay();
        }
        object.someOperation();
        
        
        if #available(iOS 10.0, *) {
            INPreferences.requestSiriAuthorization { (status:INSiriAuthorizationStatus) in
                NSLog("siri status>> %d", status.rawValue);
            }
        }
        
        return true
    }

    func okay()
    {
        self.appObj = nil;
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        print("activity>>> \(userActivity)");
        
        if userActivity.activityType == CSSearchableItemActionType
        {
            
        }
        
        if userActivity.activityType == "app.open.times" {
            
            // Restore app state for this userActivity and associated userInfo value.
            let times = UserDefaults.standard.integer(forKey: KEY);
            let alert = UIAlertController(title: "great news", message: "app open times\(times)", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil));
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil);
        }
        
        return true
    }
}

