let s:orig = []

fu! s:put(list)
	setl ma | %d | cal clearmatches() | exe 'res ' .. min([len(a:list), 8])
	keepj cal setline(1, a:list)
	setl noma
endfu

fu! s:pv(list)
	let input = getcmdline()
	if empty(input)
		cal s:put(a:list) | retu
	en
	let [ms, pos, _] = matchfuzzypos(a:list, input) | let mlen = len(ms)
	cal s:put(ms)
	for l in range(1, mlen)
		for c in pos[l-1]
			cal matchaddpos('IncSearch', [[l, byteidx(ms[l-1], c)+1]])
		endfo
	endfo
	keepj norm! gg
	redr
endfu

fu! s:fzy()
	aug fzy | au CmdlineChanged <buffer> cal s:pv(s:orig) | aug END
	cal input('>>> ') | au! fzy
endfu

fu! fzyselect#start(list)
	if empty(s:orig)
		keepa bo 0new | setl bt=nofile bh=delete noswf | cal s:put(a:list)
		let s:orig = a:list | au WinClosed <buffer> let s:orig = []
		nn <buffer><silent> i <cmd>cal <SID>fzy()<cr>
		nn <buffer><silent> <esc> <cmd>close<cr>
	en
endfu
