//
//  AppDelegateProtected.swift
//  demo
//
//  Created by Laurent Grandhomme on 9/13/16.
//  Copyright © 2016 Element. All rights reserved.
//

import UIKit

#if !(targetEnvironment(simulator))
import ElementSDK
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()

#if !(targetEnvironment(simulator))
        // TODO: replace YOUR_EAK with the EAK provided by Element
        let success = ElementSDKConfiguration.shared().initialize(withConfigurationData: "YOUR_EAK")
        assert(success, "Did your replace YOUR_EAK with your own EAK?")
        ElementSDKConfiguration.shared().enableDebugLogs = true
        // change the theme if needed
        ElementSDKConfiguration.shared().uiTheme = ELTThemeSelfieDotV2()
#endif

        var vc : UIViewController? = nil
        vc = HomePageViewController()
        
        let navigationController = UINavigationController(rootViewController: vc!)
        
        self.window?.rootViewController = navigationController   
        return true
    }
}
