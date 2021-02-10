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
        ElementSDKConfiguration.shared().initialize(withConfigurationData: "YOUR_EAK")
        // change the theme if needed
        ElementSDKConfiguration.shared().theme = .selfieDot
#endif

        var vc : UIViewController? = nil
        vc = HomePageViewController()
        
        let navigationController = UINavigationController(rootViewController: vc!)
        
        self.window?.rootViewController = navigationController   
        return true
    }
}

