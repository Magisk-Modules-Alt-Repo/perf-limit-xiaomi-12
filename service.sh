# vars
CONFIG_DIR=/sdcard/.perf-limit-magisk
CONFIG_PATH=${CONFIG_DIR}/config.prop

GPU_PATH=/sys/class/kgsl/kgsl-3d0/max_pwrlevel
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
if [ ! -f "${CONFIG_PATH}" ] ; then
    mkdir -p "$CONFIG_DIR"
    echo "perf-limit: Writing default config to $CONFIG_PATH" >> ${LOG_FILE}

    echo "# no whitespaces allowed! Do not change anything else including comments!" > ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
    echo "# 0 - Disable limit completely. S:1860,T(C):67+" >> ${CONFIG_PATH}
    echo "# 1 - Very hot. Max performance with minimum temp decrease. S:1845,T(C):64" >> ${CONFIG_PATH}
    echo "# 2 - Quite hot. Good performance, some temp decrease. S:1654,T(C):56" >> ${CONFIG_PATH}
    echo "# 3 - Same as 3 but with slightly lower CPU frequencies. I recommnd #2 and #3 modern for gaming. S:1648,T(C):55.5" >> ${CONFIG_PATH}
    echo "# 4 - [Recommended] Somewhat hot. Ok performance, noticeable temp decrease. S:1435,T(C):53" >> ${CONFIG_PATH}
    echo "# 5 - Not hot. Reduced performance, significant temp decrease. S:1184,T(C):45 " >> ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
    echo "cpu_gpu_limit=4" >> ${CONFIG_PATH}
    echo "" >> ${CONFIG_PATH}
else
    echo "perf-limit: using existing config ${CONFIG_PATH}" >> ${LOG_FILE}
fi;

# log config and defaults
LIMIT_PROFILE=$(grep "cpu_gpu_limit" ${CONFIG_PATH} | cut -d "=" -f2)
echo "perf-limit: cpu_gpu_limit=${LIMIT_PROFILE}" >> ${LOG_FILE}
echo "perf-limit: kgsl gpu is '${GPU_POWER_LIMIT_ORIG}'" >> ${LOG_FILE}
echo "perf-limit: policy 4 is '${POLICY_4_MAX_FREQ_ORIG}'" >> ${LOG_FILE}
echo "perf-limit: policy 7 is '${POLICY_7_MAX_FREQ_ORIG}'" >> ${LOG_FILE}

echo "perf-limit: perf-limit service is running..." >> ${LOG_FILE}

LIMIT_PROFILE_PREV=initial

while true; do
    # read config value
    if [ -f "${CONFIG_PATH}" ] ; then
        LIMIT_PROFILE=$(grep "cpu_gpu_limit" ${CONFIG_PATH} | cut -d "=" -f2)
    else
        echo "perf-limit: config file deleted. perf-limit service is stopping..." >> ${LOG_FILE}
        exit;
    fi;

    # reading current system values
    GPU_POWER_LIMIT_TMP=$(cat "${GPU_PATH}")
    POLICY_4_MAX_FREQ_TMP=$(cat "${POLICY_4_PATH}")
    POLICY_7_MAX_FREQ_TMP=$(cat "${POLICY_4_PATH}")
  
    # choosing new values based on config
    if [ "${LIMIT_PROFILE}" == "1" ] ; then
        GPU_POWER_LIMIT=5
        POLICY_4_MAX_FREQ=2112000
        POLICY_7_MAX_FREQ=2054400
    elif [ "${LIMIT_PROFILE}" == "2" ] ; then
        GPU_POWER_LIMIT=6
        POLICY_4_MAX_FREQ=1996800
        POLICY_7_MAX_FREQ=1958400
    elif [ "${LIMIT_PROFILE}" == "3" ] ; then
        GPU_POWER_LIMIT=6
        POLICY_4_MAX_FREQ=1881600
        POLICY_7_MAX_FREQ=1843200
    elif [ "${LIMIT_PROFILE}" == "4" ] ; then
        GPU_POWER_LIMIT=7
        POLICY_4_MAX_FREQ=1881600
        POLICY_7_MAX_FREQ=1843200
    elif [ "${LIMIT_PROFILE}" == "5" ] ; then
        GPU_POWER_LIMIT=8
        POLICY_4_MAX_FREQ=1766400
        POLICY_7_MAX_FREQ=1728000
    else
        GPU_POWER_LIMIT=$GPU_POWER_LIMIT_ORIG
        POLICY_4_MAX_FREQ=$POLICY_4_MAX_FREQ_ORIG
        POLICY_7_MAX_FREQ=$POLICY_7_MAX_FREQ_ORIG;
    fi

    if [ "${LIMIT_PROFILE_PREV}" != "${LIMIT_PROFILE}" ] ; then
        LIMIT_PROFILE_PREV="${LIMIT_PROFILE}"
        echo "perf-limit: applying new values:" >> ${LOG_FILE}
        echo "perf-limit: kgsl gpu to '${GPU_POWER_LIMIT}'" >> ${LOG_FILE}
        echo "perf-limit: policy 4 to '${POLICY_4_MAX_FREQ}'" >> ${LOG_FILE}
        echo "perf-limit: policy 7 to '${POLICY_7_MAX_FREQ}'" >> ${LOG_FILE}
    fi

    # writing new values if needed
    if [ "${GPU_POWER_LIMIT_TMP}" != "${GPU_POWER_LIMIT}" ] ; then
        echo "${GPU_POWER_LIMIT}" > ${GPU_PATH}
    fi
    if [ "${POLICY_4_MAX_FREQ_TMP}" != "${POLICY_4_MAX_FREQ}" ] ; then
        echo "${POLICY_4_MAX_FREQ}" > ${POLICY_4_PATH}
    fi
    if [ "${POLICY_7_MAX_FREQ_TMP}" != "${POLICY_7_MAX_FREQ}" ] ; then
        echo "${POLICY_7_MAX_FREQ}" > ${POLICY_7_PATH}
    fi

    sleep 15
done
