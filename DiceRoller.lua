--Creates dem sweet buttons when object is loaded.
local lastCount = 0
local lastlt = false
local count = 0
local lastThresh = 0

function onload()
    oChip = self

    oChip.createButton({
        label="---", click_function="none", function_owner=Global,
        position={0,0,0}, rotation={0,0,0}, height=0, width=0, font_size=1,
        font_color={1, 1, 1},
        scale={0.25, 0.25, 0.25}
    })

    local height = 0.95
    local start = -1.45


    createCustomButton(oChip, 'Reroll 1s', 'reroll1s', {-11, 0.14, start})
    createCustomButton(oChip, 'Reroll 1-2', 'reroll2s', {-9, 0.14, start})
    createCustomButton(oChip, 'Reroll 1-3', 'reroll3s', {-7, 0.14, start})
    createCustomButton(oChip, 'Reroll 1-4', 'reroll4s', {-5, 0.14, start})
    createCustomButton(oChip, 'Reroll 1-5', 'reroll5s', {-3, 0.14, start})
    createCustomButton(oChip, 'Keep 2+', 'keep2s', {-11, 0.14, start + height})
    createCustomButton(oChip, 'Keep 3+', 'keep3s', {-9, 0.14, start + height})
    createCustomButton(oChip, 'Keep 4+', 'keep4s', {-7, 0.14, start + height})
    createCustomButton(oChip, 'Keep 5+', 'keep5s', {-5, 0.14, start + height})
    createCustomButton(oChip, 'Keep 6+', 'keep6s', {-3, 0.14, start + height})
    createCustomButton(oChip, 'Keep <2', 'keeplt2s', {-11, 0.14, start + 2 * height})
    createCustomButton(oChip, 'Keep <3', 'keeplt3s', {-9, 0.14, start + 2 * height})
    createCustomButton(oChip, 'Keep <4', 'keeplt4s', {-7, 0.14, start + 2 * height})
    createCustomButton(oChip, 'Keep <5', 'keeplt5s', {-5, 0.14, start + 2 * height})
    createCustomButton(oChip, 'Keep <6', 'keeplt6s', {-3, 0.14, start + 2 * height})
    createCustomButton(oChip, 'Reroll', 'rerollall', {-11, 0.14, start + 3 * height})
    createCustomButton(oChip, '1d6', 'spawnOne', {-9, 0.14, start + 3 * height})
    createCustomButton(oChip, '5d6', 'spawnFive', {-7, 0.14, start + 3 * height})
    createCustomButton(oChip, '10d6', 'spawnTen', {-5, 0.14, start + 3 * height})
    createCustomButton(oChip, 'Clear', 'clearDice', {-3, 0.14, start + 3 * height})
       
    emptyText = ' '
end

function spawnOne()
    spawn(1)
end

function spawnFive()
    spawn(5)
end

function spawnTen()
    spawn(10)
end

--deletes dice below the threshold
function keepdice(threshold)
    for _, obj in pairs(getAllObjects()) do
        -- Fetch resting dices
        if obj != nil and obj.tag == 'Dice' and obj.resting then
            if obj.getValue() < threshold then
                obj.destruct()
            end
        end
    end
    lastCount = count
    lastlt = false
    lastThresh = threshold
    reroll(7)
end

--deletes dice above the threshold
function keepdicelt(threshold)
    for _, obj in pairs(getAllObjects()) do
        -- Fetch resting dices
        if obj != nil and obj.tag == 'Dice' and obj.resting then
            if obj.getValue() >= threshold then
                obj.destruct()
            end
        end
    end
    lastCount = count
    lastlt = true
    lastThresh = threshold
    reroll(7)
end

--Button functions.  Bad practice, but works fine for d6 games
function keep2s()
    keepdice(2)
end

function keep3s()
    keepdice(3)
end

function keep4s()
    keepdice(4)
end

function keep5s()
    keepdice(5)
end

function keep6s()
    keepdice(6)
end

function keeplt2s()
    keepdicelt(2)
end

function keeplt3s()
    keepdicelt(3)
end

function keeplt4s()
    keepdicelt(4)
end

function keeplt5s()
    keepdicelt(5)
end

function keeplt6s()
    keepdicelt(6)
end

function rerollall()
    reroll(7)
    reset()
end

function reroll1s()
    reroll(2)
    reset()
end

function reroll2s()
    reroll(3)
    reset()
end

function reroll3s()
    reroll(4)
    reset()
end

function reroll4s()
    reroll(5)
    reset()
end

function reroll5s()
    reroll(6)
    reset()
end

--rerolls dice lower than the value of the argument passed to the function
function reroll(hit)
    for _, obj in pairs(getAllObjects()) do
        if obj != nil and obj.tag == 'Dice' and obj.resting then
            if obj.getValue() < hit then
                obj.randomize()
            end
        end
    end
end

function reset()
    lastCount = 0
    lastThresh = 0
    lastlt = false
end

--Delete all dice on the table.  And I do mean ALL dice.  Globally.  No exceptions.
function clearDice()
    for _, obj in pairs(getAllObjects()) do
        -- Fetch resting dice
        if obj != nil and obj.tag == 'Dice' then
            obj.destruct()
        end
    end
    reset()
end
--Spawn dice function.  
function spawn(i)
    local obj = {}
    local tPosition = self.getPosition()
    local tRotation = self.getRotation()

    obj.type = 'Custom_Dice'
    --comment next line for custom textures
    obj.type = 'Die_6'
    obj.scale = {0.5, 0.5, 0.5}

    while (i >= 1) do
        --Checks rotation of the chip and vaguely tries to spawn the dice toward
        --the upper right of it's facing.  Currently only two directions set.
        if tRotation.y > 88 and tRotation.y < 227 then
            obj.position = {tPosition.x+i-6, tPosition.y+3, tPosition.z}
        else
            obj.position = {tPosition.x-i+6, tPosition.y+3, tPosition.z}
        end
        d6 = spawnObject(obj)
        --uncomment the following lines for custom textures

        --local custom = {}
        --custom.image = 'http://i.imgur.com/dkfzkPw.png'  --example texture format
        --custom.type = 1
        --d6.setCustomObject(custom)

        d6.roll(true)
        i = i - 1
    end
end

--Call here to create buttons on the chip
function createCustomButton (oParent, sLabel, sFunctionName, tPosition)
    local button = {}
    button.click_function = sFunctionName
    button.label = sLabel
    button.function_owner = oParent
    button.position = tPosition
    button.rotation = {0, 0, 0}
    button.width = 900
    button.height = 400
    button.font_size = 200

    oParent.createButton(button)
end

--Function to reset description
function setDefaultState()
    self.setDescription(JSON.encode({
        dice=6
    }))
end

--[[ The Update function. This is called once per frame. --]]
function update ()
    
    -- Reset description on null
    local data = JSON.decode(self.getDescription())
    if data==nil then
        setDefaultState()
        data = JSON.decode(self.getDescription())
        printToAll('Warning - invalid description. Restored defaut configuration.', {0.8,0.5,0})
    end
    -- Set text size based on description or reset if invalid.
    if     data.dice==4 then
        self.editButton({ position={-1.4,0.61,0}, font_size=600})
    elseif data.dice==6 then
        self.editButton({ position={-1.4,0.61,0}, font_size=600})
    elseif data.dice==8 then
        self.editButton({ position={-1.4,0.61,0}, font_size=600})
    elseif data.dice==10 then
        self.editButton({ position={-1.4,0.61,0}, font_size=550})
    elseif data.dice==12 then
        self.editButton({ position={-1.4,0.61,0}, font_size=550})
    elseif data.dice==20 then
        self.editButton({ position={-1.4,0.61,0}, font_size=350})
    else
        setDefaultState()
        data = JSON.decode(self.getDescription())
        printToAll('Warning - invalid description. Restored defaut configuration.', {0.8,0.5,0})
    end
    -- If the zone is moving, wait
    if not self.resting then
        return
    end

    local ownPos = self.getPosition()
    local ownRotation = self.getRotation()['x']
    local ownScale = self.getScale()['x']
    local Rotation = self.getRotation()
    
    -- Compute the bounds of the box.
    -- Manipulate the offset to account for tray borders.
    -- y offset will affect how above and below it will see dice.
    -- I was too lazy to split the y offset to only extend above the tray.
    -- If you want to fix do so and message me. ~(^_^;~)
    
    local xboundOffset = 1.8 --Horizontal Offset
    local yboundOffset = 2 --Up/Down Offset
    local zboundOffset = 1.5 --Vertical Offset
    if Rotation.y > 89 and Rotation.y < 91 then
        xboundOffset = 1.4
        zboundOffset = 1.6
        end
    if Rotation.y > 269 and Rotation.y < 270 then
        xboundOffset = 1.4
        zboundOffset = 1.6
        end
    local leftBound = ownPos['x'] - xboundOffset * ownScale
    local rightBound = ownPos['x'] + xboundOffset * ownScale
    local upperBound = ownPos['z'] + zboundOffset * ownScale
    local lowerBound = ownPos['z'] - zboundOffset * ownScale
    local yupperBound = ownPos['y'] + yboundOffset --* ownScale
    local ylowerBound = ownPos['y'] - yboundOffset --* ownScale

    local valueToCounter = {}
    local valuesToSort = {}
    local d3total = 0

    -- Iterate all objects in the zone
    for _, obj in pairs(getAllObjects()) do
        -- Fetch resting dices
        if obj != nil and obj.tag == 'Dice' and obj.resting then
            -- Only use objects inside the zone
            local objPos = obj.getPosition()
            if objPos['x'] > leftBound and objPos['x'] < rightBound and objPos['z'] > lowerBound and objPos['z'] < upperBound and objPos['y'] < yupperBound and objPos['y'] > ylowerBound then
                local value = obj.getValue()
                local counter = valueToCounter[value]
                -- First occurrence of this value
                if counter == nil then
                    counter = 0
                    valuesToSort[#valuesToSort + 1] = value
                end
                -- Increase the occurrence of this value
                counter = counter + 1
                valueToCounter[value] = counter
                d3total = d3total + tonumber(string.format("%." .. 0 .. "f", (value/2)))
            end
        end
    end

    -- Process the tracked values, sorted and build the lines to display
    local textLines = {}
    table.sort(valuesToSort)
    local total = 0
    count = 0
    for index, value in pairs(valuesToSort) do
        local counter = valueToCounter[value]
        local line = '#' .. value .. ': ' .. counter
        textLines[#textLines + 1] = line
        count = count + counter
        total = total + (counter * value)

    end
    if count > 0 then
        textLines[#textLines + 1] = ' '
        if lastCount > 0 then
            if lastlt then
                textLines[#textLines + 1] = '<' .. lastThresh .. ':' .. count
            else
                textLines[#textLines + 1] = lastThresh ..'+:' .. count
            end
            textLines[#textLines + 1] = '!:' .. (lastCount - count)
            textLines[#textLines + 1] = ' '
        else
            textLines[#textLines + 1] = '#: ' .. count
            textLines[#textLines + 1] = ' '
        end
        textLines[#textLines + 1] = '+: ' .. total
        textLines[#textLines + 1] = 'd3: ' .. d3total
    end

    -- Display the text
    local text = table.concat(textLines, '\n')
    if text == '' then
        -- Suppress the default text 'Type Here'
        text = emptyText
    end
    self.editButton({index=0, label=text})
end