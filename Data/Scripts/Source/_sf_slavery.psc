Scriptname _sf_slavery extends Quest Conditional

_sf_resources     property resources        auto

bool              property zbfLoaded        auto Conditional
bool              property SLLoaded         auto Conditional
bool              property SLArousedLoaded  auto Conditional
bool              property verbose          auto Conditional

int               property iPlayerAI    = 0     auto
bool              property bAISingleton = false auto
bool              property bMovement    = false auto
bool              property bFighting    = false auto
bool              property bCamera      = false auto
bool              property bLooking     = false auto
bool              property bSneaking    = false auto
bool              property bMenu        = false auto
bool              property bActivate    = false auto
bool              property bJournal     = false auto

int               property iCameraState = 0     auto


int               property ESCORT = 1 autoreadonly
int               property LEAD   = 2 autoreadonly



; ERROR CODES =====================================================================================
;
;  1.0   - success
;  0.0   - noop. For some reason nothing happened and something is really messed up.
; -1.[n] - Invalid parameter where [n] is the parameter. None
; -2.[n] - Invalid parameter where [n] is the parameter. Dead or disabled
; -3.[n] - A property of parameter [n] makes the passed value invalid. e.g. max slaves reached
; -3.0   - Internal operation failed specific to the function

bool makeSingleton = false
bool syncSingleton = false
bool relSingleton  = false
bool remSingleton  = false

; START BASE FUNCTIONS ============================================================================
float function make(Actor akSlave, Actor akMaster, string asHook = "")
	;while makeSingleton
	;	Utility.wait(0.1)
	;endWhile
	;makeSingleton = true
	
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
	
	;makeSingleton = false
	return status
endFunction

float function sync(_sf_ActorSlot akSlave, _sf_ActorSlot akMaster, string asHook = "")
	;while syncSingleton
	;	Utility.wait(0.1)
	;endWhile
	;syncSingleton = true

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
	
	;syncSingleton = false
	return status
endFunction

float function releaseSlaves(Actor akActor, string sHook = "")
	;while relSingleton
	;	Utility.wait(0.1)
	;endWhile
	;relSingleton = true

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

	;relSingleton  = false
	return status
endFunction

float function remove(Actor akActor, string sHook = "")
	;while remSingleton
	;	Utility.wait(0.1)
	;endWhile
	;remSingleton = true

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
	
	;remSingleton  = false
	return status
endFunction
; END BASE FUNCTIONS ============================================================================--




; START TRAVERSE RELATION FUNCTIONS ===============================================================
Actor function GetMaster(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetMaster:: akSlave is none", resources.verbose)
		return none
	else
		return GetActorScript(akSlave).master.selfRef
	endIf
endFunction

Actor[] function GetAllMasters(Actor akSlave)
	actor[] kMasters
	if akSlave == none
		Debug.TraceConditional("slavery.GetAllMasters:: akSlave is none", resources.verbose)
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
		Debug.TraceConditional("slavery.GetMaster:: akSlave is none", resources.verbose)
		return none
	else
		return GetActorScript(akSlave).master
	endIf
endFunction

_sf_ActorSlot[] function GetAllMasterScripts(Actor akSlave)
	_sf_ActorSlot[] kMasters
	if akSlave == none
		Debug.TraceConditional("slavery.GetAllMasters:: akSlave is none", resources.verbose)
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
		Debug.TraceConditional("slavery.GetSlaves:: akMaster is none", resources.verbose)
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
		Debug.TraceConditional("slavery.GetSlaves:: akMaster is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorScript(akMaster)
		if slot
			slaves = slot.slaves
		endIf
	endIf

	return slaves
endFunction
; END TRAVERSE RELATION FUNCTIONS =================================================================




; START AGENDA FUNCTIONS ==========================================================================
function SetAgenda(Actor akActor, Int aiAgenda = 0)
	if !akActor
		Debug.TraceConditional("slavery.SetAgenda:: akActor is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			slot.agenda = aiAgenda
		else
			Debug.TraceConditional("slavery.SetAgenda:: cannot get slot for "+akActor, resources.verbose)
		endIf
	endIf
endFunction

int function GetAgenda(Actor akActor)
	if !akActor
		Debug.TraceConditional("slavery.GetAgenda:: akActor is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			return slot.agenda
		else
			Debug.TraceConditional("slavery.GetAgenda:: cannot get slot for "+akActor, resources.verbose)
		endIf
	endIf
	
	return -1
endFunction

function SetFocusTarget(Actor akActor, Actor akTarget)
	if !akActor
		Debug.TraceConditional("slavery.SetFocusTarget:: akActor is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			slot.focusTarget = akTarget
		else
			Debug.TraceConditional("slavery.SetFocusTarget:: cannot get slot for "+akActor, resources.verbose)
		endIf
	endIf
endFunction

Actor function GetFocusTarget(Actor akActor)
	if !akActor
		Debug.TraceConditional("slavery.GetFocusTarget:: akActor is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			return slot.focusTarget
		else
			Debug.TraceConditional("slavery.GetFocusTarget:: cannot get slot for "+akActor, resources.verbose)
		endIf
	endIf

	return none
endFunction
; END AGENDA FUNCTIONS ============================================================================




; START SLAVE LEASH FUNCTIONS =====================================================================
Bool function LeashTrigger(Actor akSlave)
	if akSlave != none
		Actor kTarget = GetLeashTarget(akSlave)
		Float fLeash  = GetLeashLength(akSlave)
		Bool bEnabled = GetLeashEnabled(akSlave)
		Bool bLOSReq  = GetLeashLOS(akSlave)

		Bool bDist    = bEnabled && kTarget && kTarget.GetDistance(akSlave) > fLeash
		Bool bActive  = bDist && (!bLOSReq || (bLOSReq && kTarget.HasLOS(akSlave)))

		Debug.TraceConditional("slavery.LeashTrigger:: "+kTarget+" "+fLeash+" "+bEnabled+" "+bLOSReq+" "+bDist+" "+bActive, resources.verbose)
		return bActive
	else
		Debug.TraceConditional("slavery.LeashTrigger:: akSlave is none", resources.verbose)
		return false
	endIf
endFunction

function SetLeashEnabled(Actor akSlave, Bool abState = true)
	if !akSlave
		Debug.TraceConditional("slavery.SetLeashEnabled:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashEnabled = abState
		else
			Debug.TraceConditional("slavery.SetLeashEnabled:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
endFunction

bool function GetLeashEnabled(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashEnabled:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashEnabled
		else
			Debug.TraceConditional("slavery.GetLeashEnabled:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
	
	return false
endFunction

function SetLeashTarget(Actor akSlave, Actor akTarget)
	if !akSlave
		Debug.TraceConditional("slavery.SetLeashTarget:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashTarget = akTarget
		else
			Debug.TraceConditional("slavery.SetLeashTarget:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
endFunction

Actor function GetLeashTarget(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashTarget:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashTarget
		else
			Debug.TraceConditional("slavery.GetLeashTarget:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf

	return none
endFunction

bool function GetLeashLOS(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashLOS:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashLOS
		else
			Debug.TraceConditional("slavery.GetLeashLOS:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
	
	return false
endFunction

function SetLeashLOS(Actor akSlave, Bool abState = true)
	if !akSlave
		Debug.TraceConditional("slavery.SetLeashLOS:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashLOS = abState
		else
			Debug.TraceConditional("slavery.SetLeashLOS:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
endFunction

float function GetLeashLength(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetLeashLength:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashLength
		else
			Debug.TraceConditional("slavery.GetLeashLength:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf

	return -1.0
endFunction

function SetLeashLength(Actor akSlave, float afVal = 256.0)
	if akSlave != none
		Debug.TraceConditional("slavery.SetLeashLength:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashLength = afVal
		else
			Debug.TraceConditional("slavery.SetLeashLength:: cannot get slot for "+akSlave, resources.verbose)
		endIf
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
		Debug.TraceConditional("slavery.initActorInstance:: akActor is none", resources.verbose)
	else
		slot = GetActorInstance(akActor)

		if slot == none
			slot = SetActorInstance(akActor)
		endIf
	endIf

	Debug.TraceConditional("slavery.initActorInstance::return:" + slot, resources.verbose)
	return slot
endFunction

_sf_ActorSlot function SetActorInstance(Actor akActor)
	int idx  = self.GetNumAliases()
	bool found = false
	_sf_ActorSlot nthAlias = none
	

	Debug.TraceConditional("slavery.SetActorInstance::"+akActor+" out of "+idx, resources.verbose)
	while idx > 0 && !found
		idx -= 1
		nthAlias = self.GetNthAlias(idx) as _sf_ActorSlot

		if !nthAlias.SelfRef
			found = true

			Debug.TraceConditional("slavery.SetActorInstance::"+akActor+" at "+idx, resources.verbose)
			
			SetAliasID(akActor, idx)
			
			nthAlias.index     = idx
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
	;Debug.TraceConditional("slavery.GetActorInstance::"+akActor+" at "+idx, resources.verbose)

	if idx >= 0
		return self.GetNthAlias(idx) as _sf_ActorSlot
	else
		return none
	endIf
endFunction
; END ALIAS FUNCTIONS =============================================================================


function SetAIActive(Actor akSlave, Bool abState = true)
	if !akSlave
		Debug.TraceConditional("slavery.SetAIActive:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.AIActive = abState
		else
			Debug.TraceConditional("slavery.SetAIActive:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
endFunction

bool function GetAIActive(Actor akSlave)
	if !akSlave
		Debug.TraceConditional("slavery.GetAIActive:: akSlave is none", resources.verbose)
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.AIActive
		else
			Debug.TraceConditional("slavery.GetAIActive:: cannot get slot for "+akSlave, resources.verbose)
		endIf
	endIf
	
	return false
endFunction

function SetAliasID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127
		int sign = 1

		if aiVal < 0
			sign = -1
		endIf

		akActor.SetFactionRank(resources._sf_alias_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_alias_modu_fact, modu)
		akActor.SetFactionRank(resources._sf_alias_sign_fact, sign)
		;Debug.TraceConditional("slavery.SetAliasID:: "+abso+" -> "+mult+" "+modu+" "+sign, resources.verbose)
	else
		Debug.TraceConditional("slavery.SetAliasID:: absolute value cannot exceed 16256", resources.verbose)
	endIf
endFunction

int function GetAliasID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_alias_mult_fact) * 127
	int modu = akActor.GetFactionRank(resources._sf_alias_modu_fact)
	int sign = akActor.GetFactionRank(resources._sf_alias_sign_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		;Debug.TraceConditional("slavery.GetAliasID:: "+mult+" "+modu+" "+sign, resources.verbose)
		return (mult + modu) * sign
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
		slot = self.GetNthAlias(idx) as _sf_ActorSlot
	endIf

	if slot && slot.selfRef == akActor
		return slot
	else
		return none
	endIf
endFunction

event OnInit()
	RegisterForCameraState()
endEvent

; 0 - first person
; 1 - auto vanity
; 2 - VATS
; 3 - free
; 4 - iron sights
; 5 - furniture
; 6 - transition
; 7 - tweenmenu
; 8 - third person 1
; 9 - third person 2
; 10 - horse
; 11 - bleedout
; 12 - dragon
event OnPlayerCameraState(int oldState, int newState)
	iCameraState = newState
endEvent

