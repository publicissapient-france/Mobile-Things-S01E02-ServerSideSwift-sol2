import HTTP
import Vapor
import VaporRedis

let drop = Droplet()

let giphySearchBaseURL = "http://api.giphy.com/v1/gifs/search?q="
let publicGiphyApiKeyParameterURL = "&api_key=dc6zaTOxFJmzC"

try drop.addProvider(VaporRedis.Provider(config: drop.config))

drop.post("giphy") { req in
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
  
  return Response(status: .notFound, headers: ["Content-Type": "text/plain"], body: "Pas de giphy trouvé :(")
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
    let giphyId = slackCommand.text.value.string!
    
    if var cache = try drop.cache.get("giphyVotes")?.array {
      var giphyVotes = try cache.map { try GiphyVote(node: $0 as! Node) }
      
      if let index = giphyVotes.index(where: { $0.giphyId == giphyId }) {
        var giphyVote = giphyVotes[index] 
        
        giphyVote.numberOfVotes? += 1
        giphyVotes[index] = giphyVote
      
        try drop.cache.set("giphyVotes", Node(giphyVotes.map({ try $0.makeNode() })))
      } else {
        let giphyVote = GiphyVote(giphyId: giphyId, numberOfVotes: 1)
        
        giphyVotes.append(giphyVote)

        try drop.cache.set("giphyVotes", Node(giphyVotes.map({ try $0.makeNode() })))
      }
    } else {
      var giphyVotes = [Node]()
      var giphyVote = GiphyVote(giphyId: giphyId, numberOfVotes: 1)
      
      try giphyVotes.append(giphyVote.makeNode())
      try drop.cache.set("giphyVotes", Node(giphyVotes))
    }
  } catch let error {
    throw Abort.custom(status: .internalServerError, message: error.localizedDescription)
  }

  return Response(status: .ok, headers: ["Content-Type": "text/plain"], body: "C'est tout bon !")
}

drop.run()
