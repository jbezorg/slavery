Scriptname _sf_ActorSlot extends ReferenceAlias

ActiveMagicEffect property slaveAbility          auto hidden
ActiveMagicEffect property masterAbility         auto hidden

_sf_slavery       property slavery               auto hidden
_sf_resources     property resources             auto hidden

Bool              property xferOnQuit = false    auto hidden
Bool              property inheritOrder = false  auto hidden

Bool              property locked = false        auto hidden

Form[]            property joinedFactions        auto hidden

int               property FACTIONTYPE = 11      autoreadonly

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
	joinedFactions = nullFormArray()
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

	self.selfId     = GetID()
	slavery.SetAliasID(akActor, selfId)
	return akActor
endFunction

actor function removeSelf()
	self.selfId     = -1
	slavery.ClearAliasID(mySelfRef)
	return none
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
				mySlaves = removeSlaves()
				setClearBit(0x00000004)
				mySlaves = addSlaves(akSlaves)
				unsetClearBit(0x00000004)
			elseIf !hasNewSlaves && hasOldSlaves
				mySlaves = removeSlaves()
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

_sf_ActorSlot[] function removeSlaves()
	return nullSlotArray()
endFunction
; END FULL PROPERTIES =============================================================================


event OnCellLoad()

endEvent


; START LOCAL SCOPE FUNCTIONS =====================================================================
function initSlot()
	clearProperties = 0
	self.xferOnQuit   = false
	self.inheritOrder = false
endFunction

function emptySlot()
	self.slaves  = nullSlotArray()
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

_sf_ActorSlot[] function nullSlotArray()
	_sf_ActorSlot[] empty
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
