local bit = require("bit")
local class = require("pl.class")
local const = require("miriani.lib.audio.bass.constants")
local ffi = require("ffi")
local fx = require("miriani.lib.audio.bass.fx")
local tablex = require("pl.tablex")

class.Channel()

function Channel:_init(id)

  local meta = tablex.copy(getmetatable(self))

  self.__old_index = meta.__index

  self._channelinfo = ffi.new("BASS_CHANNELINFO[1]")
  self.bass = require("miriani.lib.audio.bindings.bass")
  self.id = id

  meta.__index = function(self, key)

    -- the problem is that we need to support both cases, direct instanciation
    -- and derived classes

    for i,obj in pairs({self, rawget(self, '__old_index')}) do

      local tmp = rawget(obj, key)

      if tmp ~= nil then
        return tmp
      end

      tmp = rawget(obj, 'get_'..key)

      if tmp ~= nil then
        return tmp(self)
      end

    end

    return nil

  end

  meta.__newindex = function(self, key, value)

    local tmp = rawget(self, 'set_'..key)

    if tmp ~= nil then
      tmp(self, value)
      return
    end

    local tmp = rawget(self, '__old_index')['set_'..key]

    if tmp ~= nil then
      tmp(self, value)
      return
    end

    error('no attribute with that name can be set')

  end

  setmetatable(self, meta)

  self:GetInfo()

end

function Channel:Bytes2Seconds(bytes)

  return self.bass.BASS_ChannelBytes2Seconds(self.id, bytes)

end

function Channel:FXReset()

  self.bass.BASS_FXReset(self.id)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:Flags(flags, mask)

  mask = mask or 0

  return self.bass.BASS_ChannelFlags(self.id, flags, mask)

end

function Channel:GetAttribute(attrib)
  local f = ffi.new("float[1]")

  local success = self.bass.BASS_ChannelGetAttribute(self.id, attrib, f)

  if success == 0 then
    return self.bass.BASS_ErrorGetCode()
  else
    return f[0]
  end

end

function Channel:GetData(length)

  if length == const.data.available then
    local bytes = self.bass.BASS_ChannelGetData(self.id, nil, length)

    if self.bass.BASS_ErrorGetCode() ~= const.error.ok then
      return self.bass.BASS_ErrorGetCode()
    else
      return bytes
    end
  else

    -- splitting actual length from additional arguments
    local actual_length = bit.band(length, 0xfffffff)

    local buf = ffi.C.malloc(actual_length)

    local returned = self.bass.BASS_ChannelGetData(self.id, buf, length)

    if self.bass.BASS_ErrorGetCode() ~= const.error.ok then
      ffi.C.free(buf)
      return self.bass.BASS_ErrorGetCode()
    else
      local result = ffi.string(buf, returned)
      ffi.C.free(buf)
      return result
    end
  end
end

function Channel:GetInfo()

  self.bass.BASS_ChannelGetInfo(self.id, self._channelinfo)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:GetLength(mode)

  mode = mode or const.position.byte

  return self.bass.BASS_ChannelGetLength(self.id, mode)

end

function Channel:GetPosition(mode)

  mode = mode or const.position.byte

  return self.bass.BASS_ChannelGetPosition(self.id, mode)

end

function Channel:IsActive()

  return self.bass.BASS_ChannelIsActive(self.id)

end

function Channel:IsSliding(attribute)

  attribute = attribute or 0

  return self.bass.BASS_ChannelIsSliding(self.id, attribute)

end

function Channel:Pause()

  self.bass.BASS_ChannelPause(self.id)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:Play(restart)

  restart = restart or false

  assert(type(restart) == 'boolean')

  self.bass.BASS_ChannelPlay(self.id, restart)

  err=self.bass.BASS_ErrorGetCode()
  if err==9 then
  started=self.bass.BASS_Start()
  if not started then
  return 0
  end
--  self:Play(restart)
else
return self.bass.BASS_ErrorGetCode()
end
end

function Channel:Seconds2Bytes(seconds)

  return self.bass.BASS_ChannelSeconds2Bytes(self.id, seconds)

end

function Channel:SetAttribute(attrib, value)

  self.bass.BASS_ChannelSetAttribute(self.id, attrib, value)

  return self.bass.BASS_ErrorGetCode()

end

function Channel.SetFX(self,lfx, priority)
  priority = priority or 0
  local handle = self.bass.BASS_ChannelSetFX(self.id, lfx, priority)

  if handle ~= 0 then
    return fx(handle, self.id, lfx)
  else
    return self.bass.BASS_ErrorGetCode()
  end

end

function Channel:SetPosition(position, mode)

  mode = mode or const.position.byte

  self.bass.BASS_ChannelSetPosition(self.id, position, mode)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:SlideAttribute(attribute, value, time)
local t=ffi.new("float",time)
  self.bass.BASS_ChannelSlideAttribute(self.id, attribute, value, time)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:Stop()

  self.bass.BASS_ChannelStop(self.id)

  return self.bass.BASS_ErrorGetCode()

end

function Channel:OnReachedEnd(func)
	print(self.bass.BASS_ChannelSetSync(self.id,2,nil,default_sync_proc))
end
function Channel:Update(length)

  length = length or 0

  return self.bass.BASS_ChannelUpdate(self.id, length)

end

-- all getters follow

function Channel:get_channel_type()

  return self._channelinfo[0].ctype

end

function Channel:get_channels()

  return self._channelinfo[0].chans

end

function Channel:get_flags()

  return self._channelinfo[0].flags

end

function Channel:get_frequency()

  return self._channelinfo[0].freq

end

-- convenience

function Channel:get_length()

  return self:Bytes2Seconds(self:GetLength())

end

function Channel:get_original_resolution()

  return self._channelinfo[0].origres

end

-- convenience

function Channel:get_position()

  return self:Bytes2Seconds(self:GetPosition())

end

-- setters

function Channel:set_position(position)

  self:SetPosition(self:Seconds2Bytes(position))

end
function Channel:AddFX(effect,options)
--adds an effect to this channel. Effect is a constant from audio.const.fx, options is a table of options matching the parameter names withou the leading f, such as RightDelay or Feedback.
newFX=self:SetFX(effect)
for k, v in pairs(options) do
if newFX.Parameters["set_"..string.lower(k)]==nil then
valid={}
for k, v in pairs(newFX.Parameters) do
if string.sub(k,1,3)=="set" then
table.insert(valid,k:sub(5))
end
end
print("invalid fx parameter. Available parameters are: "..table.concat(valid,", "))
else
newFX.Parameters["set_"..string.lower(k)](newFX.Parameters,v)
end
end
newFX:SetParameters(newFX.Parameters)
end
function Channel:listFX()
return l
end
return Channel