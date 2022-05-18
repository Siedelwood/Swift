local MapPath = "maps/externalmap/mp_t01_sync/";
Script.Load(MapPath.. "development.lua");
local ScriptPath = MapPath.. "internal_localmapscript.lua";
if gvMission.MapIsInDevelopmentMode then
    ScriptPath = "E:/Repositories/swift/qsb3/test/test17_mp_load/mp_t01_sync.s6xmap.unpacked/" ..ScriptPath;
end
Script.Load(ScriptPath);