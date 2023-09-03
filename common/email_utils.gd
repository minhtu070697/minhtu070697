extends Node

class_name EmailUtils

const email_regex = "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"

static func is_valid_email(email):
	var regex = RegEx.new()
	regex.compile(email_regex)
	return regex.search(email) != null
