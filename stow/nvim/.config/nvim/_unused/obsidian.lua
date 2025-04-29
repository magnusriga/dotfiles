-- ======================================
-- Obsidian Notes.
-- ======================================
-- - Use workspace path that is synchronized to cloud automatically,
--   e.g. `Documents/Notes/vaults/personal` and `Documents/Notes/vaults/work`.
-- - Use community git plugin to backup workspaces to git repositories every hour,
--   e.g. `obsidian-vault-personal` and `obsidian-vault-work`.
-- - Obsidian community plugins: `git` | `relative-line-numbers`.
-- - Bind mount workspace paths to Linux VM | Docker container, where development is done.

return {
  {
    "obsidian-nvim/obsidian.nvim",
    -- Use latest release instead of latest commit.
    version = "*",
    lazy = true,
    ft = "markdown",
    -- Can replace `ft` with specific paths, e.g. to only load `obsidian.nvim` for markdown
    -- files in obsidian vault, and not for all markdown files.
    -- event = {
    --   -- To use `~`: `vim.fn.expand`.
    --   -- Examples:
    --   -- - `"BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"`.
    --   -- - See: `:h file-pattern`.
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
    },
    opts = {
      -- - Workspace names and paths.
      -- - `path`: Vault root from Obsidian app, i.e. parent of `.obsidian` directory.
      -- - When loaded, `obsidian.nvim` automatically sets workspace to first workspace below,
      --   whose `path` is parent of current markdown file being edited.
      -- - Commonly, workspace corresponds to one vault.
      -- - Can configure workspace that doesn't correspond to vault.
      -- - Can configure multiple workspaces for single vault,
      --   used to segment single vault into multiple directories,
      --   with different settings applied to each directory.
      -- - Dynamic workspaces are supported, where `path` is Lua function returning absolute path,
      --   e.g. `path = vim.fn.expand("~/vaults/work")`,
      --   often used to set workspace path to parent directory of current buffer:
      --   `path = function() return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0))) end`,
      --   or to use `obsidian.nvim` on files outside Obsidian vaults.
      workspaces = {
        {
          name = "personal",
          path = "~/notes/vaults/personal",
        },
        {
          name = "work",
          path = "~/notes/vaults/work",
          -- Override global settings, for this workspace only.
          -- overrides = {
          --   notes_subdir = "notes",
          -- },
        },
        -- Using `obsidian.nvim` on markdown files outside of Obsidian vaults.
        -- - `path`: Parent directory of current markdown buffer.
        -- - Tells `obsidian.nvim` to use that directory as workspace path and root (vault root),
        --   when buffer is not located inside another fixed workspace.
        -- - Now, when entering markdown buffer outside fixed vaults above,
        --   `obsidian.nvim` switches to dynamic workspace with path / root
        --   set to parent directory of current buffer.
        {
          name = "no-vault",
          path = function()
            -- Alternatively, use CWD: `assert(vim.fn.getcwd())`.
            return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
          end,
          overrides = {
            -- Must use `vim.NIL`, not `nil`.
            notes_subdir = vim.NIL,
            new_notes_location = "current_dir",
            templates = {
              folder = vim.NIL,
            },
            disable_frontmatter = true,
          },
        },
      },

      -- For backwards compatibility, can set `dir` to single path, instead of `workspaces`.
      -- Example: `dir = "~/vaults/work"`.

      -- If notes are kept in subdirectory of vault.
      -- This will create new notes in given subdirectory.
      -- notes_subdir = "notes",

      -- - Log level for `obsidian.nvim`.
      -- - Integer from: `vim.log.levels.*`.
      -- log_level = vim.log.levels.INFO,

      -- Configuration of daily notes.
      daily_notes = {
        -- If daily notes kept in separate directory.
        -- folder = "notes/dailies",
        folder = "_daily-notes",

        -- To change date format for ID of daily notes.
        -- date_format = "%Y-%m-%d",

        -- To change date format of default alias of daily notes.
        -- alias_format = "%B %-d, %Y",

        -- Default tags to add to each new daily note created.
        default_tags = { "daily-notes" },

        -- To automatically insert template from template directory, like `daily.md`.
        template = nil,
      },

      -- Completion of: Wiki links, local markdown links, tags.
      completion = {
        -- Enables completion using `nvim_cmp`.
        -- Default: `true`.
        -- nvim_cmp = true,
        nvim_cmp = false,

        -- Not working in `epwalsh/obsidian.nvim`, only in fork `obsidian-nvim/obsidian.nvim`.
        -- `obsidian-nvim/obsidian.nvim` and `epwalsh/obsidian.nvim` are pretty
        -- much the same, both slow on Obsidian completions and serves duplicate comnpletion items.
        blink = true,

        -- Trigger completion at `x` chars.
        -- Default: `2`.
        min_chars = 2,
      },

      -- Default key mappings.
      -- mappings = {
      --   -- Overrides `gf` mapping, to work on markdown/wiki links within vault.
      --   ["gf"] = {
      --     action = function()
      --       return require("obsidian").util.gf_passthrough()
      --     end,
      --     opts = { noremap = false, expr = true, buffer = true },
      --   },
      --   -- Toggle check-boxes.
      --   ["<leader>ch"] = {
      --     action = function()
      --       return require("obsidian").util.toggle_checkbox()
      --     end,
      --     opts = { buffer = true },
      --   },
      --   -- Smart action depending on context: Follow link | show notes with tag | toggle checkbox.
      --   ["<cr>"] = {
      --     action = function()
      --       return require("obsidian").util.smart_action()
      --     end,
      --     opts = { buffer = true, expr = true },
      --   }
      -- },

      -- Where to put new notes.
      -- - `current_dir` : Put new notes in same directory as current buffer.
      -- - `notes_subdir`: Put new notes in default notes subdirectory.
      new_notes_location = "notes_subdir",

      -- Customize how note IDs are generated, given optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in Zettelkasten format, with timestamp and suffix.
        -- Specifically, note with title 'My new note' will be given an ID
        -- 'YYYYMMDDHHmm-my-new-note', and therefore file name 'YYYYMMDDHHmm-my-new-note.md',
        -- which matches Obsidian app.
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is `nil`, add 4 random uppercase letters to suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end

        return tostring(os.date("*t").year)
          .. string.format("%02d", os.date("*t").month)
          .. string.format("%02d", os.date("*t").day)
          .. string.format("%02d", os.date("*t").hour)
          .. string.format("%02d", os.date("*t").min)
          .. "-"
          .. suffix
      end,

      -- Customize how note file names are generated given ID, target directory, title.
      ---@param spec { id: string, dir: obsidian.Path, title: string|? }
      ---@return string|obsidian.Path The full path to the new note.
      note_path_func = function(spec)
        -- Equivalent to default behavior.
        local path = spec.dir / tostring(spec.id)
        return path:with_suffix(".md")
      end,

      -- Customize how wiki links are formatted.
      -- - "use_alias_only", e.g. '[[Foo Bar]]'
      -- - "prepend_note_id", e.g. '[[foo-bar|Foo Bar]]'
      -- - "prepend_note_path", e.g. '[[foo-bar.md|Foo Bar]]'
      -- - "use_path_only", e.g. '[[foo-bar.md]]'
      -- Or: Use function that takes table of options and returns string, e.g.:
      -- prepend_note_id = true,
      -- prepend_note_path = false,
      -- use_path_only = false,
      -- use_path_only = true,
      wiki_link_func = function(opts)
        return require("obsidian.util").wiki_link_id_prefix(opts)
      end,

      -- Customize how markdown links are formatted.
      markdown_link_func = function(opts)
        return require("obsidian.util").markdown_link(opts)
      end,

      -- Either 'wiki' or 'markdown'.
      preferred_link_style = "wiki",

      -- Boolean or function that takes filename and returns boolean.
      -- `true`: Do not let `obsidian.nvim` manage frontmatter.
      disable_frontmatter = false,

      -- Customize frontmatter data.
      ---@return table
      note_frontmatter_func = function(note)
        -- Add title of note as alias.
        if note.title then
          note:add_alias(note.title)
        end

        -- local out = { title = note.title, id = note.id, aliases = note.aliases, tags = note.tags }
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata`: Contains manually added fields in frontmatter.
        -- Here, make sure those fields are kept in frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,

      -- For templates (see below).
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- - Map for custom template substitution variables.
        -- - Key: Variable name.
        -- - Value: Function returning string.
        -- - Built-in variables: `id`, `title`, `date`, `time`, `path`.
        substitutions = {
          yesterday = function()
            return os.date("%Y-%m-%d", os.time() - 86400)
          end,
        },
      },

      -- Default: `ObsidianFollowLink` ignores external URLs.
      -- Change behaviour to open in browser.
      ---@param url string
      follow_url_func = function(url)
        -- Open URL in default web browser.
        vim.fn.jobstart({ "open", url }) -- Mac OS.
        -- vim.fn.jobstart({"xdg-open", url})  -- Linux.
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows.
        -- vim.ui.open(url) -- Need Neovim 0.10.0+, does not work on OrbStack Linux.
      end,

      -- Default: `ObsidianFollowLink` ignores image links.
      -- Change behaviour to open image in preview.
      ---@param img string
      follow_img_func = function(img)
        vim.fn.jobstart({ "qlmanage", "-p", img }) -- Mac OS: Quick look preview.
        -- vim.fn.jobstart({"xdg-open", url})  -- Linux.
        -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows.
      end,

      -- `true`: Use Obsidian Advanced URI plugin.
      -- https://github.com/Vinzent03/obsidian-advanced-uri
      use_advanced_uri = false,

      -- `true`: Force ':ObsidianOpen' to bring app to foreground.
      open_app_foreground = false,

      picker = {
        -- Preferred picker: `telescope.nvim` | `fzf-lua` | `mini.pick` | `snacks.pick`.
        -- name = MyVim.pick.picker.name,
        name = "fzf-lua",

        -- Key mappings for picker.
        note_mappings = {
          -- Create new note from query.
          new = "<C-x>",
          -- Insert link to selected note.
          insert_link = "<C-l>",
        },
        tag_mappings = {
          -- Add tag(s) to current note.
          tag_note = "<C-x>",
          -- Insert tag at current location.
          insert_tag = "<C-l>",
        },
      },

      -- Sort search results by "path" | "modified" | "accessed" | "created".
      -- Recommend value: "modified" and `true` for `sort_reversed`, which means, for example,
      -- that `:ObsidianQuickSwitch` will show notes sorted by latest modified time.
      sort_by = "modified",
      sort_reversed = true,

      -- Set maximum number of lines to read from notes on disk, when performing certain searches.
      search_max_lines = 1000,

      -- Determines how certain commands open notes.
      -- 1. `current` (default): Always open in current window.
      -- 2. `vsplit`           : Open in vertical split if there is not already vertical split.
      -- 3. `hsplit`           : Open in horizontal split if there is not already horizontal split.
      open_notes_in = "current",

      -- Callbacks.
      -- callbacks = {
      --   -- Runs at end of `require("obsidian").setup()`.
      --   ---@param client obsidian.Client
      --   post_setup = function(client) end,
      --
      --   -- Runs when entering note buffer.
      --   ---@param client obsidian.Client
      --   ---@param note obsidian.Note
      --   enter_note = function(client, note) end,
      --
      --   -- Runs when leaving note buffer.
      --   ---@param client obsidian.Client
      --   ---@param note obsidian.Note
      --   leave_note = function(client, note) end,
      --
      --   -- Runs before writing buffer for note.
      --   ---@param client obsidian.Client
      --   ---@param note obsidian.Note
      --   pre_write_note = function(client, note) end,
      --
      --   -- Runs when workspace is set/changed.
      --   ---@param client obsidian.Client
      --   ---@param workspace obsidian.Workspace
      --   post_set_workspace = function(client, workspace) end,
      -- },

      -- - Additional syntax highlighting / extmarks.
      -- - Requires `opt.conceallevel = 1|2`.
      -- - See `:help conceallevel`.
      -- - NOTE: Must set to `false`, since we are using `render-markdown.nvim`.
      ui = { enable = false },
      -- ui = {
      --   -- `false`: Disable additional syntax features.
      --   enable = true,
      --
      --   -- Update delay after text change (ms).
      --   update_debounce = 200,
      --
      --   -- Disable UI features for files with more than this many lines.
      --   max_file_length = 5000,
      --
      --   -- Define how check-boxes are displayed.
      --   checkboxes = {
      --     --`char`: Must be single character.
      --     [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      --     ["x"] = { char = "", hl_group = "ObsidianDone" },
      --     [">"] = { char = "", hl_group = "ObsidianRightArrow" },
      --     ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
      --     ["!"] = { char = "", hl_group = "ObsidianImportant" },
      --     -- If no patched font, use:
      --     -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
      --     -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },
      --
      --     -- Add custom checkboxes, if desired...
      --   },
      --
      --   -- Use bullet marks for non-checkbox lists.
      --   bullets = { char = "•", hl_group = "ObsidianBullet" },
      --
      --   external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      --   -- If no patched font, use:
      --   -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
      --
      --   reference_text = { hl_group = "ObsidianRefText" },
      --
      --   highlight_text = { hl_group = "ObsidianHighlightText" },
      --
      --   tags = { hl_group = "ObsidianTag" },
      --
      --   block_ids = { hl_group = "ObsidianBlockID" },
      --
      --   hl_groups = {
      --     -- Options passed directly to: `vim.api.nvim_set_hl()`.
      --     ObsidianTodo = { bold = true, fg = "#f78c6c" },
      --     ObsidianDone = { bold = true, fg = "#89ddff" },
      --     ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
      --     ObsidianTilde = { bold = true, fg = "#ff5370" },
      --     ObsidianImportant = { bold = true, fg = "#d73128" },
      --     ObsidianBullet = { bold = true, fg = "#89ddff" },
      --
      --     -- Links.
      --     -- ObsidianRefText = { underline = true, fg = "#c792ea" },
      --
      --     ObsidianExtLinkIcon = { fg = "#c792ea" },
      --     ObsidianTag = { italic = true, fg = "#89ddff" },
      --     ObsidianBlockID = { italic = true, fg = "#89ddff" },
      --     -- ObsidianHighlightText = { bg = "#75662e" },
      --   },
      -- },

      -- Specify how to handle attachments.
      attachments = {
        -- Default folder to place images in, via `:ObsidianPasteImg`.
        -- If relative path, relative to vault root.
        -- Can override this per image, by passing full path to command instead of just filename.
        -- Default: "assets/imgs".
        img_folder = "assets/imgs",

        -- Function that determines default name or prefix, when pasting images via `:ObsidianPasteImg`.
        ---@return string
        img_name_func = function()
          -- Prefix image names with timestamp.
          return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
        end,

        -- Function that determines text to insert in note when pasting image.
        -- Takes two arguments relating to image file: `obsidian.Client`, `obsidian.Path`.
        -- Default implementation:
        ---@param client obsidian.Client
        ---@param path obsidian.Path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },

      -- see below for full list of options 👇
    },
  },
  {
    "epwalsh/pomo.nvim",
    version = "*", -- Recommended, use latest release instead of latest commit
    lazy = true,
    cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
    dependencies = {
      -- Optional, but highly recommended if you want to use the "Default" timer
      -- "rcarriga/nvim-notify",
    },
    opts = {
      -- How often the notifiers are updated.
      update_interval = 1000,

      -- Configure default notifiers to use for each timer.
      -- Can also configure different notifiers for specific timers by name, see `opts.timers`.
      notifiers = {
        -- "Default" notifier uses: `vim.notify`.
        -- `vim.notify`: Replaceable by `snacks.nvim > notifier` | `noice.nvim`.
        -- Alternative: `nvim-notify`.
        {
          name = "Default",
          opts = {
            -- - With `nvim-notify`, when `sticky = true`, timer pop-up stays in place.
            -- - To only show on start, set `sticky = false`.
            -- - With built-in `vim.notify`, `sticky = true` is needed to show count-down,
            --   otherwise only "starting" and "timer done!" is shown.
            sticky = true,

            -- Display icons.
            title_icon = "󱎫",
            text_icon = "󰄉",
            -- If no patched font, use these:
            -- title_icon = "⏳",
            -- text_icon = "⏱️",
          },
        },

        -- "System" notifier sends system notification when timer is finished.
        -- Available on MacOS and Windows natively, and on Linux via `libnotify-bin` package.
        { name = "System" },

        -- Define custom notifiers, by providing `init` function instead of name.
        -- { init = function(timer) ... end }
      },

      -- Override notifiers for specific timer names.
      timers = {
        -- Example: Use only "System" notifier when timer called "Break" is created.
        -- e.g. ':TimerStart 2m Break'.
        Break = {
          { name = "System" },
        },
      },
      -- Optionally define custom timer sessions.
      sessions = {
        -- Example session configuration, for session called "pomodoro".
        pomodoro = {
          { name = "Work", duration = "25m" },
          { name = "Short Break", duration = "5m" },
          { name = "Work", duration = "25m" },
          { name = "Short Break", duration = "5m" },
          { name = "Work", duration = "25m" },
          { name = "Long Break", duration = "15m" },
        },
      },
    },
  },
  -- {
  --   "saghen/blink.cmp",
  --   dependencies = { "saghen/blink.compat" },
  --   opts = {
  --     sources = {
  --       default = { "obsidian", "obsidian_new", "obsidian_tags" },
  --       providers = {
  --         obsidian = {
  --           name = "obsidian",
  --           module = "blink.compat.source",
  --         },
  --         obsidian_new = {
  --           name = "obsidian_new",
  --           module = "blink.compat.source",
  --         },
  --         obsidian_tags = {
  --           name = "obsidian_tags",
  --           module = "blink.compat.source",
  --         },
  --       },
  --     },
  --   },
  -- },
}
