local concat = table.concat
local cache = require("reoof.cache")

local PATH = (...):gsub('%.[^%.]+$', '')

local ex = {}

local assets = {
  "assets/audio/sfx/kenney_impact/footstep_carpet_000.ogg"
}

local lw = love.graphics.getWidth()
local lh = love.graphics.getHeight()

local audio_cache
local audio_load
local audio_str

function ex.load(_args)
  audio_cache = cache.new(love.audio.newSource, concat({PATH, "." , ex.__tostring(), ".audio_cache"}))
  audio_load = audio_cache.load
  audio_str = audio_cache.__tostring
end

function ex.update(dt)
  if (not audio_load(audio_cache, assets[1], "static"):isPlaying()) then
    audio_load(audio_cache, assets[1], "static"):play()
  end
end

function ex.draw()
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, 0, lw, 20)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(audio_str(audio_cache), 0, 0)
end

function ex.quit()
  audio_cache:release()
  print("quit")
  print(ex)
end

function ex.__tostring()
  return "example 1 cache"
end

local mt = {
  __tostring = ex.__tostring
}

setmetatable(ex, mt)

return ex
