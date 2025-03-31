-- Auto Farm Module

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configurações Gerais
local Config = {
    SafeHeight = 10,          -- Altura para teleporte (para evitar obstáculos)
    PullDistance = 30,        -- Distância para puxar NPCs
    AttackAltitudeOffset = 5, -- Offset vertical para puxar os NPCs (abaixo do jogador)
}

-- Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local questAccepted = false

--------------------------------------------------
-- FUNÇÃO: Aceitar missão automaticamente
--------------------------------------------------
local function AutoQuest()
    if questAccepted then return end

    local currentLevel = LocalPlayer.Data.Level.Value
    local MissionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCPOFICIAL/op_hub/refs/heads/main/world1_missions.lua"))()
    local currentMission = MissionsModule.getMissionByLevel(currentLevel)
    
    if currentMission and currentMission.CFrameQuest then
        local questPos = currentMission.CFrameQuest.Position
        moverParaPosicao(CFrame.new(questPos) * CFrame.new(0, Config.SafeHeight, 0), 0)
        task.wait(1)
        
        local questRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if questRemote then
            questRemote:InvokeServer("StartQuest", currentMission.NameQuest, currentMission.LevelQuest)
            questAccepted = true
        end
    end
end

--------------------------------------------------
-- FUNÇÃO: Mover o jogador para uma posição
--------------------------------------------------
local function moverParaPosicao(targetCFrame, altitude)
    local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local targetPos = targetCFrame.Position
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(15000, 200000, 15000)
    bodyPos.P = 3000
    bodyPos.D = 1000
    bodyPos.Parent = HRP
    
    bodyPos.Position = Vector3.new(targetPos.X, targetPos.Y + altitude, targetPos.Z)
    task.wait(1)
    bodyPos:Destroy()
end

--------------------------------------------------
-- FUNÇÃO: Encontrar NPCs da missão
--------------------------------------------------
local function FindNPCs()
    local npcs = {}
    local currentLevel = LocalPlayer.Data.Level.Value
    local MissionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCPOFICIAL/op_hub/refs/heads/main/world1_missions.lua"))()
    local currentMission = MissionsModule.getMissionByLevel(currentLevel)
    
    if currentMission then
        local targetName = currentMission.NameMon
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Name:find(targetName) then
                table.insert(npcs, enemy)
            end
        end
    end
    return npcs
end

--------------------------------------------------
-- FUNÇÃO: Puxar NPCs para debaixo do jogador
--------------------------------------------------
local function PullNPCs(npcs)
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            local attraction = Instance.new("BodyPosition")
            attraction.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            attraction.Position = HumanoidRootPart.Position - Vector3.new(0, Config.AttackAltitudeOffset, 0)
            attraction.Parent = hrp
            task.delay(0.5, function()
                if attraction.Parent then attraction:Destroy() end
            end)
        end
    end
end

--------------------------------------------------
-- LOOP PRINCIPAL DE FARMING
--------------------------------------------------
local function StartFarm()
    while task.wait(0.1) do
        if questAccepted then
            local npcs = FindNPCs()
            if #npcs > 0 then
                local centerPos = npcs[1].HumanoidRootPart.Position
                moverParaPosicao(CFrame.new(centerPos) * CFrame.new(0, Config.SafeHeight, 0), 0)
                PullNPCs(npcs)
            end
        else
            AutoQuest()
        end
    end
end

return {
    StartFarm = StartFarm,
    AutoQuest = AutoQuest,
    FindNPCs = FindNPCs,
    PullNPCs = PullNPCs,
    moverParaPosicao = moverParaPosicao
}
