if arg[#arg] == "vsc_debug" then require("lldebugger").start() end

require 'utils'

Class = require 'lib.class'
Gamestate = require 'lib.gamestate'
Urutora = require 'lib.urutora'

Network = require 'network'()
Player = require 'player'()

MainMenu = require 'state.mainMenu'
HostGameState = require 'state.hostGameState'
GameListState = require 'state.gameListState'
GameState = require 'state.gameState'

function love.load()
    love.graphics.setDefaultFilter( 'nearest', 'nearest' )
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

function love.quit()
    if Network.connected then Network:close() end
end