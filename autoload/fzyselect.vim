fu! s:put()
	setl ma | %d _ | exe 'res ' .. min([len(b:ms), g:fzyselect_maxheight])
	keepj cal setline(1, b:ms) | setl noma
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

fu! s:pv(i)
	let [b:ms, b:pos; _] = empty(a:i) ? [b:li, []] : get(b:opts, "matchfuzzypos", {a1,a2->matchfuzzypos(a1, a2)})(b:li, a:i)
	cal s:put()
	cal s:hi()
	keepj cal cursor(0, 0)
	redr
endfu

fu! s:i()
	aug fzy | au CmdlineChanged <buffer> cal s:pv(getcmdline()) | aug END
	let b:i = input(g:fzyselect_prompt, b:i) | au! fzy
endfu

fu! fzyselect#getitem(lnum) abort
	let dp = getline(a:lnum)
	let i = index(b:li, dp)
	return [b:dict[dp], i + 1]
endfu

fu! s:rt(cb)
	if empty(b:ms) | clo
	el
		let [args, wid] = [fzyselect#getitem('.'), b:wid]
		au! fzyesc | clo | sil! cal win_gotoid(wid)
		cal a:cb(args[0], args[1])
	en
endfu

fu! fzyselect#refresh(items) abort
	let [b:li, b:dict, b:pos, b:hi_ids] = [[], {}, [], []]
	for i in a:items
		let l = get(b:opts, 'format_item', {j -> type(j) == 1 ? j : string(j)})(i)
		cal add(b:li, l) | let b:dict[l] = i
	endfo
	let b:ms = b:li | cal s:put()
	sil! cal s:pv(b:i)
endfu

fu! fzyselect#start(items, opts, cb) abort
	if empty(a:items)
		cal a:cb(v:null, v:null)
	el
		let wid = win_getid()
		exe 'keepa ' . g:fzyselect_opener | exec 'setl bt=nofile bh=wipe noswf ft=fzyselect stl='
					\.. substitute(fnameescape(get(a:opts, 'prompt', 'select one')), '\\%', '%%', 'g')
		let [b:opts, b:cb, b:i, b:wid] = [a:opts, a:cb, "", wid]
		cal fzyselect#refresh(a:items)
		aug fzyesc | au WinClosed <buffer> cal b:cb(v:null, v:null) | sil! cal win_gotoid(b:wid) | aug END
		au! WinScrolled <buffer> cal s:hi()
		nor <buffer> <Plug>(fzyselect-fzy) <cmd>cal <SID>i()<cr>
		nor <buffer> <Plug>(fzyselect-retu) <cmd>cal <SID>rt(b:cb)<cr>
	en
endfu
