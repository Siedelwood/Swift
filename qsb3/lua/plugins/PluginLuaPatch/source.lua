-- Lua Improvements --------------------------------------------------------- --

PluginLuaPatch = {
    Name = "PluginLuaPatch",
};

function PluginLuaPatch:OnGameStart()
    self:OverrideTable();
    self:OverrideString();
end

function PluginLuaPatch:OnSaveGameLoaded()
    self:OverrideTable();
    self:OverrideString();
end

function PluginLuaPatch:OverrideString()
    -- TODO: Implement!
end

function PluginLuaPatch:OverrideTable()
    ---
    -- TODO: Add doc
    -- @within table
    --
    table.contains = function (t, e)
        for k, v in ipairs(t) do
            if v == e then return true; end
        end
        return false;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.copy = function (t1, t2)
        t2 = t2 or {};
        for k, v in pairs(t1) do
            if "table" == type(v) then
                t2[k] = t2[k] or {};
                for kk, vv in pairs(table.copy(v, t2[k])) do
                    t2[k][kk] = t2[k][kk] or vv;
                end
            else
                t2[k] = v;
            end
        end
        return t2;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.invert = function (t1)
        local t2 = {};
        for i= #t1, 1, -1 do
            table.insert(t2, t1[i]);
        end
        return t2;
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.push = function (t, e)
        table.insert(t, 1, e);
    end

    ---
    -- TODO: Add doc
    -- @within table
    --
    table.pop = function (t, e)
        return table.remove(t, 1);
    end
end

-- -------------------------------------------------------------------------- --

Symfonia:RegisterPlugins(PluginLuaPatch);

