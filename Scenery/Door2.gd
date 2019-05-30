"""
Doors should open, close, lock, unlock
Players can enter doors and return from doors
Some doors act as elevators
Some doors replenish supplies (health, ammo)
Some doors transition to a new scene or cutscene
"""

extends Area2D
class_name Door

signal player_entered(body)
signal player_exited(body)


enum door_types {
	ammo,
	health,
	portal,
	cutscene,
	shortcut,
	tutorial
}

var door_names : Dictionary = {
	door_types.ammo : "Ammo",
	door_types.health : "Medical",
	door_types.portal : "101",
	door_types.cutscene : "303",
	door_types.shortcut : "Transit",
	door_types.tutorial : "press\nup"
}

export (door_types) var door_type = door_types.health
export var amount : float = 100
export var scene : PackedScene
export (String) var linkedElevatorName

signal animDone

var inside = null

#onready var linkedElevator = get_parent().get_parent().get_node(linkedElevatorName)
var linkedElevator : Door
onready var door : Area2D = self
onready var animation_player : AnimationPlayer = $AnimationPlayer


export var hidden_to_player : bool = false
#warning-ignore:unused_class_variable
export var locked : bool = false
#warning-ignore:unused_class_variable
export var open : bool = false




func _ready():

	if hidden_to_player:
		$Sprite.set_visible(false)
		$Sprite.set_self_modulate(Color(1,1,1,0))
		$Label.hide()

	if locked:
		if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("lock"):
			$AnimationPlayer.play("lock")

	call_deferred("deferred_ready")

	connect_signals()

	if has_node("Label"):
		$Label.set_text(door_names[door_type])


func deferred_ready():
	if Game.player != null and Game.player.has_method("_on_InteractiveObject_player_entered"):
		#warning-ignore:return_value_discarded
		connect("player_entered", Game.player, "_on_InteractiveObject_player_entered")
		#warning-ignore:return_value_discarded
		connect("player_exited", Game.player, "_on_InteractiveObject_player_exited")
	else:
		push_error("Interactive object is trying to connect to Game.player object, but can't.")

	if door_type == door_types.shortcut:
		linkedElevator = get_parent().get_node(linkedElevatorName)


func connect_signals():
	#warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_InteractiveObject_body_entered")
	#warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_InteractiveObject_body_exited")



func get_name() -> String:
	return door_names[door_type]


func interact(interactor):
	inside = interactor
	if not door.locked and not door.open:
		if animation_player.has_animation("open"):
			animation_player.play("open")
			door.open = true
			#yield(animation_player, "animation_finished")
			admit(interactor)

	elif door.locked:
		if interactor.keys_held > 0:
			door.unlock()
			interactor.keys_held -= 1
		elif animation_player.has_animation("access_denied"):
			animation_player.play("access_denied")
	elif door.open:
		# what should happen? The door is already open
		admit(interactor)

func admit(entity_entering):
	# theoretically, could be player or NPC
	if entity_entering.has_method("enter"):
		entity_entering.enter(self)


func animate():
	"""
	First, animate the doors opening, then animate the player walking in
	"""


func provide_reward(interactor):
	if door_type == door_types.ammo and interactor.has_method("add_ammo"):
		interactor.add_ammo(amount)

	elif door_type == door_types.health and interactor.has_method("recover_health"):
		interactor.recover_health(amount)

	elif door_type == door_types.cutscene:
		Game.main.load_cutscene(scene)

	elif door_type == door_types.portal and scene != null:
		print(self.name, " switching levels to  ", scene )
		Game.main.switch_levels(scene)

func movePlayer():
	if door_type == door_types.shortcut:
		Game.player.set_global_position(linkedElevator.get_global_position())
		Game.player.currentlyIn = linkedElevator

#func open_door():
#	if animation_player.has_animation("open"):
#			animation_player.play("open")
#			door.open = true
#			yield(animation_player,"animation_finished")
#	emit_signal("animDone")

func close_door():
	if animation_player.has_animation("close"):
			animation_player.play("close")
			door.open = false
			provide_reward(inside)



func _on_InteractiveObject_body_entered(body):
	if body == Game.player:
		emit_signal("player_entered", self)

func _on_InteractiveObject_body_exited(body):
	if body == Game.player:
		emit_signal("player_exited", self)






func _on_Player_scanned():
	print(self.name, " received signal: Player_scanned")
	if hidden_to_player:
		$AnimationPlayer.play("reveal")
		hidden_to_player = not hidden_to_player

func unlock():
	print(self.name, " unlocking" )
	if animation_player.has_animation("unlock"):
		animation_player.play("unlock")
	locked = false



