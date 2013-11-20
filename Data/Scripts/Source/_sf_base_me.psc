Scriptname _sf_base_me extends activemagiceffect

ReferenceAlias  property aliasRef       auto hidden

_sf_resources   property resources      auto hidden
_sf_ActorSlot   property actorSlot      auto hidden

function ThisEffectStart(Actor akTarget, Actor akCaster)
endFunction

event OnEffectStart(Actor akTarget, Actor akCaster)
	resources = slavery.GetInstance() as _sf_resources
	aliasRef  = slavery.GetActorInstance(akTarget)
	actorSlot = aliasRef as _sf_ActorSlot

	if self.GetBaseObject() == resources._sf_slave_base_me
		actorSlot.slaveAbility = self
	endIf
	if self.GetBaseObject() == resources._sf_master_base_me
		actorSlot.masterAbility = self
	endIf
	
	ThisEffectStart(akTarget, akCaster)
endEvent


event OnEffectFinish(Actor akTarget, Actor akCaster)

	if self.GetBaseObject() == resources._sf_slave_base_me
		if !akTarget.HasSpell(resources._sf_master_spell)

		endIf
	endIf

	if self.GetBaseObject() == resources._sf_master_base_me
		if !akTarget.HasSpell(resources._sf_slave_spell)
			
		endIf
	endIf
endEvent
