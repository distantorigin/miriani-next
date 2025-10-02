local class = require("pl.class")
local const = require("miriani.lib.audio.bass.constants")
local ffi = require("ffi")
local stream = require("miriani.lib.audio.bass.stream")

class.BASS()

function BASS:_init()

  self.bass = require("miriani.lib.audio.bindings.bass")

end

function BASS:Free()

  self.bass.BASS_Free()

  return self.bass.BASS_ErrorGetCode()

end

function BASS:GetConfig(option)

  return self.bass.BASS_GetConfig(option)

end

function BASS:IsInitialized()

  -- Try to get BASS config - this only works if BASS is initialized
  local result = self.bass.BASS_GetConfig(const.config.buffer)
  local error_code = self.bass.BASS_ErrorGetCode()

  -- If the error code is 'init' (8), BASS is not initialized
  return error_code ~= const.error.init

end

function BASS:GetVersion()

  local version = self.bass.BASS_GetVersion()

  return version

end

function BASS:Init(device, frequency, flags)

  device = device or -1

  frequency = frequency or 44100

  flags = flags or 0

  local result = self.bass.BASS_Init(device, frequency, flags, nil, nil)
  if result == 0 then
    -- Init failed, return error code
    return self.bass.BASS_ErrorGetCode()
  else
    -- Init succeeded, but DON'T set device_default - this locks us to a specific device
    -- Instead, we'll handle device switching manually when errors occur
    return 0
  end
end

function BASS:Reinit(frequency, flags)
  -- Free current BASS instance
  self:Free()

  -- Try to initialize with device -1 (system default)
  frequency = frequency or 44100
  flags = flags or 0

  local result = self.bass.BASS_Init(-1, frequency, flags, nil, nil)
  if result == 0 then
    return self.bass.BASS_ErrorGetCode()
  else
    return 0
  end
end

function BASS:SetConfig(option, value)

  self.bass.BASS_SetConfig(option, value)

  return self.bass.BASS_ErrorGetCode()

end

function BASS:StreamCreate(freq, chans, flags)

  local handle = self.bass.BASS_StreamCreate(freq, chans, flags, -1, nil)

  if self.bass.BASS_ErrorGetCode() ~= const.error.ok then
    return self.bass.BASS_ErrorGetCode()
  else
    return stream(handle)
  end
end
function BASS:StreamCreateUrl(url, offset, flags)
  offset = offset or 0
  flags = flags or 0
  assert(type(url) == "string")

  local sfile = ffi.new("char[?]", #url+1)
  ffi.copy(sfile, url)

  local handle = self.bass.BASS_StreamCreateURL(sfile, offset, flags, nil)

  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  else
    return stream(handle)
  end
end

function BASS:StreamCreateFile(mem, file, offset, length, flags)
  offset = offset or 0
  length = length or 0
  flags = flags or 0

  assert(type(mem) == 'boolean')

  local sfile = ffi.new("char[?]", #file+1)
  ffi.copy(sfile, file)

  local handle = self.bass.BASS_StreamCreateFile(mem, sfile, offset, length, flags)

  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  else
    return stream(handle)
  end

end

function BASS:PluginLoad(filename)
  local sfile = ffi.new("char[?]", #filename+1)
  ffi.copy(sfile, filename)
  local handle = self.bass.BASS_PluginLoad(sfile)

  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  else
    return handle
  end
end
function BASS:SetEnvironment(env, vol, decay, damp)
  -- only works in 3d audio mode
  local result = self.bass.BASS_SetEAXParameters(env, vol, decay, damp)

  if not result then
    return self.bass.BASS_ErrorGetCode()
  else
    return true
  end
end

return BASS