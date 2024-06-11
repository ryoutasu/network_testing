local socket = require 'socket'

local Network = Class{}

function Network:init(port)
    self.port = port
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setsockname("0.0.0.0", 12345)
    self.udp:setoption("broadcast", true)

    local ip, port = self.udp:getsockname()

    self.clients = {}
end

-- function Network:connect(ip, port)
--     self.udp:setpeername(ip, port)
-- end

function Network:broadcast(data, port)
    self.udp:sendto(data, '255.255.255.255', port or self.port)
end

function Network:receive()
    -- local data, msg_or_ip, port_or_nil
    -- repeat
        local data, msg_or_ip, port_or_nil = self.udp:receivefrom()
        if data then
            return data, msg_or_ip, port_or_nil
            
        elseif msg_or_ip ~= 'timeout' then
			error("Network error: "..tostring(msg_or_ip))

            return false
        end
    -- until not data
end

return Network