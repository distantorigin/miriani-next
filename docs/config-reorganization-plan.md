# Configuration System Reorganization Plan

## Executive Summary
Complete internal reorganization of the Toastush/Miriani configuration system to unify configuration storage, simplify the loading framework, provide better menu organization, and improve maintainability.

## Current Problems
1. **Configuration Fragmentation**: 3 separate files (toastush.conf, auto_login.conf, sound_groups.conf)
2. **Mixed Concerns**: sounds.lua contains both playback engine and preferences (1049 lines)
3. **Hardcoded UI Elements**: Variant sounds list duplicated in config_menu.lua
4. **Menu Ordering**: Requires manual numbering with order field
5. **No Validation**: Config values not validated on load
6. **Inconsistent Terminology**: Mixed use of "options", "settings", "config"

## Key Decisions
- ✅ **Keep as single plugin** (NOT separate plugin - too complex for MUSHclient)
- ✅ **Unify into miriani.conf** replacing 3 separate files
- ✅ **Create config_schema.lua** as single source of truth
- ✅ **Extract sound preferences** from sounds.lua
- ✅ **Use array position** for menu ordering (no order field)
- ✅ **Separate UI handlers** from option definitions

---

## Phase 1: Core Configuration Schema
**Goal**: Create centralized configuration schema and migration system

### Tasks
- [ ] Create `/lua/miriani/scripts/config_schema.lua`
  - Define all option metadata in single location
  - Include group definitions with array-based ordering
  - Add audio settings structure
  - Include sound variant definitions
  - Add predefined sound groups

- [ ] Design miriani.conf structure
  ```lua
  miriani_config = {
    _version = "2.0",
    options = {
      -- All options including auto_login
      auto_login = "yes",
      auto_login_username = "user",
      roundtime = "yes",
    },
    audio = {
      master_volume = 50,
      master_mute = false,
      categories = {
        sounds = {volume = 60, pan = 0},
        environment = {volume = 50, pan = 0}
      },
      offsets = {
        notification = -15,
        communication = 0,
        -- etc
      }
    },
    sound_groups = {
      notification = true,
      communication = true,
    },
    sound_variants = {
      ["miriani/ship/move/accelerate.ogg"] = 3,
    }
  }
  ```

- [ ] Update Config class in `/lua/miriani/scripts/include/config.lua`
  - Add unified init() method for new schema
  - Implement load_unified_config()
  - Implement save_unified_config()
  - Add migration logic for old files

- [ ] Create migration function
  - Auto-detect old config files
  - Merge toastush.conf + auto_login.conf + sound_groups.conf
  - Create backup files (.bak)
  - Write new miriani.conf
  - Add version field for future migrations

- [ ] Test migration paths
  - Fresh install (no configs)
  - Old format (full option structures)
  - New format (values only)
  - Mixed formats
  - Corrupted files

---

## Phase 2: Extract Sound Preferences
**Goal**: Separate sound preferences from playback engine

### Tasks
- [ ] Create `/lua/miriani/scripts/include/sound_preferences.lua`
  - Extract variant preference functions (sounds.lua lines 268-323)
  - Extract group registry functions (sounds.lua lines 144-248)
  - Create clean API for preference management
  - Integrate with Config class

- [ ] Refactor sounds.lua
  - Remove extracted preference code (~350 lines)
  - Update to use config API for variants
  - Update to use config API for group toggles
  - Keep only playback engine code
  - Update all references to use new API

- [ ] Update config initialization
  - Load sound_preferences module
  - Integrate with main config table
  - Ensure backward compatibility

- [ ] Test sound system
  - Verify sound playback still works
  - Test variant selection
  - Test group enable/disable
  - Verify volume calculations

---

## Phase 3: Refactor Menu System
**Goal**: Simplify menu system using centralized schema

### Tasks
- [ ] Update config_menu.lua to use schema
  - Replace group_metadata with schema groups
  - Use array position for ordering
  - Remove get_group_key_from_title() complexity
  - Remove get_group_title() lookups

- [ ] Remove hardcoded variant list
  - Use schema for variant-capable sounds
  - Implement dynamic variant detection
  - Update show_group() function
  - Update find_and_edit() function

- [ ] Create UI handler registry
  ```lua
  local type_handlers = {
    bool = handle_bool_option,
    enum = handle_enum_option,
    string = handle_string_option,
    password = handle_password_option,
    color = handle_color_option,
  }
  ```

- [ ] Simplify option rendering
  - Use consistent formatting
  - Remove special cases
  - Improve readability

- [ ] Test menu system
  - Verify all groups display correctly
  - Test option editing for each type
  - Verify sound variants menu
  - Test sound groups toggle

---

## Phase 4: Add Validation System
**Goal**: Ensure config integrity and type safety

### Tasks
- [ ] Create validation framework
  - Add validate_option(key, value) function
  - Implement type checking
  - Add range validation for numbers
  - Add enum validation for strings
  - Add custom validators where needed

- [ ] Update Config:set_option()
  - Call validation before setting
  - Log validation errors
  - Provide helpful error messages
  - Use defaults for invalid values

- [ ] Add validation to load process
  - Validate during config file load
  - Fix or flag invalid values
  - Log migration/fix actions
  - Ensure config consistency

- [ ] Create validation tests
  - Test each option type
  - Test boundary conditions
  - Test invalid inputs
  - Verify error handling

---

## Phase 5: Cleanup and Polish
**Goal**: Finalize reorganization and improve consistency

### Tasks
- [ ] Standardize terminology
  - Use "config" consistently throughout
  - Update variable names
  - Update function names
  - Update comments/documentation

- [ ] Remove deprecated code
  - Delete old options.lua (merged into schema)
  - Delete old audio.lua (merged into schema)
  - Remove migration code after grace period
  - Clean up unused functions

- [ ] Update documentation
  - Document new config structure
  - Update user-facing help text
  - Document config schema format
  - Add developer documentation

- [ ] Performance optimization
  - Profile config load/save
  - Optimize serialization
  - Cache frequently accessed values
  - Minimize file I/O

- [ ] Final testing
  - Full regression test
  - Test with real user configs
  - Verify all features work
  - Check for memory leaks

---

## Implementation Notes

### File Structure Changes
```
REMOVE:
  /lua/miriani/scripts/options.lua
  /lua/miriani/scripts/audio.lua

ADD:
  /lua/miriani/scripts/config_schema.lua
  /lua/miriani/scripts/include/sound_preferences.lua

UPDATE:
  /lua/miriani/scripts/include/config.lua
  /lua/miriani/scripts/config_menu.lua
  /lua/miriani/scripts/sounds.lua

MIGRATE:
  /worlds/settings/toastush.conf → miriani.conf
  /worlds/settings/auto_login.conf → (merged)
  /worlds/settings/sound_groups.conf → (merged)
```

### Backward Compatibility & Migration
- Support loading old config files
- Automatic migration on first run
- Create backup files before migration (.bak extension)
- **DELETE old config files after successful migration**
- Preserve all user settings in unified miriani.conf
- Graceful handling of missing/invalid values

### File Cleanup After Migration
When migration succeeds:
1. **toastush.conf** → backs up to toastush.conf.bak → **DELETED**
2. **auto_login.conf** → backs up to auto_login.conf.bak → **DELETED**
3. **sound_groups.conf** → backs up to sound_groups.conf.bak → **DELETED**
4. **miriani.conf** → **CREATED** with all merged settings

The old files are deleted to:
- Prevent confusion about which file is active
- Ensure the plugin doesn't accidentally read old files
- Keep the settings directory clean
- Backups (.bak) are kept for safety

### Testing Strategy
1. Unit tests for each module
2. Integration tests for config system
3. Migration tests with sample configs
4. UI tests for menu system
5. Performance benchmarks

### Risk Mitigation
- Each phase independently deployable
- Backup files created automatically
- Fallback to defaults for errors
- Extensive logging during migration
- Ability to rollback if needed

---

## Success Metrics
- [ ] Single config file instead of 3
- [ ] 40% reduction in config-related code
- [ ] All existing features preserved
- [ ] Improved load/save performance
- [ ] Easier to add new options
- [ ] Clear separation of concerns
- [ ] Better maintainability

---

## Timeline Estimate
- Phase 1: 4-6 hours (Core Schema)
- Phase 2: 3-4 hours (Extract Preferences)
- Phase 3: 4-5 hours (Menu Refactor)
- Phase 4: 2-3 hours (Validation)
- Phase 5: 2-3 hours (Cleanup)
- **Total: 15-21 hours**

---

## Questions for Consideration
1. Should auto_login remain in the same file for security?
2. How long should we support old config format?
3. Should we add config import/export features?
4. Do we want config profiles (multiple configs)?
5. Should certain options be marked as "advanced"?