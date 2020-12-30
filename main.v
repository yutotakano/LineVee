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
  vweb.run_app<LineVee>(mut lv, lv.port)
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
  lv.info("init_once()")
}

// Run for each connection
pub fn (mut lv LineVee) init() {
  lv.info("Request received at ${lv.vweb.req.url}")
  return
}

pub fn (mut lv LineVee) index() {
  if !is_valid_request(mut lv) {
    lv.vweb.ok("All Good.")
    return
  }
  lv.info("Handling valid request...")
  lv.handle_webhook(lv.vweb.req)
  lv.vweb.ok("All Good, valid request.")
}

pub fn is_valid_request(mut lv LineVee) bool {
  println(lv.vweb.req)
  if !("x-line-signature" in lv.vweb.req.headers) {
    lv.info("x-line-signature Header not found.")
    return false
  }
  hash := hmac.new(lv.channel_secret.bytes(), lv.vweb.req.data.bytes(), sha256.sum, sha256.block_size)
  signature := base64.decode(lv.vweb.req.headers["x-line-signature"]).bytes()

  if hash != signature {
    lv.info("x-line-signature Header hash mismatch.")
    return false
  }
  return true
}

fn (mut lv LineVee) handle_webhook(req http.Request) {
  a := json.decode(api.LineWebhook, lv.vweb.req.data) or {api.LineWebhook{}}
  println(a)
  return
}