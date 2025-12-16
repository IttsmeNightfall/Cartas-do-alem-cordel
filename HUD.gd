extends CanvasLayer

@onready var preview = $CardPreviewPanel/CardPreviewTexture

func show_card_preview(card):
	var tex = card.get_node("CardImg").texture
	preview.texture = tex
	preview.visible = true
	$CardPreviewPanel.visible = true   # mostra o painel também

func hide_card_preview():
	preview.visible = false
	$CardPreviewPanel.visible = false
