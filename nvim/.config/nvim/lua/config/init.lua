---------------------------------------------
-- Bootstrap lazy.nvim plugin manager. 
-- 1. Clone repo `lazy.nvim.git` into `lazypath` directory: `$HOME/.local/share/nvim/lazy/lazy.nvim`.
-- 2. Add `lazypath` to runtimepath, so `require("lazy")` resolves to: `<lazypath>/lua/lazy`.
---------------------------------------------
require('config.lazy-bootstrap')

---------------------------------------------
-- Configure lazy.nvim Plugin Manager and Load Plugins.
-- See file for details.
---------------------------------------------
require('config.lazy-plugins')

---------------------------------------------
-- Options.
---------------------------------------------
require('config.options'

---------------------------------------------
-- Keymaps.
---------------------------------------------
require 'config.keymaps'

---------------------------------------------
-- Clone lazy.nvim plugin manager and add it to runtimepath.
---------------------------------------------
require 'config.lazy-bootstrap'

---------------------------------------------
-- Configure and install lazy.nvim plugins.
---------------------------------------------
require 'config.lazy-plugins'

