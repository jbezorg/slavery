Scriptname _sf_player_alias extends ReferenceAlias  

_sf_resources property resources  auto
_sf_slavery   property slavery    auto

event OnPlayerLoadGame()
	actor player  = GetActorReference()
	bool[] loaded = modsLoaded()
	
	resources.zbfLoaded = loaded[0]
	resources.SLLoaded = loaded[1]
	resources.SLArousedLoaded = loaded[2]
endEvent

bool[] function modsLoaded()
	string name = ""
	bool[] mod  = new bool[3]
	int idx     = 0
	int cnt     = 0
	
	idx = mod.length
	while idx
		idx -= 1
		mod[idx] = false
	endWhile

	idx = Game.GetModCount()
	while idx && cnt < mod.length
		idx -= 1
		name = Game.GetModName(idx)
		if !mod[0] && (name == "ZaZAnimationPack.esm" || name == "ZaZAnimationPack.esp")
			resources.zbfWalkspeed = Game.GetFormFromFile(0x00008A4A, name) as GlobalVariable
			mod[0] = true
			cnt += 1
		endIf
		if !mod[1] && name == "SexLab.esm"
			mod[1] = true
			cnt += 1
		endIf
		if !mod[2] && name == "SexLabAroused.esm"
			mod[2] = true
			cnt += 1
		endIf
	endWhile

	return mod
endFunction
