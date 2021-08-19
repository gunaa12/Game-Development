StateMachine = Class{}

function StateMachine:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
end

function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

function StateMachine:update(dt)
	self.current:update(dt)
	local backgroundX = 0
	local BACKGROUND_SCROLL_SPEED = 80
	backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end
end

function StateMachine:render()
	love.graphics.draw(gTextures['background'], backgroundX, 0)
	self.current:render()
end
