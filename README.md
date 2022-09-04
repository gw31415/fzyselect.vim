# fzyselect.vim
**fzyselect.vim** is a simple fuzzy selector plugin of Vim.

https://user-images.githubusercontent.com/24710985/188317718-5a136fd2-7f0f-4115-bb8f-cb34fd9605ec.mov


## Introduction
The `vim.ui.select` implemented in Neovim is simple and extensible.
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
you can directly assign the function `require 'fzyselect'.start`.

```lua
vim.ui.select = require 'fzyselect'.start
```

## How to use
Only one function `fzyselect#start` is provided
(two if you includes `require 'fzyselect'.start` exported for Lua).

You can use similar to `vim.ui.select`.
Please see [this document](https://neovim.io/doc/user/lua.html#vim.ui.select()).

### Vim Scripts
```vim
cal fzyselect#start(['apple', 'banana', 'chocolate'],
	\ {}, {i->append('.', i)})
```

### Lua
```lua
require 'fzyselect'.start({'apple', 'banana', 'chocolate'}, {},
	function(i)
		vim.fn.append('.', i)
	end)
```

On the split window that appears then you can use the usual keymaps you set up,
but two keymaps are added.

| mode | key  |    |
:---: | :---: | :---
| `n` | `i` | Start fuzzy search. |
| `n` | `<esc>` | Close the window. |


## Configuration Example

### Lines
Fuzzy search for lines of the current buffer.
```vim
nn gl <cmd>cal fzyselect#start(getline(1, '$'), {}, {_,i->i==v:null?v:null:cursor(i, 0)})<cr>
```
<img width="686" alt="image" src="https://user-images.githubusercontent.com/24710985/188313240-0d3e1ce5-401b-4798-a1a2-9c8e3eec0235.png">

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
<img width="686" alt="image" src="https://user-images.githubusercontent.com/24710985/188313286-7a065b36-950b-43cd-8c1a-837dfd902fca.png">


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
<img width="686" alt="image" src="https://user-images.githubusercontent.com/24710985/188313384-24b6f7c7-3d86-48a4-af72-c580755932f0.png">
