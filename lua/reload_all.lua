-- Reload all plugins

function reload_all_plugins()
  local pid = GetPluginID()
  local plugins = GetPluginList()

  for _, id in ipairs(plugins) do
    if id ~= pid then
      local ok, msg = ReloadPlugin(id)
      if ok ~= 0 then
        -- Could not reload
        Note("Warning: Could not reload plugin " .. id .. ": " .. tostring(msg))
      end
    end
  end
end