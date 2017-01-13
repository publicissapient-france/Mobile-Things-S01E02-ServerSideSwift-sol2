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

enum ActionType: String, NodeRepresentable {
    case upVote = "upVote"
    case downVote = "downVote"
    
    func name() -> String {
        return self.rawValue.lowercased()
    }
    
    func text() -> String {
        return self.rawValue.uppercased()
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "value": self.rawValue,
            "name": self.name(),
            "text": self.text(),
            "type": "button"
            ])
    }
}

struct Attachment: NodeRepresentable {
    var imageUrl: String
    let actions: [ActionType]
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "image_url": imageUrl,
            "actions": actions.makeNode()
        ])
    }
}
