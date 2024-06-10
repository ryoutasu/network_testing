local enet = require 'enet'
local host
local peer

function love.load()
    
end

function love.update(dt)
    if host then
        local event = host:service(10)

        while event do
            print("Server detected message type: " .. event.type)
            if event.type == "connect" then
                print(event.peer, "connected.")
                
            elseif event.type == 'disconnect' then
                print(event.peer, "disconnected.")

            elseif event.type == "receive" then
                print("Received message: ", event.data, event.peer)

                local cmd, parms = event.data:match("^(%S*) (.*)")
                if cmd == 'broadcast' then
                    print('got broadcast')
                else
                    print('Unrecognised command:', cmd, parms)
                end
            end
            event = host:service()
        end
    end
end

function love.keypressed(key)
    if key == 'space' then
        host = enet.host_create('192.168.1.255:6750')
        print('created 192.168.1.255:6750')
    elseif key == 'r' then
        if not host then
            host = enet.host_create()
            print('created client host')
            peer = host:connect('192.168.0.255:6750')
        else
            peer:send('broadcast 1')
        end
        -- host:broadcast('broadcast 1')
    end
end