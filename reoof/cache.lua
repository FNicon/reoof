local concat = table.concat
local insert = table.insert

---@class Cache
---@field private fn function
---@field cache table
---@field count integer
---@field name string
---@field msg Cache.msg
local cache = {
  _VERSION = "0.0.0-alpha",
  _DESCRIPTION = "A simple and straightforward cache made for LÖVE.",
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

cache.__index = cache

--- custom to string function for each type
---@param v any
---@return string
local function to_string(v)
  if (type(v) == "string") then
    return v
  elseif (type(v) == "number") then
    return tostring(v)
  elseif (type(v) == "nil") then
    return ""
  elseif type(v) == "boolean" then
    if (v) then
      return "true"
    else
      return "false"
    end
  elseif type(v) == "table" then
    if (v.__tostring) then
      return tostring(v)
    else
      local temp = {}
      local res = {"{"}
      for k, _v in ipairs(v) do
        insert(temp, "[\"")
        insert(temp, k)
        insert(temp, "\"] = ")
        insert(temp, to_string(_v))
      end
      insert(res, concat(temp, ","))
      insert(res, "}")
      return concat(res)
    end
  elseif type(v) == "function" then
    -- local test = debug.getinfo(v)
    return ""
  elseif type(v) == "thread" then
    return ""
  elseif type(v) == "userdata" then
    return ""
  else
    return ""
  end
end

local function generate_key(...)
  local input = {...}
  local result = ""
  if (#input == 0) then
    result = ""
  elseif (#input > 1) then
    local temp = {}
    for _, v in ipairs(input) do
      insert(temp, to_string(v))
    end
    result = concat( temp ,'.' )
  else
    result = to_string(...)
  end
  if (result == "") then
    error("ERROR : no key is generated. Please input a parameter.")
  else
    return result
  end
end

--- create entity
---@param fn? function lambda to load resource
---@param name? string for debug purposes
---@return Cache self
function cache.new(fn, name)
  local self = setmetatable({}, cache)
  self.fn = fn or function ()

  end
  self.cache = {}
  self.count = 0
  self.name = name or ""

  ---@class Cache.msg
  ---@field debug string[]
  ---@field warn_release_func string[]
  ---@field error_key_not_found string[]
  self.msg = {
    debug = {
      "{\"cache\": { \"name\" : \"",
        self.name,
      "\", \"count\": ",
        tostring(self.count),
      ", \"cache\" : [",
      "",
      "]}}"
    },
    warn_release_func = {
      "WARNING : during release, ",
      "",
      " don't have release function"
    },
    error_key_not_found = {
      "ERROR : during release, ",
      "",
      " not found"
    }
  }
  return self
end

--- load resource to cache
---@param self Cache
---@param ... any
---@return any resource
function cache:load(...)
  local key = generate_key(...)
  if (self.cache[key] == nil) then
    self.cache[key] = self.fn(...)
    self.count = self.count + 1
    return self.cache[key]
  else
    return self.cache[key]
  end
end

--- release object and set it up to nil
---@param self Cache
---@param ...? any
function cache:release(...)
  if (#{...} == 0) then
    for k, _ in pairs(self.cache) do
      self:release(k)
    end
    self.cache = nil
    self.count = nil
    self.name = nil
    self.fn = nil
    setmetatable(self, nil)
    self = nil
  else
    local key = generate_key(...)
    if (self.cache[key]) then
      if (self.cache[key].release) then
        self.cache[key]:release()
        self.cache[key] = nil
        self.count = self.count - 1
      else
        self.msg.warn_release_func[2] = key
        print(concat(self.msg.warn_release_func))
      end
    else
      self.msg.error_key_not_found[2] = key
      error(concat(self.msg.error_key_not_found))
    end
  end
end

--- for debug purposes. {"cache" : { "name" : "something", "count" : 0, "cache" : ["keyA", "keyB"]}}
---@param self Cache
---@return string
function cache:__tostring()
  local temp = {}
  for k, _ in pairs(self.cache) do
    insert(temp, concat({"\"", k, "\""}))
  end
  self.msg.debug[4] = tostring(self.count)
  self.msg.debug[6] = concat(temp, " , ")
  return concat(self.msg.debug)
end

return cache
