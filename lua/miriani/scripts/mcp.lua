-- @module mcp_client
-- Implements a Mud Client Protocol (MCP) client.
-- Specifications are accurate to versions 2.1 
-- Implements mcp-negotiate package 2.0
-- Implements mcp-cord package 2.0
-- See 'https://www.moo.mud.org/mcp/mcp2.html`

-- Author: Erick Rosso

---------------------------------------------

local class = require("pl.class")

class.MCP()

MCP.packages = {
  ["mcp-negotiate"] = {min_version = 1.0, max_version = 2.0},
  ["mcp-cord"] = {min_version = 1.0, max_version = 2.0},
  ["dns-org-mud-moo-simpleedit"] = {min_version = 1.0, max_version = 1.0},
  ["dns-com-awns-status"] = {min_version = 1.0, max_version = 1.0},
  ["dns-com-vmoo-client"] = {min_version = 1.0, max_version = 1.0},
  ["dns-com-vmoo-mmedia"] = {min_version = 2.0, max_version = 2.0},
  -- ["dns-com-vmoo-userlist"] = {min_version = 1.0, max_version = 1.2},
  ["dns-com-vmoo-smartcomplete"] = {min_version = 0.0, max_version = 1.0},
  ["dns-com-awns-ping"] = {min_version = 1.0, max_version = 1.0},

}

MCP.constants = {
  auth_key = "",
  min_version = 2.1,
  max_version = 2.1
}

function MCP:generate_auth_key()
  math.randomseed(os.time())
  local key = {}
  for _ = 1, math.random(10, 15) do
    table.insert(key, string.char(math.random(48, 122))) -- Generate random string.
  end
  self.constants.auth_key = table.concat(key)
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

function MCP:handle_message(message)

  local data = self:parse_message(message)
  if data.error and data.error == -1 then
    -- do nothing right now.
  elseif (data.version and data.to) then
    self:register(data.version, data.to)
  end

end


return MCP