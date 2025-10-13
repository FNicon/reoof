# reoof

## About

This is a simple and straightforward caching and pool library

## Install

add ``reoof/cache.lua`` and ``reoof/pool.lua`` inside your project

## How to Use

### Cache

```lua
-- require lib
local cache = require("reoof.cache")

function love.load()
  -- create new cache
  audio_cache = cache.new(love.audio.newSource, "audio_cache")
end

function love.update()
  -- load to cache
  audio_cache:load("assets/audio.wav", "static"):play()
end

function love.draw()
  -- debug cache
  love.graphics.print(audio_cache:__tostring(), 0, 0)
end

function love.quit()
  -- release all cache
  audio_cache:release()
end
```

### Pool

```lua
local pool = require("reoof.pool")

-- entity to be used on pool
local entity = {}

-- reset function for entity to reset it's value
function entity:reset()
  return self
end

-- spawn function for entity to spawn entity
function entity.spawn()
  local self = setmetatable({}, entity)
  return self:reset()
end

-- update function for entity to update it's value
function entity:update(dt)
end

-- draw function for entity
function entity:draw()
end

-- release function for entity to free entity from memory
function entity:release()
  setmetatable(self, nil)
  self = nil
end

function love.load()
  -- create new pool
  entity_pool = pool.new(entity.spawn, entity.reset, "entity_pool", 10)
end

function love.update()
  -- get from pool
  entity_pool:get()
  -- update from active pool
  for _,v in pairs(entity_pool.active) do
    v:update(dt)
  end
end

function love.draw()
  -- debug cache
  love.graphics.print(entity_pool:__tostring(), 0, 0)
  -- draw from active pool
  for _,v in pairs(entity_pool.active) do
    v:draw()
  end
end

function love.quit()
  -- release all pool
  entity_pool:release()
end
```
