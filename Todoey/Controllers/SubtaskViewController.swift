//
//  SubtaskTableViewController.swift
//  Todoey
//
//  Created by Erica Zhang on 8/4/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class SubtaskViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var subtasks :Results<Subtask>?
    let realm = try! Realm()
    
    var selectedProject : Project? {
        didSet {
            loadSubtasks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedProject?.hexColor {
            
            title = selectedProject!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist yet.")}
            if let navBarColor = UIColor(hexString: colorHex) {
                let appearance = UINavigationBarAppearance()
                navBar.scrollEdgeAppearance = appearance
                //ios 13 transparent large title bg
                appearance.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                appearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
            }
        }
    }
    
    //MARK: - Data manipulation methods
    func loadSubtasks() {
        subtasks = selectedProject?.subtasks.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
        
    }
    // Saving is done in closure in addButtonPressed
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let subtaskForDeletion = subtasks?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(subtaskForDeletion)
                }
            } catch {
                print("Error in deleting subtask, \(error)")
            }
        }
    }
        
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subtasks?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let subtask = subtasks?[indexPath.row] {
            cell.textLabel?.text = subtask.title
            let percentage = CGFloat(indexPath.row)/CGFloat(subtasks!.count) //can force unwrap inside let binding
            if let color = UIColor(hexString: selectedProject!.hexColor)?.darken(byPercentage: percentage)?.lighten(byPercentage: CGFloat(0.15)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }

            cell.accessoryType = subtask.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Subtask Added"
        }
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let subtask = subtasks?[indexPath.row] {
            do {
                try realm.write {
                    subtask.done = !subtask.done
                }
            } catch {
                print("Error saving subtask, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - add Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Subtask", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Subtask", style: .default) { (action) in
            
            if let currentProject = self.selectedProject {
                do {
                    try self.realm.write {
                        let newSubtask = Subtask()
                        newSubtask.title = textField.text!
                        newSubtask.dateCreated = Date()
                        currentProject.subtasks.append(newSubtask)
                    }
                } catch {
                    print("Error saving new subtask, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new subtask"
            textField = alertTextField
        }
        
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    

}
//MARK: - Searchbar delegate methods
extension SubtaskViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         print("clicked")
        subtasks = subtasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
//        subtasks = subtasks?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadSubtasks()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

}
