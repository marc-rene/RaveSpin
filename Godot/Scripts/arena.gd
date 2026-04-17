extends Node3D

## Arena root runtime script
## Enables XR viewport output, passthrough, and recentres the gameplay setup
var xr_interface: XRInterface
@onready var environment:Environment = $"WorldEnvironment".environment



## Try passthrough first, then alpha blend fallback if supported
func enable_passthrough() -> bool:
    if xr_interface and xr_interface.is_passthrough_supported():
        return xr_interface.start_passthrough()
    else:
        var modes = xr_interface.get_supported_environment_blend_modes()
        if xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
            xr_interface.set_environment_blend_mode(xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
            return true
        else:
            return false
            
            

@export var Player_cam : RaveSpin_XRCamera3D
## Recentres the in-world layout from the active XR camera orientation
func recenter():
    Player_cam.recenter()

## Grabs XR interface and applies startup XR configuration for the main scene
func _ready():
    xr_interface = XRServer.primary_interface
    if xr_interface and xr_interface.is_initialized():
        print("OpenXR initialised successfully")

        # Turn off v-sync!
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

        # Change our main viewport to output to the HMD
        get_viewport().use_xr = true
        enable_passthrough()
        xr_interface.pose_recentered.connect(recenter)
        await get_tree().create_timer(0.2).timeout
        recenter()
    else:
        print("OpenXR not initialized, please check if your headset is connected")
