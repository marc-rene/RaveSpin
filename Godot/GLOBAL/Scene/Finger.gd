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
    NONE    # Open Hand # Nevermind this NEVER triggers
}

const Acceptable_Selection_Poses : Array[E_POSES] = [E_POSES.THUMBS_UP, E_POSES.POINT_AND_THUMBS_UP, E_POSES.INDEX_THUMB_PINCH]

@onready var DEBUG_Left_Label : Label3D = %Left_Label3D
@onready var DEBUG_Right_Label : Label3D = %Right_Label3D


static var CURRENT_LEFT_HAND_POSE = E_POSES.NONE
static var CURRENT_RIGHT_HAND_POSE = E_POSES.NONE

# to avoid race-condition : SCUFFED 
@onready var is_main_signaller = (Which_Finger == E_FINGER.SECOND)

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
    is_main_signaller = (Which_Finger == E_FINGER.SECOND)
    
    if is_right_hand and is_main_signaller:
        %HandPoseDetector_RIGHT.pose_started.connect(_on_hand_pose_detector_pose_started_R)   
        %HandPoseDetector_RIGHT.pose_ended.connect(_on_hand_pose_detector_pose_ended_R)   
        self.Fist_Pose_Start_R.connect(Set_Pointer_Enabled.bind(true, true)) #Right hand, enabled!
        self.Fist_Pose_End_R.connect(Set_Pointer_Enabled.bind(true, false)) #Right hand, Disabled
        self.ThumbsUp_Pose_Start_R.connect(Do_Pointer_Click.bind(true)) #Right hand, enabled!
    elif is_main_signaller:
        %HandPoseDetector_LEFT.pose_started.connect(_on_hand_pose_detector_pose_started_L)   
        %HandPoseDetector_LEFT.pose_ended.connect(_on_hand_pose_detector_pose_ended_L)   
        self.Fist_Pose_Start_L.connect(Set_Pointer_Enabled.bind(false, true)) #Left hand, enabled!
        self.Fist_Pose_End_L.connect(Set_Pointer_Enabled.bind(false, false)) #Left hand, Disabled
        self.ThumbsUp_Pose_Start_L.connect(Do_Pointer_Click.bind(false)) #Left hand
    set_debug_colour()
    
    Set_Pointer_Enabled(false, false) # disable left hand
    Set_Pointer_Enabled(true, false) # disable right hand
       


signal Fist_Pose_Start_R
signal Fist_Pose_Start_L
signal Fist_Pose_End_R
signal Fist_Pose_End_L

signal ThumbsUp_Pose_Start_R
signal ThumbsUp_Pose_Start_L
signal ThumbsUp_Pose_End_R
signal ThumbsUp_Pose_End_L


@onready var XR_Hand_Ref_L : XRController3D = %XR_LeftHand
@onready var XR_Hand_Ref_R : XRController3D = %XR_RightHand
@onready var XR_Hand_Ref_FP_L : XRToolsFunctionPointer = %Left_MainFuctionPointer
@onready var XR_Hand_Ref_FP_R : XRToolsFunctionPointer = %Right_MainFuctionPointer

func Set_Pointer_Enabled(use_right_hand: bool, Is_Enabled: bool):
    if use_right_hand and is_main_signaller:
        XR_Hand_Ref_FP_R.set_enabled(Is_Enabled)
        XR_Hand_Ref_FP_R.set_distance(5 if Is_Enabled else 0)
        XR_Hand_Ref_FP_R.set_show_target(Is_Enabled)
        DEBUG_Right_Label.modulate = Color("44bba4ff") if Is_Enabled else Color("e94f37ff")
        XR_Hand_Ref_FP_R.set_show_laser(XRToolsFunctionPointer.LaserShow.SHOW if Is_Enabled else XRToolsFunctionPointer.LaserShow.HIDE)
    
    elif is_main_signaller:
        XR_Hand_Ref_FP_L.set_enabled(Is_Enabled)
        XR_Hand_Ref_FP_L.set_show_target(Is_Enabled)
        XR_Hand_Ref_FP_L.set_distance(5 if Is_Enabled else 0)
        DEBUG_Left_Label.modulate = Color("44bba4ff") if Is_Enabled else Color("e94f37ff")
        XR_Hand_Ref_FP_L.set_show_laser(XRToolsFunctionPointer.LaserShow.SHOW if Is_Enabled else XRToolsFunctionPointer.LaserShow.HIDE)

        
        
func Do_Pointer_Click(use_right_hand: bool):
    if use_right_hand and is_main_signaller:
        #XR_Hand_Ref_FP_R._on_button_pressed("trigger_click", XR_Hand_Ref_R)
        await _simulate_pointer_click(XR_Hand_Ref_FP_R, XR_Hand_Ref_R)    
        DEBUG_Right_Label.modulate = Color("edae49ff")
        print("WE DID A R CLICK")
    elif is_main_signaller:
        #XR_Hand_Ref_FP_L._on_button_pressed("trigger_click", XR_Hand_Ref_L)    
        await _simulate_pointer_click(XR_Hand_Ref_FP_L, XR_Hand_Ref_L)
        DEBUG_Left_Label.modulate = Color("edae49ff")
        print("WE DID A L CLICK")



func _simulate_pointer_click(pointer: XRToolsFunctionPointer, hand: XRController3D) -> void:
    if pointer == null or hand == null or !pointer.enabled:
        return
    pointer._on_button_pressed("trigger_click", hand)
    await get_tree().process_frame # must wait otherwise tomfoolery
    
    pointer._on_button_released("trigger_click", hand)
    
func Set_Finger_Active_Status(New_Pose : E_POSES):
    var is_ok_to_activate = false
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



static func translate_pose_name_to_enum(pose_name : String) -> E_POSES:
    match pose_name:
        "ThumbsUp":
            return E_POSES.THUMBS_UP
        "Point Thumb Up":
            return E_POSES.POINT_AND_THUMBS_UP
        "Point":
            return E_POSES.POINT
        "Peace Sign":
            return E_POSES.PEACE_SIGN 
        "Fist":
            return E_POSES.FIST
        "Spock":
            return E_POSES.SPOCK 
        "Metal":
            return E_POSES.METAL 
        "Index Pinch":
            return E_POSES.INDEX_THUMB_PINCH 
        _:
            return E_POSES.NONE



# --------------- LEFT HAND ---------------- 
func _on_hand_pose_detector_pose_started_L(p_name: String) -> void:
    if is_main_signaller:
        DEBUG_Left_Label.text = p_name
        var primed : bool = CURRENT_LEFT_HAND_POSE == E_POSES.FIST
        CURRENT_LEFT_HAND_POSE = translate_pose_name_to_enum(p_name)
        if CURRENT_LEFT_HAND_POSE == E_POSES.FIST:
            Fist_Pose_Start_L.emit()
        elif CURRENT_LEFT_HAND_POSE in Acceptable_Selection_Poses and primed:
            ThumbsUp_Pose_Start_L.emit()
        else:
            Fist_Pose_End_L.emit()
            ThumbsUp_Pose_End_L.emit()
    Set_Finger_Active_Status(CURRENT_LEFT_HAND_POSE)
        
func _on_hand_pose_detector_pose_ended_L(p_name: String) -> void:
    if is_main_signaller:
        if translate_pose_name_to_enum(p_name) == E_POSES.FIST:
            pass
        elif translate_pose_name_to_enum(p_name) in Acceptable_Selection_Poses :
            ThumbsUp_Pose_End_L.emit()
        else:
            Fist_Pose_End_L.emit()
            ThumbsUp_Pose_End_L.emit()
    Set_Finger_Active_Status(CURRENT_LEFT_HAND_POSE)
# ------------------------------------------ 



# --------------- RIGHT HAND --------------- 
func _on_hand_pose_detector_pose_started_R(p_name: String) -> void:
    if is_main_signaller:
        DEBUG_Right_Label.text = p_name
        var primed : bool = CURRENT_RIGHT_HAND_POSE == E_POSES.FIST
        CURRENT_RIGHT_HAND_POSE = translate_pose_name_to_enum(p_name)
        if CURRENT_RIGHT_HAND_POSE == E_POSES.FIST:
            Fist_Pose_Start_R.emit()
        elif CURRENT_RIGHT_HAND_POSE in Acceptable_Selection_Poses and primed:
            ThumbsUp_Pose_Start_R.emit()
        else:
            Fist_Pose_End_R.emit()
            ThumbsUp_Pose_End_R.emit()
    Set_Finger_Active_Status(CURRENT_RIGHT_HAND_POSE)
        
func _on_hand_pose_detector_pose_ended_R(p_name: String) -> void:
    if is_main_signaller:
        print("STOPPED DOING A " + p_name)
        if translate_pose_name_to_enum(p_name) == E_POSES.FIST:
            pass
        elif translate_pose_name_to_enum(p_name) in Acceptable_Selection_Poses :
            ThumbsUp_Pose_End_R.emit()
        else:
            Fist_Pose_End_R.emit()
            ThumbsUp_Pose_End_R.emit()
    Set_Finger_Active_Status(CURRENT_RIGHT_HAND_POSE)
# ------------------------------------------ 
    


# Should we bother checking this finger for inputs?
func is_active() -> bool:
    return active
