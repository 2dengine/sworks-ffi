-- Love2D example script
local ffi = require("ffi")
print((ffi.abi("64bit") and "64-bit" or "32-bit").." "..ffi.os)

local steam = require("sworks.main")
local user = nil
local avatar = nil
local totalugc = nil
local myugc = nil

function love.update(dt)
  steam.update()
end

function love.draw()
  local lg = love.graphics
  if not steam.init() or not steam.isRunning() then
    -- the steam client must be running in online or offline mode and
    -- a valid "steam_appid.txt" must be present in the love.exe folder
    lg.print("Steam API not initialized")
  else
    if not user then
      -- request user stats
      user = steam.getUser()
      user:requestStats()
      function user:onReceiveStats()
      end

      -- load avatar
      local img, width, height = user:getAvatar("large")
      if img then
        local data = love.image.newImageData(width, height, "rgba8", img)
        avatar = love.graphics.newImage(data)
      end

      steam.queryUGC("recent", 1, 10, function(ok, list, total)
        totalugc = total
      end)
      steam.queryUGC(user, 1, 10, function(ok, list, total)
        myugc = total
      end)

    end
    
    -- draw avatar
    if avatar then
      local w, h = lg.getDimensions()
      local iw, ih = avatar:getDimensions()
      lg.draw(avatar, w - iw, 0)
    end

    -- current game or application
    lg.print("appid:"..steam.getAppId(), 0, 0)
    
    -- language and GeoIP location
    lg.print("locale:"..steam.getLanguage().."/"..steam.getCountry(), 0, 16)
    
    -- username
    lg.print(user:getName(), 0, 32)
    
    lg.print("steamlvl:"..user:getLevel(), 0, 48)

    -- player id
    lg.print("steamid:"..user:getId(), 0, 64)
    
    -- connection and public status
    local connect = tostring(steam.isConnected())
    local status = tostring(user:isOnline())
    lg.print("connected:"..connect.." online:"..status, 0, 80)
    
    -- list of friends and their public status
    local friends = steam.getFriends()
    local online = 0
    for i, v in ipairs(friends) do
      if v:isOnline() then
        online = online + 1
      end
    end
    lg.print("friends:"..online.."/"..#friends, 0, 96)

    -- available and unlocked achievements
    local achieve = steam.getAchievements()
    local unlocked = 0
    for i, v in ipairs(achieve) do
      if user:getAchievement(v) then
        unlocked = unlocked + 1
      end
    end
    lg.print("achievements:"..unlocked.."/"..#achieve, 0, 112)

    -- UGC we may have subscribed to and installed
    if myugc and totalugc then
      lg.print("ugc:"..myugc.."/"..totalugc, 0, 128)
    end
    
    -- groups we are currently members of
    local clans = steam.getClans()
    lg.print("clans:"..#clans, 0, 144)
  end
end