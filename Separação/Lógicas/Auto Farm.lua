-- Auto Farm Logic Module (Lógicas de Missões e Movimento)
-- Adaptado para Blox Fruits (Atualizado 2025)
-- Criado para ser utilizado em conjunto com um script de interface

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local AutoFarmLogic = {}

-- Configuração
local Config = {
    AutoFarm = false,
    AutoQuest = false,
    SafeHeight = 20,       -- Altura para teleporte (acima dos NPCs)
    PullDistance = 30,     -- Distância para puxar NPCs
    AlturaSubida = 50      -- Altura utilizada na lógica de movimento
}

-- Flag para garantir que a missão seja coletada apenas uma vez
local questAccepted = false

-- Carregar informações das missões (dados e funções) do módulo remoto do GitHub
local MissionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCPOFICIAL/op_hub/refs/heads/main/world1_missions.lua"))()
local Missions = MissionsModule.missions       -- Tabela com todas as missões (se necessário)
local GetMissionByLevel = MissionsModule.getMissionByLevel -- Função para obter a missão conforme o nível do jogador

--------------------------------------------------
-- Função de movimento usando BodyPosition
--------------------------------------------------
function AutoFarmLogic.MoverParaPosicao(targetCFrame, altura)
    local targetPos = targetCFrame.Position

    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(15000, 200000, 15000)
    bodyPos.P = 3000
    bodyPos.D = 1000
    bodyPos.Parent = HumanoidRootPart

    local alturaDesejada = math.max(HumanoidRootPart.Position.Y + altura, targetPos.Y + altura)
    -- Etapa 1: Subir até a altura desejada
    while math.abs(HumanoidRootPart.Position.Y - alturaDesejada) > 2 do
        bodyPos.Position = Vector3.new(HumanoidRootPart.Position.X, alturaDesejada, HumanoidRootPart.Position.Z)
        RunService.Heartbeat:Wait()
    end

    -- Etapa 2: Movimento horizontal até o destino
    while (Vector3.new(HumanoidRootPart.Position.X, 0, HumanoidRootPart.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude > 3 do
        bodyPos.Position = Vector3.new(targetPos.X, alturaDesejada, targetPos.Z)
        RunService.Heartbeat:Wait()
    end

    bodyPos:Destroy()
end

--------------------------------------------------
-- Função para aceitar missões automaticamente
--------------------------------------------------
function AutoFarmLogic.AutoQuest()
    if not Config.AutoQuest or questAccepted then return end

    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)
    if not currentMission then
        warn("Nenhuma missão encontrada para o nível " .. currentLevel)
        return
    end

    if HumanoidRootPart and currentMission.CFrameQuest then
        HumanoidRootPart.CFrame = currentMission.CFrameQuest
        task.wait(1)
        local questRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if questRemote then
            questRemote:InvokeServer("StartQuest", currentMission.NameQuest, currentMission.LevelQuest)
            questAccepted = true
            print("Missão aceita: " .. currentMission.NameQuest)
            -- Aqui você pode chamar uma função para atualizar a interface com o nome da missão
        else
            warn("Remote para missões não encontrado")
        end
    end
end

--------------------------------------------------
-- Função para encontrar NPCs com base na missão ativa
--------------------------------------------------
function AutoFarmLogic.FindNPCs()
    local npcs = {}
    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)

    if currentMission and currentMission.NameMon then
        local targetName = currentMission.NameMon
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                if enemy.Name:find(targetName) then
                    local humanoid = enemy:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        table.insert(npcs, enemy)
                    end
                end
            end
        end
    else
        -- Caso não haja missão ativa ou nome do monstro definido, retorna todos os NPCs válidos
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") then
                local humanoid = enemy:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(npcs, enemy)
                end
            end
        end
    end
    return npcs
end

--------------------------------------------------
-- Função para puxar NPCs até a posição alvo
--------------------------------------------------
function AutoFarmLogic.PullNPCs(npcs, targetPosition)
    if not Config.AutoFarm then return end
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            local distance = (hrp.Position - targetPosition).Magnitude
            if distance <= Config.PullDistance then
                local attraction = Instance.new("BodyPosition")
                attraction.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                attraction.Position = targetPosition + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                attraction.Parent = hrp
                task.delay(0.5, function()
                    if attraction and attraction.Parent then
                        attraction:Destroy()
                    end
                end)
            end
        end
    end
end

return AutoFarmLogic
