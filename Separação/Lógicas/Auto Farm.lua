-- Auto Farm Logic Module - Apenas Lógicas de Movimento e Auto Quest
-- Criado para Blox Fruits (Atualizado 2025)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local AutoFarmLogic = {}

-- Configurações relevantes
local Config = {
    AutoQuest = true,      -- Se true, tenta aceitar missão antes de se mover
    SafeHeight = 20,       -- Altura para teleporte (acima dos NPCs)
    AlturaSubida = 50      -- Altura utilizada na lógica de movimento
}

-- Flag para garantir que a missão seja coletada apenas uma vez
local questAccepted = false

-- Carrega informações das missões (dados e função) do módulo remoto
local MissionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCPOFICIAL/op_hub/refs/heads/main/world1_missions.lua"))()
local GetMissionByLevel = MissionsModule.getMissionByLevel

--------------------------------------------------
-- Função de movimento usando BodyPosition
--------------------------------------------------
local function moverParaPosicao(targetCFrame, altura)
    local targetPos = targetCFrame.Position
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(15000, 200000, 15000)
    bodyPos.P = 3000
    bodyPos.D = 1000
    bodyPos.Parent = HumanoidRootPart

    local alturaDesejada = math.max(HumanoidRootPart.Position.Y + altura, targetPos.Y + altura)
    -- Subir até a altura desejada
    while math.abs(HumanoidRootPart.Position.Y - alturaDesejada) > 2 do
        bodyPos.Position = Vector3.new(HumanoidRootPart.Position.X, alturaDesejada, HumanoidRootPart.Position.Z)
        RunService.Heartbeat:Wait()
    end

    -- Mover horizontalmente até a posição-alvo
    while (Vector3.new(HumanoidRootPart.Position.X, 0, HumanoidRootPart.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude > 3 do
        bodyPos.Position = Vector3.new(targetPos.X, alturaDesejada, targetPos.Z)
        RunService.Heartbeat:Wait()
    end

    bodyPos:Destroy()
end

--------------------------------------------------
-- Função para aceitar a missão automaticamente
--------------------------------------------------
local function AutoQuest()
    if not Config.AutoQuest or questAccepted then return end

    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)
    if not currentMission then
        warn("Nenhuma missão encontrada para o nível " .. currentLevel)
        return
    end

    if HumanoidRootPart and currentMission.CFrameQuest then
        -- Teleporta o personagem para a posição da missão
        HumanoidRootPart.CFrame = currentMission.CFrameQuest
        task.wait(1)
        local questRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if questRemote then
            questRemote:InvokeServer("StartQuest", currentMission.NameQuest, currentMission.LevelQuest)
            questAccepted = true
            print("Missão aceita: " .. currentMission.NameQuest)
        else
            warn("Remote para missões não encontrado")
        end
    end
end

--------------------------------------------------
-- Função única que executa as lógicas de movimento e auto quest
--------------------------------------------------
function AutoFarmLogic.Execute()
    -- Tenta aceitar a missão (caso ainda não tenha sido aceita)
    AutoQuest()

    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)
    if currentMission and currentMission.CFrameMon then
        -- Calcula a posição alvo somando uma altura de segurança
        local targetCFrame = currentMission.CFrameMon
        local targetPosition = targetCFrame.Position + Vector3.new(0, Config.SafeHeight, 0)
        moverParaPosicao(CFrame.new(targetPosition), Config.AlturaSubida)
    else
        warn("Missão ou coordenada de monstro não definida para o nível " .. currentLevel)
    end
end

return AutoFarmLogic
