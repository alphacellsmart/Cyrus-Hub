-- ╔══════════════════════════════════════════════════════╗
-- ║            CYRUS HUB  v10.0                         ║
-- ║     12h + Premium  ·  kalel-scripts                 ║
-- ║     cyrus-hub-backend.vercel.app                    ║
-- ╚══════════════════════════════════════════════════════╝

--// =========================================
--//   CONFIG PRINCIPAL
--// =========================================
local HUB_NAME   = "Cyrus Hub"
local HUB_VER    = "v10.0"
local CONFIG_URL = "https://cyrus-hub-backend.vercel.app/api/config"
local SCRIPTS_URL= "https://cyrus-hub-backend.vercel.app/api/scripts"
local LINKS_URL  = "https://cyrus-hub-backend.vercel.app/api/links"
local DISCORD_BR = "https://discord.gg/RCkCmkTFaf"
local DISCORD_EN = "https://discord.gg/RCkCmkTFaf"
local FOLDER_NAME= "CyrusHub"

--// =========================================
--//   SERVICES
--// =========================================
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local RS         = game:GetService("RunService")
local Players    = game:GetService("Players")
local HttpSvc    = (cloneref or function(x) return x end)(game:GetService("HttpService"))
local CoreGui    = game:GetService("CoreGui")
local plr        = Players.LocalPlayer
local pgui       = plr:WaitForChild("PlayerGui")

pcall(function() if pgui:FindFirstChild("CyrusHub")    then pgui.CyrusHub:Destroy()    end end)
pcall(function() if CoreGui:FindFirstChild("CyrusHub") then CoreGui.CyrusHub:Destroy() end end)

--// =========================================
--//   DETECÇÃO DE IDIOMA
--// =========================================
local _locale = "en"
pcall(function()
    local l = game:GetService("LocalizationService").RobloxLocaleId or ""
    l = l:lower()
    if l:sub(1,2)=="pt" then _locale="pt"
    elseif l:sub(1,2)=="ru" then _locale="ru"
    elseif l:sub(1,2)=="es" then _locale="es"
    elseif l:sub(1,2)=="vi" then _locale="vi"
    elseif l:sub(1,2)=="th" then _locale="th"
    elseif l:sub(1,2)=="tr" then _locale="tr"
    elseif l:sub(1,2)=="ar" then _locale="ar"
    elseif l:sub(1,2)=="fr" then _locale="fr"
    elseif l:sub(1,2)=="de" then _locale="de"
    elseif l:sub(1,2)=="id" then _locale="id"
    elseif l:sub(1,2)=="ko" then _locale="ko"
    elseif l:sub(1,2)=="ja" then _locale="ja"
    elseif l:sub(1,2)=="zh" then _locale="zh"
    elseif l:sub(1,2)=="pl" then _locale="pl"
    end
end)
local _isBR = (_locale == "pt")
local function T(pt, en, ru, es, vi, th)
    if _locale=="pt" then return pt
    elseif _locale=="ru" then return ru or en
    elseif _locale=="es" then return es or en
    elseif _locale=="vi" then return vi or en
    elseif _locale=="th" then return th or en
    else return en end
end

--// =========================================
--//   FETCH JSON
--// =========================================
local function fetchJSON(url)
    local ok, raw = pcall(function() return game:HttpGet(url, true) end)
    if not ok or not raw or raw == "" then return nil end
    local cleaned = raw:gsub("%-%-[^\n]*",""):gsub("%s+"," ")
    local dok, data = pcall(function() return HttpSvc:JSONDecode(cleaned) end)
    return dok and data or nil
end

--// =========================================
--//   CARREGA CONFIG EXTERNA
--// =========================================
local externalConfig = fetchJSON(CONFIG_URL) or {}
local linksData      = fetchJSON(LINKS_URL)  or {}

local INTERNAL_CONFIG = {
    Links          = {},
    LinkExpiryTime = 43200,
    DiscordBR      = DISCORD_BR,
    DiscordEN      = DISCORD_EN,
}

if type(linksData) == "table" then
    if linksData["DiscordBR"] then INTERNAL_CONFIG.DiscordBR = linksData["DiscordBR"] end
    if linksData["DiscordEN"] then INTERNAL_CONFIG.DiscordEN = linksData["DiscordEN"] end
    linksData["DiscordBR"] = nil; linksData["DiscordEN"] = nil
    INTERNAL_CONFIG.Links = linksData
end

local CFG_KERNEL     = externalConfig.KernelEnabled ~= false
local CFG_ICON       = externalConfig.OpenIcon    or "rbxassetid://112738695202091"
local CFG_THEME      = externalConfig.ThemeSelect or "darker"
local CFG_SND        = externalConfig.SoundId     or ""
local CFG_VOL        = externalConfig.SoundVolume or 1
local CFG_PREMIUMKEY = externalConfig.PremiumKey  or ""

--// =========================================
--//   CARREGA SCRIPTS EXTERNOS (IronTech integration)
--// =========================================
local MY_SCRIPTS = {}
local remoteScripts = fetchJSON(SCRIPTS_URL)
if type(remoteScripts) == "table" then
    for _, s in ipairs(remoteScripts) do
        table.insert(MY_SCRIPTS, s)
    end
end
-- Scripts locais fixos (fallback)
if #MY_SCRIPTS == 0 then
    MY_SCRIPTS = {
        {name="Redz Hub", desc="Script hub universal", url="https://raw.githubusercontent.com/huy384/redzHub/refs/heads/main/redzHub.lua"},
    }
end

--// =========================================
--//   DETECÇÃO DE JOGO
--// =========================================
local PLACE_ID = game.PlaceId
local GAMES = {
    [2753915549]="BloxFruits",[4442272183]="BloxFruits",[16078638328]="BloxFruits",
    [6284583030]="PetSimX",[142823291]="MM2",[2788229376]="DaHood",
    [3214529440]="KingLegacy",[8173705722]="KingLegacy",[7054676802]="WeakLegacy",
    [921042218]="AnimeFighting",[5567483462]="AnimeFighting",[13049847188]="JujutsuShenanigans",
    [13772394625]="BladeBall",[286090429]="Arsenal",[6516141723]="Doors",
    [4924922222]="Brookhaven",[6372028509]="ShindoLife",[8737384332]="GPO",
    [13022880397]="FruitBattlegrounds",[12282861865]="AnimeAdventures",
    [17017769292]="SolsRNG",[9504325490]="TypeSoul",
    [66654135]="MM2",[8202280624]="BBN",[9098570654]="STA",
}
local gameKey  = GAMES[PLACE_ID] or "Universal"
local gameName = T("Desconhecido","Unknown")
pcall(function() gameName = game:GetService("MarketplaceService"):GetProductInfo(PLACE_ID).Name end)

--// =========================================
--//   TEMA (roxo Hollow Purple)
--// =========================================
local Theme = {
    accent    = Color3.fromRGB(120,0,240),
    accentLit = Color3.fromRGB(160,0,255),
    accentGlow= Color3.fromRGB(180,60,255),
    bg        = Color3.fromRGB(8,8,12),
    bg2       = Color3.fromRGB(14,14,22),
    bg3       = Color3.fromRGB(20,20,30),
    text      = Color3.fromRGB(235,235,235),
    textDim   = Color3.fromRGB(130,130,150),
    danger    = Color3.fromRGB(255,60,60),
    success   = Color3.fromRGB(60,220,120),
    gold      = Color3.fromRGB(255,200,60),
}
local THEMES = {
    {name=T("Roxo","Purple","Фиолетовый","Morado","Tim","สีม่วง"),  accent=Color3.fromRGB(120,0,240), accentLit=Color3.fromRGB(160,0,255)},
    {name=T("Azul","Blue","Синий","Azul","Xanh","สีน้ำเงิน"),       accent=Color3.fromRGB(0,100,255), accentLit=Color3.fromRGB(0,160,255)},
    {name=T("Verde","Green","Зелёный","Verde","Xanh la","สีเขียว"),  accent=Color3.fromRGB(0,180,80),  accentLit=Color3.fromRGB(0,220,100)},
    {name=T("Laranja","Orange","Оранжевый","Naranja","Cam","สีส้ม"), accent=Color3.fromRGB(220,100,0), accentLit=Color3.fromRGB(255,140,0)},
    {name=T("Rosa","Pink","Розовый","Rosa","Hong","สีชมพู"),          accent=Color3.fromRGB(200,0,120), accentLit=Color3.fromRGB(255,0,160)},
    {name=T("Ciano","Cyan","Голубой","Cian","Xanh nhat","สีฟ้า"),    accent=Color3.fromRGB(0,180,200), accentLit=Color3.fromRGB(0,220,240)},
    {name=T("Vermelho","Red","Красный","Rojo","Do","สีแดง"),          accent=Color3.fromRGB(210,30,30), accentLit=Color3.fromRGB(255,60,60)},
    {name=T("Dourado","Gold","Золотой","Dorado","Vang","สีทอง"),      accent=Color3.fromRGB(200,150,0), accentLit=Color3.fromRGB(240,190,30)},
}

--// =========================================
--//   DATA MANAGER
--// =========================================
local DataManager = {}
DataManager.__index = DataManager
function DataManager.new()
    local self = setmetatable({}, DataManager)
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    return self
end
function DataManager:save(f, d)
    pcall(function() writefile(FOLDER_NAME.."/"..f, HttpSvc:JSONEncode(d)) end)
end
function DataManager:load(f)
    local fp = FOLDER_NAME.."/"..f
    if not isfile(fp) then return nil end
    local ok, r = pcall(function() return HttpSvc:JSONDecode(readfile(fp)) end)
    return ok and r or nil
end
local dm = DataManager.new()

--// =========================================
--//   VALIDAÇÃO
--// =========================================
local function isLinkValid()
    local s = dm:load("Link.json")
    if not s or not s.time then return false end
    return (tick()-s.time) <= INTERNAL_CONFIG.LinkExpiryTime
end
local function validateKey(k, link)
    local exp = INTERNAL_CONFIG.Links[link]
    return exp and k == exp
end
local function isPremiumKey(k)
    if not k or CFG_PREMIUMKEY == "" then return false end
    return tostring(k) == tostring(CFG_PREMIUMKEY)
end
local function hasSavedPremium()
    local s = dm:load("PremiumKey.json")
    if not s or not s.key then return false end
    return isPremiumKey(s.key)
end

--// =========================================
--//   EXECUTOR
--// =========================================
local function getExecutorName()
    if identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n and n~="" then return n end end
    if getexecutorname  then local ok,n=pcall(getexecutorname);  if ok and n and n~="" then return n end end
    return "Unknown"
end

local session = {key=nil, type=nil, expiresAt=nil, premium=false}
local state   = {
    esp=false, autoFarm=false, autoCollect=false, godMode=false,
    fly=false, noclip=false, antiAfk=false, hitbox=false,
    killAura=false, infStamina=false, speedHack=false, jumpHack=false,
    speedVal=16, jumpVal=50,
}
local connections = {}
local function killConn(k) if connections[k] then pcall(function() connections[k]:Disconnect() end); connections[k]=nil end end

local _acessoJaLiberado = false

local function executarAposLiberar()
    -- executa loadstring do script favorito do jogo ou universal
    -- placeholder — scripts são executados pela tab Scripts
end

local function liberarAcesso()
    if _acessoJaLiberado then return end
    _acessoJaLiberado = true
    -- limpa todas as GUIs do sistema de senha
    pcall(function()
        for _, gui in CoreGui:GetChildren() do
            if gui.Name:find("CyrusKey") or gui.Name:find("CyrusAnim") then
                gui:Destroy()
            end
        end
    end)
    if CFG_SND ~= "" then
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId=CFG_SND; s.Volume=CFG_VOL
            s.Parent=game:GetService("SoundService")
            if not s.IsLoaded then s.Loaded:Wait() end
            s:Play(); game:GetService("Debris"):AddItem(s,15)
        end)
    end
    task.spawn(pcall, executarAposLiberar)
end

--// =========================================
--//   BYPASS RÁPIDO (antes de carregar UI)
--// =========================================
do
    local savedLink = dm:load("Link.json")
    local savedKey  = dm:load("Key.json")
    local temPremium   = hasSavedPremium()
    local temKeyValida = savedLink and savedKey and isLinkValid() and validateKey(savedKey.key, savedLink.link)
    local kernelOff    = not CFG_KERNEL

    if temPremium or temKeyValida or kernelOff then
        -- marca sessão
        if temPremium then session.premium=true; session.type="premium"
        elseif temKeyValida then session.type="12h"; session.expiresAt=savedKey and savedKey.time and (savedKey.time+43200) or nil
        end
        _acessoJaLiberado = true
        -- pula direto pro hub principal sem tela de chave
        -- (continua execução abaixo sem return)
    end
end

--// =========================================
--//   UI UTILITÁRIOS
--// =========================================
local function corner(i,r) local c=Instance.new("UICorner",i); c.CornerRadius=UDim.new(0,r or 10); return c end
local function mkStroke(i,c,t) local s=Instance.new("UIStroke",i); s.Color=c or Theme.accent; s.Thickness=t or 1.5; return s end
local function tw(i,t,p,s,d) TS:Create(i,TweenInfo.new(t,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out),p):Play() end
local function notify(txt) pcall(function() game.StarterGui:SetCore("SendNotification",{Title="CYRUS HUB",Text=txt,Duration=4}) end) end

local function draggable(frame)
    local drag,dStart,sPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dStart=i.Position; sPos=frame.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dStart
            frame.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+d.X,sPos.Y.Scale,sPos.Y.Offset+d.Y)
        end
    end)
end

local function mkFrame(parent,size,pos,col,z,rad)
    local f=Instance.new("Frame",parent)
    f.Size=size; f.Position=pos or UDim2.new(0,0,0,0); f.BackgroundColor3=col or Theme.bg2
    f.ZIndex=z or 5; f.BorderSizePixel=0; if rad then corner(f,rad) end; return f
end
local function mkLabel(parent,txt,size,bold,col,xalign,z)
    local l=Instance.new("TextLabel",parent)
    l.Text=txt; l.TextSize=size or 12; l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextColor3=col or Theme.text; l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,1,0)
    l.TextXAlignment=xalign or Enum.TextXAlignment.Center; l.ZIndex=z or 5; l.TextWrapped=true; return l
end
local function mkBtn(parent,size,pos,col,txt,z,rad)
    local b=Instance.new("TextButton",parent)
    b.Size=size; b.Position=pos; b.BackgroundColor3=col or Theme.accent
    b.Text=txt or ""; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.TextColor3=Theme.text
    b.ZIndex=z or 5; b.BorderSizePixel=0; b.AutoButtonColor=false
    if rad then corner(b,rad) end; return b
end

--// =========================================
--//   SCREENGUI PRINCIPAL
--// =========================================
local sg=Instance.new("ScreenGui")
sg.Name="CyrusHub"; sg.ResetOnSpawn=false; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.IgnoreGuiInset=true
pcall(function() sg.Parent=CoreGui end)
if not sg.Parent then sg.Parent=pgui end

--// =========================================
--//   ANIMAÇÃO DE INTRO — HOLLOW PURPLE ÉPICA v2
--// =========================================
local animLayer=mkFrame(sg,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),100)
animLayer.Visible=true

-- Fundo com gradiente animado
local animBg=mkFrame(animLayer,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),100)

-- Partículas de fundo (estrelas)
local starFolder=Instance.new("Frame",animLayer)
starFolder.Size=UDim2.new(1,0,1,0); starFolder.BackgroundTransparency=1; starFolder.ZIndex=101
for i=1,30 do
    local star=Instance.new("Frame",starFolder)
    local sz=math.random(2,5)
    star.Size=UDim2.new(0,sz,0,sz)
    star.Position=UDim2.new(math.random(5,95)/100,0,math.random(5,95)/100,0)
    star.BackgroundColor3=Color3.fromRGB(200,150,255)
    star.BorderSizePixel=0; star.ZIndex=101; star.BackgroundTransparency=math.random(3,7)/10
    corner(star,sz)
    task.spawn(function()
        while star and star.Parent do
            tw(star,math.random(8,20)/10,{BackgroundTransparency=math.random(1,9)/10})
            task.wait(math.random(8,20)/10)
        end
    end)
end

-- Orb azul (esquerda)
local blueOrb=mkFrame(animLayer,UDim2.new(0,70,0,70),UDim2.new(0,-90,0.5,-35),Color3.fromRGB(0,80,255),102,35)
local blueHalo=mkFrame(animLayer,UDim2.new(0,140,0,140),UDim2.new(0,-160,0.5,-70),Color3.fromRGB(0,60,200),101,70)
blueHalo.BackgroundTransparency=0.6
local blueTrail=mkFrame(animLayer,UDim2.new(0,0,0,6),UDim2.new(0,0,0.5,-3),Color3.fromRGB(0,120,255),101,3)
blueTrail.BackgroundTransparency=0.2; blueTrail.Visible=false

-- Orb vermelho (direita)
local redOrb=mkFrame(animLayer,UDim2.new(0,70,0,70),UDim2.new(1,10,0.5,-35),Color3.fromRGB(220,0,50),102,35)
local redHalo=mkFrame(animLayer,UDim2.new(0,140,0,140),UDim2.new(1,10,0.5,-70),Color3.fromRGB(180,0,30),101,70)
redHalo.BackgroundTransparency=0.6
local redTrail=mkFrame(animLayer,UDim2.new(0,0,0,6),UDim2.new(1,0,0.5,-3),Color3.fromRGB(255,60,60),101,3)
redTrail.BackgroundTransparency=0.2; redTrail.Visible=false

-- Flash de colisão
local flashF=mkFrame(animLayer,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(255,255,255),103)
flashF.BackgroundTransparency=1

-- Ondas de choque (3 anéis)
local shocks={}
for i=1,3 do
    local s=mkFrame(animLayer,UDim2.new(0,10,0,10),UDim2.new(0.5,-5,0.5,-5),Color3.fromRGB(160,0,255),102,999)
    s.BackgroundTransparency=1; s.Visible=false
    mkStroke(s,Color3.fromRGB(180,60,255),2+i)
    shocks[i]=s
end

-- Partículas de explosão
local expParts={}
for i=1,20 do
    local p=mkFrame(animLayer,UDim2.new(0,6,0,6),UDim2.new(0.5,-3,0.5,-3),Color3.fromRGB(
        math.random(100,255), math.random(0,80), math.random(200,255)
    ),103,3)
    p.BackgroundTransparency=1; p.Visible=false
    expParts[i]=p
end

-- Orb roxo central (resultado da colisão — Hollow Purple)
local purpleOrb=mkFrame(animLayer,UDim2.new(0,0,0,0),UDim2.new(0.5,0,0.5,0),Color3.fromRGB(120,0,240),104,999)
purpleOrb.BackgroundTransparency=1; purpleOrb.Visible=false
local purpleGlow=mkFrame(animLayer,UDim2.new(0,0,0,0),UDim2.new(0.5,0,0.5,0),Color3.fromRGB(80,0,180),103,999)
purpleGlow.BackgroundTransparency=1; purpleGlow.Visible=false

-- Raios de energia irradiando do centro
local rays={}
for i=1,8 do
    local r=mkFrame(animLayer,UDim2.new(0,3,0,0),UDim2.new(0.5,-1,0.5,0),Color3.fromRGB(160,0,255),103)
    r.BackgroundTransparency=0.3; r.Visible=false
    r.AnchorPoint=Vector2.new(0.5,0)
    rays[i]=r
end

-- Texto central
local centerTxt=Instance.new("TextLabel",animLayer)
centerTxt.Size=UDim2.new(0.8,0,0,40); centerTxt.Position=UDim2.new(0.1,0,0.5,-20)
centerTxt.BackgroundTransparency=1; centerTxt.Text="CYRUS HUB"
centerTxt.Font=Enum.Font.GothamBold; centerTxt.TextSize=32
centerTxt.TextColor3=Color3.fromRGB(255,255,255); centerTxt.TextTransparency=1; centerTxt.ZIndex=105
centerTxt.TextStrokeTransparency=0.4; centerTxt.TextStrokeColor3=Color3.fromRGB(120,0,240)

local versionTxt=Instance.new("TextLabel",animLayer)
versionTxt.Size=UDim2.new(0.6,0,0,20); versionTxt.Position=UDim2.new(0.2,0,0.5,24)
versionTxt.BackgroundTransparency=1; versionTxt.Text=HUB_VER.."  ·  kalel-scripts"
versionTxt.Font=Enum.Font.GothamMedium; versionTxt.TextSize=13
versionTxt.TextColor3=Color3.fromRGB(200,150,255); versionTxt.TextTransparency=1; versionTxt.ZIndex=105

-- Loading bar (após colisão)
local loadLayer=mkFrame(animLayer,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(4,4,10),106)
loadLayer.BackgroundTransparency=1; loadLayer.Visible=false
local loadBg=mkFrame(loadLayer,UDim2.new(0,320,0,110),UDim2.new(0.5,-160,0.5,-55),Color3.fromRGB(10,10,18),107,14)
mkStroke(loadBg,Theme.accent,1.5)
local loadIc=mkFrame(loadBg,UDim2.new(0,32,0,32),UDim2.new(0.5,-16,0,14),Theme.accent,108,10)
mkLabel(loadIc,"◆",16,true,Color3.fromRGB(255,255,255),nil,109)
local loadTxt=Instance.new("TextLabel",loadBg); loadTxt.Size=UDim2.new(1,0,0,18); loadTxt.Position=UDim2.new(0,0,0,52)
loadTxt.BackgroundTransparency=1; loadTxt.Text=T("Carregando módulos...","Loading modules..."); loadTxt.Font=Enum.Font.GothamBold; loadTxt.TextSize=12
loadTxt.TextColor3=Color3.fromRGB(255,255,255); loadTxt.ZIndex=108
local barBg=mkFrame(loadBg,UDim2.new(1,-30,0,5),UDim2.new(0,15,0,76),Color3.fromRGB(20,20,35),108,3)
local barFill=mkFrame(barBg,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),Theme.accent,109,3)
local loadPct=Instance.new("TextLabel",loadBg); loadPct.Size=UDim2.new(1,0,0,14); loadPct.Position=UDim2.new(0,0,0,86)
loadPct.BackgroundTransparency=1; loadPct.Text="0%"; loadPct.Font=Enum.Font.GothamMedium; loadPct.TextSize=10
loadPct.TextColor3=Theme.textDim; loadPct.ZIndex=108

--// =========================================
--//   HUB PRINCIPAL (invisível até animação terminar)
--// =========================================
local HUB_W,HUB_H=440,500
local hub=mkFrame(sg,UDim2.new(0,HUB_W,0,HUB_H),UDim2.new(0.5,-HUB_W/2,0.5,-HUB_H/2),Theme.bg,10,14)
hub.BackgroundTransparency=1; hub.Visible=false; mkStroke(hub,Theme.accent,1.5)
local hubGlow=mkFrame(sg,UDim2.new(0,HUB_W+40,0,HUB_H+40),UDim2.new(0.5,-(HUB_W+40)/2,0.5,-(HUB_H+40)/2),Color3.fromRGB(80,0,180),9,20)
hubGlow.BackgroundTransparency=1; hubGlow.Visible=false; draggable(hub)

-- Header
local header=mkFrame(hub,UDim2.new(1,0,0,46),UDim2.new(0,0,0,0),Theme.bg2,11,14)
local headerAccent=mkFrame(header,UDim2.new(1,0,0,2),UDim2.new(0,0,1,-2),Theme.accent,12)
headerAccent.BackgroundTransparency=0.5
local iconF=mkFrame(header,UDim2.new(0,28,0,28),UDim2.new(0,10,0.5,-14),Theme.accent,12,8)
mkLabel(iconF,"◆",14,true,Color3.fromRGB(255,255,255),nil,13)
local titleL=Instance.new("TextLabel",header); titleL.Size=UDim2.new(1,-120,0,22); titleL.Position=UDim2.new(0,46,0,6)
titleL.BackgroundTransparency=1; titleL.Text="CYRUS HUB"; titleL.Font=Enum.Font.GothamBold; titleL.TextSize=16
titleL.TextColor3=Color3.fromRGB(255,255,255); titleL.TextXAlignment=Enum.TextXAlignment.Left; titleL.ZIndex=12
local subL=Instance.new("TextLabel",header); subL.Size=UDim2.new(1,-120,0,14); subL.Position=UDim2.new(0,46,0,28)
subL.BackgroundTransparency=1; subL.Text=T("Bem-vindo, ","Welcome, ")..plr.Name; subL.Font=Enum.Font.Gotham; subL.TextSize=10
subL.TextColor3=Theme.textDim; subL.TextXAlignment=Enum.TextXAlignment.Left; subL.ZIndex=12
local closeBtn=mkBtn(header,UDim2.new(0,28,0,28),UDim2.new(1,-36,0.5,-14),Theme.bg3,"X",12,8)
closeBtn.TextColor3=Theme.textDim; closeBtn.TextSize=14

-- Tab bar
local tabBar=mkFrame(hub,UDim2.new(1,-16,0,34),UDim2.new(0,8,0,52),Theme.bg3,11,8)
local tl=Instance.new("UIListLayout",tabBar); tl.FillDirection=Enum.FillDirection.Horizontal; tl.Padding=UDim.new(0,3)
local sep=mkFrame(hub,UDim2.new(1,-16,0,1),UDim2.new(0,8,0,92),Theme.accent,11); sep.BackgroundTransparency=0.8

-- Content
local content=Instance.new("ScrollingFrame",hub)
content.Size=UDim2.new(1,-16,1,-108); content.Position=UDim2.new(0,8,0,96)
content.BackgroundTransparency=1; content.BorderSizePixel=0; content.ScrollBarThickness=3
content.ScrollBarImageColor3=Theme.accent; content.ZIndex=11; content.ClipsDescendants=true
local cLayout=Instance.new("UIListLayout",content); cLayout.Padding=UDim.new(0,5)
local cPad=Instance.new("UIPadding",content); cPad.PaddingTop=UDim.new(0,4); cPad.PaddingBottom=UDim.new(0,6)

-- Footer
local verLbl=Instance.new("TextLabel",hub); verLbl.Size=UDim2.new(0.5,0,0,13); verLbl.Position=UDim2.new(0,8,1,-14)
verLbl.BackgroundTransparency=1; verLbl.Text="Cyrus Hub "..HUB_VER; verLbl.Font=Enum.Font.Gotham; verLbl.TextSize=9; verLbl.TextColor3=Theme.textDim; verLbl.TextXAlignment=Enum.TextXAlignment.Left; verLbl.ZIndex=11
local timerLbl=Instance.new("TextLabel",hub); timerLbl.Size=UDim2.new(0,200,0,13); timerLbl.Position=UDim2.new(1,-204,1,-14)
timerLbl.BackgroundTransparency=1; timerLbl.Text=""; timerLbl.Font=Enum.Font.GothamBold; timerLbl.TextSize=9; timerLbl.TextColor3=Theme.accentLit; timerLbl.TextXAlignment=Enum.TextXAlignment.Right; timerLbl.ZIndex=11

-- FAB (floating action button)
local fab=mkBtn(sg,UDim2.new(0,46,0,46),UDim2.new(0,14,0.5,-23),Theme.bg2,"◆",20,12)
fab.TextColor3=Theme.accentLit; fab.TextSize=22; fab.Visible=false; mkStroke(fab,Theme.accent,2); draggable(fab)

-- Watermark
local wm=Instance.new("TextLabel",sg)
wm.Size=UDim2.new(0,240,0,14); wm.Position=UDim2.new(1,-244,1,-18)
wm.BackgroundTransparency=1; wm.Text=""
wm.Font=Enum.Font.GothamMedium; wm.TextSize=9
wm.TextColor3=Color3.fromRGB(200,150,255); wm.TextTransparency=0.45
wm.TextXAlignment=Enum.TextXAlignment.Right; wm.ZIndex=25; wm.Visible=false

--// =========================================
--//   TELA DE CHAVE (se precisar)
--// =========================================
local keyLayer, kInput, kBtn, kStatus, kGetBtn
if not _acessoJaLiberado then
    keyLayer=mkFrame(sg,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),50)
    keyLayer.BackgroundTransparency=0.4; keyLayer.Visible=false

    local keyFrame=mkFrame(keyLayer,UDim2.new(0,360,0,260),UDim2.new(0.5,-180,0.5,-130),Theme.bg,51,16)
    mkStroke(keyFrame,Theme.accent,1.5)
    local keyGlow=mkFrame(keyLayer,UDim2.new(0,400,0,300),UDim2.new(0.5,-200,0.5,-150),Color3.fromRGB(60,0,120),50,20)
    keyGlow.BackgroundTransparency=0.85

    -- Header da tela de chave
    local kHeader=mkFrame(keyFrame,UDim2.new(1,0,0,50),UDim2.new(0,0,0,0),Theme.bg2,52,16)
    local kIcon=mkFrame(kHeader,UDim2.new(0,32,0,32),UDim2.new(0,14,0.5,-16),Theme.accent,53,8)
    mkLabel(kIcon,"◆",16,true,Color3.fromRGB(255,255,255),nil,54)
    local kTitle=Instance.new("TextLabel",kHeader); kTitle.Size=UDim2.new(1,-60,0,22); kTitle.Position=UDim2.new(0,54,0,8)
    kTitle.BackgroundTransparency=1; kTitle.Text="CYRUS HUB — "..T("Verificação","Verification"); kTitle.Font=Enum.Font.GothamBold; kTitle.TextSize=14
    kTitle.TextColor3=Color3.fromRGB(255,255,255); kTitle.TextXAlignment=Enum.TextXAlignment.Left; kTitle.ZIndex=53
    local kSub=Instance.new("TextLabel",kHeader); kSub.Size=UDim2.new(1,-60,0,14); kSub.Position=UDim2.new(0,54,0,30)
    kSub.BackgroundTransparency=1; kSub.Text=T("Cole ou digite sua chave de acesso","Paste or enter your access key"); kSub.Font=Enum.Font.Gotham; kSub.TextSize=10
    kSub.TextColor3=Theme.textDim; kSub.TextXAlignment=Enum.TextXAlignment.Left; kSub.ZIndex=53

    -- Input
    local kInputBg=mkFrame(keyFrame,UDim2.new(1,-30,0,38),UDim2.new(0,15,0,62),Theme.bg3,52,8)
    mkStroke(kInputBg,Theme.accent,1)
    kInput=Instance.new("TextBox",kInputBg); kInput.Size=UDim2.new(1,-12,1,0); kInput.Position=UDim2.new(0,6,0,0)
    kInput.BackgroundTransparency=1; kInput.Text=""; kInput.PlaceholderText=T("Cole sua chave...","Paste your key...")
    kInput.Font=Enum.Font.GothamMedium; kInput.TextSize=12; kInput.TextColor3=Color3.fromRGB(255,255,255)
    kInput.PlaceholderColor3=Theme.textDim; kInput.ZIndex=53; kInput.ClearTextOnFocus=false

    -- Status
    kStatus=Instance.new("TextLabel",keyFrame); kStatus.Size=UDim2.new(1,-30,0,14); kStatus.Position=UDim2.new(0,15,0,106)
    kStatus.BackgroundTransparency=1; kStatus.Text=""; kStatus.Font=Enum.Font.Gotham; kStatus.TextSize=10
    kStatus.TextColor3=Theme.textDim; kStatus.TextXAlignment=Enum.TextXAlignment.Left; kStatus.ZIndex=52

    -- Botão entrar
    kBtn=mkBtn(keyFrame,UDim2.new(1,-30,0,38),UDim2.new(0,15,0,126),Theme.accent,T("Entrar","Enter"),52,8)
    kBtn.TextSize=13
    kBtn.MouseEnter:Connect(function() tw(kBtn,0.15,{BackgroundColor3=Theme.accentLit}) end)
    kBtn.MouseLeave:Connect(function() tw(kBtn,0.15,{BackgroundColor3=Theme.accent}) end)

    -- Separador
    local sepK=mkFrame(keyFrame,UDim2.new(1,-30,0,1),UDim2.new(0,15,0,174),Theme.accent,52); sepK.BackgroundTransparency=0.7
    local orLbl=Instance.new("TextLabel",keyFrame); orLbl.Size=UDim2.new(0,30,0,14); orLbl.Position=UDim2.new(0.5,-15,0,168)
    orLbl.BackgroundTransparency=0; orLbl.BackgroundColor3=Theme.bg; orLbl.Text="ou"; orLbl.Font=Enum.Font.Gotham; orLbl.TextSize=9; orLbl.TextColor3=Theme.textDim; orLbl.ZIndex=53

    -- Botão obter chave
    kGetBtn=mkBtn(keyFrame,UDim2.new(1,-30,0,36),UDim2.new(0,15,0,184),Theme.bg3,T("🔗 Obter Chave","🔗 Get Key"),52,8)
    kGetBtn.TextColor3=Theme.accentLit; kGetBtn.TextSize=12; mkStroke(kGetBtn,Theme.accent,1)
    kGetBtn.MouseEnter:Connect(function() tw(kGetBtn,0.15,{BackgroundColor3=Color3.fromRGB(30,10,50)}) end)
    kGetBtn.MouseLeave:Connect(function() tw(kGetBtn,0.15,{BackgroundColor3=Theme.bg3}) end)

    -- Botão obter chave → copia link aleatório
    kGetBtn.MouseButton1Click:Connect(function()
        local links={}
        for link in pairs(INTERNAL_CONFIG.Links) do table.insert(links,link) end
        if #links==0 then kStatus.TextColor3=Theme.danger; kStatus.Text=T("Nenhum link disponível","No links available"); return end
        local randomLink=links[math.random(#links)]
        dm:save("Link.json",{link=randomLink,time=tick()})
        pcall(function() setclipboard(randomLink) end)
        kStatus.TextColor3=Theme.gold; kStatus.Text=T("Link copiado! Complete e volte aqui.","Link copied! Complete and come back.")
    end)

    -- Versão na tela de chave
    local kVer=Instance.new("TextLabel",keyFrame); kVer.Size=UDim2.new(1,0,0,12); kVer.Position=UDim2.new(0,0,1,-14)
    kVer.BackgroundTransparency=1; kVer.Text="Cyrus Hub "..HUB_VER.." · kalel-scripts"; kVer.Font=Enum.Font.Gotham; kVer.TextSize=8; kVer.TextColor3=Theme.textDim; kVer.ZIndex=52
end

--// =========================================
--//   TIMER COUNTDOWN
--// =========================================
local function startCountdown()
    if session.premium then timerLbl.Text=T("◆ Premium — Vitalício","◆ Premium — Lifetime"); timerLbl.TextColor3=Color3.fromRGB(180,140,255); return end
    task.spawn(function()
        while hub and hub.Parent do
            if session.expiresAt then
                local diff=session.expiresAt-os.time()
                if diff<=0 then timerLbl.Text=T("⚠ Expirada!","⚠ Expired!"); timerLbl.TextColor3=Theme.danger
                else local h2=math.floor(diff/3600); local m=math.floor((diff%3600)/60); local s=diff%60
                    timerLbl.Text=string.format("⏳ %02d:%02d:%02d",h2,m,s)
                    timerLbl.TextColor3=diff>3600 and Theme.accentLit or Theme.danger end
            end; task.wait(1)
        end
    end)
end

--// =========================================
--//   FUNÇÕES DE JOGO
--// =========================================
local function getChar() return plr.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function setSpeed(val) state.speedVal=val; pcall(function() local h=getHum(); if h then h.WalkSpeed=val end end) end
local function setJump(val)  state.jumpVal=val;  pcall(function() local h=getHum(); if h then h.JumpPower=val end end) end

local function startAutoFarm()
    killConn("autoFarm"); connections["autoFarm"]=RS.Heartbeat:Connect(function()
        pcall(function()
            local hrp=getHRP(); local hum=getHum(); if not hrp or not hum or hum.Health<=0 then return end
            local closest,cDist=nil,250
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj~=getChar() then
                    local oh=obj:FindFirstChildOfClass("Humanoid"); local ohrp=obj:FindFirstChild("HumanoidRootPart")
                    if oh and ohrp and oh.Health>0 then
                        local isP=false; for _,p2 in ipairs(Players:GetPlayers()) do if p2.Character==obj then isP=true; break end end
                        if not isP then local d=(hrp.Position-ohrp.Position).Magnitude; if d<cDist then closest=ohrp; cDist=d end end
                    end
                end
            end
            if closest then hrp.CFrame=closest.CFrame*CFrame.new(0,0,3.5) end
        end); task.wait(0.1)
    end)
end

local espFolder=nil
local function enableESP()
    if espFolder then espFolder:Destroy() end; espFolder=Instance.new("Folder",CoreGui); espFolder.Name="CyrusESP"
    local function addESP(target) pcall(function()
        local char=target.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local bb=Instance.new("BillboardGui",hrp); bb.Name="CyrusESPBB"; bb.Size=UDim2.new(0,80,0,30); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
        local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=target.Name; lbl.TextScaled=true; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.fromRGB(255,80,80); lbl.TextStrokeTransparency=0
        local hl=Instance.new("SelectionBox",espFolder); hl.Adornee=char; hl.Color3=Color3.fromRGB(255,60,60); hl.LineThickness=0.05; hl.SurfaceTransparency=0.85; hl.SurfaceColor3=Color3.fromRGB(255,60,60)
    end) end
    for _,p in ipairs(Players:GetPlayers()) do if p~=plr then addESP(p) end end
    connections["espAdded"]=Players.PlayerAdded:Connect(function(p) task.wait(3); if state.esp then addESP(p) end end)
end
local function disableESP() killConn("espAdded"); if espFolder then espFolder:Destroy(); espFolder=nil end end

local flyActive=false
local function startFly()
    flyActive=true; task.spawn(function()
        local hrp=getHRP(); if not hrp then return end
        local bv=Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(9e9,9e9,9e9)
        local bg=Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=hrp.CFrame
        while flyActive and hrp and hrp.Parent do
            local cam=workspace.CurrentCamera; local v=Vector3.new(0,0,0); local spd=55
            if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.CFrame.LookVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.CFrame.LookVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.CFrame.RightVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.CFrame.RightVector*spd end
            if UIS:IsKeyDown(Enum.KeyCode.Space)      then v=v+Vector3.new(0,spd,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v=v-Vector3.new(0,spd,0) end
            bv.Velocity=v; bg.CFrame=cam.CFrame; task.wait()
        end
        pcall(function() bv:Destroy(); bg:Destroy() end)
    end)
end
local function stopFly() flyActive=false end

local function startNoclip() killConn("noclip"); connections["noclip"]=RS.Stepped:Connect(function()
    pcall(function() local c=getChar(); if c then for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end)
end) end
local function startAntiAfk() killConn("antiAfk"); connections["antiAfk"]=plr.Idled:Connect(function()
    pcall(function() local vu=game:GetService("VirtualUser"); vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame); task.wait(1); vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end)
end) end
local function startHitbox() killConn("hitbox"); connections["hitbox"]=RS.Heartbeat:Connect(function()
    pcall(function() for _,p in ipairs(Players:GetPlayers()) do if p~=plr and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size=Vector3.new(8,8,8) end end end end)
end) end
local function stopHitbox() killConn("hitbox"); pcall(function() for _,p in ipairs(Players:GetPlayers()) do if p~=plr and p.Character then local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Size=Vector3.new(2,2,1) end end end end) end
local function startGodMode() killConn("godMode"); connections["godMode"]=RS.Heartbeat:Connect(function() pcall(function() local h=getHum(); if h then h.Health=h.MaxHealth end end) end) end
local function startKillAura() killConn("killAura"); connections["killAura"]=RS.Heartbeat:Connect(function()
    pcall(function()
        local hrp=getHRP(); if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=plr and p.Character then
            local oHRP=p.Character:FindFirstChild("HumanoidRootPart")
            if oHRP and (oHRP.Position-hrp.Position).Magnitude<12 then
                hrp.CFrame=CFrame.new(oHRP.Position+Vector3.new(0,0,2))
                local tool=getChar() and getChar():FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end
            end
        end end
    end)
end) end

--// =========================================
--//   HELPERS DE CONTEÚDO
--// =========================================
local activeTab=nil; local currentCat="Dashboard"
local function clearContent() for _,c in ipairs(content:GetChildren()) do if not(c:IsA("UIListLayout") or c:IsA("UIPadding")) then c:Destroy() end end end
local function mkCard(h,col) return mkFrame(content,UDim2.new(1,-2,0,h),UDim2.new(0,1,0,0),col or Theme.bg2,12,10) end

local function mkSection(txt)
    local row=mkFrame(content,UDim2.new(1,-2,0,20),UDim2.new(0,1,0,0),Color3.fromRGB(0,0,0),12); row.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-8,1,0); lbl.Position=UDim2.new(0,4,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=txt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextColor3=Theme.accent; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13
    local line=mkFrame(row,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),Theme.accent,13); line.BackgroundTransparency=0.75
end

local function mkToggleRow(lTxt,dTxt,initState,onToggle)
    local row=mkCard(52)
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-90,0,20); lbl.Position=UDim2.new(0,12,0,7)
    lbl.BackgroundTransparency=1; lbl.Text=lTxt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13
    local desc=Instance.new("TextLabel",row); desc.Size=UDim2.new(1,-90,0,13); desc.Position=UDim2.new(0,12,0,30)
    desc.BackgroundTransparency=1; desc.Text=dTxt; desc.Font=Enum.Font.Gotham; desc.TextSize=10; desc.TextColor3=Theme.textDim; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=13
    local tBtn=mkBtn(row,UDim2.new(0,60,0,26),UDim2.new(1,-68,0.5,-13),initState and Theme.accent or Theme.bg3,initState and "ON" or "OFF",13,7)
    tBtn.TextSize=11; tBtn.TextColor3=initState and Theme.text or Theme.textDim
    if not initState then mkStroke(tBtn,Theme.accent,1) end
    local active=initState
    tBtn.MouseButton1Click:Connect(function()
        active=not active
        if active then tw(tBtn,0.2,{BackgroundColor3=Theme.accent}); tBtn.Text="ON"; tBtn.TextColor3=Theme.text
        else tw(tBtn,0.2,{BackgroundColor3=Theme.bg3}); tBtn.Text="OFF"; tBtn.TextColor3=Theme.textDim end
        onToggle(active)
    end)
    row.MouseEnter:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg3}) end)
    row.MouseLeave:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg2}) end)
end

local function mkActionRow(lTxt,dTxt,bTxt,onPress)
    local row=mkCard(52)
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-90,0,20); lbl.Position=UDim2.new(0,12,0,7)
    lbl.BackgroundTransparency=1; lbl.Text=lTxt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13
    local desc=Instance.new("TextLabel",row); desc.Size=UDim2.new(1,-90,0,13); desc.Position=UDim2.new(0,12,0,30)
    desc.BackgroundTransparency=1; desc.Text=dTxt; desc.Font=Enum.Font.Gotham; desc.TextSize=10; desc.TextColor3=Theme.textDim; desc.TextXAlignment=Enum.TextXAlignment.Left; desc.ZIndex=13
    local btn=mkBtn(row,UDim2.new(0,64,0,28),UDim2.new(1,-72,0.5,-14),Theme.accent,bTxt,13,8); btn.TextSize=11
    btn.MouseEnter:Connect(function() tw(btn,0.15,{BackgroundColor3=Theme.accentLit}) end)
    btn.MouseLeave:Connect(function() tw(btn,0.15,{BackgroundColor3=Theme.accent}) end)
    btn.MouseButton1Click:Connect(function() tw(btn,0.1,{BackgroundColor3=Theme.success}); task.wait(0.2); tw(btn,0.2,{BackgroundColor3=Theme.accent}); onPress() end)
    row.MouseEnter:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg3}) end)
    row.MouseLeave:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg2}) end)
end

--// =========================================
--//   ABA: DASHBOARD
--// =========================================
local function makeDashboard()
    -- Card de boas vindas
    local welcome=mkCard(72,Color3.fromRGB(16,6,30)); mkStroke(welcome,Theme.accent,1)
    local wIc=mkFrame(welcome,UDim2.new(0,44,0,44),UDim2.new(0,12,0.5,-22),Theme.accent,13,10); mkLabel(wIc,"◆",22,true,Color3.fromRGB(255,255,255),nil,14)
    local wT=Instance.new("TextLabel",welcome); wT.Size=UDim2.new(1,-80,0,22); wT.Position=UDim2.new(0,66,0,12)
    wT.BackgroundTransparency=1; wT.Text=T("Bem-vindo, ","Welcome, ")..plr.Name; wT.Font=Enum.Font.GothamBold; wT.TextSize=15; wT.TextColor3=Color3.fromRGB(255,255,255); wT.TextXAlignment=Enum.TextXAlignment.Left; wT.ZIndex=13
    local wS=Instance.new("TextLabel",welcome); wS.Size=UDim2.new(1,-80,0,14); wS.Position=UDim2.new(0,66,0,36)
    wS.BackgroundTransparency=1
    if session.premium then wS.Text=T("◆ Premium — Acesso Vitalício","◆ Premium — Lifetime Access"); wS.TextColor3=Color3.fromRGB(180,140,255)
    elseif session.expiresAt then
        local diff=session.expiresAt-os.time()
        local h2=math.floor(diff/3600); local m=math.floor((diff%3600)/60)
        wS.Text=string.format(T("⏱ Plano 12h — expira em %02dh%02dm","⏱ 12h Plan — expires in %02dh%02dm"),h2,m)
        wS.TextColor3=Theme.accentLit
    else wS.Text=T("Acesso liberado","Access granted"); wS.TextColor3=Theme.success end
    wS.Font=Enum.Font.Gotham; wS.TextSize=10; wS.TextXAlignment=Enum.TextXAlignment.Left; wS.ZIndex=13

    -- Info do jogo
    local gameCard=mkCard(52)
    local gI=mkFrame(gameCard,UDim2.new(0,36,0,36),UDim2.new(0,10,0.5,-18),Theme.bg3,13,8); mkLabel(gI,"🎮",16,false,Color3.fromRGB(255,255,255),nil,14)
    local gT=Instance.new("TextLabel",gameCard); gT.Size=UDim2.new(1,-70,0,20); gT.Position=UDim2.new(0,54,0,7)
    gT.BackgroundTransparency=1; gT.Text=gameName; gT.Font=Enum.Font.GothamBold; gT.TextSize=12; gT.TextColor3=Color3.fromRGB(255,255,255); gT.TextXAlignment=Enum.TextXAlignment.Left; gT.ZIndex=13
    local gS=Instance.new("TextLabel",gameCard); gS.Size=UDim2.new(1,-70,0,13); gS.Position=UDim2.new(0,54,0,28)
    gS.BackgroundTransparency=1; gS.Text=gameKey.." · PlaceId: "..tostring(PLACE_ID); gS.Font=Enum.Font.Gotham; gS.TextSize=9; gS.TextColor3=Theme.textDim; gS.TextXAlignment=Enum.TextXAlignment.Left; gS.ZIndex=13

    mkSection(T("  SCRIPTS RÁPIDOS","  QUICK SCRIPTS"))
    for _,sc in ipairs(MY_SCRIPTS) do
        mkActionRow(sc.name, sc.desc or "", T("▶ Executar","▶ Run"), function()
            local ok,err=pcall(function() loadstring(game:HttpGet(sc.url))() end)
            if ok then notify("⚡ "..sc.name.." "..T("executado!","executed!"))
            else notify(T("✗ Erro: ","✗ Error: ")..tostring(err):sub(1,50)) end
        end)
    end
end

--// =========================================
--//   ABA: SCRIPTS
--// =========================================
local function makeScripts()
    mkSection(T("  MEUS SCRIPTS","  MY SCRIPTS","  МОИ СКРИПТЫ","  MIS SCRIPTS","  SCRIPTS CUA TOI","  สคริปต์ของฉัน"))
    for _,sc in ipairs(MY_SCRIPTS) do
        mkActionRow(sc.name, sc.desc or "", T("▶ Run","▶ Run"), function()
            local ok,err=pcall(function() loadstring(game:HttpGet(sc.url))() end)
            if ok then notify("⚡ "..sc.name) else notify(T("✗ Erro: ","✗ Error: ")..tostring(err):sub(1,50)) end
        end)
    end
end

--// =========================================
--//   ABA: CYRUS (hacks)
--// =========================================
local function makeCyrus()
    mkSection(T("  ESP & VISÃO","  ESP & VISION"))
    mkToggleRow("ESP","Show players through walls",false,function(on)
        state.esp=on; if on then enableESP() else disableESP() end
        notify((on and "✓ " or "✗ ").."ESP "..(on and T("ativado","activated") or T("desativado","deactivated")))
    end)
    mkSection(T("  PLAYER","  PLAYER"))
    mkToggleRow(T("Fly","Fly"),"W/A/S/D + Space/Ctrl",false,function(on) state.fly=on; if on then startFly() else stopFly() end end)
    mkToggleRow(T("NoClip","NoClip"),"Atravessa paredes",false,function(on) state.noclip=on; if on then startNoclip() else killConn("noclip") end end)
    mkToggleRow(T("God Mode","God Mode"),"HP sempre no máximo",false,function(on) state.godMode=on; if on then startGodMode() else killConn("godMode") end end)
    mkToggleRow(T("Anti AFK","Anti AFK"),"Evita ser expulso",false,function(on) state.antiAfk=on; if on then startAntiAfk() else killConn("antiAfk") end end)
    mkToggleRow(T("Inf. Stamina","Inf. Stamina"),"Energia/stamina infinita",false,function(on) state.infStamina=on; if on then
        killConn("infStamina"); connections["infStamina"]=RS.Heartbeat:Connect(function() pcall(function() local char=getChar(); if not char then return end
            for _,v in ipairs(char:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then
                local n=v.Name:lower(); if n:find("stamina") or n:find("energy") or n:find("mana") then v.Value=math.max(v.Value,9999) end
            end end end) end)
    else killConn("infStamina") end end)
    mkSection(T("  COMBATE","  COMBAT"))
    mkToggleRow(T("Hitbox","Hitbox"),"Hitbox aumentada",false,function(on) state.hitbox=on; if on then startHitbox() else stopHitbox() end end)
    mkToggleRow(T("Kill Aura","Kill Aura"),"Ataca inimigos próximos",false,function(on) state.killAura=on; if on then startKillAura() else killConn("killAura") end end)
    mkSection(T("  AUTO FARM","  AUTO FARM"))
    mkToggleRow(T("Auto Farm","Auto Farm"),"Farm automático de NPCs",false,function(on) state.autoFarm=on; if on then startAutoFarm() else killConn("autoFarm") end end)
    mkSection(T("  VELOCIDADE","  SPEED"))
    -- Speed slider
    local speedCard=mkCard(68)
    local sLbl=Instance.new("TextLabel",speedCard); sLbl.Size=UDim2.new(1,-80,0,18); sLbl.Position=UDim2.new(0,12,0,6)
    sLbl.BackgroundTransparency=1; sLbl.Text=T("Velocidade","Speed"); sLbl.Font=Enum.Font.GothamBold; sLbl.TextSize=13; sLbl.TextColor3=Color3.fromRGB(255,255,255); sLbl.TextXAlignment=Enum.TextXAlignment.Left; sLbl.ZIndex=13
    local sVal=Instance.new("TextLabel",speedCard); sVal.Size=UDim2.new(0,40,0,14); sVal.Position=UDim2.new(0,12,0,26)
    sVal.BackgroundTransparency=1; sVal.Text=tostring(state.speedVal); sVal.Font=Enum.Font.GothamBold; sVal.TextSize=11; sVal.TextColor3=Theme.accent; sVal.TextXAlignment=Enum.TextXAlignment.Left; sVal.ZIndex=13
    local sBar=Instance.new("Frame",speedCard); sBar.Size=UDim2.new(1,-24,0,6); sBar.Position=UDim2.new(0,12,0,46)
    sBar.BackgroundColor3=Theme.bg3; sBar.BorderSizePixel=0; sBar.ZIndex=13; corner(sBar,3)
    local sFill=mkFrame(sBar,UDim2.new((state.speedVal-16)/(200-16),0,1,0),UDim2.new(0,0,0,0),Theme.accent,14,3)
    local sThumb=mkFrame(sBar,UDim2.new(0,14,0,14),UDim2.new((state.speedVal-16)/(200-16),-7,0.5,-7),Theme.accentLit,15,7)
    local sDrag=false
    sThumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sDrag=true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sDrag=false end end)
    UIS.InputChanged:Connect(function(i)
        if sDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local rel=(i.Position.X-sBar.AbsolutePosition.X)/sBar.AbsoluteSize.X
            rel=math.clamp(rel,0,1); local val=math.floor(16+rel*(200-16))
            state.speedVal=val; sVal.Text=tostring(val); sFill.Size=UDim2.new(rel,0,1,0); sThumb.Position=UDim2.new(rel,-7,0.5,-7)
            if state.speedHack then setSpeed(val) end
        end
    end)
    local sToggle=mkBtn(speedCard,UDim2.new(0,56,0,22),UDim2.new(1,-64,0,6),Theme.bg3,"OFF",13,6); sToggle.TextSize=10; mkStroke(sToggle,Theme.accent,1)
    sToggle.MouseButton1Click:Connect(function()
        state.speedHack=not state.speedHack
        if state.speedHack then setSpeed(state.speedVal); tw(sToggle,0.2,{BackgroundColor3=Theme.accent}); sToggle.Text="ON"; sToggle.TextColor3=Theme.text
        else setSpeed(16); tw(sToggle,0.2,{BackgroundColor3=Theme.bg3}); sToggle.Text="OFF"; sToggle.TextColor3=Theme.textDim end
    end)
    mkSection(T("  TELEPORTE","  TELEPORT"))
    mkActionRow(T("Ir para Spawn","Go to Spawn"),"TeleportToPlaceInstance",T("Ir","Go"),function()
        pcall(function() local hrp=getHRP(); if hrp then hrp.CFrame=CFrame.new(0,10,0) end end)
        notify(T("Teleportado!","Teleported!"))
    end)
end

--// =========================================
--//   ABA: CONFIG
--// =========================================
local function makeConfig()
    mkSection(T("  TEMA DE CORES","  COLOR THEME"))
    for _,t in ipairs(THEMES) do
        local row=mkCard(42)
        local dot=mkFrame(row,UDim2.new(0,24,0,24),UDim2.new(0,12,0.5,-12),t.accent,13,12)
        local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-120,0,22); lbl.Position=UDim2.new(0,46,0.5,-11)
        lbl.BackgroundTransparency=1; lbl.Text=t.name; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=13
        local applyBtn=mkBtn(row,UDim2.new(0,72,0,26),UDim2.new(1,-80,0.5,-13),Theme.bg3,T("● Aplicar","● Apply"),13,7)
        applyBtn.TextColor3=t.accent; applyBtn.TextSize=10; mkStroke(applyBtn,t.accent,1)
        applyBtn.MouseButton1Click:Connect(function()
            Theme.accent=t.accent; Theme.accentLit=t.accentLit; Theme.accentGlow=t.accentLit
            mkStroke(hub,Theme.accent,1.5); sep.BackgroundColor3=Theme.accent
            notify(string.format(T("✓ Tema '%s' aplicado!","✓ Theme '%s' applied!"),t.name))
            task.wait(0.2); loadTab("Config")
        end)
        row.MouseEnter:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg3}) end)
        row.MouseLeave:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg2}) end)
    end

    mkSection(T("  IDIOMA","  LANGUAGE"))
    local langCard=mkCard(44)
    local langDesc=Instance.new("TextLabel",langCard); langDesc.Size=UDim2.new(1,-130,0,18); langDesc.Position=UDim2.new(0,10,0,6)
    langDesc.BackgroundTransparency=1; langDesc.Text=_isBR and "Idioma atual: Português 🇧🇷" or "Current language: English 🇺🇸"
    langDesc.Font=Enum.Font.GothamBold; langDesc.TextSize=11; langDesc.TextColor3=Color3.fromRGB(255,255,255); langDesc.TextXAlignment=Enum.TextXAlignment.Left; langDesc.ZIndex=13
    local ptBtn=mkBtn(langCard,UDim2.new(0,48,0,26),UDim2.new(1,-106,0.5,-13),_isBR and Theme.accent or Theme.bg3,"🇧🇷 PT",13,7); ptBtn.TextSize=10
    local enBtn=mkBtn(langCard,UDim2.new(0,48,0,26),UDim2.new(1,-54,0.5,-13),(not _isBR) and Theme.accent or Theme.bg3,"🇺🇸 EN",13,7); enBtn.TextSize=10
    if _isBR then mkStroke(enBtn,Theme.accent,1) else mkStroke(ptBtn,Theme.accent,1) end
    ptBtn.MouseButton1Click:Connect(function()
        _isBR=true; tw(ptBtn,0.2,{BackgroundColor3=Theme.accent}); tw(enBtn,0.2,{BackgroundColor3=Theme.bg3})
        langDesc.Text="Idioma atual: Português 🇧🇷"; notify("🇧🇷 Idioma alterado para Português!"); task.wait(0.3); loadTab("Config")
    end)
    enBtn.MouseButton1Click:Connect(function()
        _isBR=false; tw(enBtn,0.2,{BackgroundColor3=Theme.accent}); tw(ptBtn,0.2,{BackgroundColor3=Theme.bg3})
        langDesc.Text="Current language: English 🇺🇸"; notify("🇺🇸 Language changed to English!"); task.wait(0.3); loadTab("Config")
    end)

    mkSection(T("  KEYBIND","  KEYBIND"))
    local kbCard=mkCard(44); local currentKB=Enum.KeyCode.RightControl; local listeningKB=false
    local kbLbl=Instance.new("TextLabel",kbCard); kbLbl.Size=UDim2.new(1,-16,0,20); kbLbl.Position=UDim2.new(0,10,0,5)
    kbLbl.BackgroundTransparency=1; kbLbl.Text=T("Abrir/fechar: RightControl (clique para trocar)","Open/close: RightControl (click to change)")
    kbLbl.Font=Enum.Font.Gotham; kbLbl.TextSize=10; kbLbl.TextColor3=Color3.fromRGB(255,255,255); kbLbl.TextXAlignment=Enum.TextXAlignment.Left; kbLbl.ZIndex=13
    local kbClickBtn=Instance.new("TextButton",kbCard); kbClickBtn.Size=UDim2.new(1,0,1,0); kbClickBtn.BackgroundTransparency=1; kbClickBtn.Text=""; kbClickBtn.ZIndex=14
    kbClickBtn.MouseButton1Click:Connect(function() listeningKB=true; kbLbl.Text=T("Pressione qualquer tecla...","Press any key..."); kbLbl.TextColor3=Theme.accent end)
    UIS.InputBegan:Connect(function(inp,gp)
        if listeningKB and not gp and inp.UserInputType==Enum.UserInputType.Keyboard then
            listeningKB=false; currentKB=inp.KeyCode; kbLbl.Text=(T("Abrir/fechar: ","Open/close: "))..inp.KeyCode.Name; kbLbl.TextColor3=Color3.fromRGB(255,255,255)
        end
        if inp.KeyCode==currentKB then
            if hub.Visible then tw(hub,0.2,{BackgroundTransparency=1}); task.wait(0.22); hub.Visible=false; hubGlow.Visible=false; fab.Visible=true
            else fab.Visible=false; hub.Visible=true; hubGlow.Visible=true; hub.BackgroundTransparency=1; tw(hub,0.3,{BackgroundTransparency=0}); tw(hubGlow,0.3,{BackgroundTransparency=0.82}) end
        end
    end)
end

--// =========================================
--//   ABA: PREMIUM
--// =========================================
local function makePremium()
    local banner=mkCard(72,Color3.fromRGB(20,0,40)); mkStroke(banner,Theme.accent,1)
    local bIc=mkFrame(banner,UDim2.new(0,44,0,44),UDim2.new(0,12,0.5,-22),Theme.accent,13,10); mkLabel(bIc,"◆",22,true,Color3.fromRGB(255,255,255),nil,14)
    local bT=Instance.new("TextLabel",banner); bT.Size=UDim2.new(1,-70,0,22); bT.Position=UDim2.new(0,64,0,12)
    bT.BackgroundTransparency=1; bT.Text=T("ACESSO PREMIUM","PREMIUM ACCESS"); bT.Font=Enum.Font.GothamBold; bT.TextSize=15; bT.TextColor3=Color3.fromRGB(255,215,60); bT.TextXAlignment=Enum.TextXAlignment.Left; bT.ZIndex=13
    local bS=Instance.new("TextLabel",banner); bS.Size=UDim2.new(1,-70,0,14); bS.Position=UDim2.new(0,64,0,36)
    bS.BackgroundTransparency=1; bS.Text=T("Acesso vitalício — nunca expira","Lifetime access — never expires"); bS.Font=Enum.Font.Gotham; bS.TextSize=10; bS.TextColor3=Theme.textDim; bS.TextXAlignment=Enum.TextXAlignment.Left; bS.ZIndex=13

    mkSection(T("  BENEFÍCIOS","  BENEFITS"))
    local benefCard=mkCard(100)
    local bens={
        T("✅ Acesso PERMANENTE e ILIMITADO","✅ PERMANENT and UNLIMITED access"),
        T("✅ Sem encurtadores ou links","✅ No shorteners or links"),
        T("✅ Senha que nunca expira","✅ Password that never expires"),
        T("✅ Suporte VIP no Discord","✅ VIP Discord support"),
        T("✅ Acesso antecipado a novos scripts","✅ Early access to new scripts"),
    }
    for i,b in ipairs(bens) do
        local l=Instance.new("TextLabel",benefCard); l.Size=UDim2.new(1,-16,0,16); l.Position=UDim2.new(0,10,0,4+(i-1)*18)
        l.BackgroundTransparency=1; l.Text=b; l.Font=Enum.Font.Gotham; l.TextSize=11; l.TextColor3=Color3.fromRGB(220,220,220); l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=13
    end

    mkSection(T("  COMPRAR","  BUY"))
    mkActionRow(T("Discord (BR)","Discord (BR)"),T("Entre no servidor","Join the server"),T("Copiar Link","Copy Link"),function()
        pcall(function() setclipboard(INTERNAL_CONFIG.DiscordBR) end)
        notify(T("Link copiado! Entre e vá ao canal de compras.","Link copied! Join and go to the purchases channel."))
    end)
    if not _isBR then
        mkActionRow("Discord (INT)","Join the server","Copy Link",function()
            pcall(function() setclipboard(INTERNAL_CONFIG.DiscordEN) end)
            notify("Link copied! Join the server to buy Premium.")
        end)
    end
end

--// =========================================
--//   ABA: CONTATO
--// =========================================
local function makeContato()
    local banner=mkCard(64,Color3.fromRGB(20,0,40)); mkStroke(banner,Theme.accent,1)
    local bIc=mkFrame(banner,UDim2.new(0,40,0,40),UDim2.new(0,12,0.5,-20),Theme.accent,13,10); mkLabel(bIc,"◆",20,true,Color3.fromRGB(255,255,255),nil,14)
    local bT=Instance.new("TextLabel",banner); bT.Size=UDim2.new(1,-70,0,22); bT.Position=UDim2.new(0,62,0,10)
    bT.BackgroundTransparency=1; bT.Text="CYRUS HUB"; bT.Font=Enum.Font.GothamBold; bT.TextSize=16; bT.TextColor3=Color3.fromRGB(255,255,255); bT.TextXAlignment=Enum.TextXAlignment.Left; bT.ZIndex=13
    local bS=Instance.new("TextLabel",banner); bS.Size=UDim2.new(1,-70,0,14); bS.Position=UDim2.new(0,62,0,34)
    bS.BackgroundTransparency=1; bS.Text="Script Hub · "..HUB_VER.." · kalel-scripts"; bS.Font=Enum.Font.Gotham; bS.TextSize=10; bS.TextColor3=Theme.textDim; bS.TextXAlignment=Enum.TextXAlignment.Left; bS.ZIndex=13
    mkSection(T("  REDES SOCIAIS","  SOCIAL MEDIA"))
    local socials={
        {label="YouTube",   sub="@kalel-scripts", url="https://youtube.com/@kalel-scripts",      ic="▶",bg=Color3.fromRGB(200,0,0),   tc=Color3.fromRGB(255,100,100)},
        {label="Instagram", sub="@kalel_scripts", url="https://www.instagram.com/kalel_scripts", ic="◉",bg=Color3.fromRGB(180,0,120), tc=Color3.fromRGB(255,80,200)},
        {label="Discord",   sub="Cyrus Hub",       url=INTERNAL_CONFIG.DiscordBR,                 ic="◈",bg=Color3.fromRGB(88,101,242),tc=Color3.fromRGB(140,150,255)},
    }
    for _,s in ipairs(socials) do
        local row=mkCard(56)
        local ic=mkFrame(row,UDim2.new(0,40,0,40),UDim2.new(0,10,0.5,-20),s.bg,13,8); mkLabel(ic,s.ic,18,true,Color3.fromRGB(255,255,255),nil,14)
        local tT=Instance.new("TextLabel",row); tT.Size=UDim2.new(1,-130,0,20); tT.Position=UDim2.new(0,60,0,8)
        tT.BackgroundTransparency=1; tT.Text=s.label; tT.Font=Enum.Font.GothamBold; tT.TextSize=14; tT.TextColor3=Color3.fromRGB(255,255,255); tT.TextXAlignment=Enum.TextXAlignment.Left; tT.ZIndex=13
        local tS=Instance.new("TextLabel",row); tS.Size=UDim2.new(1,-130,0,13); tS.Position=UDim2.new(0,60,0,30)
        tS.BackgroundTransparency=1; tS.Text=s.sub; tS.Font=Enum.Font.Gotham; tS.TextSize=11; tS.TextColor3=s.tc; tS.TextXAlignment=Enum.TextXAlignment.Left; tS.ZIndex=13
        local btn=mkBtn(row,UDim2.new(0,76,0,30),UDim2.new(1,-84,0.5,-15),s.bg,T("Abrir ↗","Open ↗"),13,8); btn.TextSize=11
        btn.MouseButton1Click:Connect(function() pcall(function() setclipboard(s.url) end); notify(s.label.." "..T("copiado!","copied!")) end)
        row.MouseEnter:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg3}) end)
        row.MouseLeave:Connect(function() tw(row,0.15,{BackgroundColor3=Theme.bg2}) end)
    end
end

--// =========================================
--//   SISTEMA DE TABS
--// =========================================
local TABS={
    {id="Dashboard", icon="", label=T("Inicio","Home","Главная","Inicio","Trang chu","หน้าหลัก")},
    {id="Scripts",   icon="", label="Scripts"},
    {id="Cyrus",     icon="", label="Cyrus"},
    {id="Premium",   icon="", label="Premium"},
    {id="Config",    icon="", label=T("Config","Config","Настройки","Config","Cai dat","ตั้งค่า")},
    {id="Contato",   icon="", label=T("Contato","Contact","Контакты","Contacto","Lien he","ติดต่อ")},
}

local function loadTab(cat)
    clearContent(); currentCat=cat
    if cat=="Dashboard" then makeDashboard()
    elseif cat=="Scripts" then makeScripts()
    elseif cat=="Cyrus"   then makeCyrus()
    elseif cat=="Premium" then makePremium()
    elseif cat=="Config"  then makeConfig()
    elseif cat=="Contato" then makeContato() end
    task.wait(); content.CanvasSize=UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+10)
end

local function makeTab(info)
    local t=mkBtn(tabBar,UDim2.new(0,68,1,0),UDim2.new(0,0,0,0),Theme.bg3,info.icon.."  "..info.label,12,8)
    t.Font=Enum.Font.GothamMedium; t.TextSize=9; t.TextColor3=Theme.textDim; t.AutoButtonColor=false
    t.MouseButton1Click:Connect(function()
        if activeTab and activeTab~=t then tw(activeTab,0.15,{BackgroundColor3=Theme.bg3}); activeTab.TextColor3=Theme.textDim end
        activeTab=t; tw(t,0.15,{BackgroundColor3=Theme.accent}); t.TextColor3=Theme.text; loadTab(info.id)
    end)
    if info.id=="Dashboard" then t.BackgroundColor3=Theme.accent; t.TextColor3=Theme.text; activeTab=t end
end
for _,t in ipairs(TABS) do makeTab(t) end

closeBtn.MouseButton1Click:Connect(function()
    tw(hub,0.2,{BackgroundTransparency=1}); task.wait(0.22); hub.Visible=false; hubGlow.Visible=false; fab.Visible=true
end)
fab.MouseButton1Click:Connect(function()
    fab.Visible=false; hub.Visible=true; hubGlow.Visible=true
    hub.BackgroundTransparency=1; tw(hub,0.3,{BackgroundTransparency=0}); tw(hubGlow,0.3,{BackgroundTransparency=0.82})
end)

--// =========================================
--//   VALIDAÇÃO DE CHAVE
--// =========================================
local function checkKey()
    if not kInput then return end
    local v=kInput.Text:upper():gsub("%s","")
    if v=="" then kStatus.TextColor3=Theme.danger; kStatus.Text=T("⚠ Digite ou cole a chave!","⚠ Enter or paste the key!"); return end
    kBtn.Text=T("Validando...","Validating..."); kBtn.BackgroundColor3=Theme.bg3; kBtn.TextColor3=Theme.textDim

    -- Verifica premium
    if isPremiumKey(v) then
        dm:save("PremiumKey.json",{key=v})
        session.premium=true; session.type="premium"
        kStatus.TextColor3=Theme.gold; kStatus.Text=T("⭐ Premium ativado!","⭐ Premium activated!")
        kBtn.BackgroundColor3=Theme.gold; kBtn.Text=T("Liberado ✓","Unlocked ✓"); kBtn.TextColor3=Color3.fromRGB(0,0,0)
        task.wait(0.8)
        tw(keyLayer,0.3,{BackgroundTransparency=1}); task.wait(0.35); keyLayer.Visible=false
        liberarAcesso(); task.spawn(playCollision)
        return
    end

    -- Verifica chave normal
    local savedLinkData=dm:load("Link.json")
    if not savedLinkData or not isLinkValid() then
        kBtn.Text=T("Entrar","Enter"); kBtn.BackgroundColor3=Theme.accent; kBtn.TextColor3=Theme.text
        kStatus.TextColor3=Theme.danger; kStatus.Text=T("Gere um novo link primeiro","Generate a new link first"); return
    end
    if validateKey(v, savedLinkData.link) then
        dm:save("Key.json",{key=v, time=tick()})
        session.key=v; session.type="12h"; session.expiresAt=os.time()+43200
        kStatus.TextColor3=Theme.success; kStatus.Text=T("✅ Chave válida!","✅ Valid key!")
        kBtn.BackgroundColor3=Theme.success; kBtn.Text=T("Liberado ✓","Unlocked ✓")
        task.wait(0.5)
        tw(keyLayer,0.3,{BackgroundTransparency=1}); task.wait(0.35); keyLayer.Visible=false
        liberarAcesso(); task.spawn(playCollision)
    else
        kBtn.Text=T("Entrar","Enter"); kBtn.BackgroundColor3=Theme.accent; kBtn.TextColor3=Theme.text
        kStatus.TextColor3=Theme.danger; kStatus.Text=T("❌ Chave inválida!","❌ Invalid key!")
        -- shake animation
        if keyLayer then
            local kf=keyLayer:FindFirstChildOfClass("Frame")
            if kf then
                local p=kf.Position
                for _=1,4 do tw(kf,0.04,{Position=UDim2.new(p.X.Scale,p.X.Offset+8,p.Y.Scale,p.Y.Offset)}); task.wait(0.05)
                    tw(kf,0.04,{Position=UDim2.new(p.X.Scale,p.X.Offset-8,p.Y.Scale,p.Y.Offset)}); task.wait(0.05) end
                tw(kf,0.04,{Position=p})
            end
        end
    end
end

if kBtn then
    kBtn.MouseButton1Click:Connect(checkKey)
    if kInput then kInput.FocusLost:Connect(function(e) if e then checkKey() end end) end
end

--// =========================================
--//   HOLLOW PURPLE ANIMATION — ÉPICA v2
--// =========================================
local function playCollision()
    animLayer.Visible=true; animBg.BackgroundTransparency=0; animBg.BackgroundColor3=Color3.fromRGB(0,0,0)

    -- Posiciona orbs nas extremidades
    blueOrb.Position=UDim2.new(0,-90,0.5,-35); blueOrb.Visible=true; blueOrb.BackgroundTransparency=0
    blueHalo.Position=UDim2.new(0,-160,0.5,-70); blueHalo.Visible=true; blueHalo.BackgroundTransparency=0.6
    redOrb.Position=UDim2.new(1,20,0.5,-35); redOrb.Visible=true; redOrb.BackgroundTransparency=0
    redHalo.Position=UDim2.new(1,20,0.5,-70); redHalo.Visible=true; redHalo.BackgroundTransparency=0.6
    blueTrail.Visible=false; redTrail.Visible=false
    centerTxt.TextTransparency=1; versionTxt.TextTransparency=1

    task.wait(0.3)

    -- Orbs convergem ao centro com trilhas
    blueTrail.Size=UDim2.new(0,0,0,6); blueTrail.Visible=true; blueTrail.BackgroundTransparency=0.2
    redTrail.Size=UDim2.new(0,0,0,6); redTrail.Position=UDim2.new(1,0,0.5,-3); redTrail.Visible=true; redTrail.BackgroundTransparency=0.2

    -- Convergência
    tw(blueOrb,0.9,{Position=UDim2.new(0.5,-80,0.5,-35)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    tw(blueHalo,0.9,{Position=UDim2.new(0.5,-110,0.5,-70)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    tw(redOrb,0.9,{Position=UDim2.new(0.5,10,0.5,-35)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    tw(redHalo,0.9,{Position=UDim2.new(0.5,10,0.5,-70)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    tw(blueTrail,0.9,{Size=UDim2.new(0.5,-35,0,6)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    tw(redTrail,0.9,{Size=UDim2.new(0.5,-35,0,6),Position=UDim2.new(0.5,35,0.5,-3)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)

    -- Fundo pulsa durante a aproximação
    task.delay(0.4,function()
        tw(animBg,0.15,{BackgroundColor3=Color3.fromRGB(5,0,15)})
        task.wait(0.15); tw(animBg,0.3,{BackgroundColor3=Color3.fromRGB(0,0,0)})
    end)
    task.wait(0.9)

    -- COLISÃO — flash branco intenso
    tw(flashF,0.05,{BackgroundTransparency=0}); task.wait(0.05); tw(flashF,0.4,{BackgroundTransparency=1})

    -- Esconde orbs e trilhas
    blueOrb.Visible=false; blueHalo.Visible=false; redOrb.Visible=false; redHalo.Visible=false; blueTrail.Visible=false; redTrail.Visible=false

    -- 3 ondas de choque concêntricas
    for i,shock in ipairs(shocks) do
        shock.Size=UDim2.new(0,10,0,10); shock.Position=UDim2.new(0.5,-5,0.5,-5); shock.BackgroundTransparency=0; shock.Visible=true
        task.delay((i-1)*0.1,function()
            tw(shock,0.7,{Size=UDim2.new(0,800,0,800),Position=UDim2.new(0.5,-400,0.5,-400),BackgroundTransparency=1},Enum.EasingStyle.Quad)
        end)
    end

    -- Partículas de explosão em todas as direções
    for i,p in ipairs(expParts) do
        p.BackgroundTransparency=0; p.Position=UDim2.new(0.5,-3,0.5,-3); p.Visible=true
        local tx=math.random(5,95)/100; local ty=math.random(5,95)/100; local d=math.random(0,15)/100
        task.delay(d,function() tw(p,0.8,{Position=UDim2.new(tx,0,ty,0),BackgroundTransparency=1},Enum.EasingStyle.Quad) end)
    end

    -- Raios de energia irradiando
    for i,ray in ipairs(rays) do
        local angle=(i-1)*(math.pi*2/8)
        ray.Visible=true; ray.BackgroundTransparency=0.3
        ray.Size=UDim2.new(0,3,0,0)
        ray.Position=UDim2.new(0.5,-1,0.5,0)
        -- rota baseada no ângulo
        ray.Rotation=(angle*180/math.pi)
        task.delay(0,function()
            tw(ray,0.6,{Size=UDim2.new(0,3,0,math.random(80,180)),BackgroundTransparency=1},Enum.EasingStyle.Quad)
        end)
    end

    -- Orb roxo central cresce (Hollow Purple)
    purpleOrb.Size=UDim2.new(0,0,0,0); purpleOrb.Position=UDim2.new(0.5,0,0.5,0); purpleOrb.BackgroundTransparency=0; purpleOrb.Visible=true
    purpleGlow.Size=UDim2.new(0,0,0,0); purpleGlow.Position=UDim2.new(0.5,0,0.5,0); purpleGlow.BackgroundTransparency=0.3; purpleGlow.Visible=true
    tw(purpleOrb,0.7,{Size=UDim2.new(2.5,0,2.5,0),Position=UDim2.new(-0.75,0,-0.75,0)},Enum.EasingStyle.Quart)
    tw(purpleGlow,0.7,{Size=UDim2.new(3.2,0,3.2,0),Position=UDim2.new(-1.1,0,-1.1,0),BackgroundTransparency=0.5},Enum.EasingStyle.Quart)

    -- Fundo vira roxo intenso por um instante
    tw(animBg,0.15,{BackgroundColor3=Color3.fromRGB(40,0,80)})

    -- Textos aparecem
    task.wait(0.35); tw(centerTxt,0.4,{TextTransparency=0}); task.wait(0.25); tw(versionTxt,0.35,{TextTransparency=0})
    task.wait(0.8)

    -- Fade out
    tw(centerTxt,0.3,{TextTransparency=1}); tw(versionTxt,0.3,{TextTransparency=1}); task.wait(0.1)
    tw(purpleOrb,0.5,{BackgroundTransparency=1}); tw(purpleGlow,0.5,{BackgroundTransparency=1})
    tw(animBg,0.5,{BackgroundTransparency=1}); task.wait(0.55)

    -- Esconde estrelas
    starFolder.Visible=false

    -- Loading bar
    loadLayer.Visible=true; tw(loadLayer,0.3,{BackgroundTransparency=0})
    local steps={
        {txt=T("Verificando sessão...","Verifying session..."),   pct=0.18},
        {txt=T("Carregando ESP...","Loading ESP..."),              pct=0.36},
        {txt=T("Carregando scripts...","Loading scripts..."),     pct=0.54},
        {txt=T("Configurando UI...","Configuring UI..."),         pct=0.72},
        {txt=T("Aplicando tema...","Applying theme..."),          pct=0.90},
        {txt=T("Pronto!","Ready!"),                                pct=1.00},
    }
    for _,st in ipairs(steps) do
        loadTxt.Text=st.txt; loadPct.Text=math.floor(st.pct*100).."%"
        tw(barFill,0.28,{Size=UDim2.new(st.pct,0,1,0)}); task.wait(0.32)
    end
    task.wait(0.2)
    tw(loadLayer,0.4,{BackgroundTransparency=1})
    for _,c in ipairs(loadBg:GetDescendants()) do
        if c:IsA("TextLabel") then tw(c,0.3,{TextTransparency=1}) end
    end
    tw(loadBg,0.35,{BackgroundTransparency=1}); task.wait(0.45)
    animLayer.Visible=false

    -- Mostra hub
    hub.Visible=true; hubGlow.Visible=true; hub.BackgroundTransparency=1
    tw(hub,0.4,{BackgroundTransparency=0}); tw(hubGlow,0.4,{BackgroundTransparency=0.82})
    wm.Text="◆ CYRUS HUB  ·  "..plr.Name.."  ·  "..HUB_VER; wm.Visible=true
    startCountdown(); loadTab("Dashboard"); task.wait(0.5); fab.Visible=true
    notify(T("✓ CYRUS HUB "..HUB_VER.."  ·  Bem-vindo, ","✓ CYRUS HUB "..HUB_VER.."  ·  Welcome, ")..plr.Name.."!")
end

--// =========================================
--//   ENTRADA — decide fluxo
--// =========================================
if _acessoJaLiberado then
    -- Já autenticado: pula direto pra animação e hub
    task.spawn(playCollision)
else
    -- Precisa de chave: mostra tela de chave primeiro
    task.wait(0.5)
    if keyLayer then keyLayer.Visible=true end
    animLayer.Visible=false
end

print("[CyrusHub "..HUB_VER.."] OK — "..gameKey.." | PlaceId: "..PLACE_ID)
