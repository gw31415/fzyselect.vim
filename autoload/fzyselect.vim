let [s:li, s:dict] = [[], {}]

fu! s:put(li)
	setl ma | %d | cal clearmatches() | exe 'res ' .. min([len(a:li), 8])
	keepj cal setline(1, a:li)
	setl noma
endfu

fu! s:pv(li)
	let input = getcmdline()
	if empty(input)
		cal s:put(a:li) | retu
	en
	let [ms, pos, _] = matchfuzzypos(a:li, input) | let mlen = len(ms)
	cal s:put(ms)
	for l in range(1, mlen)
		for c in pos[l-1]
			cal matchaddpos('IncSearch', [[l, byteidx(ms[l-1], c)+1]])
		endfo
	endfo
	keepj norm! gg
	redr
endfu

fu! s:i()
	aug fzy | au CmdlineChanged <buffer> cal s:pv(s:li) | aug END
	cal input('>>> ') | au! fzy
endfu

fu! s:esc()
	let s:li = []
	cal s:cb(v:null, v:null)
endfu

fu! s:cr()
	let dp = getline('.')
	let i = index(s:li, dp)
	let s:li = []
	au! fzyesc
	close
	cal s:cb(s:dict[dp], i + 1)
endfu

fu! fzyselect#start(items, opts, cb) abort
	if empty(s:li)
		for i in a:items
			let l = get(a:opts, 'format_item', {j -> type(j) == 1 ? j : string(j)})(i)
			cal add(s:li, l) | let s:dict[l] = i
		endfo
		let s:cb = a:cb
		keepa bo new | setl bt=nofile bh=delete noswf | cal s:put(s:li)
		aug fzyesc | au WinClosed <buffer> cal s:esc() | aug END
		nn <buffer> i <cmd>cal <SID>i()<cr>
		nn <buffer> <esc> <cmd>close<cr>
		nn <buffer> <cr> <cmd>cal <SID>cr()<cr>
	en
endfu
