extends CharacterBody3D

@export var max_ground_speed: float = 8.13
@export var ground_accelerate: float = 10.0
@export var look_sensitivity: float = 0.006
@export var stop_speed: float = 0.1
@export var ground_friction: float = 6.0


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
	
	apply_ground_friction(delta)
	
	process_ground_movement(delta)
	
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

func process_ground_movement(delta: float) -> void:
	var wish_dir = get_wish_direction()
	var wish_speed = get_wish_speed()
	
	accelerate(wish_dir, wish_speed, delta)
	
	# Wish_dir ve wish_speed'e uygun bir şekilde kapsülün velocity'sini kademeli olarak artırır.

func accelerate(wish_dir: Vector3, wish_speed: float, delta: float) -> void:
	var current_speed = velocity.dot(wish_dir)
	var add_speed = wish_speed - current_speed
	
	# Kapsülün güncel hızını hesaplar (current_speed) ve 
	# Ne kadar hız eklemesi gerektiğini hesaplar (add_speed(
	# Kapsülün güncel hızını, kapsülün gidebileceği maksimum hızdan çıkartır))
	
	if add_speed <= 0:
		return
	
	var accel_speed = ground_accelerate * delta * wish_speed
	accel_speed = minf(accel_speed, add_speed)
	
	velocity += wish_dir * accel_speed
	
	# Kapsülün kademeli hızlandırmasını hesaplar ve velocity'ye ekler.

func apply_ground_friction(delta: float) -> void:
	var speed = Vector2(velocity.x, velocity.z).length()
	
	# Hızın büyüklüğünü ölçer.
	
	if speed < stop_speed:
		velocity.x = 0.0
		velocity.z = 0.0
		return
		# Eğer ölçülen hız stop_speed'den küçükse kapsül'ün velocity'sini sıfırlar.
	
	var drop = speed * ground_friction * delta
	# Friction'dan dolayı azalacak hızı hesaplar.
	var new_speed = speed - drop
	# Friction uygulandıktan sonra yeni hızı hesaplar.
	new_speed = maxf(new_speed, 0)
	# Oyuncunun yeni hızını 0'dan aşağı olmasını engeller.
	var scale = new_speed / speed
	# Yeni hız ile eski hızı oranlayarak friction'ın oranını hesaplar.
	velocity.x *= scale
	velocity.z *= scale
	# Hesaplanan friction oranını kapsül'ün velocity'sine uygular.
