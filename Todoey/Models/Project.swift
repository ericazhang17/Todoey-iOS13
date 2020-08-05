//
//  Projects.swift
//  Todoey
//
//  Created by Erica Zhang on 8/4/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Project : Object {
    @objc dynamic var name : String = ""
    // 1-> many relationship
    let subtasks = List<Subtask>()
}
