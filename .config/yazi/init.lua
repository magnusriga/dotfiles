Status:children_add(function()
  local h = cx.active.current.hovered
  if h == nil or ya.target_family() ~= "unix" then
    return ui.Line({})
  end

  return ui.Line({
    ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
    ui.Span(":"),
    ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
    ui.Span(" "),
  })
end, 500, Status.RIGHT)

Header:children_add(function()
  if ya.target_family() ~= "unix" then
    return ui.Line({})
  end
  return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)

function Status:name()
  local h = self._tab.current.hovered
  if not h then
    return ui.Line({})
  end
  local linked = ""
  if h.link_to ~= nil then
    linked = " -> " .. tostring(h.link_to)
  end
  return ui.Line(" " .. h.name .. linked)
end

require("bookmarks"):setup({
  last_directory = { enable = true, persist = false },
  persist = "none",
  desc_format = "full",
  file_pick_mode = "hover",
  notify = {
    enable = true,
    timeout = 1,
    message = {
      new = "New bookmark '<key>' -> '<folder>'",
      delete = "Deleted bookmark in '<key>'",
      delete_all = "Deleted all bookmarks",
    },
  },
})

require("full-border"):setup()
require("folder-rules"):setup()
require("relative-motions"):setup({ show_numbers = "relative", show_motion = true })
require("git"):setup()
-- require("eza-preview"):setup()
