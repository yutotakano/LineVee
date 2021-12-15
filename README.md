# <center>LineVee</center>

**This project is abandoned and unmaintained for the forseeable future**.

LINE Messenger Library for V.

## QuickStart

```v
import linevee

fn main() {
  mut client := linevee.LineVee{
    port: 8080
    channel_secret: "<channel secret>"
    channel_access_token: "<long-lived access token goes here>"
  }

  client.on_text_message = fn (id string, text string, emojis []linevee.LineEmoji) {
    println("Received text message: " + text)
  }
  
  client.on_audio_message = fn (id string, dur int, line bool, external_url string) {
    println("Received an audio message with duration: " + dur.str() + " milliseconds.")
  }

  client.run()
}
```
