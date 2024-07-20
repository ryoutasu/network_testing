WIN_WIDTH = love.graphics.getWidth()
WIN_HEIGHT = love.graphics.getHeight()

LABEL_FONT = love.graphics.newFont(40)

RECEIVE_UPDATE_TIME = 0.1

function setup_state_input(state)
    function state:update(dt) state.u:update(dt) end
    function state:draw() state.u:draw() end
    function state:mousepressed(x, y, button) state.u:pressed(x, y, button) end
    function state:mousemoved(x, y, dx, dy) state.u:moved(x, y, dx, dy) end
    function state:mousereleased(x, y, button) state.u:released(x, y, button) end
    function state:textinput(text) state.u:textinput(text) end
    function state:keypressed(k, scancode, isrepeat) state.u:keypressed(k, scancode, isrepeat) end
    function state:wheelmoved(x, y) state.u:wheelmoved(x, y) end
end