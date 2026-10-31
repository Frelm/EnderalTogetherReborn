Scriptname _00E_MQP03_ExitDoorScript extends ObjectReference  

bool Done = False

Event OnActivate(ObjectReference akActionRef)

	Actor actActor = akActionRef as Actor
	if (akActionRef == Game.GetPlayer() || (actActor != None && SkyrimTogetherUtils.IsPlayer(actActor))) && !Done
		MQP03.SetCurrentStageID(70)
		Done = True
	EndIf	

EndEvent

Quest Property MQP03 Auto