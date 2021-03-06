--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
	if params.recoverPoints==nil or params.recoverPoints==0 then
		self.recoverPoints = 5000
	else
		self.recoverPoints=params.recoverPoints
	end
	if params.paddleIncrease==nil or params.paddleIncrease==0 then
		self.paddleIncrease = 1000
	else
		self.paddleIncrease=params.paddleIncrease
	end
    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
	for i, ball in pairs(self.balls) do
		ball:update(dt)
		if ball:collides(self.paddle) then
			-- raise ball above paddle in case it goes below it, then reverse dy
			ball.y = self.paddle.y - 8
			ball.dy = -ball.dy

			--
			-- tweak angle of bounce based on where it hits the paddle
			--

			-- if we hit the paddle on its left side while moving left...
			if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
				ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
			
			-- else if we hit the paddle on its right side while moving right...
			elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
				ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
			end

			gSounds['paddle-hit']:play()
		end

    -- detect collision across all bricks with all the potential balls
		for k, brick in pairs(self.bricks) do
			
			if brick.powerup==2 and brick.a:collides(self.paddle) and brick.poweruptype==1 then
				ball1=Ball()
				ball1.dx = math.random(-200, 200)
				ball1.dy = math.random(-50, -60)
				ball1.x=self.balls[1].x
				ball1.y=self.balls[1].y
				ball1.skin=math.random(7)
				ball2=Ball()
				ball2.dx = math.random(-200, 200)
				ball2.dy = math.random(-50, -60)
				ball2.x=self.balls[1].x
				ball2.y=self.balls[1].y
				ball2.skin=math.random(7)
				table.insert(self.balls,ball1)
				table.insert(self.balls,ball2)
				brick.powerup=0
			elseif brick.powerup==2 and brick.a:collides(self.paddle) and brick.poweruptype==2 then
				clearable=true
				brick.powerup=0
			end
		
		
			-- only check collision if we're in play
			if brick.inPlay and ball:collides(brick) then
				if (brick.special==1 and clearable==true) or brick.special==0 then
				-- add to score
					self.score = self.score + (brick.tier * 200 + brick.color * 25)

					-- trigger the brick's hit function, which removes it from play
					brick:hit()
				end

				-- if we have enough points, recover a point of health
				if self.score > self.recoverPoints then
					-- can't go above 3 health
					self.health = math.min(3, self.health + 1)

					-- multiply recover points by 2
					self.recoverPoints = math.min(100000, self.recoverPoints * 2)

					-- play recover sound effect
					gSounds['recover']:play()
				end
				
				if self.score>self.paddleIncrease then
					self.paddle.size=math.min(4,self.paddle.size+1)
					if self.paddle.size==2 then
						self.paddle.width=64
					elseif self.paddle.size==3 then
						self.paddle.width=96
					else
						self.paddle.width=128
					end
					self.paddleIncrease=self.paddleIncrease+20000
				end	
				
				-- go to our victory screen if there are no more bricks left
				if self:checkVictory() then
					gSounds['victory']:play()

					gStateMachine:change('victory', {
						level = self.level,
						paddle = self.paddle,
						health = self.health,
						score = self.score,
						highScores = self.highScores,
						ball =ball,
						recoverPoints = self.recoverPoints
					})
				end

				--
				-- collision code for bricks
				--
				-- we check to see if the opposite side of our velocity is outside of the brick;
				-- if it is, we trigger a collision on that side. else we're within the X + width of
				-- the brick and should check to see if the top or bottom edge is outside of the brick,
				-- colliding on the top or bottom accordingly 
				--

				-- left edge; only check if we're moving right, and offset the check by a couple of pixels
				-- so that flush corner hits register as Y flips, not X flips
				if ball.x + 2 < brick.x and ball.dx > 0 then
					
					-- flip x velocity and reset position outside of brick
					ball.dx = -ball.dx
					ball.x = brick.x - 8
				
				-- right edge; only check if we're moving left, , and offset the check by a couple of pixels
				-- so that flush corner hits register as Y flips, not X flips
				elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
					
					-- flip x velocity and reset position outside of brick
					ball.dx = -ball.dx
					ball.x = brick.x + 32
				
				-- top edge if no X collisions, always check
				elseif ball.y < brick.y then
					
					-- flip y velocity and reset position outside of brick
					ball.dy = -ball.dy
					ball.y = brick.y - 8
				
				-- bottom edge if no X collisions or top collision, last possibility
				else
					
					-- flip y velocity and reset position outside of brick
					ball.dy = -ball.dy
					ball.y = brick.y + 16
				end

				-- slightly scale the y velocity to speed up the game, capping at +- 150
				if math.abs(ball.dy) < 150 then
					ball.dy = ball.dy * 1.02
				end

				-- only allow colliding with one brick, for corners
				break
			end
		end

		-- if ball goes below bounds, revert to serve state and decrease health
		if ball.y >= VIRTUAL_HEIGHT then
			table.remove(self.balls,i)
			if table.getn(self.balls)==0 then
				self.health = self.health - 1
				gSounds['hurt']:play()
			end

			if self.health == 0 then
				gStateMachine:change('game-over', {
					score = self.score,
					highScores = self.highScores
				})
			elseif table.getn(self.balls)==0 then
				self.paddle.size=math.max(1,self.paddle.size-1)
				if self.paddle.size==1 then
						self.paddle.width=32
					elseif self.paddle.size==2 then
						self.paddle.width=64
					else
						self.paddle.width=96
				end
				gStateMachine:change('serve', {
					paddle = self.paddle,
					bricks = self.bricks,
					health = self.health,
					score = self.score,
					highScores = self.highScores,
					level = self.level,
					recoverPoints = self.recoverPoints,
					paddleIncrease=self.paddleIncrease
				})
			end
		end
	end
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
	for i, ball in pairs(self.balls) do
		ball:render()
	end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
		love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
		local backgroundWidth = gTextures['background']:getWidth()
    	local backgroundHeight = gTextures['background']:getHeight()		
		love.graphics.draw(gTextures['background'], 
        -- draw at coordinates 0, 0
        0, 0, 
        -- no rotation
        0,
        -- scale factors on X and Y axis so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end