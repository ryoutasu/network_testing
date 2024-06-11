if arg[#arg] == "vsc_debug" then require("lldebugger").start() end

Class = require 'lib.class'
Gamestate = require 'lib.gamestate'
Urutora = require 'lib.urutora'
Network = require 'network'

MainMenu = require 'states.main_menu'
ServerState = require 'states.serverState'

function love.load()
    love.graphics.setBackgroundColor(0.65, 0.65, 0.65, 1)
    love.graphics.setColor(0, 0, 0, 1)
    
    math.randomseed(os.time())
    
    Gamestate.registerEvents()
    Gamestate.switch(MainMenu)
end

function love.update(dt)
    
end

function love.draw()
    
end