extends Control
class_name TrackDeleteConfirmUI

## Simple confirmation dialog used before removing a user-imported track.
signal delete_confirmed
signal delete_cancelled

@onready var Message_Label: Label = %DeleteConfirmMessage
@onready var Confirm_Button: Button = %DeleteConfirmYesButton
@onready var Cancel_Button: Button = %DeleteConfirmNoButton


## Connects confirm/cancel button actions.
func _ready() -> void:
    Confirm_Button.pressed.connect(_on_confirm_pressed)
    Cancel_Button.pressed.connect(_on_cancel_pressed)


## Updates dialog message text.
func set_message_text(message: String) -> void:
    if Message_Label != null:
        Message_Label.text = message


func _on_confirm_pressed() -> void:
    delete_confirmed.emit()


func _on_cancel_pressed() -> void:
    delete_cancelled.emit()
