Scriptname _sf_slavery extends Quest Conditional

bool              property zbfLoaded        auto Conditional
bool              property SLLoaded         auto Conditional
bool              property SLArousedLoaded  auto Conditional
bool              property verbose          auto Conditional
_sf_resources     property resources        auto

; ERROR CODES =====================================================================================
;
;  1.0   - success
;  0.0   - noop. For some reason nothing happened and something is really messed up.
; -1.[n] - Invalid parameter where [n] is the parameter. None
; -2.[n] - Invalid parameter where [n] is the parameter. Dead or disabled
; -3.[n] - A property of parameter [n] makes the passed value invalid. e.g. max slaves reached
; -3.0   - Internal operation failed specific to the function


; START BASE FUNCTIONS ============================================================================
float function make(Actor akSlave, Actor akMaster, string asHook = "")
	_sf_ActorSlot kMaster = none
	_sf_ActorSlot kSlave  = none

	float status = 0.0
	string error = "fail"

	if !akSlave
		status = -1.1
		error  = "akSlave is none"
	elseIf !akMaster
		status = -1.2
		error  = "akMaster is none"
	elseIf akSlave.IsDead() || akSlave.IsDisabled()
		status = -2.1
		error  = "akSlave is dead or disabled"
	elseIf akMaster.IsDead() || akMaster.IsDisabled()
		status = -2.2
		error  = "akMaster is dead or disabled"
	elseIf GetSlaveScripts(akMaster).length >= 128
		status = -3.2
		error  = "max slaves exceeded for " + akMaster.GetLeveledActorBase().GetName()
	else
		while !Game.GetPlayer().Is3DLoaded()
			Utility.Wait(0.1)
		endWhile

		kMaster = initActorInstance(akMaster) as _sf_ActorSlot
		kSlave  = initActorInstance(akSlave) as _sf_ActorSlot
		
		sync(kSlave, kMaster, asHook)

		status = 1.0
		error  = "success"
	endIf

	self.SendModEvent("slavery.make", error, status)
	if asHook != ""
		self.SendModEvent("slavery.make."+asHook, error, status)
	endIf
	
	return status
endFunction

float function sync(_sf_ActorSlot akSlave, _sf_ActorSlot akMaster, string asHook = "")
	float status = 0.0
	string error = "fail"

	if !akSlave
		status = -1.1
		error  = "akSlave is none"
	elseIf !akMaster
		status = -1.2
		error  = "akMaster is none"
	else
		akSlave.master  = akMaster
		akSlave.status  = 0
		akMaster.slaves = _sf_utility.pushSlot(akSlave, akMaster.slaves)
		status = 1.0
		error  = "success"
	endIf

	self.SendModEvent("slavery.sync", error, status)
	if asHook != ""
		self.SendModEvent("slavery.sync."+asHook, error, status)
	endIf
	
	return status
endFunction

float function releaseSlaves(Actor akActor, string sHook = "")
	float status = 0.0
	string error = "fail"

	if akActor == none
		status = -1.1
		error  = "akActor is none"
	elseIf akActor.IsDead() || akActor.IsDisabled()
		status = -2.1
		error  = "akActor is dead or disabled"
	else
		_sf_ActorSlot slot = GetActorScript(akActor)
		if slot
			status = 1.0
			error  = "success"

			slot.slaves = _sf_utility.nullSlotArray()
		else
			status = -2.1
			error  = "could not obtain the actor's alias script"
		endIf
	endIf

	SendModEvent("slavery.releaseSlaves", error, status)
	if sHook != ""
		SendModEvent("slavery.releaseSlaves."+sHook, error, status)
	endIf
	
	return status
endFunction

float function remove(Actor akActor, string sHook = "")
	float status = 0.0
	string error = "fail"

	if akActor == none
		status = -1.1
		error  = "akActor is none"
	elseIf akActor.IsDead() || akActor.IsDisabled()
		status = -2.1
		error  = "akActor is dead or disabled"
	else
		_sf_ActorSlot slot = GetActorScript(akActor)
		if slot
			status = 1.0
			error  = "success"

			slot.selfRef = none
		else
			status = -2.1
			error  = "could not obtain the actor's alias script"
		endIf
	endIf

	SendModEvent("slavery.remove", error, status)
	if sHook != ""
		SendModEvent("slavery.remove."+sHook, error, status)
	endIf
	
	return status
endFunction
; END BASE FUNCTIONS ============================================================================--




; START TRAVERSE RELATION FUNCTIONS ===============================================================
Actor function GetMaster(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetMaster:: akSlave is none", verbose)
		return none
	else
		return GetActorScript(akSlave).master.selfRef
	endIf
endFunction

Actor[] function GetAllMasters(Actor akSlave)
	actor[] kMasters
	if akSlave == none
		Debug.TraceConditional("slavery.GetAllMasters:: akSlave is none", verbose)
		return none
	else
		kMasters = new actor[1]
		kMasters[0] = GetMaster(akSlave)

		while GetMaster(kMasters[kMasters.length - 1]) && kMasters.length < 128
			kMasters = _sf_utility.PushActor(GetMaster(kMasters[kMasters.length - 1]), kMasters)
		endWhile
	endIf

	return kMasters
endFunction

_sf_ActorSlot function GetMasterScript(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetMaster:: akSlave is none", verbose)
		return none
	else
		return GetActorScript(akSlave).master
	endIf
endFunction

_sf_ActorSlot[] function GetAllMasterScripts(Actor akSlave)
	_sf_ActorSlot[] kMasters
	if akSlave == none
		Debug.TraceConditional("slavery.GetAllMasters:: akSlave is none", verbose)
	else
		kMasters = new _sf_ActorSlot[1]
		kMasters[0] = GetActorScript(akSlave).master

		while kMasters[kMasters.length - 1].master && kMasters.length < 128
			kMasters = _sf_utility.pushSlot( kMasters[kMasters.length - 1].master, kMasters )
		endWhile
	endIf

	return kMasters
endFunction

Actor[] function GetSlaves(Actor akMaster)
	Actor[] slots
	if akMaster == none
		Debug.TraceConditional("slavery.GetSlaves:: akMaster is none", verbose)
	else
		_sf_ActorSlot slot = GetActorScript(akMaster)
		if slot != none
			int idx = slot.slaves.length
			slots = _sf_utility.actorArray(idx)

			while idx > 0
				idx -= 1
				slots[idx] = slot.slaves[idx].selfRef
			endWhile
		endIf
	endIf

	return slots
endFunction

_sf_ActorSlot[] function GetSlaveScripts(Actor akMaster)
	_sf_ActorSlot[] slaves
	if akMaster == none
		Debug.TraceConditional("slavery.GetSlaves:: akMaster is none", verbose)
	else
		_sf_ActorSlot slot = GetActorScript(akMaster)
		if slot
			slaves = slot.slaves
		endIf
	endIf

	return slaves
endFunction
; END TRAVERSE RELATION FUNCTIONS =================================================================



; START SLAVE LEASH FUNCTIONS =====================================================================
Bool function LeashTrigger(Actor akSlave)
	if akSlave != none
		Actor kMaster = GetMaster(akSlave)
		Float fLeash  = GetLeashLength(akSlave)
		Bool bEnabled = GetLeashEnabled(akSlave)
		Bool bLOSReq  = GetLeashLOS(akSlave)

		Bool bDist    = bEnabled && kMaster.GetDistance(akSlave) > fLeash
		Bool bActive  = bDist && (!bLOSReq || (bLOSReq && kMaster.HasLOS(akSlave)))

		SetLeashActive(akSlave, bActive)
		return bActive
	else
		Debug.TraceConditional("slavery.LeashTest:: akSlave is none", verbose)
		return none
	endIf
endFunction

bool function GetLeashEnabled(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashEnabled:: akSlave is none", verbose)
	else
		return GetActorInstance(akSlave).leashEnabled
	endIf
endFunction

function SetLeashTarget(Actor akSlave, Actor akTarget)
	if akSlave == none
		Debug.TraceConditional("slavery.SetLeashTarget:: akSlave is none", verbose)
	else
		GetActorInstance(akSlave).leashTarget = akTarget
	endIf
endFunction

function SetLeashEnabled(Actor akSlave, Bool abState = true)
	if akSlave != none
		GetActorInstance(akSlave).leashEnabled = abState
	else
		Debug.TraceConditional("slavery.SetLeashEnabled:: akSlave is none", verbose)
	endIf
endFunction

function SetLeashActive(Actor akSlave, Bool abState = true)
	if akSlave != none
		GetActorInstance(akSlave).leashActive = abState
	else
		Debug.TraceConditional("slavery.SetLeashActive:: akSlave is none", verbose)
	endIf
endFunction

bool function GetLeashLOS(Actor akSlave)
	if akSlave != none
		return GetActorInstance(akSlave).leashLOS
	else
		Debug.TraceConditional("slavery.GetLeashLOS:: akSlave is none", verbose)
	endIf
endFunction

function SetLeashLOS(Actor akSlave, Bool abState = true)
	if akSlave != none
		GetActorInstance(akSlave).leashLOS = abState
	else
		Debug.TraceConditional("slavery.SetLeashLOS:: akSlave is none", verbose)
	endIf
endFunction

float function GetLeashLength(Actor akSlave)
	if akSlave != none
		return GetActorInstance(akSlave).leashLength
	else
		Debug.TraceConditional("slavery.GetLeashLength:: akSlave is none", verbose)
	endIf
endFunction

function SetLeashLength(Actor akSlave, float afVal = 256.0)
	if akSlave != none
		GetActorInstance(akSlave).leashLength = afVal
	else
		Debug.TraceConditional("slavery.SetLeashLength:: akSlave is none", verbose)
	endIf
endFunction
; END SLAVE LEASH FUNCTIONS =======================================================================



; START MASTER FUNCTIONS ==========================================================================
function transfer(Actor akOldMaster, Actor akNewMaster)
	_sf_ActorSlot slotOld = GetActorScript(akOldMaster)
	_sf_ActorSlot slotNew = GetActorScript(akNewMaster)

endFunction
; END MASTER FUNCTIONS ============================================================================



; START ALIAS FUNCTIONS ===========================================================================
_sf_ActorSlot function initActorInstance(Actor akActor)
	_sf_ActorSlot slot = none

	if !akActor
		Debug.TraceConditional("slavery.initActorInstance:: akActor is none", verbose)
	else
		slot = GetActorInstance(akActor)

		if slot == none
			slot = SetActorInstance(akActor)
		endIf
	endIf

	Debug.TraceConditional("slavery.initActorInstance::return:" + slot, verbose)
	return slot
endFunction

_sf_ActorSlot function SetActorInstance(Actor akActor)
	int idx  = self.GetNumAliases()
	bool found = false
	_sf_ActorSlot nthAlias = none
	

	Debug.TraceConditional("slavery.SetActorInstance::"+akActor+" out of "+idx, verbose)
	while idx > 0 && !found
		idx -= 1
		nthAlias = self.GetNthAlias(idx) as _sf_ActorSlot

		if !nthAlias.SelfRef
			found = true

			Debug.TraceConditional("slavery.SetActorInstance::"+akActor+" at "+idx, verbose)

			nthAlias.slavery   = self as _sf_slavery
			nthAlias.resources = resources
			nthAlias.SelfRef   = akActor
		endIf
	endWhile

	return nthAlias
endFunction

_sf_ActorSlot function GetActorInstance(Actor akActor)
	if !akActor
		return none
	endIf

	int idx = GetAliasID(akActor)
	Debug.TraceConditional("slavery.GetActorInstance::"+akActor+" at "+idx, verbose)

	if idx > 0
		return self.GetAlias(idx) as _sf_ActorSlot
	else
		return none
	endIf
endFunction
; END ALIAS FUNCTIONS =============================================================================



int function GetAliasID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_alias_mult_fact)
	int modu = akActor.GetFactionRank(resources._sf_alias_modu_fact)
	int sign = akActor.GetFactionRank(resources._sf_alias_sign_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		return (mult * 127 + modu) * sign
	endIf
endFunction

function ClearActorInstance(Actor akActor)
	_sf_ActorSlot slot = GetActorScript(akActor)
	if slot
		slot.emptySlot()
	endIf
endFunction

_sf_ActorSlot function GetActorScript(Actor akActor)
	if !akActor
		return none
	endIf

	_sf_ActorSlot slot = none
	int idx = GetAliasID(akActor)
	if idx > 0
		slot = self.GetAlias(idx) as _sf_ActorSlot
	endIf

	if slot && slot.selfRef == akActor
		return slot
	else
		return none
	endIf
endFunction

function aiRetention(Actor akActor, Bool abState = true)
	if akActor == Game.GetPlayer()
		if zbfLoaded
			if abState
				zbfUtil.GetMain().RetainAi()
			else
				zbfUtil.GetMain().ReleaseAi()
			endIf
		else
			Game.SetPlayerAiDriven(abState)
		endIf
	endIf
endFunction

