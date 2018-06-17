//
//  Model.swift
//  twoLevelList
//
//  Created by Maksym on 6/15/18.
//  Copyright © 2018 Maksym. All rights reserved.
//

import Foundation

struct header: Decodable {
    var response: [parent]?
}

struct parent: Decodable {
    lazy var opened : Bool = false
    let id : Int?
    let name : String?
    var children : [child]?
}

struct child: Decodable {
    lazy var marked : Bool = false
    let id: Int?
    let name: String?
}
