-- @module mcp_client
-- Implements a Mud Client Protocol (MCP) client.
-- Specifications are accurate to versions 2.1
-- Implements mcp-negotiate package 2.0
-- Implements mcp-cord package 2.0
-- Implements dns-org-mud-moo-simpleedit package 1.0
-- See 'https://www.moo.mud.org/mcp/mcp2.html`

-- Author: Erick Rosso

---------------------------------------------

local class = require("pl.class")
local path = require("pl.path")
local lfs = require("lfs")
local version = require("lua/miriani/scripts/version")

class.MCP()

-- Packages we support (class-level, shared)
MCP.packages = {
  ["mcp-negotiate"] = {min_version = 1.0, max_version = 2.0},
  ["dns-org-mud-moo-simpleedit"] = {min_version = 1.0, max_version = 1.0},
  ["dns-com-vmoo-client"] = {min_version = 1.0, max_version = 1.0},
  ["dns-com-awns-status"] = {min_version = 1.0, max_version = 1.0},
}

-- Client info (class-level, shared)
MCP.client_info = {
  name = "Miriani-Next",
  internal_version = 0,
  reg_id = 0,
  flags = "p"
}

-- Instance initialization
function MCP:_init()
  self.constants = {
    auth_key = "",
    min_version = 2.1,
    max_version = 2.1
  }
  self.edit = nil
  self.file_watchers = {}
  self.watcher_timers = {}
  self.watcher_counter = 0
  self.watcher_registry = {}
end

function MCP:generate_auth_key()
  -- Check if we have a stored auth key (persists across reloads)
  local stored_key = GetVariable("mcp_auth_key")
  if stored_key and stored_key ~= "" then
    self.constants.auth_key = stored_key
    return
  end

  -- Generate hex auth key (0-9, a-f only)
  math.randomseed(os.time() + os.clock() * 1000)
  local chars = "0123456789abcdef"
  local key = {}
  -- Generate 8 hex characters
  for _ = 1, 8 do
    local idx = math.random(1, #chars)
    table.insert(key, chars:sub(idx, idx))
  end
  self.constants.auth_key = table.concat(key)
  SetVariable("mcp_auth_key", self.constants.auth_key)
end

-- Generate a random hex datatag
function MCP:generate_datatag()
  local chars = "0123456789abcdef"
  local tag = {}
  for _ = 1, 8 do
    local idx = math.random(1, #chars)
    table.insert(tag, chars:sub(idx, idx))
  end
  return table.concat(tag)
end

-- Parse MCP argument string, handling quoted values
function MCP:parse_argstr(str)
  local args = {}
  if not str then return args end

  -- Split by quotes
  local parts = {}
  local pos = 1
  while pos <= #str do
    local quote_start = str:find('"', pos, true)
    if quote_start then
      -- Add text before the quote
      if quote_start > pos then
        table.insert(parts, {text = str:sub(pos, quote_start - 1), quoted = false})
      end
      -- Find closing quote
      local quote_end = str:find('"', quote_start + 1, true)
      if quote_end then
        -- Add quoted content (including empty strings)
        table.insert(parts, {text = str:sub(quote_start + 1, quote_end - 1), quoted = true})
        pos = quote_end + 1
      else
        -- No closing quote, treat rest as unquoted
        table.insert(parts, {text = str:sub(quote_start + 1), quoted = false})
        break
      end
    else
      -- No more quotes, add rest
      table.insert(parts, {text = str:sub(pos), quoted = false})
      break
    end
  end

  -- Process parts
  local last_char = nil
  for _, part in ipairs(parts) do
    if part.quoted then
      -- Quoted content: if last char wasn't space, append to last arg; otherwise add as new arg
      if last_char and last_char ~= ' ' and last_char ~= '\t' and #args > 0 then
        args[#args] = args[#args] .. '"' .. part.text .. '"'
      else
        table.insert(args, part.text)
      end
      last_char = nil  -- Reset after quoted
    else
      -- Unquoted: split by whitespace
      local text = part.text
      if #text > 0 then
        last_char = text:sub(-1)
        text = text:match("^%s*(.-)%s*$")  -- trim
        if #text > 0 then
          for word in text:gmatch("%S+") do
            table.insert(args, word)
          end
        end
      end
    end
  end

  return args
end

-- Sanitize reference string for use as filename
function MCP:sanitize_filename(reference)
  return reference:gsub('[\\/:*?"<>|]', '_')
end

-- Get temporary directory for edit files
function MCP:get_temp_dir()
  local mushclient_dir = GetInfo(59) -- MUSHclient exe directory
  local tmp_dir = path.join(mushclient_dir, "worlds", "temp")

  -- Create directory if it doesn't exist
  if not path.isdir(tmp_dir) then
    lfs.mkdir(tmp_dir)
  end

  return tmp_dir
end

-- Get the configured text editor
function MCP:get_text_editor()
  if config and config.get_option then
    local editor_opt = config:get_option("text_editor")
    if editor_opt and editor_opt.value and editor_opt.value ~= "" then
      return editor_opt.value
    end
  end
  return "notepad.exe"
end

-- Open editor with the edit content
function MCP:open_editor(edit)
  local tmp_dir = self:get_temp_dir()
  if not tmp_dir then
    return
  end

  local filename = self:sanitize_filename(edit.reference) .. ".txt"
  local filepath = path.join(tmp_dir, filename)

  -- Close existing watcher for this file if any
  if self.file_watchers[filepath] then
    self:stop_file_watcher(filepath)
  end

  -- Write content to file
  local file, err = io.open(filepath, "wb")
  if not file then
    return
  end

  local content = table.concat(edit.data, "\r\n")
  file:write(content)
  file:close()

  -- Launch editor (non-blocking)
  local editor = self:get_text_editor()
  utils.shellexecute(editor, '"' .. filepath .. '"', tmp_dir, "open", 1)

  -- Start file watcher
  self:start_file_watcher(filepath, edit)
end

-- Start watching a file for changes
function MCP:start_file_watcher(filepath, edit)
  -- Get initial modification time
  local attr = lfs.attributes(filepath)
  if not attr then return end

  local last_mtime = attr.modification

  -- Generate unique watcher ID
  self.watcher_counter = self.watcher_counter + 1
  local watcher_id = self.watcher_counter

  -- Store watcher state
  local watcher = {
    filepath = filepath,
    edit = edit,
    last_mtime = last_mtime,
    debounce_active = false,
    watcher_id = watcher_id,
    active = true,
    started_at = os.time(),
    last_change = os.time()  -- Track when file was last modified
  }

  self.file_watchers[filepath] = watcher
  self.watcher_registry[watcher_id] = watcher
  self.watcher_timers[filepath] = watcher_id

  -- Start the polling loop
  self:schedule_poll(watcher_id)
end

-- Schedule next poll for a watcher
function MCP:schedule_poll(watcher_id)
  DoAfterSpecial(0.5, "mcp_dispatch_poll(" .. watcher_id .. ")", sendto.script)
end

-- Global dispatch function for poll callbacks
function mcp_dispatch_poll(watcher_id)
  if mcp then
    mcp:poll_file(watcher_id)
  end
end

-- Global dispatch function for debounce callbacks
function mcp_dispatch_debounce(watcher_id)
  if mcp then
    mcp:do_debounce(watcher_id)
  end
end

-- Global dispatch function for debounce clear
function mcp_dispatch_clear(watcher_id)
  if mcp then
    local watcher = mcp.watcher_registry[watcher_id]
    if watcher then
      watcher.debounce_active = false
    end
  end
end

-- Watcher timeout in seconds (1 hour - stop watching if no changes)
MCP.WATCHER_TIMEOUT = 60 * 60

-- Poll file for changes
function MCP:poll_file(watcher_id)
  local watcher = self.watcher_registry[watcher_id]

  -- Stop if watcher was removed or inactive
  if not watcher or not watcher.active then
    -- Clean up registry entry since no more polls will happen
    self.watcher_registry[watcher_id] = nil
    return
  end

  local filepath = watcher.filepath
  local attr = lfs.attributes(filepath)
  if not attr then
    -- File was deleted, stop watching
    self:stop_file_watcher(filepath)
    return
  end

  -- Check for timeout (no changes for WATCHER_TIMEOUT seconds)
  local now = os.time()
  if (now - watcher.last_change) > self.WATCHER_TIMEOUT then
    self:stop_file_watcher(filepath)
    return
  end

  if attr.modification ~= watcher.last_mtime then
    watcher.last_mtime = attr.modification
    watcher.last_change = now  -- Update last change time

    -- Check if we're in debounce period
    if not watcher.debounce_active then
      -- Set debounce flag and send content after delay
      watcher.debounce_active = true
      DoAfterSpecial(0.5, "mcp_dispatch_debounce(" .. watcher_id .. ")", sendto.script)
    end
  end

  -- Schedule next poll if still active
  if watcher.active then
    self:schedule_poll(watcher_id)
  end
end

-- Handle debounce callback
function MCP:do_debounce(watcher_id)
  local watcher = self.watcher_registry[watcher_id]
  if not watcher or not watcher.active then
    self.watcher_registry[watcher_id] = nil
    return
  end

  self:send_edit_back(watcher.filepath)

  -- Clear debounce after 2 seconds
  DoAfterSpecial(2, "mcp_dispatch_clear(" .. watcher_id .. ")", sendto.script)
end

-- Send edited content back to server
function MCP:send_edit_back(filepath)
  local watcher = self.file_watchers[filepath]
  if not watcher then return end

  local edit = watcher.edit
  local datatag = self:generate_datatag()

  -- Read file content
  local file, err = io.open(filepath, "rb")
  if not file then
    self:stop_file_watcher(filepath)
    return
  end

  local rawdata = file:read("*all")
  file:close()

  -- Send simpleedit-set command
  Send(string.format('#$#dns-org-mud-moo-simpleedit-set %s reference: "%s" type: %s content*: "" _data-tag: %s',
    self.constants.auth_key,
    edit.reference,
    edit.type,
    datatag))

  -- Send content line by line
  -- Handle CRLF, LF, or CR line endings
  if rawdata then
    -- Normalize line endings: convert CRLF and CR to LF, then split on LF
    local normalized = rawdata:gsub("\r\n", "\n"):gsub("\r", "\n")

    -- Split by LF, preserving empty lines
    local lines = {}
    local pos = 1
    while pos <= #normalized do
      local lf_pos = normalized:find("\n", pos, true)
      if lf_pos then
        table.insert(lines, normalized:sub(pos, lf_pos - 1))
        pos = lf_pos + 1
      else
        -- No more LF, add remaining content
        table.insert(lines, normalized:sub(pos))
        break
      end
    end

    -- Send each line
    for _, line in ipairs(lines) do
      Send(string.format("#$#* %s content: %s", datatag, line))
    end
  end

  -- Send completion marker
  Send(string.format("#$#: %s", datatag))
end

-- Stop watching a file
function MCP:stop_file_watcher(filepath)
  local watcher = self.file_watchers[filepath]
  if not watcher then return end

  local watcher_id = watcher.watcher_id

  -- Mark as inactive to stop polling loop
  watcher.active = false

  -- Clear from tracking tables (keep watcher_registry entry so pending timers don't crash)
  self.watcher_timers[filepath] = nil
  self.file_watchers[filepath] = nil
  -- Note: We keep watcher_registry[watcher_id] so pending timers can check watcher.active
end

-- Clean up all file watchers (call on disconnect)
function MCP:cleanup()
  for filepath, _ in pairs(self.file_watchers) do
    self:stop_file_watcher(filepath)
  end
  self.edit = nil
  self.watcher_registry = {}
  self.constants.auth_key = ""
  DeleteVariable("mcp_auth_key")

  -- Clear status from infobar
  if infobar then
    infobar("mcp_status", "")
  end
end

function MCP:register()
  self:generate_auth_key()

  local messages = {self:format_mcp_message({
    version = self.constants.min_version,
    to = self.constants.max_version
  })}


  -- mcp-negotiate package specifications.
  for package_name, versions in pairs(self.packages) do
    table.insert(messages, string.format(
      "#$#mcp-negotiate-can %s package: %s min-version: %.1f max-version: %.1f",
      self.constants.auth_key, package_name, versions.min_version, versions.max_version))
  end

  -- Conclude mcp-negotiate packages.
  table.insert(messages, string.format("#$#mcp-negotiate-end %s", self.constants.auth_key))

  for _, message in ipairs(messages) do
    Send(message)
  end

  return 0 -- ok
end

-- Send client info (called after server sends mcp-negotiate-end)
function MCP:send_client_info()
  local info = self.client_info
  local ver = version.version_string()
  local channel = version.update_channel()
  if channel ~= "stable" and version.commit() then
    ver = ver .. "+" .. version.commit()
  end
  Send(string.format('#$#dns-com-vmoo-client-info %s name: %s text-version: "%s" internal-version: %d reg-id: %d flags: %s',
    self.constants.auth_key,
    info.name,
    ver,
    info.internal_version,
    info.reg_id,
    info.flags))
end

-- Handle server's mcp-negotiate-end (send our client info)
function MCP:handle_negotiate_end(message)
  local command = self:parse_argstr(message)
  -- command[1] = #$#mcp-negotiate-end
  -- command[2] = authkey
  if #command >= 2 and command[2] == self.constants.auth_key then
    self:send_client_info()
  end
end

-- Handle dns-com-awns-status (server status updates)
-- Format: #$#dns-com-awns-status authkey <status>
function MCP:handle_status(message)
  local prefix = "#$#dns-com-awns-status " .. self.constants.auth_key .. " "
  if message:sub(1, #prefix) ~= prefix then
    return false
  end

  local status = message:sub(#prefix + 1)

  -- Update infobar with status
  if infobar then
    infobar("mcp_status", status)
  end

  return true
end

function MCP:parse_message(message)
  local parsed = {}
  local error_code = 0  -- Assume no error initially

  -- Check if the message starts with "#$#mcp"
  if not message:match("^#%$#mcp") then
      return { error = -1 }  -- Malformed syntax
  end

  -- Remove the initial "#$#mcp" part
  message = message:sub(7):gsub("^%s+", "")

  -- Extract key-value pairs
  for key, value in message:gmatch("(%S+):%s*([^%s]+)") do
      parsed[key] = value
  end

  -- Check for malformed message
  if next(parsed) == nil then
      error_code = -1
  end

  if error_code == 0 then
      return parsed
  else
      return { error = error_code }
  end
end

function MCP:format_mcp_message(data)
  -- Start with the MCP prefix and authentication key
  local response = "#$#mcp authentication-key: " .. self.constants.auth_key

  -- Iterate over the table and add the remaining key-value pairs
  for key, value in pairs(data) do
      response = response .. " " .. key .. ": " .. tostring(value)
  end

  return response
end

-- Handle dns-org-mud-moo-simpleedit-content command
-- Format: #$#dns-org-mud-moo-simpleedit-content authkey reference: "ref" name: "name" type: type content*: "" _data-tag: tag
function MCP:handle_simpleedit_content(message)
  local command = self:parse_argstr(message)

  -- Validate command structure
  -- command[1] = #$#dns-org-mud-moo-simpleedit-content
  -- command[2] = authkey
  -- command[3] = reference:
  -- command[4] = reference value
  -- command[5] = name:
  -- command[6] = name value
  -- command[7] = type:
  -- command[8] = type value
  -- command[9] = content*:
  -- command[10] = content value (usually "")
  -- command[11] = _data-tag:
  -- command[12] = datatag value

  if #command < 12 then
    return false
  end

  if command[2] ~= self.constants.auth_key then
    return false -- Wrong auth key, ignore
  end

  if command[3] ~= "reference:" or command[5] ~= "name:" or
     command[7] ~= "type:" or command[9] ~= "content*:" or
     command[11] ~= "_data-tag:" then
    return false
  end

  -- Store edit state
  self.edit = {
    reference = command[4],
    name = command[6],
    type = command[8],
    content = command[10],
    datatag = command[12],
    line_prefix = "#$#* " .. command[12] .. " content: ",
    data = {}
  }

  return true
end

-- Handle multiline data (#$#* datatag content: line)
-- Returns: true if handled, false if error, nil if not our datatag (ignore)
function MCP:handle_multiline_data(message)
  if not self.edit then
    return false
  end

  if message:sub(1, #self.edit.line_prefix) ~= self.edit.line_prefix then
    -- Wrong prefix - could be different datatag, don't cancel
    return nil
  end

  -- Extract line content
  local line = message:sub(#self.edit.line_prefix + 1)
  table.insert(self.edit.data, line)

  return true
end

-- Handle multiline end (#$#: datatag)
-- Returns: true if complete, false if error, nil if not our datatag
function MCP:handle_multiline_end(message)
  if not self.edit then
    return false
  end

  local expected = "#$#: " .. self.edit.datatag
  if message:sub(1, #expected) ~= expected then
    -- Wrong datatag, could be for something else
    return nil
  end

  -- Edit complete, open editor
  local edit = self.edit
  self.edit = nil

  self:open_editor(edit)

  return true
end

function MCP:handle_message(message)

  local data = self:parse_message(message)
  if data.error and data.error == -1 then
    -- do nothing right now.
  elseif (data.version and data.to) then
    self:register(data.version, data.to)
  end

end


-- Clean up stale temp files on module load (files older than 24 hours)
local function cleanup_stale_temp_files()
  local mushclient_dir = GetInfo(59)
  local tmp_dir = path.join(mushclient_dir, "worlds", "temp")

  if not path.isdir(tmp_dir) then return end

  local now = os.time()
  local max_age = 24 * 60 * 60 -- 24 hours in seconds

  for file in lfs.dir(tmp_dir) do
    if file ~= "." and file ~= ".." then
      local filepath = path.join(tmp_dir, file)
      local attr = lfs.attributes(filepath)
      if attr and attr.mode == "file" then
        local age = now - attr.modification
        if age > max_age then
          os.remove(filepath)
        end
      end
    end
  end
end

-- Create global MCP instance
mcp = MCP()

-- Restore auth_key from variable if it exists (survives reloads)
local stored_key = GetVariable("mcp_auth_key")
if stored_key and stored_key ~= "" then
  mcp.constants.auth_key = stored_key
end

-- Run cleanup on module load
cleanup_stale_temp_files()

-- MCP trigger handlers
function mcp_handle_init(name, line, wildcards)
  mcp:handle_message(line)
end

function mcp_handle_simpleedit_content(name, line, wildcards)
  if mcp:handle_simpleedit_content(line) then
    -- Successfully started edit, enable multiline triggers
    EnableTrigger("mcp_multiline_data", true)
    EnableTrigger("mcp_multiline_end", true)
  end
end

function mcp_handle_multiline_data(name, line, wildcards)
  local result = mcp:handle_multiline_data(line)
  if result == false then
    -- Error state, disable triggers
    EnableTrigger("mcp_multiline_data", false)
    EnableTrigger("mcp_multiline_end", false)
  end
end

function mcp_handle_multiline_end(name, line, wildcards)
  local result = mcp:handle_multiline_end(line)
  if result == true or result == false then
    -- Edit complete or error, disable multiline triggers
    EnableTrigger("mcp_multiline_data", false)
    EnableTrigger("mcp_multiline_end", false)
  end
  -- nil means wrong datatag, keep waiting
end

function mcp_handle_negotiate_end(name, line, wildcards)
  mcp:handle_negotiate_end(line)
end

function mcp_handle_status(name, line, wildcards)
  mcp:handle_status(line)
end

-- Import MCP triggers
ImportXML([=[
<triggers>
  <trigger
   enabled="y"
   name="mcp_init"
   group="mcp"
   script="mcp_handle_init"
   match="^#\$#mcp .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   name="mcp_simpleedit_content"
   group="mcp"
   script="mcp_handle_simpleedit_content"
   match="^#\$#dns-org-mud-moo-simpleedit-content .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="n"
   name="mcp_multiline_data"
   group="mcp"
   script="mcp_handle_multiline_data"
   match="^#\$#\* .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="n"
   name="mcp_multiline_end"
   group="mcp"
   script="mcp_handle_multiline_end"
   match="^#\$#: .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   name="mcp_negotiate_end"
   group="mcp"
   script="mcp_handle_negotiate_end"
   match="^#\$#mcp-negotiate-end .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   name="mcp_status"
   group="mcp"
   script="mcp_handle_status"
   match="^#\$#dns-com-awns-status .+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="100"
  >
  </trigger>

  <trigger
   enabled="y"
   name="mcp_catchall"
   group="mcp"
   match="^#\$#.+$"
   regexp="y"
   omit_from_output="y"
   omit_from_log="y"
   sequence="200"
  >
  </trigger>
</triggers>
]=])

return MCP
