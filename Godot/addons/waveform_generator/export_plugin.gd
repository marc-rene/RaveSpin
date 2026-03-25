@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin = null


func _enter_tree() -> void:
    export_plugin = WaveformGeneratorExportPlugin.new()
    add_export_plugin(export_plugin)


func _exit_tree() -> void:
    remove_export_plugin(export_plugin)
    export_plugin = null


class WaveformGeneratorExportPlugin extends EditorExportPlugin:
    var _plugin_name: String = "WaveformGenerator"
    var _addon_folder: String = "waveform_generator"

    func _supports_platform(platform: EditorExportPlatform) -> bool:
        if platform is EditorExportPlatformAndroid:
            return true
        return false

    func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
        if debug:
            return PackedStringArray([_addon_folder + "/bin/debug/" + _plugin_name + "-debug.aar"])
        else:
            return PackedStringArray([_addon_folder + "/bin/release/" + _plugin_name + "-release.aar"])

    func _get_name() -> String:
        return _plugin_name
