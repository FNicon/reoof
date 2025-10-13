local examples = {
  require("examples.ex1"),
  require("examples.ex2"),
  require("examples.ex3")
}

local ex
local ei = 1

local lw, lh = love.graphics.getDimensions()
local dw = lw
local dh = 20

local function quitEx()
  if (ex) then
    ex.quit()
  end
end

local function loadEx()
  quitEx()
  ex = examples[ei]
  ex.load()
end

local function nextEx()
  ei = ei + 1
  if (ei > #examples) then
    ei = 1
  end
  loadEx()
end

local function prevEx()
  ei = ei - 1
  if (ei < 1) then
    ei = #examples
  end
  loadEx()
end

function love.load(_args)
  love.window.setVSync(0)
  if (ex == nil) then
    if (#_args >= 1 and (type(_args[1]) == "number") or type(_args[1]) == "string") then
      ei = _args[1]
    end
    loadEx()
  end
end

function love.update(dt)
  if (ex and ex.update) then
    ex.update(dt)
  else
    love.event.quit( "restart" )
  end
end

local stats = {}

local function debug()
  stats = love.graphics.getStats( stats )
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, lh - dh, dw, dh)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(
    "fps : " .. love.timer.getFPS() ..
    " drawcalls : " .. stats.drawcalls ..
    " drawcallsbatched : " .. stats.drawcallsbatched ..
    " canvasswitches : " .. stats.canvasswitches ..
    " texturememory : " .. stats.texturememory ..
    " images : " .. stats.images ..
    " canvases : " .. stats.canvases ..
    " shaderswitches : " .. stats.shaderswitches ..
    " fonts : " .. stats.fonts
    ,0, lh - dh
  )
  love.graphics.print("< (left arrow) prev", 0, lh / 2)
  love.graphics.print("(right arrow) next >", lw - 120, lh/2)
end

function love.draw()
  if (ex and ex.draw) then
    ex.draw()
  end
  debug()
end

function love.keyreleased(key, scancode)
  if (ex and ex.keyreleased) then
    ex.keyreleased(key, scancode)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" and love.system.getOS() ~= "Web" then
    love.event.quit()
  else
    if (ex) then
      if (key == "left") then
        prevEx()
      elseif (key == "right") then
        nextEx()
      elseif (ex.keypressed) then
        ex.keypressed(key, scancode, isrepeat)
      end
    end
  end
end

function love.quit()
  if (ex) then
    ex.quit()
  end
end
