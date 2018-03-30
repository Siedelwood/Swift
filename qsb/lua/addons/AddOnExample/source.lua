-- This is just a Test! Do not intent to use this in your maps! This will
-- be removed after tests are done!

AddOnExample = {
    Global = {
        Data = {}
    },
    Local = {
        Data = {},
    },
}

function AddOnExample.Global:Install()
    --API.Info("Global: AddOnExample was installed!");
end

function AddOnExample.Global:Bockwurst()
    --API.Info("Global: Bockwurst is realy delicious!");
end

function AddOnExample.Local:Install()
    --API.Info("Local: AddOnExample was installed!");
end

function AddOnExample.Local:Bockwurst()
    --API.Info("Local: Bockwurst is realy delicious!");
end

Core:RegisterAddOn("AddOnExample");