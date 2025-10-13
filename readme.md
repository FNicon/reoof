# reoof

![Example](/docs/examples/love_ex.gif?raw=true "Example")

## About

This is a simple and straightforward caching and pool library

## Install

add ``reoof/cache.lua`` or ``reoof/pool.lua`` inside your project.
they are independent of each other.

## How to Use

### Cache

#### function Cache.new(fn?: function, name?: string) -> self: Cache

to create new cache entity

```lua
  audio_cache = cache.new(love.audio.newSource, "audio_cache")
```

#### function load(self: Cache, ...) -> any  -- resource

to load resource to cache

```lua
  audio_cache:load("assets/audio.wav", "static")
```

#### function __tostring(self: Cache) -> string

to print for debug ``{"pool" : {"name": "something", "#active" : 0, "#hidden" : 0, "total" : 0 }}``

```lua
  love.graphics.print(audio_cache:__tostring(), 0, 0)
```

#### function release(self: Cache, ...)

to release all cache :

```lua
  audio_cache:release()
```

to release specific cache :

```lua
  audio_cache:release("assets/audio.wav", "static")
```

### cache : table

to hold the resources as key value dictionary

### count : number

counter for unique key count

### name : string

name for cache entity

#### full example

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

#### Pool.new(fn: fun(...any):any, rfn: fun(...any):any, name?: string, max?: number) -> self: Pool

initialize pool

```lua
  entity_pool = pool.new(entity.spawn, entity.reset, "entity_pool", 10)
```

#### function put(self: Pool, entity: any) -> Pool

put entity to pool

```lua
  entity_pool:put(entity)
```

#### function get(self: Pool, ...) -> any  -- entity from pool

get entity from pool

```lua
  entity_pool:get()
```

#### function release(self: Pool, entity: any)

release function

to release entity and all of it's resources

```lua
  entity_pool:release()
```

to release specific entity. it'll check from active table first then hidden table.

```lua
  entity_pool:release(entity)
```

#### function __tostring(self: Pool) -> string

for debug purposes. ``{"pool" : {"name": "something", "#active" : 0, "#hidden" : 0, "total" : 0 }}``

```lua
  love.graphics.print(entity_pool:__tostring(), 0, 0)
```

#### Pool.active: any[]

to hold active pool

#### Pool.hidden: any[]

to hold hidden pool

#### Pool.fn: function

entity generate function

#### Pool.rfn: function

entity reset function

#### Pool.max: number|nil

hidden pool max length

#### Pool.name: string

pool name

#### full example

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

## Examples

see ``examples\`` for further examples:

## Limitations

### Cache

cache rely on key value. Where key needs to be in type that can changed to string.

so far, here's the handling for several known type

``number`` and ``string`` will be changed to ``string`` as usual.

``nil`` will be changed as ``""``

``boolean`` will be changed as ``"true"`` or ``"false"``

``table`` will be changed as ``""``

``function`` will be changed as ``""``

other than that will be changed as ``""``

if somehow when generating key will result in ``""`` it will cause error

### Pool

using ``pool`` in ``thread`` might cause error because of race condition accessing same index.

because of ``pool`` also hold active table, ``put()`` might be slow because it'll try to search for index on ``active`` table first.

``release()`` also affected because it needs to search for index on ``active`` and ``hidden`` table.
