//
//  ProfilesTableViewController.swift
//  keyacid
//
//  Created by Yuan Zhou on 6/22/17.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class ProfilesTableViewController: UITableViewController {

    static var remoteProfiles: [RemoteProfile] = []
    static var localProfiles: [LocalProfile] = []
    static var selectedRemoteProfileIndex: Int = -1
    static var selectedLocalProfileIndex: Int = -1

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == ProfilesTableViewController.remoteProfiles.count {
                return tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath)
            } else {
                let ret: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
                ret.textLabel?.text = ProfilesTableViewController.remoteProfiles[indexPath.row].name
                ret.detailTextLabel?.text = ProfilesTableViewController.remoteProfiles[indexPath.row].publicKey.base64EncodedString()
                if indexPath.row == ProfilesTableViewController.selectedRemoteProfileIndex {
                    ret.accessoryType = .checkmark
                } else {
                    ret.accessoryType = .none
                }
                return ret
            }
        } else if indexPath.section == 1 {
            if indexPath.row == ProfilesTableViewController.localProfiles.count {
                return tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath)
            } else {
                let ret: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
                ret.textLabel?.text = ProfilesTableViewController.localProfiles[indexPath.row].name
                ret.detailTextLabel?.text = ProfilesTableViewController.localProfiles[indexPath.row].publicKey.base64EncodedString()
                if indexPath.row == ProfilesTableViewController.selectedLocalProfileIndex {
                    ret.accessoryType = .checkmark
                } else {
                    ret.accessoryType = .none
                }
                return ret
            }
        }
        return UITableViewCell.init()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ProfilesTableViewController.remoteProfiles.count + 1
        } else if section == 1 {
            return ProfilesTableViewController.localProfiles.count + 1
        }
        return 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Remote Profiles"
        } else if section == 1 {
            return "Local Profiles"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == ProfilesTableViewController.remoteProfiles.count {
                self.performSegue(withIdentifier: "ShowRemoteProfile", sender: self)
            } else {
                if tableView.isEditing {
                    RemoteProfileTableViewController.showProfile = ProfilesTableViewController.remoteProfiles[indexPath.row]
                    self.performSegue(withIdentifier: "ShowRemoteProfile", sender: self)
                } else {
                    if ProfilesTableViewController.selectedRemoteProfileIndex != -1 {
                        tableView.cellForRow(at: IndexPath.init(row: ProfilesTableViewController.selectedRemoteProfileIndex, section: 0))?.accessoryType = .none
                    }
                    ProfilesTableViewController.selectedRemoteProfileIndex = indexPath.row
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == ProfilesTableViewController.localProfiles.count {
                self.performSegue(withIdentifier: "ShowLocalProfile", sender: self)
            } else {
                if tableView.isEditing {
                    LocalProfileTableViewController.showProfile = ProfilesTableViewController.localProfiles[indexPath.row]
                    self.performSegue(withIdentifier: "ShowLocalProfile", sender: self)
                } else {
                    if ProfilesTableViewController.selectedLocalProfileIndex != -1 {
                        tableView.cellForRow(at: IndexPath.init(row: ProfilesTableViewController.selectedLocalProfileIndex, section: 1))?.accessoryType = .none
                    }
                    ProfilesTableViewController.selectedLocalProfileIndex = indexPath.row
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if indexPath.row == ProfilesTableViewController.remoteProfiles.count {
                return false
            } else {
                return true
            }
        } else if indexPath.section == 1 {
            if indexPath.row == ProfilesTableViewController.localProfiles.count {
                return false
            } else {
                return true
            }
        }
        return false
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            if indexPath.row == ProfilesTableViewController.remoteProfiles.count {
                return UITableViewCellEditingStyle.none
            } else {
                return UITableViewCellEditingStyle.delete
            }
        } else if indexPath.section == 1 {
            if indexPath.row == ProfilesTableViewController.localProfiles.count {
                return UITableViewCellEditingStyle.none
            } else {
                return UITableViewCellEditingStyle.delete
            }
        }
        return UITableViewCellEditingStyle.none
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    @IBAction func editClicked(_ sender: UIBarButtonItem) {
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            self.tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                ProfilesTableViewController.remoteProfiles.remove(at: indexPath.row)
                if ProfilesTableViewController.selectedRemoteProfileIndex == indexPath.row {
                    ProfilesTableViewController.selectedRemoteProfileIndex = -1
                } else if ProfilesTableViewController.selectedRemoteProfileIndex > indexPath.row {
                    ProfilesTableViewController.selectedRemoteProfileIndex -= 1
                }
            } else if indexPath.section == 1 {
                ProfilesTableViewController.localProfiles.remove(at: indexPath.row)
                if ProfilesTableViewController.selectedLocalProfileIndex == indexPath.row {
                    ProfilesTableViewController.selectedLocalProfileIndex = -1
                } else if ProfilesTableViewController.selectedLocalProfileIndex > indexPath.row {
                    ProfilesTableViewController.selectedLocalProfileIndex -= 1
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
