extends Node2D

@export var car_scene: PackedScene = preload("res://car.tscn")
@export_file("*.tscn") var next_scene_path: String = "res://Main3.tscn"

var car: PhysicsCar = null
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

# Fixed: 5.0 m runway to match the question and choices
const LAUNCH_DISTANCE_M: float = 5.0
var car_spawn_position: Vector2 = Vector2(95, 437)

var selected_choice_idx: int = -1
var has_cleared_level: bool = false

var level_question: String = "Level 2: A 2.5 kg car must clear a 25 m canyon gap with a 3.0 m drop. Over a 5.0 m runway, what applied force (F) imparts enough Work (W) to land safely?"

var formula_hint: String = "Hint: t = sqrt(2h/g)  |  vx = d/t  |  W = 0.5 * m * vx²  |  F = W / s"

var choices: Array = [
	{
		"label": "A: 80 N\n(W = 400 J)",
		"force": 80.0,
		"is_correct": false,
		"feedback": "Underpowered! 400 J (~17.9 m/s) drops the car into the first half of the canyon."
	},
	{
		"label": "B: 140 N\n(W = 700 J)",
		"force": 140.0,
		"is_correct": false,
		"feedback": "Short! 700 J (~23.7 m/s) clips the front edge just shy of the landing platform."
	},
	{
		"label": "C: 200 N\n(W = 1000 J)",
		"force": 200.0,
		"is_correct": true,
		"feedback": "Correct! 200 N * 5.0 m = 1000 J (~28.3 m/s). The car sails across the gap and lands safely!"
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
	
	car = car_scene.instantiate() as PhysicsCar
	car.name = "Car"
	car.position = car_spawn_position
	add_child(car)

func load_quiz_ui() -> void:
	question_label.text = level_question
	hint_label.text = formula_hint
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
	car.launch(choice["force"], LAUNCH_DISTANCE_M)
	status_label.text = "Testing: " + choice["feedback"]

func _on_goal_entered(body: Node2D) -> void:
	if body.name == "Chassis" or (is_instance_valid(car) and body.get_parent() == car):
		if choices[selected_choice_idx]["is_correct"] and not has_cleared_level:
			has_cleared_level = true
			status_label.text = "TRACK CLEARED! Valid Work calculation!"
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
