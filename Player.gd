extends KinematicBody2D

export (int) var speed = 160
export (int) var jump_speed = -180
export (int) var gravity = 400
export (int) var slide_speed = 400

var vel = Vector2.ZERO
var isAttacking = false
var comboattack = 3

export (float) var friction = 10
export (float) var accleration = 25

enum state {IDLE, RUNNING, ROLLING, JUMP, FALL, ATTACK, ATTACK2, ATTACK3, HANG}

var player_state = state.IDLE

func get_input():
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if dir != 0:
		
		vel.x = move_toward(vel.x, dir * speed, accleration)
	else:
		
		vel.x = move_toward(vel.x, 0, friction)
	
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
		state.ROLLING:
			$AnimationPlayer.play("Rolling")
			yield($AnimationPlayer, "animation_finished")
			player_state = state.IDLE
		state.JUMP:
			$AnimationPlayer.play("Jump")
		state.FALL:
			$AnimationPlayer.play("Fall")
		state.ATTACK:
			$AnimationPlayer.play("Attack")
			yield($AnimationPlayer, "animation_finished")
			player_state = state.IDLE
		state.ATTACK2:
			$AnimationPlayer.play("Attack2")
			yield($AnimationPlayer, "animation_finished")
			player_state = state.IDLE
		state.ATTACK3:
			$AnimationPlayer.play("Attack3")
			yield($AnimationPlayer, "animation_finished")
			player_state = state.IDLE
		state.HANG: 
			$AnimationPlayer.play("Hang")
		
func _physics_process(delta):
	if player_state != state.ROLLING and player_state != state.ATTACK:
		get_input()
	
		print(vel)
		
		if vel.x == 0:
			vel.x = 0
			player_state = state.IDLE
		elif vel.x != 0 and Input.is_action_just_pressed("Slide") and is_on_floor():
			player_state = state.ROLLING
			vel.x *= 2.3
		elif vel.x != 0:
			player_state = state.RUNNING
			if vel.x < 0:
				$HangChecker.position.x = -9.5
			elif vel.x > 0:
				$HangChecker.position.x = 9.5
		
		if is_on_floor() and player_state != state.ROLLING:
			if Input.is_action_just_pressed("ui_up"):
				vel.y = jump_speed
				player_state = state.JUMP
			if Input.is_action_just_pressed("ATTACK") && comboattack == 3:
				player_state = state.ATTACK
				comboattack = - 1
				isAttacking == true
				$Area2D/CollisionShape2D.disabled = false
			elif Input.is_action_just_pressed("ATTACK") && comboattack == 2:
				player_state = state.ATTACK2
				comboattack = - 1
				isAttacking == true
				$Area2D/CollisionShape2D.disabled = false
			elif Input.is_action_just_pressed("ATTACK") && comboattack == 1:
				player_state = state.ATTACK3
				comboattack = - 1
				isAttacking == true
				$Area2D/CollisionShape2D.disabled = false
				
	if not is_on_floor():
		if vel.y < 0:
			player_state = state.JUMP
		else:
			player_state = state.FALL
	
	if player_state == state.ATTACK:
		vel.x = move_toward(vel.x, 0, friction)
	
	if $HangChecker.is_colliding():
		player_state = state.HANG
	
	if Input.is_action_just_released("ATTACK"):
		isAttacking = false
		player_state = state.IDLE
		$Area2D/CollisionShape2D.disabled = true
		
	vel.y += gravity * delta
	vel = move_and_slide(vel, Vector2.UP)
	update_animation()
