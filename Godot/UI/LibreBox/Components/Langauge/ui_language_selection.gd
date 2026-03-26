extends PanelContainer


@onready var _vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var _title: Label = $MarginContainer/VBoxContainer/Label

@onready var Lang_English : Button = $MarginContainer/VBoxContainer/LangBTN_English
@onready var Lang_Irish : Button = $MarginContainer/VBoxContainer/LangBTN_Irish
@onready var Lang_French : Button = $MarginContainer/VBoxContainer/LangBTN_French
@onready var Lang_Chinese : Button = $MarginContainer/VBoxContainer/LangBTN_Chinese


func _ready() -> void:
    Lang_English.pressed.connect(_on_Lang_English_clicked)
    Lang_Irish.pressed.connect(_on_Lang_Irish_clicked)
    Lang_French.pressed.connect(_on_Lang_French_clicked)
    Lang_Chinese.pressed.connect(_on_Lang_Chinese_clicked)

func _on_Lang_English_clicked():
    _on_pick_language("en")
func _on_Lang_Irish_clicked():
    _on_pick_language("ga")
func _on_Lang_French_clicked():
    _on_pick_language("fr")
func _on_Lang_Chinese_clicked():
    _on_pick_language("zh_CN")





func _on_pick_language(locale: String) -> void:
    Language_Manager.apply_locale(locale)
