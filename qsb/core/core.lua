-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Core                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Hier werden wichtige Basisfunktionen bereitgestellt. Diese Funktionen sind
-- auch in der Minimalkonfiguration der QSB vorhanden und essentiell für alle
-- anderen Bundles.
--
-- @set sort=true
--

API = API or {};
QSB = QSB or {};
QSB.Version = "Version 2.12.2 16/10/2020";
QSB.HumanPlayerID = 1;
QSB.Language = "de";

Core = Core or {
    Data = {}
};

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

---
-- AddOn Versionsnummer
-- @local
--
g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

