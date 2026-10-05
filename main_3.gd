extends Node2D

@export var car_scene: PackedScene = preload("res://car.tscn")
@export var crate_scene: PackedScene = preload("res://Crate.tscn")
@export_file("*.tscn") var victory_or_menu_scene: String = ""

var car: Node2D = null
var crate: RigidBody2D = null
@onready var goal_area: Area2D = $GoalArea

# UI References
@onready var next_level_btn: Button = %NextLevelBtn
@onready var question_label: Label = %QuestionLabel
@onready var hint_label: Label = %FormulaHint
@onready var status_label: Label = %StatusLabel
@onready var btn_a: Button = %ChoiceA
@onready var btn_b: Button = %ChoiceB
@onready var btn_c: Button = %ChoiceC
@onready var reset_btn: Button = %ResetBtn

var initial_car_transform: Transform2D
var initial_crate_transform: Transform2D
var selected_choice_idx: int = -1
var has_cleared_level: bool = false

const LAUNCH_STROKE_M: float = 2.0

var level_question: String = "Level 3: The 2.5 kg car must strike the cargo crate and launch it into the docking bay. What launch force (F) over a 2.0 m stroke imparts enough kinetic energy to knock the crate into the target?"

var formula_hint: String = "Hint: W = F * d_stroke  |  KE = 0.5 * m * v²  |  Elastic Transfer: p = m * v"

var choices: Array = [
	{
		"label": "A: 100.0 N\n(W = 200 J)",
		"force": 100.0,
		"is_correct": true,
		"feedback": "SLAM! 200 J of kinetic energy transfers into the crate, launching it directly into the docking head!"
	},
	{
		"label": "B: 35.0 N\n(W = 70 J)",
		"force": 35.0,
		"is_correct": false,
		"feedback": "Too weak! The car gently nudges the crate forward a bit, falling far short of the goal."
	},
	{
		"label": "C: 8.0 N\n(W = 16 J)",
		"force": 8.0,
		"is_correct": false,
		"feedback": "Underpowered! The car stalls on the runway and doesn't even make contact with the crate."
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
	
	car = get_node_or_null("Car")
	if car:
		initial_car_transform = car.transform
		
	crate = get_node_or_null("Crate") as RigidBody2D
	if crate:
		initial_crate_transform = crate.transform
	
	load_quiz_ui()

func load_quiz_ui() -> void:
	question_label.text = level_question
	hint_label.text = formula_hint
	status_label.text = "Select a launch force to ram the cargo crate!"
	
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
	
	# Untouched standard launch from Car.gd
	car.call("launch", choice["force"], LAUNCH_STROKE_M)
	status_label.text = "Testing: " + choice["feedback"]

func _on_goal_entered(body: Node2D) -> void:
	if body == crate or body.name == "Crate":
		if choices[selected_choice_idx]["is_correct"] and not has_cleared_level:
			has_cleared_level = true
			status_label.text = "LEVEL COMPLETE! Successful momentum transfer & work calculation!"
			next_level_btn.text = "YOU WIN! / REPLAY"
			next_level_btn.show()

func _on_next_level_pressed() -> void:
	if victory_or_menu_scene != "":
		get_tree().change_scene_to_file(victory_or_menu_scene)
	else:
		get_tree().reload_current_scene()

func _on_reset_pressed() -> void:
	has_cleared_level = false
	selected_choice_idx = -1
	set_cards_active(true)
	next_level_btn.hide()
	status_label.text = "Select a launch force to ram the cargo crate!"
	
	# Respawn Car at original editor location
	if is_instance_valid(car):
		car.queue_free()
	car = car_scene.instantiate()
	car.name = "Car"
	car.transform = initial_car_transform
	add_child(car)
	
	# Respawn Crate at original editor location
	if is_instance_valid(crate):
		crate.queue_free()
	crate = crate_scene.instantiate() as RigidBody2D
	crate.name = "Crate"
	crate.transform = initial_crate_transform
	add_child(crate)
