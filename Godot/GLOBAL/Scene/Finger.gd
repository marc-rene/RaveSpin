extends Area3D
class_name Player_Finger

enum E_FINGER
{
    FIRST,  # thumb
    SECOND, # index
    THIRD,  # middle
    FOURTH, # ring
    FIFTH, # punky
}


enum E_POSES
{
    THUMBS_UP,
    POINT_AND_THUMBS_UP, 
    POINT, 
    PEACE_SIGN, 
    FIST, 
    SPOCK,  # Index & Middle jointed together away from Ring & Pinky
    METAL,  # Devil horns - Eminem
    INDEX_THUMB_PINCH,
    NONE    # Open Hand
}

static var CURRENT_LEFT_HAND_POSE = E_POSES.NONE
static var CURRENT_RIGHT_HAND_POSE = E_POSES.NONE

# to avoid race-condition : SCUFFED 
@onready var is_main_signaller = (Which_Finger == E_FINGER.SECOND) and is_right_hand

@export var Which_Finger : E_FINGER # Which finger is this?
@export var is_right_hand : bool    # True == Right  |  False == Left

var active = true

func set_debug_colour():
    var debug_colour : Color
    if active:
        debug_colour = Color(0.106, 0.88, 0.106, 1.0)
    else:
        debug_colour = Color(1.0, 0.0, 0.0, 1.0)
        
    $CollisionShape3D.debug_color = debug_colour


func _ready() -> void:
    if is_right_hand:
        $"../../../../../../HandPoseDetector_RIGHT".pose_started.connect(_on_hand_pose_detector_pose_started)   
        $"../../../../../../HandPoseDetector_RIGHT".pose_ended.connect(_on_hand_pose_detector_pose_ended)   
    else:
        $"../../../../../../HandPoseDetector_LEFT".pose_started.connect(_on_hand_pose_detector_pose_started)   
        $"../../../../../../HandPoseDetector_LEFT".pose_ended.connect(_on_hand_pose_detector_pose_ended)   
    set_debug_colour()
    is_main_signaller = (Which_Finger == E_FINGER.SECOND) and is_right_hand
    



signal Fist_Pose_Start
signal Fist_Pose_End


signal ThumbsUp_Pose_Start
signal ThumbsUp_Pose_End

# Are we doing a Fist? Time to show the ray
func Set_Pointer_Ready(is_ready:bool):
    if is_ready and is_main_signaller:
        get_node("%MainFuctionPointer").enabled = true
        get_node("%MainFuctionPointer").show_target = true
        get_node("%MainFuctionPointer").show_laser = 1
        
    elif (is_ready == false) and is_main_signaller:
        get_node("%MainFuctionPointer").enabled = false
        get_node("%MainFuctionPointer").show_target = false
        get_node("%MainFuctionPointer").show_laser = 0
    
func Do_Pointer_Click():
    if get_node("%MainFuctionPointer").enabled and is_main_signaller:
        var ev := InputEventAction.new()
        ev.action = "trigger_click"
        ev.pressed = true
        Input.parse_input_event(ev)
        print("Trigger click simutlated")
        

func on_pose_changed(New_Pose : E_POSES):
    var pose_name = ""
    var is_ok_to_activate = false
    var DEBUG_OUTPUT_HAND = "Right Hand" if is_right_hand else "Left Hand"
    #print(DEBUG_OUTPUT_HAND + " Change")
    match New_Pose:
        E_POSES.THUMBS_UP:
            Do_Pointer_Click()
            if Which_Finger == E_FINGER.FIRST:
                 is_ok_to_activate = true
            pose_name = "THUMBS UP"
            
            # Hacky race-condition chaos fix
            if is_main_signaller:
                print("THUMBSUP EMMITTED")
                ThumbsUp_Pose_Start.emit()
               
        E_POSES.POINT_AND_THUMBS_UP:
            Do_Pointer_Click()
            if Which_Finger in [E_FINGER.FIRST, E_FINGER.SECOND]:
                 is_ok_to_activate = true
            pose_name = "POINT AND THUMBS UP"
        E_POSES.POINT:
            if Which_Finger == E_FINGER.SECOND:
                 is_ok_to_activate = true
            pose_name = "POINT"
        E_POSES.PEACE_SIGN:
            Set_Pointer_Ready(false)
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.THIRD]:
                 is_ok_to_activate = true
            pose_name = "PEACE SIGN"
        E_POSES.FIST:
            is_ok_to_activate = false
            pose_name = "FIST"
            if is_main_signaller:
                print("Fist Emiited")
                Set_Pointer_Ready(true)
                Fist_Pose_Start.emit()
                
        E_POSES.SPOCK:
            Set_Pointer_Ready(false)
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.THIRD, E_FINGER.FOURTH, E_FINGER.FIFTH]:
                 is_ok_to_activate = true
            pose_name = "SPOCK"
        E_POSES.METAL:
            Set_Pointer_Ready(false)
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.FIFTH]:
                 is_ok_to_activate = true
            pose_name = "METAL"
        E_POSES.INDEX_THUMB_PINCH:
            Set_Pointer_Ready(false)
            if Which_Finger == E_FINGER.SECOND: # Thumb and Index are so close and I dont want tomfoolery
                 is_ok_to_activate = true
            pose_name = "INDEX THUMB PINCH"
        E_POSES.NONE:
            Set_Pointer_Ready(false)
            is_ok_to_activate = true
            pose_name = "NONE"
            
    $"../../../Label3D".text = pose_name
    active = is_ok_to_activate
    set_debug_colour()

            
    


func _on_hand_pose_detector_pose_started(p_name: String) -> void:
    match p_name:
        "ThumbsUp":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.THUMBS_UP
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.THUMBS_UP 
        "Point Thumb Up":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.POINT_AND_THUMBS_UP
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.POINT_AND_THUMBS_UP 
        "Point":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.POINT
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.POINT 
        "Peace Sign":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.PEACE_SIGN
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.PEACE_SIGN 
        "Fist":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.FIST
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.FIST
        "Spock":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.SPOCK
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.SPOCK 
        "Metal":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.METAL
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.METAL 
        "Index Pinch":
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.INDEX_THUMB_PINCH
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.INDEX_THUMB_PINCH 
        _:
            if is_right_hand:
                CURRENT_RIGHT_HAND_POSE = E_POSES.NONE
            else:
                CURRENT_LEFT_HAND_POSE = E_POSES.NONE
           
    if is_right_hand:
        on_pose_changed(CURRENT_RIGHT_HAND_POSE)
    else:
        on_pose_changed(CURRENT_LEFT_HAND_POSE)



func _on_hand_pose_detector_pose_ended(p_name: String) -> void:
    if is_right_hand:
        CURRENT_RIGHT_HAND_POSE = E_POSES.NONE
        on_pose_changed(CURRENT_RIGHT_HAND_POSE)
    else:
        CURRENT_LEFT_HAND_POSE = E_POSES.NONE
        on_pose_changed(CURRENT_LEFT_HAND_POSE)
   
    if p_name == "Fist" and is_main_signaller:
        print("Hand stopped doing " + p_name)
        Fist_Pose_End.emit()

        
    if p_name == "ThumbsUp" and is_main_signaller:
        print("Hand stopped doing " + p_name)
        ThumbsUp_Pose_End.emit()
       
        


# Should we bother checking this finger for inputs?
func is_active() -> bool:
    return active
