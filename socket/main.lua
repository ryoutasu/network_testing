if arg[#arg] == "vsc_debug" then require("lldebugger").start() end

Class = require 'libs.class'
Gamestate = require 'libs.gamestate'
Urutora = require 'libs.urutora'
Network = require 'network'

MainMenu = require 'states.main_menu'
ServerState = require 'states.serverState'

-- local udp = assert(Socket.udp())
-- local client = assert(Socket.udp())
-- local data

-- udp:settimeout(1)
-- udp:setsockname("0.0.0.0",12345)
-- udp:setoption("broadcast", true)
-- -- assert(client:setpeername("localhost",1234))
-- client:setsockname("0.0.0.0",54321)
-- client:setoption("broadcast", true)

-- for i = 0, 2, 1 do
--     client:send("ping")
--     local result, msg = client:sendto("ping", "255.255.255.255", 12345)
--     if not result then print(msg) end
--     data = udp:receivefrom()
--     if data then
--         break
--     end
-- end


-- if data == nil then
--     print("timeout")
-- else
--     print(data)
-- end



function love.load()
    love.graphics.setBackgroundColor(0.65, 0.65, 0.65, 1)
    love.graphics.setColor(0, 0, 0, 1)
    
    Gamestate.registerEvents()
    Gamestate.switch(MainMenu)
end

function love.update(dt)
    
end

function love.draw()
    
end