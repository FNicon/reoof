---@class Pool
---@field private fn function
---@field private rfn function
---@field active any[]
---@field hidden any[]
---@field max number | nil
---@field name string
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

--- Return the first index with the given value (or nil if not found).
---@param array any[]
---@param value any
---@return number?
local function indexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
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
---@return Pool self
function pool.new(fn, rfn, name, max)
  local self = setmetatable({}, pool)
  self.active = {}
  self.hidden = {}
  self.fn = fn
  self.rfn = rfn
  local _max = max
  if (_max == 0) then
    _max = nil
  end
  self.max = _max or nil
  self.name = name or ""
  return self
end

--- put entity to pool
---@param self Pool
---@param entity any
function pool:put(entity)
  local idx = indexOf(self.active, entity)
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
    print("WARNING : trying to insert entity not from generate function")
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
    local idx = indexOf(self.active, entity)
    if (idx) then
      if (self.active[idx].release) then
        self.active[idx]:release()
        table.remove(self.active, idx)
      else
        print("WARNING : during release active, " .. idx .. " don't have release function")
      end
    else
      idx = indexOf(self.hidden, entity)
      if (idx) then
        if (self.hidden[idx].release) then
          self.hidden[idx]:release()
          table.remove(self.hidden, idx)
        else
          print("WARNING : during release hidden, " .. idx .. " don't have release function")
        end
      else
        print("WARNING : trying to release object not from generate function")
      end
    end
  end
end

--- for debug purposes. {"pool" : {"name": "something", "#active" : 0, "#hidden" : 0, "total" : 0 }}
---@param self Pool
---@return string
function pool:__tostring()
  local total = #self.active + #self.hidden
  local result = "{ \"pool\" : { \"name\" : \"" .. self.name ..  "\", \"#active\" : " .. #self.active .. ", \"#hidden\": " .. #self.hidden .. ", \"total\": " .. total .. " }}"
  return result
end

return pool
