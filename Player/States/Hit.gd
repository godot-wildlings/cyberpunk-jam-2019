extends Player_State

#var player : KinematicBody2D
var my_state_num : int
onready var hitstun_timer = $HitstunTimer

func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.hidden
	hitstun_timer.connect("timeout", self, "_on_HitstunTimer_timeout")

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	show_sprites()
	hitstun_timer.start()
	$OofNoise.play()
	take_damage(arguments[0], arguments[1])

func deactivate():
	hide_sprites()

func show_sprites():
	for child in get_children():
		if child is Sprite:
			child.show()

func hide_sprites():
	for child in get_children():
		if child is Sprite:
			child.hide()

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		pass

func _on_HitstunTimer_timeout():
	player.set_state(player.states.idle)

func take_damage(damage, damage_type):
	var damage_mod : float = 1
	if player.damage_reduction.has(damage_type):
		print("received damage: type == ", damage_type, ": " , Game.damage_type_names[damage_type])
		print("damage_reduction == ", player.damage_reduction[damage_type])
		damage_mod = 1 - player.damage_reduction[damage_type]
	player.health -= damage * damage_mod
	player.get_node("HealthBar").set_value(player.health)

############


