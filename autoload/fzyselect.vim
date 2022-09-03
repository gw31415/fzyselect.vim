fu! s:put(list) abort
	setl ma | %d | cal clearmatches() | exe 'res ' .. min([len(a:list), 8])
	keepj cal setline(1, a:list)
	setl noma
endfu

fu! s:pv(list) abort
	if getcmdtype() == '@'
		let input = getcmdline()
		if empty(input)
			cal s:put(a:list) | retu
		en
		let [match, chars, _] = matchfuzzypos(a:list, input) | let mlen = len(match)
		cal s:put(match)
		for l in range(1, mlen)
			for c in chars[l-1]
				cal matchaddpos('IncSearch', [[l, byteidx(match[l-1], c)+1]])
			endfo
		endfo
		keepj norm! gg
		redr
	en
endfu

fu! fzyselect#start(list) abort
	keepa bo 0new | setl bt=nofile bh=delete noswf | cal s:put(a:list)
	let s:list = a:list
	au! CmdlineChanged <buffer> cal s:pv(s:list)
	nn <buffer><silent> i <cmd>cal input('>>> ')<cr>
	nn <buffer><silent> <esc> <cmd>close<cr>
endfu
