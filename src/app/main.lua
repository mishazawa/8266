-- ***************************************************************************
-- Graphics Test
--
-- This script executes several features of u8glib to test their Lua bindings.
--
-- Note: It is prepared for SSD1306-based displays. Select your connectivity
--       type by calling either init_i2c_display() or init_spi_display() at
--       the bottom of this file.
--
-- ***************************************************************************

-- display object
local disp
local loop_tmr = tmr.create()
-- setup I2c and connect display
local function init_i2c_display()
    -- SDA and SCL can be assigned freely to available GPIOs
    local sda = 2 -- GPIO4
    local scl = 1 -- GPIO5
    local sla = 0x3c

    i2c.setup(0, sda, scl, i2c.SLOW)
    disp = u8g2.ssd1306_i2c_128x64_noname(0, sla)
end

local function u8g2_prepare()
  disp:setFont(u8g2.font_6x10_tf)
  disp:setFontRefHeightExtendedText()
  disp:setDrawColor(1)
  disp:setFontPosTop()
  disp:setFontDirection(0)
end

local function u8g2_string(x, y, val)
  disp:setFontDirection(0)
  disp:drawStr(x, y, val)
end

local function draw()
  u8g2_prepare()
  u8g2_string(0, 5, "asd.")
end

local function loop()
  disp:clearBuffer()
  draw()
  disp:sendBuffer()

  loop_tmr:start()
end

do
  loop_tmr:register(100, tmr.ALARM_SEMI, loop)

  init_i2c_display()

  print("--- Starting Graphics Test ---")
  loop_tmr:start()
end
