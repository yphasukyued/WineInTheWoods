import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()

        let vc = ViewController()
        window?.rootViewController = vc
        
        //let notifTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        //let notifSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notifTypes, categories: nil)
        //UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
        
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = UIColor(red: 51/255, green: 0/255, blue: 51/255, alpha: 1)
        UITabBar.appearance().tintColor = UIColor(red: 255/255, green: 0/255, blue: 128/255, alpha: 1)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

