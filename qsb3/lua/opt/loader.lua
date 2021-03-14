OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_ModuleFiles = {
    "Swift_1_ModuleJobs/source.lua",
    "Swift_1_ModuleJobs/api.lua",
    "Swift_1_ModuleTextTools/source.lua",
    "Swift_1_ModuleTextTools/api.lua",
    "Swift_2_ModuleRealtime/source.lua",
    "Swift_2_ModuleRealtime/api.lua",
}

function OptLoader_SetBasePath(_Path)
    OptLoader_BasePath = _Path;
end

function OptLoader_LoadFiles()
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/swift.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/api.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/debug.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/behavior.lua");

    for i= 1, #OptLoader_ModuleFiles, 1 do
        Script.Load(OptLoader_BasePath.. "lua/modules/" ..OptLoader_ModuleFiles[i]);
    end

    Script.Load(OptLoader_BasePath.. "lua/modules/Swift_0_Core/selfload.lua");
end

