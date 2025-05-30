extends RichTextLabel


func set_message(won: bool, stale_mate: bool) -> void:
	if stale_mate:
		text = "[b][color=purple]Tie!"
	if won:
		text = "[b][color=blue]Win!"
	else:
		text = "[b][color=red]Loss!"
