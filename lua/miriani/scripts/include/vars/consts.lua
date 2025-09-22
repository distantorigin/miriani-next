-- Toastush Constants

local consts = {
  error = {
    OK = 0, -- Executed with no errors.
    NO_INIT = 1, -- Failed to initialize.
    INVALID_ARG = 2, -- Bad arguments provided.
    INVALID_TYPE = 3, -- Expected different typed arguments.
    NO_SAVE = 4, -- Failed to save to mush variable.
    ALREADY = 5, -- Already initialized.
    INVALID_FILE = 6,
    UNKNOWN = -1, -- Undetermined error.
  }, -- error

  pack = {
    SOUND_DIRECTORY = "sounds/",
    MUSH_VAR = "toastush_settings",
    DEFAULT_AUDIO = "master",
    VERSION = "4.0",
  } -- pack

} -- consts
return consts