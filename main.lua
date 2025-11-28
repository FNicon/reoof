local concat = table.concat
local tostring = tostring
local sformat = string.format

local ex
local ei = 1
local emax = 4

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
  ex = require(concat({"examples.ex", tostring(ei)}))
  ex.load()
end

local function nextEx()
  ei = ei + 1
  if (ei > emax) then
    ei = 1
  end
  loadEx()
end

local function prevEx()
  ei = ei - 1
  if (ei < 1) then
    ei = emax
  end
  loadEx()
end

local debug_msg = {
  "fps : ",
  "",
  " drawcalls : ",
  "",
  " drawcallsbatched : ",
  "",
  " canvasswitches : ",
  "",
  " texturememory : ",
  "",
  " images : ",
  "",
  " canvases : ",
  "",
  " shaderswitches : ",
  "",
  " fonts : ",
  "",
  " dt : ",
  "",
  " is : ",
  "",
}

function love.load(_args)
  love.window.setVSync(0)
  if (ex == nil) then
    if (#_args >= 1) then
      if (_args[1] == "debug") then
        if ((type(_args[2]) == "number") or type(_args[2]) == "string") then
          ei = _args[2]
        end
      else
        if ((type(_args[1]) == "number") or type(_args[1]) == "string") then
          ei = _args[1]
        end
      end
    end
    loadEx()
  end
end

local prev_dt = 0
local delta_label = ""

function love.update(dt)
  if (ex and ex.update) then
    ex.update(dt)
  else
    love.event.quit( "restart" )
  end
  delta_label = dt > prev_dt and "slower" or "faster"
  prev_dt = dt
end

local stats = {}

local function debug()
  stats = love.graphics.getStats( stats )
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, lh - dh, dw, dh)
  love.graphics.setColor(1, 1, 1, 1)

  debug_msg[2] = tostring(love.timer.getFPS())
  debug_msg[4] = tostring(stats.drawcalls)
  debug_msg[6] = tostring(stats.drawcallsbatched)
  debug_msg[8] = tostring(stats.canvasswitches)
  debug_msg[10] = tostring(stats.texturememory)
  debug_msg[12] = tostring(stats.images)
  debug_msg[14] = tostring(stats.canvases)
  debug_msg[16] = tostring(stats.shaderswitches)
  debug_msg[18] = tostring(stats.fonts)
  debug_msg[20] = sformat("%.3f", prev_dt)
  debug_msg[22] = tostring(delta_label)

  love.graphics.print(concat(debug_msg),0, lh - dh)
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

function love.mousereleased(x, y, button, istouch, presses)
  if (ex and ex.mousereleased) then
    ex.mousereleased(x, y, button, istouch, presses)
  end
end

function love.quit()
  if (ex) then
    ex.quit()
  end
end
