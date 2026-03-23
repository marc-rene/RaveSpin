@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin

func _enter_tree():
	export_plugin = WaveformGeneratorExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree():
	remove_export_plugin(export_plugin)
	export_plugin = null


class WaveformGeneratorExportPlugin extends EditorExportPlugin:
	var _plugin_name = "WaveformGenerator"
	var _addon_folder = "waveform_generator"

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if debug:
			return PackedStringArray([_addon_folder + "/bin/debug/" + _plugin_name + "-debug.aar"])
		else:
			return PackedStringArray([_addon_folder + "/bin/release/" + _plugin_name + "-release.aar"])

	func _get_name():
		return _plugin_name
