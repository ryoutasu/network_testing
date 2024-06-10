local socket = require 'socket'

local Network = Class{}

function Network:init(port)
    self.port = port
    self.udp = socket.udp()
    self.udp:settimeout(1)
    self.udp:setsockname("0.0.0.0", 12345)
    self.udp:setoption("broadcast", true)

    self.clients = {}
end

-- function Network:connect(ip, port)
--     self.udp:setpeername(ip, port)
-- end

function Network:broadcast(data, port)
    self.udp:sendto(data, '255.255.255.255', port or self.port)
end

function Network:receive()
    local data, msg_or_ip, port_or_nil
    repeat
        data, msg_or_ip, port_or_nil = self.udp:receivefrom()
        if data then
            local ent, cmd, parms = data:match("^(%S*) (%S*) (.*)")
            
        elseif msg_or_ip ~= 'timeout' then 
			error("Network error: "..tostring(msg_or_ip))
        end
    until not data
end

return Network