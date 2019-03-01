function Tokenizer(_Text)
    _Text = _Text:gsub("%s+", " ");
    local Tokens = {};
    local TempTokens = {};
    local Text = _Text;
    while (true) do
        local s, e = Text:find(" ");
        if not s then
            table.insert(TempTokens, Text);
            break;
        end
        local NewToken = Text:sub(1, s-1);
        if NewToken:find("}") then
            for i= #NewToken, 1, -1 do
                local Char = NewToken:sub(i, i);
                if Char == "}" then
                    table.insert(TempTokens, NewToken:sub(1, i));
                    table.insert(TempTokens, NewToken:sub(i+1));
                    break;
                end
            end
        else
            table.insert(TempTokens, NewToken);
        end
        table.insert(TempTokens, " ");
        Text = Text:sub(e+1);
    end

    for i= 1, #TempTokens, 1 do
        if TempTokens[i] == " " or string.find(TempTokens[i], "{") then
            table.insert(Tokens, TempTokens[i]);
        else
            local Index = 1;
            while (Index <= #TempTokens[i]) do
                if string.byte(string.sub(TempTokens[i], Index, Index)) == 195 then
                    local lowByte  = string.byte(string.sub(TempTokens[i], Index, Index));
                    local highByte = string.byte(string.sub(TempTokens[i], Index+1, Index+1));
                    table.insert(Tokens, "\\" ..lowByte.. "\\" ..highByte); 
                    Index = Index +1;
                else
                    table.insert(Tokens, string.sub(TempTokens[i], Index, Index)); 
                end
                Index = Index +1;
            end
        end
    end
    return Tokens;
end

local Text = "Ich möchte Umlaute testen.";
local Tokens = Tokenizer(Text);
print (unpack(Tokens));