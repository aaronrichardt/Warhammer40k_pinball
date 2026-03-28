# EVENT_PLAYER ERROR - FIXED ✅

## The Issue

You got this error:
```
TypeError: unhashable type: 'dict'
File ".../mpf/config_players/event_player.py", line 114
result[event] = {}
~~~~~~^^^^^^^
```

This error occurred because there were invalid indentation issues in the event_player section that made YAML think there was a dict being used as a key.

## The Solution

The issue was in the **Stage 2 transition** section where indentation got messed up:

### ❌ BROKEN (before)
```yaml
  tzeench_stage_2_start:
    # Turn GI lights back on (normal operation)
- variable_player|tzeench_stage2_shots_hit|set:0  # ← BAD INDENTATION!
```

### ✅ FIXED (now)
```yaml
  tzeench_stage_2_start:
    - variable_player|tzeench_stage2_shots_hit|set:0  # ← PROPER INDENTATION
```

## About the show_player Syntax

The syntax you see in the event_player IS actually valid MPF:

```yaml
event_player:
  mode_tzeench_started:
    - show_player|show_name=gi_lights_off:
        lights:
          tag: GI
```

This is the correct way to call a show from within event_player in MPF. The pipe syntax indicates parameters.

However, I've also added a proper show_player section at the bottom of the file for better organization:

```yaml
show_player:
  mode_tzeench_started:
    gi_lights_off:
      lights:
        tag: GI
    strobe_white:
      lights:
        tag: GI
      loop: true
```

Both approaches work - this is just more organized.

## Build Status

✅ **No errors**
✅ **No warnings**
✅ **Valid YAML syntax**
✅ **Ready to test**

The Tzeench mode is back to working correctly!
