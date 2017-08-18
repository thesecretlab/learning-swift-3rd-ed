//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Tim Nugent on 14/8/17.
//  Copyright © 2017 Lonely Coffee. All rights reserved.
//

import UIKit

class SelfieListViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    // BEGIN selfie_array
    // The list of Photo objects we're going to display
    var selfies : [Selfie] = []
    // END selfie_array

    // BEGIN selfie_list_viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // loading the list of selfies from the selfie store
        do
        {
            // Get the list of photos, sorted by date (newer first)
            selfies = try SelfieStore.shared.listSelfies()
                .sorted(by: { $0.created > $1.created })
        }
        catch let error
        {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1]
                as? UINavigationController)?.topViewController
                as? DetailViewController
        }
    }
    // END selfie_list_viewDidLoad

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    // MARK: - Helper methods
    // BEGIN selfie_list_showError
    func showError(message : String)
    {
        // Create an alert controller, with the message we received
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        
        // Add an action to it - it won't do anything, but
        // doing this means that it will have a button to dismiss it
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Show the alert and its message
        self.present(alert, animated: true, completion: nil)
    }
    // END selfie_list_showError

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Segues

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // BEGIN selfie_list_tableview
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }
    override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        
        let selfie = selfies[indexPath.row]
        cell.textLabel?.text = selfie.title
        
        return cell
    }
    // END selfie_list_tableview
}

