extends Node

signal turn_changed(new_turn)

enum { PLAYER_TURN, ENEMY_TURN }
var current_turn = PLAYER_TURN

# --- NOVAS VARIÁVEIS DE VIDA ---
var player_health = 10
var enemy_health = 10
const STARTING_HEALTH = 10

# Referências Visuais
@onready var player_health_label = $"../PlayerHealthLabel" # Crie este nó na cena!
@onready var enemy_health_label = $"../EnemyHealthLabel" # Crie este nó na cena!

# Referências do Jogo
@onready var end_turn_button = $"../EndTurnButton"
@onready var card_manager = $"../CardManager"
@onready var player_deck = $"../Deck"
@onready var opponent_hand_node = $"../OpponentHand"
@onready var opponent_deck = $"../EnemyDeck"
@onready var enemy_slots_node = $"../EnemyCardSlots" 

# Arrays para saber quem está no campo
var empty_enemy_slots = []
var player_cards_on_field = [] # Precisamos preencher isso quando VOCÊ joga uma carta

func _ready():
	# Inicializa a vida visualmente
	update_health_ui()
	
	end_turn_button.pressed.connect(end_player_turn)
	for slot in enemy_slots_node.get_children():
		empty_enemy_slots.append(slot)

func update_health_ui():
	# Atualiza os textos na tela
	if player_health_label:
		player_health_label.text = str(player_health)
	if enemy_health_label:
		enemy_health_label.text = str(enemy_health)

func end_player_turn():
	if current_turn == PLAYER_TURN:
		current_turn = ENEMY_TURN
		end_turn_button.disabled = true
		end_turn_button.visible = false
		print("--- Turno do INIMIGO ---")
		start_enemy_turn()

func start_enemy_turn():
	await get_tree().create_timer(1.0).timeout
	
	# 1. COMPRAR CARTA
	if opponent_deck and opponent_deck.enemy_deck_list.size() > 0:
		opponent_deck.draw_card()
		await get_tree().create_timer(1.0).timeout
	
	# 2. JOGAR CARTA (Invocação)
	try_play_card()
	
	# 3. FASE DE ATAQUE (Novo!)
	await get_tree().create_timer(1.0).timeout
	enemy_attack_phase()

func try_play_card():
	# (Sua lógica de jogar carta que já fizemos antes...)
	if opponent_hand_node.opponent_hand.size() == 0 or empty_enemy_slots.size() == 0:
		return

	var best_card = opponent_hand_node.opponent_hand[0]
	# ... (Lógica de escolher a melhor carta) ...
	
	var random_index = randi() % empty_enemy_slots.size()
	var target_slot = empty_enemy_slots[random_index]
	
	play_enemy_card(best_card, target_slot)
	empty_enemy_slots.remove_at(random_index)

func play_enemy_card(card, slot):
	opponent_hand_node.remove_card_from_hand(card)
	
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", slot.global_position, 0.5)
	
	slot.card_in_slot = card
	
	# IMPORTANTE: Adicione a carta à lista de "Atacantes" do inimigo se quiser rastrear depois
	# Mas por enquanto, vamos focar no ataque direto

func enemy_attack_phase():
	var attackers = []
	for slot in enemy_slots_node.get_children():
		if slot.card_in_slot != null:
			attackers.append(slot.card_in_slot)
	
	if attackers.size() == 0:
		end_opponent_turn()
		return
	
	for card in attackers:
		# Se o jogador NÃO tem cartas -> Ataque Direto
		if player_cards_on_field.size() == 0:
			await direct_attack(card, "Player")
		else:
			# --- CÓDIGO NOVO: Ataque Monstro x Monstro ---
			# Escolhe uma carta aleatória do jogador para atacar
			var target_card = player_cards_on_field.pick_random()
			if target_card != null:
				await attack_card(card, target_card)
	
	end_opponent_turn()

func direct_attack(card, target):
    print(card.name, " está atacando diretamente!")
    
    # 1. Animação de ir para frente (ataque)
    var original_pos = card.global_position
    var target_pos = Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y - 100)
    
    var tween = get_tree().create_tween()
    tween.tween_property(card, "global_position", target_pos, 0.2)
    await tween.finished
    
    # 2. Aplica o Dano
    if target == "Player":
        var dmg = card.attack if "attack" in card else 1
        player_health -= dmg
        update_health_ui()
        print("Jogador tomou ", dmg, " de dano! Vida restante: ", player_health)
    
    # 3. Volta para o lugar
    var tween_back = get_tree().create_tween()
    tween_back.tween_property(card, "global_position", original_pos, 0.3)
    await tween_back.finished

func attack_card(attacker, defender):
    print("Combate: ", attacker.name, " vs ", defender.name)
    
    # 1. Animação de ir até a carta
    var original_pos = attacker.global_position
    attacker.z_index = 10 # Fica por cima de tudo
    
    var tween = get_tree().create_tween()
    tween.tween_property(attacker, "global_position", defender.global_position, 0.2)
    await tween.finished
    
    # 2. Cálculo de Dano (Mútuo)
    # Defensor toma dano = Ataque do Atacante
    if "health" in defender and "attack" in attacker:
        defender.health -= attacker.attack
        # Atualiza visual da carta (Label de vida)
        if defender.has_method("update_visuals"): defender.update_visuals()
    
    # Atacante toma dano = Ataque do Defensor (Contra-ataque)
    if "health" in attacker and "attack" in defender:
        attacker.health -= defender.attack
        if attacker.has_method("update_visuals"): attacker.update_visuals()
    
    # 3. Animação de volta
    var tween_back = get_tree().create_tween()
    tween_back.tween_property(attacker, "global_position", original_pos, 0.2)
    await tween_back.finished
    attacker.z_index = 0
    
    # 4. Verificar Mortes (Cemitério)
    if defender.health <= 0:
        await destroy_card(defender)
    
    if attacker.health <= 0:
        await destroy_card(attacker)

func destroy_card(card):
    print(card.name, " foi destruída!")
    
    # Remove das listas lógicas
    if card in player_cards_on_field:
        player_cards_on_field.erase(card)
    
    # Libera o slot onde a carta estava
    if "card_slot_card_is_in" in card and card.card_slot_card_is_in != null:
        card.card_slot_card_is_in.card_in_slot = null
        card.card_slot_card_is_in = null
    
    # Move visualmente para o cemitério
    var target_discard = null
    if card.global_position.y > 300: # Lógica rápida baseada na altura da tela
        target_discard = player_discard
    else:
        target_discard = enemy_discard
        
    if target_discard:
        var tween = get_tree().create_tween()
        tween.tween_property(card, "global_position", target_discard.global_position, 0.3)
        tween.parallel().tween_property(card, "scale", Vector2(0.2, 0.2), 0.3)
        await tween.finished
    
    # Opcional: Deletar a carta ou deixá-la empilhada no cemitério
    card.queue_free()

func end_opponent_turn():
	print("--- Turno do JOGADOR ---")
	current_turn = PLAYER_TURN
	end_turn_button.disabled = false
	end_turn_button.visible = true
	start_player_turn()

func start_player_turn():
	# Reseta as coisas do jogador
	if card_manager and "played_monster_this_turn" in card_manager:
		card_manager.played_monster_this_turn = false
	if player_deck:
		player_deck.drawn_card_this_turn = false
		player_deck.draw_card(true)
