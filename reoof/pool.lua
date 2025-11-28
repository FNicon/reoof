local concat = table.concat

---@class Pool
---@field private fn function
---@field private rfn function
---@field private efn function
---@field active any[]
---@field hidden any[]
---@field max number | nil
---@field name string
---@field msg Pool.msg
local pool = {
  _VERSION = "0.0.0-alpha",
  _DESCRIPTION = "A simple and straightforward pool made for LÖVE.",
  _URL = "https://github.com/FNicon/reoof",
  _LICENSE = [[
    MIT License

    Copyright (c) 2025 FNicon

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]]
}

pool.__index = pool

--- default equal function
---@param v1 any
---@param v2 any
local function defaultEqual(v1, v2)
  return v1 == v2
end

--- Return the first index with the given value (or nil if not found).
---@param array any[]
---@param value any
---@param efn fun(...):boolean
---@return number?
local function indexOf(array, value, efn)
  for i, v in ipairs(array) do
    if efn(v, value) then
      return i
    end
  end
  return nil
end

--- initialize pool
---@param fn fun(...):any generate Function
---@param rfn fun(...):any reset Function
---@param name? string for debug purposes
---@param max? number pool max size
---@param efn? fun(...):boolean equal Function
---@return Pool self
function pool.new(fn, rfn, name, max, efn)
  local self = setmetatable({}, pool)
  self.active = {}
  self.hidden = {}
  self.fn = fn
  self.rfn = rfn
  self.efn = efn or defaultEqual
  local _max = max
  if (_max == 0) then
    _max = nil
  end
  self.max = _max or nil
  self.name = name or ""

  ---@class Pool.msg
  ---@field debug string[]
  ---@field warn_put_wrong string
  ---@field warn_release_wrong string
  ---@field warn_release_hidden_wrong string[]
  ---@field warn_release_active_wrong string[]
  self.msg = {
    debug = {
      "{ \"pool\" : { \"name\" : \"",
        self.name,
      "\", \"#active\" : ",
        tostring(#self.active),
      ", \"#hidden\": ",
        tostring(#self.hidden),
      ", \"total\": ",
        tostring(#self.active + #self.hidden),
      " }}"
    },
    warn_put_wrong = "WARNING : trying to insert entity not from generate function",
    warn_release_wrong = "WARNING : trying to release object not from generate function",
    warn_release_hidden_wrong = {
      "WARNING : during release hidden, ",
      "",
      " don't have release function"
    },
    warn_release_active_wrong = {
      "WARNING : during release active, ",
      "",
      " don't have release function"
    }
  }
  return self
end

--- put entity to pool
---@param self Pool
---@param entity any
function pool:put(entity)
  local idx = indexOf(self.active, entity, self.efn)
  if (idx) then
    if (self.max) then
      if (#self.hidden < self.max) then
        table.insert(self.hidden, entity)
      else
        self:release(entity)
      end
    else
      table.insert(self.hidden, entity)
    end
    table.remove(self.active, idx)
  else
    print(self.msg.warn_put_wrong)
  end
  return self
end

--- get entity from pool
---@param self Pool
---@param ... any
---@return any entity from pool
function pool:get(...)
  local entity = self.hidden[#self.hidden]
  if (entity) then
    table.insert(self.active, entity)
    table.remove(self.hidden, #self.hidden)
    self.rfn(entity, ...)
    return entity
  else
    entity = self.fn(...)
    table.insert(self.active, entity)
    return entity
  end
end

--- release function
---@param self Pool
---@param entity? any
function pool:release(entity)
  if (entity == nil) then
    for _, v in ipairs(self.active) do
      self:release(v)
    end
    for _, v in ipairs(self.hidden) do
      self:release(v)
    end
    self.active = nil
    self.hidden = nil
    self.fn = nil
    self.rfn = nil
    self.name = nil
    setmetatable(self, nil)
    self = nil
  else
    local idx = indexOf(self.active, entity, self.efn)
    if (idx) then
      if (self.active[idx].release) then
        self.active[idx]:release()
        table.remove(self.active, idx)
      else
        self.msg.warn_release_active_wrong[2] = tostring(idx)
        print(concat(self.msg.warn_release_active_wrong))
      end
    else
      idx = indexOf(self.hidden, entity, self.efn)
      if (idx) then
        if (self.hidden[idx].release) then
          self.hidden[idx]:release()
          table.remove(self.hidden, idx)
        else
          self.msg.warn_release_hidden_wrong[2] = tostring(idx)
          print(concat(self.msg.warn_release_hidden_wrong))
        end
      else
        print(self.msg.warn_release_wrong)
      end
    end
  end
end

--- for debug purposes. {"pool" : {"name": "something", "#active" : 0, "#hidden" : 0, "total" : 0 }}
---@param self Pool
---@return string
function pool:__tostring()
  self.msg.debug[4] = tostring(#self.active)
  self.msg.debug[6] = tostring(#self.hidden)
  self.msg.debug[8] = tostring(#self.active + #self.hidden)
  return concat(self.msg.debug)
end

return pool
