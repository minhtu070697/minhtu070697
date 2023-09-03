extends "res://addons/gut/test.gd"
var utils = load("res://autoload/utils.gd").new()

func test_value_between():
	assert_false(utils.value_between(100, Vector2(1, 2)))
	assert_true(utils.value_between(100, Vector2(0, 1000)))
	assert_true(utils.value_between(100, Vector2(0, 100)))
	assert_true(utils.value_between(100, Vector2(100, 200)))
