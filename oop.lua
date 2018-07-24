---
-- Kopiert die Quelltabelle rekursiv in die Zieltabelle. Ist ein Wert im
-- Ziel vorhanden, wird er nicht überschrieben.
--
-- @param _Source [table] Quelltabelle
-- @param _Dest [table] Zieltabelle
-- @return [table] Kindklasse
--
function copy(_Source, _Dest)
    _Dest = _Dest or {};
    assert(type(_Source) == "table")
    assert(type(_Dest) == "table")

    for k, v in pairs(_Source) do
        if type(v) == "table" then
            _Dest[k] = _Dest[k] or {};
            for kk, vv in pairs(copy(v)) do
                _Dest[k][kk] = _Dest[k][kk] or vv;
            end
        else
            _Dest[k] = _Dest[k] or v;
        end
    end
    return _Dest;
end

---
-- Fügt einer Table Magic Methods hinzu und macht sie zur Klasse.
--
-- @param _Table [table] Referenz auf Table
-- @return [table] Klasse
--
function class(_Table)
    -- __className hinzufügen
    for k, v in pairs(_G) do 
        if v == _Table then
            _Table.__className = k;
        end
    end
    
    -- __construct hinzufügen
    _Table.__construct = _Table.__construct or function(self) end

    -- __clone hinzufügen
    _Table.__clone = _Table.__clone or function(self)
        return copy(self);
    end

    -- __toString hinzufügen
    _Table.__toString = _Table.__toString or function(self)
        local s = "";
        for k, v in pairs(self) do
            s = s .. k .. ":" .. tostring(v) .. ";";
        end
        return "{" ..s.. "}";
    end

    -- __equals hinzufügen
    _Table.__equals = _Table.__equals or function(self, _Other)
        -- Anderes Objekt muss table sein.
        if type(_Other) ~= "table" then 
            return false;
        end
        -- Gehe Inhalt durch
        for k, v in pairs(self) do
            if v ~= _Other[k] then
                return false;
            end
        end
        return true;
    end

    return _Table;
end

---
-- Erzeugt eine Ableitung einer Klasse
--
-- @param _Parent [table] Referenz auf Klasse
-- @return [table] Kindklasse
--
function inherit(_Class, _Parent)
    local c = copy(_Parent, _Class);
    c.parent = _Parent;
    return class(c);
end

---
-- Erzeugt eine Instanz der Klasse.
--
-- @param _Class [table] Referenz auf Klasse
-- @param ... [mixed] Argumente des Konstruktors
-- @return [table] Instanz der Klasse
--
function new(_Class, ...)
    -- Instanz erzeugen
    local instance = copy(_Class);
    -- Parent instanzieren
    if instance.parent then
        instance.parent = new(instance.parent, ...);
    end
    instance:__construct(...);
    return instance;
end


Father = {};
function Father:__construct(_Name)
    self.Name = _Name;
end
function Father:foo()
    print ("bar");
end
Father = class(Father);

Son = {};
function Son:foo()
    print ("muh");
end
Son = inherit(Son, Father);

-- ------------------------------

MyFather = new(Father, "Ingolf");
MyFather:foo();

MySon = new(Son, "Horst");
NotMySon = new(Son, "Günter");

MySon:foo();

print(MySon:__toString());
print(NotMySon:__toString());

print(MySon:__equals(MySon));
print(MySon:__equals(NotMySon));