-- AutoFarmLogic.lua
-- Auto Farm Script - Módulo de Lógicas (Atualizado 2025)
-- Criado por Claude

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

-- Configurações Gerais (ajuste conforme sua necessidade)
local Config = {
    AutoFarm = false,
    AutoQuest = false,
    AutoAttack = false,
    SafeHeight = 10,
    PullDistance = 30,
    AttackRange = 15,
    DodgeEnabled = true,
    HitboxExtender = true,
    HitboxSize = 10,
    HitboxMax = 50,
    AttackAltitudeOffset = 5,
    HitboxAdjustIncrement = 2,
}

-- Estado da missão
local questAccepted = false

-- Carrega as informações das missões (certifique-se de que o link está correto)
local MissionsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/DragonSCPOFICIAL/op_hub/refs/heads/main/world1_missions.lua"))()
local Missions = MissionsModule.missions
local GetMissionByLevel = MissionsModule.getMissionByLevel

--------------------------------------------------
-- FUNÇÃO: Detectar obstáculos via Raycast
--------------------------------------------------
local function detectObstacle(origin, target)
    local direction = (target - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    return result and true or false, result
end

--------------------------------------------------
-- FUNÇÃO: Calcular posição média dos inimigos
--------------------------------------------------
local function GetEnemyCenterPosition(npcs)
    if #npcs == 0 then return nil end
    local sum = Vector3.new(0,0,0)
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            sum = sum + hrp.Position
        end
    end
    return sum / #npcs
end

--------------------------------------------------
-- FUNÇÃO: Movimento utilizando BodyPosition
--------------------------------------------------
local function moverParaPosicao(targetCFrame, altitude)
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")
    local targetPos = targetCFrame.Position

    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(15000, 200000, 15000)
    bodyPos.P = 3000
    bodyPos.D = 1000
    bodyPos.Parent = HRP

    -- Subida
    local alturaDesejada = math.max(HRP.Position.Y + altitude, targetPos.Y + altitude)
    while math.abs(HRP.Position.Y - alturaDesejada) > 2 do
        bodyPos.Position = Vector3.new(HRP.Position.X, alturaDesejada, HRP.Position.Z)
        RunService.Heartbeat:Wait()
    end

    -- Movimento horizontal com verificação de obstáculos
    local horizontalDistance = (Vector3.new(HRP.Position.X, 0, HRP.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
    while horizontalDistance > 3 do
        local hasObs, obsResult = detectObstacle(HRP.Position, targetPos)
        if hasObs then
            local newAlt = obsResult.Position.Y + Config.SafeHeight + 5
            bodyPos.Position = Vector3.new(targetPos.X, newAlt, targetPos.Z)
        else
            bodyPos.Position = Vector3.new(targetPos.X, alturaDesejada, targetPos.Z)
        end
        RunService.Heartbeat:Wait()
        horizontalDistance = (Vector3.new(HRP.Position.X, 0, HRP.Position.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude
    end

    bodyPos:Destroy()
end

--------------------------------------------------
-- FUNÇÃO: Equipar arma selecionada
--------------------------------------------------
local function equipWeapon()
    local selected = _G.SelectWeapon
    local toolToEquip = nil
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if selected == "Melee" and tool.ToolTip == "Melee" then
                toolToEquip = tool
                break
            elseif selected == "Sword" and tool.ToolTip == "Sword" then
                toolToEquip = tool
                break
            elseif selected == "Fruit" and tool.ToolTip == "Blox Fruit" then
                toolToEquip = tool
                break
            elseif selected == "Gun" and tool.ToolTip == "Gun" then
                toolToEquip = tool
                break
            end
        end
    end
    if toolToEquip then
        Humanoid:EquipTool(toolToEquip)
        print(selected .. " equipado!")
        return true
    else
        print("Nenhum " .. selected .. " encontrado no inventário!")
        return false
    end
end

--------------------------------------------------
-- FUNÇÃO: Aceitar missão automaticamente de longe
--------------------------------------------------
local function AutoQuest()
    if not Config.AutoQuest or questAccepted then return end

    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)
    if not currentMission then
        print("Nenhuma missão encontrada para o nível " .. currentLevel)
        return
    end

    if currentMission.CFrameQuest then
        local questPos = currentMission.CFrameQuest.Position
        local targetCF = CFrame.new(questPos) * CFrame.new(0, Config.SafeHeight, 0)
        moverParaPosicao(targetCF, 0)
        task.wait(1)
        local args = { "StartQuest", currentMission.NameQuest, currentMission.LevelQuest }
        local questRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if questRemote then
            questRemote:InvokeServer(unpack(args))
            print("Missão aceita: " .. currentMission.NameQuest)
            questAccepted = true
        else
            print("Remote para missões não encontrado")
        end
    end
end

--------------------------------------------------
-- FUNÇÃO: Encontrar NPCs
--------------------------------------------------
local function FindNPCs()
    local npcs = {}
    local currentLevel = LocalPlayer.Data.Level.Value
    local currentMission = GetMissionByLevel(currentLevel)
    if currentMission then
        local targetName = currentMission.NameMon
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Name:find(targetName) then
                local humanoid = enemy:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    table.insert(npcs, enemy)
                end
            end
        end
    else
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
-- FUNÇÃO: Puxar NPCs para debaixo do jogador
--------------------------------------------------
local function PullNPCs(npcs)
    if not Config.AutoFarm then return end
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - HumanoidRootPart.Position).Magnitude <= Config.PullDistance then
            local attraction = Instance.new("BodyPosition")
            attraction.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            attraction.Position = Vector3.new(HumanoidRootPart.Position.X, HumanoidRootPart.Position.Y - Config.AttackAltitudeOffset, HumanoidRootPart.Position.Z)
            attraction.Parent = hrp
            task.delay(0.5, function()
                if attraction and attraction.Parent then
                    attraction:Destroy()
                end
            end)
        end
    end
end

--------------------------------------------------
-- FUNÇÃO: Atacar NPCs próximos com ajuste dinâmico da hitbox
--------------------------------------------------
local function AutoAttack(npcs, targetPosition)
    if not Config.AutoAttack or not equipWeapon() then return end

    local effectiveAttackRange = Config.AttackRange
    if Config.HitboxExtender then
        effectiveAttackRange = effectiveAttackRange + 20
    end

    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        local humanoid = npc:FindFirstChild("Humanoid")
        if hrp and humanoid then
            local distance = (hrp.Position - targetPosition).Magnitude
            if distance <= effectiveAttackRange then
                local initialHealth = humanoid.Health
                local combatRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if combatRemote then
                    combatRemote:InvokeServer("Combat", "M1")
                end
                task.wait(0.2)
                if math.abs(humanoid.Health - initialHealth) < 1 then
                    Config.HitboxSize = math.min(Config.HitboxSize + Config.HitboxAdjustIncrement, Config.HitboxMax)
                    print("Ajustando hitbox para: " .. Config.HitboxSize)
                end
                task.wait(0.1 + math.random()*0.1)
            end
        end
    end
end

--------------------------------------------------
-- FUNÇÃO: Estender a hitbox dos NPCs
--------------------------------------------------
local function ExtendHitbox(npcs)
    if not Config.HitboxExtender then return end
    for _, npc in ipairs(npcs) do
        local hrp = npc:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            hrp.Transparency = 0.5
            hrp.CanCollide = false
        end
    end
end

--------------------------------------------------
-- FUNÇÃO: Detectar ataques e desviar
--------------------------------------------------
local function DetectAttacks(npcs)
    if not Config.DodgeEnabled then return end
    for _, npc in ipairs(npcs) do
        local humanoid = npc:FindFirstChild("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks() or {}) do
                if track.Name:find("Attack") or track.Name:find("Ability") then
                    local dodgePosition = HumanoidRootPart.Position + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
                    local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(dodgePosition) })
                    tween:Play()
                    task.wait(1)
                    return
                end
            end
        end
    end
end

--------------------------------------------------
-- LOOP PRINCIPAL DE FARMING
--------------------------------------------------
local function StartFarm()
    while task.wait(0.1) do
        if Config.AutoFarm then
            if not questAccepted then
                AutoQuest()
            else
                local npcs = FindNPCs()
                if #npcs > 0 then
                    local centerPos = GetEnemyCenterPosition(npcs)
                    if centerPos then
                        local targetCF = CFrame.new(centerPos) * CFrame.new(0, Config.SafeHeight, 0)
                        moverParaPosicao(targetCF, 0)
                    end
                end
            end

            local npcs = FindNPCs()
            if #npcs > 0 then
                local currentMission = GetMissionByLevel(LocalPlayer.Data.Level.Value)
                local targetPosition = (currentMission and currentMission.CFrameMon) and currentMission.CFrameMon.Position or npcs[1].HumanoidRootPart.Position

                if (HumanoidRootPart.Position - targetPosition).Magnitude > 5 then
                    moverParaPosicao(CFrame.new(targetPosition), Config.SafeHeight)
                    task.wait(0.2)
                end

                PullNPCs(npcs)
                AutoAttack(npcs, targetPosition)
                ExtendHitbox(npcs)
                DetectAttacks(npcs)
            end
        else
            questAccepted = false
        end
    end
end

--------------------------------------------------
-- INICIALIZAÇÃO
--------------------------------------------------
local function InitLogic()
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    end)
    -- Inicia a rotina de farming em uma task separada
    task.spawn(StartFarm)
end

-- Retorna as funções principais para que o módulo possa ser chamado externamente
return {
    Init = InitLogic,
    Config = Config,
    GetEnemyCenterPosition = GetEnemyCenterPosition,
    moverParaPosicao = moverParaPosicao,
    AutoQuest = AutoQuest,
    FindNPCs = FindNPCs,
    PullNPCs = PullNPCs,
    AutoAttack = AutoAttack,
    ExtendHitbox = ExtendHitbox,
    DetectAttacks = DetectAttacks,
}
