return {
	init = function()
		vim.ui.select = function(items, opts, on_choice)
			return vim.fn['fzyselect#start'](
				items, opts or {}, function(item, idx)
				if item == vim.NIL or idx == vim.NIL then
					on_choice()
				else
					on_choice(item, idx)
				end
			end)
		end
	end
}
