push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- initialize player paddles and ball
    player1 = Paddle(10, VIRTUAL_HEIGHT/2 - 10, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT/2 - 10, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
    players = ""
    mute = "false"
end

--[[
    Called by LÖVE whenever we resize the screen; here, we just want to pass in the
    width and height to push so our virtual resolution can be resized as needed.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
    if love.keyboard.isDown('r') then
        ball:reset()
        gameState = 'start'
        player2Score = "0"
        player1Score = "0"
    end
    if players == "1" then
        if gameState == 'serve' then
            -- before switching to play, initialize ball's velocity based
            -- on player who last scored
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        elseif gameState == 'play' then
            -- detect ball collision with paddles, reversing dx if true and
            -- slightly increasing it, then altering the dy based on the position of collision
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.03
                ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                if mute == "false" then
                    sounds['paddle_hit']:play()
                end
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.03
                ball.x = player2.x - 4

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                if mute == "false" then
                    sounds['paddle_hit']:play()
                end
            end

            -- detect upper and lower screen boundary collision and reverse if collided
            if ball.y <= 31 then
                ball.y = 32
                ball.dy = -ball.dy
                if mute == "false" then
                    sounds['wall_hit']:play()
                end
            end

            -- -4 to account for the ball's size
            if ball.y >= VIRTUAL_HEIGHT - 5 then
                ball.y = VIRTUAL_HEIGHT - 6
                ball.dy = -ball.dy
                if mute == "false" then
                    sounds['wall_hit']:play()
                end
            end
            
            -- if we reach the left or right edge of the screen, 
            -- go back to start and update the score
            if ball.x < 0 then
                servingPlayer = 1
                player2Score = player2Score + 1
                if mute == "false" then
                    sounds['score']:play()
                end

                -- if we've reached a score of 10, the game is over; set the
                -- state to done so we can show the victory message
                if player2Score == 10 then
                    winningPlayer = 2
                    gameState = 'done'
                else
                    gameState = 'serve'
                    -- places the ball in the middle of the screen, no velocity
                    ball:reset()
                end
            end

            if ball.x > VIRTUAL_WIDTH then
                servingPlayer = 2
                player1Score = player1Score + 1
                if mute == "false" then
                    sounds['score']:play()
                end
                if player1Score == 10 then
                    winningPlayer = 1
                    gameState = 'done'
                else
                    gameState = 'serve'
                    ball:reset()
                end
            end
        end
    end
    if players == "2" then
        if gameState == 'serve' then
            -- before switching to play, initialize ball's velocity based
            -- on player who last scored
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, 200)
            else
                ball.dx = -math.random(140, 200)
            end
        elseif gameState == 'play' then
            -- detect ball collision with paddles, reversing dx if true and
            -- slightly increasing it, then altering the dy based on the position of collision
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.03
                ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                if mute == "false" then
                    sounds['paddle_hit']:play()
                end
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.03
                ball.x = player2.x - 4

                -- keep velocity going in the same direction, but randomize it
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)
                else
                    ball.dy = math.random(10, 150)
                end
                if mute == "false" then
                    sounds['paddle_hit']:play()
                end
            end

            -- detect upper and lower screen boundary collision and reverse if collided
            if ball.y <= 31 then
                ball.y = 32
                ball.dy = -ball.dy
                if mute == "false" then
                    sounds['wall_hit']:play()
                end
            end

            -- -4 to account for the ball's size
            if ball.y >= VIRTUAL_HEIGHT - 5 then
                ball.y = VIRTUAL_HEIGHT - 6
                ball.dy = -ball.dy
                if mute == "false" then
                    sounds['wall_hit']:play()
                end
            end
            
            -- if we reach the left or right edge of the screen, 
            -- go back to start and update the score
            if ball.x < 0 then
                servingPlayer = 1
                player2Score = player2Score + 1
                if mute == "false" then
                    sounds['score']:play()
                end
                -- if we've reached a score of 10, the game is over; set the
                -- state to done so we can show the victory message
                if player2Score == 10 then
                    winningPlayer = 2
                    gameState = 'done'
                else
                    gameState = 'serve'
                    -- places the ball in the middle of the screen, no velocity
                    ball:reset()
                end
            end

            if ball.x > VIRTUAL_WIDTH then
                servingPlayer = 2
                player1Score = player1Score + 1
                if mute == "false" then
                    sounds['score']:play()
                end
                
                if player1Score == 10 then
                    winningPlayer = 1
                    gameState = 'done'
                else
                    gameState = 'serve'
                    ball:reset()
                end
            end
        end
    end

    -- player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 movement
    if love.keyboard.isDown('up') then
        if players == "2" then
            player2.dy = -PADDLE_SPEED
        end
    elseif love.keyboard.isDown('down') then
        if players == "2" then
            player2.dy = PADDLE_SPEED
        end
    else
        player2.dy = 0
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    if players == "2" then
        player2:update(dt)
        player1:update(dt)
    elseif players == "1" then
        player1:update(dt)
        if ball.y < player2.y then
            player2.dy = -PADDLE_SPEED
        elseif ball.y > player2.y then
            player2.dy = PADDLE_SPEED
        end
        player2:update(dt)
    end
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'm' then
        if mute == "false" then
            mute = "true"
        elseif mute == "true" then
            mute = "false"
        end
    elseif key == '1' then
        players = "1"
        if gameState == 'start' then
            gameState = 'serve'
        end
    elseif key == '2' then
        players = "2"
        if gameState == 'start' then
            gameState = 'serve'
        end
    elseif key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()

    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40, 45, 52, 0)

    love.graphics.setFont(smallFont)

    boundaries()
    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press 1 for 1 player mode and 2 for 2 player mode.', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('M = Mute', 0, 3, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('R = Restart', 0, 13, VIRTUAL_WIDTH, 'right')
        love.graphics.printf('Esc = Quit', 0, 23, VIRTUAL_WIDTH, 'right')
    elseif gameState == 'serve' then
        if players == "2" then
            love.graphics.setFont(smallFont)
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        elseif players == "1" then
            love.graphics.setFont(smallFont)
            love.graphics.printf("Player 1's serve!", 
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        if players == "1" then
            love.graphics.printf("Use 'W' and 'S' to control paddle.", 
            0, 20, VIRTUAL_WIDTH, 'center')
        elseif players == "2" then
            love.graphics.printf("Player 1: Use 'W' and 'S' to control paddle. Player 2: Use up and down arrows to control paddle.", 
            0, 20, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, VIRTUAL_HEIGHT / 2 - 15, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function boundaries()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("-----------------------------------------------------------------------------------------------------------------------", 0, 30)
end

--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print("-", VIRTUAL_WIDTH / 2 - 6, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end
