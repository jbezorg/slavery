Scriptname _sf_ActorSlot extends ReferenceAlias

ActiveMagicEffect property slaveAbility          auto hidden
ActiveMagicEffect property masterAbility         auto hidden

_sf_slavery       property slavery               auto hidden
_sf_resources     property resources             auto hidden

Bool              property locked = false        auto hidden
Bool              property leashLOS = false      auto hidden
Bool              property isPlayer = false      auto hidden

Form[]            property joinedFactions        auto hidden
Int               property status                auto hidden


int clearProperties = 7

; START FULL PROPERTIES ===========================================================================
;##################################################################################################
; PROPERTY MASTER =================================================================================
; 0x00000001 ======================================================================================

_sf_ActorSlot kMaster = none
_sf_ActorSlot property master hidden
	function Set(_sf_ActorSlot akMaster)
		if !locked
			Bool hasSlaveSpell = mySelfRef.HasSpell(resources._sf_slave_spell)
			Bool hasNewMaster  = akMaster != none
			Bool hasOldMaster  = kMaster != none
			bool hasSlaves     = slaves.length > 0

			if hasNewMaster && !hasSlaveSpell
				mySelfRef.AddSpell(resources._sf_slave_spell)
			elseIf !hasNewMaster && hasSlaveSpell
				mySelfRef.RemoveSpell(resources._sf_slave_spell)
			endIf

			if hasNewMaster && !hasOldMaster
				kMaster = addMaster(akMaster)
				unsetClearBit(0x00000001)
			elseIf hasNewMaster && hasOldMaster
				kMaster = removeSlave()
				setClearBit(0x00000001)
				kMaster = addMaster(akMaster)
				unsetClearBit(0x00000001)
			elseIf !hasNewMaster && hasOldMaster
				kMaster = removeSlave()
				setClearBit(0x00000001)
			else
				setClearBit(0x00000001)
			endIf
			
			if !hasNewMaster && !hasSlaves
				emptySlot()
			endIf
		endIf
	endFunction
	_sf_ActorSlot function Get()
		return kMaster
	endFunction
endProperty

_sf_ActorSlot function addMaster(_sf_ActorSlot akSlot)
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

_sf_ActorSlot function removeSlave()
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

actor mySelfRef = none
actor property selfRef hidden
	function Set(actor akActor)
		if !locked
			Bool hasNewActor = akActor != none
			Bool hasOldActor = mySelfRef != none
			Bool hasMaster   = kMaster != none
			bool hasSlaves   = slaves.length > 0

			if hasNewActor && !hasOldActor
				mySelfRef = addSelf(akActor)
				unsetClearBit(0x00000002)
			elseIf hasNewActor && hasOldActor
				mySelfRef = removeSelf()
				setClearBit(0x00000002)
				mySelfRef = addSelf(akActor)
				unsetClearBit(0x00000002)
			elseIf !hasNewActor && hasOldActor
				mySelfRef = removeSelf()
				setClearBit(0x00000002)
			else
				setClearBit(0x00000002)
			endIf
			
			if !hasNewActor && hasSlaves
				slaves = none
			endIf
		endIf
	endFunction
	actor function Get()
		return mySelfRef
	endFunction
endProperty

Bool myAIActive = false
Bool property AIActive hidden
	function Set(bool abActive)
		if !myAIActive && abActive
			resources.trace("AIActive"+abActive)
			EnableAI()
		elseIf myAIActive && !abActive
			resources.trace("AIActive"+abActive)
			DisableAI()
		endIf

		myAIActive = abActive
	endFunction
	Bool function Get()
		return myAIActive
	endFunction
endProperty

actor function addSelf(actor akActor)
	isPlayer = akActor == Game.GetPlayer()
	ForceRefTo(akActor)
	return akActor
endFunction

actor function removeSelf()
	isPlayer = false
	index    = -1
	mySelfRef.RemoveFromFaction(resources._sf_alias_mult_fact)
	mySelfRef.RemoveFromFaction(resources._sf_alias_modu_fact)
	mySelfRef.RemoveFromFaction(resources._sf_alias_sign_fact)
	return none
endFunction

function setActorOffset()
	if selfRef
		Float fHalf  = leashLength/2.0
		Float fPX    = -fHalf * Math.Sin(leashTarget.GetAngleZ())
		Float fPY    = -fHalf * Math.Cos(leashTarget.GetAngleZ())
		Float fPZ    = 0.0
		Float fAX    = 0.0
		Float fAY    = 0.0
		Float fAZ    = selfRef.GetAngleZ() - selfRef.GetHeadingAngle(leashTarget)

		selfRef.KeepOffsetFromActor(leashTarget, fPX, fPY, fPZ, fAX, fAY, fAZ, fHalf, leashLength)
	endIf
endFunction

function clearActorOffset()
	if selfRef
		selfRef.ClearKeepOffsetFromActor()
	endIf
endFunction

function EnableAI()
	if isPlayer
		Game.SetPlayerAiDriven(true)

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
	else
		setActorOffset()
	endIf
	
	selfRef.EvaluatePackage()
endFunction

function DisableAI()
	if isPlayer
		Game.EnablePlayerControls(slavery.bMovement, slavery.bFighting, slavery.bCamera, !slavery.bLooking, slavery.bSneaking, slavery.bMenu, slavery.bActivate, slavery.bJournal)
		Game.SetPlayerAiDriven(false)
	else
		clearActorOffset()
	endIf

	selfRef.EvaluatePackage()
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
				mySlaves = removeSlaves(mySlaves)
				setClearBit(0x00000004)
				mySlaves = addSlaves(akSlaves)
				unsetClearBit(0x00000004)
			elseIf !hasNewSlaves && hasOldSlaves
				mySlaves = removeSlaves(mySlaves)
				setClearBit(0x00000004)
			else
				setClearBit(0x00000004)		
			endIf
		endIf
	endFunction
	_sf_ActorSlot[] function Get()
		return mySlaves
	endFunction
endProperty

_sf_ActorSlot[] function addSlaves(_sf_ActorSlot[] akSlots)
	if !selfRef.HasSpell( resources._sf_master_spell )
		selfRef.AddSpell( resources._sf_master_spell )
	endIf

	return _sf_utility.compressSlotArray(akSlots)
endFunction

_sf_ActorSlot[] function removeSlaves(_sf_ActorSlot[] akSlots)
	if selfRef.HasSpell( resources._sf_master_spell )
		selfRef.RemoveSpell( resources._sf_master_spell )
	endIf

	return _sf_utility.nullSlotArray()
endFunction




;##################################################################################################
; PROPERTY LEASH ==================================================================================
; 0x00000008 ======================================================================================
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

Actor myLeashTarget
Actor property leashTarget hidden
	function Set(Actor akActor)
		Bool hasNewActor = akActor != none
		Bool hasOldActor = myLeashTarget != none

		if hasNewActor && !hasOldActor
			SetLeashID(selfRef, index)
			SetLeashID(akActor, index)
		elseIf hasNewActor && hasOldActor
			ClearLeashID(myLeashTarget)
			SetLeashID(selfRef, index)
			SetLeashID(akActor, index)
		elseIf !hasNewActor && hasOldActor
			ClearLeashID(myLeashTarget)
			ClearLeashID(akActor)
		endIf
			
		myLeashTarget = akActor
	endFunction
	Actor function Get()
		return myLeashTarget
	endFunction
endProperty

int function GetLeashID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_leash_mult_fact) * 127
	int modu = akActor.GetFactionRank(resources._sf_leash_modu_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		return mult + modu
	endIf
endFunction

function SetLeashID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127

		akActor.SetFactionRank(resources._sf_leash_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_leash_modu_fact, modu)
	else
		resources.trace("slavery.SetLeashID:: absolute value cannot exceed 16256")
	endIf
endFunction

function ClearLeashID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_leash_mult_fact)
	akActor.RemoveFromFaction(resources._sf_leash_modu_fact)
endFunction




;##################################################################################################
; PROPERTY FOCUS ==================================================================================
; 0x00000010 ======================================================================================
Actor myFocusTarget
Actor property focusTarget hidden
	function Set(Actor akActor)
		Bool hasNewActor = akActor != none
		Bool hasOldActor = myFocusTarget != none

		if hasNewActor && !hasOldActor
			SetFocusID(selfRef, index)
			SetFocusID(akActor, index)
		elseIf hasNewActor && hasOldActor
			ClearFocusID(myFocusTarget)
			SetFocusID(selfRef, index)
			SetFocusID(akActor, index)
		elseIf !hasNewActor && hasOldActor
			ClearFocusID(myFocusTarget)
			ClearFocusID(akActor)
		endIf
			
		myFocusTarget = akActor	
	endFunction
	Actor function Get()
		return myFocusTarget
	endFunction
endProperty

function SetFocusID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127

		akActor.SetFactionRank(resources._sf_focus_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_focus_modu_fact, modu)
	else
		resources.trace("slavery.SetFocusID:: absolute value cannot exceed 16256")
	endIf
endFunction

function ClearFocusID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_focus_mult_fact)
	akActor.RemoveFromFaction(resources._sf_focus_modu_fact)
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
endEvent

event OnPackageChange(Package akOldPackage)
endEvent

event OnPackageEnd(Package akOldPackage)
endEvent


; START LOCAL SCOPE FUNCTIONS =====================================================================
function initSlot()
	clearProperties = 0
endFunction

function emptySlot()
	self.slaves  = _sf_utility.nullSlotArray()
	self.selfRef = none
	self.master  = none

	self.locked = true
	int delay = 0
	while clearProperties < 7 && delay < 10
		Utility.Wait(0.2)
		delay += 1
	endWhile
	self.Clear()
	self.locked = false
endFunction

function unsetClearBit(int bit)
	clearProperties = Math.LogicalAnd(clearProperties, Math.LogicalNot(bit))
endFunction

function setClearBit(int bit)
	clearProperties = Math.LogicalOr(clearProperties, bit)
endFunction

