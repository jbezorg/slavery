Scriptname _sf_base_mes extends activemagiceffect

_sf_ActorSlot   property actorSlot      auto hidden

_sf_resources   property resources      auto
_sf_slavery     property slavery        auto

Faction         property master         auto
Faction         property slave          auto

event OnEffectStart(Actor akTarget, Actor akCaster)
	actorSlot = slavery.GetActorInstance(akTarget)

	if self.GetBaseObject() == resources._sf_slave_base_me

	endIf
	if self.GetBaseObject() == resources._sf_master_base_me
		actorSlot.masterAbility = self
		akTarget.AddToFaction(master)
	endIf
endEvent

event OnEffectFinish(Actor akTarget, Actor akCaster)
	if self.GetBaseObject() == resources._sf_slave_base_me

	endIf

	if self.GetBaseObject() == resources._sf_master_base_me
		akTarget.RemoveFromFaction(master)
	endIf
endEvent
