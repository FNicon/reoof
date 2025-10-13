local cache = require("reoof.cache")
local pool = require("reoof.pool")

local PATH = (...):gsub('%.[^%.]+$', '')

local img_cache
local batch_cache
local entity_pool

local assets = {
  "assets/image/kenney_fish_pack/fish_brown_outline.png",
  "assets/image/kenney_fish_pack/fish_blue_outline.png",
  "assets/image/kenney_fish_pack/fish_blue_skeleton_outline.png",
  "assets/image/kenney_fish_pack/fish_green_outline.png",
  "assets/image/kenney_fish_pack/fish_green_skeleton_outline.png",
  "assets/image/kenney_fish_pack/fish_grey_outline.png",
  "assets/image/kenney_fish_pack/fish_orange_outline.png",
  "assets/image/kenney_fish_pack/fish_orange_skeleton_outline.png",
  "assets/image/kenney_fish_pack/fish_pink_outline.png",
  "assets/image/kenney_fish_pack/fish_pink_skeleton_outline.png",
  "assets/image/kenney_fish_pack/fish_red_outline.png",
  "assets/image/kenney_fish_pack/fish_red_skeleton_outline.png",
}

local lw = love.graphics.getWidth()
local lh = love.graphics.getHeight()

local entity = {}

local time = 0

entity.__index = entity

function entity:reset(seed, x, y, r, sx, sy, ox, oy, kx, ky, imgPath )
  self.seed = seed or math.random(time)
  love.math.setRandomSeed(self.seed)

  local assetIdx = love.math.random(1, #assets)

  self.img = img_cache:load(assets[assetIdx] or imgPath)

  self.x = x or love.math.random(lw)
  self.y = y or love.math.random(lh)
  self.r = r or love.math.random(2 * math.pi)
  self.sx = sx or love.math.random(2)
  self.sy = sy or love.math.random(2)
  self.ox = ox or love.math.random(self.img:getWidth())
  self.oy = oy or love.math.random(self.img:getHeight())
  self.kx = kx or love.math.random(self.img:getWidth())
  self.ky = ky or love.math.random(self.img:getHeight())

  self.w = self.img:getWidth() * self.sx
  self.h = self.img:getHeight() * self.sy

  self.batch = batch_cache:load(assets[assetIdx] or imgPath)
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

  self.x = self.x + love.math.random(lw) * dt * dir
  self.y = self.y + love.math.random(lh) * dt * dir
  self.r = self.r + love.math.random(2 * math.pi) * dt * dir
  self.sx = love.math.random(2) * dt * dir
  self.sy = love.math.random(2) * dt * dir
  self.ox = self.ox + love.math.random(self.img:getWidth()) * dt * dir
  self.oy = self.oy + love.math.random(self.img:getHeight()) * dt * dir
  self.kx = self.kx + love.math.random(self.img:getWidth()) * dt * dir
  self.ky = self.ky + love.math.random(self.img:getHeight()) * dt * dir

  self.w = self.img:getWidth() * self.sx
  self.h = self.img:getHeight() * self.sy

  if (
    self.x > lw or self.x < 0 or
    self.y > lh or self.y < 0
  ) then
    entity_pool:put(self)
  end
end

function entity:draw()
  self.batch:add(self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
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
  entity_pool = pool.new(entity.spawn, entity.reset, PATH .. "." .. ex.__tostring() .. ".pool", 10)
end

function ex.update(dt)
  time = time + dt
  love.math.setRandomSeed(time)
  local spawn_amount = love.math.random(100)
  for i = 1, spawn_amount do
    entity_pool:get()
  end
  for _,v in pairs(entity_pool.active) do
    v:update(dt)
  end
end

local function draw_batch()
  for _, v in pairs(batch_cache.cache) do
    v:clear()
  end
  for _,v in pairs(entity_pool.active) do
    v:draw()
  end
  for _, v in pairs(batch_cache.cache) do
    love.graphics.draw(v)
  end
end

local function draw_debug()
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, lw, 60)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(entity_pool:__tostring(), 0, 0)
  love.graphics.print(img_cache:__tostring(), 0, 20)
  love.graphics.print(batch_cache:__tostring(), 0, 40)
end

function ex.draw()
  draw_batch()
  draw_debug()
end

function ex.quit()
  img_cache:release()
  batch_cache:release()
  entity_pool:release()
  print("quit")
  print(ex)
end

function ex.__tostring()
  return "example 3 pool"
end

local mt = {
  __tostring = ex.__tostring
}

setmetatable(ex, mt)

return ex
