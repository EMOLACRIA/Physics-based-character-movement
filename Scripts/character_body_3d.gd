extends CharacterBody3D

@export var max_ground_speed: float = 8.13
@export var ground_accelerate: float = 10.0
@export var look_sensitivity: float = 0.006
@export var stop_speed: float = 0.1
@export var ground_friction: float = 8.0
@export var gravity: float = 20.3
@export var jump_height: float = 1.14
@export var max_air_speed: float = 2.0
@export var air_accelerate: float = 40.0
@export var air_control: float = 0.45
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.15
@export var autobhop_enabled: bool = true


@onready var cast = %SeeCast
@onready var interacttxt = %Intertact
var just_landed: bool = false
var was_on_floor: bool = false
var coyote_time_left: float = 0.0
var jump_buffer_time_left: float = 0.0



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
	if is_on_floor():
		coyote_time_left = coyote_time
	else:
		coyote_time_left = maxf(coyote_time_left - delta, 0.0)
	
	if Input.is_action_just_pressed("jump"): 
		jump_buffer_time_left = jump_buffer_time
	else:
		jump_buffer_time_left = maxf(jump_buffer_time_left - delta, 0.0)
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
	
	just_landed = is_on_floor() and not was_on_floor
	
	apply_gravity(delta)
	process_jump()
	
	if is_on_floor():
		if not just_landed:
			apply_ground_friction(delta)
		process_ground_movement(delta)
	else:
		process_air_movement(delta)
	
	was_on_floor = is_on_floor()
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
	
	accelerate(wish_dir, wish_speed, ground_accelerate, delta)
	
	# Wish_dir ve wish_speed'e uygun bir şekilde kapsülün velocity'sini kademeli olarak artırır.

func accelerate(wish_dir: Vector3, wish_speed: float, accel: float, delta: float) -> void:
	var current_speed = velocity.dot(wish_dir)
	var add_speed = wish_speed - current_speed
	
	# Kapsülün güncel hızını hesaplar (current_speed) ve 
	# Ne kadar hız eklemesi gerektiğini hesaplar (add_speed(
	# Kapsülün güncel hızını, kapsülün gidebileceği maksimum hızdan çıkartır))
	
	if add_speed <= 0:
		return
	
	var accel_speed = accel * delta * wish_speed
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

func apply_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func get_jump_velocity() -> float:
	return sqrt(2 * gravity * jump_height)
	# Kapsülün zıplarken kazanması gereken velocity'i hesaplar.

func process_jump() -> void:	
	if coyote_time_left > 0.0 and jump_buffer_time_left > 0.0:
		velocity.y = get_jump_velocity()
		coyote_time_left = 0.0
		jump_buffer_time_left = 0.0
		return
	
	if autobhop_enabled == true and Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = get_jump_velocity()
		coyote_time_left = 0.0
		jump_buffer_time_left = 0.0


func process_air_movement(delta: float) -> void:
	var wish_dir = get_wish_direction()
	var wish_speed = get_air_wish_speed()
	
	accelerate(wish_dir, wish_speed, air_accelerate, delta)
	# process_ground_movement'ta olan şeyleri air_wish_speed ile yeniden uygular.
	apply_air_control(wish_dir, delta)

func get_air_wish_speed() -> float:
	var input_dir = read_movement_input()
	return input_dir.length() * max_air_speed
	# Girdinin kuvvetine göre max_air_speed hesaplanır

func apply_air_control(wish_dir: Vector3, delta:float) -> void:
	if wish_dir.is_zero_approx():
		return
	
	var speed = Vector2(velocity.x, velocity.z).length()
	var current_dir = Vector2(velocity.x, velocity.z).normalized()
	var wish_dir_2d = Vector2(wish_dir.x, wish_dir.z)
	var alignment = current_dir.dot(wish_dir_2d)
	
	
	if alignment <= 0:
		return
	
	var new_dir = current_dir.lerp(wish_dir_2d, air_control * delta).normalized()
	velocity.x = new_dir.x * speed
	velocity.z = new_dir.y * speed
