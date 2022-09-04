# fzyselect.vim
**fzyselect.vim** is a simple fuzzy selector plugin of Vim.

## Introduction
The `vim.ui.select` implemented in Neovim is simple but extensible.
There are also several well-designed extension plugins based on it
(e.g. [dressing.nvim](https://github.com/stevearc/dressing.nvim)).

This plugin is one such extensions. As a feature, it uses a built-in `matchfuzzy`
function to speed up the search process. Also, for the minimalists (or following the UNIX philosophy),
it has few extra functions, keymaps and commands as possible.

Vim does not have `vim.ui.select`, but this plugin is implemented in Vim scripts
(not Vim9 scripts), so you can use it in Vim as well as Neovim.

## Installation

[Plug.vim](https://github.com/junegunn/vim-plug)
```vim
Plug 'gw31415/fzyselect.vim'
```

[dein.vim](https://github.com/Shougo/dein.vim)
```vim
call dein#add('gw31415/fzyselect.vim')
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'gw31415/fzyselect.vim'
```

### For Neovim users: `vim.ui.select`
If you want to replace `vim.ui.select` with this plugin's,
you can directly assign the function `fzyselect.start`.

```lua
vim.ui.select = require 'fzyselect'.start
```

## Configuration Example

### Lines
Fuzzy search for lines of the current buffer.
```vim
nn gl <cmd>cal fzyselect#start(getline(1, '$'), {}, {_,i->i==v:null?v:null:cursor(i, 0)})<cr>
```

### Files
Fuzzy search for files of the working directory.
```vim
fu! s:glob(path)
	let li = []
	for f in readdir(a:path)
		let p = a:path .. '/' .. f
		if isdirectory(p)
			cal extend(li, s:glob(p))
		else
			cal add(li, p)
		en
	endfo
	return li
endfu
fu! s:edit(path) abort
	if a:path != v:null
		exe 'e ' .. a:path
	en
endfu
nn <c-p> <cmd>cal fzyselect#start(<SID>glob('.'), {}, {p-><SID>edit(p)})<cr>
```

### Buffers
Fuzzy switcher of buffers.
```vim
fu! s:buffer(i) abort
	if a:i != v:null
		exe 'b ' .. a:i
	en
endfu
nn <c-b> <cmd>cal fzyselect#start(
			\ filter(range(1, bufnr('$')), 'buflisted(v:val)'),
			\ #{format_item: {i->split(execute('ls!'), "\n")[i-1]}},
			\ {li-><SID>buffer(li)})<cr>
```
