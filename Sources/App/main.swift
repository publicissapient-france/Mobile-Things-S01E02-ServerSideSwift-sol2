import HTTP
import Vapor
import VaporRedis

let drop = Droplet()

let giphySearchBaseURL = "http://api.giphy.com/v1/gifs/search?q="
let publicGiphyApiKeyParameterURL = "&api_key=dc6zaTOxFJmzC"

try drop.addProvider(VaporRedis.Provider(config: drop.config))

drop.get { req in
  return try drop.view.make("welcome", [
    "message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.post() { req in
  guard let text = req.data["text"]?.string else {
    let errorMessage = "\(String(bytes: req.body.bytes ?? Bytes(), encoding: String.Encoding.utf8)) is not a valid request)"
    throw Abort.custom(status: .badRequest, message: errorMessage)
  }
  
  do {
    let slackCommand = try SlackCommand(request: req)
    let giphySearchFullURL = giphySearchBaseURL + slackCommand.text.value + publicGiphyApiKeyParameterURL
    let giphyResponse = try drop.client.get(giphySearchFullURL)
    
    if let datas = giphyResponse.json?["data"]?.array, datas.count > 0, let url = datas[0].object?["images"]?.object?["fixed_height"]?.object?["url"] {
      
      let actions = [ActionType.upVote, ActionType.downVote]
      let attachment = Attachment(imageUrl: url.string ?? "", actions: actions)
      let response = SlackResponse(text: "Coucou", attachments: [attachment])
      
      return response
    }
  } catch let error {
    throw Abort.custom(status: .internalServerError, message: error.localizedDescription)
  }
  
  return "{ text: \"No gihpy found\" }"
}

drop.get("auth") { req in
  guard let code = req.query?["code"] else {
    throw Abort.custom(status: .internalServerError, message: "The code received is \(req.query?["code"])")
  }
  
  var query = [String: String]()
  
  query["client_id"] = "125651482789.127368141717"
  query["client_secret"] = "c3483364c03ff8d65d6741cff047e9f1"
  query["code"] = code.string
  query["redirect_url"] = "https://young-meadow-71957.herokuapp.com/auth"
  
  let oAuthResponse = try drop.client.post("https://slack.com/api/oauth.access", headers: [:], query: query, body: Body())
  
  return oAuthResponse.makeResponse()
}

drop.post("vote") { req in
  do {
    let slackCommand = try SlackCommand(request: req)
    let giphyId = slackCommand.text
    
    if var cache = try drop.cache.get("giphyVotes1")?.array {
      var giphyVotes = try cache.map { try GiphyVote(node: $0 as! Node) }
      
      if let index = giphyVotes.index(where: { $0.giphyId == giphyId.value.string }) {
        var giphyVote = giphyVotes[index] 
        
        giphyVote.numberOfVotes? += 1
        giphyVotes[index] = giphyVote
      
        try drop.cache.set("giphyVotes1", Node(giphyVotes.map({ try $0.makeNode() })))
      } else {
        let giphyVote = GiphyVote(giphyId: giphyId.value.string!, numberOfVotes: 1)
        
        giphyVotes.append(giphyVote)

        try drop.cache.set("giphyVotes1", Node(giphyVotes.map({ try $0.makeNode() })))
      }
    } else {
      var giphyVotes = [Node]()
      var giphyVote = GiphyVote(giphyId: giphyId.value.string!, numberOfVotes: 1)
      
      try giphyVotes.append(giphyVote.makeNode())
      try drop.cache.set("giphyVotes1", Node(giphyVotes))
    }
  } catch let error {
    throw Abort.custom(status: .internalServerError, message: error.localizedDescription)
  }

  return ""
}

drop.run()
