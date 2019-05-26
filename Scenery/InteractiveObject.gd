extends Area2D

signal player_entered(body)
signal player_exited(body)

export var hidden_to_player : bool = false
export var locked : bool = false
export var open : bool = false
onready var interaction = $Interaction
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if hidden_to_player:
		$Sprite.set_visible(false)
		$Sprite.set_self_modulate(Color(1,1,1,0))

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
	if not locked and not open:
		if has_node("Interaction") and get_node("Interaction").has_method("interact"):
			$Interaction.interact(interactor)
		if has_node("AnimationPlayer") and get_node("AnimationPlayer").has_animation("interact"):
			$AnimationPlayer.play("interact")
			open = true
	elif locked:
		if has_node("AnimationPlayer") and get_node("AnimationPlayer").has_animation("access_denied"):
			$AnimationPlayer.play("access_denied")
	elif open:
		# what should happen? The door is already open
		pass


func _on_Player_scanned():
	print(self.name, " received signal: Player_scanned")
	if hidden_to_player:
		$AnimationPlayer.play("reveal")

func unlock():
	print(self.name, " unlocking" )
	if animation_player.has_animation("unlock"):
		animation_player.play("unlock")
	locked = false
