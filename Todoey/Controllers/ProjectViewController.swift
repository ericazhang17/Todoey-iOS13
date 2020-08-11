//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ProjectTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var cnt = -1
    var projects :Results<Project>?
    let colorArray = [UIColor(hexString: "ffd5cd"),UIColor(hexString: "efbbcf"),UIColor(hexString: "c3aed6"),UIColor(hexString: "8675a9"),UIColor(hexString: "f09ae9"),UIColor(hexString: "ffc1fa"),UIColor(hexString: "ffe78f"),UIColor(hexString: "ffd36b")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProjects()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller does not exist.")
        }
        let appearance = navBar.standardAppearance
        navBar.backgroundColor = UIColor(hexString: "ea81b0")
        navBar.scrollEdgeAppearance = appearance
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
        
        if let project = projects?[indexPath.row] {
            cell.textLabel?.text = project.name
            guard let projectColor = UIColor(hexString: project.hexColor) else {
                fatalError()
            }
            cell.backgroundColor = projectColor
            cell.selectionStyle = .none // remove highlight effect completely
            cell.textLabel?.textColor = ContrastColorOf(projectColor, returnFlat: true)
        }
        return cell
    }
    
    //MARK: - Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        performSegue(withIdentifier: "goToSubtasks", sender: self)
//        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            let destinationVC = segue.destination as! SubtaskViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedProject = projects?[indexPath.row]
            }
    }
    
    //MARK: - add Button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
       
        
        let alertController = UIAlertController(title: "Add New Project", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newProject = Project()
            newProject.name = textField.text!
  
            guard let hexStr = self.colorArray[self.cnt % self.colorArray.count]?.hexValue() else {fatalError()}
            newProject.hexColor = hexStr
            
//            newProject.hexColor = UIColor.randomFlat().hexValue()
            self.saveProject(project: newProject)
        }
        
        alertController.addAction(action)
        alertController.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new project"
        }
        present(alertController, animated: true, completion: nil)
        cnt += 1
    }
    
    // https://stackoverflow.com/questions/26341008/how-to-convert-uicolor-to-hex-and-display-in-nslog
    func hexStringFromColor(color: UIColor) -> String {
       let components = color.cgColor.components
       let r: CGFloat = components?[0] ?? 0.0
       let g: CGFloat = components?[1] ?? 0.0
       let b: CGFloat = components?[2] ?? 0.0

       let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
//       print(hexString)
       return hexString
    }
}

