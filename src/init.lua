if node.LFS.get("_init") == nil then
  node.LFS.reload('flash.img')
end

local channel = 9
local packet_type = bit.bor(0xb0, 0xa0, 0x00, 0x10, 0x20, 0x30, 0xc0) -- 
local switchChannelTimer = tmr.create()

-- FRAME_SUBTYPE_ASSOC_REQUEST    0x00
-- FRAME_SUBTYPE_ASSOC_RESPONSE   0x01
-- FRAME_SUBTYPE_REASSOC_REQUEST  0x02
-- FRAME_SUBTYPE_REASSOC_RESPONSE 0x03
-- FRAME_SUBTYPE_PROBE_REQUEST    0x04
-- FRAME_SUBTYPE_PROBE_RESPONSE   0x05
-- FRAME_SUBTYPE_BEACON           0x08
-- FRAME_SUBTYPE_ATIM             0x09
-- FRAME_SUBTYPE_DISASSOCIATION   0x0a
-- FRAME_SUBTYPE_AUTHENTICATION   0x0b
-- FRAME_SUBTYPE_DEAUTHENTICATION 0x0c

local function iter_chan() 
  channel = channel + 1
  if channel > 15 then
    channel = 1
  end
end

local function packet_callback(pkt)
  if pkt.subtype ~= 8 then 
    print ('Packet(' .. channel.. '): ' .. '[' .. pkt.subtype .. ']' .. pkt.bssid_hex .. ' ' .. pkt.frame)
  end
end 

local function monitor() 
  wifi.monitor.start(packet_callback)
  wifi.monitor.channel(channel)
  iter_chan()
end

local function _init() 
  -- print("init")
  -- local a, b = pcall(node.LFS._init)
  -- print("  OK:", a)
  -- print("  Result:", b)
  
  -- print("main")
  -- local a, b = pcall(node.LFS.main)
  -- print("  OK:", a)
  -- print("  Result:", b)

  monitor()
  switchChannelTimer:register(150, tmr.ALARM_AUTO, monitor)
  switchChannelTimer:start()
end

local initTimer = tmr.create()
initTimer:register(1000, tmr.ALARM_SINGLE, _init)
initTimer:start()