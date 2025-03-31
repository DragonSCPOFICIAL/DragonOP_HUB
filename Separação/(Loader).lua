-- Loader.lua
-- Este arquivo intermedia os botões da interface com as funções do módulo de lógicas.
-- Ele carrega apenas o módulo de lógicas e expõe uma função Setup para conectar os botões.
-- Link do módulo de Lógicas:
local logicModuleLink = "https://raw.githubusercontent.com/DragonSCPOFICIAL/DragonOP_HUB/refs/heads/main/Separa%C3%A7%C3%A3o/AutoFarmLogic.lua"

-- Carrega o módulo de lógicas via loadstring
local logicModule = loadstring(game:HttpGet(logicModuleLink))()

-- Cria uma tabela para exportar as funções de conexão
local ButtonController = {}

-- Função Setup: recebe os elementos da UI (criados pelo arquivo de Interface) e a tabela de configuração,
-- e conecta cada botão à sua função específica do módulo de lógicas.
function ButtonController.Setup(uiElements, uiConfig)
    -- Botão de Seleção de Arma:
    uiElements.WeaponButton.MouseButton1Click:Connect(function()
        local currentIndex = table.find(uiElements.weaponOptions, _G.SelectWeapon) or 1
        currentIndex = currentIndex % #uiElements.weaponOptions + 1
        _G.SelectWeapon = uiElements.weaponOptions[currentIndex]
        uiElements.WeaponButton.Text = "Arma: " .. _G.SelectWeapon
        print("Arma selecionada: " .. _G.SelectWeapon)
    end)

    -- Botão Auto Farm:
    uiElements.AutoFarmButton.MouseButton1Click:Connect(function()
        uiConfig.AutoFarm = not uiConfig.AutoFarm
        uiElements.AutoFarmButton.Text = "Auto Farm: " .. (uiConfig.AutoFarm and "ON" or "OFF")
        uiElements.AutoFarmButton.BackgroundColor3 = uiConfig.AutoFarm and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(60, 60, 60)
        
        if uiConfig.AutoFarm then
            -- Inicia o loop principal de farming definido no módulo de lógicas
            logicModule.Init()
            print("Auto Farm iniciado.")
        else
            print("Auto Farm desativado.")
        end
    end)

    -- Botão Auto Quest:
    uiElements.AutoQuestButton.MouseButton1Click:Connect(function()
        uiConfig.AutoQuest = not uiConfig.AutoQuest
        uiElements.AutoQuestButton.Text = "Auto Quest: " .. (uiConfig.AutoQuest and "ON" or "OFF")
        uiElements.AutoQuestButton.BackgroundColor3 = uiConfig.AutoQuest and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(60, 60, 60)
        
        if uiConfig.AutoQuest then
            -- Chama a função AutoQuest do módulo de lógicas
            logicModule.AutoQuest()
            print("Auto Quest acionado.")
        end
    end)

    -- Botão Auto Attack:
    uiElements.AutoAttackButton.MouseButton1Click:Connect(function()
        uiConfig.AutoAttack = not uiConfig.AutoAttack
        uiElements.AutoAttackButton.Text = "Auto Attack: " .. (uiConfig.AutoAttack and "ON" or "OFF")
        uiElements.AutoAttackButton.BackgroundColor3 = uiConfig.AutoAttack and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(60, 60, 60)
        
        if uiConfig.AutoAttack then
            -- Obtém os NPCs e define a posição alvo com base no primeiro NPC encontrado
            local npcs = logicModule.FindNPCs()
            if #npcs > 0 then
                local targetPosition = npcs[1]:FindFirstChild("HumanoidRootPart").Position
                logicModule.AutoAttack(npcs, targetPosition)
                print("Auto Attack acionado.")
            else
                print("Nenhum NPC encontrado para atacar.")
            end
        end
    end)

    -- Botão Dodge:
    uiElements.DodgeButton.MouseButton1Click:Connect(function()
        uiConfig.DodgeEnabled = not uiConfig.DodgeEnabled
        uiElements.DodgeButton.Text = "Auto Dodge: " .. (uiConfig.DodgeEnabled and "ON" or "OFF")
        uiElements.DodgeButton.BackgroundColor3 = uiConfig.DodgeEnabled and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(60, 60, 60)
        print("Auto Dodge: " .. (uiConfig.DodgeEnabled and "ativado" or "desativado"))
        -- A lógica de Dodge é aplicada continuamente no loop de farming do módulo de lógicas.
    end)

    -- Botão Hitbox Extender:
    uiElements.HitboxButton.MouseButton1Click:Connect(function()
        uiConfig.HitboxExtender = not uiConfig.HitboxExtender
        uiElements.HitboxButton.Text = "Hitbox Extender: " .. (uiConfig.HitboxExtender and "ON" or "OFF")
        uiElements.HitboxButton.BackgroundColor3 = uiConfig.HitboxExtender and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(60, 60, 60)
        print("Hitbox Extender: " .. (uiConfig.HitboxExtender and "ativado" or "desativado"))
    end)
end

return ButtonController
