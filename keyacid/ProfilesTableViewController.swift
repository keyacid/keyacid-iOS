//
//  ProfilesTableViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class ProfilesTableViewController: UITableViewController {

    @IBAction func remoteProfilesAddClicked() {
        self.performSegue(withIdentifier: "ShowRemoteProfile", sender: self)
    }

    @IBAction func localProfilesAddClicked() {
        self.performSegue(withIdentifier: "ShowLocalProfile", sender: self)
    }
}
