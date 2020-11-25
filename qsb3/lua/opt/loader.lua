OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_ModuleFiles = {
    "ModuleJobs/source.lua",
    "ModuleJobs/api.lua",
    "ModuleTextTools/source.lua",
    "ModuleTextTools/api.lua",
}

function OptLoader_SetBasePath(_Path)
    OptLoader_BasePath = _Path;
end

function OptLoader_LoadFiles()  
    Script.Load(OptLoader_BasePath.. "lua/modules/Core/swift.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Core/api.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Core/debug.lua");
    Script.Load(OptLoader_BasePath.. "lua/modules/Core/behavior.lua");

    for i= 1, #OptLoader_ModuleFiles, 1 do
        Script.Load(OptLoader_BasePath.. "lua/modules/" ..OptLoader_ModuleFiles[i]);
    end

    Script.Load(OptLoader_BasePath.. "lua/modules/Core/selfload.lua");
end

