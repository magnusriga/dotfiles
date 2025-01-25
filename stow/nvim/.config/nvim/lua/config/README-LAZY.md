==================================================================
`lazy.nvim`: How it handles multiple specs with same source.
==================================================================

- `plugin.meta.plugins[<name, e.g. short_url>] = { name = fragment.name, _ = frags = { <fragment.ids> } }`: One per plugin, i.e. one for all `snacks.nvim`.
- `plugin.meta.plugins[<name>]._frags[<index>] = fragment.id`: One per spec for given plugin, i.e. all `snacks.nvim` specs, indexed by normal incrementing integer.
- Config.plugins = Config.spec.plugins = plugin.meta.plugins. <-- `Loader.load()`.
- Each spec is accessible via a chain of metatables:
- - Config.plugin[<key>] <-- fragment.spec <-- fragment.spec <-- ...
- - One metatable per `fragment.spec` from `plugin._.frags`, aka. spec spec.
- When running `config` function from spec, `lazy.nvim` takes first `config` function it finds, when moving up metatable chain of specs.
- Also takes first it finds of priority, and other fields inside spec, except `opts`.
- Thus, only define _one_ `config` function.
- OK to define multiple `opts`, i.e. multiple specs with different `opts`, as those are
  merged right before passing in `opts` into `config` function, inside `Loader.config`,
  by calling `local opts = Plugin.values(plugin, "opts", false)`.
- `Plugin.values(..)` recursively calls itself down to last metatable, i.e. last spec.
- As recursion reverses back up metatable chain, `ret` equals `opts` from deeper spec,
  which is then merged with `opts` from current spec, all way to top spec, when
  `_values` returns tables of all spec's `opts`, for same plugin source, merged.
- Important: If `opts` is function, it is passed currently merged `opts` up to
  this point, as well as root plugin table, i.e. `values(root, ret)`, and `opts` function
  can choose if it merges parent `ret` into new options and returns new options,
  whatever options it returns becomes new options, which in turn will be merged with
  `opts` higher up reecursion chain.

- `opts_extend`:

  - Used to add`opts_extends` fields to list, aka. tabled with integer index,
    and add parents
  - Thus, each field in `opts_extend` is added to list, aka. integer indexed table,
    to `lists[key].list`, where `lists[key].path` is key split on `.`, and key is
    name of field in `opts_extend`.
  - Thus, `opts_extend` can contain same fields in multiple specs, without them overwriting each other.

  Thus, in summary:

  - If using `opts` as function, return merged `opts` with second argument,
    or loose arbitrary `opts` from table passed to `config` function.
  - Only `opts`, `cmd`, `event`, `ft`, and `keys`, are merged.
  - Thus, only define `config` function in ONE spec,
    if multiple same-source specs are defined.

==================================================================

Notes regarding require(<name>):

- Searches in “<runtimepath>/lua” for <name>, i.e. plugin’s <repo> name.
- Since all plugins’ plugin.dir are added to runtimepath, each plugin must contain the folder “/lua/<repo>”, in order for `require(<name>)` to work.

Notes regarding plugin’s `plugin` directory:

- All modules inside a plugin’s top-most plugin directory, at all levels, are sourced automatically by lazy.nvim.
- Thus, all modules inside `$HOME/.local/share/nvim/lazy/<repo>/plugin` are sourced automatically by lazy.nvim.
- Not also sourced by nvim

  - Even though all plugin directories (plugin.dir), e.g. `$HOME/.local/share/nvim/lazy/<repo>`, are added to runtimepath, and at nvim start all ‘plugin’ folders in runtimepath get all their modules, at any level, sourced.
  - Because, lazy.nvim turns off step 10 of nvim initialization, i.e. plugin sourcing.
  - See: https://lazy.folke.io/usage

- plugin.dir
  - Config.options.root/<plugin.name>,.
  - vim.fn.stdpath("data") .. "/lazy”/<repo_name>.
  - $HOME/.local/share/nvim/lazy/<repo_name>.

config()

- When “config(plugin, opts)” is called, it should call require(“<repo>”), which will look for <repo> inside all <runtimepath>/lua directories.
- All plugin repos are previously added to runtimepath, i.e. Config.options.root/<plugin.name>, e.g. vim.fn.stdpath("data") .. "/lazy”/<repo_name>, e.g. $HOME/.local/share/nvim/lazy/<repo_name>.
- Thus, require(“foo”) will look for “foo/init.lua” or “foo.lua” inside `$HOME/.local/share/nvim/lazy/<repo>/lua`.

==============================
Notes
==============================

- Installing an option, means to clone repo to Config.options.root/<repo> directory, e.g. $HOME/.local/share/nvim/lazy/<repo>.
- There is no concept of plugin being run.
- Instead, plugin specs are sourced, i.e. prlugin spec files are run, so that they can be added to Config.plugins (in special fragment form, but with full spec as parent, see below).
- Then, the plugin spec’s config(options, opts) is called, which calls `require(“<name>”).setup({ options })`.
- Loading an option, i.e. running it, means to call: `require(“<name>”).setup({ options })`.

==============================
STEPS
==============================
Loader.setup() - Install plugins, including those from import’s.

- Plugin.load()
  - Sets Config.plugins to table containing tables with fields like plugin name, url (full GitHub url), dependency names, etc.
  - Plugin.load() > parse > normalize ensures Config.spec.meta.plugins are set to all listed plugins from Config.options, i.e. user config, including those from import field.
  - For { import=“plugins” } first “<runtimepath>/lua/plugin” folder in runtimepath is used as root, and all .lua files at any level within is loaded.
    - At this point only our user config plugins folder is discoverable via runtimepath, non-of the lazy.nvim plugin.dir’s have been added to runtimepath yet, thus it re-runs Plugin.load() after all plugins have been installed (see install below).
    - As result, every module inside <runtimepath>/lua/<importedFolder> will be added to Config.plugins, and thus installed in the next step, after Plugin.load(), in Loader.setup().
  - Plugin being loaded, means to add resolved spec details to Config.plugins.
  - Plugin.load() assigns Config.spec.meta.plugins to Config.plugins.
  - In parse | resolve > rebuild > \_rebuild, Config.spec.meta.plugin’s metatable key \_\_index is set to metavalue super, which equals fragment.spec, which contains entire spec.
    - Thus, each lookup in plugin that cannot be found, will be looked up in full spec.
    - For instance, plugin.keys and plugin.events.
  - Important: rebuild also sets plugin.dir to Config.options.root/<plugin.name>, which is where plugin is installed and the path that later (Loader.startup) is added to runtimepath.
- Installing
  - Happens in Loader.setup, after Plugin.load().
  - First, Config.plugin.dir is set to Config.options.root/<plugin.name>, e.g. vim.fn.stdpath("data") .. "/lazy”/<repo_name>, e.g. $HOME/.local/share/nvim/lazy/<repo_name>.
  - git clone is run from manage > task > git.lua, where it uses plugin.dir as install directory.
  - After installing plugins, re-run Plugin.load(), so any import’s in specs of installed plugins are added to Config.plugins.

Loader.startup()

- Run Config.plugins[name].init(), for all plugins, passing in entire plugin, so it can access e.g. entire spec from its parent (entire spec table is metavalue of \_\_index metatable key of the metatable for Config.plugins).
  - plugins.url: Fully resolved url to github
  - plugins.dir: Full install path of plugin on local disk, based on Config.options.root (not yet added to runtimepath, that happens next).
  - plugins.name: Name of github repo, i.e. <repo> in <user>/<repo>.
- Source each “start” plugin, i.e. plugins which do not have Config.plugins[name].lazy set to true.
  1. Add each plugin.dir to runtimepath, e.g. `$HOME/.local/share/nvim/lazy/<repo_name>`.
  2. For every plugin, call vim cmd “source <plugin.dir>/plugin” on every module inside that “plugin” (note it is singular) directory.
     - Result: All plugins will need to place modules inside /plugin” to ensure they are sourced automatically by lazy.nvim.
     - LazyVim does not have `/plugin` directory, only `/lua/plugins` used via `{ import=“lazyvim.plugins” }`.
  3. Do the same for after/plugin: “source <plugin.dir>/after/plugin”.
     - 2 and 3 just executes the files, it does not call their setup functions inside <repo>/lua/<name>/init.lua.
     - As such, only handles some global setup done by modules inside plugin’s /plugins folder.
  4. Run Config.plugins[name].config(plugin, opts) for all plugins, including those from { import=“<name>” }, i.e. those in `<runtimepath>/lua/<name>`, starting with dependencies.
     - When “config(plugin, opts)” is called, it calls require(“<repo>”).setup({ options }), which will look for <repo> inside all <runtimepath>/lua directories.
     - All plugin repos are previously added to runtimepath, i.e. Config.options.root/<plugin.name>, e.g. vim.fn.stdpath("data") .. "/lazy”/<repo_name>, e.g. $HOME/.local/share/nvim/lazy/<repo_name>.
     - Thus, require(“<name>”) will look for “<name>/init.lua” or “<name>.lua” inside `$HOME/.local/share/nvim/lazy/<repo>/lua`, i.e. `$HOME/.local/share/nvim/lazy/<repo>/lua/<name>`.
     - For simplicity, <name> is usually equal to <repo>.
     - Result: Plugins must contain at top-level `/lua/<name>/init.lua, or /lua/<name>.lua`.
     - config function has a default form, which calls require(<repo>).setup({ options }).
     - Note regarding require(<name>): Searches in “<runtimepath>/lua” for <name>, i.e. plugin’s <repo> name, and since all plugins’ plugin.dir are added to runtimepath, each plugin must contain the folder “/lua/<repo>”, in order for `require(<name>)` to work.
- Source plugins from original rtp
  - For every runtimepath prior to adding plugins.dir, run “source <runtimepath>/plugin”.
  - Thus, all modules inside `$HOME/.config/nvim/plugin` is sourced.
- Source all modules inside <runtimepath>/after/plugin

==============================
Install Summary
==============================
For each plugin in spec, including those in directory from { import=“plugins” }, starting with their dependencies:

1. Source each `.lua` module in plugin’s top-level ‘/plugin’ directory.
2. Run plugin spec’s `config(plugin, opts)`, which calls `require(<name>).setup({ options })`, where `require(<name>)` resolves to plugin’s top-level `/lua/<name>.lua`OR `/lua/<name>/init.lua`.

==============================

Change linuxbrew vim.opt.rtp:appen in options.lua.
Actually , install fzf-lua instead.

Replace autocmd with persistence plugin.

How are starter keymapts etc loaded? Where should those folders be? In /lua/plugins, or in lua/config? Should be directly in lua, or in lua/config. But check lazy vim, it does something fancy in config/init.lua.

on_very_lazy (i.e. VeryLazy event):
Registeres auto command User with pattern VeryLazy, and passed in function.

Lazy.nvim repo is added to runtimepath, just so it is possible to call require(‘lazy’),
As lazy.nvim contains directory: lua/lazy…

When requiring plugins, they are found in .local/share/nvim/lazy/<plugin>/plugin

When modules in plugin directory are auto-loaded at nvim start, it sources all the files that are found, not just the firs.t

We say that files are sourced, meaning the lua code is executed.

Lazy.nvim adds every plugin folder, under `$HOME/.local/share/nvim/lazy/<plugin>` to runtimepath,
So it is possible to source modules from their lua subfolders, and so that all modules in its plugin subfolder are automatically sourced.

Sourced: Means lua code is executed.

`lua` and `plugin` directories must be directly within runtimepath directory, not nested at deeper level.
`.lua` or `.vim` files within plugin directory may be at any level, they are all automatically sourced at nvim startup.

lazy.nvim overwrites rtp to include its own root path, so add to config any rtp to keep.

Plugins are sourced alphabetically per plugin directory.

Root is where plugins are downloaded to, and each plugin dir is added to rtp.
Lazypath is just where lazy.nvim is stored, and it is added manually to rtp and required from there.

If root does not match rtp

Every time nvim starts it clones lazy.nvim repo, adds lazypath to rtp, then overwrites it rtp to include lazy path again, as well as root path where plugins will be stored.

When setup runs first time it is passed opts, and opts.spec is set to spec or to entire first argument.

Then we require a config object. Then we set some of the values in that config object.

When object is later sourced, we get cached value, but with updated properties?
Now, Config.options.spec holds table with all spec sub-tables. Installing means downloading to root folder.
Loading means …. Figure out hen they run, then move on.

loadeer.startup adds all plugins from spec to rtp and runs config(plugin). We are passing in entire plugin, which is actually spec for that plugin inc opt property, dependencies, etc.

We need utils of our own, to register formatters, etc.

- Config.setup
  - Sets Config.options to merge of config.defaults and passed in, I.e. user defined, options.
  - If Config.options.spec is plain string, sets Contig.options.spec to { import = config.options.string }.
  - Creates config.root directory.
  - Replaces rtp with:
    - stdpath(config)
    - stdpath(data)/site
    - Path of cloned ‘lazy.nvim’, I.e. lazypath, saved as Config.me
    - $VIMRUNTIME, which contains various built-in rtps,
    - <path to nvim program>/lib <— Uses actual location: /usr/local/stow/neovim/bin/nvim.
    - stdpath(config)/after
    - config.performance.rtp.paths, if defined.
    - config.readme.root
  - Create UIEnter autocommand, running stats
  - Create User autocommand, for pattern LazyDone, and User autocommand for pattern VeryLazy, which reloads nvim and checks for updates upon LazyDone > UIEnter.

Adding plugin to runtimepath

- Happens in Loader.startup > load(plugin, ..) > \_load > add_to_rtp(plugin), which loops through Config.plugins and adds plugins.dir.
- plugin.dir === Config.options.root/<plugin.name>, e.g. vim.fn.stdpath("data") .. "/lazy”/<repo_name>, e.g. $HOME/.local/share/nvim/lazy/<repo_name>.

Config.spec is set to new empty table, with empty Spec table as metatable.
Config.spec.meta is set to new table, with metastable as empty table with metavale of \__index as Meta object, so when indexing Config.spec.meta and not finding a match, it looks in Meta table returned from meta.lua.
Config.spec.meta.fragments.spec = Config.spec.meta.spec = Config.spec, i.e. the original Spec:new() table, and that table has access to .normalize via its parent, which is the Spec object.
Config.spec.plugins: Does not exist, so is found on parent Config.spec.meta.plugins (see \_index routing to meta) = Table indexed by fragment.name, which is last part of url, I.e. <repo>, and initially contains { name = fragment.name, _ = { frags = { id1, id2, etc.. } } }.

- Will be updated later, at parse > resolve > rebuild, see below.
- Config.plugins = Config.spec.plugins, set in Plugin.load(), after parse.
  Config.spec.meta.fragments = New empty table, containing e.g. fragments and plugins properties.
- Config.spec.meta.fragments.plugins = Table indexed by spec table, containing id of each plugin (aka. spec table), which is a static number \_fid added to fragments metatable, which starts at 0 and increments by 1 every time a plugin (spec) is added.
- Config.spec.meta.fragments.specs = Table used indexed by spec table, containing id of each plugin
- Config.spec.meta.fragments.fragments = Table indexed by same \_fid as plugins, one for each spec added, containing: fragment = {
  id = id,
  pid = pid,
  name = plugin.name,
  url = plugin.url,
  dir = plugin.dir,
  spec = plugin --[[@as LazyPlugin]],
  }
  - Thus, for each spec, including all dependencies, we add an entry into Config.spec.meta.fragments.fragments table.
  - If first entry in plugin table, aka. plugin[1], aka. spec table, is string with slash, I.e. git short url <user>/<repo> or full git url, then fragment.url is set to that string.
  - If first spec entry is short url, i.e. does not contain http or git@, it is expanded with Config.options.git.url_format.
  - fragment.name is set to last part of url, i.e. <repo>.
  - Add all dependencies to same fragments table.

Config.plugins = Config.spec.plugins = Config.spec.meta.plugins = {
name = {
name = fragment.name <— Name of plugin repo, in <user>/<repo> GitHub url.
\_ = {
frags = { fragment.id }
installed = If plugins.dir, i.e. local plugin directory, is within Config.options.root, set installed to true. It does not look for repo installed plugins.
}
url = Single string containing full GitHub url
dependencies = fragment.dependencies = Table containing repo names of all dependencies.
lazy = true if any of the lazy conditions are met, i.e. spec contains keys | events | ft | cmd, or Config.options.defaults.lazy is true.
}
}

- Important: metatable for Config.plugins[name] holds full spec table in \_\_index, thus any field in spec is available on Config.plugins[name].
- Where name is name of GitHub <repo>.
- normalize ensures an entry is made in Config.spec.meta.plugins table for every single spec in lazy.nvim.
- Plugins.load() > Config.spec.parse, we run resolve, which will first normalize, then go through every added plugin in above plugins table and run resolve > rebuild,
  which adds to each entry in Config.spec.meta.plugins:
- url: fragment.url = Single string containing full GitHub url
- dependencies: fragment.dependencies = Table containing repo names of all dependencies.

Then, Plugin.load > Plugin.update_state, which updates install state by looking for <repo>, i.e. plugin name.:

- \_.installed: checks if plugin, if local dir, is within Config.options.root, to determine if it is installed. It does not look for repo.

- lazy: true if any of the lazy conditions are met.

- Plugin.load will
  1. Create

Then, next in normalize, handle import specs, which executes every module from root and down to leafs, where root is

Config.spec.modules = ….

Config.spec.meta:load_pkgs() does not do anything, as Pkg.get() returns empty Pkg.cache.

Runs Config.spec:parse(specs), where specs is entire specs table from config.options.spec, containing several spec tables.

- Spec:normalize(spec), where spec is that full specs table.
  - If entire specs table is just a plain string. i.e. { specs = ‘string’ }, then:
    -
  - If specs table contains list of other tables or strings, as opposed to being just one spec with key-value pairs, like spec.dir | spec.url and others, recursively call normalize for every containing spec.
  - Normalize(spec)
    - For each containing spec, within larger specs table, call Config.spec.meta:add(that_single_spec).
      - Config.spec.meta:add(that_single_spec)
        - Calls Config.spec.meta.fragments:add(that_single_spec), where that_single_spec is referred to as the variable “plugin”

Config.spec.meta.fragments = N

is_list: Table is list if it only contains values not key-value pairs: { {…}, {…}, … } and { ‘foo’, ‘bar’, … }

Require in nvim is set up, perhaps by setting lua’s package.path to <runtimepath>/lua/\*\*/?.lua

What does config.spec.meta.plugins contain? See Meta:add, seems it just contains:
{ name = fragment.name, \_ = { frags = { id1, id2, etc.. } } }

Search pattern: /lua/plugins.lua and /lua/plugins

Topmod is just mod name, as mod name contains no dot.
Loader.\_rpt table (list) is filled with runtime paths.
Loops through runtimepaths and tries to find plugins.lua or plugins

Inside runtimpath/lua/\*

Loader.\_indexed.<runtimepath>.<dorOrFileName>

Lsmod returns list of all files|directories inside runtimepath/lua { fileOrFolderNameWithoutExt = {modpath = <rtp>/lua/<entry>, modname=<fileOrFolderNameWithoutExt> }
Then \_find checks if that contains “plugins” entry

{ import = “plugins” }
Thus import looks for plugins.lua file, and then plugins directory, inside all runtimepath/lua, stopping when first is found,
Then calls the spec function to get the spec table, then adds that to full Config.plugins (via fragments in normalize etc), alongside all other plugin specs.
Will always find my own config first as user config comes first in runtimepath.
It does not consider the rest of spec, thus if it is desired to find specific plugins folder, in case position in runtimepath is nondeterministic, use an extra folder inside /lua, e.g. <runtimepath>/lua/<myPlugin>/plugins (that is what LazyVim does).
Own “plugins” folder, i.e. the string used for import, is pre-populated with our own spec definitions, and it is in runtimepath `$HOME/.config/nvim`,
so plugins folder is found in `$HOME/.config/nvim/lua/plugins`, and all modules within `$HOME/.config/nvim/lua/plugins` run, so the plugin specs they return are added to Config.plugins.
In the case of external plugin’s imports, Plugin.load > parse > normalize > import > Utils.lsmod > find_root > get_unloaded_rtp : Returns Config.plugins[name].dir as unloaded rtp table,
and all those plugin.dir’s were added to Config.plugins[name] during normalize,
however the folders are not populated, i.e. git clone, until after Plugin.load, duirng the subsequent step install_missing, thus at end of install_missing Plugin.load() re-runs,
meaning { import=“lazyvim.plugins” } results in e.g. all modules in the first found `<runtimepath>/lua/lazyvim/plugins` to run and be added to Config.plugins.

topmod: lazynvim
modname: plugins
normname removes extensions .nvim .vim .lua, and digits.

========================
LazyVim
========================

---

## LazyNvim starter sequence

1. LazyVim starter's `require("lazy").setup(...)` adds plugins for:
   - "LazyVim/LazyVim".
   - `{ import="lazyvim.plugins" }`.
   - `{ import="plugins" }`.
2. Install LazyVim plugin and all plugins defined in other specs above, and their dependencies.
   - Including specs added via `{ import=“lazyvim.plugins” }`,
     i.e. specs in all moudles inside `<runtimepath>/lua/lazyvim/plugins/*`,
     which it only finds in: `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/plugins/*`,
     and specs added via `{ import=“plugins” }`,
     i.e. specs in all modules inside `<runtimepath>/lua/plugins/*`,
     which it only finds in: `$HOME/.config/nvim/lua/plugins/*`.

For each plugin:

- Run init() function.
- Defined in plugin spec.

For each start plugin:
(do below steps for plugin's dependencies, then for plugin itself)

1. Add plugin directory to runtimepath.
2. Source each `.lua` module in each plugin’s top-level `/plugin` and `/after/plugin` directories.
   - lazyvim does not contain top-level `/plugin` or `/after/plugin` directory.
   - Other plugin directories might.
3. Run `config(plugin, opts)`,
   which calls `require("<name>").setup( opts )`,
   where `require("<name>") resolves to `<runtimepath>/lua/<name>/config/init.lua`,
meaning `<name>` should be unique across all plugin directories,
   since they are all added to runtimepath,

   - `require("lazyvim").setup( opts )`.

     - `require("lazyvim")` resolves to `<runtimepath>/lua/lazyvim/config/init.lua`,
       which it only finds in: `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/config/init.lua`.
     - Runs:
       - `require(‘lazyvim.config.autocmd’)`
       - `require(‘lazyvim.config.keymap’)`
       - `require(‘lazyvim.config.options’)`
     - These modules are found in `/lua` directory of lazyvim plugin directory,
       which was added to runtimepath by lazy.nvim,
       e.g. `$HOME/.local/share/nvim/lazy/lazyvim/lua/lazyvim/config/options`.
     - `require("lazyvim").setup( opts )` then follows the same process for user's own config: same for
       - `require(‘config.autocmd’)`
       - `require(‘config.keymap’)`
       - `require(‘config.options’)`
     - These modules are found in `/lua` directory of user's own config directory,
       which is always in runtimepath,
       e.g. `$HOME/.config/nvim/lua/config/options`.
     - That way, user config for ‘options’, ‘autocmds’, and ‘keymaps’,
       overwrite lazyvim’s files with same name.
     - Note: Since we do not use LazyVim, skip their options.

   - `{ import="lazyvim.plugins" }`

     - Runs `config(plugin, opts)` for every plugin spec,
       in all modules, at any level, within `$HOME/.local/share/nvim/lazy/lazynvim/lua/plugins`.
     - Which calls `require("<name>").setup( opts )` for each plugin,
       where `require("<name>")` resolves to
       `<runtimepath>/lua/<name>.lua | /<name>/init.lua`,
       where name should be unique across all plugin directories (added to runtimepath),
       so it resolves to `$HOME/.local/share/nvim/lazy/<repo>/lua/<name>.lua | /<name>/init.lua`.

   - `{ import="plugins" }`
     - Runs `config(plugin, opts)` for every plugin spec,
       in all modules, at any level, within `$HOME/.config/nvim/lua/plugins`.
     - See steps above.

VeryLazy

- LazyDone fires after lazy.nvim’s setup is done, i.e. all plugins installed and config(plugin, opts) functions have run, i.e. after calling require(<repo>).setup({ … })
- VeryLazy autcomd is called when LazyDone autocmd fires, earliest directly after UIEnter, i.e. when all windows and buffers have been created, and nvim startup sequence is done.
- UIEnter fires after vim UI is ready, directly after VimEnter.
- VimEnter fires after vim startup is done.
- VeryLazy autocmd is defined in Util.very_lazy(), called at beginning of lazy.vim’s setup, i.e. at end of Config.setup().

========================
Looking up plugin modules
========================
cache find only finds module in <runtimepath>/lua/\*, not in nested folders.
When looking for plugin foo.bar, find looks for <runtimepath>/lua/bar, and not foo, because <runtimepath> includes the foo directory when foo is <repo>, i.e. plugin name.
Thus, when running require(‘lazy.core.cache’).find(“foo.bar”), search is done for `<runtimepath>/lua/foo`, and if found, it tries to stat `<runtimepath>/lua/foo/bar.lua | /bar/init.lua`, i.e. `$HOME/.local/share/nvim/lazy/foo/lua/foo/bar.lua | bar/init.lua`
With find(“foo”), search is done in `<runtimepath>/lua/foo.lua | foo/init.lua` i.e. `$HOME/.local/share/nvim/lazy/foo/lua/foo.lua | foo/init.lua`.
This is the same as what require would have done, but use lazy.nvim `find` first to avoid error when require module that does not exist.

Problem: I need to load lazyvim > config > init.lua before I load my own plugins, but after lazy.nvim has bootstrapped.
perhaps just require(config.init).setup(), or M.setup(), after bootstrap before requie(lazy).
