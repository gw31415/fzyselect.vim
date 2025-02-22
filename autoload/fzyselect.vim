fu! s:ed()
	setl ma | exe '%d_ | res ' .. min([len(b:ms), get(g:,'fzyselect_maxheight',10)])
	keepj cal setline(1, b:ms) | doau TextChanged | setl noma
endfu
fu! s:hi()
	cal filter(b:hids,{_,v->matchdelete(v)*0}) | let hi = get(g:,'fzyselect_higroup','IncSearch')
	let _=empty(b:pos)||id(map(range(line('w0'),line('w$')),{_,l->map(copy(b:pos[l-1]),{_,c->add(b:hids,matchaddpos(hi,[[l,byteidx(b:ms[l-1],c)+1]]))})}))
endfu
fu! fzyselect#applyfz(...) abort
	let [b:ms,b:pos;_] = a:000
	cal s:ed() | cal s:hi() | cal cursor(1,empty(b:pos)?1:byteidx(b:ms[0],b:pos[0][0])+1) | redr
endfu
let s:fz = {i->empty(i)?fzyselect#applyfz(b:li,[]):get(g:,'fzyselect_match',{l,i->call('fzyselect#applyfz',matchfuzzypos(l,i))})(b:li,i)}
fu! fzyselect#input() abort
	aug fzy | au CmdlineChanged <buffer> cal s:fz(getcmdline()) | aug END
	let b:i = input(get(g:,'fzyselect_prompt','>> '), b:i) | au! fzy
endfu
fu! fzyselect#getitem(lnum='.') abort
	retu {a->has_key(b:dict,a)?[b:dict[a],index(b:li,a)+1]:v:null}(getline(a:lnum))
endfu
fu! fzyselect#cr(lnum='.') abort
	if empty(b:ms) | clo
	el
		let [a, wid, Cb] = [fzyselect#getitem(a:lnum), b:wid, b:cb]
		au! fzyesc | clo | sil! cal win_gotoid(wid)
		cal call(Cb, a)
	en
endfu
fu! fzyselect#swap(items) abort
	let [b:li, b:dict, b:pos, b:hids] = [[], {}, [], []]
	for i in a:items
		let l = get(b:opts, 'format_item', {j->type(j)==1? j :string(j)})(i)
		cal add(b:li, l) | let b:dict[l] = i
	endfo
	let b:ms = b:li | cal s:ed() | sil! cal s:fz(b:i)
endfu
fu! fzyselect#start(items, opts, cb) abort
	if empty(a:items) | cal a:cb(v:null,v:null)
	el
		let wid = win_getid() | exe 'keepa '..get(g:,'fzyselect_opener','bo new')
		exec 'setl bt=nofile bh=wipe noswf ft=fzyselect stl='..substitute(fnameescape(get(a:opts,'prompt','Select')),'\\%','%%','g')
		let [b:opts, b:cb, b:i, b:wid] = [a:opts, a:cb, '', wid]
		cal fzyselect#swap(a:items)
		aug fzyesc | au WinClosed <buffer> cal b:cb(v:null,v:null) | sil! cal win_gotoid(b:wid) | aug END
		au! WinScrolled <buffer> cal s:hi()
	en
endfu
