//
//  MainTabBarController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    @IBAction func profilesClicked() {
        self.performSegue(withIdentifier: "ShowProfiles", sender: self)
    }
}
