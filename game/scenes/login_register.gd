extends Node
class_name LoginRegister

const DEFAULT_KEY = "defaultkey"
const DEFAULT_HOST = "127.0.0.1"
const DEFAULT_PORT = 7350
const MAP_MANAGER_TSCN = "res://map/scenes/MapManager.tscn"

onready var client := Nakama.create_client(DEFAULT_KEY, DEFAULT_HOST, DEFAULT_PORT, "http")

func _ready():
	$Login.visible = true
	$Register.visible = false;
	$ErrorMessage.visible = false
	$SuccessMessage.visible = false
	$Login/LoginBtn.connect("pressed", self, "_login_login_btn_pressed")
	$Login/RegisterBtn.connect("pressed", self, "_login_register_btn_pressed")
	$Register/LoginBtn.connect("pressed", self, "_register_login_btn_pressed")
	$Register/RegisterBtn.connect("pressed", self, "_register_register_btn_pressed")
	
	
func _login_login_btn_pressed():
	$Login/LoginBtn.disabled = true
	
	var usernameOrEmail = $Login/Username.text
	var password = $Login/Password.text
	
	if not usernameOrEmail or not password:
		return set_error_message("Please enter your credentials.")
	
	var username = ""
	var email = ""
	
	if EmailUtils.is_valid_email(usernameOrEmail):
		email = usernameOrEmail
	else:
		username = usernameOrEmail
	
	var session:NakamaSession = yield(client.authenticate_email_async(email, password, username, false), "completed")
	
	if session.is_exception():
		return set_error_message("Invalid credentials.")
		
	set_success_message("Successfully logged in!")
	get_tree().change_scene(MAP_MANAGER_TSCN)


func _register_register_btn_pressed():
	$Register/RegisterBtn.disabled = true
	
	var email = $Register/Email.text
	var password = $Register/Password.text
	var username = $Register/Username.text
	
	if not email or not password:
		return set_error_message("Please enter your credentials.")
	
	if not EmailUtils.is_valid_email(email):
		return set_error_message("Invalid Email")
	
	var session:NakamaSession = yield(client.authenticate_email_async(email, password, username, true), "completed") 
	
	if session.is_exception():
		return set_error_message("Error registering new user.")
		
	set_success_message( "Successfully registered new user!")
	get_tree().change_scene(MAP_MANAGER_TSCN)


func _login_register_btn_pressed():
	$Login.visible = false
	$Register.visible = true
	$ErrorMessage.text = ""
	$SuccessMessage.text = ""

func _register_login_btn_pressed():
	$Login.visible = true
	$Register.visible = false
	$ErrorMessage.text = ""
	$SuccessMessage.text = ""
	
func set_error_message(msg):
	$SuccessMessage.text = "";
	$SuccessMessage.visible = false
	$ErrorMessage.text = msg
	$ErrorMessage.visible = true
	$Register/RegisterBtn.disabled = false
	$Login/LoginBtn.disabled = false

func set_success_message(msg):
	$ErrorMessage.text = ""
	$ErrorMessage.visible = false
	$SuccessMessage.text = msg
	$SuccessMessage.visible = true
	$Register/RegisterBtn.disabled = false
	$Login/LoginBtn.disabled = false
