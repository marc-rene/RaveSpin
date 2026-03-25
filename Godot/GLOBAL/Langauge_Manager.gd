extends Node

const CONFIG_PATH := "user://language.cfg"
const CONFIG_SECTION := "i18n"
const CONFIG_KEY_LOCALE := "locale"

## Locales registered in Project Settings -> Localization (en = default / source strings).
const SUPPORTED_LOCALES: Array[String] = ["en", "fr", "zh_CN", "ga"]

const LOCALE_DISPLAY_NAMES: Dictionary = {
    "en": "English",
    "fr": "Français",
    "zh_CN": "简体中文",
    "ga": "Gaeilge",
}

var current_locale: String = "en"


func _ready() -> void:
    var saved: String = _load_saved_locale()
    if saved.is_empty() or not saved in SUPPORTED_LOCALES:
        current_locale = _locale_from_os()
    else:
        current_locale = saved
    apply_locale(current_locale)


func apply_locale(locale: String) -> void:
    if not locale in SUPPORTED_LOCALES:
        locale = "en"
    current_locale = locale
    TranslationServer.set_locale(locale)
    _save_locale(locale)


func get_locale_display_name(locale: String) -> String:
    return LOCALE_DISPLAY_NAMES.get(locale, locale)


func _locale_from_os() -> String:
    var lang: String = OS.get_locale_language().to_lower()
    var full: String = OS.get_locale().replace("-", "_").to_lower()
    print("LANGAUGE: We Got %s as our OS_Lang" % lang)
    match lang:
        "fr":
            return "fr"
        "ga":
            return "ga"
        "zh", "zh_cn", "zh_hans":
            return "zh_CN"
        "en":
            return "en"
        _:
            # e.g. en_IE stays English; unknown → default
            if full.begins_with("zh_"):
                return "zh_CN"
            return "en"


func _load_saved_locale() -> String:
    var cfg := ConfigFile.new()
    if cfg.load(CONFIG_PATH) != OK:
        return ""
    return str(cfg.get_value(CONFIG_SECTION, CONFIG_KEY_LOCALE, ""))


func _save_locale(locale: String) -> void:
    var cfg := ConfigFile.new()
    cfg.load(CONFIG_PATH)
    cfg.set_value(CONFIG_SECTION, CONFIG_KEY_LOCALE, locale)
    cfg.save(CONFIG_PATH)
