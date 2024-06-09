extends Node2D

var box = preload("res://Scenes/caixa.tscn")

const FROG_START_POS = Vector2i(40, 236)
const CAM_START_POS = Vector2i(84, 144)
var score : int
var highscore : int
var speed : float
var time : int
const START_SPEED : float = 2.2
var screen_size : Vector2i
var ground_height : int = 240
var game_running : bool
var obstacles : Array
var last_obs
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	$Game_Over.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	# reseta-se as variáveis
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	
	# Depois reseta-se os nós
	$Jogador.position = FROG_START_POS
	$Jogador.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$chao.position = Vector2i(0, 0)
	$CanvasLayer.get_node('StartLabel').show()
	$Game_Over.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED
		
		#Gera os obstáculos
		generate_obs()
		
		#Move o sapo e a câmera
		$Jogador.position.x += speed
		$Camera2D.position.x += speed
		
		#Mostra o escore
		show_score()
		
		time += speed
		#Atualiza a posição do chão
		if $Camera2D.position.x - $chao.position.x > screen_size.x * 1.5:
			$chao.position.x += screen_size.x 
	else:
		if Input.is_action_pressed('ui_accept'):
			game_running = true
	
func show_score():
	$CanvasLayer.get_node("ScoreLabel").text = "Score: " + str(score)
	$CanvasLayer.get_node('StartLabel').hide()

func check_highscore():
	if score > highscore:
		highscore = score
		$CanvasLayer.get_node("HighScoreLabel").text = "Highscore: " + str(highscore)
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < time + randi_range(200, 500):
		var max_obs = 3
		for i in range(randi() % max_obs + 1):
			var obs = box.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + 300 + time + (i * 100)
			var obs_y : int = ground_height
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			
		
func add_obs(obs, x, y) :
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	score += 1

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Jogador":
		game_over()

func game_over():
	check_highscore()
	get_tree().paused = true
	$Game_Over.show()
