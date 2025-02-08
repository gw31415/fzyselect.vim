return setmetatable({}, {
	__index = function(_, key)
		return function(...) return vim.call('fzyselect#' .. key, ...) end
	end,
})
