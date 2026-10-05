extends Node2D
class_name PhysicsCar

const SCALE: float = 100.0 # 100 px = 1 meter
const TOTAL_MASS_KG: float = 2.5

@onready var chassis: RigidBody2D = $Chassis
@onready var rear_wheel: RigidBody2D = $RearWheel
@onready var front_wheel: RigidBody2D = $FrontWheel

func _ready() -> void:
	set_car_freeze(true)

func set_car_freeze(frozen: bool) -> void:
	chassis.freeze = frozen
	rear_wheel.freeze = frozen
	front_wheel.freeze = frozen

func launch(force_n: float, dist_m: float) -> void:
	var work_joules: float = force_n * dist_m
	var speed_m_s: float = sqrt((2.0 * work_joules) / TOTAL_MASS_KG)
	var speed_px_s: float = speed_m_s * SCALE
	
	set_car_freeze(false)
	
	var initial_velocity: Vector2 = Vector2.RIGHT * speed_px_s
	chassis.linear_velocity = initial_velocity
	rear_wheel.linear_velocity = initial_velocity
	front_wheel.linear_velocity = initial_velocity
	
	var wheel_omega: float = speed_px_s / 32.0
	rear_wheel.angular_velocity = wheel_omega
	front_wheel.angular_velocity = wheel_omega

# Launch by pure kinetic energy (used for spring PE conversion)
func launch_with_energy(energy_joules: float) -> void:
	var speed_m_s: float = sqrt((2.0 * energy_joules) / TOTAL_MASS_KG)
	var speed_px_s: float = speed_m_s * SCALE
	
	set_car_freeze(false)
	
	var initial_velocity: Vector2 = Vector2.RIGHT * speed_px_s
	chassis.linear_velocity = initial_velocity
	rear_wheel.linear_velocity = initial_velocity
	front_wheel.linear_velocity = initial_velocity
	
	var wheel_omega: float = speed_px_s / 32.0
	rear_wheel.angular_velocity = wheel_omega
	front_wheel.angular_velocity = wheel_omega

func _physics_process(_delta: float) -> void:
	if not chassis.freeze:
		var clamped: float = clamp(chassis.rotation, deg_to_rad(-40.0), deg_to_rad(40.0))
		if chassis.rotation != clamped:
			chassis.rotation = clamped
			chassis.angular_velocity = 0.0

func get_speed() -> float:
	return chassis.linear_velocity.length() / SCALE
