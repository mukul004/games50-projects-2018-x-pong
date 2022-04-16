--Pong Game program in lua
--We have included class and push file in main.
push = require 'push'
Class = require 'class'

--We have included Paddle and Ball file in main to make our program simplified 
require 'Paddle'
require 'Ball'

--Global variable are initialised which can be used in all the files
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

--Now we load our program
function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    --To make our game look retro as actual game we will decrease our resolution. This command helps set pixel quality intact.
    
    love.window.setTitle('Pong')
    --setting title for our program

    math.randomseed(os.time())
    --giving randomness in our program when random command. As randomness depends upon varible. we have provided
    --os.time() as the number which changes continuously.
    
    smallfont = love.graphics.newFont('font.ttf', 8)
    mediumfont = love.graphics.newFont('font.ttf', 16)
    largefont = love.graphics.newFont('font.ttf', 32)
    --Saving different fonts on different variables which can be used in different formats
    love.graphics.setFont(smallfont)
    --setting small font.

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['score'] = love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static')
    }
    --loading different sounds in a sound table.

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = true,
        vsync = true,
        resize = true
    })

    player1 = Paddle(10,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)
    ball = Ball(VIRTUAL_WIDTH/2 -2,VIRTUAL_HEIGHT/2-2, 4, 4)
    --loading two paddles and a ball
    player1score = 0
    player2score = 0
    servingplayer = 1
    winningplayer = 0
    --setting scores of both player to 0 and starting the gamestate

    gamestate = 'start'    
end

function love.resize(w,h)
    push:resize(w,h)
    
end

function love.update(dt)
    
    if gamestate == 'serve' then
        ball.dy = math.random(-50,50)
        if servingplayer == 1 then
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gamestate == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx *1.03
            ball.x = player1.x + 5
            if ball.dy<0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx *1.03
            ball.x = player2.x - 4
            if ball.dy <0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end

        if ball.y <=0 then
            ball.y = 0 
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >=VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT-4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        
        if ball.x <0 then
            servingplayer = 1
            player2score = player2score +1
            sounds['score']:play()

            if player2score == 10 then
                winningplayer = 2
                gamestate = 'done'
            else
                gamestate = 'serve'

                ball:reset()

            end
        end
        if ball.x >VIRTUAL_WIDTH then
            servingplayer = 2 
            player1score = player1score +1
            sounds['score']:play()

            if player1score == 10 then
                winningplayer = 1 
                gamestate = 'done'
            else
                gamestate = 'serve'

                ball:reset()
            end
        end
        
        --Giving manual controls for paddle 1 using w and s keys
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED 
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED 
        else
            player1.dy = 0
        end

        -- Giving controls to AI using command
        --[[if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED 
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED 
        else
            player2.dy = 0
        end]]
        player2.y = ball.y

        player1:update(dt)
        player2:update(dt)
        --paddles should move freely without any restriction
        if gamestate == 'play' then
            ball:update(dt)
        end            
    end   
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key =='enter' or key == 'return' then
        
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            gamestate = 'serve'
            ball:reset()
            player1score = 0
            player2score = 0
            if winningplayer == 1 then
                servingplayer = 2
            else
                servingplayer = 1
            end

        end
    end
    
end

function love.draw()
    push:start()
    --giving color to screen using clear command
    love.graphics.clear(40/255,45/255,52/255,255/255)
    
    if gamestate == 'start' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Welcome to Pong!!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Begin', 0,20,VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'serve' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player '.. tostring(servingplayer).."'s serve", 0,10,VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Begin', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'play' then

    elseif gamestate == 'done' then
        love.graphics.setFont(largefont)
        love.graphics.printf('Player ' .. tostring(winningplayer) .. 'wins!!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf('Press enter to restart', 0, 50, VIRTUAL_WIDTH, 'center')
    end

    ball:render()
    player1:render()
    player2:render()
    displayScore()
    displayFPS()

    push:finish()

    
end

function displayScore()
    love.graphics.setFont(mediumfont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH/2 -50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
       
end

function displayFPS()
    love.graphics.setFont(smallfont)
    love.graphics.setColor(0, 255/255,0,255/255)
    love.graphics.print('FPS: '.. tostring(love.timer.getFPS()), 10,10)
    love.graphics.setColor(1,1,1,1)
    
end