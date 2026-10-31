Scriptname _00E_DungeonLiftScript extends ObjectReference  
{Place this on a lift platform (and follow the tutorial in the comments!) to make a platform move when a trigger is activated.}

Event OnActivate(ObjectReference akActionRef)
    Actor actActor = akActionRef as Actor
    bool isAllowed = (akActionRef == Game.GetPlayer()) || (actActor != None && SkyrimTogetherUtils.IsPlayer(actActor)) || (akActionRef != None && !(akActionRef as Actor))

    if isAllowed
        
        if DisablePlayerControlsDuringRide == True && akActionRef == Game.GetPlayer()
            Game.DisablePlayerControls()
        EndIf

        if UpDown == 0
            LiftMarkerTop.SetAngle(self.GetAngleX(), self.GetAngleY(), self.GetAngleZ())
            self.TranslateToRef(LiftMarkerTop, MovementSpeed, 10.0)
        ElseIf UpDown == 1
            self.TranslateToRef(LiftMarkerBottom, MovementSpeed, 10.0)
            LiftMarkerBottom.SetAngle(self.GetAngleX(), self.GetAngleY(), self.GetAngleZ())
        EndIf

        if doubleclick == False
            if MechanicalLift == True
                MoveSound = _00E_SternenstadtLifeSoundMarker.Play(Self)
            Else
                MoveSound = DRSStoneRotatingDiscLPM.Play(Self)
            EndIf
            doubleclick = True
        endif
    EndIf
	
EndEvent

Event OnTranslationAlmostComplete()

    if DisablePlayerControlsDuringRide == True
        Game.EnablePlayerControls()
    EndIf

    Sound.StopInstance(MoveSound) ; Stops the loop Sound

    if UpDown == 0
        UpDown = 1
    ElseIf UpDown == 1
        UpDown = 0
    EndIf
    
    doubleclick = False

EndEvent


int UpDown ; 1 = Lift is at the top, 0 = Lift is at the bottom
int MoveSound
bool doubleclick = False ; True = player is activating while the lift is in
                         ; motion (hence, don't play sound again)
float Property MovementSpeed = 100.0 Auto
{How fast the platform should move - Start at 100.0 and work your way up! 1 is barely visible to the human eye.}
Bool Property DisablePlayerControlsDuringRide Auto
{Should the player controls be disabled once the switch has been hit?}
Bool Property MechanicalLift = False Auto ; Check this if the lift is mechanical
{Set this to true if the lift should play a mechanical sound instead of a "crumbling stone"-sound}
ObjectReference Property LiftMarkerTop Auto
{The X-Marker Reference where the lift will stop moving at the top}
ObjectReference Property LiftMarkerBottom Auto
{The X-Marker Reference where the lift will stop moving at the bottom (Set this XMarker's coordinates to match the platforms coordinates!}
Sound Property DRSStoneRotatingDiscLPM Auto
Sound Property _00E_SternenstadtLifeSoundMarker Auto


;"WICHTIG!

;- Lifte nirgendwo platzieren, wo es GEGNER gibt!
;- KEIN Navmesh auf der Liftplattform , da sich Navmesh nicht mitbewegt! Ergo keine Litftplattformen in Dungeons für Begleiter!


;TUTORIAL ZUM ERSTELLEN BEWEGBARER PLATTFORMEN!

;1.) Sucht das .nif des Objektes, das ihr als Plattform verwenden wollt
;2.) Öffnet es mit NifSkope
;3.) Ändert in den bhkRigidBody settings des Objektes folgendes:
;	- Layer: OL_STATIC in OL_ANIM_STATIC unändern
;	- Layer Copy: OL_STATIC in OL_ANIM_STATIC umändern
;	- Motion System: MO_SYS_BOX_STAILIZED in MO_SYS_BOX umändern
;4.) Speichert das .nif ab, unter dem Pfad meshes/Enderal/Dungeons/NameEuresObjektes.nif
;5.) Erstellt ein neues MoveableStatic mit dem Objekt als .nif
;6.) Legt dieses Skript auf die Referenz der Plattform, d.h. geht zu eurem Dungeon, platziert die Plattform, doppelklickt sie und geht zum Tab "Scripts" und fügt dieses Skript zu
;7.) Drückt auf Properties, drückt Auto-Fill, die Sound-Properties sollte nun gefüllt sein
;8.) Setzt die "DisablePlayer..." und "MechanicalLift" Properties auf TRUE wenn sie es sein sollen - Das heißt, wenn der Spieler sich während der Liftfahrt nicht bewegen können soll oder der Lift mechanisch ist.
;9.) Weißt dem LiftMarkerTop und dem LiftMarkerBottom jeweils zwei XMarker zu, die ihr an den Start und an den Endpunkten des Liftes platziert. Der Liftmarker Bottom sollte GENAU dieselben Koordinaten wie die Liftplattform
;	im Ursprungszustand haben
;10.) Nun platziert eine Kette, einen Hebel, oder eine Triggerbox (oder sonst etwas), mit dem der Lift aktiviert werden soll. Nun doppelklickt ihr den Lift und geht zum Tab "ActivateParents". Dort doppelklickt ihr
;	und wählt die Kette oder den Hebel aus.
; 11.) Alles sollte klappen. Hurra! :)@"