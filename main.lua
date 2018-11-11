function love.load()
    -- inicia o programa
    arenaWidth = 800
    arenaHeight = 600

    -- nave
    shipX = arenaWidth/2
    shipY = arenaHeight/2
    shipAngle = 0
    shipSpeedX = 0
    shipSpeedY = 0
    shipRadius = 30

    -- bullets
    bullets = {}
    bulletTimer = 0
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

    -- atira
    bulletTimer = bulletTimer + dt

    if love.keyboard.isDown('s') then
        if bulletTimer >= 0.5 then
            bulletTimer = 0

            table.insert(bullets, {
                x = shipX + math.cos(shipAngle) * shipRadius,
                y = shipY + math.sin(shipAngle) * shipRadius,
                angle = shipAngle,
                timeLeft = 4,
            })
        end
    end

    for bulletIndex, bullet in ipairs(bullets) do
        local bulletSpeed = 500
        bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt) % arenaWidth
        bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt) % arenaHeight
    end

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
            love.graphics.circle('line', shipX, shipY, shipRadius)
            
            -- desenha o piloto
            love.graphics.setColor(0, 1, 1)
            love.graphics.circle('line', shipX + math.cos(shipAngle) * 20, shipY + math.sin(shipAngle) * 20, shipRadius/6)
        
            -- desenha as balas
            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle('fill', bullet.x, bullet.y, 5)
            end
        end
    end

    -- Temporary
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(table.concat({
        'shipAngle: '..shipAngle,
        'shipX: '..shipX,
        'shipY: '..shipY,
        'shipSpeedX: '..shipSpeedX,
        'shipSpeedY: '..shipSpeedY,
    }, '\n'))

    -- debug
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(table.concat({
        'shipAngle: '..shipAngle,
        'shipX: '..shipX,
        'shipY: '..shipY,
        'shipSpeedX: '..shipSpeedX,
        'shipSpeedY: '..shipSpeedY,
    }, '\n'))
end