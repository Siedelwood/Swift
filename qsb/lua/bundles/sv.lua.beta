-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia BundleEntityScriptingValues                                  # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- 
--
-- @within Modulbeschreibung
-- @set sort=true
--
BundleEntityScriptingValues = {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --



-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

BundleEntityScriptingValues = {
    Global = {
        Data = {},
    },
    Local = {
        Data = {},
    },
}

-- -------------------------------------------------------------------------- --

function BundleEntityScriptingValues.Global:Install()
    local EntityID = Logic.CreateEntity(Entities.XD_ScriptEntity, 1, 1, 0, 8);
    self:InitAdressEntity(EntityID);
end

-- -------------------------------------------------------------------------- --

---
-- Setzt den Wert, auf den der Pointer zeigt
--
-- @param _entityID [number] Entity
-- @param _indextable [table] Indextabelle
-- @param _value [number] Wert
--
function BundleEntityScriptingValues.Global:SetPointerValue(_entityID, _indextable, _value)
    local IndexTable = _indextable;
    local Svbn = Logic.GetEntityScriptingValue(_entityID,IndexTable[1]);
    local Adress1 = BigNum.new(""..Svbn);
    local Adress2 = BigNum.new();
    local Count = table.getn(IndexTable);
    for i = 2,Count do
        BigNum.add(Adress1,BigNum.new(""..IndexTable[i]*4),Adress2);
        if i < Count then
            Adress1 = BigNum.new(self:GetValueByAdress(BigNum.mt.tostring(Adress2)));
        end
    end
    self:SetValueByAdress(BigNum.mt.tostring(Adress2),_value);
end

---
-- Gibt den Wert zurück, auf den der Pointer zeigt.
--
-- @param _entityID [number] Entity
-- @param _indextable [table] Indextabelle
-- @return [number] Wert
--
function BundleEntityScriptingValues.Global:GetPointerValue(_entityID, _indextable)
    local IndexTable = _indextable;
    local Svbn = Logic.GetEntityScriptingValue(_entityID,IndexTable[1]);
    local Adress1 = BigNum.new(""..Svbn);
    local Adress2 = BigNum.new();
    local Count = table.getn(IndexTable);
    for i = 2,Count do
        BigNum.add(Adress1,BigNum.new(""..IndexTable[i]*4),Adress2);
        if i < Count then
            Adress1 = BigNum.new(self:GetValueByAdress(BigNum.mt.tostring(Adress2)));
        end
    end
    return self:GetValueByAdress(BigNum.mt.tostring(Adress2));
end

---
-- Gibt die Scripting Value auf der Speicheradresse zurück.
--
-- @param _adress [string] Adresse
-- @return [number] Wert
--
function BundleEntityScriptingValues.Global:GetValueByAdress(_adress)
    local SVi = _adress;
    local SVibn = BigNum.new(_adress);
    if string.len(BigNum.mt.tostring(SVibn)) > 9 or tonumber(BigNum.mt.tostring(SVibn)) <= 0 then
        return SVi;
    end
    local input = BigNum.new();
    BigNum.sub(SVibn,ZO,input);
    local ergebnis = BigNum.new();
    local rest = BigNum.new();
    BigNum.div(input, BigNum.new("4"), ergebnis, rest);
    if tonumber(BigNum.mt.tostring(rest)) == 0 then
        SVi = Logic.GetEntityScriptingValue(AdressEntity,tonumber(BigNum.mt.tostring(ergebnis)));
    end
    return SVi
end

---
-- Setzt die Scripting Value anhand einer Speicheradresse.
--
-- @param _adress [string] Adresse
-- @param _value [number] Wert
--
function BundleEntityScriptingValues.Global:SetValueByAdress(_adress, _value)
    local SVibn = BigNum.new(_adress);
    if string.len(BigNum.mt.tostring(SVibn)) > 9 or tonumber(BigNum.mt.tostring(SVibn)) <= 0 then
        return false;
    end
    local input = BigNum.new();
    BigNum.sub(SVibn,ZO,input);
    local ergebnis = BigNum.new();
    local rest = BigNum.new();
    BigNum.div(input, BigNum.new("4"), ergebnis, rest);
    if tonumber(BigNum.mt.tostring(rest)) == 0 then
        Logic.SetEntityScriptingValue(AdressEntity,tonumber(BigNum.mt.tostring(ergebnis)),_value);
    end
end

---
-- FIXME: What is my value in S6?
--
-- @param _entity [string|number] Adress Entity
-- @param _callback [function] Callback
--
function BundleEntityScriptingValues.Global:InitAdressEntity(_entity, _callback)
    InitAdressEntityJob = function()
        local eID = GetID(_entity);
        local sv67 = Logic.GetEntityScriptingValue(eID, 67);
        if sv67 < 10000 then
            return;
        else
            local SV67bn = BigNum.new(sv67);
            AdressEntity = eID;
            ZO = BigNum.new();
            BigNum.add(SV67bn, BigNum.new("232"), ZO);
            if _callback then
                _callback();
            end
            return true;
        end
    end
    StartSimpleHiResJob("InitAdressEntityJob");
end

-- -------------------------------------------------------------------------- --

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param a	[number] Zahl
-- @param b	[number] Modul
-- @return [number] qmod der Zahl
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Global:qmod(a, b)
    return a - math.floor(a/b)*b;
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param num [number] Integer
-- @return [number] Integer als Float
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Global:Int2Float(num)
    if(num == 0) then return 0; end
    local sign = 1;
    if(num < 0) then num = 2147483648 + num; sign = -1; end
    local frac = self:qmod(num, 8388608);
    local headPart = (num-frac)/8388608;
    local expNoSign = self:qmod(headPart, 256);
    local exp = expNoSign-127;
    local fraction = 1;
    local fp = 0.5;
    local check = 4194304;
    for i = 23, 0, -1 do
        if(frac - check) > 0 then fraction = fraction + fp; frac = frac - check; end
        check = check / 2; fp = fp / 2;
    end
    return fraction * math.pow(2, exp) * sign;
end

---
-- Gibt den Integer als Bits zurück
--
-- @param num [number] Bits
-- @return [table] Table mit Bits
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Global:bitsInt(num)
    local t={};
    while num>0 do
        rest=self:qmod(num, 2); table.insert(t,1,rest); num=(num-rest)/2;
    end
    table.remove(t, 1);
    return t;
end

---
-- Stellt eine Zahl als eine Folge von Bits in einer Table dar.
--
-- @param num [integer] Integer
-- @param t	  [table] Table
-- @return [table] Table mit Bits
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Global:bitsFrac(num, t)
    for i = 1, 48 do
        num = num * 2;
        if(num >= 1) then table.insert(t, 1); num = num - 1; else table.insert(t, 0); end
        if(num == 0) then return t; end
    end
    return t;
end

---
-- Konvertiert eine Dezimalzahl in eine Ganzzahl.
--
-- @param fval [number] Float
-- @return [number] Float als Integer
-- @within BundleEntityScriptingValues
-- @local
--
function BundleEntityScriptingValues.Global:Float2Int(fval)
    if(fval == 0) then return 0; end
    local signed = false;
    if(fval < 0) then signed = true; fval = fval * -1; end
    local outval = 0;
    local bits;
    local exp = 0;
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:bitsInt(intPart); exp = table.getn(bits); self:bitsFrac(fracPart, bits);
    else
        bits = {}; self:bitsFrac(fval, bits);
        while(bits[1] == 0) do exp = exp - 1; table.remove(bits, 1); end
        exp = exp - 1;
        table.remove(bits, 1);
    end
    local bitVal = 4194304; local start = 1;
    for bpos = start, 23 do
        local bit = bits[bpos];
        if(not bit) then break; end
        if(bit == 1) then outval = outval + bitVal; end
        bitVal = bitVal / 2;
    end
    outval = outval + (exp+127)*8388608;
    if(signed) then outval = outval - 2147483648 end
    return outval;
end

-- -------------------------------------------------------------------------- --

function BundleEntityScriptingValues.Local:Install()
end

-- -------------------------------------------------------------------------- --

Core:RegisterBundle("BundleEntityScriptingValues");

-- -------------------------------------------------------------------------- --
-- Big Numbers library for Lua                                                --
--   by Frederico Macedo Pessoa and  Marco Serpa Molinaro                     --
--   Version 1.1                                                              --
--   (Minified)                                                               --
-- -------------------------------------------------------------------------- --

RADIX=10^7;RADIX_LEN=math.floor(math.log10(RADIX))
BigNum={}BigNum.mt={}
function BigNum.new(QDnlt)local LmcA2auZ={}
setmetatable(LmcA2auZ,BigNum.mt)BigNum.change(LmcA2auZ,QDnlt)return LmcA2auZ end
function BigNum.mt.sub(Q,ZA)local _IQQ=BigNum.new()local XpkjA=BigNum.new(Q)
local pVRj=BigNum.new(ZA)BigNum.sub(XpkjA,pVRj,_IQQ)return _IQQ end
function BigNum.mt.add(fuZ3z86,er)local DFb100j=BigNum.new()
local XL_=BigNum.new(fuZ3z86)local WYdR=BigNum.new(er)BigNum.add(XL_,WYdR,DFb100j)
return DFb100j end
function BigNum.mt.mul(QKKks_zt,Are7xU)local yxjl=BigNum.new()
local ZG=BigNum.new(QKKks_zt)local Vu0cCAf=BigNum.new(Are7xU)
BigNum.mul(ZG,Vu0cCAf,yxjl)return yxjl end
function BigNum.mt.div(q,kP7O5)local lqT={}local mP3mlD={}local PrPyxMK=BigNum.new()
local tczrIB=BigNum.new()lqT=BigNum.new(q)mP3mlD=BigNum.new(kP7O5)
BigNum.div(lqT,mP3mlD,PrPyxMK,tczrIB)return PrPyxMK,tczrIB end
function BigNum.mt.tostring(a)local wqU76o=0;local LB1Z=0;local N9L=""local hDc_M=""
if a==nil then return"nil"elseif a.len>0 then
for wqU76o=a.len-2,0,-1 do for LB1Z=0,
RADIX_LEN-string.len(a[wqU76o])-1 do
hDc_M=hDc_M..'0'end;hDc_M=hDc_M..a[wqU76o]end;hDc_M=a[a.len-1]..hDc_M;if a.signal=='-'then
hDc_M=a.signal..hDc_M end;return hDc_M else return""end end
function BigNum.mt.pow(qW0lRiD1,iD1IUx)local JLCOx_ak=BigNum.new(qW0lRiD1)
local hPQ=BigNum.new(iD1IUx)return BigNum.pow(JLCOx_ak,hPQ)end
function BigNum.mt.eq(R1FIoQI,NsoTwDs)local HGli=BigNum.new(R1FIoQI)
local iy=BigNum.new(NsoTwDs)return BigNum.eq(HGli,iy)end
function BigNum.mt.lt(m6SCS0,NUhYw6R4)local Hv=BigNum.new(m6SCS0)
local Ch=BigNum.new(NUhYw6R4)return BigNum.lt(Hv,Ch)end
function BigNum.mt.le(urkh,zhzpBSx)local rHSjalVy=BigNum.new(urkh)
local TjhsnP=BigNum.new(zhzpBSx)return BigNum.le(rHSjalVy,TjhsnP)end
function BigNum.mt.unm(t5jzEd9)local JZAU2=BigNum.new(t5jzEd9)if JZAU2.signal=='+'then
JZAU2.signal='-'else JZAU2.signal='+'end;return JZAU2 end;BigNum.mt.__metatable="hidden"
BigNum.mt.__tostring=BigNum.mt.tostring;BigNum.mt.__add=BigNum.mt.add
BigNum.mt.__sub=BigNum.mt.sub;BigNum.mt.__mul=BigNum.mt.mul
BigNum.mt.__div=BigNum.mt.div;BigNum.mt.__pow=BigNum.mt.pow
BigNum.mt.__unm=BigNum.mt.unm;BigNum.mt.__eq=BigNum.mt.eq
BigNum.mt.__le=BigNum.mt.le;BigNum.mt.__lt=BigNum.mt.lt
setmetatable(BigNum.mt,{__index="inexistent field",__newindex="not available",__metatable="hidden"})
function BigNum.add(zPXTTg,seMLr,qX)local h_8=0;local xL7OTb=0;local w8T3f=0;local K='+'local qL=0
if zPXTTg==nil or seMLr==nil or
qX==nil then
error("Function BigNum.add: parameter nil")elseif zPXTTg.signal=='-'and seMLr.signal=='+'then
zPXTTg.signal='+'BigNum.sub(seMLr,zPXTTg,qX)if not rawequal(zPXTTg,qX)then
zPXTTg.signal='-'end;return 0 elseif
zPXTTg.signal=='+'and seMLr.signal=='-'then seMLr.signal='+'BigNum.sub(zPXTTg,seMLr,qX)if not
rawequal(seMLr,qX)then seMLr.signal='-'end;return 0 elseif
zPXTTg.signal=='-'and seMLr.signal=='-'then K='-'end;qL=qX.len;if zPXTTg.len>seMLr.len then h_8=zPXTTg.len else h_8=seMLr.len
zPXTTg,seMLr=seMLr,zPXTTg end
for xL7OTb=0,h_8-1 do
if seMLr[xL7OTb]~=nil then qX[xL7OTb]=
zPXTTg[xL7OTb]+seMLr[xL7OTb]+w8T3f else qX[xL7OTb]=
zPXTTg[xL7OTb]+w8T3f end
if qX[xL7OTb]>=RADIX then qX[xL7OTb]=qX[xL7OTb]-RADIX;w8T3f=1 else w8T3f=0 end end;if w8T3f==1 then qX[h_8]=1 end;qX.len=h_8+w8T3f;qX.signal=K;for xL7OTb=qX.len,qL do qX[xL7OTb]=
nil end;return 0 end
function BigNum.sub(vfIyB,quNsijN,QUh2tc)local qboV=0;local nSBOx7=0;local u=0;local K=0
if
vfIyB==nil or quNsijN==nil or QUh2tc==nil then error("Function BigNum.sub: parameter nil")elseif
vfIyB.signal=='-'and quNsijN.signal=='+'then vfIyB.signal='+'
BigNum.add(vfIyB,quNsijN,QUh2tc)QUh2tc.signal='-'
if not rawequal(vfIyB,QUh2tc)then vfIyB.signal='-'end;return 0 elseif vfIyB.signal=='-'and quNsijN.signal=='-'then
vfIyB.signal='+'quNsijN.signal='+'BigNum.sub(quNsijN,vfIyB,QUh2tc)if not
rawequal(vfIyB,QUh2tc)then vfIyB.signal='-'end;if not
rawequal(quNsijN,QUh2tc)then quNsijN.signal='-'end;return 0 elseif
vfIyB.signal=='+'and quNsijN.signal=='-'then quNsijN.signal='+'
BigNum.add(vfIyB,quNsijN,QUh2tc)
if not rawequal(quNsijN,QUh2tc)then quNsijN.signal='-'end;return 0 end
if BigNum.compareAbs(vfIyB,quNsijN)==2 then
BigNum.sub(quNsijN,vfIyB,QUh2tc)QUh2tc.signal='-'return 0 else qboV=vfIyB.len end;K=QUh2tc.len;QUh2tc.len=0
for nSBOx7=0,qboV-1 do
if quNsijN[nSBOx7]~=nil then QUh2tc[nSBOx7]=
vfIyB[nSBOx7]-quNsijN[nSBOx7]-u else QUh2tc[nSBOx7]=
vfIyB[nSBOx7]-u end;if QUh2tc[nSBOx7]<0 then
QUh2tc[nSBOx7]=RADIX+QUh2tc[nSBOx7]u=1 else u=0 end;if QUh2tc[nSBOx7]~=0 then QUh2tc.len=
nSBOx7+1 end end;QUh2tc.signal='+'
if QUh2tc.len==0 then QUh2tc.len=1;QUh2tc[0]=0 end;if u==1 then error("Error in function sub")end;for nSBOx7=QUh2tc.len,max(K,
qboV-1)do QUh2tc[nSBOx7]=nil end;return 0 end
function BigNum.mul(i1,zz1QI,kFTAh)local LBf=0;j=0;local dijn4Ph=BigNum.new()local CO1=0;local RlZo=0;local SUn=kFTAh.len
if
i1 ==nil or zz1QI==nil or kFTAh==nil then
error("Function BigNum.mul: parameter nil")elseif i1.signal~=zz1QI.signal then BigNum.mul(i1,-zz1QI,kFTAh)
kFTAh.signal='-'return 0 end;kFTAh.len=(i1.len)+ (zz1QI.len)for LBf=1,kFTAh.len do
kFTAh[LBf-1]=0 end;for LBf=kFTAh.len,SUn do kFTAh[LBf]=nil end
for LBf=0,i1.len-1
do
for Ib4=0,zz1QI.len-1 do
RlZo=(i1[LBf]*zz1QI[Ib4]+RlZo)RlZo=RlZo+kFTAh[LBf+Ib4]
kFTAh[LBf+Ib4]=math.mod(RlZo,RADIX)CO1=kFTAh[LBf+Ib4]RlZo=math.floor(RlZo/RADIX)end;if RlZo~=0 then kFTAh[LBf+zz1QI.len]=RlZo end
RlZo=0 end;for LBf=kFTAh.len-1,1,-1 do if kFTAh[LBf]~=nil and kFTAh[LBf]~=0 then break else kFTAh[LBf]=
nil end
kFTAh.len=kFTAh.len-1 end;return 0 end
function BigNum.div(fjV1G2,Do,_,TqYJ4)local DI=BigNum.new()local b=BigNum.new()
local E=BigNum.new("1")local KMw7_i1s=BigNum.new("0")
if
BigNum.compareAbs(Do,KMw7_i1s)==0 then error("Function BigNum.div: Division by zero")end
if
fjV1G2 ==nil or Do==nil or _==nil or TqYJ4 ==nil then error("Function BigNum.div: parameter nil")elseif
fjV1G2.signal=="+"and Do.signal=="-"then Do.signal="+"
BigNum.div(fjV1G2,Do,_,TqYJ4)Do.signal="-"_.signal="-"return 0 elseif
fjV1G2.signal=="-"and Do.signal=="+"then fjV1G2.signal="+"BigNum.div(fjV1G2,Do,_,TqYJ4)
fjV1G2.signal="-"if TqYJ4 <KMw7_i1s then BigNum.add(_,E,_)
BigNum.sub(Do,TqYJ4,TqYJ4)end;_.signal="-"return 0 elseif fjV1G2.signal=="-"and
Do.signal=="-"then fjV1G2.signal="+"Do.signal="+"
BigNum.div(fjV1G2,Do,_,TqYJ4)fjV1G2.signal="-"if TqYJ4 <KMw7_i1s then BigNum.add(_,E,_)
BigNum.sub(Do,TqYJ4,TqYJ4)end;Do.signal="-"return 0 end;DI.len=fjV1G2.len-Do.len-1
BigNum.change(_,"0")BigNum.change(TqYJ4,"0")
BigNum.copy(fjV1G2,TqYJ4)
while(BigNum.compareAbs(TqYJ4,Do)~=2)do
if
TqYJ4[TqYJ4.len-1]>=Do[Do.len-1]then
BigNum.put(DI,math.floor(TqYJ4[TqYJ4.len-1]/Do[
Do.len-1]),TqYJ4.len-Do.len)DI.len=TqYJ4.len-Do.len+1 else
BigNum.put(DI,math.floor(
(
TqYJ4[TqYJ4.len-1]*RADIX+TqYJ4[TqYJ4.len-2])/Do[Do.len-1]),
TqYJ4.len-Do.len-1)DI.len=TqYJ4.len-Do.len end
if TqYJ4.signal~=Do.signal then DI.signal="-"else DI.signal="+"end;BigNum.add(DI,_,_)DI=DI*Do
BigNum.sub(TqYJ4,DI,TqYJ4)end
if TqYJ4.signal=='-'then decr(_)BigNum.add(Do,TqYJ4,TqYJ4)end;return 0 end
function BigNum.pow(CQi,nHlJ)local lw4Q7kbl=BigNum.new(nHlJ)local IN=BigNum.new(1)
local QYf1=BigNum.new(CQi)local RfsnisO=BigNum.new("0")if nHlJ<RfsnisO then
error("Function BigNum.exp: domain error")elseif nHlJ==RfsnisO then return IN end
while 1 do
if
math.mod(lw4Q7kbl[0],2)==0 then lw4Q7kbl=lw4Q7kbl/2 else lw4Q7kbl=lw4Q7kbl/2;IN=QYf1*IN;if
lw4Q7kbl==RfsnisO then return IN end end;QYf1=QYf1*QYf1 end end;BigNum.exp=BigNum.pow
function BigNum.gcd(lvW2ga,T7RKP)local _L6Bs={}local SH={}local wU4wYbA9={}local fFeQcIM={}
local JEHSHPh3={}JEHSHPh3=BigNum.new("0")if
lvW2ga==JEHSHPh3 or T7RKP==JEHSHPh3 then return BigNum.new("1")end
_L6Bs=BigNum.new(lvW2ga)SH=BigNum.new(T7RKP)_L6Bs.signal='+'SH.signal='+'
wU4wYbA9=BigNum.new()fFeQcIM=BigNum.new()
while SH>JEHSHPh3 do
BigNum.div(_L6Bs,SH,wU4wYbA9,fFeQcIM)_L6Bs,SH,fFeQcIM=SH,fFeQcIM,_L6Bs end;return _L6Bs end;BigNum.mmc=BigNum.gcd
function BigNum.eq(bb,o5e6fP)if BigNum.compare(bb,o5e6fP)==0 then return
true else return false end end;function BigNum.lt(iq7ol,eMV)
if BigNum.compare(iq7ol,eMV)==2 then return true else return false end end
function BigNum.le(WDTNkTD,Oejsws)local CkD73N0=-1
CkD73N0=BigNum.compare(WDTNkTD,Oejsws)
if CkD73N0 ==0 or CkD73N0 ==2 then return true else return false end end
function BigNum.compareAbs(PlwhaRKJ,Caz4NM4Z)
if PlwhaRKJ==nil or Caz4NM4Z==nil then
error("Function compare: parameter nil")elseif PlwhaRKJ.len>Caz4NM4Z.len then return 1 elseif PlwhaRKJ.len<Caz4NM4Z.len then return 2 else
local XVxxx;for XVxxx=PlwhaRKJ.len-1,0,-1 do
if PlwhaRKJ[XVxxx]>Caz4NM4Z[XVxxx]then return 1 elseif
PlwhaRKJ[XVxxx]<Caz4NM4Z[XVxxx]then return 2 end end end;return 0 end
function BigNum.compare(hD,G5BuU5)local AfwsY=0
if hD==nil or G5BuU5 ==nil then
error("Funtion BigNum.compare: parameter nil")elseif hD.signal=='+'and G5BuU5.signal=='-'then return 1 elseif hD.signal=='-'and
G5BuU5.signal=='+'then return 2 elseif
hD.signal=='-'and G5BuU5.signal=='-'then AfwsY=1 end
if hD.len>G5BuU5.len then return 1+AfwsY elseif hD.len<G5BuU5.len then return 2-AfwsY else local T;for T=
hD.len-1,0,-1 do
if hD[T]>G5BuU5[T]then return 1+AfwsY elseif hD[T]<G5BuU5[T]then return 2-AfwsY end end end;return 0 end
function BigNum.copy(WZs,ITdz)
if WZs~=nil and ITdz~=nil then local AjfoUo;for AjfoUo=0,WZs.len-1 do
ITdz[AjfoUo]=WZs[AjfoUo]end;ITdz.len=WZs.len else
error("Function BigNum.copy: parameter nil")end end
function BigNum.change(Er9zidsB,X)local dR=0;local JFXtQwy=0;local X=X;local uMV17h0;local E2NZK=0
if Er9zidsB==nil then
error("BigNum.change: parameter nil")elseif type(Er9zidsB)~="table"then
error("BigNum.change: parameter error, type unexpected")elseif X==nil then Er9zidsB.len=1;Er9zidsB[0]=0;Er9zidsB.signal="+"elseif
type(X)=="table"and X.len~=nil then
for WNWWe=0,X.len do Er9zidsB[WNWWe]=X[WNWWe]end;if X.signal~='-'and X.signal~='+'then Er9zidsB.signal='+'else
Er9zidsB.signal=X.signal end;E2NZK=Er9zidsB.len
Er9zidsB.len=X.len elseif type(X)=="string"or type(X)=="number"then
if
string.sub(X,1,1)=='+'or string.sub(X,1,1)=='-'then
Er9zidsB.signal=string.sub(X,1,1)X=string.sub(X,2)else Er9zidsB.signal='+'end;X=string.gsub(X," ","")local zMzjn3lk=string.find(X,"e")
if zMzjn3lk~=
nil then X=string.gsub(X,"%.","")
local Trkkpmd=string.sub(X,zMzjn3lk+1)Trkkpmd=tonumber(Trkkpmd)if Trkkpmd~=nil and Trkkpmd>0 then
Trkkpmd=tonumber(Trkkpmd)else
error("Function BigNum.change: string is not a valid number")end;X=string.sub(X,1,
zMzjn3lk-2)
for L=string.len(X),Trkkpmd do X=X.."0"end else zMzjn3lk=string.find(X,"%.")if zMzjn3lk~=nil then
X=string.sub(X,1,zMzjn3lk-1)end end;uMV17h0=string.len(X)E2NZK=Er9zidsB.len
if
(uMV17h0 >RADIX_LEN)then local GGv=uMV17h0-
(math.floor(uMV17h0/RADIX_LEN)*RADIX_LEN)
for ZIzh4Si=1,uMV17h0-GGv,RADIX_LEN do
Er9zidsB[dR]=tonumber(string.sub(X,
- (ZIzh4Si+RADIX_LEN-1),-ZIzh4Si))
if Er9zidsB[dR]==nil then
error("Function BigNum.change: string is not a valid number")Er9zidsB.len=0;return 1 end;dR=dR+1;JFXtQwy=JFXtQwy+1 end
if(GGv~=0)then
Er9zidsB[dR]=tonumber(string.sub(X,1,GGv))Er9zidsB.len=JFXtQwy+1 else Er9zidsB.len=JFXtQwy end
for c8D4n81=Er9zidsB.len-1,1,-1 do if Er9zidsB[c8D4n81]==0 then Er9zidsB[c8D4n81]=nil;Er9zidsB.len=
Er9zidsB.len-1 else break end end else Er9zidsB[dR]=tonumber(X)Er9zidsB.len=1 end else
error("Function BigNum.change: parameter error, type unexpected")end;if E2NZK~=nil then
for cSjJHx=Er9zidsB.len,E2NZK do Er9zidsB[cSjJHx]=nil end end;return 0 end
function BigNum.put(fa,M,dIZlrvD)if fa==nil then
error("Function BigNum.put: parameter nil")end;local jQgsATKd=0
for jQgsATKd=0,dIZlrvD-1 do fa[jQgsATKd]=0 end;fa[dIZlrvD]=M
for jQgsATKd=dIZlrvD+1,fa.len do fa[jQgsATKd]=nil end;fa.len=dIZlrvD;return 0 end
function printraw(aBbGg)local D9=0;if aBbGg==nil then
error("Function printraw: parameter nil")end
while 1 ==1 do
if aBbGg[D9]==nil then
io.write(' len '..aBbGg.len)
if D9 ~=aBbGg.len then io.write(' ERRO!!!!!!!!')end;io.write("\n")return 0 end;io.write('r'..aBbGg[D9])D9=D9+1 end end;function max(G,gE)if G>gE then return G else return gE end end
function decr(QgC)
local CYoa={}CYoa=BigNum.new("1")BigNum.sub(QgC,CYoa,QgC)return 0 end