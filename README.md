# Performance limit for Xiaomi with Qualcomm Gen 1 CPU

> Limit CPU and GPU performance to desired level on Xiaomi devices with Qualcomm Gen 1 CPU

## Setup

Download and install the module. See [Releases](https://github.com/mgrybyk/perf-limit-magisk/releases).

## Configuration

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

### max_pwrlevel

`max_pwrlevel`

Allow manually override CPU frequencies and GPU power limit.
`0` - disable limit. `8` - max power limit

Example: `cpu_gpu_limit=7`

### policy0_scaling_max_freq

`policy0_scaling_max_freq`

CPUs 1-4. See `/sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies` for available values.

Example: `policy0_scaling_max_freq=960000`

### policy4_scaling_max_freq

`policy4_scaling_max_freq`

CPUs 5-7. See `/sys/devices/system/cpu/cpufreq/policy4/scaling_available_frequencies` for available values.

Example: `policy4_scaling_max_freq=1440000`

### policy7_scaling_max_freq

`policy7_scaling_max_freq`

CPU 8. See `/sys/devices/system/cpu/cpufreq/policy7/scaling_available_frequencies` for available values.

Example: `policy7_scaling_max_freq=1958400`
