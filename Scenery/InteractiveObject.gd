extends Area2D

signal player_entered(body)
signal player_exited(body)


enum object_types { door, terminal, letter, NPC }
#warning-ignore:unused_class_variable
export (object_types )var object_type : int = object_types.door

export var hidden_to_player : bool = false
#warning-ignore:unused_class_variable
export var locked : bool = false
#warning-ignore:unused_class_variable
export var open : bool = false
onready var interaction = $Interaction
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
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
		$Label.set_text(interaction.get_name())

func connect_signals():
	#warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_InteractiveObject_body_entered")
	#warning-ignore:return_value_discarded
	connect("body_exited", self, "_on_InteractiveObject_body_exited")


func deferred_ready():
	if Game.player != null and Game.player.has_method("_on_InteractiveObject_player_entered"):
		#warning-ignore:return_value_discarded
		connect("player_entered", Game.player, "_on_InteractiveObject_player_entered")
		#warning-ignore:return_value_discarded
		connect("player_exited", Game.player, "_on_InteractiveObject_player_exited")
	else:
		push_error("Interactive object is trying to connect to Game.player object, but can't.")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InteractiveObject_body_entered(body):
	if body == Game.player:
		emit_signal("player_entered", self)

func _on_InteractiveObject_body_exited(body):
	if body == Game.player:
		emit_signal("player_exited", self)


#warning-ignore:unused_argument
func interact(interactor):
	if has_node("Interaction") and get_node("Interaction").has_method("interact") and not hidden_to_player:
		$Interaction.interact(interactor)



func _on_Player_scanned():

	if hidden_to_player:
		$AnimationPlayer.play("reveal")
		hidden_to_player = not hidden_to_player

func unlock():

	if animation_player.has_animation("unlock"):
		animation_player.play("unlock")
	locked = false



