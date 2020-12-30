module api

pub struct LineWebhook {
	destination string
	events []LineWebhookEvent
}

struct LineWebhookEvent {
	event_type          string                   [json: "type"]
	mode                string
	timestamp           int
	source              LineWebhookSource
	reply_to            string                   [json: "replyTo"]
	message             LineWebhookMessage
	unsend              LineWebhookUnsend
	joined              LineWebhookMembers
	left                LineWebhookMembers
	postback            LineWebhookPostback
	video_play_complete LineWebhookVideoComplete [json: "videoPlayComplete"]
	beacon              LineWebhookBeacon
	link                LineWebhookLink
	things              LineWebhookDevice
}

struct LineWebhookSource {
	source_type string  [json: "type"]
	group_id    string  [json: "groupId"]
	room_id      string [json: "roomId"]
	user_id     string  [json: "userId"]
}

struct LineWebhookMessage {
	id                    string
	message_type          string                     [json: "type"]
	text                  string
	emojis                []LineEmoji
	duration              int
	content_provider      LineWebhookContentProvider [json: "contentProvider"]
	file_name             string                     [json: "fileName"]
	file_size             int                        [json: "fileSize"]
	title                 string
	address               string
	latitude              f32
	longitude             f32
	package_id            string                     [json: "packageId"]
	sticker_id            string                     [json: "stickerId"]
	sticker_resource_type string                     [json: "stickerResourceType"]
	keywords              []string
}

struct LineEmoji {
	index      int
	length     int
	product_id string [json: "productId"]
	emoji_id   string [json: "emojiId"]
}

struct LineWebhookContentProvider {
	content_type         string [json: "type"]
	original_content_url string [json: "originalContentUrl"]
	preview_image_url    string [json: "previewImageUrl"]
}


struct LineWebhookUnsend {
	message_id string [json: "messageId"]
}

struct LineWebhookMembers {
	members []LineWebhookSource
}

struct LineWebhookPostback {
	data   string
	params LineWebhookPostbackParam
}

struct LineWebhookPostbackParam {
	date     string
	time     string
	datetime string
}

struct LineWebhookVideoComplete {
	tracking_id string [json: "trackingId"]
}

struct LineWebhookBeacon {
	hwid              string
	beacon_event_type string [json: "type"]
	dm                string
}

struct LineWebhookLink {
	result string
	nonce  string
}

struct LineWebhookDevice {
	device_id         string [json: "deviceId"]
	device_event_type string [json: "type"]
	result            LineWebhookDeviceResult
}

struct LineWebhookDeviceResult {
	scenario_id              string                          [json: "scenarioId"]
	revision                 int
	start_time               int                             [json: "startTime"]
	end_time                 int                             [json: "endTime"]
	result_code              string                          [json: "resultCode"]
	action_results           []LineWebhookDeviceActionResult [json: "actionResults"]
	ble_notification_payload string                          [json: "bleNotificationPayload"]
	error_reason             string                          [json: "errorReason"]
}

struct LineWebhookDeviceActionResult {
	device_action_result_type string [json: "type"]
	data                      string
}