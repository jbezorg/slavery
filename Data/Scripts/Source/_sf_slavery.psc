Scriptname _sf_slavery extends Quest Conditional

_sf_resources     property resources        auto

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
;  1.0    - success
;  0.0    - noop. For some reason nothing happened and something is really messed up.
; -1.[n]  - Invalid parameter where [n] is the parameter. None.
; -2.[n]  - Invalid parameter where [n] is the parameter. Dead or disabled.
; -3.[n]  - A property of parameter [n] makes the passed value invalid. e.g. max slaves reached.
; -4.[n]+ - Internal operation failed specific to the function. [n] is defined by the function.

bool makeSingleton  = false
bool syncSingleton  = false
bool relSingleton   = false
bool remSingleton   = false
bool leashSingleton = false

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
		error  = "max slaves exceeded for "+akMaster.GetLeveledActorBase().GetName()
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
		_sf_ActorSlot slot = GetActorInstance(akActor)
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
		_sf_ActorSlot slot = GetActorInstance(akActor)
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

float function leash(Actor[] akActors, string sHook = "")
	;while leashSingleton
	;	Utility.wait(0.1)
	;endWhile
	;leashSingleton = true

	float status = 0.0
	string error = "fail"
	int idx      = 0
	int len      = akActors.length

	if len < 2
		status = -4.0
		error  = "akActors must have at least 2 actors"
	else
		_sf_ActorSlot[] slots
		_sf_ActorSlot slot

		while idx < len
			slot = GetActorInstance(akActors[idx])
			if slot
				slots = _sf_utility.pushSlot(slot, slots)
			endIf
			idx += 1
		endWhile
		
		idx = slots.length
		while idx
			idx -= 1
			slots[idx].leashChain = slots
		endWhile

		status = 1.0
		error = slots+" successfully added "
	endIf

	resources.trace(error)
	SendModEvent("slavery.leash", error, status)
	if sHook != ""
		SendModEvent("slavery.leash."+sHook, error, status)
	endIf
	
	;leashSingleton  = false
	return status
endFunction

; END BASE FUNCTIONS ============================================================================--




; START TRAVERSE RELATION FUNCTIONS ===============================================================
Actor function GetMaster(Actor akSlave)
	if !akSlave
		resources.trace("slavery.GetMaster:: akSlave is none")
		return none
	else
		return GetActorInstance(akSlave).master.selfRef
	endIf
endFunction

Actor[] function GetAllMasters(Actor akSlave)
	actor[] kMasters
	if akSlave == none
		resources.trace("slavery.GetAllMasters:: akSlave is none")
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
		resources.trace("slavery.GetMaster:: akSlave is none")
		return none
	else
		return GetActorInstance(akSlave).master
	endIf
endFunction

_sf_ActorSlot[] function GetAllMasterScripts(Actor akSlave)
	_sf_ActorSlot[] kMasters
	if akSlave == none
		resources.trace("slavery.GetAllMasters:: akSlave is none")
	else
		kMasters = new _sf_ActorSlot[1]
		kMasters[0] = GetActorInstance(akSlave).master

		while kMasters[kMasters.length - 1].master && kMasters.length < 128
			kMasters = _sf_utility.pushSlot( kMasters[kMasters.length - 1].master, kMasters )
		endWhile
	endIf

	return kMasters
endFunction

Actor[] function GetSlaves(Actor akMaster)
	Actor[] slots
	if akMaster == none
		resources.trace("slavery.GetSlaves:: akMaster is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akMaster)
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
		resources.trace("slavery.GetSlaves:: akMaster is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akMaster)
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
		resources.trace("slavery.SetAgenda:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			slot.agenda = aiAgenda
		else
			resources.trace("slavery.SetAgenda:: cannot get slot for "+akActor)
		endIf
	endIf
endFunction

int function GetAgenda(Actor akActor)
	if !akActor
		resources.trace("slavery.GetAgenda:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			return slot.agenda
		else
			resources.trace("slavery.GetAgenda:: cannot get slot for "+akActor)
		endIf
	endIf
	
	return -1
endFunction

function SetFocusTarget(Actor akActor, Actor akTarget)
	if !akActor
		resources.trace("slavery.SetFocusTarget:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			slot.focusTarget = akTarget
		else
			resources.trace("slavery.SetFocusTarget:: cannot get slot for "+akActor)
		endIf
	endIf
endFunction

Actor function GetFocusTarget(Actor akActor)
	if !akActor
		resources.trace("slavery.GetFocusTarget:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			return slot.focusTarget
		else
			resources.trace("slavery.GetFocusTarget:: cannot get slot for "+akActor)
		endIf
	endIf

	return none
endFunction

bool function GetAIActive(Actor akActor)
	if !akActor
		resources.trace("slavery.GetAIActive:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			return slot.AIActive
		else
			resources.trace("slavery.GetAIActive:: cannot get slot for "+akActor)
		endIf
	endIf
	
	return false
endFunction

function SetAIActive(Actor akActor, bool abState)
	if !akActor
		resources.trace("slavery.SetAIActive:: akActor is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akActor)
		if slot
			slot.AIActive = abState
		else
			resources.trace("slavery.SetAIActive:: cannot get slot for "+akActor)
		endIf
	endIf
endFunction
; END AGENDA FUNCTIONS ============================================================================




; START SLAVE LEASH FUNCTIONS =====================================================================
Bool function LeashTrigger(Actor akSlave)
	if akSlave != none
		Bool bDist    = false
		Bool bActive  = false
		Actor kTarget = none
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		
		if slot && slot.leashIdx > 0
			kTarget = slot.leashChain[slot.leashIdx - 1].selfRef
			
			if slot.leashActive
				bDist = kTarget && kTarget.GetDistance(akSlave) > slot.leashLength * 0.75
			else
				bDist = kTarget && kTarget.GetDistance(akSlave) > slot.leashLength * 1.25
			endIf

			bActive  = bDist && (!slot.leashLOS || (slot.leashLOS && kTarget.HasLOS(akSlave)))

			slot.leashActive = bActive
			slot.AIActive    = bActive
			return bActive
		endIf
	else
		resources.trace("slavery.LeashTrigger:: akSlave is none")
	endIf

	return false
endFunction

bool function GetLeashActive(Actor akSlave)
	if !akSlave
		resources.trace("slavery.GetLeashActive:: akSlave is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashActive
		else
			resources.trace("slavery.GetLeashActive:: cannot get slot for "+akSlave)
		endIf
	endIf
	
	return false
endFunction

bool function GetLeashLOS(Actor akSlave)
	if !akSlave
		resources.trace("slavery.GetLeashLOS:: akSlave is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashLOS
		else
			resources.trace("slavery.GetLeashLOS:: cannot get slot for "+akSlave)
		endIf
	endIf
	
	return false
endFunction

function SetLeashLOS(Actor akSlave, Bool abState = true)
	if !akSlave
		resources.trace("slavery.SetLeashLOS:: akSlave is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashLOS = abState
		else
			resources.trace("slavery.SetLeashLOS:: cannot get slot for "+akSlave)
		endIf
	endIf
endFunction

float function GetLeashLength(Actor akSlave)
	if !akSlave
		resources.trace("slavery.GetLeashLength:: akSlave is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			return slot.leashLength
		else
			resources.trace("slavery.GetLeashLength:: cannot get slot for "+akSlave)
		endIf
	endIf

	return -1.0
endFunction

function SetLeashLength(Actor akSlave, float afVal = 256.0)
	if akSlave != none
		resources.trace("slavery.SetLeashLength:: akSlave is none")
	else
		_sf_ActorSlot slot = GetActorInstance(akSlave)
		if slot
			slot.leashLength = afVal
		else
			resources.trace("slavery.SetLeashLength:: cannot get slot for "+akSlave)
		endIf
	endIf
endFunction
; END SLAVE LEASH FUNCTIONS =======================================================================



; START MASTER FUNCTIONS ==========================================================================
function transfer(Actor akOldMaster, Actor akNewMaster)
	_sf_ActorSlot slotOld = GetActorInstance(akOldMaster)
	_sf_ActorSlot slotNew = GetActorInstance(akNewMaster)

endFunction
; END MASTER FUNCTIONS ============================================================================



; START ALIAS FUNCTIONS ===========================================================================
_sf_ActorSlot function initActorInstance(Actor akActor)
	_sf_ActorSlot slot = none

	if !akActor
		resources.trace("slavery.initActorInstance:: akActor is none")
	else
		slot = GetActorInstance(akActor)

		if slot == none
			slot = SetActorInstance(akActor)
		endIf
	endIf

	resources.trace("slavery.initActorInstance::return:"+slot)
	return slot
endFunction

_sf_ActorSlot function SetActorInstance(Actor akActor)
	int idx  = self.GetNumAliases()
	bool found = false
	_sf_ActorSlot nthAlias = none
	

	resources.trace("slavery.SetActorInstance::"+akActor+" out of "+idx)
	while idx > 0 && !found
		idx -= 1
		nthAlias = self.GetNthAlias(idx) as _sf_ActorSlot

		if !nthAlias.locked && !nthAlias.SelfRef
			found = true
			nthAlias.initSlot(akActor, idx)
		endIf
	endWhile

	return nthAlias
endFunction

_sf_ActorSlot function GetActorInstance(Actor akActor)
	if !akActor
		return none
	endIf

	int idx = GetAliasID(akActor)

	if idx >= 0 && GetNumAliases() > idx
		_sf_ActorSlot slot = GetNthAlias(idx) as _sf_ActorSlot
		if slot.selfRef == akActor
			return slot
		endIf
	endIf

	return none
endFunction

function ClearActorInstance(Actor akActor)
	_sf_ActorSlot slot = GetActorInstance(akActor)
	if slot
		slot.emptySlot()
	endIf
endFunction
; END ALIAS FUNCTIONS =============================================================================


int function GetAliasID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_alias_mult_fact) * 127
	int modu = akActor.GetFactionRank(resources._sf_alias_modu_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		return mult + modu
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

