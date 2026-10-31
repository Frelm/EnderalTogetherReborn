Scriptname _00E_MQ00TemplePuzzleSCN extends ObjectReference	  
;DRSTG08AStoneSecretDoorOpenM

Event OnActivate(ObjectReference akActionRef)
	Actor PlayerRef = Game.GetForm(0x14) as Actor
	Actor actActor = akActionRef as Actor
	bool isLocal = (akActionRef == PlayerRef)
	bool isRemote = (actActor != None && (SkyrimTogetherUtils.IsRemotePlayer(actActor) || (actActor != PlayerRef && SkyrimTogetherUtils.IsPlayer(actActor))))

	if !Activated && ((isLocal && PlayerRef.GetItemCount(_00E_MQ00TempleKey) >= 1) || isRemote)
		if isLocal
			PlayerRef.RemoveItem(_00E_MQ00TempleKey, 1)
		endif
		MoveStone = true
		Runenstein.enable()
		Self.GetNthLinkedRef(1).enable(True)
		Self.GetNthLinkedRef(2).TranslateTo(3231.4490, 9968.7236, 1104.0, 0.0, 0.0, 270, 20)
		StoneSound = DRSStoneRotatingDiscLPM.Play(Self.GetNthLinkedRef(2))
		Sound.SetInstanceVolume(StoneSound, 5)
		Utility.Wait(2.0)
		Self.GetNthLinkedRef(3).enable(True)
		Self.GetNthLinkedRef(4).TranslateTo(3104, 10080, 1184.0, 0.0, 0.0, 180, 20)
		Utility.Wait(3.0)
		Self.GetNthLinkedRef(5).enable(True)
		Self.GetNthLinkedRef(6).TranslateTo(3040, 10272, 1200, 0.0, 0.0, 90, 25)
		Self.GetNthLinkedRef(1).Disable(True)
		Utility.Wait(3.0)
		Self.GetNthLinkedRef(7).enable(True)
		Self.GetNthLinkedRef(3).Disable(True)
		Self.GetNthLinkedRef(8).TranslateTo(3040, 10464, 1280, 0.0, 0.0, 250, 30)
		Utility.Wait(3.0)
		Self.GetNthLinkedRef(9).enable(True)
		Self.GetNthLinkedRef(5).Disable(True)
		Self.GetNthLinkedRef(10).TranslateTo(3088, 10624, 1216, 0.0, 0.0, 90, 35)
		Utility.Wait(4.5)
		Self.GetNthLinkedRef(7).Disable(True)
		Utility.Wait(4.9)
		Self.GetNthLinkedRef(9).Disable(True)
		Activated = True
	ElseIf !MoveStone && isLocal
		_00E_MQP03_sMechanismSomethingMissing.Show()
	EndIf
EndEvent

Event OnLoad()
	if Count == False
		_00E_Questshader.Play(Self)
		Count = True
	endif
    ; Failsave to ensure that leaving the cell does not stop the
    ; pillars from rising.
	if MoveStone == true
		if ( Self.GetNthLinkedRef(2).GetPositionZ() < 1100 || Self.GetNthLinkedRef(4).GetPositionZ() < 1180 || Self.GetNthLinkedRef(6).GetPositionZ() < 1197 || Self.GetNthLinkedRef(8).GetPositionZ() < 1276 || Self.GetNthLinkedRef(10).GetPositionZ() < 1214 )
			Self.GetNthLinkedRef(1).enable(True)
			Self.GetNthLinkedRef(2).TranslateTo(3231.4490, 9968.7236, 1104.0, 0.0, 0.0, 270, 20)
			StoneSound = DRSStoneRotatingDiscLPM.Play(Self.GetNthLinkedRef(2))
			Sound.SetInstanceVolume(StoneSound, 5)
			Utility.Wait(2.0)
			Self.GetNthLinkedRef(3).enable(True)
			Self.GetNthLinkedRef(4).TranslateTo(3104, 10080, 1184.0, 0.0, 0.0, 180, 20)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(5).enable(True)
			Self.GetNthLinkedRef(6).TranslateTo(3040, 10272, 1200, 0.0, 0.0, 90, 25)
			Self.GetNthLinkedRef(1).Disable(True)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(7).enable(True)
			Self.GetNthLinkedRef(3).Disable(True)
			Self.GetNthLinkedRef(8).TranslateTo(3040, 10464, 1280, 0.0, 0.0, 250, 30)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(9).enable(True)
			Self.GetNthLinkedRef(5).Disable(True)
			Self.GetNthLinkedRef(10).TranslateTo(3088, 10624, 1216, 0.0, 0.0, 90, 35)
			Utility.Wait(4.5)
			Self.GetNthLinkedRef(7).Disable(True)
			Utility.Wait(4.9)
			Self.GetNthLinkedRef(9).Disable(True)
			Activated = True
		endif
	endif
EndEvent

Event OnCellAttach()
    ; Failsave to ensure that leaving the cell does not stop the
    ; pillars from rising.
	if MoveStone == true
		if ( Self.GetNthLinkedRef(2).GetPositionZ() < 1100 || Self.GetNthLinkedRef(4).GetPositionZ() < 1180 || Self.GetNthLinkedRef(6).GetPositionZ() < 1197 || Self.GetNthLinkedRef(8).GetPositionZ() < 1276 || Self.GetNthLinkedRef(10).GetPositionZ() < 1214 )
			Self.GetNthLinkedRef(1).enable(True)
			Self.GetNthLinkedRef(2).TranslateTo(3231.4490, 9968.7236, 1104.0, 0.0, 0.0, 270, 20)
			StoneSound = DRSStoneRotatingDiscLPM.Play(Self.GetNthLinkedRef(2))
			Sound.SetInstanceVolume(StoneSound, 5)
			Utility.Wait(2.0)
			Self.GetNthLinkedRef(3).enable(True)
			Self.GetNthLinkedRef(4).TranslateTo(3104, 10080, 1184.0, 0.0, 0.0, 180, 20)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(5).enable(True)
			Self.GetNthLinkedRef(6).TranslateTo(3040, 10272, 1200, 0.0, 0.0, 90, 25)
			Self.GetNthLinkedRef(1).Disable(True)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(7).enable(True)
			Self.GetNthLinkedRef(3).Disable(True)
			Self.GetNthLinkedRef(8).TranslateTo(3040, 10464, 1280, 0.0, 0.0, 250, 30)
			Utility.Wait(3.0)
			Self.GetNthLinkedRef(9).enable(True)
			Self.GetNthLinkedRef(5).Disable(True)
			Self.GetNthLinkedRef(10).TranslateTo(3088, 10624, 1216, 0.0, 0.0, 90, 35)
			Utility.Wait(4.5)
			Self.GetNthLinkedRef(7).Disable(True)
			Utility.Wait(4.9)
			Self.GetNthLinkedRef(9).Disable(True)
			Activated = True
		endif
	endif
endevent

Function StopSound()
	Sound.StopInstance(StoneSound)
EndFunction

Message Property _00E_MQP03_sMechanismTriggered Auto
Message Property _00E_MQP03_sMechanismSomethingMissing Auto

Int StoneSound 
MiscObject Property _00E_MQ00TempleKey Auto
ObjectReference Property Runenstein Auto
EffectShader Property _00E_Questshader Auto
Sound Property DRSTG08AStoneSecretDoorOpenM Auto
Sound Property DRSStoneLabyrinthianCloseM Auto
Sound Property DRSStoneRotatingDiscLPM Auto
Bool Activated = False
Bool Count = False
bool MoveStone
