extends Node
## Central saved settings manager (planned).
##
## This class will eventually hold user-facing config that should persist between sessions.
## Planned examples include language choice, controller scale, accessibility options, and UI scale.
##
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
class_name Saved_Settings

## Emitted after a setting value changes and is accepted.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
signal setting_changed(setting_key: StringName, new_value: Variant)

## Emitted after settings are loaded from storage.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
signal settings_loaded

## Emitted after settings are saved to storage.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
signal settings_saved

## Config file path for persisted settings.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const SETTINGS_FILE_PATH: String = "user://settings.cfg"

## Config section name used for saved values.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const SETTINGS_SECTION: StringName = &"ravespin"

## Default language locale code.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_LANGUAGE_CODE: String = "en"

## Default virtual controller scale multiplier.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_CONTROLLER_SCALE: float = 1.0

## Default in-world UI scale multiplier.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_UI_SCALE: float = 1.0

## Default high-contrast mode toggle.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_HIGH_CONTRAST: bool = false

## Default reduced-motion toggle.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_REDUCED_MOTION: bool = false

## Default tooltip enable state.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
const DEFAULT_TOOLTIPS_ENABLED: bool = true

## Currently selected locale code (for example: "en", "fr", "ga", "zh_CN").
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var language_code: String = DEFAULT_LANGUAGE_CODE

## World scale applied to the virtual controller rig.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var controller_scale: float = DEFAULT_CONTROLLER_SCALE

## Scale multiplier for 2D UI shown in XR viewports.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var ui_scale: float = DEFAULT_UI_SCALE

## Accessibility toggle for high contrast UI/material states.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var accessibility_high_contrast: bool = DEFAULT_HIGH_CONTRAST

## Accessibility toggle for reduced motion and animation intensity.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var accessibility_reduced_motion: bool = DEFAULT_REDUCED_MOTION

## Global tooltip visibility preference.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var tooltips_enabled: bool = DEFAULT_TOOLTIPS_ENABLED

## Internal guard so callers can check whether values came from disk.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
var has_loaded_from_disk: bool = false


## Resets in-memory values to project defaults.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func reset_to_defaults() -> int:
    language_code = DEFAULT_LANGUAGE_CODE
    controller_scale = DEFAULT_CONTROLLER_SCALE
    ui_scale = DEFAULT_UI_SCALE
    accessibility_high_contrast = DEFAULT_HIGH_CONTRAST
    accessibility_reduced_motion = DEFAULT_REDUCED_MOTION
    tooltips_enabled = DEFAULT_TOOLTIPS_ENABLED
    has_loaded_from_disk = false
    push_warning("Saved_Settings.reset_to_defaults() is NOT IMPLEMENTED for runtime propagation yet. DO NOT USE.")
    return ERR_UNAVAILABLE


## Loads persisted settings from `user://settings.cfg`.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func load_settings() -> int:
    push_warning("Saved_Settings.load_settings() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Saves current in-memory settings to `user://settings.cfg`.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func save_settings() -> int:
    push_warning("Saved_Settings.save_settings() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Applies current settings to active runtime systems (language, UI scale, controller scale, etc.).
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func apply_settings_to_runtime() -> int:
    push_warning("Saved_Settings.apply_settings_to_runtime() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Sets language preference and prepares it for save/apply.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_language_code(new_language_code: String) -> int:
    language_code = new_language_code.strip_edges()
    push_warning("Saved_Settings.set_language_code() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Sets preferred virtual controller scale.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_controller_scale(new_scale: float) -> int:
    controller_scale = maxf(0.1, new_scale)
    push_warning("Saved_Settings.set_controller_scale() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Sets preferred XR UI scale.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_ui_scale(new_scale: float) -> int:
    ui_scale = maxf(0.1, new_scale)
    push_warning("Saved_Settings.set_ui_scale() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Enables or disables high-contrast accessibility mode.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_accessibility_high_contrast(enabled: bool) -> int:
    accessibility_high_contrast = enabled
    push_warning("Saved_Settings.set_accessibility_high_contrast() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Enables or disables reduced-motion accessibility mode.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_accessibility_reduced_motion(enabled: bool) -> int:
    accessibility_reduced_motion = enabled
    push_warning("Saved_Settings.set_accessibility_reduced_motion() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE


## Enables or disables gameplay/control tooltips.
## @experimental: NOT IMPLEMENTED. DO NOT USE YET.
func set_tooltips_enabled(enabled: bool) -> int:
    tooltips_enabled = enabled
    push_warning("Saved_Settings.set_tooltips_enabled() is NOT IMPLEMENTED. DO NOT USE.")
    return ERR_UNAVAILABLE
