import HTTP
import Vapor

let drop = Droplet()

let giphySearchBaseURL = "http://api.giphy.com/v1/gifs/search?q="
let publicGiphyApiKeyParameterURL = "&api_key=dc6zaTOxFJmzC"

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
    guard let code = req.data["code"] else {
        throw Abort.serverError
    }
    
    var query = [String: String]()
    
    query["client_id"] = "125651482789.127368141717"
    query["client_secret"] = "c3483364c03ff8d65d6741cff047e9f1"
    query["code"] = code.string
    query["redirect_url"] = "https://young-meadow-71957.herokuapp.com/auth"
    
    let oAuthResponse = try drop.client.post("https://slack.com/api/oauth.access", headers: [:], query: query, body: Body())
    
    return "OK"
}

drop.post("vote") { req in
    return ""
}

drop.run()
