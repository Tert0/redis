# Custom Docker Redis Image


## Features

- Activate Redis Modules (Preinstalled or Custom)
- Preinstalled Redis Modules
    - Redis JSON
    - Redis Search
    - Redis Bloom
    - Redis Timeseries
- Set Custem Start Paramterers
- Set Password, Memory Limit with an Environment Variable


## Environment Variables

### `REDIS_MODULES`

A list of all Redis Modules to activate.
The list will get splitted by `,` and `;`.
You can either enter the name of a default module or the path to the module.
If this argument is not given, it will be `REDIS_JSON,REDIS_SEARCH` by default.

**Default Modules**:

- `REDIS_JSON`
- `REDIS_SEARCH`
- `REDIS_BLOOM`
- `REDIS_TIMESERIES`

### `REDIS_PARAMETERS`

You can give custom parameters to the `redis-server`.
These paramters can be found in the [Redis Docs](https://redis.io/topics/config).

### `REDIS_PASSWORD`

You can set the Password for the Redis Database.
This will set with the paramter `--requirepass <password>`

### `REDIS_MAXMEMORY`

You can set the Redis maximum Memory.
This will set with the paramter `--maxmemory <memory-limit>`

**Important**
    
    You have to specify the unit. (e.g. `kb`, `mb`, `gb`)



## License

This Project is released under the [MIT License](https://mit-license.org/)