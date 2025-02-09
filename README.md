# fzyselect.vim
**fzyselect.vim** is a simple fuzzy selector plugin of Vim.

https://user-images.githubusercontent.com/24710985/188317718-5a136fd2-7f0f-4115-bb8f-cb34fd9605ec.mov


## Introduction
The `vim.ui.select` implemented in Neovim is simple and extensible.
There are also several well-designed extension plugins based on it
(e.g. [dressing.nvim](https://github.com/stevearc/dressing.nvim)).

This plugin is one such extensions. As a feature, it uses a built-in `matchfuzzypos`
function to speed up the search process (you can even customize the function if you wish).

Also, for the minimalists (or following the UNIX philosophy),
it has few extra functions, keymaps and commands as possible.
Also, the source code is very small, too. See [the main code](./autoload/fzyselect.vim).

You can use this plugin in Vim as well as Neovim. Except exporting code for Lua,
the all of this plugin is written in only Vim scripts (not Vim9 scripts).

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

### Key mappings
No default keymaps are provided.

#### Vim Scripts
```vim
fu! s:fzy_keymap()
	nmap <buffer> i <cmd>cal fzyselect#input()<cr>
	nmap <buffer> <cr> <cmd>cal fzyselect#cr()<cr>
	nmap <buffer> <esc> <cmd>clo<cr>
endfu
au FileType fzyselect cal <SID>fzy_keymap()
```

#### Lua
```lua
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'fzyselect',
	callback = function ()
		vim.keymap.set('n', 'i', require 'fzyselect'.input, { buffer = true })
		vim.keymap.set('n', '<cr>', require 'fzyselect'.cr, { buffer = true })
		vim.keymap.set('n', '<esc>', '<cmd>clo<cr>', { buffer = true })
	end
})
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

On the split window that appears then you can use the usual keymaps you set up.
To operate fuzzy selecting, you need to call functions below:

| Vim Function        | Lua Function        | Usage                |
| ------------------- | ------------------- | -------------------- |
| `fzyselect#input()` | `fzyselect.input()` | Launch fuzzy search. |
| `fzyselect#cr()`    | `fzyselect.cr()`    | Select the item.     |

## Configuration Example
### Lines
Fuzzy search for lines of the current buffer.

```vim
nn gl <cmd>cal fzyselect#start(getline(1, '$'), #{prompt:'Fuzzy search'}, {_,i->i==v:null?v:null:cursor(i, 0)})<cr>
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
If you use Neovim, use [bufmanager.nvim](https://github.com/gw31415/bufmanager.nvim). Below is simpler version.

```vim
fu! s:buffer(i) abort
	if a:i != v:null
		exe 'b ' .. a:i
	en
endfu
nn B <cmd>cal fzyselect#start(
			\ filter(range(1, bufnr('$')), 'buflisted(v:val)'),
			\ #{prompt:'Select buffer',format_item:{i->split(execute('ls!'), "\n")[i-1]}},
			\ {li-><SID>buffer(li)})<cr>
```

<img width="686" alt="image" src="https://user-images.githubusercontent.com/24710985/188313384-24b6f7c7-3d86-48a4-af72-c580755932f0.png">
