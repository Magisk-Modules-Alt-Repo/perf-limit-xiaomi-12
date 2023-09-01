# vars
CONFIG_DIR=/sdcard/.perf-limit-magisk
CONFIG_PATH=${CONFIG_DIR}/config.prop

GPU_PATH=/sys/class/kgsl/kgsl-3d0/max_pwrlevel
POLICY_0_PATH=/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
POLICY_4_PATH=/sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
POLICY_7_PATH=/sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq

LOG_FILE=/cache/magisk.log

# starting
echo "perf-limit: start, waiting for /sdcard" >> ${LOG_FILE}

while [ ! -d /sdcard ]; do
    sleep 5
done

# GPU
if [ -f "${GPU_PATH}" ] ; then
    GPU_POWER_LIMIT_ORIG=$(cat "${GPU_PATH}")
else
    echo "perf-limit: ${GPU_PATH} not found. Exiting." >> ${LOG_FILE}
    exit
fi;

# POLICY_0
if [ -f "${POLICY_0_PATH}" ] ; then
    POLICY_0_MAX_FREQ_ORIG=$(cat "${POLICY_0_PATH}")
else
    echo "perf-limit: ${POLICY_0_PATH} not found. Exiting." >> ${LOG_FILE}
    exit
fi;

# POLICY_4
if [ -f "${POLICY_4_PATH}" ] ; then
    POLICY_4_MAX_FREQ_ORIG=$(cat "${POLICY_4_PATH}")
else
    echo "perf-limit: ${POLICY_4_PATH} not found. Exiting." >> ${LOG_FILE}
    exit
fi;

# POLICY_7
if [ -f "${POLICY_7_PATH}" ] ; then
    POLICY_7_MAX_FREQ_ORIG=$(cat "${POLICY_7_PATH}")
else
    echo "perf-limit: ${POLICY_7_PATH} not found. Exiting." >> ${LOG_FILE}
    exit
fi;

# create config
if [ -f "${CONFIG_PATH}" ] ; then
    LIMIT_PROFILE=$(grep "cpu_gpu_limit" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_GPU_POWER_LIMIT=$(grep "max_pwrlevel" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_0_SCALING_MAX_FREQ=$(grep "policy0_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_4_SCALING_MAX_FREQ=$(grep "policy4_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_7_SCALING_MAX_FREQ=$(grep "policy7_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)
    echo "perf-limit: using existing config ${CONFIG_PATH}" >> ${LOG_FILE}
else
    LIMIT_PROFILE=5;
    echo "perf-limit: Writing default config to $CONFIG_PATH" >> ${LOG_FILE}
fi
write_config()
{
    mkdir -p "$CONFIG_DIR"

    echo "# no whitespaces allowed! Do not change anything else including comments!" > ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
    echo "# 0 - Disable limit completely. S:1860,T(C):67+" >> ${CONFIG_PATH}
    echo "# 1 - Very hot. Max performance with minimum temp decrease. S:1845,T(C):64" >> ${CONFIG_PATH}
    echo "# 2 - Quite hot. Good performance, some temp decrease. S:1654,T(C):56" >> ${CONFIG_PATH}
    echo "# 3 - Same as 3 but with slightly lower CPU frequencies. I recommnd #2 and #3 modern for gaming. S:1648,T(C):55.5" >> ${CONFIG_PATH}
    echo "# 4 - Somewhat hot. Ok performance, noticeable temp decrease. S:1435,T(C):53" >> ${CONFIG_PATH}
    echo "# 5 - [Recommended] Not hot. Reduced performance, significant temp decrease. S:1184,T(C):45" >> ${CONFIG_PATH}
    echo "6 and 7 are similar with 5 but with lower CPU frequencies" >> ${CONFIG_PATH}
    echo "# 6 - Not hot. Reduced performance" >> ${CONFIG_PATH}
    echo "# 7 - Not hot. Reduced performance" >> ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
    echo "cpu_gpu_limit=${LIMIT_PROFILE}" >> ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
    echo "# allow manually override CPU frequencies and GPU power limit" >> ${CONFIG_PATH}
    echo "# GPU. 0 - disable limit. 8 - max power limit" >> ${CONFIG_PATH}
    echo "max_pwrlevel=${OVERRIDE_GPU_POWER_LIMIT}" >> ${CONFIG_PATH}
    echo "# CPUs 1-4. See /sys/devices/system/cpu/cpufreq/policy0/scaling_available_frequencies" >> ${CONFIG_PATH}
    echo "policy0_scaling_max_freq=${OVERRIDE_POLICY_0_SCALING_MAX_FREQ}" >> ${CONFIG_PATH}
    echo "# CPUs 5-7. See /sys/devices/system/cpu/cpufreq/policy4/scaling_available_frequencies" >> ${CONFIG_PATH}
    echo "policy4_scaling_max_freq=${OVERRIDE_POLICY_4_SCALING_MAX_FREQ}" >> ${CONFIG_PATH}
    echo "# CPU 8. See /sys/devices/system/cpu/cpufreq/policy7/scaling_available_frequencies" >> ${CONFIG_PATH}
    echo "policy7_scaling_max_freq=${OVERRIDE_POLICY_7_SCALING_MAX_FREQ}" >> ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
}
write_config;

# log config and defaults
echo "perf-limit: cpu_gpu_limit=${LIMIT_PROFILE}" >> ${LOG_FILE}
if [ -n "${OVERRIDE_GPU_POWER_LIMIT}" ] ; then
    echo "perf-limit: max_pwrlevel=${OVERRIDE_GPU_POWER_LIMIT}" >> ${LOG_FILE}
fi
if [ -n "${OVERRIDE_POLICY_0_SCALING_MAX_FREQ}" ] ; then
    echo "perf-limit: policy0_scaling_max_freq=${OVERRIDE_POLICY_0_SCALING_MAX_FREQ}" >> ${LOG_FILE}
fi
if [ -n "${OVERRIDE_POLICY_4_SCALING_MAX_FREQ}" ] ; then
    echo "perf-limit: policy4_scaling_max_freq=${OVERRIDE_POLICY_4_SCALING_MAX_FREQ}" >> ${LOG_FILE}
fi
if [ -n "${OVERRIDE_POLICY_7_SCALING_MAX_FREQ}" ] ; then
    echo "perf-limit: policy7_scaling_max_freq=${OVERRIDE_POLICY_7_SCALING_MAX_FREQ}" >> ${LOG_FILE}
fi
echo "perf-limit: current kgsl gpu value is '${GPU_POWER_LIMIT_ORIG}'" >> ${LOG_FILE}
echo "perf-limit: current policy 0 value is '${POLICY_0_MAX_FREQ_ORIG}'" >> ${LOG_FILE}
echo "perf-limit: current policy 4 value is '${POLICY_4_MAX_FREQ_ORIG}'" >> ${LOG_FILE}
echo "perf-limit: current policy 7 value is '${POLICY_7_MAX_FREQ_ORIG}'" >> ${LOG_FILE}

echo "perf-limit: perf-limit service is running..." >> ${LOG_FILE}

LIMIT_PROFILE_PREV=initial

while true; do
    # read config value
    if [ ! -f "${CONFIG_PATH}" ] ; then
        echo "perf-limit: Config was deleted! Writing your config to $CONFIG_PATH" >> ${LOG_FILE}
        write_config;
    fi;

    LIMIT_PROFILE=$(grep "cpu_gpu_limit" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_GPU_POWER_LIMIT=$(grep "max_pwrlevel" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_0_SCALING_MAX_FREQ=$(grep "policy0_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_4_SCALING_MAX_FREQ=$(grep "policy4_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)
    OVERRIDE_POLICY_7_SCALING_MAX_FREQ=$(grep "policy7_scaling_max_freq" ${CONFIG_PATH} | cut -d "=" -f2)

    # reading current system values
    GPU_POWER_LIMIT_TMP=$(cat "${GPU_PATH}")
    POLICY_0_MAX_FREQ_TMP=$(cat "${POLICY_0_PATH}")
    POLICY_4_MAX_FREQ_TMP=$(cat "${POLICY_4_PATH}")
    POLICY_7_MAX_FREQ_TMP=$(cat "${POLICY_7_PATH}")
  
    # choosing new values based on config
    if [ "${LIMIT_PROFILE}" == "1" ] ; then
        GPU_POWER_LIMIT=5
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=2112000
        POLICY_7_MAX_FREQ=2054400
    elif [ "${LIMIT_PROFILE}" == "2" ] ; then
        GPU_POWER_LIMIT=6
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1996800
        POLICY_7_MAX_FREQ=1958400
    elif [ "${LIMIT_PROFILE}" == "3" ] ; then
        GPU_POWER_LIMIT=6
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1881600
        POLICY_7_MAX_FREQ=1843200
    elif [ "${LIMIT_PROFILE}" == "4" ] ; then
        GPU_POWER_LIMIT=7
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1881600
        POLICY_7_MAX_FREQ=1843200
    elif [ "${LIMIT_PROFILE}" == "5" ] ; then
        GPU_POWER_LIMIT=8
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1766400
        POLICY_7_MAX_FREQ=1728000
    elif [ "${LIMIT_PROFILE}" == "6" ] ; then
        GPU_POWER_LIMIT=8
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1440000
        POLICY_7_MAX_FREQ=1497600
    elif [ "${LIMIT_PROFILE}" == "7" ] ; then
        GPU_POWER_LIMIT=8
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=1324800
        POLICY_7_MAX_FREQ=1401600
    else
        GPU_POWER_LIMIT=$GPU_POWER_LIMIT_ORIG
        POLICY_0_MAX_FREQ=$POLICY_0_MAX_FREQ_ORIG
        POLICY_4_MAX_FREQ=$POLICY_4_MAX_FREQ_ORIG
        POLICY_7_MAX_FREQ=$POLICY_7_MAX_FREQ_ORIG;
    fi

    if [ -n "${OVERRIDE_GPU_POWER_LIMIT}" ] ; then
        GPU_POWER_LIMIT=${OVERRIDE_GPU_POWER_LIMIT}
    fi
    if [ -n "${OVERRIDE_POLICY_0_SCALING_MAX_FREQ}" ] ; then
        POLICY_0_MAX_FREQ=${OVERRIDE_POLICY_0_SCALING_MAX_FREQ}
    fi
    if [ -n "${OVERRIDE_POLICY_4_SCALING_MAX_FREQ}" ] ; then
        POLICY_4_MAX_FREQ=${OVERRIDE_POLICY_4_SCALING_MAX_FREQ}
    fi
    if [ -n "${OVERRIDE_POLICY_7_SCALING_MAX_FREQ}" ] ; then
        POLICY_7_MAX_FREQ=${OVERRIDE_POLICY_7_SCALING_MAX_FREQ}
    fi

    if [ "${LIMIT_PROFILE_PREV}" != "${LIMIT_PROFILE}" ] ; then
        LIMIT_PROFILE_PREV="${LIMIT_PROFILE}"
        echo "perf-limit: applying new values:" >> ${LOG_FILE}
    fi

    # writing new values if needed
    if [ "${GPU_POWER_LIMIT_TMP}" != "${GPU_POWER_LIMIT}" ] ; then
        echo "perf-limit: updating kgsl gpu to '${GPU_POWER_LIMIT}'" >> ${LOG_FILE}
        echo "${GPU_POWER_LIMIT}" > ${GPU_PATH}
    fi
    if [ "${POLICY_0_MAX_FREQ_TMP}" != "${POLICY_0_MAX_FREQ}" ] ; then
        echo "perf-limit: updating policy 0 to '${POLICY_0_MAX_FREQ}'" >> ${LOG_FILE}
        echo "${POLICY_0_MAX_FREQ}" > ${POLICY_0_PATH}
    fi
    if [ "${POLICY_4_MAX_FREQ_TMP}" != "${POLICY_4_MAX_FREQ}" ] ; then
        echo "perf-limit: updating policy 4 to '${POLICY_4_MAX_FREQ}'" >> ${LOG_FILE}
        echo "${POLICY_4_MAX_FREQ}" > ${POLICY_4_PATH}
    fi
    if [ "${POLICY_7_MAX_FREQ_TMP}" != "${POLICY_7_MAX_FREQ}" ] ; then
        echo "perf-limit: updating policy 7 to '${POLICY_7_MAX_FREQ}'" >> ${LOG_FILE}
        echo "${POLICY_7_MAX_FREQ}" > ${POLICY_7_PATH}
    fi

    sleep 20
done
