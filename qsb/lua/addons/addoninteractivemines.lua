-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnInteractiveMines                                        # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Der Spieler kann eine Stein- oder Eisenmine erzeugen, die zuerst durch
-- Begleichen der Kosten aufgebaut werden muss, bevor sie genutzt werden kann.
-- <br>Optional kann die Mine einstürzen, wenn sie erschöpft wurde.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnInteractiveMines = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Erstelle eine verschüttete Mine eines bestimmten Typs. Es können zudem eine
-- Bedingung und zwei verschiedene Callbacks vereinbart werden.
--
-- Minen können als "nicht auffüllbar" markiert werden. In diesem Fall werden
-- sie zusammenstützen, sobald die Rohstoffe verbraucht sind.
--
-- Verschüttete Minen können durch einen Helden in normale Minen umgewandelt
-- werden. FÜr diese Umwandlung können Kosten anfallen, müssen aber nicht. Es
-- dürfen immer maximal 2 Waren als Kosten verwendet werden.
--
-- Es können weitere Funktionen hinzugefügt werden, um die Mine anzupassen:
-- <ul>
-- <li><u>Bedingung:</u> Eine Funktion, die true oder false zurückgeben muss.
-- Mit dieser Funktion wird bestimmt, ob die Mine gebaut werden darf.</li>
-- <li><u>Callback Aktivierung:</u> Eine Funktion, die ausgeführt wird, wenn
-- die Mine erfolgreich aktiviert wurde (evtl. Kosten bezahlt und/oder
-- Bedingung erfüllt).</li>
-- <li><u>Callback Erschöpft:</u> Eine Funktion, die ausgeführt wird, sobald
-- die Rohstoffe der Mine erschöpft sind.</li>
-- </ul>
--
-- <p><b>Alias</b>: CreateIOMine</p>
--
-- @param[type=string]   _Position         Script Entity, die mit Mine ersetzt wird
-- @param[type=number]   _Type             Typ der Mine
-- @param[type=table]    _Costs            (optional) Kostentabelle
-- @param[type=boolean]  _NotRefillable    (optional) Die Mine wird weiterhin überwacht
-- @param[type=function] _Condition        (optional) Bedingungsfunktion
-- @param[type=function] _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param[type=function] _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Anwenderfunktionen
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Entities.B_IronMine, {Goods.G_Wood, 20}, true)
-- -- Die Mine kann für 20 Holz erschlossen werden. Sobald die Rohstoffe
-- -- erschöpft sind, stürzt die Mine zusammen.
--
function API.CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Entities, _Type) == nil then
        error("API.CreateIOMine: _Type (" ..tostring(_Type).. ") is wrong!");
        return;
    end
    if _Costs and (type(_Costs) ~= "table" or #_Costs %2 ~= 0) then
        error("API.CreateIOMine: _Costs has the wrong format!");
        return;
    end
    if _Condition and type(_Condition) ~= "function" then
        error("API.CreateIOMine: _Condition must be a function!");
        return;
    end
    if _CreationCallback and type(_CreationCallback) ~= "function" then
        error("API.CreateIOMine: _CreationCallback must be a function!");
        return;
    end
    if _CallbackDepleted and type(_CallbackDepleted) ~= "function" then
        error("API.CreateIOMine: _CallbackDepleted must be a function!");
        return;
    end
    AddOnInteractiveMines.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted);
end
CreateIOMine = API.CreateIOMine;

---
-- Erstelle eine verschüttete Eisenmine.
--
-- <p><b>Alias</b>: CreateIOIronMine</p>
--
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOIronMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Cost1Type) == nil then
        error("API.CreateIOIronMine: _Cost1Type (" ..tostring(_Cost1Type).. ") is wrong!");
        return;
    end
    if _Cost1Amount and (type(_Cost1Amount) ~= "number" or _Cost1Amount < 1) then
        error("API.CreateIOIronMine: _Cost1Amount must be above 0!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Cost2Type) == nil then
        error("API.CreateIOIronMine: _Cost2Type (" ..tostring(_Cost2Type).. ") is wrong!");
        return;
    end
    if _Cost2Amount and (type(_Cost2Amount) ~= "number" or _Cost2Amount < 1) then
        error("API.CreateIOIronMine: _Cost2Amount must be above 0!");
        return;
    end
    AddOnInteractiveMines.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOIronMine = API.CreateIOIronMine;

---
-- Erstelle eine verschüttete Steinmine.
--
-- <p><b>Alias</b>: CreateIOStoneMine</p>
--
-- @param[type=string]  _Position      Script Entity, die mit Mine ersetzt wird
-- @param[type=number]  _Cost1Type     (optional) Kostenware 1
-- @param[type=number]  _Cost1Amount   (optional) Kostenmenge 1
-- @param[type=number]  _Cost2Type     (optional) Kostenware 2
-- @param[type=number]  _Cost2Amount   (optional) Kostenmenge 2
-- @param[type=boolean] _NotRefillable (optional) Mine wird nach Ausbeutung zerstört
-- @within Anwenderfunktionen
-- @see API.CreateIOMine
--
-- @usage
-- -- Beispiel für eine Mine
-- API.CreateIOMine("mine", Goods.G_Wood, 20)
--
function API.CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    if GUI then
        return;
    end
    if not IsExisting(_Position) then
        error("API.CreateIOStoneMine: _Position (" ..tostring(_Position).. ") does not exist!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Cost1Type) == nil then
        error("API.CreateIOStoneMine: _Cost1Type (" ..tostring(_Cost1Type).. ") is wrong!");
        return;
    end
    if _Cost1Amount and (type(_Cost1Amount) ~= "number" or _Cost1Amount < 1) then
        error("API.CreateIOStoneMine: _Cost1Amount must be above 0!");
        return;
    end
    if GetNameOfKeyInTable(Goods, _Cost2Type) == nil then
        error("API.CreateIOStoneMine: _Cost2Type (" ..tostring(_Cost2Type).. ") is wrong!");
        return;
    end
    if _Cost2Amount and (type(_Cost2Amount) ~= "number" or _Cost2Amount < 1) then
        error("API.CreateIOStoneMine: _Cost2Amount must be above 0!");
        return;
    end
    AddOnInteractiveMines.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable);
end
CreateIOStoneMine = API.CreateIOStoneMine;

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnInteractiveMines = {
    Global = {
        Data = {
            Mines = {
                Description = {
                    Title = {
                        de = "Mine errichten",
                        en = "Build pit",
                    },
                    Text = {
                        de = "An diesem Ort könnt Ihr eine Mine errichten!",
                        en = "You're able to create a pit at this location!",
                    },
                },
            },
        }
    },
    Local = {
        Data = {},
    },
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global:Install()
end

---
-- Erstelle eine Mine eines bestimmten Typs. Es können zudem eine Bedingung
-- und zwei verschiedene Callbacks vereinbart werden.
--
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Type [number] Typ der Mine
-- @param _Costs [table] (optional) Kostentabelle
-- @param _NotRefillable [boolean] (optional) Die Mine wird weiterhin überwacht
-- @param _Condition [function] (optional) Bedingungsfunktion
-- @param _CreationCallback (optional) Funktion nach Kauf ausführen
-- @param _CallbackDepleted (optional) Funktion nach Ausbeutung ausführen
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global:CreateIOMine(_Position, _Type, _Costs, _NotRefillable, _Condition, _CreationCallback, _CallbackDepleted)
    -- Objekt austauschen und Model anpassen
    local eID = ReplaceEntity(_Position, Entities.XD_ScriptEntity);
    local Model = Models.Doodads_D_SE_ResourceIron_Wrecked;
    if _Type == Entities.R_StoneMine then
        Model = Models.R_SE_ResorceStone_10;
    end
    Logic.SetVisible(eID, true);
    Logic.SetModel(eID, Model);
    local x, y, z = Logic.EntityGetPos(eID);
    local BlockerID = Logic.CreateEntity(Entities.D_ME_Rock_Set01_B_07, x, y, 0, 0);
    Logic.SetVisible(BlockerID, false);

    CreateObject {
        Name                 = _Position,
        Title                = self.Data.Mines.Description.Title,
        Text                 = self.Data.Mines.Description.Text,
        Type                 = _Type,
        Special              = _NotRefillable,
        Costs                = _Costs,
        InvisibleBlocker     = BlockerID,
        Distance             = 1500,
        Condition            = self.ConditionBuildIOMine,
        CustomCondition      = _Condition,
        CallbackCreate       = _CreationCallback,
        CallbackDepleted     = _CallbackDepleted,
        Callback             = self.ActionBuildIOMine,
    };
end

---
-- Erstelle eine verschüttete Eisenmine.
--
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type [number] (optional) Kostenware 1
-- @param _Cost1Amount [number] (optional) Kostenmenge 1
-- @param _Cost2Type [number] (optional) Kostenware 2
-- @param _Cost2Amount [number] (optional) Kostenmenge 2
-- @param _NotRefillable [boolean] (optional) Mine wird nach Ausbeutung zerstört
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global:CreateIOIronMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_IronMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

---
-- Erstelle eine verschüttete Steinmine.
--
-- @param _Position [string] Script Entity, die mit Mine ersetzt wird
-- @param _Cost1Type [number] (optional) Kostenware 1
-- @param _Cost1Amount [number] (optional) Kostenmenge 1
-- @param _Cost2Type [number] (optional) Kostenware 2
-- @param _Cost2Amount [number] (optional) Kostenmenge 2
-- @param _NotRefillable [boolean] (optional) Mine wird nach Ausbeutung zerstört
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global:CreateIOStoneMine(_Position, _Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount, _NotRefillable)
    assert(IsExisting(_Position));
    if _Cost1Type then
        assert(API.TraverseTable(_Cost1Type, Goods));
        assert(type(_Cost1Amount) == "number");
    end
    if _Cost2Type then
        assert(API.TraverseTable(_Cost2Type, Goods));
        assert(type(_Cost2Amount) == "number");
    end

    self:CreateIOMine(
        _Position, Entities.R_StoneMine,
        {_Cost1Type, _Cost1Amount, _Cost2Type, _Cost2Amount},
        _NotRefillable
    );
end

---
-- Testet die Bedingung, unter der die Mine errichtet werden kann.
-- @param _Data Daten des Objektes
-- @return boolean: Bedingung erfüllt
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global.ConditionBuildIOMine(_IO, _PlayerID, _Data)
    if _Data.CustomCondition then
        return _Data.CustomCondition(_Data) == true;
    end
    return true;
end


function AddOnInteractiveMines.Global.ActionBuildIOMine(_IO, _PlayerID, _Data)
    ReplaceEntity(_Data.Name, _Data.Type);
    DestroyEntity(_Data.InvisibleBlocker);
    if type(_Data.CallbackCreate) == "function" then
        _Data.CallbackCreate(_Data);
    end
    StartSimpleJobEx(AddOnInteractiveMines.Global.ControlIOMine, _Data.Name);
end

---
-- Prüft gebaute Minen ob diese ausgebeutet sind. Ist das der Fall
-- werden sie "zerstört" und ggf. das Callback ausgelöst.
-- @param _Mine Zu überwachende Mine
-- @return boolean: Job beendet
-- @within Internal
-- @local
--
function AddOnInteractiveMines.Global.ControlIOMine(_Mine)
    if not IO[_Mine] then
        return true;
    end
    if not IsExisting(_Mine) then
        return true;
    end
    local eID = GetID(_Mine);

    if Logic.GetResourceDoodadGoodAmount(eID) == 0 then
        API.Note(IO[_Mine].Special)
        if IO[_Mine].Special == true then
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

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnInteractiveMines");

