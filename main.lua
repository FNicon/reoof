local concat = table.concat
local tostring = tostring

local ex
local ei = 1
local emax = 3

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
  ""
}

local function unpack20(tbl)
  return  tbl[1], tbl[2], tbl[3], tbl[4], tbl[5], tbl[6], tbl[7], tbl[8], tbl[9], tbl[10],
          tbl[11], tbl[12], tbl[13], tbl[14], tbl[15], tbl[16], tbl[17], tbl[18], tbl[19], tbl[20]
end

local graph_fps = {0, lh, 0, lh, 0, lh, 0, lh, 0, lh,
                  0, lh, 0, lh, 0, lh, 0, lh, 0, lh}
local max_dt = 20
local new_idx = 1

local function update_graph_dt(fps)
  new_idx = new_idx + 2
  if (new_idx > max_dt) then
    new_idx = 1
  end
  graph_fps[new_idx] = (new_idx * 5) -- x
  graph_fps[new_idx + 1] = lh - fps -- y
end

local function draw_graph_dt()
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.line(unpack20(graph_fps))
  love.graphics.setColor(1, 1, 1, 1)
end

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

function love.update(dt)
  if (ex and ex.update) then
    ex.update(dt)
  else
    love.event.quit( "restart" )
  end

  update_graph_dt(love.timer.getFPS())
end

local stats = {}

local function debug()
  stats = love.graphics.getStats( stats )
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle("fill", 0, lh - dh, dw, dh)
  draw_graph_dt()
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
