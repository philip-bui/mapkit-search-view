//
//  AppDelegate.swift
//  Example
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func setRootViewController(viewController: UIViewController,
                               duration: TimeInterval = 0.7,
                               options: UIView.AnimationOptions? = .transitionCrossDissolve) {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("No window in app")
        }
        if let options = options, window.rootViewController != nil {
            UIView.transition(with: window, duration: duration,
                              options: options, animations: {
                                window.rootViewController = viewController
            })
        } else {
            window.rootViewController = viewController
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        setRootViewController(viewController: UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!)
        // Override point for customization after application launch.
        return true
    }
}
