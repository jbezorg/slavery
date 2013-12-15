Scriptname _sf_ai_mes extends activemagiceffect

_sf_slavery     property slavery        auto

Actor kTarget
Bool  bAICurrent
Bool  bAIState

event OnEffectStart(Actor akTarget, Actor akCaster)
	GoToState("active")
	if akTarget
		kTarget = akTarget
	else
		kTarget = akCaster
	endIf
	
	if kTarget
		RegisterForSingleUpdate(1.0)
	else
		Dispel()
	endIf
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	slavery.SetAIActive(kTarget, false)
	GoToState("null")
endEvent

auto state active
	event OnUpdate()
		bAIState = slavery.LeashTrigger(kTarget)
		
		if bAIState != bAICurrent
			bAICurrent = bAIState
			slavery.SetAIActive(kTarget, bAIState)
		endIf

		RegisterForSingleUpdate(1.0)
	endEvent
endState

state null
	event OnUpdate()
	endEvent
endState