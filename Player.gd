extends Sprite

const SPEED = 800
const UPDATE_PERIOD = 0

var update_timeout = UPDATE_PERIOD
var updated = true

var moving = false
var motion = Vector2(0, 0)
var target_position = null

export var local = false

onready var world = get_node("/root/World")

func _ready():
	set_process(true)
	if local:
		set_process_input(true)

# It's not the most elegant way of player control handling but it's 
# the least processor consuming way I can come with (so far)
# - its event based and in periodical process function it's doing computations
#   only when it moves (and only reealy simple one)
# - when it doesn't move, it periodically coparing one boolean value only
 
func _input(event):	
	if !local:
		return
		
	if event.is_action_pressed("ui_left"):
		motion.x -= 1
	if event.is_action_released("ui_left"):
		motion.x += 1
		
	if event.is_action_pressed("ui_right"):
		motion.x += 1
	if event.is_action_released("ui_right"):
		motion.x -= 1

	if event.is_action_pressed("ui_up"):
		motion.y -= 1
	if event.is_action_released("ui_up"):
		motion.y += 1
		
	if event.is_action_pressed("ui_down"):
		motion.y += 1
	if event.is_action_released("ui_down"):
		motion.y -= 1		
		
	moving = motion != Vector2(0, 0)
		
func _process(delta):
	if local:
		if !updated:
			update_timeout -= delta
			if update_timeout <= 0:
				update_timeout = UPDATE_PERIOD
				world.distribute_position(position)
				updated = true	
					
		if moving:
			updated = false
			position += motion * SPEED * delta
	else:
		if target_position:
			position = target_position; #lerp(position, target_position, 0.04)
			#if position == target_position:
			#	target_position = null
			
func distribute_players_position(pos):
	print("POS")
