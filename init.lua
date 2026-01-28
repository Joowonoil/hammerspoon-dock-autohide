-- 최대화 시 Dock 자동숨기기 + 창 확장

local function setDockAutohide(shouldHide)
    if shouldHide then
        hs.osascript.applescript('tell application "System Events" to set autohide of dock preferences to true')
    else
        hs.osascript.applescript('tell application "System Events" to set autohide of dock preferences to false')
    end
end

local function isDockAutohideEnabled()
    local ok, result = hs.osascript.applescript('tell application "System Events" to get autohide of dock preferences')
    return ok and result
end

local function isWindowMaximized(win)
    if not win then return false end

    local screen = win:screen()
    if not screen then return false end

    local screenFrame = screen:frame()
    local fullFrame = screen:fullFrame()
    local winFrame = win:frame()

    local tolerance = 10
    local menuBarHeight = screenFrame.y - fullFrame.y
    local fullHeightWithoutMenuBar = fullFrame.h - menuBarHeight

    local isFullHeight = math.abs(winFrame.h - screenFrame.h) <= tolerance or
                         math.abs(winFrame.h - fullHeightWithoutMenuBar) <= tolerance

    local isFullWidth = math.abs(winFrame.w - screenFrame.w) <= tolerance or
                        math.abs(winFrame.w - fullFrame.w) <= tolerance

    return isFullHeight and isFullWidth
end

local function maximizeWindowFully(win)
    if not win then return end

    local screen = win:screen()
    if not screen then return end

    local fullFrame = screen:fullFrame()
    local screenFrame = screen:frame()

    local menuBarHeight = screenFrame.y - fullFrame.y

    win:setFrame({
        x = fullFrame.x,
        y = fullFrame.y + menuBarHeight,
        w = fullFrame.w,
        h = fullFrame.h - menuBarHeight
    })
end

local function checkAndUpdateDock()
    local win = hs.window.focusedWindow()

    if not win then
        setDockAutohide(false)
        return
    end

    if isWindowMaximized(win) then
        local wasHidden = isDockAutohideEnabled()
        setDockAutohide(true)

        if not wasHidden then
            hs.timer.doAfter(0.5, function()
                local currentWin = hs.window.focusedWindow()
                if currentWin then
                    maximizeWindowFully(currentWin)
                end
            end)
        end
    else
        setDockAutohide(false)
    end
end

local wf = hs.window.filter.new()
wf:subscribe(hs.window.filter.windowFocused, checkAndUpdateDock)
wf:subscribe(hs.window.filter.windowMoved, checkAndUpdateDock)
wf:subscribe(hs.window.filter.windowDestroyed, function() hs.timer.doAfter(0.1, checkAndUpdateDock) end)
wf:subscribe(hs.window.filter.windowMinimized, function() hs.timer.doAfter(0.1, checkAndUpdateDock) end)

hs.hotkey.bind({"cmd", "ctrl"}, "R", hs.reload)

checkAndUpdateDock()
