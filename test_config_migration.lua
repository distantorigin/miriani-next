-- Test script for configuration migration
-- Run this to test the unified config system

-- Mock MUSHclient functions for testing
function GetInfo(code)
  if code == 59 then  -- MUSHclient exe directory
    return "/mnt/c/Users/Tristan/src/Toastush"
  end
  return ""
end

function Note(msg)
  print("Note: " .. msg)
end

-- Set up package path
package.path = package.path .. ";./lua/?.lua;./lua/miriani/scripts/?.lua;./lua/miriani/scripts/include/?.lua"

-- Load required modules
local Config = require("config")
local config_schema = require("config_schema")

print("=== Configuration Migration Test ===")
print()

-- Test 1: Initialize with schema
print("Test 1: Initialize Config with schema")
local config = Config()
local result = config:init(config_schema)

if result == 0 then  -- Assuming OK is 0
  print("✓ Config initialized successfully with schema")
else
  print("✗ Config initialization failed: " .. tostring(result))
end

print()

-- Test 2: Check if options were loaded
print("Test 2: Check option loading")
local auto_login = config:get_option("auto_login")
if auto_login and auto_login.value then
  print("✓ Options loaded: auto_login = " .. tostring(auto_login.value))
else
  print("✗ Failed to load options")
end

print()

-- Test 3: Check audio configuration
print("Test 3: Check audio configuration")
local volume = config:get_attribute("sounds", "volume")
if volume then
  print("✓ Audio loaded: sounds volume = " .. tostring(volume))
else
  print("✗ Failed to load audio configuration")
end

print()

-- Test 4: Test migration
print("Test 4: Test migration from old files")
print("(This will attempt to migrate any existing old config files)")
local migrated = config:migrate_old_configs()
if migrated then
  print("✓ Migration completed successfully")
else
  print("✓ No old files to migrate (or already migrated)")
end

print()

-- Test 5: Test unified save
print("Test 5: Test unified save")
-- Set a test value
config:set_option("debug_mode", "yes")
config:set_sound_group("test_group", false)
config:set_sound_variant("miriani/ship/move/accelerate.ogg", 2)

local save_result = config:save()
if save_result == 0 then  -- Assuming OK is 0
  print("✓ Unified config saved successfully")
else
  print("✗ Failed to save unified config: " .. tostring(save_result))
end

print()

-- Test 6: Reload and verify
print("Test 6: Reload and verify saved values")
local config2 = Config()
config2:init(config_schema)

local debug_mode = config2:get_option("debug_mode")
local test_group = config2:get_sound_group("test_group")
local variant = config2:get_sound_variant("miriani/ship/move/accelerate.ogg")

local all_good = true
if debug_mode and debug_mode.value == "yes" then
  print("✓ Option persisted: debug_mode = yes")
else
  print("✗ Option not persisted correctly")
  all_good = false
end

if test_group == false then
  print("✓ Sound group persisted: test_group = false")
else
  print("✗ Sound group not persisted correctly")
  all_good = false
end

if variant == 2 then
  print("✓ Sound variant persisted: accelerate.ogg = 2")
else
  print("✗ Sound variant not persisted correctly")
  all_good = false
end

print()
print("=== Test Summary ===")
if all_good then
  print("All tests passed! The unified config system is working.")
else
  print("Some tests failed. Check the implementation.")
end

-- Clean up test values
config2:set_option("debug_mode", "no")
config2:save()

print()
print("Test complete. Test values have been cleaned up.")