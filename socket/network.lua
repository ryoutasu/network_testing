local socket = require 'socket'
local bitser = require 'lib.bitser'

local Network = Class{}

function Network:address()
    return self.ip .. '/' .. self.port
end

function Network:init(port)
    self.port = port
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setsockname("0.0.0.0", port)
    self.udp:setoption("broadcast", true)

    -- self.bitser = bitser
    
    local received, i = false, 0
    while not received and i < 10 do
        local r = math.random(1, 65536)

        self.udp:sendto(r, '255.255.255.255', port)
        local msg, ip, port = self.udp:receivefrom()
        
        if tonumber(msg) == r then
            self.ip = ip
            received = true
        end

        i = i + 1
    end
    if not received then
        print("Error: can't find IP")
    end

    self.clients = {}
end

-- function Network:connect(ip, port)
--     self.udp:setpeername(ip, port)
-- end

function Network:send(data, ip, port)
    local serializedData = bitser.dumps(data)

    self.udp:sendto(serializedData, ip, port or self.port)
end

function Network:broadcast(data, port)
    self:send(data, '255.255.255.255', port or self.port)
end

function Network:receive()
    -- local data, msg_or_ip, port_or_nil
    -- repeat
        local serializedData, msg_or_ip, port_or_nil = self.udp:receivefrom()
        if serializedData then
            local data = bitser.loads(serializedData)
            return data, msg_or_ip, port_or_nil
            
        elseif msg_or_ip ~= 'timeout' then
			error("Network error: "..tostring(msg_or_ip))

            return false
        end
    -- until not data
end

return Network