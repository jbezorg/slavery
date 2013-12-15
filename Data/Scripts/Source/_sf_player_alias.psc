Scriptname _sf_player_alias extends ReferenceAlias  

_sf_resources property resources  auto
_sf_slavery   property slavery    auto

event OnPlayerLoadGame()
	actor player  = GetActorReference()
	bool[] loaded = modsLoaded()
	
	slavery.zbfLoaded = loaded[0]
	slavery.SLLoaded = loaded[1]
	slavery.SLArousedLoaded = loaded[2]
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
		if name == "ZaZAnimationPack.esm" || name == "ZaZAnimationPack.esp"
			mod[0] = true
			cnt += 1
		endIf
		if name == "SexLab.esm"
			mod[1] = true
			cnt += 1
		endIf
		if name == "SexLabAroused.esm"
			mod[2] = true
			cnt += 1
		endIf
	endWhile

	return mod
endFunction
