module linevee

import vweb
import net.http
import log
import json
import crypto.hmac
import crypto.sha256
import encoding.base64

import linevee.api

pub const (
  version = "0.0.1"
)

pub struct LineVee {
  port                 int    = 8080
  channel_secret       string
  channel_access_token string
pub mut:
  vweb                 vweb.Context
	cli_log              log.Log
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
  lv.cli_log.set_level(log.Level.info)
  lv.cli_log.set_output_level(log.Level.info)
  lv.debug("init_once()")
}

// Run for each connection
pub fn (mut lv LineVee) init() {
  lv.info("Request received at ${lv.vweb.req.url}")
  lv.vweb.set_content_type("text/html; charset=UTF-8")
  return
}

// Handle only the index page
pub fn (mut lv LineVee) index() vweb.Result {
  if !is_valid_request(mut lv) {
    lv.debug("Invalid request, discarding with empty 200 OK.")
    return lv.vweb.ok("Invalid Request.")
  }
  lv.handle_webhook(lv.vweb.req)
  return lv.vweb.ok("All Good.")
}

fn is_valid_request(mut lv LineVee) bool {
  lv.debug(lv.vweb.req.headers.str())

  mut lowercase_headers := map[string]string
  for i, v in lv.vweb.req.headers {
    lowercase_headers[i.to_lower()] = v
  }

  mut sent_signature := ""
  if "x-line-signature" in lv.vweb.req.headers {
    sent_signature = lv.vweb.req.headers["x-line-signature"]
  } else if "X-Line-Signature" in lv.vweb.req.headers {
    sent_signature = lv.vweb.req.headers["X-Line-Signature"]
  } else {
    lv.debug("X-Line-Signature Header not found.")
    return false
  }

  hash := hmac.new(lv.channel_secret.bytes(), lv.vweb.req.data.bytes(), sha256.sum, sha256.block_size)
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
  a := json.decode(api.LineWebhook, lv.vweb.req.data) or {api.LineWebhook{}}
  lv.debug("Parsed Webhook:" + a.str())
  return
}