//
//  Created by Brian Coyner on 7/8/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow()

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window?.rootViewController = UINavigationController(rootViewController: AdaptiveViewController())
        window?.makeKeyAndVisible()

        return true
    }
}
