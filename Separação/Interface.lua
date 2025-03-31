--------------------------------------------------
-- INTERFACE DO USUÁRIO (UI)
--------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Declaração do módulo
local InterfaceModule = {}

-- Variáveis e configurações
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

-- Criação da interface
function InterfaceModule.CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoFarmGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 250, 0, 400)
    MainFrame.Position = UDim2.new(0.85, 0, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.BorderSizePixel = 0
    Title.Text = "Auto Farm"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    -- Botão de seleção de arma (simula um dropdown)
    local weaponOptions = {"Melee", "Sword", "Fruit", "Gun"}
    local currentWeaponIndex = 1
    _G.SelectWeapon = weaponOptions[currentWeaponIndex]

    local WeaponButton = Instance.new("TextButton")
    WeaponButton.Name = "WeaponButton"
    WeaponButton.Size = UDim2.new(0.9, 0, 0, 35)
    WeaponButton.Position = UDim2.new(0.05, 0, 0.05, 0)
    WeaponButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    WeaponButton.Text = "Arma: " .. _G.SelectWeapon
    WeaponButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    WeaponButton.TextSize = 16
    WeaponButton.Font = Enum.Font.SourceSans
    WeaponButton.Parent = MainFrame

    local AutoFarmButton = Instance.new("TextButton")
    AutoFarmButton.Name = "AutoFarmButton"
    AutoFarmButton.Size = UDim2.new(0.9, 0, 0, 35)
    AutoFarmButton.Position = UDim2.new(0.05, 0, 0.15, 0)
    AutoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AutoFarmButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    AutoFarmButton.Text = "Auto Farm: OFF"
    AutoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoFarmButton.TextSize = 16
    AutoFarmButton.Font = Enum.Font.SourceSans
    AutoFarmButton.Parent = MainFrame

    local AutoQuestButton = Instance.new("TextButton")
    AutoQuestButton.Name = "AutoQuestButton"
    AutoQuestButton.Size = UDim2.new(0.9, 0, 0, 35)
    AutoQuestButton.Position = UDim2.new(0.05, 0, 0.25, 0)
    AutoQuestButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AutoQuestButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    AutoQuestButton.Text = "Auto Quest: OFF"
    AutoQuestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoQuestButton.TextSize = 16
    AutoQuestButton.Font = Enum.Font.SourceSans
    AutoQuestButton.Parent = MainFrame

    local AutoAttackButton = Instance.new("TextButton")
    AutoAttackButton.Name = "AutoAttackButton"
    AutoAttackButton.Size = UDim2.new(0.9, 0, 0, 35)
    AutoAttackButton.Position = UDim2.new(0.05, 0, 0.35, 0)
    AutoAttackButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AutoAttackButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    AutoAttackButton.Text = "Auto Attack: OFF"
    AutoAttackButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoAttackButton.TextSize = 16
    AutoAttackButton.Font = Enum.Font.SourceSans
    AutoAttackButton.Parent = MainFrame

    local DodgeButton = Instance.new("TextButton")
    DodgeButton.Name = "DodgeButton"
    DodgeButton.Size = UDim2.new(0.9, 0, 0, 35)
    DodgeButton.Position = UDim2.new(0.05, 0, 0.45, 0)
    DodgeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DodgeButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    DodgeButton.Text = "Auto Dodge: ON"
    DodgeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DodgeButton.TextSize = 16
    DodgeButton.Font = Enum.Font.SourceSans
    DodgeButton.Parent = MainFrame

    local HitboxButton = Instance.new("TextButton")
    HitboxButton.Name = "HitboxButton"
    HitboxButton.Size = UDim2.new(0.9, 0, 0, 35)
    HitboxButton.Position = UDim2.new(0.05, 0, 0.55, 0)
    HitboxButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    HitboxButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    HitboxButton.Text = "Hitbox Extender: OFF"
    HitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxButton.TextSize = 16
    HitboxButton.Font = Enum.Font.SourceSans
    HitboxButton.Parent = MainFrame

    local HitboxSliderFrame = Instance.new("Frame")
    HitboxSliderFrame.Name = "HitboxSliderFrame"
    HitboxSliderFrame.Size = UDim2.new(0.9, 0, 0, 20)
    HitboxSliderFrame.Position = UDim2.new(0.05, 0, 0.65, 0)
    HitboxSliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    HitboxSliderFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    HitboxSliderFrame.Parent = MainFrame

    local HitboxSlider = Instance.new("TextButton")
    HitboxSlider.Name = "HitboxSlider"
    HitboxSlider.Size = UDim2.new(0.5, 0, 1, 0)
    HitboxSlider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    HitboxSlider.BorderSizePixel = 0
    HitboxSlider.Text = ""
    HitboxSlider.Parent = HitboxSliderFrame

    -- Posiciona o valor da hitbox logo abaixo do slider
    local HitboxValue = Instance.new("TextLabel")
    HitboxValue.Name = "HitboxValue"
    HitboxValue.Size = UDim2.new(0.9, 0, 0, 20)
    HitboxValue.Position = UDim2.new(0.05, 0, 0.70, 0)
    HitboxValue.BackgroundTransparency = 1
    HitboxValue.Text = "Hitbox Size: " .. Config.HitboxSize
    HitboxValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    HitboxValue.TextSize = 14
    HitboxValue.Font = Enum.Font.SourceSans
    HitboxValue.Parent = MainFrame

    -- Posiciona o status abaixo do valor da hitbox
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 50)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.80, 0)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    StatusLabel.BorderColor3 = Color3.fromRGB(80, 80, 80)
    StatusLabel.Text = "Status: Aguardando"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Parent = MainFrame

    -- Lógica para controle do slider de Hitbox
    local isDragging = false
    HitboxSlider.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = HitboxSliderFrame.AbsolutePosition
            local frameSize = HitboxSliderFrame.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
            HitboxSlider.Size = UDim2.new(relativeX, 0, 1, 0)
            Config.HitboxSize = math.floor(1 + relativeX * 9)
            HitboxValue.Text = "Hitbox Size: " .. Config.HitboxSize
        end
    end)

    -- Retorna os elementos de UI para que possam ser configurados pelo módulo de lógica
    local elements = {
        StatusLabel = StatusLabel,
        AutoFarmButton = AutoFarmButton,
        AutoQuestButton = AutoQuestButton,
        AutoAttackButton = AutoAttackButton,
        DodgeButton = DodgeButton,
        HitboxButton = HitboxButton,
        WeaponButton = WeaponButton,
        HitboxSlider = HitboxSlider,
        HitboxSliderFrame = HitboxSliderFrame,
        HitboxValue = HitboxValue,
        weaponOptions = weaponOptions
    }
    
    return elements, Config
end

-- Expõe as funções e a configuração para o módulo principal
InterfaceModule.Config = Config

return InterfaceModule
