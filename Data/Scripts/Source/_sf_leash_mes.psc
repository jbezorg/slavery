Scriptname _sf_leash_mes extends activemagiceffect

_sf_slavery     property slavery        auto

Actor kTarget

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
	GoToState("null")
endEvent

auto state active
	event OnUpdate()
		slavery.LeashTrigger(kTarget)
		RegisterForSingleUpdate(1.0)
	endEvent
endState

state null
	event OnUpdate()
	endEvent
endState
