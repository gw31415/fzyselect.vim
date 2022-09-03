let s:orig = []

fu! s:put(list) abort
	setl ma | %d | cal clearmatches() | exe 'res ' .. min([len(a:list), 8])
	keepj cal setline(1, a:list)
	setl noma
endfu

fu! s:pv(list) abort
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
endfu

fu! s:fzy()
	aug fzy | au! CmdlineChanged <buffer> cal s:pv(s:orig) | aug END
	cal input('>>> ') | au! fzy
endfu

fu! fzyselect#start(list) abort
	if empty(s:orig)
		keepa bo 0new | setl bt=nofile bh=delete noswf | cal s:put(a:list)
		let s:orig = a:list | au WinClosed <buffer> let s:orig = []
		nn <buffer><silent> i <cmd>cal <SID>fzy()<cr>
		nn <buffer><silent> <esc> <cmd>close<cr>
	endif
endfu
