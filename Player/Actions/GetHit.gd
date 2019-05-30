extends Player_State

#var player : KinematicBody2D
onready var hitstun_timer = $HitstunTimer

func _ready():
	player = get_parent().get_parent()
	hitstun_timer.connect("timeout", self, "_on_HitstunTimer_timeout")


func use(damage, damage_type):
	if hitstun_timer.is_stopped():
		hitstun_timer.start()
		play_random_hurt_noise()
		take_damage(damage, damage_type)
		flash_red()


func flash_red():
	player.set_modulate(Color.red)

func play_random_hurt_noise():
	var noises = $SFX.get_children()
	var noise = noises[randi()%noises.size()]
	noise.play()




func take_damage(damage, damage_type):
	var damage_mod : float = 1
	if player.damage_reduction.has(damage_type):
		damage_mod = 1 - player.damage_reduction[damage_type]
	player.health -= damage * damage_mod
	player.get_node("HealthBar").set_value(player.health)

	if player.health <= 0:
		player.die()



func _on_HitstunTimer_timeout():
	player.set_modulate(Color.white)
