getModulePath() {
    local module=$1
    case $module in
        "REDIS_JSON")
            echo "/usr/lib/redisjson.so"
            ;;
        "REDIS_SEARCH")
            echo "/usr/lib/redisearch.so"
            ;;
        "REDIS_BLOOM")
            echo "/usr/lib/redisbloom.so"
            ;;
        "REDIS_TIMESERIES")
            echo "/usr/lib/redistimeseries.so"
            ;;
        *)
            echo $module
            ;;
    esac
}

DEFAULT_REDIS_MODULES="REDIS_JSON,REDIS_SEARCH"

if [[ $REDIS_MODULES == "" ]]; then
    REDIS_MODULES=$DEFAULT_REDIS_MODULES
fi

modules_str=${REDIS_MODULES//";"/","}

readarray -d "," -t modules<<<"$modules_str"

echo "Loading Modules: ${modules[@]}"

command="redis-server"

declare -A parameters

parameters["REDIS_PARAMTERS"]="$REDIS_PARAMTERS"
parameters["REDIS_PASSWORD"]="--requirepass $REDIS_PASSWORD"
parameters["MAXMEMORY"]="--maxmemory $MAXMEMORY"

for parameter_name in "${!parameters[@]}"; do    
    if [[ ${!parameter_name} != "" ]]; then
        command="$command ${parameters[$parameter_name]}"
    fi
done

for module in "${modules[@]}"
do
    path=$(getModulePath $module)
    command="$command --loadmodule $path"
done

echo "Starting Redis with command: $command"
echo ""

$command