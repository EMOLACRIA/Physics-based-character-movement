extends Node3D

@onready var icon = %icon
@onready var desc = %desc

var current_page = 0

func _process(delta):
	if Input.is_action_just_pressed("Menu"):
		if visible:
			hide()
		else:
			show()
			update_book()
	
	if visible:
		if Input.is_action_just_pressed("ui_right"):
			next_page()
		if Input.is_action_just_pressed("ui_left"):
			prev_page()

func next_page():
	if current_page < InvManager.items.size() - 1:
		current_page += 1
		update_book()
		print("Sayfa ileri: ", current_page)
	else:
		print("Son sayfadasınız!")

func prev_page():
	if current_page > 0:
		current_page -= 1
		update_book()
		print("Sayfa geri: ", current_page)
	else:
		print("İlk sayfadasınız!")

func update_book():
	var items = InvManager.items
	
	if items.size() == 0:
		desc.text = "Hiç bir eşyan yok"
		return
		
	var item = items[current_page]
	icon.texture = item["icon"]
	desc.text = item["description"]
