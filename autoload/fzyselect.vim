let [s:li, s:dict] = [[], {}]

fu! s:put(li)
	setl ma | %d | cal clearmatches() | exe 'res ' .. min([len(a:li), g:fzyselect_maxheight])
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
			cal matchaddpos(g:fzyselect_higroup, [[l, byteidx(ms[l-1], c)+1]])
		endfo
	endfo
	keepj cal cursor(0, 0)
	redr
endfu

fu! s:i()
	aug fzy | au CmdlineChanged <buffer> cal s:pv(s:li) | aug END
	cal input(g:fzyselect_prompt) | au! fzy
endfu

fu! s:esc()
	let s:li = []
	cal s:cb(v:null, v:null)
endfu

fu! s:rt()
	let dp = getline('.')
	let i = index(s:li, dp)
	let s:li = []
	au! fzyesc
	clo
	cal s:cb(s:dict[dp], i + 1)
endfu

fu! fzyselect#start(items, opts, cb) abort
	if empty(a:items) || !empty(s:li)
		cal s:esc()
	el
		for i in a:items
			let l = get(a:opts, 'format_item', {j -> type(j) == 1 ? j : string(j)})(i)
			cal add(s:li, l) | let s:dict[l] = i
		endfo
		let s:cb = a:cb | echo get(a:opts, 'prompt', 'Select one')
		keepa bo new | setl bt=nofile bh=delete noswf ft=fzyselect | cal s:put(s:li)
		aug fzyesc | au WinClosed <buffer> cal s:esc() | aug END
		nn <buffer> <Plug>(fzyselect-fzy) <cmd>cal <SID>i()<cr>
		nn <buffer> <Plug>(fzyselect-retu) <cmd>cal <SID>rt()<cr>
	en
endfu
