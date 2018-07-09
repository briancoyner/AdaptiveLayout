//
//  Created by Brian Coyner on 7/8/18.
//  Copyright © 2018 High Rail, LLC. All rights reserved.
//

import Foundation

struct AdaptiveAction {

    let title: String
    let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}
