if !exists('g:fzyselect_maxheight')
	let g:fzyselect_maxheight = 10
endif

if !exists('g:fzyselect_higroup')
	let g:fzyselect_higroup = 'IncSearch'
endif

if !exists('g:fzyselect_prompt')
	let g:fzyselect_prompt = '>>> '
endif

if !exists('g:fzyselect_opener')
	let g:fzyselect_opener = 'bo new'
endif

if !has('nvim') | finish | endif
lua<<EOF
package.preload['fzyselect'] = function()
	return {
		start = function(items, opts, on_choice)
			return vim.fn['fzyselect#start'](
				items, opts or {}, function(item, idx)
				if item == vim.NIL or idx == vim.NIL then
					on_choice(nil, nil)
				else
					on_choice(item, idx)
				end
			end)
		end
	}
end
EOF
