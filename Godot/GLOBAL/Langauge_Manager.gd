extends Node

## Runtime language manager.
## Loads locale preference, applies it through `TranslationServer`, and persists selection.
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


## Applies saved locale (or OS/default fallback) at startup.
func _ready() -> void:
    var saved: String = _load_saved_locale()
    if saved.is_empty() or (saved not in SUPPORTED_LOCALES):
        current_locale = _locale_from_os()
    else:
        current_locale = saved
    if not current_locale or current_locale.is_empty():
        current_locale = "en"
    apply_locale(current_locale)


## Picks supported locale from operating system language.
## OS.get_locale_language() returns "zh" for Chinese users; TranslationServer uses "zh_CN" in project settings.
func _locale_from_os() -> String:
    var lang : String= OS.get_locale_language()
    if lang == "zh":
        return "zh_CN"
    if lang in SUPPORTED_LOCALES:
        return lang
    return "en"


## Applies locale to runtime and saves it to config.
func apply_locale(locale: String) -> void:
    if not locale in SUPPORTED_LOCALES:
        locale = "en"
    current_locale = locale
    TranslationServer.set_locale(locale)
    
    _save_locale(locale)


## Returns display label for locale code.
func get_locale_display_name(locale: String) -> String:
    return LOCALE_DISPLAY_NAMES.get(locale, locale)


## Loads saved locale from config file.
func _load_saved_locale() -> String:
    var cfg := ConfigFile.new()
    if cfg.load(CONFIG_PATH) != OK:
        return ""
    return str(cfg.get_value(CONFIG_SECTION, CONFIG_KEY_LOCALE, ""))


## Saves locale to config file.
func _save_locale(locale: String) -> void:
    var cfg := ConfigFile.new()
    cfg.load(CONFIG_PATH)
    cfg.set_value(CONFIG_SECTION, CONFIG_KEY_LOCALE, locale)
    cfg.save(CONFIG_PATH)

