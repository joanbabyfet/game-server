#!/bin/bash

docker exec -it skynet sh -c "
cd /app/game &&
/app/skynet/skynet config/config.lua
"