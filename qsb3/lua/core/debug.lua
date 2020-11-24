-- Core Debug --------------------------------------------------------------- --

Swift = Swift or {
    m_CheckAtRun       = false;
    m_TraceQuests      = false;
    m_DevelopingCheats = false;
    m_DevelopingShell  = false;
};

---
-- TODO: Add doc
-- @local
--
function Swift:ActivateDebugMode(_CheckAtRun, _TraceQuests, _DevelopingCheats, _DevelopingShell)
    self.m_CheckAtRun       = false;
    self.m_TraceQuests      = false;
    self.m_DevelopingCheats = false;
    self.m_DevelopingShell  = false;

    Swift:RegisterLoadAction(function()
        Swift:RestoreAfterLoad();
    end);
    self:ActivateCheats();
end

function Swift:RestoreAfterLoad()
    self:ActivateCheats()
end

function Swift:ActivateCheats()
    Logic.ExecuteInLuaLocalState([[
        Input.KeyBindDown(Keys.ModifierControl + Keys.ModifierAlt + Keys.R, "Framework.RestartMap()", 2);
    ]]);
end

