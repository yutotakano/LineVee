module linevee

pub struct Emoji {
	index      int
	length     int
	product_id string
	emoji_id   string
}

struct Event {
	event_type string
	mode       string
	timestamp  int
	source     WebhookSource
}

struct MessageEvent {
	reply_to            string                   [json: 'replyTo']
	message             LineWebhookMessageType
	unsend              LineWebhookUnsend
	joined              LineWebhookMembers
	left                LineWebhookMembers
	postback            LineWebhookPostback
	video_play_complete LineWebhookVideoComplete [json: 'videoPlayComplete']
	beacon              LineWebhookBeacon
	link                LineWebhookLink
	things              LineWebhookDevice
}

struct LineWebhookSource {
	source_type string [json: 'type']
	group_id    string [json: 'groupId']
	room_id     string [json: 'roomId']
	user_id     string [json: 'userId']
}

struct LineWebhookMessage {
	id           string
	message_type string [json: 'type']
}

struct LineWebhookTextMessage {
	LineWebhookMessage
	text   string
	emojis []LineEmoji
}

struct LineWebhookVideoMessage {
	LineWebhookMessage
	duration         int
	content_provider LineWebhookContentProvider [json: 'contentProvider']
}

struct LineWebhookAudioMessage {
	LineWebhookMessage
	duration         int
	content_provider LineWebhookContentProvider [json: 'contentProvider']
}

struct LineWebhookFileMessage {
	LineWebhookMessage
	file_name string [json: 'fileName']
	file_size int    [json: 'fileSize']
}

struct LineWebhookLocationMessage {
	LineWebhookMessage
	title     string
	address   string
	latitude  f32
	longitude f32
}

struct LineWebhookStickerMessage {
	LineWebhookMessage
	package_id            string   [json: 'packageId']
	sticker_id            string   [json: 'stickerId']
	sticker_resource_type string   [json: 'stickerResourceType']
	keywords              []string
}

struct LineWebhookContentProvider {
	content_type         string [json: 'type']
	original_content_url string [json: 'originalContentUrl']
	preview_image_url    string [json: 'previewImageUrl']
}

struct LineWebhookUnsend {
	message_id string [json: 'messageId']
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
	tracking_id string [json: 'trackingId']
}

struct LineWebhookBeacon {
	hwid              string
	beacon_event_type string [json: 'type']
	dm                string
}

struct LineWebhookLink {
	result string
	nonce  string
}

struct LineWebhookDevice {
	device_id         string                  [json: 'deviceId']
	device_event_type string                  [json: 'type']
	result            LineWebhookDeviceResult
}

struct LineWebhookDeviceResult {
	scenario_id              string                          [json: 'scenarioId']
	revision                 int
	start_time               int                             [json: 'startTime']
	end_time                 int                             [json: 'endTime']
	result_code              string                          [json: 'resultCode']
	action_results           []LineWebhookDeviceActionResult [json: 'actionResults']
	ble_notification_payload string                          [json: 'bleNotificationPayload']
	error_reason             string                          [json: 'errorReason']
}

struct LineWebhookDeviceActionResult {
	device_action_result_type string [json: 'type']
	data                      string
}
