if node.LFS.get("_init") == nil then
  node.LFS.reload('flash.img')
end

local function _init() 
  print("init")
  local a, b = pcall(node.LFS._init)
  print("  OK:", a)
  print("  Result:", b)
  
  print("main")
  local a, b = pcall(node.LFS.main)
  print("  OK:", a)
  print("  Result:", b)

end

local initTimer = tmr.create()
initTimer:register(1000, tmr.ALARM_SINGLE, _init)
initTimer:start()