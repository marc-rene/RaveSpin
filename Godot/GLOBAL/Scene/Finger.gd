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


@export var Which_Finger : E_FINGER # Which finger is this?
@export var is_right_hand : bool    # True == Right  |  False == Left

var active = true

func set_debug_colour():
    var debug_colour = Color(0,0,0)
    if active:
        # super scuffed unique colour
        $CollisionShape3D.debug_color = debug_colour.from_rgba8(5, ((Which_Finger+1) * 211 % 255), ((Which_Finger+1) * 281 % 255))
    else:
        $CollisionShape3D.debug_color = debug_colour.from_rgba8(255,0,0,150)
        


func _ready() -> void:
    $"../../../../../../HandPoseDetector".pose_started.connect(_on_hand_pose_detector_pose_started)   
    $"../../../../../../HandPoseDetector".pose_ended.connect(_on_hand_pose_detector_pose_ended)   
    set_debug_colour()
    
    

func on_pose_changed(New_Pose : E_POSES):
    var pose_name = ""
    match New_Pose:
        E_POSES.THUMBS_UP:
            pose_name = "THUMBS UP"
        E_POSES.POINT_AND_THUMBS_UP:
            pose_name = "POINT AND THUMBS UP"
        E_POSES.POINT:
            pose_name = "POINT"
        E_POSES.PEACE_SIGN:
            pose_name = "PEACE SIGN"
        E_POSES.FIST:
            pose_name = "FIST"
        E_POSES.SPOCK:
            pose_name = "SPOCK"
        E_POSES.METAL:
            pose_name = "METAL"
        E_POSES.INDEX_THUMB_PINCH:
            pose_name = "INDEX THUMB PINCH"
        E_POSES.NONE:
            pose_name = "NONE"

    $"../../../Label3D".text = pose_name
    var is_ok_to_activate = false
    var DEBUG_OUTPUT_HAND = "Right Hand" if is_right_hand else "Left Hand"
    print(DEBUG_OUTPUT_HAND + " is doing pose: " + str(New_Pose))
    match New_Pose:
        E_POSES.THUMBS_UP:
            if Which_Finger == E_FINGER.FIRST:
                 is_ok_to_activate = true
        E_POSES.POINT_AND_THUMBS_UP:
            if Which_Finger in [E_FINGER.FIRST, E_FINGER.SECOND]:
                 is_ok_to_activate = true
        E_POSES.POINT:
            if Which_Finger == E_FINGER.SECOND:
                 is_ok_to_activate = true
        E_POSES.PEACE_SIGN:
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.THIRD]:
                 is_ok_to_activate = true
        E_POSES.FIST:
            is_ok_to_activate = false
        E_POSES.SPOCK:
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.THIRD, E_FINGER.FOURTH, E_FINGER.FIFTH]:
                 is_ok_to_activate = true
        E_POSES.METAL:
            if Which_Finger in [E_FINGER.SECOND, E_FINGER.FIFTH]:
                 is_ok_to_activate = true
        E_POSES.INDEX_THUMB_PINCH:
            if Which_Finger == E_FINGER.SECOND: # Thumb and Index are so close and I dont want tomfoolery
                 is_ok_to_activate = true
        E_POSES.NONE:
            is_ok_to_activate = true
            
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
    


# Should we bother checking this finger for inputs?
func is_active() -> bool:
    return active
