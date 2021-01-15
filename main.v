module linevee

import vweb
import net.http
import log
import x.json2
import crypto.hmac
import crypto.sha256
import encoding.base64

pub const (
  version = "0.0.1"
)

pub struct LineVee {
	vweb.Context
  port                 int    = 8080
  channel_secret       string
  channel_access_token string
pub mut:
	cli_log              log.Log
  on_raw_webhook_receive   fn (json2.Any) = fn (a json2.Any) {}
  on_text_message      fn (string, string, []LineEmoji)              = fn (a string, b string, c []LineEmoji) {}
  on_image_message     fn (string, bool, string, string)             = fn (a string, b bool, c string, d string) {}
  on_video_message     fn (string, int, bool, string, string)        = fn (a string, b int, c bool, d string, e string) {}
  on_audio_message     fn (string, int, bool, string)                = fn (a string, b int, c bool, d string) {}
  on_file_message      fn (string, string, int)                      = fn (a string, b string, c int) {}
  on_location_message  fn (string, string, string, f32, f32)         = fn (a string, b string, c string, d f32, e f32) {}
  on_sticker_message   fn (string, string, string, string, []string) = fn (a string, b string, c string, d string, e []string) {}
}

pub fn (mut lv LineVee) run() {
  println("Running LineVee " + version + " by Yuto Takano.")
  vweb.run_app<LineVee>(mut lv, lv.port)
}

pub fn (mut lv LineVee) debug(msg string) {
  lv.cli_log.debug(msg)
}

pub fn (mut lv LineVee) info(msg string) {
  lv.cli_log.info(msg)
}

pub fn (mut lv LineVee) warn(msg string) {
  lv.cli_log.warn(msg)
}

// Run once upon starting
pub fn (mut lv LineVee) init_once() {
  lv.cli_log = log.Log{}
  lv.cli_log.set_level(log.Level.debug)
  lv.cli_log.set_output_level(log.Level.debug)
  lv.debug("init_once()")
}

// Run for each connection
pub fn (mut lv LineVee) init() {
  lv.info("Request received at ${lv.req.url}")
  lv.set_content_type("text/html; charset=UTF-8")
  return
}

// Handle only the index page
pub fn (mut lv LineVee) index() vweb.Result {
  if !is_valid_request(mut lv) {
    lv.debug("Invalid request, discarding with empty 200 OK.")
    return lv.ok("Invalid Request.")
  }
  lv.handle_webhook(lv.req)
  return lv.ok("All Good.")
}

fn is_valid_request(mut lv LineVee) bool {
  lv.debug(lv.req.headers.str())

  mut lowercase_headers := map[string]string
  for i, v in lv.req.headers {
    lowercase_headers[i.to_lower()] = v
  }

  mut sent_signature := ""
  if "x-line-signature" in lv.req.headers {
    sent_signature = lv.req.headers["x-line-signature"]
  } else if "X-Line-Signature" in lv.req.headers {
    sent_signature = lv.req.headers["X-Line-Signature"]
  } else {
    lv.debug("X-Line-Signature Header not found.")
    return false
  }

  hash := hmac.new(lv.channel_secret.bytes(), lv.req.data.bytes(), sha256.sum, sha256.block_size)
  signature := base64.decode(sent_signature).bytes()

  if hash != signature {
    lv.warn("X-Line-Signature Header hash mismatch, is someone attempting to wrongly authenticate?")
    return false
  }
  lv.debug("Request's signature is valid.")
  return true
}

fn (mut lv LineVee) handle_webhook(req http.Request) {
  lv.debug("Webhook Received:" + req.str())
  raw_data := json2.raw_decode(lv.req.data) or { 
    panic("Invalid JSON in webhook.")
    return
  }
  lv.on_raw_webhook_receive(raw_data)
  data := raw_data.as_map()
  
  for raw_event in data["events"].arr() {
    event := raw_event.as_map()
    event_identifier := event["type"].str()
    lv.debug("Determined event: " + event_identifier)
    match event_identifier {
      "message" {
        raw_message := event["message"]
        message := raw_message.as_map()
        mut emojis := []LineEmoji{}
        for raw_emoji in message["emojis"].arr() {
          emoji := raw_emoji.as_map()
          emojis << LineEmoji{
            index: emoji["index"].int(),
            length: emoji["length"].int(),            
            product_id: emoji["productId"].str(),            
            emoji_id: emoji["emojiId"].str()
          }
        }
        lv.on_text_message(
          message["id"].str(),
          message["text"].str(),
          emojis
          )
      }
      else {}
    }
    //   "message/image" {
    //     lv.on_image_message(
    //       event.message.id,
    //       event.message.content_provider.content_type == "line",
    //       event.message.content_provider.original_content_url,
    //       event.message.content_provider.preview_image_url
    //       )
    //   }
    //   "message/video" {
    //     lv.on_video_message(
    //       event.message.id,
    //       event.message.duration,
    //       event.message.content_provider.content_type == "line",
    //       event.message.content_provider.original_content_url,
    //       event.message.content_provider.preview_image_url
    //     )
    //   }
    //   "message/audio" {
    //     lv.on_audio_message(
    //       event.message.id,
    //       event.message.duration,
    //       event.message.content_provider.content_type == "line",
    //       event.message.content_provider.original_content_url
    //     )
    //   }
    //   "message/file" {
    //     lv.on_file_message(
    //       event.message.id,
    //       event.message.file_name,
    //       event.message.file_size
    //     )
    //   }
    //   "message/location" {
    //     lv.on_location_message(
    //       event.message.id,
    //       event.message.title,
    //       event.message.address,
    //       event.message.latitude,
    //       event.message.longitude
    //     )
    //   }
    //   "message/sticker" {
    //     lv.on_sticker_message(
    //       event.message.id,
    //       event.message.package_id,
    //       event.message.sticker_id,
    //       event.message.sticker_resource_type,
    //       event.message.keywords
    //     )
    //   }
    //   else {}
    // }
  }
}