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
        %HandPoseDetector_RIGHT.pose_started.connect(_on_hand_pose_detector_pose_started_R)   
        %HandPoseDetector_RIGHT.pose_ended.connect(_on_hand_pose_detector_pose_ended_R)   
    else:
        %HandPoseDetector_LEFT.pose_started.connect(_on_hand_pose_detector_pose_started_L)   
        %HandPoseDetector_LEFT.pose_ended.connect(_on_hand_pose_detector_pose_ended_L)   
    set_debug_colour()
    is_main_signaller = (Which_Finger == E_FINGER.SECOND)
    
    self.Fist_Pose_Start_L.connect(Set_Pointer_Enabled.bind(false, true)) #Left hand, enabled!
    self.Fist_Pose_End_L.connect(Set_Pointer_Enabled.bind(false, false)) #Left hand, Disabled
    self.Fist_Pose_Start_R.connect(Set_Pointer_Enabled.bind(true, true)) #Right hand, enabled!
    self.Fist_Pose_End_R.connect(Set_Pointer_Enabled.bind(true, false)) #Right hand, Disabled
    
    self.ThumbsUp_Pose_Start_L.connect(Do_Pointer_Click.bind(false)) #Left hand
    #self.ThumbsUp_Pose_End_L.connect(Do_Pointer_Click.bind(false, false)) #Left hand, Disabled
    self.ThumbsUp_Pose_Start_R.connect(Do_Pointer_Click.bind(true)) #Right hand, enabled!
    #self.ThumbsUp_Pose_End_R.connect(Do_Pointer_Click.bind(true, false)) #Right hand, Disabled
    Set_Pointer_Enabled(false, false) # disable left hand
    Set_Pointer_Enabled(true, false) # disable right hand
    
    #XR_Hand_Ref_L = %XR_LeftHand
    #XR_Hand_Ref_R = %XR_RightHand
    #XR_Hand_Ref_FP_L = %Left_MainFuctionPointer
    #XR_Hand_Ref_FP_R = %Right_MainFuctionPointer

    


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
    if use_right_hand:
        XR_Hand_Ref_FP_L.set_enabled(Is_Enabled)
        XR_Hand_Ref_FP_L.set_show_laser(XRToolsFunctionPointer.LaserShow.SHOW if Is_Enabled else XRToolsFunctionPointer.LaserShow.HIDE)
    
    else:
        XR_Hand_Ref_FP_R.set_enabled(Is_Enabled)
        XR_Hand_Ref_FP_R.set_show_laser(XRToolsFunctionPointer.LaserShow.SHOW if Is_Enabled else XRToolsFunctionPointer.LaserShow.HIDE)
        
        
func Do_Pointer_Click(use_right_hand: bool):
    if use_right_hand:
        XR_Hand_Ref_FP_R._on_button_pressed("trigger_click", XR_Hand_Ref_R)    
    else:
        XR_Hand_Ref_FP_L._on_button_pressed("trigger_click", XR_Hand_Ref_L)    

    print("WE DID A CLICK")
    

        

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



func _on_hand_pose_detector_pose_started_L(p_name: String) -> void:
    if is_main_signaller:
        %Left_Label3D.text = p_name
        var primed = CURRENT_LEFT_HAND_POSE == E_POSES.FIST
        CURRENT_LEFT_HAND_POSE = translate_pose_name_to_enum(p_name)
        #on_pose_changed(CURRENT_LEFT_HAND_POSE)
        if CURRENT_LEFT_HAND_POSE == E_POSES.FIST:
            print("Left Hand started doing Fist")
            Fist_Pose_Start_L.emit()
            
        elif CURRENT_LEFT_HAND_POSE in [E_POSES.THUMBS_UP, E_POSES.POINT_AND_THUMBS_UP, E_POSES.INDEX_THUMB_PINCH] and primed:
            print("Left Hand started doing Selection")
            ThumbsUp_Pose_Start_L.emit()
    Set_Finger_Active_Status(CURRENT_LEFT_HAND_POSE)
        


func _on_hand_pose_detector_pose_ended_L(p_name: String) -> void:
    if is_main_signaller:
        %Left_Label3D.text = "N/A"
        if translate_pose_name_to_enum(p_name) == E_POSES.FIST :
            print("Hand stopped doing Fist")
            Fist_Pose_End_L.emit()
            
        elif translate_pose_name_to_enum(p_name) in [E_POSES.THUMBS_UP, E_POSES.POINT_AND_THUMBS_UP] :
            print("Hand stopped doing Thumbs Up")
            ThumbsUp_Pose_End_L.emit()
    Set_Finger_Active_Status(CURRENT_LEFT_HAND_POSE)



func _on_hand_pose_detector_pose_started_R(p_name: String) -> void:
    if is_main_signaller:
        %Right_Label3D.text = p_name
        var primed = CURRENT_RIGHT_HAND_POSE == E_POSES.FIST
        CURRENT_RIGHT_HAND_POSE = translate_pose_name_to_enum(p_name)
        
        #on_pose_changed(CURRENT_LEFT_HAND_POSE)
        if CURRENT_RIGHT_HAND_POSE == E_POSES.FIST:
            print("Right Hand started doing Fist")
            Fist_Pose_Start_R.emit()
            
        elif CURRENT_RIGHT_HAND_POSE in [E_POSES.THUMBS_UP, E_POSES.POINT_AND_THUMBS_UP, E_POSES.INDEX_THUMB_PINCH] and primed:
            print("Right Hand started doing Selection")
            ThumbsUp_Pose_Start_R.emit()
    Set_Finger_Active_Status(CURRENT_RIGHT_HAND_POSE)
        


func _on_hand_pose_detector_pose_ended_R(p_name: String) -> void:
    if is_main_signaller:
        %Right_Label3D.text = "N/A"
        if translate_pose_name_to_enum(p_name) == E_POSES.FIST :
            print("Right Hand stopped doing Fist")
            Fist_Pose_End_R.emit()
            
        elif translate_pose_name_to_enum(p_name) in [E_POSES.THUMBS_UP, E_POSES.POINT_AND_THUMBS_UP] :
            print("Right Hand stopped doing Thumbs Up")
            ThumbsUp_Pose_End_R.emit()
    Set_Finger_Active_Status(CURRENT_RIGHT_HAND_POSE)
    


# Should we bother checking this finger for inputs?
func is_active() -> bool:
    return active
