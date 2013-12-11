Scriptname _sf_slavery extends Quest Conditional

bool              property zbfLoaded      auto
bool              property verbose        auto
_sf_resources     property resources      auto

; ERROR CODES =====================================================================================
;
;  1.0   - success
;  0.0   - noop. For some reason nothing happened and something is really messed up.
; -1.[n] - Invalid parameter where [n] is the parameter. None
; -2.[n] - Invalid parameter where [n] is the parameter. Dead or disabled
; -3.[n] - A property of parameter [n] makes the passed value invalid. e.g. max slaves reached
; -3.0   - Internal operation failed


; BASE FUNCTIONS ==================================================================================
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

			slot.slaves = none
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

	SendModEvent("slavery.quit", error, status)
	if sHook != ""
		SendModEvent("slavery.releaseSlaves."+sHook, error, status)
	endIf
	
	return status
endFunction


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



; SLAVE LEASH FUNCTIONS ===========================================================================
function LeashEnabled(Actor akSlave, Bool abState = true)
	if akSlave != none
		akSlave.SetAnimationVariableInt("sfLeashEnabled", abState as Int)
	else
		Debug.TraceConditional("slavery.LeashEnabled:: akSlave is none", verbose)
	endIf
endFunction

function SetLeashLength(Actor akSlave, Float afLength = 256.0)
	if akSlave != none
		akSlave.SetAnimationVariableFloat("sfLeashLength", afLength)
	else
		Debug.TraceConditional("slavery.SetLeashLength:: akSlave is none", verbose)
	endIf
endFunction

float function GetLeashLength(Actor akSlave)
	if akSlave != none
		return akSlave.GetAnimationVariableFloat("sfLeashLength")
	else
		Debug.TraceConditional("slavery.GetLeashLength:: akSlave is none", verbose)
		return -1.0
	endIf
endFunction

function SetLeashLOS(Actor akSlave, Bool abState = true)
	if akSlave != none
		akSlave.SetAnimationVariableInt("sfLeashLOSReq", abState as Int)
	else
		Debug.TraceConditional("slavery.SetLeashLOS:: akSlave is none", verbose)
	endIf
endFunction

bool function GetLeashLOS(Actor akSlave)
	if akSlave != none
		return akSlave.GetAnimationVariableInt("sfLeashLOSReq") as bool
	else
		Debug.TraceConditional("slavery.GetLeashLOS:: akSlave is none", verbose)
	endIf
endFunction


; LEASH UTILITY FUNCTIONS =========================================================================
Bool function LeashTrigger(Actor akSlave)
	if akSlave != none
		Actor kMaster = GetMaster(akSlave)
		Float fLeash  = GetLeashLength(akSlave)
		Bool bEnabled = GetLeashActive(akSlave)
		Bool bLOSReq  = GetLeashLOS(akSlave)

		Bool bDist    = bEnabled && kMaster.GetDistance(akSlave) > fLeash
		Bool bActive  = bDist && (!bLOSReq || (bLOSReq && kMaster.HasLOS(akSlave)))

		SetLeashActive(akSlave, bActive)

		if bActive
			Float fHalf  = fLeash/2
			Float fPX    = -fHalf * Math.Sin(kMaster.GetAngleZ())
			Float fPY    = -fHalf * Math.Cos(kMaster.GetAngleZ())
			Float fPZ    = 0.0
			Float fAX    = 0.0
			Float fAY    = 0.0
			Float fAZ    = akSlave.GetAngleZ() - akSlave.GetHeadingAngle(kMaster)

			akSlave.KeepOffsetFromActor(kMaster, fPX, fPY, fPZ, fAX, fAY, fAZ, fHalf, fLeash)
		else
			akSlave.ClearKeepOffsetFromActor()
		endIf

		return bActive
	else
		Debug.TraceConditional("slavery.LeashTest:: akSlave is none", verbose)
		return none
	endIf
endFunction

function SetLeashActive(Actor akSlave, Bool abState = true)
	if !akSlave
		Debug.TraceConditional("slavery.SetLeashActive:: akSlave is none", verbose)
	elseIf !akSlave.Is3DLoaded()
		Debug.TraceConditional("slavery.SetLeashActive:: akSlave 3D not loaded", verbose)
	else
		aiRetention(akSlave, abState)
		akSlave.SetAnimationVariableInt("sfLeashActive", abState as Int)
	endIf
endFunction

bool function GetLeashActive(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashActive:: akSlave is none", verbose)
	elseIf !akSlave.Is3DLoaded()
		Debug.TraceConditional("slavery.GetLeashActive:: akSlave 3D not loaded", verbose)
	else
		return akSlave.GetAnimationVariableInt("sfLeashActive") as bool
	endIf
endFunction




; MASTER FUNCTIONS ================================================================================
function SetXferOnQuit(Actor akMaster, Bool abTransfer = true)
	_sf_ActorSlot slot = GetActorScript(akMaster)
	if slot
		slot.xferOnQuit = abTransfer
	endIf
endFunction

function SetInheritOrderOnQuit(Actor akMaster, Bool abTopDown = true)
	_sf_ActorSlot slot = GetActorScript(akMaster)
	if slot
		slot.inheritOrder = abTopDown
	endIf
endFunction



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

; +/- 16256
int function GetAliasID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_mult_fact)
	int modu = akActor.GetFactionRank(resources._sf_modu_fact)
	int sign = akActor.GetFactionRank(resources._sf_sign_fact)

	if mult < 0 || modu < 0
		return -2147483648
	else
		return (mult * 127 + modu) * sign
	endIf
endFunction

; +/- 16256
function SetAliasID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	int mult = abso / 127 ;int division is floored
	int modu = abso % 127
	int sign = 1

	if aiVal < 0
		sign = -1
	endIf

	akActor.SetFactionRank(resources._sf_mult_fact, mult)
	akActor.SetFactionRank(resources._sf_modu_fact, modu)
	akActor.SetFactionRank(resources._sf_sign_fact, sign)
endFunction

function ClearAliasID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_mult_fact)
	akActor.RemoveFromFaction(resources._sf_modu_fact)
	akActor.RemoveFromFaction(resources._sf_sign_fact)
endFunction
; END ALIAS FUNCTIONS =============================================================================

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

