PhaseBase = {
    actions = {},
    player = '',
    uiAdapter = nil
}

function PhaseBase:new(player, uiAdapter)
    local new = setmetatable({
        player = player,
        uiAdapter = uiAdapter
    }, {__index = PhaseBase})
end

function PhaseBase:complete() 
    self.uiAdapter.resetAll()
end

function PhaseBase:pickup(player, obj) end

function PhaseBase:release(player, obj) end
    