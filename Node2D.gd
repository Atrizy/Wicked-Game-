extends KinematicBody2D

export (int) var speed = 160
export (int) var jump_speed = -180
export (int) var gravity = 400

var vel = Vector2.ZERO

export (float,0,1.0) var friction = 0.1
export (float,0,1.0) var accleration = 0.25

enum state {IDLE, RUNNING, ROLLING, JUMP, FALL, ATTACK}

var player_state = state.IDLE

func get_input():
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if dir != 0:
		vel.x = lerp(vel.x, dir * speed, accleration)
	else:
		vel.x = lerp(vel.x, 0, friction)
	
func update_animation():
	if vel.x < 0 :
		$Sprite.flip_h = true
	if vel.x > 0 :
		$Sprite.flip_h = false
	match(player_state):
		state.IDLE:
			$AnimationPlayer.play("Idle")
		state.RUNNING:
			$AnimationPlayer.play("Running")
			yield($AnimationPlayer, "animation_finished")
			player_state = state.IDLE
		state.ROLLING:
			$AnimationPlayer.play("Rolling")
		state.JUMP:
			$AnimationPlayer.play("Jump")
		state.FALL:
			$AnimationPlayer.play("Fall")
		state.ATTACK:
			$AnimationPlayer.play("Attack")
		
func _physics_process(delta):
	if player_state != state.ROLLING and player_state != state.ATTACK:
		get_input()
	
		print(vel)
		if -29 <= vel.x and vel.x <= 29:
			vel.x = 0
			player_state = state.IDLE
		elif vel.x != 0 and Input.is_action_just_pressed("Slide"):
			player_state = state.ROLLING
		elif vel.x != 0:
			player_state = state.RUNNING
		
		if is_on_floor() and player_state != state.ROLLING:
			if Input.is_action_just_pressed("ui_up"):
				vel.y = jump_speed
				player_state = state.JUMP
				###
				# ATTACK
				###
	if not is_on_floor():
		if vel.y < 0:
			player_state = state.JUMP
		else:
			player_state = state.FALL
			
	vel.y += gravity * delta
	vel = move_and_slide(vel, Vector2.UP)
	update_animation()
