//
//  GiphyVote.swift
//  ServerSideSwift
//
//  Created by Julien on 22/01/2017.
//
//

import Foundation
import Vapor

struct GiphyVote {

  var giphyId: String?
  var numberOfVotes: Int?
  
  init(node: Node) throws {
    self.giphyId = try node.extract("giphyId")
    self.numberOfVotes = try node.extract("numberOfVotes")
  }
  
  init(giphyId: String, numberOfVotes: Int) {
    self.giphyId = giphyId
    self.numberOfVotes = numberOfVotes
  }
  
  func makeNode() throws -> Node {
    return try Node(node: [
      "giphyId": self.giphyId,
      "numberOfVotes": self.numberOfVotes
    ])
  }
}
