let g:fzyselect_maxheight = 10

let g:fzyselect_higroup = 'IncSearch'

let g:fzyselect_prompt = '>>> '

if !has('nvim') | finish | endif
lua<<EOF
package.preload['fzyselect'] = function()
	return {
		start = function(items, opts, on_choice)
			local winid = vim.api.nvim_get_current_win()
			return vim.fn['fzyselect#start'](
				items, opts or {}, function(item, idx)
				vim.api.nvim_set_current_win(winid)
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
