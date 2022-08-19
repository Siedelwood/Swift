Script.Load("maps/externalmap/mp_t01_sync/development.lua");
local ScriptPath = "maps/externalmap/mp_t01_sync/qsb.lua";
if gvMission.MapIsInDevelopmentMode then
    ScriptPath = "E:/Repositories/swift/qsb3/lua/var/qsb/qsb.lua";
end
Script.Load(ScriptPath);