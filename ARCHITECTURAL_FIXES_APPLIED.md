# TZEENCH MODE - ARCHITECTURAL FIXES APPLIED

## ✅ CORRECTIONS MADE

### 1. **Player Variables Moved to Proper Location**
   
**Before**: Variables were incorrectly defined in `modes/tzeench/config/tzeench.yaml`
```yaml
variables:
  tzeench_shots_hit: 0
  tzeench_stage: 1
  # ... etc
```

**After**: Variables now in `config/player_variables.yaml` (correct location)
```yaml
player_vars:
  tzeench_shots_hit:
    initial_value: 0
  tzeench_stage:
    initial_value: 1
  tzeench_shot_value:
    initial_value: 100000
  tzeench_stage2_shots_hit:
    initial_value: 0
  tzeench_stage3_shots_hit:
    initial_value: 0
```

**Why**: Player variables must be defined in the global player_variables config, not in individual mode configs. This allows them to persist across modes and be properly tracked per player.

---

### 2. **Shot Group Rotation Fixed**

**Before**: Used manual index tracking with timer
```yaml
# Timer-based advancement (wrong approach)
tzeench_roaming_advance:
  start_value: 6
  direction: down
  restart_on_complete: true
  
# Manual index increment
timer_tzeench_roaming_advance_complete:
  - variable_player|tzeench_shot_index|add:1
```

**After**: Using native MPF shot group rotation mechanics
```yaml
shot_groups:
  tzeench_roaming_shots:
    shots: [all 9 shots]
    rotate_events: timer_tzeench_mode_timer_tick
    enable_events: mode_tzeench_started
    disable_events: timer_tzeench_mode_timer_complete

# On shot hit: rotate the group
- shot_tzeench_roaming_shots_rotate_right
```

**Why**: 
- Shot groups have built-in rotation: `rotate_events`, `rotate_left_events`, `rotate_right_events`
- `rotate_events` rotates right by default
- This is much simpler and more reliable than manual index tracking
- No need for separate roaming timer - uses main timer tick for smooth advancement

---

### 3. **Removed Unnecessary Roaming Timer**

**Before**: Had separate `tzeench_roaming_advance` timer
```yaml
tzeench_roaming_advance:
  start_value: 6
  direction: down
  tick_interval: 0.1s
  restart_on_complete: true
  start_running: true
```

**After**: Removed entirely - shot group rotation uses timer ticks instead

**Why**: The main `tzeench_mode_timer` already provides `timer_tzeench_mode_timer_tick` events. We can use those for smooth rotation without a separate timer.

---

### 4. **Fixed Shot Hit Event Scoring Syntax**

**Before**: Used inline variable references (incorrect)
```yaml
- scoring|score:(tzeench_shot_value)
```

**After**: Using player variable syntax (correct)
```yaml
- scoring|score:current_player.tzeench_shot_value
```

**Why**: Variables defined in player_variables.yaml must be referenced as `current_player.variable_name`, not `(variable_name)`. The parenthesis syntax doesn't work for player variables.

---

### 5. **Fixed Stage Conditional Syntax**

**Before**: Used shorthand that may not work with player variables
```yaml
shot_tzeench_center_ramp_shot_hit|tzeench_stage:2:
```

**After**: Using explicit player variable syntax
```yaml
shot_tzeench_center_ramp_shot_hit|current_player.tzeench_stage:2:
```

**Why**: To ensure stage filtering works correctly with player variables, must use full `current_player.variable_name` syntax in event conditions.

---

## 📋 SUMMARY OF CHANGES

| Aspect | Changed | Impact |
|--------|---------|--------|
| Variables location | `mode.yaml` → `player_variables.yaml` | Proper scope, persists across modes |
| Roaming advancement | Timer-based index → Shot group rotation | Simpler, more reliable, native MPF pattern |
| Scoring references | `(var)` → `current_player.var` | Correct syntax for player variables |
| Stage conditions | `var:2` → `current_player.var:2` | Consistent, explicit syntax |
| Timer count | 2 → 1 | Removed unnecessary roaming timer |

---

## ✨ BENEFITS OF THESE FIXES

1. **Architectural Correctness**
   - Variables in right location (player_variables.yaml)
   - Uses native MPF rotation mechanics
   - Follows MPF best practices

2. **Simpler Code**
   - No manual index tracking needed
   - No extra timers
   - Cleaner event flow

3. **More Reliable**
   - Shot groups handle rotation internally
   - Player variables properly scoped
   - Explicit syntax prevents misunderstandings

4. **Better Maintainability**
   - Variables easily found in central config
   - Shot rotation follows standard MPF patterns
   - Clear event conditions

---

## 🔧 TECHNICAL NOTES

### Player Variable Syntax
When referencing player variables:
- **In scoring**: `current_player.variable_name`
- **In conditions**: `current_player.variable_name:value`
- **In variable_player**: `variable_player|variable_name|action:value`

### Shot Group Rotation
When a shot group is configured with `rotate_events`:
- Each event listed advances the shot group
- `rotate_events: timer_tzeench_mode_timer_tick` advances on every timer tick
- Use `shot_group_name_rotate_right` to manually rotate right
- Use `shot_group_name_rotate_left` to manually rotate left

### Stage Conditions
Filter events by player variable:
```yaml
event_name|current_player.variable_name:expected_value:
  - action
```

---

## ✅ FILES MODIFIED

1. **modes/tzeench/config/tzeench.yaml**
   - Removed `variables:` section
   - Removed `tzeench_roaming_advance` timer
   - Updated shot groups with `rotate_events`
   - Updated all event conditions to use `current_player.variable`
   - Updated scoring references to use `current_player.tzeench_shot_value`
   - Updated all roaming shot hit events to call `shot_tzeench_roaming_shots_rotate_right`

2. **config/player_variables.yaml**
   - Added `tzeench_shots_hit`
   - Added `tzeench_stage`
   - Added `tzeench_shot_value`
   - Added `tzeench_stage2_shots_hit`
   - Added `tzeench_stage3_shots_hit`

---

## 🎯 NEXT STEPS

The mode is now architecturally correct and ready for:
1. Build verification
2. Testing with the 32-item checklist
3. Balance adjustments
4. Integration with other modes

All mechanics remain the same - only the underlying implementation is now cleaner and more MPF-idiomatic.
