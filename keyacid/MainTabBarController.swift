//
//  MainTabBarController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    static var profilesShown: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !MainTabBarController.profilesShown {
            MainTabBarController.profilesShown = true
            self.performSegue(withIdentifier: "ShowProfiles", sender: self)
        }
    }

    @IBAction func profilesClicked() {
        self.performSegue(withIdentifier: "ShowProfiles", sender: self)
    }
}
