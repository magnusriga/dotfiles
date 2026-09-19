-- desc: matching survives DP port shuffles across reboots.
-- Layout L->R: LG (portrait), BenQ, laptop.
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
  output = "desc:LG Electronics LG SDQHD",
  mode = "preferred",
  position = "0x0",
  scale = 1.6,
})

hl.monitor({
  output = "desc:BNQ BenQ RD280U",
  mode = "preferred",
  position = "1600x0",
  scale = 1.6,
  bitdepth = 10,
  cm = "hdr",
  sdrbrightness = 1.5,
})

hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "4000x0",
  scale = 1.6,
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.6,
})
