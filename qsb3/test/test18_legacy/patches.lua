function PatchDestructionableMines()
    function ManualMineDestructionController(_Mine)
        if not IO[_Mine] then
            return true;
        end
        if not IsExisting(_Mine) then
            return true;
        end
        local eID = GetID(_Mine);
        if Logic.GetResourceDoodadGoodAmount(eID) == 0 then
            if IO[_Mine].m_Data.Special == true then
                local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
                if IO[_Mine].Type == Entities.R_StoneMine then
                    Model = Models.R_ResorceStone_Scaffold_Destroyed;
                end
                eID = ReplaceEntity(eID, Entities.XD_ScriptEntity);
                Logic.SetVisible(eID, true);
                Logic.SetModel(eID, Model);
            end
    
            if type(IO[_Mine].CallbackDepleted) == "function" then
                IO[_Mine].CallbackDepleted(IO[_Mine]);
            end
            return true;
        end
    end
    AddOnInteractiveMines.Global.ControlIOMine = ManualMineDestructionController;
end