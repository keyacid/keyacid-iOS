//
//  EncryptViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/24/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class EncryptViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var signedAnonymous: UISegmentedControl!

    func getSelectedRemoteProfile() -> RemoteProfile? {
        if ProfilesTableViewController.selectedRemoteProfileIndex == -1 {
            let remoteProfileNotSelected: UIAlertController = UIAlertController.init(title: "Error", message: "You have to select a remote profile!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "ShowProfiles", sender: self)
            })
            remoteProfileNotSelected.addAction(OKAction)
            self.present(remoteProfileNotSelected, animated: true, completion: nil)
            return nil
        }
        return ProfilesTableViewController.remoteProfiles[ProfilesTableViewController.selectedRemoteProfileIndex]
    }

    func getSelectedLocalProfile() -> LocalProfile? {
        if ProfilesTableViewController.selectedLocalProfileIndex == -1 {
            let localProfileNotSelected: UIAlertController = UIAlertController.init(title: "Error", message: "You have to select a local profile!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "ShowProfiles", sender: self)
            })
            localProfileNotSelected.addAction(OKAction)
            self.present(localProfileNotSelected, animated: true, completion: nil)
            return nil
        }
        return ProfilesTableViewController.localProfiles[ProfilesTableViewController.selectedLocalProfileIndex]
    }

    @IBAction func encryptClicked() {
        let plainText: String = textView.text
        var cipherText: String = ""
        if plainText == "" {
            let empty: UIAlertController = UIAlertController.init(title: "Error", message: "You have to encrypt something!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.textView.becomeFirstResponder()
            })
            empty.addAction(OKAction)
            self.present(empty, animated: true, completion: nil)
            return
        }
        if signedAnonymous.selectedSegmentIndex == 0 {
            let remoteProfile: RemoteProfile? = getSelectedRemoteProfile()
            if remoteProfile == nil {
                return
            }
            let localProfile: LocalProfile? = getSelectedLocalProfile()
            if localProfile == nil {
                return
            }
            cipherText = Crypto.encrypt(data: plainText.data(using: String.Encoding.utf8)!, from: localProfile!, to: remoteProfile!).base64EncodedString()
            if cipherText == "" {
                let empty: UIAlertController = UIAlertController.init(title: "Error", message: "Corrputed profile!", preferredStyle: .alert)
                let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                empty.addAction(OKAction)
                self.present(empty, animated: true, completion: nil)
                return
            }
            textView.text = cipherText
        } else {
            let remoteProfile: RemoteProfile? = getSelectedRemoteProfile()
            if remoteProfile == nil {
                return
            }
            cipherText = Crypto.sealedEncrypt(data: plainText.data(using: String.Encoding.utf8)!, to: remoteProfile!).base64EncodedString()
            if cipherText == "" {
                let empty: UIAlertController = UIAlertController.init(title: "Error", message: "Corrputed profile!", preferredStyle: .alert)
                let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                empty.addAction(OKAction)
                self.present(empty, animated: true, completion: nil)
                return
            }
            textView.text = cipherText
        }
        UIPasteboard.general.string = cipherText
    }

    @IBAction func decryptClicked() {
        let cipher: Data? = Data.init(base64Encoded: textView.text)
        if cipher == nil {
            let notBase64: UIAlertController = UIAlertController.init(title: "Error", message: "Invalid cipher!", preferredStyle: .alert)
            let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            notBase64.addAction(OKAction)
            self.present(notBase64, animated: true, completion: nil)
            return
        }
        if signedAnonymous.selectedSegmentIndex == 0 {
            let remoteProfile: RemoteProfile? = getSelectedRemoteProfile()
            if remoteProfile == nil {
                return
            }
            let localProfile: LocalProfile? = getSelectedLocalProfile()
            if localProfile == nil {
                return
            }
            let plainText: String = String.init(data: Crypto.decrypt(data: cipher!, from: remoteProfile!, to: localProfile!), encoding: String.Encoding.utf8)!
            if plainText == "" {
                let empty: UIAlertController = UIAlertController.init(title: "Error", message: "Wrong profile or tampered data!", preferredStyle: .alert)
                let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                empty.addAction(OKAction)
                self.present(empty, animated: true, completion: nil)
                return
            }
            textView.text = plainText
        } else {
            let localProfile: LocalProfile? = getSelectedLocalProfile()
            if localProfile == nil {
                return
            }
            let plainText: String = String.init(data: Crypto.sealedDecrypt(data: cipher!, to: localProfile!), encoding: String.Encoding.utf8)!
            if plainText == "" {
                let empty: UIAlertController = UIAlertController.init(title: "Error", message: "Wrong profile or tampered data!", preferredStyle: .alert)
                let OKAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                empty.addAction(OKAction)
                self.present(empty, animated: true, completion: nil)
                return
            }
            textView.text = plainText
        }
    }
}
