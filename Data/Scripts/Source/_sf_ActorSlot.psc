Scriptname _sf_ActorSlot extends ReferenceAlias

ActiveMagicEffect property slaveAbility          auto hidden
ActiveMagicEffect property masterAbility         auto hidden

_sf_slavery       property slavery               auto hidden
_sf_resources     property resources             auto hidden

Bool              property locked = false        auto hidden
Bool              property leashLOS = false      auto hidden
Bool              property leashFirst = false    auto hidden
Bool              property focusFirst = false    auto hidden
Bool              property isPlayer = false      auto hidden

Form[]            property joinedFactions        auto hidden
Int               property status                auto hidden


bool property packagesOn
	bool function get()
		return resources._sf_packages_enabled.GetValueInt() == 1
	endFunction
endProperty


int clearProperties = 7

; START FULL PROPERTIES ===========================================================================
;##################################################################################################
; PROPERTY MASTER =================================================================================
; 0x00000001 ======================================================================================

_sf_ActorSlot kMaster = none
_sf_ActorSlot property master hidden
	function Set(_sf_ActorSlot akMaster)
		if !locked
			Bool hasSlaveSpell = selfRef.HasSpell(resources._sf_slave_spell)
			Bool hasNewMaster  = akMaster != none
			Bool hasOldMaster  = kMaster != none
			bool hasSlaves     = slaves.length > 0

			if hasNewMaster && !hasOldMaster
				kMaster = addMaster(akMaster)
				unsetClearBit(0x00000001)
			elseIf hasNewMaster && hasOldMaster
				kMaster = removeMaster(true)
				setClearBit(0x00000001)
				kMaster = addMaster(akMaster, true)
				unsetClearBit(0x00000001)
			elseIf !hasNewMaster && hasOldMaster
				kMaster = removeMaster()
				setClearBit(0x00000001)
			else
				setClearBit(0x00000001)
			endIf
			
			if mySlaves.length == 0 && kMaster == none
				emptySlot()
			endIf			
		endIf
	endFunction
	_sf_ActorSlot function Get()
		return kMaster
	endFunction
endProperty

_sf_ActorSlot function addMaster(_sf_ActorSlot akSlot, bool abTransfer = false)
	if !abTransfer && !selfRef.HasSpell( resources._sf_slave_spell )
		selfRef.AddSpell( resources._sf_slave_spell )
	endIf

	int idx = resources._sf_faction_list.GetSize()
	while idx > 0
		idx -= 1
		form nthFaction = resources._sf_faction_list.GetAt(idx)
		if akSlot.selfRef.IsInFaction(nthFaction as faction) && !selfRef.IsInFaction(nthFaction as faction)
			selfRef.AddToFaction(nthFaction as faction)
			joinedFactions = _sf_utility.PushForm(nthFaction, joinedFactions)
		endIf
	endWhile
	return akSlot
endFunction

_sf_ActorSlot function removeMaster(bool abTransfer = false)
	if !abTransfer && selfRef.HasSpell( resources._sf_slave_spell )
		selfRef.RemoveSpell( resources._sf_slave_spell )
	endIf

	int idx = joinedFactions.length
	while idx > 0
		idx -= 1
		selfRef.RemoveFromFaction(joinedFactions[idx] as faction)
	endWhile
	joinedFactions = _sf_utility.nullFormArray()
	return none
endFunction



;##################################################################################################
; PROPERTY SELFREF ================================================================================
; 0x00000002 ======================================================================================
int               property index = -1           auto hidden
actor             property selfRef              auto hidden

Bool myAIActive = false
Bool property AIActive hidden
	function Set(bool abActive)
		if !myAIActive && abActive
			EnableAI()
		elseIf myAIActive && !abActive
			DisableAI()
		endIf

		if myAIActive != abActive
			resources.trace(self+" AIActive "+abActive)
		endIf
		
		if packagesOn
			selfRef.EvaluatePackage()
		endIf

		myAIActive = abActive
	endFunction
	Bool function Get()
		return myAIActive
	endFunction
endProperty

function initSlot(Actor akActor, int aiVal)
	clearProperties = 0
	int abso = math.abs(aiVal) as int

	if !akActor
		resources.trace("slavery.initSlot:: akActor is none")
	elseIf abso > 16256
		resources.trace("slavery.initSlot:: absolute value cannot exceed 16256")
	else
		ForceRefTo(akActor)

		int mult = math.floor(abso / 127)
		int modu = abso % 127
		
		index    = aiVal
		SelfRef  = GetActorReference()
		isPlayer = SelfRef == Game.GetPlayer()

		selfRef.SetFactionRank(resources._sf_alias_mult_fact, mult)
		selfRef.SetFactionRank(resources._sf_alias_modu_fact, modu)

		resources.trace("slavery.initSlot::"+akActor.GetLeveledActorBase().GetName()+" at "+aiVal)
	endIf	
endFunction

function emptySlot()
	selfRef.RemoveFromFaction(resources._sf_alias_mult_fact)
	selfRef.RemoveFromFaction(resources._sf_alias_modu_fact)
	selfRef.RemoveFromFaction(resources._sf_alias_sign_fact)

	selfRef.RemoveFromFaction(resources._sf_focus_mult_fact)
	selfRef.RemoveFromFaction(resources._sf_focus_modu_fact)
	selfRef.RemoveFromFaction(resources._sf_focus_indx_fact)

	selfRef.RemoveFromFaction(resources._sf_leash_mult_fact)
	selfRef.RemoveFromFaction(resources._sf_leash_modu_fact)
	selfRef.RemoveFromFaction(resources._sf_leash_indx_fact)

	slaves   = _sf_utility.nullSlotArray()
	selfRef  = none
	master   = none
	isPlayer = false
	index    = -1

	locked = true
	int delay = 0
	while clearProperties < 7 && delay < 10
		Utility.Wait(0.2)
		delay += 1
	endWhile
	Clear()
	locked = false
endFunction

function EnableAI()
	if isPlayer
		slavery.bMovement = Game.IsMovementControlsEnabled()
		slavery.bFighting = Game.IsFightingControlsEnabled()
		slavery.bCamera   = Game.IsCamSwitchControlsEnabled()
		slavery.bLooking  = Game.IsLookingControlsEnabled()
		slavery.bSneaking = Game.IsSneakingControlsEnabled()
		slavery.bMenu     = Game.IsMenuControlsEnabled()
		slavery.bActivate = Game.IsActivateControlsEnabled()
		slavery.bJournal  = Game.IsJournalControlsEnabled()

		Game.DisablePlayerControls(true, true, true, !slavery.bLooking, true, true, true, true)
		Game.ForceThirdPerson()

		Game.SetPlayerAiDriven(true)
	endIf
	
	if !packagesOn
		float fSpeed = resources.walkspeed
		if resources.zbfLoaded
			fSpeed = resources.zbfWalkspeed.GetValue()
		endIf

		locked = true
		selfRef.PathToReference(leashTarget.selfRef, fSpeed)
		locked = false
	endIf
endFunction

function DisableAI()
	if isPlayer
		Game.EnablePlayerControls(slavery.bMovement, slavery.bFighting, slavery.bCamera, !slavery.bLooking, slavery.bSneaking, slavery.bMenu, slavery.bActivate, slavery.bJournal)
		Game.SetPlayerAiDriven(false)
	endIf
endFunction




;##################################################################################################
; PROPERTY SLAVES =================================================================================
; 0x00000004 ======================================================================================
_sf_ActorSlot[] mySlaves
_sf_ActorSlot[] property slaves hidden
	function Set(_sf_ActorSlot[] akSlaves)
		if !locked
			Bool hasNewSlaves = akSlaves.length > 0
			Bool hasOldSlaves = mySlaves.length > 0

			if hasNewSlaves && !hasOldSlaves
				mySlaves = addSlaves(akSlaves)
				unsetClearBit(0x00000004)
			elseIf hasNewSlaves && hasOldSlaves
				mySlaves = removeSlaves(mySlaves, true)
				setClearBit(0x00000004)
				mySlaves = addSlaves(akSlaves, true)
				unsetClearBit(0x00000004)
			elseIf !hasNewSlaves && hasOldSlaves
				mySlaves = removeSlaves(mySlaves)
				setClearBit(0x00000004)
			else
				setClearBit(0x00000004)		
			endIf
			
			if mySlaves.length == 0 && kMaster == none
				emptySlot()
			endIf
		endIf
	endFunction
	_sf_ActorSlot[] function Get()
		return mySlaves
	endFunction
endProperty

_sf_ActorSlot[] function addSlaves(_sf_ActorSlot[] akSlots, bool abTransfer = false)
	if !abTransfer && !selfRef.HasSpell( resources._sf_master_spell )
		selfRef.AddSpell( resources._sf_master_spell )
	endIf

	return _sf_utility.compressSlotArray(akSlots)
endFunction

_sf_ActorSlot[] function removeSlaves(_sf_ActorSlot[] akSlots, bool abTransfer = false)
	if !abTransfer && selfRef.HasSpell( resources._sf_master_spell )
		selfRef.RemoveSpell( resources._sf_master_spell )
	endIf

	return _sf_utility.nullSlotArray()
endFunction




;##################################################################################################
; PROPERTY LEASH ==================================================================================
; 0x00000008 ======================================================================================
_sf_ActorSlot     property leashTarget          auto hidden

_sf_ActorSlot[] myLeashChain
_sf_ActorSlot[] property leashChain hidden
	function Set(_sf_ActorSlot[] akSlots)
		leashIdx  = akSlots.Find(self)
		Bool hasLeash = akSlots.length > 1 && leashIdx >= 0
		Bool isLeader = leashIdx == 0
		
		if hasLeash && !isLeader && !leashFirst
			leashLead   = akSlots[0]
			leashTarget = akSlots[leashIdx - 1]
			
		elseIf hasLeash && !isLeader && leashFirst
			leashLead   = akSlots[0]
			leashTarget = akSlots[0]
			leashIdx    = 1
		else
			leashLead   = none
			leashTarget = none
		endIf
		
		if leashTarget
			setActorOffset()
		else
			clearActorOffset()
		endIf

		myLeashChain = akSlots
	endFunction
	_sf_ActorSlot[] function Get()
		return myLeashChain
	endFunction
endProperty

_sf_ActorSlot myleashLead
_sf_ActorSlot property leashLead hidden
	function Set(_sf_ActorSlot akLead)
		if !locked
			if akLead
				int mult = math.floor(akLead.index / 127)
				int modu = akLead.index % 127

				selfRef.SetFactionRank(resources._sf_leash_mult_fact, mult)
				selfRef.SetFactionRank(resources._sf_leash_modu_fact, modu)
				resources.trace(self+" property leashLead *"+mult+" %"+modu)
			else
				selfRef.RemoveFromFaction(resources._sf_leash_mult_fact)
				selfRef.RemoveFromFaction(resources._sf_leash_modu_fact)
			endIf

			myleashLead = akLead
		endIf
	endFunction
	_sf_ActorSlot function Get()
		return myleashLead
	endFunction
endProperty

int myLeashIdx
int property leashIdx hidden
	function Set(int aiVal)
		if aiVal >= 0
			selfRef.SetFactionRank(resources._sf_leash_indx_fact, aiVal)
		else
			selfRef.RemoveFromFaction(resources._sf_leash_indx_fact)
		endIf
		
		resources.trace(self+" property leashIdx = "+aiVal)
		myLeashIdx = aiVal
	endFunction
	int function Get()
		return myLeashIdx
	endFunction
endProperty

Bool myLeashActive
Bool property leashActive hidden
	function Set(bool abActive)
		if myLeashActive && !abActive
			selfRef.SetFactionRank(resources._sf_leash_active_fact, 0)
		elseIf !myLeashActive && abActive
			selfRef.SetFactionRank(resources._sf_leash_active_fact, 1)
		endIf

		myLeashActive = abActive
	endFunction
	Bool function Get()
		return myLeashActive
	endFunction
endProperty

float mLeashLength
float property leashLength hidden
	function Set(float afVal)
		mLeashLength = afVal
		setActorOffset()
	endFunction
	float function Get()
		return mLeashLength
	endFunction
endProperty




;##################################################################################################
; PROPERTY FOCUS ==================================================================================
; 0x00000010 ======================================================================================
actor             property focusTarget          auto hidden

function SetFocusID(Actor akActor, int aiVal, int aiIndx)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127

		akActor.SetFactionRank(resources._sf_focus_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_focus_modu_fact, modu)
		akActor.SetFactionRank(resources._sf_focus_indx_fact, aiIndx)
	else
		resources.trace("slavery.SetFocusID:: absolute value cannot exceed 16256")
	endIf
endFunction

function ClearFocusID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_focus_mult_fact)
	akActor.RemoveFromFaction(resources._sf_focus_modu_fact)
	akActor.RemoveFromFaction(resources._sf_focus_indx_fact)
endFunction


;##################################################################################################
; PROPERTY AGENDA =================================================================================
; 0x00000020 ======================================================================================
int myAgenda = 0
int property agenda hidden
	function Set(int aiAgenda)
		selfRef.SetFactionRank(resources._sf_agenda_fact, aiAgenda)
		selfRef.EvaluatePackage()
		myAgenda = aiAgenda
	endFunction
	int function Get()
		return myAgenda
	endFunction
endProperty

; END FULL PROPERTIES =============================================================================
;##################################################################################################
;##################################################################################################
;##################################################################################################

event OnInit()
	leashLength = 256.0 * 1.25
	slavery     = GetOwningQuest() as _sf_slavery
	resources   = GetOwningQuest() as _sf_resources
endEvent

event OnCellLoad()
	selfRef.EvaluatePackage()
endEvent

event OnPackageStart(Package akNewPackage)
	resources.trace(self+" OnPackageStart "+akNewPackage)
endEvent

event OnPackageChange(Package akOldPackage)
	resources.trace(self+" OnPackageChange "+akOldPackage)
endEvent

event OnPackageEnd(Package akOldPackage)
	resources.trace(self+" OnPackageEnd "+akOldPackage)
endEvent


; START LOCAL SCOPE FUNCTIONS =====================================================================
function unsetClearBit(int bit)
	clearProperties = Math.LogicalAnd(clearProperties, Math.LogicalNot(bit))
endFunction

function setClearBit(int bit)
	clearProperties = Math.LogicalOr(clearProperties, bit)
endFunction

function setActorOffset()
	if selfRef && packagesOn
		Actor kTarget = leashTarget.selfRef
		Float fHalf   = leashLength/2.0
		Float fPX     = -fHalf * Math.Sin(kTarget.GetAngleZ())
		Float fPY     = -fHalf * Math.Cos(kTarget.GetAngleZ())
		Float fPZ     = 0.0
		Float fAX     = 0.0
		Float fAY     = 0.0
		Float fAZ     = selfRef.GetAngleZ() - selfRef.GetHeadingAngle(kTarget)

		selfRef.KeepOffsetFromActor(kTarget, fPX, fPY, fPZ, fAX, fAY, fAZ, fHalf, leashLength)
	endIf
endFunction

function clearActorOffset()
	if selfRef && packagesOn
		selfRef.ClearKeepOffsetFromActor()
	endIf
endFunction
