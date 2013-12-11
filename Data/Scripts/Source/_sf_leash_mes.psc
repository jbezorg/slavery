Scriptname _sf_leash_mes extends activemagiceffect

_sf_slavery     property slavery        auto

Actor kTarget

event OnEffectStart(Actor akTarget, Actor akCaster)
	kTarget = akTarget
	RegisterForSingleUpdate(1.0)
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	slavery.SetLeashActive(kTarget, false)
endEvent

event OnUpdate()
	slavery.LeashTrigger(kTarget)
	RegisterForSingleUpdate(1.0)
endEvent
