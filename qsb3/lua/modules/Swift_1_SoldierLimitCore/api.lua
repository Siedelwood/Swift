-- Job API ------------------------------------------------------------------ --

---
-- Dieses Modul ermöglicht es das Soldatenlimit eines Spielers frei festzulegen.
--
-- <b>Hinweis</b>: Wird nichts eingestellt, wird der Standard verwendet. Das
-- Limit ist dann 25, 43, 61, 91 (je nach Ausbaustufe der Burg).
--
-- <b>Vorausgesetzte Module:</b>
-- <ul>
-- <li><a href="Swift_0_Core.api.html">(0) Core</a></li>
-- </ul>
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Gibt das aktuelle Soldatenlimit des Spielers zurück.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @return[type=number] Aktuelles Soldatenlimit
-- @within Anwenderfunktionen
-- @usage local Limit = API.GetPlayerSoldierLimit(1);
--
function API.GetPlayerSoldierLimit(_PlayerID)
    local CastleID = Logic.GetHeadquarters(PlayerID);
    local CastleLevel = 1;
    if CastleID ~= 0 then
        CastleLevel = Logic.GetUpgradeLevel(CastleID) +1;
    end
    return ModuleSoldierLimitCore.Shared:GetLimitForPlayer(_PlayerID, CastleID);
end

---
-- Setzt das Soldatenlimit des Spielers für jede Burgausbaustufe fest.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Lv1      Limit Burgstufe 1
-- @param[type=number] _Lv2      Limit Burgstufe 2
-- @param[type=number] _Lv3      Limit Burgstufe 3
-- @param[type=number] _Lv4      Limit Burgstufe 4
-- @within Anwenderfunktionen
-- @usage API.SetPlayerSoldierLimits(1, 100, 200, 300, 400);
--
function API.SetPlayerSoldierLimits(_PlayerID, _Lv1, _Lv2, _Lv3, _Lv4)
    ModuleSoldierLimitCore.Shared:SetLimitsForPlayer(_PlayerID, _Lv1, _Lv2, _Lv3, _Lv4);
    if not GUI then
        Logic.ExecuteInLuaLocalState(string.format(
            [[ModuleSoldierLimitCore.Shared:SetLimitsForPlayer(%d, %d, %d, %d, %d)]],
            _PlayerID, _Lv1, _Lv2, _Lv3, _Lv4
        ));
    else
        GUI.SendScriptCommand(string.format(
            [[ModuleSoldierLimitCore.Shared:SetLimitsForPlayer(%d, %d, %d, %d, %d)]],
            _PlayerID, _Lv1, _Lv2, _Lv3, _Lv4
        ));
    end
end