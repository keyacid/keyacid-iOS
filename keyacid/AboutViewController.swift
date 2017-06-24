//
//  AboutViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/24/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var about: UITextView!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        about.setContentOffset(CGPoint.zero, animated: false)
    }
}
