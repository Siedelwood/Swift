-- -------------------------------------------------------------------------- --
-- Module Text Tools                                                          --
-- -------------------------------------------------------------------------- --

ModuleTextTools = {
    Properties = {
        Name = "ModuleTextTools",
    },

    m_Colors = {
        red     = "{@color:255,80,80,255}",
        blue    = "{@color:104,104,232,255}",
        yellow  = "{@color:255,255,80,255}",
        green   = "{@color:80,180,0,255}",
        white   = "{@color:255,255,255,255}",
        black   = "{@color:0,0,0,255}",
        grey    = "{@color:140,140,140,255}",
        azure   = "{@color:0,160,190,255}",
        orange  = "{@color:255,176,30,255}",
        amber   = "{@color:224,197,117,255}",
        violet  = "{@color:180,100,190,255}",
        pink    = "{@color:255,170,200,255}",
        scarlet = "{@color:190,0,0,255}",
        magenta = "{@color:190,0,89,255}",
        olive   = "{@color:74,120,0,255}",
        sky     = "{@color:145,170,210,255}",
        tooltip = "{@color:51,51,120,255}",
        lucid   = "{@color:0,0,0,0}"
    },

    m_Placeholders = {
        Names = {},
        EntityTypes = {},
    }
};

function ModuleTextTools:OnGameStart()
    Swift.GetTextOfDesiredLanguage = function(self, _Table)
        return ModuleTextTools:Localize(_Table);
    end
end

-- Swift:GetTextOfDesiredLanguage

function ModuleTextTools:Note(_Text)
    _Text = self:ConvertPlaceholders(self:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.DEBUG_AddNote(_Text);
    else
        GUI.AddNote(_text);
    end
end

function ModuleTextTools:StaticNote(_Text)
    _Text = self:ConvertPlaceholders(self:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format([[GUI.AddStaticNote("%s")]], _Text));
        return;
    end
    GUI.AddStaticNote(_text);
end

function ModuleTextTools:Message(_Text)
    _Text = self:ConvertPlaceholders(self:Localize(_Text));
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState(string.format([[Message("%s")]], _Text));
        return;
    end
    Message(_Text);
end

function ModuleTextTools:ClearNotes()
    if Swift:IsGlobalEnvironment() then
        Logic.ExecuteInLuaLocalState([[GUI.ClearNotes()]]);
        return;
    end
    GUI.ClearNotes();
end

function ModuleTextTools:Localize(_Text)
    if type(_Text) ~= "table" or (_Text.de == nil or _Text.en == nil) then
        return tostring(_Text);
    end
    if _Text[self.m_Language] then
        return tostring(_Text[self.m_Language]);
    end
    if _Text.en then
        return tostring(_Text.en);
    end
    return tostring(_Text);
end

function ModuleTextTools:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{name:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{name:");
            Replacement = self.m_Placeholders.Names[Placeholder];
            _Text = Before .. self:Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        elseif _Text:find("{type:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{type:");
            Replacement = self.m_Placeholders.EntityTypes[Placeholder];
            _Text = Before .. self:Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

function ModuleTextTools:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

function ModuleTextTools:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(self.m_Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModules(ModuleTextTools);

