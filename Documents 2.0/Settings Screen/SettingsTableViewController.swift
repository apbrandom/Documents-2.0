//
//  SettingsTableViewController.swift
//  Documents 2.0
//
//  Created by Vadim Vinogradov on 07.07.2023.
//


import UIKit

class SettingsTableViewController: UITableViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            //Сell for Sorting
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as? SortingTableViewCell else {
                fatalError("The dequeued cell is not an instance of SortingTableViewCell.")
            }

            let sortingOption = UserDefaults.standard.integer(forKey: "sortOption")
            cell.sortSegmentedControl.selectedSegmentIndex = sortingOption
            
            cell.sortSegmentedControl.addTarget(self, action: #selector(sortOptionChanged(_:)), for: .valueChanged)
            
            return cell
            
        case 1:
            // Cell for password
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChangePasswordCell", for: indexPath) as? ChangePasswordTableViewCell else {
                fatalError("The dequeued cell is not an instance of ChangePasswordTableViewCell.")
            }
            
            cell.changePasswordButton.addTarget(self, action: #selector(changePasswordTapped(_:)), for: .touchUpInside)
            
            return cell
            
        default:
            fatalError("Invalid row index")
        }
    }
    
    // MARK: - Actions
    
    @objc func sortOptionChanged(_ sender: UISegmentedControl) {
//        UserDefaults.standard.setValue(sender.selectedSegmentIndex, forKey: "sortOption")
        
//        switch sender.selectedSegmentIndex {
//        case 0: // Ascending order
//            items = FileManagerHelper.shared.sortItemsByName(items)
//        case 1: // Descending order
//            items = FileManagerHelper.shared.sortItemsByNameReversed(items)
//        default:
//            break
//        }
        
        // Reload the table view to reflect the sorted items
//        tableView.reloadData()
    }
    
    @objc func changePasswordTapped(_ sender: UIButton) {
        // Handle change password
    }
}




