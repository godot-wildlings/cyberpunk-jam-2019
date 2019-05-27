"""
Attacking state is activated when player uses their attack action.
The attack action will be a punch or gunshot, and will last around 0.6s
At the end of the duration timer:
	switch to idle or running state, depending on keys pressed
"""

extends Node2D

var player : KinematicBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	#warning-ignore:return_value_discarded
	$AttackTimer.connect("timeout", self, "_on_AttackTimer_timeout")


func activate():
	$AttackTimer.start()

func deactivate():
	pass

#warning-ignore:unused_argument
func process_state(delta):
	# should they be able to move slowly during attacks?
	pass


func _on_AttackTimer_timeout():
	player.set_state(player.states.idle)