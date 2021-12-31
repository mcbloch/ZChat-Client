extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	launch()

func launch():
	apply_central_impulse(Vector2(-1, -0.7)*2000)

func fix_size():
	var size = $Label.theme.default_font.get_string_size( $Label.text )
	$CollisionShape2D.shape.set_height(size.x)

	#$Sprite.scale.x = (100/600) * $Label.rect_size.x
