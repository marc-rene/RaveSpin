class_name WaveformGenerator
extends RefCounted

## Generates waveform PNGs from audio at runtime.
## On Android/Quest uses the WaveformGenerator plugin (ffmpeg-kit). On desktop uses the GDExtension if loaded.

static func generate(audio_path: String, output_png_path: String, width: int = 1200, height: int = 320) -> int:
    if OS.get_name() == "Android":
        if Engine.has_singleton("WaveformGenerator"):
            return Engine.get_singleton("WaveformGenerator").generate(audio_path, output_png_path, width, height)
        push_error("WaveformGenerator: Android plugin not found. Enable the plugin and use Gradle build.")
        return -1
    else:
        # Desktop: use GDExtension class if available (registered as WaveformGeneratorNative)
        if ClassDB.class_exists("WaveformGeneratorNative"):
            var gen = ClassDB.instantiate("WaveformGeneratorNative")
            if gen:
                return gen.generate(audio_path, output_png_path, width, height) 
        push_error("WaveformGenerator: GDExtension not loaded on desktop. Build and load the extension, or use only on Android.")
        return -1
