# Virtual base class for all states.
class_name State
extends Node

var state_machine = null
var previous_state = null
var previous_msg := {}
var msg := {}


func unhandled_input(_event: InputEvent) -> void:
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func enter(_msg := {}) -> void:
	pass


func exit() -> void:
	pass
