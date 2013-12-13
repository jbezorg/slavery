Scriptname _sf_ActorSlot extends ReferenceAlias

ActiveMagicEffect property slaveAbility          auto hidden
ActiveMagicEffect property masterAbility         auto hidden

_sf_slavery       property slavery               auto hidden
_sf_resources     property resources             auto hidden

Bool              property locked = false        auto hidden
Bool              property leashLOS = false      auto hidden

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
		if akSlot.selfRef.IsInFaction(nthFaction as faction)
			selfRef.AddToFaction(nthFaction as faction)
			joinedFactions = sslUtility.PushForm(nthFaction, joinedFactions)
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
int               property selfId = -1           auto hidden

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

actor function addSelf(actor akActor)
	ForceRefTo(akActor)

	self.selfId = GetID()
	SetAliasID(akActor, selfId)
	return akActor
endFunction

actor function removeSelf()
	self.selfId     = -1
	ClearAliasID(mySelfRef)
	return none
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
	else
		Debug.TraceConditional("slavery.SetAliasID:: absolute value cannot exceed 16256", slavery.verbose)
	endIf
endFunction

function ClearAliasID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_alias_mult_fact)
	akActor.RemoveFromFaction(resources._sf_alias_modu_fact)
	akActor.RemoveFromFaction(resources._sf_alias_sign_fact)
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
	return _sf_utility.compressSlotArray(akSlots)
endFunction

_sf_ActorSlot[] function removeSlaves(_sf_ActorSlot[] akSlots)
	return _sf_utility.nullSlotArray()
endFunction




;##################################################################################################
; PROPERTY LEASH ==================================================================================
; 0x00000008 ======================================================================================
Bool myLeashEnabled
Bool property leashEnabled hidden
	function Set(bool abEnabled)
		if myLeashEnabled && !abEnabled
			selfRef.SetFactionRank(resources._sf_agenda_fact, 0)
		elseIf !myLeashEnabled && abEnabled
			selfRef.SetFactionRank(resources._sf_agenda_fact, 1)
		endIf

		myLeashEnabled = abEnabled
	endFunction
	Bool function Get()
		return myLeashEnabled
	endFunction
endProperty

Bool myLeashActive
Bool property leashActive hidden
	function Set(bool abActive)
		if myLeashActive && !abActive
			selfRef.ClearKeepOffsetFromActor()
		elseIf !myLeashActive && abActive
			setActorOffset(leashLength)
		endIf

		slavery.aiRetention(selfRef, abActive)
		myLeashActive = abActive
	endFunction
	Bool function Get()
		return myLeashActive
	endFunction
endProperty

float mLeashLength
float property leashLength hidden
	function Set(float afVal)
		if leashActive && leashLength != afVal
			setActorOffset(afVal)
		endIf

		mLeashLength = afVal
	endFunction
	float function Get()
		return mLeashLength
	endFunction
endProperty

Actor myLeashTarget
Actor property leashTarget hidden
	function Set(Actor akActor)
		if akActor == none
			ClearLeashID(selfRef)
		else
			SetLeashID(selfRef, selfId)
			SetLeashID(akActor, selfId)
		endIf

		if myLeashTarget && myLeashTarget != akActor
			ClearLeashID(myLeashTarget)
		endIf

		myLeashTarget = akActor
	endFunction
	Actor function Get()
		return myLeashTarget
	endFunction
endProperty

int function GetLeashID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_leash_mult_fact)
	int modu = akActor.GetFactionRank(resources._sf_leash_modu_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		return mult * 127 + modu
	endIf
endFunction

function setActorOffset(float afDistance)
	Float fHalf  = afDistance/2
	Float fPX    = -fHalf * Math.Sin(master.selfRef.GetAngleZ())
	Float fPY    = -fHalf * Math.Cos(master.selfRef.GetAngleZ())
	Float fPZ    = 0.0
	Float fAX    = 0.0
	Float fAY    = 0.0
	Float fAZ    = selfRef.GetAngleZ() - selfRef.GetHeadingAngle(master.selfRef)

	selfRef.KeepOffsetFromActor(master.selfRef, fPX, fPY, fPZ, fAX, fAY, fAZ, fHalf, afDistance)
endFunction

function SetLeashID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127

		akActor.SetFactionRank(resources._sf_leash_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_leash_modu_fact, modu)
	else
		Debug.TraceConditional("slavery.SetLeashID:: absolute value cannot exceed 16256", slavery.verbose)
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
		if akActor == none
			ClearFocusID(selfRef)
		else
			SetFocusID(selfRef, selfId)
			SetFocusID(akActor, selfId)
		endIf

		if myFocusTarget && myFocusTarget != akActor
			ClearFocusID(myFocusTarget)
		endIf

		myFocusTarget = akActor
	endFunction
	Actor function Get()
		return myFocusTarget
	endFunction
endProperty

int function GetFocusID(Actor akActor)
	int mult = akActor.GetFactionRank(resources._sf_focus_mult_fact)
	int modu = akActor.GetFactionRank(resources._sf_focus_modu_fact)

	if mult < 0 || modu < 0
		return resources.VOID
	else
		return mult * 127 + modu
	endIf
endFunction

function SetFocusID(Actor akActor, int aiVal)
	int abso = math.abs(aiVal) as int
	if abso <= 16256
		int mult = math.floor(abso / 127)
		int modu = abso % 127

		akActor.SetFactionRank(resources._sf_focus_mult_fact, mult)
		akActor.SetFactionRank(resources._sf_focus_modu_fact, modu)
	else
		Debug.TraceConditional("slavery.SetFocusID:: absolute value cannot exceed 16256", slavery.verbose)
	endIf
endFunction

function ClearFocusID(Actor akActor)
	akActor.RemoveFromFaction(resources._sf_focus_mult_fact)
	akActor.RemoveFromFaction(resources._sf_focus_modu_fact)
endFunction


; END FULL PROPERTIES =============================================================================
;##################################################################################################


event OnCellLoad()

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

form[] function nullFormArray()
	form[] empty
	return empty
endFunction

form[] function getMyFactions(actor akActor, int aiType = 11)
	form[] forms1 = new form[128]

	int idx = 0
	int cnt = 0
	form nthForm = (akActor as ObjectReference).GetNthForm(idx)
	while nthForm
		Debug.TraceConditional("> > > > > > > > > >"+akActor+":"+nthForm+":"+nthForm.GetType(), slavery.verbose)

		if nthForm.GetType() == aiType
			forms1[cnt] = nthForm
			cnt += 1
		endIf
		idx += 1
		nthForm = (akActor as ObjectReference).GetNthForm(idx)
	endWhile

	Debug.TraceConditional("> > > > > > > > > >slavery:getMyFactions:count:"+akActor+":"+cnt, slavery.verbose)
	
	form[] forms2 = sslUtility.FormArray(cnt)
	while cnt > 0
		cnt -= 1
		forms2[cnt] = forms1[cnt]
	endWhile

	return forms2
endFunction
