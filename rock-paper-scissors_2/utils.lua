WIN_WIDTH = love.graphics.getWidth()
WIN_HEIGHT = love.graphics.getHeight()

LABEL_FONT = love.graphics.newFont(40)

RECEIVE_UPDATE_TIME = 0.1

local function __NULL__() end

local callbacks = {
    ['update'] = 'update',
    ['draw'] = 'draw',
    ['pressed'] = 'mousepressed',
    ['moved'] = 'mousemoved',
    ['released'] ='mousereleased',
    ['textinput'] = 'textinput',
    ['keypressed'] = 'keypressed',
    ['wheelmoved'] = 'wheelmoved',
}

function setup_state_urutora(state)
    if not state.u then return end

	local registry = {}
    for uf, f in pairs(callbacks) do
        registry[f] = state[f] or __NULL__
        state[f] = function (state, ...)
            registry[f](state, ...)
            state.u[uf](state.u, ...)
        end
    end
end