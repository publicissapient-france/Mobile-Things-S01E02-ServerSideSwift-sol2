//
//  SlackCommand.swift
//  ServerSideSwift
//
//  Created by Julien on 10/01/2017.
//
//

import Foundation
import HTTP
import Vapor

struct SlackCommand {
    var text: Valid<GiphyName>
    
    init(request: Request) throws {
        text = try request.data["text"].validated()
    }
}

class GiphyName: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self && Count.max(128)
        
        try evaluation.validate(input: value)
    }
}
