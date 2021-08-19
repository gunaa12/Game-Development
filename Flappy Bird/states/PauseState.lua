--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

PauseState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function PauseState:init()
    
end

function PauseState:enter()
    
end

function PauseState:update(dt)
    BACKGROUND_SCROLL_SPEED = 0
    GROUND_SCROLL_SPEED = 0
    if love.keyboard.wasPressed('p') then
        BACKGROUND_SCROLL_SPEED = 30
        GROUND_SCROLL_SPEED = 60
        gStateMachine:change('countdown')
    end
end

function PauseState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Pause', 0, 64, VIRTUAL_WIDTH, 'center')
end