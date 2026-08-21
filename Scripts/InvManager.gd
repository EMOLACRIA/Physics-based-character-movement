extends Node

var items = []

func add_item(item_data: Dictionary):
	items.append(item_data)
	print("Eklendi: ", item_data["name"])
