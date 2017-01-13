import HTTP
import Vapor

let drop = Droplet()
let publicGiphyApiKey = "dc6zaTOxFJmzC"

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.post() { req in
    guard let text = req.json?["text"]?.string else {
        let errorMessage = "\(String(bytes: req.body.bytes ?? Bytes(), encoding: String.Encoding.utf8)) is not a valid request)"
        throw Abort.custom(status: .badRequest, message: errorMessage)
    }
    
    do {
        let slackCommand = try SlackCommand(request: req)
        let giphyResponse = try drop.client.get("http://api.giphy.com/v1/gifs/search?q=\(slackCommand.text)&api_key=\(publicGiphyApiKey)")
        
        if let imageURL = giphyResponse.json?["embed_url"] {
            return "OK"
        }
    } catch let error {
        throw Abort.custom(status: .internalServerError, message: error.localizedDescription)
    }

    return "{ text: \"No gihpy found\" }"
}

drop.run()
