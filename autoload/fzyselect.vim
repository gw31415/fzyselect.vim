let [s:label, s:dict] = [[], {}]

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
	aug fzy | au CmdlineChanged <buffer> cal s:pv(s:label) | aug END
	cal input('>>> ') | au! fzy
endfu

fu! s:cancel()
	let s:label = []
	cal s:on_choice(v:null, v:null)
	close
endfu

fu! s:enter()
	let dp = getline('.')
	let i = index(s:label, dp)
	let s:label = []
	close
	cal s:on_choice(s:dict[dp], i + 1)
endfu

fu! fzyselect#start(items, opts, on_choice)
	if empty(s:label)
		for i in a:items
			let l = get(a:opts, 'format_item', {j -> type(j)==v:t_string ? j : string(j)})(i)
			cal add(s:label, l) | let s:dict[i] = l
		endfo
		let s:on_choice = a:on_choice
		keepa bo 0new | setl bt=nofile bh=delete noswf | cal s:put(s:label)
		au WinClosed <buffer> cal s:cancel()
		nn <buffer><silent> i <cmd>cal <SID>fzy()<cr>
		nn <buffer><silent> <esc> <cmd>close<cr>
		nn <buffer><silent> <cr> <cmd>cal <SID>enter()<cr>
	en
endfu
