import HTTP
import Foundation
import Vapor

struct SlackResponse: ResponseRepresentable {
    var text: String
    var attachments: [Attachment]
    
    func makeResponse() throws -> Response {
        return try JSON(node: [
            "text": text,
            "attachments": attachments.makeNode()
        ]).makeResponse()
    }
}
