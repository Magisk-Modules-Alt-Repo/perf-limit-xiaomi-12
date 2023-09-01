ui_print "perf-limit: GPU power and CPU frequencies limit for Xiaomi 12 Pro."
ui_print "perf-limit: running checks..."

GPU_PATH=/sys/class/kgsl/kgsl-3d0/max_pwrlevel
POLICY_0_PATH=/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
POLICY_4_PATH=/sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
POLICY_7_PATH=/sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq

# GPU
if [ ! -f "${GPU_PATH}" ] ; then
    ui_print "perf-limit: won't work ${GPU_PATH} not found. Exiting."
    exit
fi;

# POLICY_0
if [ ! -f "${POLICY_0_PATH}" ] ; then
    ui_print "perf-limit: won't work. ${POLICY_0_PATH} not found. Exiting."
    exit
fi;

# POLICY_4
if [ ! -f "${POLICY_4_PATH}" ] ; then
    ui_print "perf-limit: won't work. ${POLICY_4_PATH} not found. Exiting."
    exit
fi;

# POLICY_7
if [ ! -f "${POLICY_7_PATH}" ] ; then
    ui_print "perf-limit: won't work ${POLICY_7_PATH} not found. Exiting."
    exit
fi;

ui_print "perf-limit: all looks good! Please reboot the device."
