OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_PluginFiles = {
    "PluginJobs/source.lua",
    "PluginJobs/api.lua",
    "PluginTextTools/source.lua",
    "PluginTextTools/api.lua",
}

function OptLoader_SetBasePath(_Path)
    OptLoader_BasePath = _Path;
end

function OptLoader_LoadFiles()  
    Script.Load(OptLoader_BasePath.. "lua/core/swift.lua");
    Script.Load(OptLoader_BasePath.. "lua/core/api.lua");
    Script.Load(OptLoader_BasePath.. "lua/core/debug.lua");
    Script.Load(OptLoader_BasePath.. "lua/core/behavior.lua");

    for i= 1, #OptLoader_PluginFiles, 1 do
        Script.Load(OptLoader_BasePath.. "lua/plugins/" ..OptLoader_PluginFiles[i]);
    end

    Script.Load(OptLoader_BasePath.. "lua/core/selfload.lua");
end

