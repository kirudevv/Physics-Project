extends Node2D

@export var car_scene: PackedScene = preload("res://car.tscn")
@export_file("*.tscn") var next_scene_path: String = "res://Main2.tscn"

var car: Node2D = null
@onready var goal_area: Area2D = $GoalArea

# UI References (Unique Names)
@onready var next_level_btn: Button = %NextLevelBtn
@onready var question_label: Label = %QuestionLabel
@onready var hint_label: Label = %FormulaHint
@onready var status_label: Label = %StatusLabel
@onready var btn_a: Button = %ChoiceA
@onready var btn_b: Button = %ChoiceB
@onready var btn_c: Button = %ChoiceC
@onready var reset_btn: Button = %ResetBtn

const LAUNCH_DISTANCE_M: float = 5.0
var car_spawn_position: Vector2 = Vector2(95, 437)

var selected_choice_idx: int = -1
var has_cleared_level: bool = false

var level_question: String = "Level 1: A 2.5 kg car must climb a 2.5 m hill (PE ≈ 61.25 J). Over a 5.0 m runway, what applied force (F) delivers enough Work (W) to pass?"

var choices: Array = [
	{
		"label": "A: 8 N\n(W = 40 J)",
		"force": 8.0,
		"is_correct": false,
		"feedback": "Underpowered! W = 40 J is less than the 61.25 J potential energy required. The car stalls on the slope."
	},
	{
		"label": "B: 25 N\n(W = 125 J)",
		"force": 25.0,
		"is_correct": true,
		"feedback": "Correct! 25 N * 5.0 m = 125 J. This comfortably clears the 61.25 J barrier and crests the summit cleanly!"
	},
	{
		"label": "C: 100 N\n(W = 500 J)",
		"force": 100.0,
		"is_correct": false,
		"feedback": "Overpowered! 500 J generates extreme speed, causing the car to fly off the crest."
	}
]

func _ready() -> void:
	btn_a.pressed.connect(func(): _on_choice_selected(0))
	btn_b.pressed.connect(func(): _on_choice_selected(1))
	btn_c.pressed.connect(func(): _on_choice_selected(2))
	reset_btn.pressed.connect(_on_reset_pressed)
	goal_area.body_entered.connect(_on_goal_entered)
	
	next_level_btn.hide()
	next_level_btn.pressed.connect(_on_next_level_pressed)
	
	var existing_car = get_node_or_null("Car")
	if existing_car:
		car_spawn_position = existing_car.position
		existing_car.queue_free()
	
	_spawn_fresh_car()
	load_quiz_ui()

func _spawn_fresh_car() -> void:
	if is_instance_valid(car):
		car.queue_free()
	
	car = car_scene.instantiate()
	car.name = "Car"
	car.position = car_spawn_position
	add_child(car)

func load_quiz_ui() -> void:
	question_label.text = level_question
	hint_label.text = "Hint: PE = m * g * h  |  W = F * d  (g = 9.8 m/s²)"
	status_label.text = "Select an answer card to test the simulation!"
	
	btn_a.text = choices[0]["label"]
	btn_b.text = choices[1]["label"]
	btn_c.text = choices[2]["label"]
	
	set_cards_active(true)

func set_cards_active(active: bool) -> void:
	btn_a.disabled = !active
	btn_b.disabled = !active
	btn_c.disabled = !active

func _on_choice_selected(index: int) -> void:
	if not is_instance_valid(car):
		return
		
	selected_choice_idx = index
	set_cards_active(false)
	
	var choice = choices[index]
	car.call("launch", choice["force"], LAUNCH_DISTANCE_M)
	status_label.text = "Testing: " + choice["feedback"]

func _on_goal_entered(body: Node2D) -> void:
	if body.name == "Chassis" or (is_instance_valid(car) and body.get_parent() == car):
		if choices[selected_choice_idx]["is_correct"] and not has_cleared_level:
			has_cleared_level = true
			status_label.text = "LEVEL COMPLETE! Valid Work calculation!"
			next_level_btn.show()

func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)

func _on_reset_pressed() -> void:
	_spawn_fresh_car()
	has_cleared_level = false
	selected_choice_idx = -1
	set_cards_active(true)
	next_level_btn.hide()
	status_label.text = "Select an answer card to test the simulation!"
