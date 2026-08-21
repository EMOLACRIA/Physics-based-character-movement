extends CharacterBody3D

var max_ground_speed = 8.13

@export var look_sensitivity = 0.006
@onready var cast = %SeeCast
@onready var interacttxt = %Intertact


func _unhandled_input(event):
	if event.is_action_pressed("return"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Fareyi görünür veya görünmez yapar
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			$Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	# Fare görünmezken kamerayı kontrol etmeni sağlar ve belli açılarda clamp'ler

func _physics_process(delta: float) -> void:
	
	
	#------------------------------------------------
	
	interacttxt.hide()
	
	if cast.is_colliding():
		var target = cast.get_collider()
		if target != null and target.has_method("interacted"):
			interacttxt.show()
			if Input.is_action_just_pressed("Interact"):
				target.interacted()
	
	# Etkileşime geçebileceği objenin önüne gelince bir text çıkartır ve
	# etkileşime geçince "interacted" fonksiyonunu çalıştırır
	
	process_ground_movement()
	
	move_and_slide()

func read_movement_input() -> Vector2:
	return Input.get_vector("left", "right", "forward", "back")
	# 2 Düzlemli uzayda girdi yönlerini alır

func get_wish_direction() -> Vector3:
	var input_dir = read_movement_input()
	
	if input_dir.is_zero_approx():
		return Vector3.ZERO
	
	var local_direction = Vector3(input_dir.x, 0.0, input_dir.y)
	
	return transform.basis * local_direction
	
	# 2 Düzlemli uzayda alınan yönleri 3 Düzlemli uzaya uyarlar 

func get_wish_speed() -> float:
	var input_dir = read_movement_input()
	return input_dir.length() * max_ground_speed
	# Girdinin kuvvetine göre max_ground_speed hesaplanır

func process_ground_movement() -> void:
	var wish_dir = get_wish_direction()
	var wish_speed = get_wish_speed()
	
	velocity.x = wish_dir.x * wish_speed
	velocity.z = wish_dir.z * wish_speed
	
	#Bu fonksiyon ise wish_dir/speed'i kapsül'ün x ve z ekenindeki velocity'sine uygular.
