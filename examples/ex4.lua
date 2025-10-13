local cache = require("reoof.cache")
local pool = require("reoof.pool")

local PATH = (...):gsub('%.[^%.]+$', '')

local img_cache
local batch_cache
local entity_pool
local quad_cache

local assets = {
  "assets/image/kenney_fish_pack/fish_brown_outline.png",
}

local lw = love.graphics.getWidth()
local lh = love.graphics.getHeight()

local ADD_AMOUNT = 1000
local REMOVE_AMOUNT = 10000
local MAX_BUNNIES = 85000

local isTransformOther = false

local entity = {}

local time = 0

entity.__index = entity

function entity:reset(seed, x, y, r, sx, sy, ox, oy, kx, ky, imgPath )
  self.seed = seed or math.random(time * #entity_pool.active)
  love.math.setRandomSeed(self.seed)

  local assetIdx = love.math.random(1, #assets)

  self.img = img_cache:load(assets[assetIdx] or imgPath)

  self.x = x or love.math.random(lw)
  self.y = y or love.math.random(lh)

  if (isTransformOther) then
    self.r = r or love.math.random(2 * math.pi)
    self.sx = sx or love.math.random(2)
    self.sy = sy or love.math.random(2)
    self.ox = ox or love.math.random(self.img:getWidth())
    self.oy = oy or love.math.random(self.img:getHeight())
    self.kx = kx or love.math.random(self.img:getWidth())
    self.ky = ky or love.math.random(self.img:getHeight())

    local iw = self.img:getWidth()
    local ih = self.img:getHeight()

    self.w = iw * self.sx
    self.h = ih * self.sy

    self.quad = quad_cache:load(
      0, 0,
      iw, ih,
      iw, ih
    )
  else
    self.r = 0
    self.sx = 1
    self.sy = 1
    self.ox = 0
    self.oy = 0
    self.kx = 0
    self.ky = 0

    local iw = self.img:getWidth()
    local ih = self.img:getHeight()

    self.w = iw * self.sx
    self.h = ih * self.sy

  end

  self.speed = {
    x = love.math.random(-250, 250),
    y = love.math.random(-250, 250)
  }

  self.color = {
    r = love.math.random(50 / 255, 240 / 255),
    g = love.math.random(80 / 255, 240 / 255),
    b = love.math.random(100 / 255, 240 / 255)
  }

  self.batch = batch_cache:load(assets[assetIdx] or imgPath, MAX_BUNNIES)
  self.batch:add(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
  return self
end

function entity.spawn(seed, x, y, r, sx, sy, ox, oy, kx, ky, imgPath )
  local self = setmetatable({}, entity)
  return self:reset(seed, x, y, r, sx, sy, ox, oy, kx, ky, imgPath )
end

function entity:update(dt)
  love.math.setRandomSeed(self.seed)
  local dirRand = love.math.random(2)
  local dir = 0
  if (dirRand == 2) then
    dir = -1
  elseif (dirRand == 1) then
    dir = 1
  end

  self.x = self.x + self.speed.x * dt
  self.y = self.y + self.speed.y * dt

  if (isTransformOther) then
    self.r = self.r + love.math.random(2 * math.pi) * dt * dir
    self.sx = love.math.random(2) * dt * dir
    self.sy = love.math.random(2) * dt * dir
    self.ox = self.ox + love.math.random(self.img:getWidth()) * dt * dir
    self.oy = self.oy + love.math.random(self.img:getHeight()) * dt * dir
    self.kx = self.kx + love.math.random(self.img:getWidth()) * dt * dir
    self.ky = self.ky + love.math.random(self.img:getHeight()) * dt * dir

    self.w = self.img:getWidth() * self.sx
    self.h = self.img:getHeight() * self.sy

    local iw = self.img:getWidth()
    local ih = self.img:getHeight()

    self.quad = quad_cache:load(
      0, 0,
      iw, ih,
      iw, ih
    )
  end

  self.color = {
    r = love.math.random(50 / 255, 240 / 255),
    g = love.math.random(80 / 255, 240 / 255),
    b = love.math.random(100 / 255, 240 / 255)
  }

  if (self.x > lw or self.x < 0) then
    self.speed.x = -self.speed.x
  end
  if (self.y > lh or self.y < 0) then
    self.speed.y = -self.speed.y
  end
end

function entity:draw(index)
  self.batch:setColor(self.color.r, self.color.g, self.color.b, 1)
  self.batch:set(index, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
end

function entity:release()
  self.seed = nil
  self.x = nil
  self.y = nil
  self.r = nil
  self.sx = nil
  self.sy = nil
  self.ox = nil
  self.oy = nil
  self.kx = nil
  self.ky = nil

  self.w = nil
  self.h = nil

  self = nil
end

local ex = {}

local function newSpriteBatch(path)
  return love.graphics.newSpriteBatch(img_cache:load(path))
end

function ex.load(_args)
  time = 0
  love.math.setRandomSeed(time)
  img_cache = cache.new(love.graphics.newImage, PATH .. "." .. ex.__tostring() .. ".img_cache")
  batch_cache = cache.new(newSpriteBatch, PATH .. "." .. ex.__tostring() .. ".batch_cache")
  quad_cache = cache.new(love.graphics.newQuad, PATH .. "." .. ex.__tostring() .. ".quad_cache")
  entity_pool = pool.new(entity.spawn, entity.reset, PATH .. "." .. ex.__tostring() .. ".pool")
end

function ex.update(dt)
  time = time + dt
  for _,v in pairs(entity_pool.active) do
    v:update(dt)
  end
end

local function draw_batch()
  for i, v in ipairs(entity_pool.active) do
    v:draw(i)
  end
  for _, v in pairs(batch_cache.cache) do
    love.graphics.draw(v)
  end
end

local function draw_debug()
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, lw, 80)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(entity_pool:__tostring(), 0, 0)
  love.graphics.print(img_cache:__tostring(), 0, 20)
  love.graphics.print(batch_cache:__tostring(), 0, 40)
  love.graphics.print(quad_cache:__tostring(), 0, 60)
  love.graphics.print("(left click) despawn , (right click) spawn", lw/2, lh/2)
end

function ex.draw()
  draw_batch()
  draw_debug()
end

local function spawn(x, y)
  local target_amount = ADD_AMOUNT
  for i = 1, target_amount do
    entity_pool:get(nil, x, y)
  end
end

local function despawn()
  local target_amount = #entity_pool.active - REMOVE_AMOUNT
  if (target_amount < 0) then
    target_amount = 0
  end
  for i = #entity_pool.active, target_amount, - 1 do
    entity_pool:put(entity_pool.active[i])
  end
  for _, v in pairs(batch_cache.cache) do
    v:clear()
  end
  for _, v in ipairs(entity_pool.active) do
    v.batch:add(v.x, v.y, v.r, v.sx, v.sy, v.ox, v.oy, v.kx, v.ky)
  end
end

function ex.mousereleased(x, y, button, istouch, presses)
  if button == 1 then -- right click = spawn
    spawn(x, y)
  else                -- left click = despawn
    despawn()
  end
end

function ex.quit()
  img_cache:release()
  batch_cache:release()
  entity_pool:release()
  quad_cache:release()
  print("quit")
  print(ex)
end

function ex.__tostring()
  return "example 4 pool"
end

local mt = {
  __tostring = ex.__tostring
}

setmetatable(ex, mt)

return ex
