local socket = require 'socket'
local bitser = require 'lib.bitser'

local Network = Class{}

function Network:address()
    return self.ip .. '/' .. self.port
end

function Network:connect(port)
    if self.connected or self.udp then return end
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setsockname("0.0.0.0", port)
    self.udp:setoption("broadcast", true)
    
    local received, i = false, 0
    while not received and i < 100 do
        local r = math.random(1, 65536)

        self.udp:sendto(r, '255.255.255.255', port)
        local msg, ip, port = self.udp:receivefrom()
        
        if tonumber(msg) == r then
            self.ip = ip
            self.port = port
            self.connected = true
            received = true
            print('Connected.')
        end

        i = i + 1
    end

    if not received then
        self.connected = false
        self.udp:close()
        print("Error: cannot connect.")
    end

    return received
end

function Network:init()
    self.udp = nil
    self.connected = false

    self.clients = {}
end

function Network:close()
    if not self.connected then return end

    print('Network closed.')
    self.udp:close()
    self.udp = nil
    self.ip = nil
    self.port = nil
    self.connected = false
end

function Network:send(data, ip, port)
    if not self.connected then return end
    local serializedData = bitser.dumps(data)

    self.udp:sendto(serializedData, ip, port or self.port)
end

function Network:broadcast(data, port)
    if not self.connected then return end
    self:send(data, '255.255.255.255', port or self.port)
end

function Network:receive()
    if not self.connected then return end
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