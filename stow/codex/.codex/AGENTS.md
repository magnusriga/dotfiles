# Global agent instructions

## Responsive and browser testing

- To test a web page at a given width, emulate the viewport in the browser (e.g. `bunx agent-browser@latest set viewport 390 844`, Playwright `page.setViewportSize`, or the Chrome DevTools Protocol `Emulation.setDeviceMetricsOverride`).
- Never resize, move or float real windows with `hyprctl` for testing. Window resizing disturbs the user's desktop, and in Hyprland 0.56 setting a window's `max_size` or `min_size` to `"unset"` crashes the whole session.
