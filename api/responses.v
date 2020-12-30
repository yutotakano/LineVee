module api 

struct LineResponse {
	LineError
}

struct LineError {
	message string
	details []LineSpecificError
}

struct LineSpecificError {
	message string
	property string
}