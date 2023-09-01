ui_print "perf-limit: GPU power and CPU frequencies limit for Xiaomi 12 (Pro)."
ui_print "perf-limit: running checks..."

GPU_PATH=/sys/class/kgsl/kgsl-3d0/max_pwrlevel
POLICY_0_PATH=/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
POLICY_4_PATH=/sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
POLICY_7_PATH=/sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq

check_if_file_exist() {
    if [ ! -f "${1}" ]; then
        abort "perf-limit: won't work ${1} not found. Exiting."
    fi
}

for file in \
    ${GPU_PATH} \
    ${POLICY_0_PATH} \
    ${POLICY_4_PATH} \
    ${POLICY_7_PATH}; do
    check_if_file_exist "$file"
done

ui_print "perf-limit: all looks good! Please reboot the device."
