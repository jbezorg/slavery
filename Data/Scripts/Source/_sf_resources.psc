Scriptname _sf_resources extends Quest  

Spell       Property _sf_trigger_spell      Auto  
Spell       Property _sf_slave_spell        Auto  
Spell       Property _sf_master_spell       Auto  
MagicEffect Property _sf_trigger_me         Auto  
MagicEffect Property _sf_slave_base_me      Auto  
MagicEffect Property _sf_master_base_me     Auto  
Keyword     Property _sf_master_kw          Auto  
Keyword     Property _sf_slave_kw           Auto  
Faction     Property _sf_alias_mult_fact    Auto  
Faction     Property _sf_alias_modu_fact    Auto  
Faction     Property _sf_alias_sign_fact    Auto  
Faction     Property _sf_leash_mult_fact    Auto  
Faction     Property _sf_leash_modu_fact    Auto  
Faction     Property _sf_focus_mult_fact    Auto  
Faction     Property _sf_focus_modu_fact    Auto  
Faction     Property _sf_agenda_fact        Auto
FormList    Property _sf_faction_list       Auto  

int         Property VOID = -2147483648     autoreadonly



; Obsolete/Unused Stats
; altered*	retained**	reboot***
;	[   ]	[   ]		[   ]	"CombatHealthRegenMultMod"
;	[   ]	[   ]		[   ]	"CombatHealthRegenMultPowerMod"
;	[ X ]	[   ]		[   ]	"PerceptionCondition"
;	[ X ]	[   ]		[   ]	"EnduranceCondition"
;	[ X ]	[   ]		[   ]	"LeftAttackCondition"
;	[ X ]	[   ]		[   ]	"RightAttackCondition"
;	[ X ]	[   ]		[   ]	"LeftMobilityCondition"
;	[ X ]	[   ]		[   ]	"RightMobilityCondition"
;	[ X ]	[   ]		[   ]	"BrainCondition"
;	[ X ]	[ X ]		[ X ]	"IgnoreCrippledLimbs"
;	[ X ]	[ X ]		[ X ]	"Fame"
;	[ X ]	[ X ]		[ X ]	"Infamy"
;	[ X ]	[ X ]		[ X ]	"FavorActive"
;	[ X ]	[ X ]		[ X ]	"FavorPointsBonus"
;	[ X ]	[ X ]		[ X ]	"FavorsPerDay"
;	[ X ]	[ X ]		[ X ]	"FavorsPerDayTimer"
;	[ X ]	[ X ]		[ X ]	"BypassVendorStolenCheck"
;	[ X ]	[ X ]		[ X ]	"BypassVendorKeywordCheck"
;	[ X ]	[ X ]		[ X ]	"LastBribedIntimidated"
;	[ X ]	[ X ]		[ X ]	"LastFlattered"
;
;   * Can set through SetAV. Min/Max value is signed float
;  ** value set on NPC was retained after fast traveling out
;     of the area and waiting 24 game hours.
;     Note: tested at values above 100, they may have reset
;     to a lower value for the Condition stats
; *** value set on NPC was retained after game restart.
