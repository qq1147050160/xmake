--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        fasturl.lua
--

-- imports
import("ping")

-- parse host from url
function _parse_host(url)

    -- init host cache
    _g._URLHOSTS = _g._URLHOSTS or {}

    -- http[s]://xxx.com/.. or git@git.xxx.com:xxx/xxx.git
    local host = _g._URLHOSTS[url] or url:match("://(.-)/") or url:match("@(.-):")

    -- save to cache
    _g._URLHOSTS[url] = host

    -- ok
    return host
end

-- add urls
function add(urls)

    -- get current ping info
    local pinginfo = _g._PINGINFO or {}

    -- add ping hosts
    _g._PINGHOSTS = _g._PINGHOSTS or {}
    for _, url in ipairs(urls) do

        -- parse host
        local host = _parse_host(url)

        -- this host has not been tested?
        if host and not pinginfo[host] then
            table.insert(_g._PINGHOSTS, host)
        end
    end
end

-- sort urls
function sort(urls)

    -- ping hosts
    local pinghosts = table.unique(_g._PINGHOSTS or {})
    if pinghosts and #pinghosts > 0 then
 
        -- ping them and test speed, enable cache by default
        local pinginfo = ping(pinghosts)
        
        -- merge to ping info
        _g._PINGINFO = table.join(_g._PINGINFO or {}, pinginfo) 
    end

    -- sort urls by the ping info
    local pinginfo = _g._PINGINFO or {}
    table.sort(urls, function(a, b) 
        a = pinginfo[_parse_host(a) or ""] or 65536
        b = pinginfo[_parse_host(b) or ""] or 65536
        return a < b 
    end)

    -- clear hosts
    _g._PINGHOSTS = {}

    -- ok
    return urls
end

