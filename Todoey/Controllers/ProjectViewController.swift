//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var projects :Results<Project>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProjects()
    }
    
    //MARK: - Data manipulation methods
    func saveProject(project : Project) {
        do {
            try realm.write {
                realm.add(project)
            }
        } catch {
            print("Error in saving project, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadProjects() {
        projects = realm.objects(Project.self)
        tableView.reloadData()
        
    }
    
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let projectForDeletion = self.projects?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete (projectForDeletion)
                }
            } catch {
                print("Error deleting project, \(error)")
            }
        }
    }
    
    //MARK: - DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = projects?[indexPath.row].name ?? "No Project Created"
        
        return cell
    }
    
    //MARK: - Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: "goToSubtasks", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "goToSubtasks" {
            let destinationVC = segue.destination as! SubtaskViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedProject = projects?[indexPath.row]
            }
//        }
    }
    
    //MARK: - add Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Project", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newProject = Project()
            newProject.name = textField.text!
            self.saveProject(project: newProject)
        }
        
        alertController.addAction(action)
        alertController.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new project"
        }
        present(alertController, animated: true, completion: nil)
    }
}

