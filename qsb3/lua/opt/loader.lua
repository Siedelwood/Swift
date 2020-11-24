OptLoader_BasePath = "maps/externalmap/" ..Framework.GetCurrentMapName().. "/";
OptLoader_PluginFiles = {
    {"PluginJobs/source.lua", true, true},
    {"PluginJobs/api.lua", true, true},
    {"PluginTextTools/source.lua", true, true},
    {"PluginTextTools/api.lua", true, true},
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
        if not GUI and OptLoader_PluginFiles[i][2] then
            Script.Load(OptLoader_BasePath.. "lua/plugins/" ..OptLoader_PluginFiles[i][1]);
        end
        if GUI and OptLoader_PluginFiles[i][3] then
            Script.Load(OptLoader_BasePath.. "lua/plugins/" ..OptLoader_PluginFiles[i][1]);
        end
    end

    Script.Load(OptLoader_BasePath.. "lua/core/selfload.lua");
end

