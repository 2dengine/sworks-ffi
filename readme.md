# Steamworks for Lua/FFI
This is a cross-platform LuaJIT/FFI wrapper for Steamworks v1.51.
The library provides easy and simple Steamworks integration,
using the original redistributable binaries provided by Valve.
The full documentation is available at:
https://2dengine.com/?p=sworks

# Installation
1. Download the correct version of the SDK from the Steamworks partner site.
Find and copy the Steamworks library file in your game's executable folder.
For 64-bit versions of Windows the correct redistributable is "steam_api64.dll".

2. Create a text file called "steam_appid.txt" and paste your AppID.
Save the "steam_appid.txt" file in your game's executable folder.
You can get your unique AppID by becoming a Steamworks developer.

3. Copy the included Lua files from the "sworks" folder and include "main.lua" in your code:
```Lua
steam = require("sworks.main")
```

## Getting Started
This library requires LuaJIT/FFI, but will work fine with Love2D too.
Take a look in the "examples" folder for a Love2D demo.
Here is a very basic example that checks if we are connected to Steam:

```Lua
steam = require("sworks.main")
assert(steam.init() and steam.isRunning(), 'Steam client must be running')
assert(steam.isConnected(), 'Steam is in Offline mode')
user = steam.getUser()
print('hello '..user:getName())
while true do
  steam.update()
  ...
end
```

Note that this library performs asynchronious requests so make sure to call "steam.update()" regularly.

## Callbacks
Async requests are handled for every object using callbacks:

```Lua
user:requestStats()

function user:onReceiveStats()
  print('stats received!')
end)

function user:onFail(msg)
  print('request failed:'..msg)
end)
```

...although individual requests can be intercepted using closures:

```Lua
user:requestStats(function(ok, msg)
  if ok then
    print('stats received!')
  else
    print('request failed:'..msg)
  end
end)
```

# Development
This library has two layers: first is the low-level FFI binding called "flat.lua".
Additionally, there is a second, higher layer of abstraction that handles the
initialization, callbacks and provides access to the library using just pure Lua.
In theory, you can access every function in the Steamworks API using just "flat.lua".
Here is the previous example written using just the low-level FFI binding:

```Lua
local ffi = require('ffi')
local lib = require('sworks.flat')
lib.SteamAPI_Init()

local uhandle = lib.SteamAPI_GetHSteamUser()
local user = lib.SteamInternal_FindOrCreateUserInterface(uhandle, 'SteamUser020')
local id = lib.SteamAPI_ISteamUser_GetSteamID(user)
local cid = ffi.new('uint64_t', id)
local req = lib.SteamAPI_ISteamUserStats_RequestUserStats(user, cid)

local utils = lib.SteamInternal_FindOrCreateUserInterface(uhandle, 'SteamUtils009')
local failed = ffi.new('bool[1]')
while true do
  if lib.SteamAPI_ISteamUtils_IsAPICallCompleted(utils, req, failed) then
    break
  end
end
if failed[1] then
  print('request failed')
else
  print('stats received!')
end

```

There are some inheirent hurdles such as the Steamworks C++ callback mechanism.
FFI obviosly doesn't support C++ so this mechanism remains out of reach.

## Credits
This library was written by 2dengine with the help of the following folks: Phil, grump and garry.
Please support us and check out our games which are powered using this library:
https://2dengine.com/

Valve does not in any way endorse this project.