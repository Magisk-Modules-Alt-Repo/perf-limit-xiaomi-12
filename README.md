# Performance limit for Xiaomi with Qualcomm Gen 1 CPU

> Limit CPU and GPU performance to desired level on Xiaomi devices with Qualcomm Gen 1 CPU

Tested on Xiaomi 12 Pro Global, Android 13, Xiaomi.eu 14.0.14.0

## Setup

Download and install the module. See [Releases](https://github.com/mgrybyk/perf-limit-magisk/releases).

## Configuration

Config file location: `/sdcard/.perf-limit-magisk/config.prop`

Note: `.perf-limit-magisk` is a hidden folder.

No need to reboot the devices after making changes to the config!
Check magisk logs after making updating the config file. 
Your changes will be reflected within 20 seconds.

### cpu_gpu_limit

`cpu_gpu_limit`

- `0` - Disable limit completely. S:1860,T(C):67+
- `1` - Very hot. Max performance with minimum temp decrease. S:1845,T(C):64
- `2` - Quite hot. Good performance, some temp decrease. S:1654,T(C):56
- `3` - Same as 3 but with slightly lower CPU frequencies. I recommnd #2 and #3 modern for gaming. S:1648,T(C):55.5
- `4` - Somewhat hot. Ok performance, noticeable temp decrease. S:1435,T(C):53
- `5` - [Recommended] Not hot. Reduced performance, significant temp decrease. S:1184,T(C):45
- `6` - Not hot. Similar with 5 but with lower CPU frequencies
- `7` - Not hot. Similar with 6 but with even lower CPU frequencies

Example: `cpu_gpu_limit=5`

### Override max_pwrlevel

`max_pwrlevel`

Allow manually override CPU frequencies and GPU power limit.
`0` - disable limit. `8` - max power limit

Example: `cpu_gpu_limit=7`

### Override policy0_scaling_max_freq

`policy0_scaling_max_freq`

CPUs 1-4. See `/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies` for available values.

Example: `policy0_scaling_max_freq=960000`

### Override policy4_scaling_max_freq

`policy4_scaling_max_freq`

CPUs 5-7. See `/sys/devices/system/cpu/cpufreq/policy4/scaling_available_frequencies` for available values.

Example: `policy4_scaling_max_freq=1440000`

### Override policy7_scaling_max_freq

`policy7_scaling_max_freq`

CPU 8. See `/sys/devices/system/cpu/cpufreq/policy7/scaling_available_frequencies` for available values.

Example: `policy7_scaling_max_freq=1958400`

## Logs

Example log output:

```
perf-limit: start, waiting for /sdcard
perf-limit: Writing default config to ./config.prop
perf-limit: cpu_gpu_limit=5
perf-limit: current kgsl gpu value is '0'
perf-limit: current policy 0 value is '1728000'
...
perf-limit: perf-limit service is running...
perf-limit: applying new values:
perf-limit: updating kgsl gpu to '8'
perf-limit: updating policy 4 to '1766400'
...
```
