//
//  GiphyResponse.swift
//  ServerSideSwift
//
//  Created by Julien on 23/01/2017.
//
//

import Foundation
import HTTP
import Vapor

struct GiphyResponse {
  var data: [GiphyData]
  
  init(node: Node) throws {
    data = try node.extract("data")
  }
}

struct GiphyData: NodeInitializable {
  var id: String
  var giphyImage: GiphyImage
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    giphyImage = try node.extract("images")
  }
}

struct GiphyImage: NodeInitializable {
  var fixedHeight: FixedHeight
  
  init(node: Node, in context: Context) throws {
    fixedHeight = try node.extract("fixed_height")
  }
}

struct FixedHeight: NodeInitializable {
  var url: String
  
  init(node: Node, in context: Context) throws {
    url = try node.extract("url")
  }
}
