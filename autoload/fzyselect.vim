fu! s:put()
	setl ma | %d | exe 'res ' .. min([len(b:ms), g:fzyselect_maxheight])
	keepj cal setline(1, b:ms)
	setl noma
endfu

fu! s:hi()
	for id in b:hi_ids
		cal matchdelete(id)
	endfo
	let b:hi_ids = []
	if !empty(b:pos)
		for l in range(line('w0'), line('w$'))
			for c in b:pos[l-1]
				cal add(b:hi_ids, matchaddpos(g:fzyselect_higroup, [[l, byteidx(b:ms[l-1], c)+1]]))
			endfo
		endfo
	en
endfu

fu! s:pv()
	let input = getcmdline()
	if empty(input)
		let [b:ms, b:pos] = [b:li, []]
	el
		let [b:ms, b:pos, _] = matchfuzzypos(b:li, input)
	en
	cal s:put()
	cal s:hi()
	keepj cal cursor(0, 0)
	redr
endfu

fu! s:i()
	aug fzy | au CmdlineChanged <buffer> cal s:pv() | aug END
	cal input(g:fzyselect_prompt) | au! fzy
endfu

fu! s:rt(cb)
	if empty(b:ms) | clo
	el
		let dp = getline('.')
		let i = index(b:li, dp)
		let args = [b:dict[dp], i + 1]
		au! fzyesc
		clo
		cal a:cb(args[0], args[1])
	en
endfu

fu! fzyselect#start(items, opts, cb) abort
	if empty(a:items)
		cal a:cb(v:null, v:null)
	el
		keepa bo new | exec 'setl bt=nofile bh=delete noswf ft=fzyselect stl='
					\.. substitute(fnameescape(get(a:opts, 'prompt', 'select one')), '\\%', '%%', 'g')
		let [b:li, b:dict, b:cb, b:pos, b:hi_ids] = [[], {}, a:cb, [], []]
		for i in a:items
			let l = get(a:opts, 'format_item', {j -> type(j) == 1 ? j : string(j)})(i)
			cal add(b:li, l) | let b:dict[l] = i
		endfo
		let b:ms = b:li | cal s:put()
		aug fzyesc | au WinClosed <buffer> cal b:cb(v:null, v:null) | aug END
		au! WinScrolled <buffer> cal s:hi()
		nn <buffer> <Plug>(fzyselect-fzy) <cmd>cal <SID>i()<cr>
		nn <buffer> <Plug>(fzyselect-retu) <cmd>cal <SID>rt(b:cb)<cr>
	en
endfu
