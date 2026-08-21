extends StaticBody3D

var item_data = {
"name": "Blok1",
"description": "Dikdörtgen şeklinde bir blok",
"icon": preload("res://icon.svg")
}

func interacted():
	InvManager.add_item(item_data)
	get_parent().queue_free()
