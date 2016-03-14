//
//  AppDelegate.swift
//  KisarazuTrafficSafetyMap
//
//  Created by Kouta on 2016/03/02.
//  Copyright © 2016年 Kouta. All rights reserved.
//

import UIKit
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // スリープの抑止
    var restrainSleep: Bool = false


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Notificationを削除
        UIApplication.sharedApplication().cancelAllLocalNotifications();
        //これがないとpermissionエラー
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // アプリ起動中(フォアグラウンド)に通知が届いた場合
        if (application.applicationState == UIApplicationState.Active) {
//            let dialog: UIAlertController = UIAlertController(title: "取締りエリア内に入りました", message: "", preferredStyle: .Alert)
//            let soundIdRing:SystemSoundID = 1002  // new-mail.caf
//            AudioServicesPlaySystemSound(soundIdRing)
            self.window?.rootViewController?.view.makeToast(message: "取締エリア内に入りました！")

//            self.window!.rootViewController?.presentViewController(dialog, animated: true) { () -> Void in
//                let delay = 2.0 * Double(NSEC_PER_SEC)
//                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                dispatch_after(time, dispatch_get_main_queue(), {
//                    self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
//                })
//            }
            print("アプリ起動中(フォアグラウンド)に通知が届いた場合")
            
            // アプリがバックグラウンドから復帰した場合
        } else if (application.applicationState == UIApplicationState.Inactive) {
            print("アプリがバックグラウンドから復帰した場合")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

