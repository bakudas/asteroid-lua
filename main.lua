function love.load()
    -- inicia o programa
    arenaWidth = 800
    arenaHeight = 600

    -- nave
    shipRadius = 30

    -- bullets
    bulletRadius = 5

    -- asteroids
    asteroids = {
        {
            x = 100,
            y = 100,
        },
        {
            x = arenaWidth - 100,
            y = 100,
        },
        {
            x = arenaWidth / 2,
            y = arenaHeight - 100,
        },
    }
    
    asteroidStages = {
        {
            speed = 120,
            radius = 15
        },
        {
            speed = 70,
            radius = 30
        },
        {
            speed = 50,
            radius = 50
        },
        {
            speed = 20,
            radius = 80
        }
    }

    
    function reset()
        -- inicia a nave
        shipX = arenaWidth / 2
        shipY = arenaHeight / 2
        shipAngle = 0
        shipSpeedX = 0
        shipSpeedY = 0

        -- inicia as bsalas
        bullets = {}
        bulletTimer = 0 -- cooldown

        asteroids = {
            {
                x = 100,
                y = 100,
            },
            {
                x = arenaWidth - 100,
                y = 100,
            },
            {
                x = arenaWidth / 2,
                y = arenaHeight - 100,
            }
        }

        for asteroidIndex, asteroid in ipairs(asteroids) do
            asteroid.angle = love.math.random() * (2 * math.pi)
            asteroid.stage = #asteroidStages
        end
    end

    reset()

end

function love.update(dt)
    local turnAngle = 5 -- modificador da variável do angulo da nave

    -- vira para a direita
    if love.keyboard.isDown('right') then
        shipAngle = (shipAngle + turnAngle * dt) % (2 * math.pi)
    else if love.keyboard.isDown('left') then -- vira para esquerda
        shipAngle = (shipAngle - turnAngle * dt) % (2 * math.pi)
    end
    end

    -- aceleração da nave
    if love.keyboard.isDown('up') then
        local shipSpeed = 200
        shipSpeedX = shipSpeedX + math.cos(shipAngle) * shipSpeed * dt
        shipSpeedY = shipSpeedY + math.sin(shipAngle) * shipSpeed * dt
    end

    shipX = (shipX + shipSpeedX * dt) % arenaWidth
    shipY = (shipY + shipSpeedY * dt) % arenaWidth

    -- função que detecta se dois circulos estão se colidindo
    local function areCirclesIntersecting( aX, aY, aRadius, bX, bY, bRadius )
        return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
    end

    
    -- move as balas
    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]
        
        bullet.timeLeft = bullet.timeLeft - dt
        if bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            local bulletSpeed = 500
            
            bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % arenaWidth
            bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % arenaHeight
        end
        
        -- laço para checagem de todos os asteroids
        for asteroidIndex = #asteroids, 1, -1 do
            local asteroid = asteroids[asteroidIndex]
            -- colisão entre bala e asteroids
            if areCirclesIntersecting(bullet.x, bullet.y, bulletRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
                table.remove( bullets,bulletIndex )
                
                if asteroid.stage > 1 then
                    local angle1 = love.math.random() * (2 * math.pi)
                    local angle2 = (angle1 - math.pi) % (2 * math.pi)
                    
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle1,
                        stage = asteroid.stage -1,
                    })
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        angle = angle2,
                        stage = asteroid.stage - 1,
                    })
                end
                
                table.remove( asteroids,asteroidIndex )
                break
            end
            
            
        end
    end

    -- atira
    bulletTimer = bulletTimer + dt

    if love.keyboard.isDown('s') then
        if bulletTimer >= 0.5 then
            bulletTimer = 0

            table.insert(bullets, {
                x = shipX + math.cos(shipAngle) * shipRadius,
                y = shipY + math.sin(shipAngle) * shipRadius,
                angle = shipAngle,
                timeLeft = 4, -- tempo que as balas desaparecem
            })
        end
    end

    -- move os asteroids
    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.x = (asteroid.x + math.cos(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaHeight
    
        -- colisão entre asteriod e player
        if areCirclesIntersecting(shipX, shipY, shipRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
            reset () -- reseta o game 
            break
        end
    end

    -- game over
    if #asteroids == 0 then
        reset() -- reseta o game
    end

end

function love.draw()
    -- -- desenha a nave
    -- love.graphics.setColor(0, 0, 1) 
    -- love.graphics.circle(
    --     'line', 
    --     shipX , 
    --     shipY, 
    --     30
    -- )   

    -- -- desenha o piloto
    -- love.graphics.setColor(0, 1, 1)
    -- local shipCircleDistance = 20
    -- love.graphics.circle(
    --     'line', 
    --     shipX + math.cos( shipAngle ) * shipCircleDistance , 
    --     shipY + math.sin( shipAngle ) * shipCircleDistance , 
    --     5
    -- )

    -- desenhando o jogador parcialmente fora da tela
    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * arenaWidth, y * arenaHeight)
            
            -- desenha o jogador
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle(
                'line', 
                shipX, 
                shipY, 
                shipRadius
            )
            
            -- desenha o piloto
            love.graphics.setColor(0, 1, 1)
            love.graphics.circle(
                'line', 
                shipX + math.cos(shipAngle) * 20, 
                shipY + math.sin(shipAngle) * 20, 
                shipRadius/6
            )
        
            -- desenha as balas
            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle(
                    'fill', 
                    bullet.x, 
                    bullet.y, 
                    bulletRadius
                )
            end

            -- desenha os asteroids
            for asteroidsIndex, asteroid in ipairs(asteroids) do
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle(
                    'line', 
                    asteroid.x, 
                    asteroid.y, 
                    asteroidStages[asteroid.stage].radius
                )
            end
        end
    end

    -- debug
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(table.concat({
        'shipAngle: '..shipAngle,
        'shipX: '..shipX,
        'shipY: '..shipY,
        'shipSpeedX: '..shipSpeedX,
        'shipSpeedY: '..shipSpeedY,
    }, '\n'))


end