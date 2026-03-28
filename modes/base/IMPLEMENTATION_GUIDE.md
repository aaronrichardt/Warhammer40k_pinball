# Base Mode Shot Combos - Implementation Guide

## Quick Start

The shot combo system is now configured in `modes/base/config/base.yaml`. Here's what you need to do to make it fully functional:

---

## Step 1: Define Player Variables

Add to `config/player_variables.yaml`:

```yaml
playfield_multiplier:
  initial_value: 1
  value_type: int
  
ball_lock_qualified_shots:
  initial_value: 0
  value_type: int
```

---

## Step 2: Create Show Files

The combos reference show files that need to exist. Create these in your `shows/` directory:

### shows/off.yaml
```yaml
#config_version=6
shows:
  off:
    - duration: 1
      lights:
        (leds): off
```

### shows/flash.yaml
```yaml
#config_version=6
shows:
  flash:
    - duration: 0.5
      lights:
        (leds): red
    - duration: 0.5
      lights:
        (leds): off
```

### shows/on.yaml
```yaml
#config_version=6
shows:
  on:
    - duration: 1
      lights:
        (leds): red
```

---

## Step 3: Define LED Tokens

Add to `config/lights.yaml` (or create mapping for show tokens):

```yaml
lights:
  # Combo Indicators
  combo_indicator_1:
    number: (your_board)-(pin)  # Green LED for Ramp combo
    tags: combo_light
  
  combo_indicator_2:
    number: (your_board)-(pin)  # Green LED for Loop combo
    tags: combo_light
  
  combo_indicator_3:
    number: (your_board)-(pin)  # Purple LED for Spinner combo
    tags: combo_light

  # Ramp LEDs
  l_left_ramp_arrow:
    number: (your_board)-(pin)
    tags: ramp_arrow
  
  l_right_orbit_arrow:
    number: (your_board)-(pin)
    tags: orbit_arrow
  
  l_center_ramp_arrow:
    number: (your_board)-(pin)
    tags: ramp_arrow
  
  # Spinner LEDs
  l_left_spinner_arrow:
    number: (your_board)-(pin)
    tags: spinner_arrow
  
  l_center_spinner_arrow:
    number: (your_board)-(pin)
    tags: spinner_arrow
  
  l_right_spinner_arrow:
    number: (your_board)-(pin)
    tags: spinner_arrow
```

---

## Step 4: Create Event Handlers

Create mode configs to handle the combo events. Add to modes that need to listen:

### For Ball Lock Features
Add to your ball lock mode config:

```yaml
event_player:
  ball_lock_qualification_started:
    - enable_ball_lock_shots
```

### For Hurry Up Mode
Add to your hurry up mode config:

```yaml
event_player:
  hurry_up_mode_start:
    - hurry_up_mode_qualifying
```

### For Super Mode
Add to your premium/super mode config:

```yaml
event_player:
  super_mode_qualified:
    - super_mode_start
```

---

## Step 5: Display Combo Status

Create a mode or add to an existing slide to show combo progress. Example slide config:

```yaml
slides:
  base:
    widgets:
      combo_status:
        type: text
        text: "COMBOS: Ramp=%ramp_combo_qualified% Loop=%loop_combo_qualified% Spinner=%spinner_combo_qualified%"
        x: center
        y: bottom
        anchor_x: center
        anchor_y: bottom
```

---

## How Combos Work

### Sequence Shot Mechanics

When a `sequence_shot` is defined, MPF tracks:
1. **Sequence State** - Which step of the combo you're on (0, 1, 2, etc.)
2. **Time Window** - The `delay_between` value (4-5 seconds)
3. **Completion** - When all shots hit in order within time windows

### Example Flow

**Ramp to Orbit Combo:**

```
Time 0.0s:  Player hits Left Ramp (s_left_ramp)
            → Shot 1 Complete
            → Timer starts: 5 second window

Time 2.5s:  Player hits Right Orbit (s_right_orbit)
            → Shot 2 Complete
            → Timer resets: 5 second window

Time 4.0s:  Player hits Left Spinner (s_left_spinner)
            → Shot 3 Complete
            → All shots hit in order!
            ✓ COMBO COMPLETE!
            
            Events posted:
            - ramp_to_orbit_combo_complete
            - ball_lock_qualification_started
            - playfield_multiplier_x2
            - ramp_combo_qualified
            
            Player variables updated:
            - score: +50,000
            - playfield_multiplier: +1
            - ball_lock_qualified_shots: +1

Time 5.0s:  Window closes
            Combo tracker resets, ready for next attempt
```

---

## Understanding Each Combo

### Ramp to Orbit Combo
- **Use Case:** Early game, starting features
- **Why This Sequence?** Ramps are typically wide targets, easy to hit early
- **Strategic Value:** Unlocks ball lock immediately
- **Timing:** 5 seconds is generous for ramp/orbit/spinner

### Loop Combo  
- **Use Case:** Mid-game, building up to hurry ups
- **Why This Sequence?** Inner loops are precision shots
- **Strategic Value:** Activates time pressure (hurry ups)
- **Timing:** 5 seconds for technical loop play

### Spinner Rampage
- **Use Case:** High risk/reward, late game or catch-up balls
- **Why This Sequence?** Three spinners = most time-intensive
- **Strategic Value:** Maximum multiplier + super mode
- **Timing:** 4 seconds (slightly tighter) = higher difficulty

---

## Modifying Combos

### To Change a Combo Sequence

Edit `modes/base/config/base.yaml`, find the `sequence_shots` section:

```yaml
sequence_shots:
  my_combo:
    sequences:
      - shot: shot1
        shot: shot2
        shot: shot3          # Change these
    delay_between: 5s        # Change timing (tighter/looser)
    sequence_complete_events: my_combo_complete
```

### To Add New Combo

```yaml
sequence_shots:
  brand_new_combo:
    sequences:
      - shot: scoop
        shot: center_ramp
        shot: right_orbit
    delay_between: 6s
    sequence_complete_events: brand_new_combo_complete
    show_tokens:
      leds: my_custom_led
      color: blue

event_player:
  brand_new_combo_complete:
    - my_new_event
    
variable_player:
  brand_new_combo_complete:
    score: 75000
```

### To Remove Combo

Delete the entire combo block from `sequence_shots` section.

---

## Troubleshooting

### Combo Not Triggering

**Problem:** Shots are hit but combo doesn't complete

**Solutions:**
1. Check shot names in `sequences` match defined shots
2. Verify time window is sufficient (`delay_between`)
3. Ensure switches are properly debounced
4. Check console log for missed shot hits
5. Verify playfield_multiplier variable exists

### Multiplier Not Increasing

**Problem:** Combo completes but multiplier stays same

**Solutions:**
1. Check `playfield_multiplier` variable is defined
2. Verify `variable_player` section has correct syntax
3. Check base mode priority isn't being overridden
4. Ensure combos are in base mode, not lower priority mode

### Event Not Firing

**Problem:** Combo completes but event isn't posted

**Solutions:**
1. Check event name spelled correctly in both places
2. Verify `event_player` section has correct indentation
3. Check event listeners are in higher priority modes
4. Enable debug logging: `debug: true` on sequence_shot

---

## Advanced: Combo Modifiers

### Make Combos Harder (Tighter Time Windows)

```yaml
sequence_shots:
  ramp_to_orbit_combo:
    delay_between: 3s  # Changed from 5s (much harder!)
```

### Make Combos Easier (Looser Time Windows)

```yaml
sequence_shots:
  ramp_to_orbit_combo:
    delay_between: 8s  # Changed from 5s (easier)
```

### Add More Shots to Combo

```yaml
sequence_shots:
  extended_ramp_combo:
    sequences:
      - shot: left_orbit
        shot: right_orbit
        shot: left_spinner
        shot: center_spinner  # Added 4th shot!
    delay_between: 4s
```

### Create Mode-Specific Combos

Add to `modes/mymode/config/mymode.yaml`:

```yaml
sequence_shots:
  mode_combo_1:
    sequences:
      - shot: shot_a
        shot: shot_b
        shot: shot_c
    sequence_complete_events: mode_combo_1_complete
```

---

## Performance Considerations

### Combo Tracking Overhead

- Each sequence_shot adds minimal overhead (event tracking only)
- Show playback is only for combo indicators, minimal impact
- Variable updates are lightweight

### Best Practices

1. **Limit Combos:** 3-5 active combos recommended
2. **Clear Time Windows:** Don't make windows too loose (player confusion)
3. **Event Reuse:** Post multiple events for flexibility
4. **Variable Consolidation:** Use single variables for related features

---

## Testing Guide

### Test 1: Combo Completion
```
1. Start game
2. Hit shots in exact combo order
3. Verify event posted (check logs)
4. Verify score increase
5. Verify variable updates
```

### Test 2: Time Window Expiry
```
1. Start game
2. Hit first shot
3. Wait beyond delay_between time
4. Hit remaining shots
5. Verify combo resets (doesn't complete)
```

### Test 3: Wrong Order
```
1. Start game
2. Hit shots out of sequence order
3. Verify combo doesn't complete
4. Reset and try again in correct order
```

### Test 4: Simultaneous Shots
```
1. Use mock events to simulate rapid hits
2. Verify sequence tracks correctly
3. Check ordering is maintained
```

---

## Integration Checklist

Use this before deploying combos:

```
SETUP:
☐ Player variables defined (playfield_multiplier, etc.)
☐ Show files created (off, flash, on, pulse_fast)
☐ LED definitions added to lights.yaml
☐ Base mode config updated (already done!)

FEATURES:
☐ Ball lock mode listening for ball_lock_qualification_started
☐ Hurry up mode listening for hurry_up_mode_start  
☐ Super mode listening for super_mode_qualified
☐ Scoring system using playfield_multiplier

DISPLAY:
☐ Slides showing combo progress
☐ Feedback for completed combos
☐ Multiplier display updating

TESTING:
☐ Manual combo tests pass
☐ All events firing correctly
☐ Variables updating properly
☐ No console errors
☐ Performance acceptable
```

---

## Next Steps

1. **Define player variables** (see Step 1)
2. **Create show files** (see Step 2)
3. **Map LED tokens** (see Step 3)
4. **Hook up event handlers** (see Step 4)
5. **Test combos** (see Testing Guide)
6. **Deploy and balance** (adjust time windows as needed)

---

## Questions?

Refer to Mission Pinball Framework docs:
- Sequence Shots: https://missionpinball.org/latest/game_logic/shots/sequence_shots/
- Shot Groups: https://missionpinball.org/latest/config/shot_groups/
- Events: https://missionpinball.org/latest/events/overview/
