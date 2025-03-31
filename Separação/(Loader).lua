-- Loader Principal: Carrega a Lógica e a Interface

-- Substitua os links abaixo pelos URLs dos seus módulos
local logicModuleLink = "https://seulink.com/AutoFarmLogic.lua"
local interfaceModuleLink = "https://seulink.com/AutoFarmInterface.lua"

local AutoFarmLogic = loadstring(game:HttpGet(logicModuleLink))()
local AutoFarmInterface = loadstring(game:HttpGet(interfaceModuleLink))()

-- Se os módulos tiverem funções de inicialização, você pode chamá-las:
if AutoFarmLogic and AutoFarmLogic.Init then
    AutoFarmLogic.Init()
end

if AutoFarmInterface and AutoFarmInterface.Init then
    AutoFarmInterface.Init()
end

print("Módulos de Lógica e Interface carregados com sucesso!")
