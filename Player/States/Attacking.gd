"""
Attacking state is activated when player uses their attack action.
The attack action will be a punch or gunshot, and will last around 0.6s
At the end of the duration timer:
	switch to idle or running state, depending on keys pressed
"""

extends Player_State

#var player : KinematicBody2D
onready var sprite : Sprite = $PunchingSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	#warning-ignore:return_value_discarded
	$AttackTimer.connect("timeout", self, "_on_AttackTimer_timeout")
	$PunchingSprite.hide()

func activate():
	$AttackTimer.start()
	#$PunchingSprite.show()

func deactivate():
	#$PunchingSprite.hide()
	pass

#warning-ignore:unused_argument
func process_state(delta):
	# should they be able to move slowly during attacks?

	# can you shoot in the air? Should be able to.
	var damping = 0.5
	if player.is_on_platform():
		velocity *= damping







func _on_AttackTimer_timeout():

	if Input.is_action_pressed("mv_down"):
		player.crouch(Vector2.ZERO)
	else:
		player.idle()

func flip_sprites(dir):
	if dir > 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)