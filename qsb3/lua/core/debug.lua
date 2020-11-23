-- Core Debug --------------------------------------------------------------- --

Symfonia.Debug = {
    m_CheckAtRun       = false;
    m_TraceQuests      = false;
    m_DevelopingCheats = false;
    m_DevelopingShell  = false;
};

---
-- TODO: Add doc
-- @local
--
function Symfonia.Debug:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    self.m_CheckAtRun       = false;
    self.m_TraceQuests      = false;
    self.m_DevelopingCheats = false;
    self.m_DevelopingShell  = false;

    Symfonia:RegisterLoadAction(function()
        Symfonia.Debug:RestoreAfterLoad();
    end);
    self:ActivateCheats();
end

function Symfonia.Debug:RestoreAfterLoad()
    self:ActivateCheats()
end

function Symfonia.Debug:ActivateCheats()
    Logic.ExecuteInLuaLocalState([[Input.KeyBindDown(Keys.ModifierControl + Keys.ModifierAlt + Keys.R, "Framework.RestartMap()", 2)]]);
end

