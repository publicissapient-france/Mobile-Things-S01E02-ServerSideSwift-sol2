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
        throw Abort.badRequest
    }
    
    do {
        let slackCommand = try SlackCommand(request: req)
        let giphyResponse = try drop.client.get("http://api.giphy.com/v1/gifs/search?q=\(slackCommand.text)&api_key=\(publicGiphyApiKey)")
        
        if let imageURL = giphyResponse.json?["embed_url"] {
            return "OK"
        }
    } catch {
        throw Abort.badRequest
    }

    return "{ text: \"No gihpy found\" }"
}

drop.run()
