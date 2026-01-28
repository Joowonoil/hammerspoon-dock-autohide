-- 현재 focus된 창이 최대화 상태인지에 따라 Dock 자동 숨김/보임

-- Dock autohide 설정 함수
local function setDockAutohide(shouldHide)
    local script
    if shouldHide then
        script = 'tell application "System Events" to set autohide of dock preferences to true'
    else
        script = 'tell application "System Events" to set autohide of dock preferences to false'
    end
    hs.osascript.applescript(script)
end

-- 현재 Dock autohide 상태 가져오기
local function isDockAutohideEnabled()
    local ok, result = hs.osascript.applescript('tell application "System Events" to get autohide of dock preferences')
    return ok and result
end

-- 창이 최대화 상태인지 확인 (분할 제외)
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

    local isMaxWidth = math.abs(winFrame.w - screenFrame.w) <= tolerance or
                       math.abs(winFrame.w - fullFrame.w) <= tolerance

    return isFullHeight and isMaxWidth
end

-- 창이 최대화 또는 분할 상태인지 확인하는 함수
local function isWindowMaximizedOrSplit(win)
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

    local isMaxWidth = math.abs(winFrame.w - screenFrame.w) <= tolerance or
                       math.abs(winFrame.w - fullFrame.w) <= tolerance

    -- 분할 상태 (너비가 화면의 약 50% 또는 33% 또는 67%)
    local halfWidth = fullFrame.w / 2
    local oneThirdWidth = fullFrame.w / 3
    local twoThirdWidth = fullFrame.w * 2 / 3

    local isSplitWidth = math.abs(winFrame.w - halfWidth) <= tolerance or
                         math.abs(winFrame.w - oneThirdWidth) <= tolerance or
                         math.abs(winFrame.w - twoThirdWidth) <= tolerance

    return (isFullHeight and isMaxWidth) or (isFullHeight and isSplitWidth)
end

-- 창을 전체 영역으로 최대화하는 함수
local function maximizeWindowFully(win)
    if not win then return end

    local screen = win:screen()
    if not screen then return end

    local fullFrame = screen:fullFrame()
    local screenFrame = screen:frame()

    -- 메뉴바 높이 계산
    local menuBarHeight = screenFrame.y - fullFrame.y

    -- 메뉴바 아래부터 화면 끝까지
    local newFrame = {
        x = fullFrame.x,
        y = fullFrame.y + menuBarHeight,
        w = fullFrame.w,
        h = fullFrame.h - menuBarHeight
    }

    win:setFrame(newFrame)
end

-- 현재 상태 체크하고 Dock 설정하는 함수
local function checkAndUpdateDock()
    local win = hs.window.focusedWindow()

    -- 창이 없으면 (바탕화면) Dock 보임
    if not win then
        setDockAutohide(false)
        return
    end

    -- 최대화/분할 상태면 Dock 숨김, 아니면 보임
    if isWindowMaximizedOrSplit(win) then
        local wasHidden = isDockAutohideEnabled()
        setDockAutohide(true)

        -- Dock이 새로 숨겨졌고, 최대화 상태일 때만 창 크기 재조정
        if not wasHidden and isWindowMaximized(win) then
            hs.timer.doAfter(0.5, function()
                local currentWin = hs.window.focusedWindow()
                if currentWin and isWindowMaximized(currentWin) then
                    maximizeWindowFully(currentWin)
                end
            end)
        end
    else
        setDockAutohide(false)
    end
end

-- 창 필터 설정
local wf = hs.window.filter.new()

-- 창 focus 변경 시 체크
wf:subscribe(hs.window.filter.windowFocused, function()
    checkAndUpdateDock()
end)

-- 창 이동/크기 변경 시 체크
wf:subscribe(hs.window.filter.windowMoved, function()
    checkAndUpdateDock()
end)

-- 창 닫힐 때 체크
wf:subscribe(hs.window.filter.windowDestroyed, function()
    hs.timer.doAfter(0.1, checkAndUpdateDock)
end)

-- 창 최소화될 때 체크
wf:subscribe(hs.window.filter.windowMinimized, function()
    hs.timer.doAfter(0.1, checkAndUpdateDock)
end)

-- 초기 실행
checkAndUpdateDock()

-- 설정 리로드 단축키 (Cmd+Ctrl+R)
hs.hotkey.bind({"cmd", "ctrl"}, "R", function()
    hs.reload()
end)

hs.alert.show("Hammerspoon 설정 로드됨")
