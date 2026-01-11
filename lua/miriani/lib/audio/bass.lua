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
  self.bass.BASS_GetConfig(const.config.buffer)
  -- If the error code is 'init' (8), BASS is not initialized
  return self.bass.BASS_ErrorGetCode() ~= const.error.init
end

function BASS:GetVersion()
  return self.bass.BASS_GetVersion()
end

function BASS:Init(device, frequency, flags)
  device = device or -1
  frequency = frequency or 44100
  flags = flags or 0

  local result = self.bass.BASS_Init(device, frequency, flags, nil, nil)
  if result == 0 then
    return self.bass.BASS_ErrorGetCode()
  end

  -- Enable automatic device switching: when initialized with device -1 (default),
  -- setting DEV_DEFAULT makes BASS follow the Windows default device automatically
  if device == -1 then
    self.bass.BASS_SetConfig(const.config.device_default, 1)
  end
  return 0
end

function BASS:Reinit(frequency, flags)
  self:Free()
  return self:Init(-1, frequency, flags)
end

function BASS:Start()
  local result = self.bass.BASS_Start()
  if result == 0 then
    return self.bass.BASS_ErrorGetCode()
  end
  return 0
end

function BASS:CheckDeviceHealth()
  if not self:IsInitialized() then
    return const.error.init
  end

  self.bass.BASS_GetConfig(const.config.buffer)
  local error_code = self.bass.BASS_ErrorGetCode()

  if error_code == const.error.device or error_code == const.error.driver or error_code == const.error.buffer_lost then
    return error_code
  end

  return const.error.ok
end

function BASS:RecoverFromDeviceFailure()
  local recovery_attempts = {
    function() return self:Start() end,
    function() return self:Reinit(44100, 0) end
  }

  for i, attempt in ipairs(recovery_attempts) do
    if attempt() == 0 then
      return true, "Recovered using method " .. i
    end
  end

  return false, "All recovery attempts failed"
end

function BASS:SetConfig(option, value)
  self.bass.BASS_SetConfig(option, value)
  return self.bass.BASS_ErrorGetCode()
end

function BASS:StreamCreate(freq, chans, flags)
  local handle = self.bass.BASS_StreamCreate(freq, chans, flags, -1, nil)
  local error_code = self.bass.BASS_ErrorGetCode()

  if error_code ~= const.error.ok then
    return error_code
  end
  return stream(handle)
end

function BASS:StreamCreateUrl(url, offset, flags)
  offset = offset or 0
  flags = flags or 0
  assert(type(url) == "string")

  local sfile = ffi.new("char[?]", #url + 1)
  ffi.copy(sfile, url)

  local handle = self.bass.BASS_StreamCreateURL(sfile, offset, flags, nil)
  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  end
  return stream(handle)
end

function BASS:StreamCreateFile(mem, file, offset, length, flags)
  offset = offset or 0
  length = length or 0
  flags = flags or 0
  assert(type(mem) == 'boolean')

  local sfile = ffi.new("char[?]", #file + 1)
  ffi.copy(sfile, file)

  local handle = self.bass.BASS_StreamCreateFile(mem, sfile, offset, length, flags)
  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  end
  return stream(handle)
end

function BASS:PluginLoad(filename)
  local sfile = ffi.new("char[?]", #filename + 1)
  ffi.copy(sfile, filename)
  local handle = self.bass.BASS_PluginLoad(sfile)

  if handle == 0 then
    return self.bass.BASS_ErrorGetCode()
  end
  return handle
end

function BASS:SetEnvironment(env, vol, decay, damp)
  local result = self.bass.BASS_SetEAXParameters(env, vol, decay, damp)
  if not result then
    return self.bass.BASS_ErrorGetCode()
  end
  return true
end

return BASS
