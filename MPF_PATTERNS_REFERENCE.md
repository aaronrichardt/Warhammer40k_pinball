# MPF BEST PRACTICES - PATTERNS LEARNED

## Player Variables: Correct Architecture

### ❌ WRONG: Variables in mode config
```yaml
# modes/mymode/config/mymode.yaml
variables:
  my_var: 0
  my_counter: 100
```
**Problem**: Variables are mode-scoped, lost when mode ends, not persisted.

### ✅ CORRECT: Variables in player_variables.yaml
```yaml
# config/player_variables.yaml
player_vars:
  my_var:
    initial_value: 0
  my_counter:
    initial_value: 100
```
**Benefits**: Player-scoped, persists across modes, accessible to all modes, proper MPF architecture.

---

## Variable References: Correct Syntax

### Scoring
```yaml
# ❌ WRONG
- scoring|score:(my_var)

# ✅ CORRECT
- scoring|score:current_player.my_var
```

### Variable Player Actions
```yaml
# ✅ CORRECT - This works in variable_player
- variable_player|my_var|add:100
- variable_player|my_var|set:50
- variable_player|my_var|mult:2
```

### Event Conditions
```yaml
# ❌ WRONG
my_shot_hit|my_var:5:
  - action

# ✅ CORRECT
my_shot_hit|current_player.my_var:5:
  - action
```

---

## Shot Group Rotation: Correct Pattern

### ❌ WRONG: Manual index tracking
```yaml
variables:
  shot_index: 0  # Wrong place!

timers:
  advance_timer:
    start_value: 6
    restart_on_complete: true
    
event_player:
  timer_advance_timer_complete:
    - variable_player|shot_index|add:1

# Shot sequences manually managed
shot_tzeench_center_ramp_shot_hit:
  - variable_player|shot_index|set:1
shot_tzeench_left_orbit_shot_hit:
  - variable_player|shot_index|set:2
```
**Problems**: 
- Manual index management
- Error-prone
- Extra timers needed
- Not using MPF's built-in features

### ✅ CORRECT: Native shot group rotation
```yaml
shot_groups:
  roaming_shots:
    shots: shot1, shot2, shot3, shot4, shot5
    rotate_events: timer_main_timer_tick  # Auto-rotate on timer tick
    enable_events: mode_started
    disable_events: mode_ended

event_player:
  any_shot_hit:
    - shot_roaming_shots_rotate_right  # Manual rotation on hit
```
**Benefits**:
- Built-in shot group rotation
- Simpler code
- No manual index tracking
- Native MPF pattern

---

## Shot Group Rotation Events

### Configuration Options

```yaml
shot_groups:
  my_group:
    shots: shot1, shot2, shot3
    
    # Option 1: Auto-rotate on events
    rotate_events: timer_main_timer_tick
    
    # Option 2: Rotate left on specific event
    rotate_left_events: flipper_left_active
    
    # Option 3: Rotate right on specific event
    rotate_right_events: flipper_right_active
    
    # Option 4: Auto-rotate right on event (default rotate direction)
    rotate_events: some_event
```

### Manual Rotation in Event Player

```yaml
event_player:
  some_event:
    - shot_my_group_rotate_right   # Manually rotate right
    - shot_my_group_rotate_left    # Manually rotate left
    - shot_my_group_reset          # Reset to first shot
    - shot_my_group_lighting_hit   # Light all shots
```

---

## Conditional Events: Variable Filtering

### Basic Structure
```yaml
event_name|condition:value:
  - action
```

### Examples

```yaml
# Check if player variable equals value
shot_hit|current_player.my_var:5:
  - scoring|score:1000000

# Check if mode stage is 2
shot_hit|current_player.mode_stage:2:
  - show_player|show_name:stage2_effect

# Check if counter is greater than or equal to 9
variable_player|variable_name|change:
  - event_player|post:next_mode_start
  
# Using variable comparison
variable_my_counter|ge:10:
  - event_player|post:counter_reached_ten
```

---

## Complete Tzeench Example: Correct Pattern

```yaml
# config/player_variables.yaml
player_vars:
  tzeench_shots_hit:
    initial_value: 0
  tzeench_stage:
    initial_value: 1
  tzeench_shot_value:
    initial_value: 100000

# modes/tzeench/config/tzeench.yaml
shot_groups:
  tzeench_roaming_shots:
    shots: ramp, orbit_left, orbit_right, loop_left, loop_right, target1, scoop, vuk, snikt
    rotate_events: timer_tzeench_mode_timer_tick
    enable_events: mode_tzeench_started

event_player:
  # Any roaming shot hit
  shot_tzeench_center_ramp_shot_hit:
    - variable_player|tzeench_shots_hit|add:1
    - variable_player|tzeench_shot_value|add:10000
    - scoring|score:current_player.tzeench_shot_value
    - shot_tzeench_roaming_shots_rotate_right
    - delay:15s|event:tzeench_reset_roaming_shots

  # Stage 2 specific handling
  shot_tzeench_center_ramp_shot_hit|current_player.tzeench_stage:2:
    - variable_player|tzeench_stage2_shots_hit|add:1
    - scoring|score:250000
    - shot_tzeench_super_jackpot_lighting_hit

  # Check for stage advancement
  variable_tzeench_shots_hit|ge:9:
    - variable_player|tzeench_stage|set:2
    - event_player|post:tzeench_stage_2_start
```

---

## Key Takeaways

1. **Variables Live in player_variables.yaml**
   - Not in mode configs
   - Accessible across all modes
   - Persists with player

2. **Reference Variables Correctly**
   - Scoring: `current_player.variable_name`
   - Conditions: `current_player.variable_name:value`
   - Variable player: `variable_player|name|action:value`

3. **Shot Groups Handle Rotation Natively**
   - Use `rotate_events`, `rotate_left_events`, `rotate_right_events`
   - Don't manually track shot index
   - Use `shot_group_rotate_right`, etc. for manual control

4. **Event Conditions Use Full Variable Path**
   - Always use `current_player.variable_name` in event conditions
   - Not `variable_name` alone
   - Ensures proper scope and filtering

5. **Follow MPF Conventions**
   - Keep configs clean and simple
   - Use built-in features (shot groups, event conditions)
   - Let framework handle complexity

---

## Testing the Patterns

To verify player variables work:
1. Start a game
2. Hit a roaming shot
3. Check that `tzeench_shots_hit` increments
4. Verify score updates with `tzeench_shot_value`
5. Confirm stage conditions filter events correctly

---

## MPF Documentation References

- **Player Variables**: `/config/player_variables.yaml` in config root
- **Shot Groups**: Built-in rotation via `rotate_events`
- **Event Conditions**: `event_name|condition:value:` syntax
- **Variable References**: `current_player.variable_name` for all access

