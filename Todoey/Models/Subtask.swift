//
//  Subtasks.swift
//  Todoey
//
//  Created by Erica Zhang on 8/4/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Subtask : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    // many -> 1, inverse relationship
    var parentProject = LinkingObjects(fromType: Project.self, property: "subtasks")
}
