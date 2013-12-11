Scriptname _sf_utility

int[] function RemoveInt(int var, int[] array) global
	int len = array.Length
	if len <= 1
		return none
	endIf

	int cnt = len
	int[] pulled = sslUtility.IntArray(len - 1)
	while len
		len -=1
		if array[len] != var
			cnt -=1
			pulled[cnt] = array[len]
		endIf
	endWhile
	return pulled
endFunction

actor[] function PushActor(actor var, actor[] array) global
	int len = array.Length
	if len >= 128
		return array
	elseIf len == 0
		array = new actor[1]
		array[0] = var
		return array
	endIf

	actor[] pushed = ActorArray(len + 1)
	pushed[len] = var
	while len
		len -=1
		pushed[len] = array[len]
	endWhile
	return pushed
endFunction

actor[] function RemoveActor(actor var, actor[] array) global
	int len = array.Length
	if len <= 1
		return none
	endIf

	int cnt = len
	actor[] pulled = ActorArray(len - 1)
	while len
		len -=1
		if array[len] != var
			cnt -=1
			pulled[cnt] = array[len]
		endIf
	endWhile
	return pulled
endFunction

_sf_ActorSlot[] function PushActorSlot(_sf_ActorSlot var, _sf_ActorSlot[] array) global
	int len = array.Length
	if len >= 128
		return array
	elseIf len == 0
		array = new _sf_ActorSlot[1]
		array[0] = var
		return array
	endIf

	_sf_ActorSlot[] pushed = ActorSlotArray(len + 1)
	pushed[len] = var
	while len
		len -=1
		pushed[len] = array[len]
	endWhile
	return pushed
endFunction

_sf_ActorSlot[] function ActorSlotArray(int size) global
	size = sslUtility.ValidateSize(size)
	if size == 1
		return new _sf_ActorSlot[1]
	elseIf size == 2
		return new _sf_ActorSlot[2]
	elseIf size == 3
		return new _sf_ActorSlot[3]
	elseIf size == 4
		return new _sf_ActorSlot[4]
	elseIf size == 5
		return new _sf_ActorSlot[5]
	elseIf size == 6
		return new _sf_ActorSlot[6]
	elseIf size == 7
		return new _sf_ActorSlot[7]
	elseIf size == 8
		return new _sf_ActorSlot[8]
	elseIf size == 9
		return new _sf_ActorSlot[9]
	elseIf size == 10
		return new _sf_ActorSlot[10]
	elseIf size == 11
		return new _sf_ActorSlot[11]
	elseIf size == 12
		return new _sf_ActorSlot[12]
	elseIf size == 13
		return new _sf_ActorSlot[13]
	elseIf size == 14
		return new _sf_ActorSlot[14]
	elseIf size == 15
		return new _sf_ActorSlot[15]
	elseIf size == 16
		return new _sf_ActorSlot[16]
	elseIf size == 17
		return new _sf_ActorSlot[17]
	elseIf size == 18
		return new _sf_ActorSlot[18]
	elseIf size == 19
		return new _sf_ActorSlot[19]
	elseIf size == 20
		return new _sf_ActorSlot[20]
	elseIf size == 21
		return new _sf_ActorSlot[21]
	elseIf size == 22
		return new _sf_ActorSlot[22]
	elseIf size == 23
		return new _sf_ActorSlot[23]
	elseIf size == 24
		return new _sf_ActorSlot[24]
	elseIf size == 25
		return new _sf_ActorSlot[25]
	elseIf size == 26
		return new _sf_ActorSlot[26]
	elseIf size == 27
		return new _sf_ActorSlot[27]
	elseIf size == 28
		return new _sf_ActorSlot[28]
	elseIf size == 29
		return new _sf_ActorSlot[29]
	elseIf size == 30
		return new _sf_ActorSlot[30]
	elseIf size == 31
		return new _sf_ActorSlot[31]
	elseIf size == 32
		return new _sf_ActorSlot[32]
	elseIf size == 33
		return new _sf_ActorSlot[33]
	elseIf size == 34
		return new _sf_ActorSlot[34]
	elseIf size == 35
		return new _sf_ActorSlot[35]
	elseIf size == 36
		return new _sf_ActorSlot[36]
	elseIf size == 37
		return new _sf_ActorSlot[37]
	elseIf size == 38
		return new _sf_ActorSlot[38]
	elseIf size == 39
		return new _sf_ActorSlot[39]
	elseIf size == 40
		return new _sf_ActorSlot[40]
	elseIf size == 41
		return new _sf_ActorSlot[41]
	elseIf size == 42
		return new _sf_ActorSlot[42]
	elseIf size == 43
		return new _sf_ActorSlot[43]
	elseIf size == 44
		return new _sf_ActorSlot[44]
	elseIf size == 45
		return new _sf_ActorSlot[45]
	elseIf size == 46
		return new _sf_ActorSlot[46]
	elseIf size == 47
		return new _sf_ActorSlot[47]
	elseIf size == 48
		return new _sf_ActorSlot[48]
	elseIf size == 49
		return new _sf_ActorSlot[49]
	elseIf size == 50
		return new _sf_ActorSlot[50]
	elseIf size == 51
		return new _sf_ActorSlot[51]
	elseIf size == 52
		return new _sf_ActorSlot[52]
	elseIf size == 53
		return new _sf_ActorSlot[53]
	elseIf size == 54
		return new _sf_ActorSlot[54]
	elseIf size == 55
		return new _sf_ActorSlot[55]
	elseIf size == 56
		return new _sf_ActorSlot[56]
	elseIf size == 57
		return new _sf_ActorSlot[57]
	elseIf size == 58
		return new _sf_ActorSlot[58]
	elseIf size == 59
		return new _sf_ActorSlot[59]
	elseIf size == 60
		return new _sf_ActorSlot[60]
	elseIf size == 61
		return new _sf_ActorSlot[61]
	elseIf size == 62
		return new _sf_ActorSlot[62]
	elseIf size == 63
		return new _sf_ActorSlot[63]
	elseIf size == 64
		return new _sf_ActorSlot[64]
	elseIf size == 65
		return new _sf_ActorSlot[65]
	elseIf size == 66
		return new _sf_ActorSlot[66]
	elseIf size == 67
		return new _sf_ActorSlot[67]
	elseIf size == 68
		return new _sf_ActorSlot[68]
	elseIf size == 69
		return new _sf_ActorSlot[69]
	elseIf size == 70
		return new _sf_ActorSlot[70]
	elseIf size == 71
		return new _sf_ActorSlot[71]
	elseIf size == 72
		return new _sf_ActorSlot[72]
	elseIf size == 73
		return new _sf_ActorSlot[73]
	elseIf size == 74
		return new _sf_ActorSlot[74]
	elseIf size == 75
		return new _sf_ActorSlot[75]
	elseIf size == 76
		return new _sf_ActorSlot[76]
	elseIf size == 77
		return new _sf_ActorSlot[77]
	elseIf size == 78
		return new _sf_ActorSlot[78]
	elseIf size == 79
		return new _sf_ActorSlot[79]
	elseIf size == 80
		return new _sf_ActorSlot[80]
	elseIf size == 81
		return new _sf_ActorSlot[81]
	elseIf size == 82
		return new _sf_ActorSlot[82]
	elseIf size == 83
		return new _sf_ActorSlot[83]
	elseIf size == 84
		return new _sf_ActorSlot[84]
	elseIf size == 85
		return new _sf_ActorSlot[85]
	elseIf size == 86
		return new _sf_ActorSlot[86]
	elseIf size == 87
		return new _sf_ActorSlot[87]
	elseIf size == 88
		return new _sf_ActorSlot[88]
	elseIf size == 89
		return new _sf_ActorSlot[89]
	elseIf size == 90
		return new _sf_ActorSlot[90]
	elseIf size == 91
		return new _sf_ActorSlot[91]
	elseIf size == 92
		return new _sf_ActorSlot[92]
	elseIf size == 93
		return new _sf_ActorSlot[93]
	elseIf size == 94
		return new _sf_ActorSlot[94]
	elseIf size == 95
		return new _sf_ActorSlot[95]
	elseIf size == 96
		return new _sf_ActorSlot[96]
	elseIf size == 97
		return new _sf_ActorSlot[97]
	elseIf size == 98
		return new _sf_ActorSlot[98]
	elseIf size == 99
		return new _sf_ActorSlot[99]
	elseIf size == 100
		return new _sf_ActorSlot[100]
	elseIf size == 101
		return new _sf_ActorSlot[101]
	elseIf size == 102
		return new _sf_ActorSlot[102]
	elseIf size == 103
		return new _sf_ActorSlot[103]
	elseIf size == 104
		return new _sf_ActorSlot[104]
	elseIf size == 105
		return new _sf_ActorSlot[105]
	elseIf size == 106
		return new _sf_ActorSlot[106]
	elseIf size == 107
		return new _sf_ActorSlot[107]
	elseIf size == 108
		return new _sf_ActorSlot[108]
	elseIf size == 109
		return new _sf_ActorSlot[109]
	elseIf size == 110
		return new _sf_ActorSlot[110]
	elseIf size == 111
		return new _sf_ActorSlot[111]
	elseIf size == 112
		return new _sf_ActorSlot[112]
	elseIf size == 113
		return new _sf_ActorSlot[113]
	elseIf size == 114
		return new _sf_ActorSlot[114]
	elseIf size == 115
		return new _sf_ActorSlot[115]
	elseIf size == 116
		return new _sf_ActorSlot[116]
	elseIf size == 117
		return new _sf_ActorSlot[117]
	elseIf size == 118
		return new _sf_ActorSlot[118]
	elseIf size == 119
		return new _sf_ActorSlot[119]
	elseIf size == 120
		return new _sf_ActorSlot[120]
	elseIf size == 121
		return new _sf_ActorSlot[121]
	elseIf size == 122
		return new _sf_ActorSlot[122]
	elseIf size == 123
		return new _sf_ActorSlot[123]
	elseIf size == 124
		return new _sf_ActorSlot[124]
	elseIf size == 125
		return new _sf_ActorSlot[125]
	elseIf size == 126
		return new _sf_ActorSlot[126]
	elseIf size == 127
		return new _sf_ActorSlot[127]
	elseIf size == 128
		return new _sf_ActorSlot[128]
	endIf
endFunction

_sf_ActorSlot[] function RemoveActorSlot(_sf_ActorSlot var, _sf_ActorSlot[] array) global
	int len = array.Length
	if len <= 1
		return none
	endIf

	int cnt = len
	_sf_ActorSlot[] pulled = ActorSlotArray(len - 1)
	while len
		len -=1
		if array[len] != var
			cnt -=1
			pulled[cnt] = array[len]
		endIf
	endWhile
	return pulled
endFunction

; =================================================================================================

_sf_ActorSlot[] function slotArray(int size) global
	size = sslUtility.ValidateSize(size)
	if size == 1
		return new _sf_ActorSlot[1]
	elseIf size == 2
		return new _sf_ActorSlot[2]
	elseIf size == 3
		return new _sf_ActorSlot[3]
	elseIf size == 4
		return new _sf_ActorSlot[4]
	elseIf size == 5
		return new _sf_ActorSlot[5]
	elseIf size == 6
		return new _sf_ActorSlot[6]
	elseIf size == 7
		return new _sf_ActorSlot[7]
	elseIf size == 8
		return new _sf_ActorSlot[8]
	elseIf size == 9
		return new _sf_ActorSlot[9]
	elseIf size == 10
		return new _sf_ActorSlot[10]
	elseIf size == 11
		return new _sf_ActorSlot[11]
	elseIf size == 12
		return new _sf_ActorSlot[12]
	elseIf size == 13
		return new _sf_ActorSlot[13]
	elseIf size == 14
		return new _sf_ActorSlot[14]
	elseIf size == 15
		return new _sf_ActorSlot[15]
	elseIf size == 16
		return new _sf_ActorSlot[16]
	elseIf size == 17
		return new _sf_ActorSlot[17]
	elseIf size == 18
		return new _sf_ActorSlot[18]
	elseIf size == 19
		return new _sf_ActorSlot[19]
	elseIf size == 20
		return new _sf_ActorSlot[20]
	elseIf size == 21
		return new _sf_ActorSlot[21]
	elseIf size == 22
		return new _sf_ActorSlot[22]
	elseIf size == 23
		return new _sf_ActorSlot[23]
	elseIf size == 24
		return new _sf_ActorSlot[24]
	elseIf size == 25
		return new _sf_ActorSlot[25]
	elseIf size == 26
		return new _sf_ActorSlot[26]
	elseIf size == 27
		return new _sf_ActorSlot[27]
	elseIf size == 28
		return new _sf_ActorSlot[28]
	elseIf size == 29
		return new _sf_ActorSlot[29]
	elseIf size == 30
		return new _sf_ActorSlot[30]
	elseIf size == 31
		return new _sf_ActorSlot[31]
	elseIf size == 32
		return new _sf_ActorSlot[32]
	elseIf size == 33
		return new _sf_ActorSlot[33]
	elseIf size == 34
		return new _sf_ActorSlot[34]
	elseIf size == 35
		return new _sf_ActorSlot[35]
	elseIf size == 36
		return new _sf_ActorSlot[36]
	elseIf size == 37
		return new _sf_ActorSlot[37]
	elseIf size == 38
		return new _sf_ActorSlot[38]
	elseIf size == 39
		return new _sf_ActorSlot[39]
	elseIf size == 40
		return new _sf_ActorSlot[40]
	elseIf size == 41
		return new _sf_ActorSlot[41]
	elseIf size == 42
		return new _sf_ActorSlot[42]
	elseIf size == 43
		return new _sf_ActorSlot[43]
	elseIf size == 44
		return new _sf_ActorSlot[44]
	elseIf size == 45
		return new _sf_ActorSlot[45]
	elseIf size == 46
		return new _sf_ActorSlot[46]
	elseIf size == 47
		return new _sf_ActorSlot[47]
	elseIf size == 48
		return new _sf_ActorSlot[48]
	elseIf size == 49
		return new _sf_ActorSlot[49]
	elseIf size == 50
		return new _sf_ActorSlot[50]
	elseIf size == 51
		return new _sf_ActorSlot[51]
	elseIf size == 52
		return new _sf_ActorSlot[52]
	elseIf size == 53
		return new _sf_ActorSlot[53]
	elseIf size == 54
		return new _sf_ActorSlot[54]
	elseIf size == 55
		return new _sf_ActorSlot[55]
	elseIf size == 56
		return new _sf_ActorSlot[56]
	elseIf size == 57
		return new _sf_ActorSlot[57]
	elseIf size == 58
		return new _sf_ActorSlot[58]
	elseIf size == 59
		return new _sf_ActorSlot[59]
	elseIf size == 60
		return new _sf_ActorSlot[60]
	elseIf size == 61
		return new _sf_ActorSlot[61]
	elseIf size == 62
		return new _sf_ActorSlot[62]
	elseIf size == 63
		return new _sf_ActorSlot[63]
	elseIf size == 64
		return new _sf_ActorSlot[64]
	elseIf size == 65
		return new _sf_ActorSlot[65]
	elseIf size == 66
		return new _sf_ActorSlot[66]
	elseIf size == 67
		return new _sf_ActorSlot[67]
	elseIf size == 68
		return new _sf_ActorSlot[68]
	elseIf size == 69
		return new _sf_ActorSlot[69]
	elseIf size == 70
		return new _sf_ActorSlot[70]
	elseIf size == 71
		return new _sf_ActorSlot[71]
	elseIf size == 72
		return new _sf_ActorSlot[72]
	elseIf size == 73
		return new _sf_ActorSlot[73]
	elseIf size == 74
		return new _sf_ActorSlot[74]
	elseIf size == 75
		return new _sf_ActorSlot[75]
	elseIf size == 76
		return new _sf_ActorSlot[76]
	elseIf size == 77
		return new _sf_ActorSlot[77]
	elseIf size == 78
		return new _sf_ActorSlot[78]
	elseIf size == 79
		return new _sf_ActorSlot[79]
	elseIf size == 80
		return new _sf_ActorSlot[80]
	elseIf size == 81
		return new _sf_ActorSlot[81]
	elseIf size == 82
		return new _sf_ActorSlot[82]
	elseIf size == 83
		return new _sf_ActorSlot[83]
	elseIf size == 84
		return new _sf_ActorSlot[84]
	elseIf size == 85
		return new _sf_ActorSlot[85]
	elseIf size == 86
		return new _sf_ActorSlot[86]
	elseIf size == 87
		return new _sf_ActorSlot[87]
	elseIf size == 88
		return new _sf_ActorSlot[88]
	elseIf size == 89
		return new _sf_ActorSlot[89]
	elseIf size == 90
		return new _sf_ActorSlot[90]
	elseIf size == 91
		return new _sf_ActorSlot[91]
	elseIf size == 92
		return new _sf_ActorSlot[92]
	elseIf size == 93
		return new _sf_ActorSlot[93]
	elseIf size == 94
		return new _sf_ActorSlot[94]
	elseIf size == 95
		return new _sf_ActorSlot[95]
	elseIf size == 96
		return new _sf_ActorSlot[96]
	elseIf size == 97
		return new _sf_ActorSlot[97]
	elseIf size == 98
		return new _sf_ActorSlot[98]
	elseIf size == 99
		return new _sf_ActorSlot[99]
	elseIf size == 100
		return new _sf_ActorSlot[100]
	elseIf size == 101
		return new _sf_ActorSlot[101]
	elseIf size == 102
		return new _sf_ActorSlot[102]
	elseIf size == 103
		return new _sf_ActorSlot[103]
	elseIf size == 104
		return new _sf_ActorSlot[104]
	elseIf size == 105
		return new _sf_ActorSlot[105]
	elseIf size == 106
		return new _sf_ActorSlot[106]
	elseIf size == 107
		return new _sf_ActorSlot[107]
	elseIf size == 108
		return new _sf_ActorSlot[108]
	elseIf size == 109
		return new _sf_ActorSlot[109]
	elseIf size == 110
		return new _sf_ActorSlot[110]
	elseIf size == 111
		return new _sf_ActorSlot[111]
	elseIf size == 112
		return new _sf_ActorSlot[112]
	elseIf size == 113
		return new _sf_ActorSlot[113]
	elseIf size == 114
		return new _sf_ActorSlot[114]
	elseIf size == 115
		return new _sf_ActorSlot[115]
	elseIf size == 116
		return new _sf_ActorSlot[116]
	elseIf size == 117
		return new _sf_ActorSlot[117]
	elseIf size == 118
		return new _sf_ActorSlot[118]
	elseIf size == 119
		return new _sf_ActorSlot[119]
	elseIf size == 120
		return new _sf_ActorSlot[120]
	elseIf size == 121
		return new _sf_ActorSlot[121]
	elseIf size == 122
		return new _sf_ActorSlot[122]
	elseIf size == 123
		return new _sf_ActorSlot[123]
	elseIf size == 124
		return new _sf_ActorSlot[124]
	elseIf size == 125
		return new _sf_ActorSlot[125]
	elseIf size == 126
		return new _sf_ActorSlot[126]
	elseIf size == 127
		return new _sf_ActorSlot[127]
	elseIf size == 128
		return new _sf_ActorSlot[128]
	endIf
endFunction

_sf_ActorSlot[] function pushSlot(_sf_ActorSlot var, _sf_ActorSlot[] array) global
	int len = array.Length
	if len >= 128
		return array
	elseIf len == 0
		array = new _sf_ActorSlot[1]
		array[0] = var
		return array
	endIf

	_sf_ActorSlot[] pushed = slotArray(len + 1)
	pushed[len] = var
	while len
		len -=1
		pushed[len] = array[len]
	endWhile
	return pushed
endFunction

_sf_ActorSlot[] function removeSlot(_sf_ActorSlot var, _sf_ActorSlot[] array) global
	int len = array.Length
	if len <= 1
		return none
	endIf

	int cnt = len
	_sf_ActorSlot[] slots = ActorSlotArray(len - 1)
	while len
		len -=1
		if array[len] != var
			cnt -=1
			slots[cnt] = array[len]
		endIf
	endWhile
	return slots
endFunction

actor[] function actorArray(int size) global
	size = sslUtility.ValidateSize(size)
	if size == 1
		return new actor[1]
	elseIf size == 2
		return new actor[2]
	elseIf size == 3
		return new actor[3]
	elseIf size == 4
		return new actor[4]
	elseIf size == 5
		return new actor[5]
	elseIf size == 6
		return new actor[6]
	elseIf size == 7
		return new actor[7]
	elseIf size == 8
		return new actor[8]
	elseIf size == 9
		return new actor[9]
	elseIf size == 10
		return new actor[10]
	elseIf size == 11
		return new actor[11]
	elseIf size == 12
		return new actor[12]
	elseIf size == 13
		return new actor[13]
	elseIf size == 14
		return new actor[14]
	elseIf size == 15
		return new actor[15]
	elseIf size == 16
		return new actor[16]
	elseIf size == 17
		return new actor[17]
	elseIf size == 18
		return new actor[18]
	elseIf size == 19
		return new actor[19]
	elseIf size == 20
		return new actor[20]
	elseIf size == 21
		return new actor[21]
	elseIf size == 22
		return new actor[22]
	elseIf size == 23
		return new actor[23]
	elseIf size == 24
		return new actor[24]
	elseIf size == 25
		return new actor[25]
	elseIf size == 26
		return new actor[26]
	elseIf size == 27
		return new actor[27]
	elseIf size == 28
		return new actor[28]
	elseIf size == 29
		return new actor[29]
	elseIf size == 30
		return new actor[30]
	elseIf size == 31
		return new actor[31]
	elseIf size == 32
		return new actor[32]
	elseIf size == 33
		return new actor[33]
	elseIf size == 34
		return new actor[34]
	elseIf size == 35
		return new actor[35]
	elseIf size == 36
		return new actor[36]
	elseIf size == 37
		return new actor[37]
	elseIf size == 38
		return new actor[38]
	elseIf size == 39
		return new actor[39]
	elseIf size == 40
		return new actor[40]
	elseIf size == 41
		return new actor[41]
	elseIf size == 42
		return new actor[42]
	elseIf size == 43
		return new actor[43]
	elseIf size == 44
		return new actor[44]
	elseIf size == 45
		return new actor[45]
	elseIf size == 46
		return new actor[46]
	elseIf size == 47
		return new actor[47]
	elseIf size == 48
		return new actor[48]
	elseIf size == 49
		return new actor[49]
	elseIf size == 50
		return new actor[50]
	elseIf size == 51
		return new actor[51]
	elseIf size == 52
		return new actor[52]
	elseIf size == 53
		return new actor[53]
	elseIf size == 54
		return new actor[54]
	elseIf size == 55
		return new actor[55]
	elseIf size == 56
		return new actor[56]
	elseIf size == 57
		return new actor[57]
	elseIf size == 58
		return new actor[58]
	elseIf size == 59
		return new actor[59]
	elseIf size == 60
		return new actor[60]
	elseIf size == 61
		return new actor[61]
	elseIf size == 62
		return new actor[62]
	elseIf size == 63
		return new actor[63]
	elseIf size == 64
		return new actor[64]
	elseIf size == 65
		return new actor[65]
	elseIf size == 66
		return new actor[66]
	elseIf size == 67
		return new actor[67]
	elseIf size == 68
		return new actor[68]
	elseIf size == 69
		return new actor[69]
	elseIf size == 70
		return new actor[70]
	elseIf size == 71
		return new actor[71]
	elseIf size == 72
		return new actor[72]
	elseIf size == 73
		return new actor[73]
	elseIf size == 74
		return new actor[74]
	elseIf size == 75
		return new actor[75]
	elseIf size == 76
		return new actor[76]
	elseIf size == 77
		return new actor[77]
	elseIf size == 78
		return new actor[78]
	elseIf size == 79
		return new actor[79]
	elseIf size == 80
		return new actor[80]
	elseIf size == 81
		return new actor[81]
	elseIf size == 82
		return new actor[82]
	elseIf size == 83
		return new actor[83]
	elseIf size == 84
		return new actor[84]
	elseIf size == 85
		return new actor[85]
	elseIf size == 86
		return new actor[86]
	elseIf size == 87
		return new actor[87]
	elseIf size == 88
		return new actor[88]
	elseIf size == 89
		return new actor[89]
	elseIf size == 90
		return new actor[90]
	elseIf size == 91
		return new actor[91]
	elseIf size == 92
		return new actor[92]
	elseIf size == 93
		return new actor[93]
	elseIf size == 94
		return new actor[94]
	elseIf size == 95
		return new actor[95]
	elseIf size == 96
		return new actor[96]
	elseIf size == 97
		return new actor[97]
	elseIf size == 98
		return new actor[98]
	elseIf size == 99
		return new actor[99]
	elseIf size == 100
		return new actor[100]
	elseIf size == 101
		return new actor[101]
	elseIf size == 102
		return new actor[102]
	elseIf size == 103
		return new actor[103]
	elseIf size == 104
		return new actor[104]
	elseIf size == 105
		return new actor[105]
	elseIf size == 106
		return new actor[106]
	elseIf size == 107
		return new actor[107]
	elseIf size == 108
		return new actor[108]
	elseIf size == 109
		return new actor[109]
	elseIf size == 110
		return new actor[110]
	elseIf size == 111
		return new actor[111]
	elseIf size == 112
		return new actor[112]
	elseIf size == 113
		return new actor[113]
	elseIf size == 114
		return new actor[114]
	elseIf size == 115
		return new actor[115]
	elseIf size == 116
		return new actor[116]
	elseIf size == 117
		return new actor[117]
	elseIf size == 118
		return new actor[118]
	elseIf size == 119
		return new actor[119]
	elseIf size == 120
		return new actor[120]
	elseIf size == 121
		return new actor[121]
	elseIf size == 122
		return new actor[122]
	elseIf size == 123
		return new actor[123]
	elseIf size == 124
		return new actor[124]
	elseIf size == 125
		return new actor[125]
	elseIf size == 126
		return new actor[126]
	elseIf size == 127
		return new actor[127]
	elseIf size == 128
		return new actor[128]
	endIf
endFunction

actor[] function compressActorArray(actor[] array) global
	int idx = 0
	int cnt = 0
	
	idx = array.length
	while idx > 0
		idx -= 1
		if array[idx] != none
			cnt += 1
		endIf
	endWhile
	
	idx = array.length
	if cnt
		if cnt != idx
			actor[] this = _sf_utility.ActorArray(cnt)
			while idx > 0
				idx -= 1
				if array[idx] != none
					cnt -= 1
					this[cnt] = array[idx]
				endIf
			endWhile
			return this
		else
			return array
		endIf
	else
		return none
	endIf
endFunction

_sf_ActorSlot[] function compressSlotArray(_sf_ActorSlot[] array) global
	int idx = 0
	int cnt = 0
	
	idx = array.length
	while idx > 0
		idx -= 1
		if array[idx] != none
			cnt += 1
		endIf
	endWhile
	
	idx = array.length
	if cnt
		if cnt != idx
			_sf_ActorSlot[] this = _sf_utility.slotArray(cnt)
			while idx > 0
				idx -= 1
				if array[idx] != none
					cnt -= 1
					this[cnt] = array[idx]
				endIf
			endWhile
			return this
		else
			return array
		endIf
	else
		return none
	endIf
endFunction
