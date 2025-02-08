fu! s:bf()
	setl ma | %d _ | exe 'res ' .. min([len(b:ms), get(g:,'fzyselect_maxheight',10)])
	keepj cal setline(1, b:ms) | setl noma
endfu

fu! s:hi()
	cal filter(b:hi_ids,{_,v->matchdelete(v)*0}) | let hi = get(g:,'fzyselect_higroup','IncSearch')
	if !empty(b:pos)
		cal map(range(line('w0'),line('w$')), {_,l->map(copy(b:pos[l-1]),{_,c->add(b:hi_ids, matchaddpos(hi,[[l,byteidx(b:ms[l-1],c)+1]]))})})
	en
endfu

fu! s:pv(i)
	let [b:ms,b:pos;_] = empty(a:i) ? [b:li,[]] : get(g:,'fzyselect_match',function('matchfuzzypos'))(b:li, a:i)
	cal s:bf() | cal s:hi() | keepj cal cursor(0, 0) | redr " TODO: async or callback
endfu

fu! s:i()
	aug fzy | au CmdlineChanged <buffer> cal s:pv(getcmdline()) | aug END
	let b:i = input(get(g:, 'fzyselect_prompt', '>> '), b:i) | au! fzy
endfu

fu! fzyselect#getitem(lnum) abort
	retu {a->[b:dict[a], index(b:li,a)+1]}(getline(a:lnum))
endfu

fu! s:rt(cb)
	if empty(b:ms) | clo
	el
		let [a, wid] = [fzyselect#getitem('.'), b:wid]
		au! fzyesc | clo | sil! cal win_gotoid(wid)
		cal call(a:cb, a)
	en
endfu

fu! fzyselect#refresh(items) abort
	let [b:li, b:dict, b:pos, b:hi_ids] = [[], {}, [], []]
	for i in a:items
		let l = get(b:opts, 'format_item', {j->type(j)==1? j :string(j)})(i)
		cal add(b:li, l) | let b:dict[l] = i
	endfo
	let b:ms = b:li | cal s:bf() | sil! cal s:pv(b:i)
endfu

fu! fzyselect#start(items, opts, cb) abort
	if empty(a:items) | cal a:cb(v:null,v:null)
	el
		let wid = win_getid() | exe 'keepa '..get(g:,'fzyselect_opener','bo new')
		exec 'setl bt=nofile bh=wipe noswf ft=fzyselect stl='..substitute(fnameescape(get(a:opts,'prompt','Select')),'\\%','%%','g')
		let [b:opts, b:cb, b:i, b:wid] = [a:opts, a:cb, '', wid]
		cal fzyselect#refresh(a:items)
		aug fzyesc | au WinClosed <buffer> cal b:cb(v:null,v:null) | sil! cal win_gotoid(b:wid) | aug END
		au! WinScrolled <buffer> cal s:hi()
		nor <buffer> <Plug>(fzyselect-fzy) <cmd>cal <SID>i()<cr>
		nor <buffer> <Plug>(fzyselect-retu) <cmd>cal <SID>rt(b:cb)<cr>
	en
endfu
