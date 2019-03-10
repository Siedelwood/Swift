-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleKnightTitleRequirements                                # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Erlaubt es dem Mapper die vorgegebenen Aufstiegsbedingungen idividuell
-- an die eigenen Vorstellungen anzupassen.
--
-- Die Aufstiegsbedingungen werden in der Funktion InitKnightTitleTables
-- angegeben und bearbeitet.
--
-- <p><a href="#InitKnightTitleTables">Aufstiegsbedingungen steuern</a></p>
--
-- <p>Mögliche Aufstiegsbedingungen:
-- <ul>
-- <li><b>Entitytyp besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Entities = {
--     {Entities.B_Bakery, 2},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Entitykategorie besitzen</b><br/>
-- Der Spieler muss eine bestimmte Anzahl von Entities einer Kategorie besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Category = {
--     {EntitiyCategories.CattlePasture, 10},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Gütertyp besitzen</b><br/>
-- Der Spieler muss Rohstoffe oder Güter eines Typs besitzen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Goods = {
--     {Goods.G_RawFish, 35},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Produkte erzeugen</b><br/>
-- Der Spieler muss Gebrauchsgegenstände für ein Bedürfnis bereitstellen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Products = {
--     {GoodCategories.GC_Clothes, 6},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Güter konsumieren</b><br/>
-- Die Siedler müssen eine Menge einer bestimmten Waren konsumieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Consume = {
--     {Goods.G_Bread, 30},
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Vielfältigkeit bereitstellen</b><br/>
-- Der Spieler muss einen Vielfältigkeits-Buff aktivieren.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Buff = {
--     Buffs.Buff_FoodDiversity,
--     ...
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Stadtruf erreichen</b><br/>
-- Der Ruf der Stadt muss einen bestimmten Wert erreichen oder überschreiten.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Reputation = 20
-- </code></pre>
--
-- <li><b>Anzahl an Dekorationen</b><br/>
-- Der Spieler muss mindestens die Anzahl der angegebenen Dekoration besitzen.
-- <code><pre>
-- KnightTitleRequirements[KnightTitles.Mayor].DecoratedBuildings = {
--     {Goods.G_Banner, 9 },
-- }
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl voll dekorierter Gebäude</b><br/>
-- Anzahl an Gebäuden, an die alle vier Dekorationen angebracht sein müssen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].FullDecoratedBuildings = 12
-- </code></pre>
-- </li>
--
-- <li><b>Spezialgebäude ausbauen</b><br/>
-- Ein Spezielgebäude muss ausgebaut werden.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Storehouse = 1
-- KnightTitleRequirements[KnightTitles.Mayor].Cathedrals = 1
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl Siedler</b><br/>
-- Der Spieler benötigt eine Gesamtzahl an Siedlern.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Settlers = 40
-- </code></pre>
-- </li>
--
-- <li><b>Anzahl reiche Stadtgebäude</b><br/>
-- Eine Anzahl an Gebäuden muss durch Einnahmen Reichtum erlangen.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].RichBuildings = 30
-- </code></pre>
-- </li>
--
-- <li><b>Benutzerdefiniert</b><br/>
-- Eine benutzerdefinierte Funktion, die entweder als Schalter oder als Zähler
-- fungieren kann und true oder false zurückgeben muss.
-- <pre><code>
-- KnightTitleRequirements[KnightTitles.Mayor].Custom = {
--     {SomeFunction, {1, 1}, "Überschrift", "Beschreibung"}
-- }
-- </code></pre>
-- </li>
-- </ul></p>
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleKnightTitleRequirements = {};

API = API or {};
QSB = QSB or {};

QSB.RequirementTooltipTypes = {};
QSB.ConsumedGoodsCounter = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleKnightTitleRequirements = {
    Global = {},
    Local = {
        Data = {},
    }
};

-- Global Script ---------------------------------------------------------------

---
-- Installiert das Bundle im globalen Skript.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Global:Install()
    self:OverwriteConsumedGoods();
end

---
-- Zählt den Konsumzähler rauf, sobald eine Ware konsumiert wird.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good Warentyp
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Global:RegisterConsumedGoods(_PlayerID, _Good)
    QSB.ConsumedGoodsCounter[_PlayerID]        = QSB.ConsumedGoodsCounter[_PlayerID] or {};
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] or 0;
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] +1;
end

---
-- Überschreibt GameCallback_ConsumeGood, sodass konsumierte Waren gezählt
-- werden können.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Global:OverwriteConsumedGoods()
    GameCallback_ConsumeGood_Orig_QSB_Requirements = GameCallback_ConsumeGood
    GameCallback_ConsumeGood = function(_Consumer, _Good, _Building)
        GameCallback_ConsumeGood_Orig_QSB_Requirements(_Consumer, _Good, _Building)

        local PlayerID = Logic.EntityGetPlayer(_Consumer);
        BundleKnightTitleRequirements.Global:RegisterConsumedGoods(PlayerID, _Good);
        Logic.ExecuteInLuaLocalState([[
            BundleKnightTitleRequirements.Local:RegisterConsumedGoods(
                ]] ..PlayerID.. [[, ]] .._Good.. [[
            );
        ]]);
    end
end

-- Local Script ----------------------------------------------------------------

---
-- Installiert das Bundle im lokalen Skript.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:Install()
    self:OverwriteTooltips();
    self:InitTexturePositions();
    self:OverwriteUpdateRequirements();
    self:OverwritePromotionCelebration();
end

---
-- Zählt den Konsumzähler rauf, sobald eine Ware konsumiert wird.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _Good Warentyp
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:RegisterConsumedGoods(_PlayerID, _Good)
    QSB.ConsumedGoodsCounter[_PlayerID]        = QSB.ConsumedGoodsCounter[_PlayerID] or {};
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] or 0;
    QSB.ConsumedGoodsCounter[_PlayerID][_Good] = QSB.ConsumedGoodsCounter[_PlayerID][_Good] +1;
end

---
-- Fügt einige weitere Einträge zu den Texturpositionen hinzu.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:InitTexturePositions()
    g_TexturePositions.EntityCategories[EntityCategories.GC_Food_Supplier]          = { 1, 1};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Clothes_Supplier]       = { 1, 2};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Hygiene_Supplier]       = {16, 1};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Entertainment_Supplier] = { 1, 4};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Luxury_Supplier]        = {16, 3};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Weapon_Supplier]        = { 1, 7};
    g_TexturePositions.EntityCategories[EntityCategories.GC_Medicine_Supplier]      = { 2,10};
    g_TexturePositions.EntityCategories[EntityCategories.Outpost]                   = {12, 3};
    g_TexturePositions.EntityCategories[EntityCategories.Spouse]                    = { 5,15};
    g_TexturePositions.EntityCategories[EntityCategories.CattlePasture]             = { 3,16};
    g_TexturePositions.EntityCategories[EntityCategories.SheepPasture]              = { 4, 1};
    g_TexturePositions.EntityCategories[EntityCategories.Soldier]                   = { 7,12};
    g_TexturePositions.EntityCategories[EntityCategories.GrainField]                = {14, 2};
    g_TexturePositions.EntityCategories[EntityCategories.OuterRimBuilding]          = { 3, 4};
    g_TexturePositions.EntityCategories[EntityCategories.CityBuilding]              = { 8, 1};
    g_TexturePositions.EntityCategories[EntityCategories.Leader]                    = { 7, 11};
    g_TexturePositions.EntityCategories[EntityCategories.Range]                     = { 9, 8};
    g_TexturePositions.EntityCategories[EntityCategories.Melee]                     = { 9, 7};
    g_TexturePositions.EntityCategories[EntityCategories.SiegeEngine]               = { 2,15};

    g_TexturePositions.Entities[Entities.B_Outpost]                                 = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_AS]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_ME]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_NA]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_NE]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Outpost_SE]                              = {12, 3};
    g_TexturePositions.Entities[Entities.B_Cathedral_Big]                           = { 3,12};
    g_TexturePositions.Entities[Entities.U_MilitaryBallista]                        = {10, 5};
    g_TexturePositions.Entities[Entities.U_Trebuchet]                               = { 9, 1};
    g_TexturePositions.Entities[Entities.U_SiegeEngineCart]                         = { 9, 4};

    g_TexturePositions.Needs[Needs.Medicine]                                        = { 2,10};

    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_1]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_2]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_3]                = { 4, 7};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_1]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_2]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_3]             = { 4, 5};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_1]            = { 4, 6};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_2]            = { 4, 6};
    g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_3]            = { 4, 6};

    g_TexturePositions.Buffs = g_TexturePositions.Buffs or {};

    g_TexturePositions.Buffs[Buffs.Buff_ClothesDiversity]                           = { 1, 2};
    g_TexturePositions.Buffs[Buffs.Buff_EntertainmentDiversity]                     = { 1, 4};
    g_TexturePositions.Buffs[Buffs.Buff_FoodDiversity]                              = { 1, 1};
    g_TexturePositions.Buffs[Buffs.Buff_HygieneDiversity]                           = { 1, 3};
    g_TexturePositions.Buffs[Buffs.Buff_Colour]                                     = { 5,11};
    g_TexturePositions.Buffs[Buffs.Buff_Entertainers]                               = { 5,12};
    g_TexturePositions.Buffs[Buffs.Buff_ExtraPayment]                               = { 1, 8};
    g_TexturePositions.Buffs[Buffs.Buff_Sermon]                                     = { 4,14};
    g_TexturePositions.Buffs[Buffs.Buff_Spice]                                      = { 5,10};
    g_TexturePositions.Buffs[Buffs.Buff_NoTaxes]                                    = { 1, 6};
    if Framework.GetGameExtraNo() ~= 0 then
        g_TexturePositions.Buffs[Buffs.Buff_Gems]                                   = { 1, 1, 1};
        g_TexturePositions.Buffs[Buffs.Buff_MusicalInstrument]                      = { 1, 3, 1};
        g_TexturePositions.Buffs[Buffs.Buff_Olibanum]                               = { 1, 2, 1};
    end

    g_TexturePositions.GoodCategories = g_TexturePositions.GoodCategories or {};

    g_TexturePositions.GoodCategories[GoodCategories.GC_Ammunition]                 = {10, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Animal]                     = { 4,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Clothes]                    = { 1, 2};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Document]                   = { 5, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Entertainment]              = { 1, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Food]                       = { 1, 1};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Gold]                       = { 1, 8};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Hygiene]                    = {16, 1};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Luxury]                     = {16, 3};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Medicine]                   = { 2,10};
    g_TexturePositions.GoodCategories[GoodCategories.GC_None]                       = {15,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_RawFood]                    = { 3, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_RawMedicine]                = { 2, 2};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Research]                   = { 5, 6};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Resource]                   = { 3, 4};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Tools]                      = { 4,12};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Water]                      = { 1,16};
    g_TexturePositions.GoodCategories[GoodCategories.GC_Weapon]                     = { 8, 5};
end

---
-- Überschreibt die Aktualisierungsfunktion der Aufstiegsbedingungen.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:OverwriteUpdateRequirements()
    GUI_Knight.UpdateRequirements = function()
        local WidgetPos = BundleKnightTitleRequirements.Local.Data.RequirementWidgets;
        local RequirementsIndex = 1;

        local PlayerID = GUI.GetPlayerID();
        local CurrentTitle = Logic.GetKnightTitle(PlayerID);
        local NextTitle = CurrentTitle + 1;

        --Headline
        local KnightID = Logic.GetKnightID(PlayerID);
        local KnightType = Logic.GetEntityType(KnightID);
        XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitle", "{center}" .. GUI_Knight.GetTitleNameByTitleID(KnightType, NextTitle));
        XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitleWhite", "{center}" .. GUI_Knight.GetTitleNameByTitleID(KnightType, NextTitle));

        -- show Settlers
        if KnightTitleRequirements[NextTitle].Settlers ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {5,16})
            local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfSettlersForKnightTitleExist(PlayerID, NextTitle)
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount)
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1)
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0)
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1)

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Settlers";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- show rich buildings
        if KnightTitleRequirements[NextTitle].RichBuildings ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {8,4});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfRichBuildingsForKnightTitleExist(PlayerID, NextTitle);
            if NeededAmount == -1 then
                NeededAmount = Logic.GetNumberOfPlayerEntitiesInCategory(PlayerID, EntityCategories.CityBuilding);
            end
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "RichBuildings";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Castle
        if KnightTitleRequirements[NextTitle].Headquarters ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,7});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Headquarters);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Headquarters";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Storehouse
        if KnightTitleRequirements[NextTitle].Storehouse ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,6});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Storehouse);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Storehouse";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Cathedral
        if KnightTitleRequirements[NextTitle].Cathedrals ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {4,5});
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededSpecialBuildingUpgradeForKnightTitleExist(PlayerID, NextTitle, EntityCategories.Cathedrals);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount + 1 .. "/" .. NeededAmount + 1);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Cathedrals";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Neue Bedingungen --------------------------------------------

        -- Volldekorierte Gebäude
        if KnightTitleRequirements[NextTitle].FullDecoratedBuildings ~= nil then
            local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist(PlayerID, NextTitle);
            local EntityCategory = KnightTitleRequirements[NextTitle].FullDecoratedBuildings;
            SetIcon(WidgetPos[RequirementsIndex].."/Icon"  , g_TexturePositions.Needs[Needs.Wealth]);

            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] , 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "FullDecoratedBuildings";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Stadtruf
        if KnightTitleRequirements[NextTitle].Reputation ~= nil then
            SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", {5,14});
            local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededCityReputationForKnightTitleExist(PlayerID, NextTitle);
            XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
            if IsFulfilled then
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
            else
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
            end
            XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

            QSB.RequirementTooltipTypes[RequirementsIndex] = "Reputation";
            RequirementsIndex = RequirementsIndex +1;
        end

        -- Güter sammeln
        if KnightTitleRequirements[NextTitle].Goods ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Goods do
                local GoodType = KnightTitleRequirements[NextTitle].Goods[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfGoodTypesForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Goods" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Kategorien
        if KnightTitleRequirements[NextTitle].Category ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Category do
                local Category = KnightTitleRequirements[NextTitle].Category[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.EntityCategories[Category]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                local EntitiesInCategory = {Logic.GetEntityTypesInCategory(Category)};
                if Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.GC_Weapon_Supplier) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Weapons" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.SiegeEngine) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "HeavyWeapons" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Spouse) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Spouse" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Worker) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Worker" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Soldier) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Soldiers" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Leader) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Leader" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.Outpost) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Outposts" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.CattlePasture) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Cattle" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.SheepPasture) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Sheep" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.CityBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "CityBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.OuterRimBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "OuterRimBuilding" .. i;
                elseif Logic.IsEntityTypeInCategory(EntitiesInCategory[1], EntityCategories.AttackableBuilding) == 1 then
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "Buildings" .. i;
                else
                    QSB.RequirementTooltipTypes[RequirementsIndex] = "EntityCategoryDefault" .. i;
                end
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Entities
        if KnightTitleRequirements[NextTitle].Entities ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Entities do
                local EntityType = KnightTitleRequirements[NextTitle].Entities[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Entities[EntityType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Entities" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Güter konsumieren
        if KnightTitleRequirements[NextTitle].Consume ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Consume do
                local GoodType = KnightTitleRequirements[NextTitle].Consume[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfConsumedGoodsForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Consume" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Güter aus Gruppe produzieren
        if KnightTitleRequirements[NextTitle].Products ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Products do
                local Product = KnightTitleRequirements[NextTitle].Products[i][1];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.GoodCategories[Product]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNumberOfProductsInCategoryExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Products" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Bonus aktivieren
        if KnightTitleRequirements[NextTitle].Buff ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Buff do
                local Buff = KnightTitleRequirements[NextTitle].Buff[i];
                SetIcon(WidgetPos[RequirementsIndex] .. "/Icon", g_TexturePositions.Buffs[Buff]);
                local IsFulfilled = DoNeededDiversityBuffForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "");
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Buff" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Selbstdefinierte Bedingung
        if KnightTitleRequirements[NextTitle].Custom ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].Custom do
                local Icon = KnightTitleRequirements[NextTitle].Custom[i][2];
                BundleKnightTitleRequirements.Local:RequirementIcon(WidgetPos[RequirementsIndex] .. "/Icon", Icon);
                local IsFulfilled, CurrentAmount, NeededAmount = DoCustomFunctionForKnightTitleSucceed(PlayerID, NextTitle, i);
                if CurrentAmount and NeededAmount then
                    XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                else
                    XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "");
                end
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "Custom" .. i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Dekorationselemente
        if KnightTitleRequirements[NextTitle].DecoratedBuildings ~= nil then
            for i=1, #KnightTitleRequirements[NextTitle].DecoratedBuildings do
                local GoodType = KnightTitleRequirements[NextTitle].DecoratedBuildings[i][1];
                SetIcon(WidgetPos[RequirementsIndex].."/Icon", g_TexturePositions.Goods[GoodType]);
                local IsFulfilled, CurrentAmount, NeededAmount = DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(PlayerID, NextTitle, i);
                XGUIEng.SetText(WidgetPos[RequirementsIndex] .. "/Amount", "{center}" .. CurrentAmount .. "/" .. NeededAmount);
                if IsFulfilled then
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 1);
                else
                    XGUIEng.ShowWidget(WidgetPos[RequirementsIndex] .. "/Done", 0);
                end
                XGUIEng.ShowWidget(WidgetPos[RequirementsIndex], 1);

                QSB.RequirementTooltipTypes[RequirementsIndex] = "DecoratedBuildings" ..i;
                RequirementsIndex = RequirementsIndex +1;
            end
        end

        -- Übrige ausblenden
        for i=RequirementsIndex, 6 do
            XGUIEng.ShowWidget(WidgetPos[i], 0);
        end
    end
end

---
-- Überschreibt die Beförderung des Primary Knight.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:OverwritePromotionCelebration()
    StartKnightsPromotionCelebration = function( _PlayerID , _OldTitle, _FirstTime)
        if _PlayerID ~= GUI.GetPlayerID() or Logic.GetTime() < 5 then
            return;
        end

        local MarketplaceID = Logic.GetMarketplace(_PlayerID);

        if _FirstTime == 1 then
            local KnightID = Logic.GetKnightID(_PlayerID);
            local Random

            repeat
                Random = 1 + XGUIEng.GetRandom(3)
            until Random ~= g_LastGotPromotionMessageRandom

            g_LastGotPromotionMessageRandom = Random;
            local TextKey = "Title_GotPromotion" .. Random;
            LocalScriptCallback_QueueVoiceMessage(_PlayerID, TextKey, false, _PlayerID);
            GUI.StartFestival(_PlayerID, 1);
        end

        -- reset local
        local Consume = QSB.ConsumedGoodsCounter[_PlayerID];
        QSB.ConsumedGoodsCounter[_PlayerID] = Consume or {};
        for k,v in pairs(QSB.ConsumedGoodsCounter[_PlayerID]) do
            QSB.ConsumedGoodsCounter[_PlayerID][k] = 0;
        end

        -- reset global
        GUI.SendScriptCommand([[
            local Consume = QSB.ConsumedGoodsCounter[]].._PlayerID..[[];
            QSB.ConsumedGoodsCounter[]].._PlayerID..[[] = Consume or {};
            for k,v in pairs(QSB.ConsumedGoodsCounter[]].._PlayerID..[[]) do
                QSB.ConsumedGoodsCounter[]].._PlayerID..[[][k] = 0;
            end
        ]]);

        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu", 0);
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopCenter/KnightTitleMenuBig", 0);
        g_WantsPromotionMessageInterval = 30;
        g_TimeOfPromotionPossible = nil;
    end
end

---
-- Überschreibt die Tooltips im Aufstiegsmenü.
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:OverwriteTooltips()
    GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements = GUI_Tooltip.SetNameAndDescription;
    GUI_Tooltip.SetNameAndDescription = function(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean)
        local CurrentWidgetID = XGUIEng.GetCurrentWidgetID();
        local Selected = GUI.GetSelectedEntity();
        local PlayerID = GUI.GetPlayerID();

        for k,v in pairs(BundleKnightTitleRequirements.Local.Data.RequirementWidgets) do
            if v .. "/Icon" == XGUIEng.GetWidgetPathByID(CurrentWidgetID) then
                local key = QSB.RequirementTooltipTypes[k];
                local num = tonumber(string.sub(key, string.len(key)));
                if num ~= nil then
                    key = string.sub(key, 1, string.len(key)-1);
                end
                BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(key, num);
                return;
            end
        end
        GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements(_TooltipNameWidget, _TooltipDescriptionWidget, _OptionalTextKeyName, _OptionalDisabledTextKeyName, _OptionalMissionTextFileBoolean);
    end

    GUI_Knight.RequiredGoodTooltip = function()
        local key = QSB.RequirementTooltipTypes[2];
        local num = tonumber(string.sub(key, string.len(key)));
        if num ~= nil then
            key = string.sub(key, 1, string.len(key)-1);
        end
        BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(key, num);
    end

    if Framework.GetGameExtraNo() ~= 0 then
        BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_Gems] = {
            de = "Edelsteine beschaffen", en = "Obtain gems"
        }
        BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_Olibanum] = {
            de = "Weihrauch beschaffen", en = "Obtain olibanum"
        }
        BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_MusicalInstrument] = {
            de = "Muskinstrumente beschaffen", en = "Obtain instruments"
        }
    end
end

---
-- Ändert die Textur eines Icons in den Aufstiegsbedingungen.
--
-- Icons für Aufstiegsbedingungen können sein:
-- <ul>
-- <li>Koordinaten auf der Spielinternen Icon Matrix</li>
-- <li>Koordinaten auf einer externen Icon Matrix (Name .. "big.png")</li>
-- <li>Pfad zu einelnem Icon (200x200 Pixel)</li>
-- </ul>
--
-- @param[type=string] _Widget Icon Widget
-- @param              _Icon Icon Textur (Dateiname oder Matrix)
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:RequirementIcon(_Widget, _Icon)
    if type(_Icon) == "table" then
        if type(_Icon[3]) == "string" then
            local ButtonState = 1;
            if XGUIEng.IsButton(_Widget) == 1 then
                ButtonState = 7;
            end

            local u0, u1, v0, v1;
            u0 = (_Icon[1] - 1) * 64;
            v0 = (_Icon[2] - 1) * 64;
            u1 = (_Icon[1]) * 64;
            v1 = (_Icon[2]) * 64;
            XGUIEng.SetMaterialAlpha(_Widget, ButtonState, 255);
            XGUIEng.SetMaterialTexture(_Widget, ButtonState, _Icon[3].. "big.png");
            XGUIEng.SetMaterialUV(_Widget, ButtonState, u0, v0, u1, v1);
        else
            SetIcon(_Widget, _Icon);
        end
    else
        local screenSize = {GUI.GetScreenSize()};
        local Scale = 330;
        if screenSize[2] >= 800 then
            Scale = 260;
        end
        if screenSize[2] >= 1000 then
            Scale = 210;
        end
        XGUIEng.SetMaterialAlpha(_Widget, 1, 255);
        XGUIEng.SetMaterialTexture(_Widget, 1, _file);
        XGUIEng.SetMaterialUV(_Widget, 1, 0, 0, Scale, Scale);
    end
end

---
-- Setzt einen für den Tooltip des aktuellen Widget einen neuen Text.
--
-- @param[type=string] _Title Titel des Tooltip
-- @param[type=string] _Text  Text des Tooltip
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:RequirementTooltip(_Title, _Text)
    local TooltipContainerPath = "/InGame/Root/Normal/TooltipNormal";
    local TooltipContainer = XGUIEng.GetWidgetID(TooltipContainerPath);
    local TooltipNameWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Name");
    local TooltipDescriptionWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/Text");
    local TooltipBGWidget = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn/BG");
    local TooltipFadeInContainer = XGUIEng.GetWidgetID(TooltipContainerPath .. "/FadeIn");
    local PositionWidget = XGUIEng.GetCurrentWidgetID();
    GUI_Tooltip.ResizeBG(TooltipBGWidget, TooltipDescriptionWidget);
    local TooltipContainerSizeWidgets = {TooltipBGWidget};
    GUI_Tooltip.SetPosition(TooltipContainer, TooltipContainerSizeWidgets, PositionWidget);
    GUI_Tooltip.FadeInTooltip(TooltipFadeInContainer);

    XGUIEng.SetText(TooltipNameWidget, "{center}" .. _Title);
    XGUIEng.SetText(TooltipDescriptionWidget, _Text);
    local Height = XGUIEng.GetTextHeight(TooltipDescriptionWidget, true);
    local W, H = XGUIEng.GetWidgetSize(TooltipDescriptionWidget);
    XGUIEng.SetWidgetSize(TooltipDescriptionWidget, W, Height);
end

---
-- Ermittelt die veränderten Texte für den Tooltip hinter dem angegebenen Key.
--
-- @param[type=string] _key Index in Description
-- @param[type=number] _i   Buttonindex
-- @within BundleKnightTitleRequirements
-- @local
--
function BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(_key, _i)
    local lang = (Network.GetDesiredLanguage() == "de" and "de") or "en";
    local PlayerID = GUI.GetPlayerID();
    local KnightTitle = Logic.GetKnightTitle(PlayerID);
    local Title = ""
    local Text = "";

    if _key == "Consume" or _key == "Goods" or _key == "DecoratedBuildings" then
        local GoodType     = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local GoodTypeName = Logic.GetGoodTypeName(GoodType);
        local GoodName     = XGUIEng.GetStringTableText("UI_ObjectNames/" .. GoodTypeName);

        if GoodName == nil then
            GoodName = "Goods." .. GoodTypeName;
        end
        Title = GoodName;
        Text  = BundleKnightTitleRequirements.Local.Data.Description[_key].Text;

    elseif _key == "Products" then
        local GoodCategoryNames = BundleKnightTitleRequirements.Local.Data.GoodCategoryNames;
        local Category = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local CategoryName = GoodCategoryNames[Category][lang];

        if CategoryName == nil then
            CategoryName = "ERROR: Name missng!";
        end
        Title = CategoryName;
        Text  = BundleKnightTitleRequirements.Local.Data.Description[_key].Text;

    elseif _key == "Entities" then
        local EntityType     = KnightTitleRequirements[KnightTitle+1][_key][_i][1];
        local EntityTypeName = Logic.GetEntityTypeName(EntityType);
        local EntityName = XGUIEng.GetStringTableText("Names/" .. EntityTypeName);

        if EntityName == nil then
            EntityName = "Entities." .. EntityTypeName;
        end

        Title = EntityName;
        Text  = BundleKnightTitleRequirements.Local.Data.Description[_key].Text;

    elseif _key == "Custom" then
        local Custom = KnightTitleRequirements[KnightTitle+1].Custom[_i];
        Title = Custom[3];
        Text  = Custom[4];

    elseif _key == "Buff" then
        local BuffTypeNames = BundleKnightTitleRequirements.Local.Data.BuffTypeNames;
        local BuffType = KnightTitleRequirements[KnightTitle+1][_key][_i];
        local BuffTitle = BuffTypeNames[BuffType][lang];

        if BuffTitle == nil then
            BuffTitle = "ERROR: Name missng!";
        end
        Title = BuffTitle;
        Text  = BundleKnightTitleRequirements.Local.Data.Description[_key].Text;

    else
        Title = BundleKnightTitleRequirements.Local.Data.Description[_key].Title;
        Text  = BundleKnightTitleRequirements.Local.Data.Description[_key].Text;
    end

    Title = (type(Title) == "table" and Title[lang]) or Title;
    Text  = (type(Text) == "table" and Text[lang]) or Text;
    self:RequirementTooltip(Title, Text);
end

BundleKnightTitleRequirements.Local.Data.RequirementWidgets = {
    [1] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Settlers",
    [2] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Goods",
    [3] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/RichBuildings",
    [4] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Castle",
    [5] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Storehouse",
    [6] = "/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Cathedral",
};

BundleKnightTitleRequirements.Local.Data.GoodCategoryNames = {
    [GoodCategories.GC_Ammunition]      = {de = "Munition", en = "Ammunition"},
    [GoodCategories.GC_Animal]          = {de = "Nutztiere", en = "Livestock"},
    [GoodCategories.GC_Clothes]         = {de = "Kleidung", en = "Clothes"},
    [GoodCategories.GC_Document]        = {de = "Dokumente", en = "Documents"},
    [GoodCategories.GC_Entertainment]   = {de = "Unterhaltung", en = "Entertainment"},
    [GoodCategories.GC_Food]            = {de = "Nahrungsmittel", en = "Food"},
    [GoodCategories.GC_Gold]            = {de = "Gold", en = "Gold"},
    [GoodCategories.GC_Hygiene]         = {de = "Hygieneartikel", en = "Hygiene"},
    [GoodCategories.GC_Luxury]          = {de = "Dekoration", en = "Decoration"},
    [GoodCategories.GC_Medicine]        = {de = "Medizin", en = "Medicine"},
    [GoodCategories.GC_None]            = {de = "Nichts", en = "None"},
    [GoodCategories.GC_RawFood]         = {de = "Nahrungsmittel", en = "Food"},
    [GoodCategories.GC_RawMedicine]     = {de = "Medizin", en = "Medicine"},
    [GoodCategories.GC_Research]        = {de = "Forschung", en = "Research"},
    [GoodCategories.GC_Resource]        = {de = "Rohstoffe", en = "Resource"},
    [GoodCategories.GC_Tools]           = {de = "Werkzeug", en = "Tools"},
    [GoodCategories.GC_Water]           = {de = "Wasser", en = "Water"},
    [GoodCategories.GC_Weapon]          = {de = "Waffen", en = "Weapon"},
};

BundleKnightTitleRequirements.Local.Data.BuffTypeNames = {
    [Buffs.Buff_ClothesDiversity]        = {de = "Abwechslungsreiche Kleidung", en = "Clothes diversity"},
    [Buffs.Buff_Colour]                  = {de = "Farben beschaffen", en = "Obtain color"},
    -- Funktioniert nicht, belegt MP
    [Buffs.Buff_Entertainers]            = {de = "Gaukler anheuern", en = "Hire entertainer"},
    [Buffs.Buff_EntertainmentDiversity]  = {de = "Abwechslungsreiche Unterhaltung", en = "Entertainment diversity"},
    [Buffs.Buff_ExtraPayment]            = {de = "Sonderzahlung", en = "Extra payment"},
    -- Funktioniert nicht, belegt MP
    [Buffs.Buff_Festival]                = {de = "Fest veranstalten", en = "Hold Festival"},
    [Buffs.Buff_FoodDiversity]           = {de = "Abwechslungsreiche Nahrung", en = "Food diversity"},
    [Buffs.Buff_HygieneDiversity]        = {de = "Abwechslungsreiche Hygiene", en = "Hygiene diversity"},
    [Buffs.Buff_NoTaxes]                 = {de = "Steuerbefreiung", en = "No taxes"},
    [Buffs.Buff_Sermon]                  = {de = "Pregigt abhalten", en = "Hold sermon"},
    [Buffs.Buff_Spice]                   = {de = "Salz beschaffen", en = "Obtain salt"},
};

BundleKnightTitleRequirements.Local.Data.Description = {
    Settlers = {
        Title = {
            de = "Benötigte Siedler",
            en = "Needed settlers",
        },
        Text = {
            de = "- Benötigte Menge an Siedlern",
            en = "- Needed number of settlers",
        },
    },

    RichBuildings = {
        Title = {
            de = "Reiche Stadtgebäude",
            en = "Rich city buildings",
        },
        Text = {
            de = "- Menge an reichen Stadtgebäuden",
            en = "- Needed amount of rich city buildings",
        },
    },

    Goods = {
        Title = {
            de = "Waren lagern",
            en = "Store Goods",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed amount",
        },
    },

    FullDecoratedBuildings = {
        Title = {
            de = "Dekorierte Stadtgebäude",
            en = "Decorated City buildings",
        },
        Text = {
            de = "- Menge an voll dekorierten Gebäuden",
            en = "- Amount of full decoraded city buildings",
        },
    },

    DecoratedBuildings = {
        Title = {
            de = "Dekoration",
            en = "Decoration",
        },
        Text = {
            de = "- Menge an Dekorationsgütern in der Siedlung",
            en = "- Amount of decoration goods in settlement",
        },
    },

    Headquarters = {
        Title = {
            de = "Burgstufe",
            en = "Castle level",
        },
        Text = {
            de = "- Benötigte Ausbauten der Burg",
            en = "- Needed castle upgrades",
        },
    },

    Storehouse = {
        Title = {
            de = "Lagerhausstufe",
            en = "Storehouse level",
        },
        Text = {
            de = "- Benötigte Ausbauten des Lagerhauses",
            en = "- Needed storehouse upgrades",
        },
    },

    Cathedrals = {
        Title = {
            de = "Kirchenstufe",
            en = "Cathedral level",
        },
        Text = {
            de = "- Benötigte Ausbauten der Kirche",
            en = "- Needed cathedral upgrades",
        },
    },

    Reputation = {
        Title = {
            de = "Ruf der Stadt",
            en = "City reputation",
        },
        Text = {
            de = "- Benötigter Ruf der Stadt",
            en = "- Needed city reputation",
        },
    },

    EntityCategoryDefault = {
        Title = {
            de = "",
            en = "",
        },
        Text = {
            de = "- Benötigte Anzahl",
            en = "- Needed amount",
        },
    },

    Cattle = {
        Title = {
            de = "Kühe",
            en = "Cattle",
        },
        Text = {
            de = "- Benötigte Menge an Kühen",
            en = "- Needed amount of cattle",
        },
    },

    Sheep = {
        Title = {
            de = "Schafe",
            en = "Sheeps",
        },
        Text = {
            de = "- Benötigte Menge an Schafen",
            en = "- Needed amount of sheeps",
        },
    },

    Outposts = {
        Title = {
            de = "Territorien",
            en = "Territories",
        },
        Text = {
            de = "- Zu erobernde Territorien",
            en = "- Territories to claim",
        },
    },

    CityBuilding = {
        Title = {
            de = "Stadtgebäude",
            en = "City buildings",
        },
        Text = {
            de = "- Menge benötigter Stadtgebäude",
            en = "- Needed amount of city buildings",
        },
    },

    OuterRimBuilding = {
        Title = {
            de = "Rohstoffgebäude",
            en = "Gatherer",
        },
        Text = {
            de = "- Menge benötigter Rohstoffgebäude",
            en = "- Needed amount of gatherer",
        },
    },

    Consume = {
        Title = {
            de = "",
            en = "",
        },
        Text = {
            de = "- Durch Siedler zu konsumierende Menge",
            en = "- Amount to be consumed by the settlers",
        },
    },

    Products = {
        Title = {
            de = "",
            en = "",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed amount",
        },
    },

    Buff = {
        Title = {
            de = "Bonus aktivieren",
            en = "Activate Buff",
        },
        Text = {
            de = "- Aktiviere diesen Bonus auf den Ruf der Stadt",
            en = "- Raise the city reputatition with this buff",
        },
    },

    Leader = {
        Title = {
            de = "Batalione",
            en = "Battalions",
        },
        Text = {
            de = "- Menge an Batalionen unterhalten",
            en = "- Battalions you need under your command",
        },
    },

    Soldiers = {
        Title = {
            de = "Soldaten",
            en = "Soldiers",
        },
        Text = {
            de = "- Menge an Streitkräften unterhalten",
            en = "- Soldiers you need under your command",
        },
    },

    Worker = {
        Title = {
            de = "Arbeiter",
            en = "Workers",
        },
        Text = {
            de = "- Menge an arbeitender Bevölkerung",
            en = "- Workers you need under your reign",
        },
    },

    Entities = {
        Title = {
            de = "",
            en = "",
        },
        Text = {
            de = "- Benötigte Menge",
            en = "- Needed Amount",
        },
    },

    Buildings = {
        Title = {
            de = "Gebäude",
            en = "Buildings",
        },
        Text = {
            de = "- Gesamtmenge an Gebäuden",
            en = "- Amount of buildings",
        },
    },

    Weapons = {
        Title = {
            de = "Waffen",
            en = "Weapons",
        },
        Text = {
            de = "- Benötigte Menge an Waffen",
            en = "- Needed amount of weapons",
        },
    },

    HeavyWeapons = {
        Title = {
            de = "Belagerungsgeräte",
            en = "Siege Engines",
        },
        Text = {
            de = "- Benötigte Menge an Belagerungsgeräten",
            en = "- Needed amount of siege engine",
        },
    },

    Spouse = {
        Title = {
            de = "Ehefrauen",
            en = "Spouses",
        },
        Text = {
            de = "- Benötigte Anzahl Ehefrauen in der Stadt",
            en = "- Needed amount of spouses in your city",
        },
    },
};

Core:RegisterBundle("BundleKnightTitleRequirements");

-- -------------------------------------------------------------------------- --
-- Spielfunktionen                                                            --
-- -------------------------------------------------------------------------- --

---
-- Prüft, ob genug Entities in einer bestimmten Kategorie existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Category == nil then
        return;
    end
    if _i then
        local EntityCategory = KnightTitleRequirements[_KnightTitle].Category[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Category[_i][2];

        local ReachedAmount = 0;
        if EntityCategory == EntityCategories.Spouse then
            ReachedAmount = Logic.GetNumberOfSpouses(_PlayerID);
        else
            local Buildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategory)};
            for i=1, #Buildings do
                if Logic.IsBuilding(Buildings[i]) == 1 then
                    if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                        ReachedAmount = ReachedAmount +1;
                    end
                else
                    ReachedAmount = ReachedAmount +1;
                end
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Category do
            bool, reach, need = DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Entities eines bestimmten Typs existieren.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Entities == nil then
        return;
    end
    if _i then
        local EntityType = KnightTitleRequirements[_KnightTitle].Entities[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Entities[_i][2];
        local Buildings = GetPlayerEntities(_PlayerID, EntityType);

        local ReachedAmount = 0;
        for i=1, #Buildings do
            if Logic.IsBuilding(Buildings[i]) == 1 then
                if Logic.IsConstructionComplete(Buildings[i]) == 1 then
                    ReachedAmount = ReachedAmount +1;
                end
            else
                ReachedAmount = ReachedAmount +1;
            end
        end

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Entities do
            bool, reach, need = DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob es genug Einheiten eines Warentyps gibt.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoesNeededNumberOfGoodTypesForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Goods == nil then
        return;
    end
    if _i then
        local GoodType = KnightTitleRequirements[_KnightTitle].Goods[_i][1];
        local NeededAmount = KnightTitleRequirements[_KnightTitle].Goods[_i][2];
        local ReachedAmount = GetPlayerGoodsInSettlement(GoodType, _PlayerID, true);

        if ReachedAmount >= NeededAmount then
            return true, ReachedAmount, NeededAmount;
        end
        return false, ReachedAmount, NeededAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Goods do
            bool, reach, need = DoesNeededNumberOfGoodTypesForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Siedler genug Einheiten einer Ware konsumiert haben.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfConsumedGoodsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Consume == nil then
        return;
    end
    if _i then
        QSB.ConsumedGoodsCounter[_PlayerID] = QSB.ConsumedGoodsCounter[_PlayerID] or {};

        local GoodType = KnightTitleRequirements[_KnightTitle].Consume[_i][1];
        local GoodAmount = QSB.ConsumedGoodsCounter[_PlayerID][GoodType] or 0;
        local NeededGoodAmount = KnightTitleRequirements[_KnightTitle].Consume[_i][2];
        if GoodAmount >= NeededGoodAmount then
            return true, GoodAmount, NeededGoodAmount;
        else
            return false, GoodAmount, NeededGoodAmount;
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Consume do
            bool, reach, need = DoNeededNumberOfConsumedGoodsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return false, reach, need
            end
        end
        return true, reach, need;
    end
end

---
-- Prüft, ob genug Waren der Kategorie hergestellt wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNumberOfProductsInCategoryExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Products == nil then
        return;
    end
    if _i then
        local GoodAmount = 0;
        local NeedAmount = KnightTitleRequirements[_KnightTitle].Products[_i][2];
        local GoodCategory = KnightTitleRequirements[_KnightTitle].Products[_i][1];
        local GoodsInCategory = {Logic.GetGoodTypesInGoodCategory(GoodCategory)};

        for i=1, #GoodsInCategory do
            GoodAmount = GoodAmount + GetPlayerGoodsInSettlement(GoodsInCategory[i], _PlayerID, true);
        end
        return (GoodAmount >= NeedAmount), GoodAmount, NeedAmount;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Products do
            bool, reach, need = DoNumberOfProductsInCategoryExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob ein bestimmter Buff für den Spieler aktiv ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededDiversityBuffForKnightTitleExist = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Buff == nil then
        return;
    end
    if _i then
        local buff = KnightTitleRequirements[_KnightTitle].Buff[_i];
        if Logic.GetBuff(_PlayerID,buff) and Logic.GetBuff(_PlayerID,buff) ~= 0 then
            return true;
        end
        return false;
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Buff do
            bool, reach, need = DoNeededDiversityBuffForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Custom Function true vermeldet.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoCustomFunctionForKnightTitleSucceed = function(_PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].Custom == nil then
        return;
    end
    if _i then
        return KnightTitleRequirements[_KnightTitle].Custom[_i][1]();
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].Custom do
            bool, reach, need = DoCustomFunctionForKnightTitleSucceed(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob genug Dekoration eines Typs angebracht wurde.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _i Button Index
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle, _i)
    if KnightTitleRequirements[_KnightTitle].DecoratedBuildings == nil then
        return
    end

    if _i then
        local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
        local DecorationGoodType = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][1]
        local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].DecoratedBuildings[_i][2]
        local BuildingsWithDecoration = 0

        for i=1, #CityBuildings do
            local BuildingID = CityBuildings[i]
            local GoodState = Logic.GetBuildingWealthGoodState(BuildingID, DecorationGoodType)
            if GoodState > 0 then
                BuildingsWithDecoration = BuildingsWithDecoration + 1
            end
        end

        if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
            return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
        else
            return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
        end
    else
        local bool, reach, need;
        for i=1,#KnightTitleRequirements[_KnightTitle].DecoratedBuildings do
            bool, reach, need = DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(_PlayerID, _KnightTitle, i);
            if bool == false then
                return bool, reach, need
            end
        end
        return bool;
    end
end

---
-- Prüft, ob die Spezialgebäude weit genug ausgebaut sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @param[type=number] _EntityCategory Entity Category
-- @within Originalfunktionen
-- @local
--
DoNeededSpecialBuildingUpgradeForKnightTitleExist = function( _PlayerID, _KnightTitle, _EntityCategory)
    local SpecialBuilding
    local SpecialBuildingName
    if _EntityCategory == EntityCategories.Headquarters then
        SpecialBuilding = Logic.GetHeadquarters(_PlayerID)
        SpecialBuildingName = "Headquarters"
    elseif _EntityCategory == EntityCategories.Storehouse then
        SpecialBuilding = Logic.GetStoreHouse(_PlayerID)
        SpecialBuildingName = "Storehouse"
    elseif _EntityCategory == EntityCategories.Cathedrals then
        SpecialBuilding = Logic.GetCathedral(_PlayerID)
        SpecialBuildingName = "Cathedrals"
    else
        return
    end
    if KnightTitleRequirements[_KnightTitle][SpecialBuildingName] == nil then
        return
    end
    local NeededUpgradeLevel = KnightTitleRequirements[_KnightTitle][SpecialBuildingName]
    if SpecialBuilding ~= nil then
        local SpecialBuildingUpgradeLevel = Logic.GetUpgradeLevel(SpecialBuilding)
        if SpecialBuildingUpgradeLevel >= NeededUpgradeLevel then
            return true, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        else
            return false, SpecialBuildingUpgradeLevel, NeededUpgradeLevel
        end
    else
        return false, 0, NeededUpgradeLevel
    end
end

---
-- Prüft, ob der Ruf der Stadt hoch genug ist.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoesNeededCityReputationForKnightTitleExist = function(_PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].Reputation == nil then
        return;
    end
    local NeededAmount = KnightTitleRequirements[_KnightTitle].Reputation;
    if not NeededAmount then
        return;
    end
    local ReachedAmount = math.floor((Logic.GetCityReputation(_PlayerID) * 100) + 0.5);
    if ReachedAmount >= NeededAmount then
        return true, ReachedAmount, NeededAmount;
    end
    return false, ReachedAmount, NeededAmount;
end

---
-- Prüft, ob genug Gebäude vollständig dekoriert sind.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist = function( _PlayerID, _KnightTitle)
    if KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings == nil then
        return
    end
    local CityBuildings = {Logic.GetPlayerEntitiesInCategory(_PlayerID, EntityCategories.CityBuilding)}
    local NeededBuildingsWithDecoration = KnightTitleRequirements[_KnightTitle].FullDecoratedBuildings
    local BuildingsWithDecoration = 0

    for i=1, #CityBuildings do
        local BuildingID = CityBuildings[i]
        local AmountOfWealthGoodsAtBuilding = 0

        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Banner ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Sign  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Candle) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if Logic.GetBuildingWealthGoodState(BuildingID, Goods.G_Ornament  ) > 0 then
            AmountOfWealthGoodsAtBuilding = AmountOfWealthGoodsAtBuilding  + 1
        end
        if AmountOfWealthGoodsAtBuilding >= 4 then
            BuildingsWithDecoration = BuildingsWithDecoration + 1
        end
    end

    if BuildingsWithDecoration >= NeededBuildingsWithDecoration then
        return true, BuildingsWithDecoration, NeededBuildingsWithDecoration
    else
        return false, BuildingsWithDecoration, NeededBuildingsWithDecoration
    end
end

---
-- Prüft, ob der Spieler befördert werden kann.
--
-- @param[type=number] _PlayerID ID des Spielers
-- @param[type=number] _KnightTitle Nächster Titel
-- @within Originalfunktionen
-- @local
--
CanKnightBePromoted = function(_PlayerID, _KnightTitle)
    if _KnightTitle == nil then
        _KnightTitle = Logic.GetKnightTitle(_PlayerID) + 1;
    end

    if Logic.CanStartFestival(_PlayerID, 1) == true then
        if  KnightTitleRequirements[_KnightTitle] ~= nil
        and DoesNeededNumberOfSettlersForKnightTitleExist(_PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfGoodsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Headquarters) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Storehouse) ~= false
        and DoNeededSpecialBuildingUpgradeForKnightTitleExist( _PlayerID, _KnightTitle, EntityCategories.Cathedrals)  ~= false
        and DoNeededNumberOfRichBuildingsForKnightTitleExist( _PlayerID, _KnightTitle)  ~= false
        and DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfDecoratedBuildingsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededCityReputationForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoesNeededNumberOfGoodTypesForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNeededDiversityBuffForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoCustomFunctionForKnightTitleSucceed( _PlayerID, _KnightTitle) ~= false
        and DoNeededNumberOfConsumedGoodsForKnightTitleExist( _PlayerID, _KnightTitle) ~= false
        and DoNumberOfProductsInCategoryExist( _PlayerID, _KnightTitle) ~= false then
            return true;
        end
    end
    return false;
end

---
-- Der Spieler gewinnt das Spiel
-- @within Originalfunktionen
-- @local
--
VictroryBecauseOfTitle = function()
    QuestTemplate:TerminateEventsAndStuff();
    Victory(g_VictoryAndDefeatType.VictoryMissionComplete);
end

-- -------------------------------------------------------------------------- --
-- Aufstiegsbedingungen                                                       --
-- -------------------------------------------------------------------------- --

---
-- Definiert andere Aufstiegsbedingungen für den Spieler. Muss stets nach dem
-- Laden der QSB im globalen und lokalen Skript aufgerufen werden!
--
-- Diese Funktion muss entweder in der QSB modifiziert oder sowohl im globalen
-- als auch im lokalen Skript überschrieben werden. Bei Modifikationen muss
-- das Schema für Aufstiegsbedingungen und Rechtevergabe immer beibehalten
-- werden.
--
-- @within Originalfunktionen
--
InitKnightTitleTables = function()
    KnightTitles = {}
    KnightTitles.Knight     = 0
    KnightTitles.Mayor      = 1
    KnightTitles.Baron      = 2
    KnightTitles.Earl       = 3
    KnightTitles.Marquees   = 4
    KnightTitles.Duke       = 5
    KnightTitles.Archduke   = 6

    -- ---------------------------------------------------------------------- --
    -- Rechte und Pflichten                                                   --
    -- ---------------------------------------------------------------------- --

    NeedsAndRightsByKnightTitle = {}

    -- Ritter ------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Knight] = {
        ActivateNeedForPlayer,
        {
            Needs.Nutrition,                                    -- Bedürfnis: Nahrung
            Needs.Medicine,                                     -- Bedürfnis: Medizin
        },
        ActivateRightForPlayer,
        {
            Technologies.R_Gathering,                           -- Recht: Rohstoffsammler
            Technologies.R_Woodcutter,                          -- Recht: Holzfäller
            Technologies.R_StoneQuarry,                         -- Recht: Steinbruch
            Technologies.R_HuntersHut,                          -- Recht: Jägerhütte
            Technologies.R_FishingHut,                          -- Recht: Fischerhütte
            Technologies.R_CattleFarm,                          -- Recht: Kuhfarm
            Technologies.R_GrainFarm,                           -- Recht: Getreidefarm
            Technologies.R_SheepFarm,                           -- Recht: Schaffarm
            Technologies.R_IronMine,                            -- Recht: Eisenmine
            Technologies.R_Beekeeper,                           -- Recht: Imkerei
            Technologies.R_HerbGatherer,                        -- Recht: Kräutersammler
            Technologies.R_Nutrition,                           -- Recht: Nahrung
            Technologies.R_Bakery,                              -- Recht: Bäckerei
            Technologies.R_Dairy,                               -- Recht: Käserei
            Technologies.R_Butcher,                             -- Recht: Metzger
            Technologies.R_SmokeHouse,                          -- Recht: Räucherhaus
            Technologies.R_Clothes,                             -- Recht: Kleidung
            Technologies.R_Tanner,                              -- Recht: Ledergerber
            Technologies.R_Weaver,                              -- Recht: Weber
            Technologies.R_Construction,                        -- Recht: Konstruktion
            Technologies.R_Wall,                                -- Recht: Mauer
            Technologies.R_Pallisade,                           -- Recht: Palisade
            Technologies.R_Trail,                               -- Recht: Pfad
            Technologies.R_KnockDown,                           -- Recht: Abriss
            Technologies.R_Sermon,                              -- Recht: Predigt
            Technologies.R_SpecialEdition,                      -- Recht: Special Edition
            Technologies.R_SpecialEdition_Pavilion,             -- Recht: Pavilion AeK SE
        }
    }

    -- Landvogt ----------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Mayor] = {
        ActivateNeedForPlayer,
        {
            Needs.Clothes,                                      -- Bedürfnis: KLeidung
        },
        ActivateRightForPlayer, {
            Technologies.R_Hygiene,                             -- Recht: Hygiene
            Technologies.R_Soapmaker,                           -- Recht: Seifenmacher
            Technologies.R_BroomMaker,                          -- Recht: Besenmacher
            Technologies.R_Military,                            -- Recht: Militär
            Technologies.R_SwordSmith,                          -- Recht: Schwertschmied
            Technologies.R_Barracks,                            -- Recht: Schwertkämpferkaserne
            Technologies.R_Thieves,                             -- Recht: Diebe
            Technologies.R_SpecialEdition_StatueFamily,         -- Recht: Familienstatue Aek SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Baron -------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Baron] = {
        ActivateNeedForPlayer,
        {
            Needs.Hygiene,                                      -- Bedürfnis: Hygiene
        },
        ActivateRightForPlayer, {
            Technologies.R_Medicine,                            -- Recht: Medizin
            Technologies.R_BowMaker,                            -- Recht: Bogenmacher
            Technologies.R_BarracksArchers,                     -- Recht: Bogenschützenkaserne
            Technologies.R_Entertainment,                       -- Recht: Unterhaltung
            Technologies.R_Tavern,                              -- Recht: Taverne
            Technologies.R_Festival,                            -- Recht: Fest
            Technologies.R_Street,                              -- Recht: Straße
            Technologies.R_SpecialEdition_Column,               -- Recht: Säule AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Graf --------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Earl] = {
        ActivateNeedForPlayer,
        {
            Needs.Entertainment,                                -- Bedürfnis: Unterhaltung
            Needs.Prosperity,                                   -- Bedürfnis: Reichtum
        },
        ActivateRightForPlayer, {
            Technologies.R_SiegeEngineWorkshop,                 -- Recht: Belagerungswaffenschmied
            Technologies.R_BatteringRam,                        -- Recht: Ramme
            Technologies.R_Baths,                               -- Recht: Badehaus
            Technologies.R_AmmunitionCart,                      -- Recht: Munitionswagen
            Technologies.R_Prosperity,                          -- Recht: Reichtum
            Technologies.R_Taxes,                               -- Recht: Steuern einstellen
            Technologies.R_Ballista,                            -- Recht: Mauerkatapult
            Technologies.R_SpecialEdition_StatueSettler,        -- Recht: Siedlerstatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Marquees ----------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Marquees] = {
        ActivateNeedForPlayer,
        {
            Needs.Wealth,                                       -- Bedürfnis: Verschönerung
        },
        ActivateRightForPlayer, {
            Technologies.R_Theater,                             -- Recht: Theater
            Technologies.R_Wealth,                              -- Recht: Schmuckgebäude
            Technologies.R_BannerMaker,                         -- Recht: Bannermacher
            Technologies.R_SiegeTower,                          -- Recht: Belagerungsturm
            Technologies.R_SpecialEdition_StatueProduction,     -- Recht: Produktionsstatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Herzog ------------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Duke] = {
        ActivateNeedForPlayer, nil,
        ActivateRightForPlayer, {
            Technologies.R_Catapult,                            -- Recht: Katapult
            Technologies.R_Carpenter,                           -- Recht: Tischler
            Technologies.R_CandleMaker,                         -- Recht: Kerzenmacher
            Technologies.R_Blacksmith,                          -- Recht: Schmied
            Technologies.R_SpecialEdition_StatueDario,          -- Recht: Dariostatue AeK SE
        },
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }

    -- Erzherzog ---------------------------------------------------------------

    NeedsAndRightsByKnightTitle[KnightTitles.Archduke] = {
        ActivateNeedForPlayer,nil,
        ActivateRightForPlayer, {
            Technologies.R_Victory                              -- Sieg
        },
        -- VictroryBecauseOfTitle,                              -- Sieg wegen Titel
        StartKnightsPromotionCelebration                        -- Beförderungsfest aktivieren
    }



    -- Reich des Ostens --------------------------------------------------------

    if g_GameExtraNo >= 1 then
        local TechnologiesTableIndex = 4;
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Cistern);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Brazier);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][TechnologiesTableIndex],Technologies.R_Beautification_Shrine);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Baron][TechnologiesTableIndex],Technologies.R_Beautification_Pillar);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_StoneBench);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][TechnologiesTableIndex],Technologies.R_Beautification_Vase);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Marquees][TechnologiesTableIndex],Technologies.R_Beautification_Sundial);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Archduke][TechnologiesTableIndex],Technologies.R_Beautification_TriumphalArch);
        table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Duke][TechnologiesTableIndex],Technologies.R_Beautification_VictoryColumn);
    end



    -- ---------------------------------------------------------------------- --
    -- Bedingungen                                                            --
    -- ---------------------------------------------------------------------- --

    KnightTitleRequirements = {}

    -- Ritter ------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Mayor] = {}
    KnightTitleRequirements[KnightTitles.Mayor].Headquarters = 1
    KnightTitleRequirements[KnightTitles.Mayor].Settlers = 10
    KnightTitleRequirements[KnightTitles.Mayor].Products = {
        {GoodCategories.GC_Clothes, 6},
    }

    -- Baron -------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Baron] = {}
    KnightTitleRequirements[KnightTitles.Baron].Settlers = 30
    KnightTitleRequirements[KnightTitles.Baron].Headquarters = 1
    KnightTitleRequirements[KnightTitles.Baron].Storehouse = 1
    KnightTitleRequirements[KnightTitles.Baron].Cathedrals = 1
    KnightTitleRequirements[KnightTitles.Baron].Products = {
        {GoodCategories.GC_Hygiene, 12},
    }

    -- Graf --------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Earl] = {}
    KnightTitleRequirements[KnightTitles.Earl].Settlers = 50
    KnightTitleRequirements[KnightTitles.Earl].Headquarters = 2
    KnightTitleRequirements[KnightTitles.Earl].Products = {
        {GoodCategories.GC_Entertainment, 18},
    }

    -- Marquess ----------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Marquees] = {}
    KnightTitleRequirements[KnightTitles.Marquees].Settlers = 70
    KnightTitleRequirements[KnightTitles.Marquees].Headquarters = 2
    KnightTitleRequirements[KnightTitles.Marquees].Storehouse = 2
    KnightTitleRequirements[KnightTitles.Marquees].Cathedrals = 2
    KnightTitleRequirements[KnightTitles.Marquees].RichBuildings = 20

    -- Herzog ------------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Duke] = {}
    KnightTitleRequirements[KnightTitles.Duke].Settlers = 90
    KnightTitleRequirements[KnightTitles.Duke].Storehouse = 2
    KnightTitleRequirements[KnightTitles.Duke].Cathedrals = 2
    KnightTitleRequirements[KnightTitles.Duke].Headquarters = 3
    KnightTitleRequirements[KnightTitles.Duke].DecoratedBuildings = {
        {Goods.G_Banner, 9 },
    }

    -- Erzherzog ---------------------------------------------------------------

    KnightTitleRequirements[KnightTitles.Archduke] = {}
    KnightTitleRequirements[KnightTitles.Archduke].Settlers = 150
    KnightTitleRequirements[KnightTitles.Archduke].Storehouse = 3
    KnightTitleRequirements[KnightTitles.Archduke].Cathedrals = 3
    KnightTitleRequirements[KnightTitles.Archduke].Headquarters = 3
    KnightTitleRequirements[KnightTitles.Archduke].RichBuildings = 30
    KnightTitleRequirements[KnightTitles.Archduke].FullDecoratedBuildings = 30

    -- Einstellungen Aktivieren
    CreateTechnologyKnightTitleTable()
end

