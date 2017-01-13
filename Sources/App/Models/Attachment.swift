//
//  Attachment.swift
//  ServerSideSwift
//
//  Created by Julien on 13/01/2017.
//
//

import Fluent
import Foundation
import Vapor

struct Attachment: NodeRepresentable {
    var imageUrl: String
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "image_url": imageUrl
        ])
    }
}
