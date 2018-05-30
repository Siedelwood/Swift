API=API or{}QSB=QSB or{Version="0.0.6"}
ParameterType=ParameterType or{}g_QuestBehaviorVersion=1;g_QuestBehaviorTypes={}g_GameExtraNo=0
if Framework then
g_GameExtraNo=Framework.GetGameExtraNo()elseif MapEditor then g_GameExtraNo=MapEditor.GetGameExtraNo()end;function API.Install()Core:InitalizeBundles()end
function API.InstanceTable(abn5,AvK)AvK=
AvK or{}assert(type(abn5)=="table")assert(type(AvK)==
"table")
for rhVu,ngzOjWHO in pairs(abn5)do if type(ngzOjWHO)=="table"then
AvK[rhVu]=API.InstanceTable(ngzOjWHO)else AvK[rhVu]=ngzOjWHO end end;return AvK end;CopyTableRecursive=API.InstanceTable
function API.TraverseTable(dM,U)for _u,aLgiy in pairs(U)do
if aLgiy==dM then return true end end;return false end;Inside=API.TraverseTable
function API.DumpTable(mvi,g4KV)local dT7iYDf4="{"if g4KV then
dT7iYDf4=g4KV.." = \n"..dT7iYDf4 end;Framework.WriteToLog(dT7iYDf4)
for L,WRH9 in
pairs(mvi)do
if type(WRH9)=="table"then
Framework.WriteToLog("["..L.."] = ")API.DumpTable(WRH9)elseif type(WRH9)=="string"then
Framework.WriteToLog("["..L.."] = \""..WRH9 ..
"\"")else
Framework.WriteToLog("["..L.."] = "..tostring(WRH9))end end;Framework.WriteToLog("}")end
function API.ConvertTableToString(cJoBcud)assert(type(cJoBcud)=="table")
local e="{"
for B6zKxgVs,O3_X in pairs(cJoBcud)do local DVs8kf2w
if(tonumber(B6zKxgVs))then DVs8kf2w=""..B6zKxgVs else DVs8kf2w=
"\""..B6zKxgVs.."\""end
if type(O3_X)=="table"then e=e..
"["..DVs8kf2w.."] = "..
API.ConvertTableToString(O3_X)..", "elseif type(O3_X)==
"number"then
e=e.."["..DVs8kf2w.."] = "..O3_X..", "elseif type(O3_X)=="string"then e=e..
"["..DVs8kf2w.."] = \""..O3_X.."\", "elseif type(O3_X)=="boolean"or type(O3_X)==
"nil"then
e=e.."["..DVs8kf2w..
"] = \""..tostring(O3_X).."\", "else e=e..
"["..DVs8kf2w.."] = \""..tostring(O3_X).."\", "end end;e=e.."}"return e end
function API.GetQuestID(vms5)if type(vms5)=="number"then return vms5 end;for M7,v3 in pairs(Quests)do
if v3 and
M7 >0 then if v3.Identifier==vms5 then return M7 end end end end;GetQuestID=API.GetQuestID;function API.IsValidateQuest(ihKb)
return Quests[ihKb]~=nil or
Quests[API.GetQuestID(ihKb)]~=nil end
IsValidQuest=API.IsValidateQuest
function API.FailAllQuests(...)for JGSK=1,#arg,1 do
API.FailQuest(arg[JGSK].Identifier)end end;FailQuestsByName=API.FailAllQuests
function API.FailQuest(rA5U)
local Uc06=Quests[GetQuestID(rA5U)]if Uc06 then API.Info("fail quest "..rA5U)
Uc06:RemoveQuestMarkers()Uc06:Fail()end end;FailQuestByName=API.FailQuest
function API.RestartAllQuests(...)for lcBL=1,#arg,1 do
API.RestartQuest(arg[lcBL].Identifier)end end;RestartQuestsByName=API.RestartAllQuests
function API.RestartQuest(DHPxI)
local dx=GetQuestID(DHPxI)local RRuSHnxf=Quests[dx]
if RRuSHnxf then
API.Info("restart quest "..DHPxI)
if RRuSHnxf.Objectives then local scRP0=RRuSHnxf.Objectives
for AI0R2TQ6=1,scRP0[0]do
local yA=scRP0[AI0R2TQ6]yA.Completed=nil;local XmVolesU=yA.Type
if XmVolesU==Objective.Deliver then
local eZ0l3ch=yA.Data;eZ0l3ch[3]=nil;eZ0l3ch[4]=nil;eZ0l3ch[5]=nil elseif
g_GameExtraNo and g_GameExtraNo>=1 and XmVolesU==Objective.Refill then
yA.Data[2]=nil elseif
XmVolesU==Objective.Protect or XmVolesU==Objective.Object then local W_63_9=yA.Data
for h9dyA_4T=1,W_63_9[0],1 do W_63_9[-h9dyA_4T]=nil end elseif
XmVolesU==Objective.DestroyEntities and yA.Data[1]~=1 and yA.DestroyTypeAmount then
yA.Data[3]=yA.DestroyTypeAmount elseif XmVolesU==Objective.Distance then if yA.Data[1]==-65565 then yA.Data[4].NpcInstance=
nil end elseif XmVolesU==Objective.Custom2 and
yA.Data[1].Reset then
yA.Data[1]:Reset(RRuSHnxf,AI0R2TQ6)end end end
local function mcYOuT(oh,DZXGTh)local RRuSHnxf=RRuSHnxf;local Su9Koz=RRuSHnxf[oh]
if Su9Koz then
for Uk7e=1,Su9Koz[0]do local KwQCk_G=Su9Koz[Uk7e]
if
KwQCk_G.Type==DZXGTh then local ptZa=KwQCk_G.Data[1]if ptZa and ptZa.Reset then
ptZa:Reset(RRuSHnxf,Uk7e)end end end end end;mcYOuT("Triggers",Triggers.Custom2)
mcYOuT("Rewards",Reward.Custom)mcYOuT("Reprisals",Reprisal.Custom)
RRuSHnxf.Result=nil;local Rr=RRuSHnxf.State;RRuSHnxf.State=QuestState.NotTriggered
Logic.ExecuteInLuaLocalState(
"LocalScriptCallback_OnQuestStatusChanged("..RRuSHnxf.Index..")")if Rr==QuestState.Over then
Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"",QuestTemplate.Loop,1,0,{RRuSHnxf.QueueID})end
return dx,RRuSHnxf end end;RestartQuestByName=API.RestartQuest
function API.StartAllQuests(...)for PEqsd=1,#arg,1 do
API.StartQuest(arg[PEqsd].Identifier)end end;StartQuestsByName=API.StartAllQuests
function API.StartQuest(iSj)
local iXxD6s=Quests[GetQuestID(iSj)]
if iXxD6s then API.Info("start quest "..iSj)
iXxD6s:SetMsgKeyOverride()iXxD6s:SetIconOverride()iXxD6s:Trigger()end end;StartQuestByName=API.StartQuest;function API.StopAllQuests(...)for oiY=1,#arg,1 do
API.StopQuest(arg[oiY].Identifier)end end
StopQuestwByName=API.StopAllQuests
function API.StopQuest(FsYIVlkf)local HLXS0Q_=Quests[GetQuestID(FsYIVlkf)]
if HLXS0Q_ then API.Info(
"interrupt quest "..FsYIVlkf)
HLXS0Q_:RemoveQuestMarkers()HLXS0Q_:Interrupt(-1)end end;StopQuestByName=API.StopQuest;function API.WinAllQuests(...)for Kw=1,#arg,1 do
API.WinQuest(arg[Kw].Identifier)end end
WinQuestsByName=API.WinAllQuests
function API.WinQuest(nvaIsNv7)local vDnoL55=Quests[GetQuestID(nvaIsNv7)]
if vDnoL55 then API.Info(
"win quest "..nvaIsNv7)
vDnoL55:RemoveQuestMarkers()vDnoL55:Success()end end;WinQuestByName=API.WinQuest
function API.Note(xlAK)xlAK=API.EnsureMessage(xlAK)
local zr1y=Logic.DEBUG_AddNote;if GUI then zr1y=GUI.AddNote end;zr1y(xlAK)end;GUI_Note=API.Note
function API.StaticNote(Hs)Hs=API.EnsureMessage(Hs)if not GUI then
Logic.ExecuteInLuaLocalState(
'GUI.AddStaticNote("'..Hs..'")')return end
GUI.AddStaticNote(Hs)end
function API.ClearNotes()if not GUI then
Logic.ExecuteInLuaLocalState('GUI.ClearNotes()')return end;GUI.ClearNotes()end;function API.Log(jk)local qzSFyIO=(GUI and"Local")or"Global"
local Z65=Logic.GetTimeMs()
Framework.WriteToLog(qzSFyIO..":"..Z65 ..": "..jk)end
function API.Message(umyCNfj)
umyCNfj=API.EnsureMessage(umyCNfj)if not GUI then
Logic.ExecuteInLuaLocalState('Message("'..umyCNfj..'")')return end;Message(umyCNfj)end
function API.Dbg(FT)
if QSB.Log.CurrentLevel<=QSB.Log.Level.ERROR then API.StaticNote("DEBUG: "..
FT)end;API.Log("DEBUG: "..FT)end;dbg=API.Dbg
function API.EnsureMessage(YVLXYq)local bJfct=
(Network.GetDesiredLanguage()=="de"and"de")or"en"if
type(YVLXYq)=="table"then YVLXYq=YVLXYq[bJfct]end
return tostring(YVLXYq)end
function API.Warn(OhuFpq_N)
if QSB.Log.CurrentLevel<=QSB.Log.Level.WARNING then API.StaticNote(
"WARNING: "..OhuFpq_N)end;API.Log("WARNING: "..OhuFpq_N)end;warn=API.Warn
function API.Info(Dzg)if QSB.Log.CurrentLevel<=QSB.Log.Level.INFO then API.Note(
"INFO: "..Dzg)end;API.Log(
"INFO: "..Dzg)end;info=API.Info
QSB.Log={Level={OFF=90000,ERROR=3000,WARNING=2000,INFO=1000,ALL=0}}QSB.Log.CurrentLevel=QSB.Log.Level.ALL
function API.SetLogLevel(_4O)assert(type(_4O)==
"number")QSB.Log.CurrentLevel=_4O end
function API.SendCart(C,fLI2zRe,_Fr2YU,Xfn,U,Ebsw)local UlikV=GetID(C)if not IsExisting(UlikV)then return end
local JtAjijkG;local s,YAtG_LV3,LfEJbh_=Logic.EntityGetPos(UlikV)
local JD=Logic.GetGoodCategoryForGoodType(_Fr2YU)local u=0
if Logic.IsBuilding(UlikV)==1 then
s,YAtG_LV3=Logic.GetBuildingApproachPosition(UlikV)u=Logic.GetEntityOrientation(UlikV)-90 end
if JD==GoodCategories.GC_Resource then
JtAjijkG=Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant,s,YAtG_LV3,u,fLI2zRe)elseif _Fr2YU==Goods.G_Medicine then
JtAjijkG=Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus,s,YAtG_LV3,u,fLI2zRe)elseif _Fr2YU==Goods.G_Gold then
if U then
JtAjijkG=Logic.CreateEntityOnUnblockedLand(U,s,YAtG_LV3,u,fLI2zRe)else
JtAjijkG=Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart,s,YAtG_LV3,u,fLI2zRe)end else
JtAjijkG=Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer,s,YAtG_LV3,u,fLI2zRe)end
Logic.HireMerchant(JtAjijkG,fLI2zRe,_Fr2YU,Xfn,fLI2zRe,Ebsw)return JtAjijkG end;SendCart=API.SendCart
function API.ReplaceEntity(pzDMZwG,XPoQB,XxJ)local o5sms=GetID(pzDMZwG)
if o5sms==0 then return end;local JQi1jg=GetPosition(o5sms)
local wVzn=XxJ or Logic.EntityGetPlayer(o5sms)local pE=Logic.GetEntityOrientation(o5sms)
local RSjapQ=Logic.GetEntityName(o5sms)DestroyEntity(o5sms)
if
Logic.IsEntityTypeInCategory(XPoQB,EntityCategories.Soldier)==1 then return
CreateBattalion(wVzn,XPoQB,JQi1jg.X,JQi1jg.Y,1,RSjapQ,pE)else
return CreateEntity(wVzn,XPoQB,JQi1jg,RSjapQ,pE)end end;ReplaceEntity=API.ReplaceEntity
function API.LookAt(QJf,zC,pfZ3SPy_)local pDNa2ox6=GetEntityId(QJf)
local Do6yo7nm=GetEntityId(zC)
assert(not
(Logic.IsEntityDestroyed(pDNa2ox6)or Logic.IsEntityDestroyed(Do6yo7nm)),"LookAt: One Entity is wrong or dead")local y06X3k,ivnJjrA=Logic.GetEntityPosition(pDNa2ox6)
local d3fMjkg,el=Logic.GetEntityPosition(Do6yo7nm)
local Wu_uIt=math.deg(math.atan2((el-ivnJjrA),(d3fMjkg-y06X3k)))
if Logic.IsBuilding(pDNa2ox6)==1 then Wu_uIt=Wu_uIt-90 end;pfZ3SPy_=pfZ3SPy_ or 0
Logic.SetOrientation(pDNa2ox6,Wu_uIt+pfZ3SPy_)end;LookAt=API.LookAt;function API.Confront(w,sgeP)API.LookAt(w,sgeP)
API.LookAt(sgeP,w)end
function API.GetDistance(CM,Qlmlet)
if(type(CM)=="string")or(
type(CM)=="number")then CM=GetPosition(CM)end
if(type(Qlmlet)=="string")or
(type(Qlmlet)=="number")then Qlmlet=GetPosition(Qlmlet)end;if type(CM)~="table"or type(Qlmlet)~="table"then
return{X=1,Y=1}end;local _=(CM.X-Qlmlet.X)local RkGFh6=(CM.Y-
Qlmlet.Y)return
math.sqrt((_^2)+ (RkGFh6^2))end;GetDistance=API.GetDistance
function API.ValidatePosition(hw18)
if type(hw18)=="table"then
if
(hw18.X~=nil and
type(hw18.X)=="number")and(hw18.Y~=nil and
type(hw18.Y)=="number")then local nvCiFt7r={Logic.WorldGetSize()}
if

hw18.X<=nvCiFt7r[1]and hw18.X>=0 and hw18.Y<=nvCiFt7r[2]and hw18.Y>=0 then return true end end end;return false end;IsValidPosition=API.ValidatePosition
function API.LocateEntity(xSebv5Jc)if
(type(xSebv5Jc)=="table")then return xSebv5Jc end;if
(not IsExisting(xSebv5Jc))then return{X=0,Y=0,Z=0}end
local mMp,rDtVf,vj=Logic.EntityGetPos(GetID(xSebv5Jc))return{X=mMp,Y=rDtVf,Z=vj}end;GetPosition=API.LocateEntity
function API.ActivateIO(z,Zg)State=State or 0;if GUI then
GUI.SendScriptCommand(
'API.ActivateIO("'..z..'", '..State..')')return end
if not IsExisting(z)then return end
Logic.InteractiveObjectSetAvailability(GetID(z),true)for ykRppH=1,8 do
Logic.InteractiveObjectSetPlayerState(GetID(z),ykRppH,State)end end;InteractiveObjectActivate=API.ActivateIO
function API.DeactivateIO(WQ6)if GUI then
GUI.SendScriptCommand('API.DeactivateIO("'..
WQ6 ..'")')return end
if not IsExisting(WQ6)then return end
Logic.InteractiveObjectSetAvailability(GetID(WQ6),false)for y36Aetn=1,8 do
Logic.InteractiveObjectSetPlayerState(GetID(WQ6),y36Aetn,2)end end;InteractiveObjectDeactivate=API.DeactivateIO
function API.GetEntitiesOfCategoryInTerritory(iPL3B4cr,GI2hz6SK,Oh)local PG={}
local n={}
if(iPL3B4cr==-1)then
for O=0,8 do local N5UjTN=0
repeat
n={Logic.GetEntitiesOfCategoryInTerritory(Oh,O,GI2hz6SK,N5UjTN)}PG=Array_Append(PG,n)N5UjTN=N5UjTN+#n until#n==0 end else local qLH5=0
repeat
n={Logic.GetEntitiesOfCategoryInTerritory(Oh,iPL3B4cr,GI2hz6SK,qLH5)}PG=Array_Append(PG,n)qLH5=qLH5+#n until#n==0 end;return PG end;GetEntitiesOfCategoryInTerritory=API.GetEntitiesOfCategoryInTerritory
function API.EnsureScriptName(tE)
if
type(tE)=="string"then return tE else assert(type(tE)=="number")
local VcV0EuD=Logic.GetEntityName(tE)
if
(type(VcV0EuD)~="string"or VcV0EuD=="")then
QSB.GiveEntityNameCounter=(QSB.GiveEntityNameCounter or 0)+1
VcV0EuD="EnsureScriptName_Name_"..QSB.GiveEntityNameCounter;Logic.SetEntityName(tE,VcV0EuD)end;return VcV0EuD end end;GiveEntityName=API.EnsureScriptName;function API.Bridge(pX4gCR,gad4ZcL)
if not GUI then
Logic.ExecuteInLuaLocalState(pX4gCR)else GUI.SendScriptCommand(pX4gCR,gad4ZcL)end end;function API.ToBoolean(dk)return
Core:ToBoolean(dk)end
AcceptAlternativeBoolean=API.ToBoolean
function API.AddSaveGameAction(E)if GUI then
API.Dbg("API.AddSaveGameAction: Can not be used from the local script!")return end;return
Core:AppendFunction("Mission_OnSaveGameLoaded",E)end;AddOnSaveGameLoadedAction=API.AddSaveGameAction
function API.AddHotKey(OO,y)if not GUI then
API.Dbg("API.AddHotKey: Can not be used from the global script!")return end
table.insert(Core.Data.HotkeyDescriptions,{OO,y})return#Core.Data.HotkeyDescriptions end
function API.RemoveHotKey(cR6rJlAl)if not GUI then
API.Dbg("API.RemoveHotKey: Can not be used from the global script!")return end
if

type(cR6rJlAl)~="number"or cR6rJlAl>#Core.Data.HotkeyDescriptions then
API.Dbg("API.RemoveHotKey: No candidate found or Index is nil!")return end;Core.Data.HotkeyDescriptions[cR6rJlAl]=nil end
Core={Data={Overwrite={StackedFunctions={},AppendedFunctions={},Fields={}},HotkeyDescriptions={},BundleInitializerList={}}}
function Core:InitalizeBundles()
if not GUI then self:SetupGobal_HackCreateQuest()
self:SetupGlobal_HackQuestSystem()else self:SetupLocal_HackRegisterHotkey()end
for M6ilzGJ,iW6CD in pairs(self.Data.BundleInitializerList)do local wZdg=_G[iW6CD]
if not GUI then if wZdg.Global~=
nil and wZdg.Global.Install~=nil then
wZdg.Global:Install()end else
if wZdg.Local~=nil and
wZdg.Local.Install~=nil then wZdg.Local:Install()end end end end
function Core:SetupGobal_HackCreateQuest()
CreateQuest=function(BaX,SJsW11k,Ki1HJT,wjim8xCV,E,QLam,qTDt,v,Ta)local u={}local nArcvQl={}local h6Ub7U={}local Gm={}
local YKA7cU=Logic.Quest_GetQuestNumberOfBehaviors(BaX)
for mCsewfX=0,YKA7cU-1 do
local yY=Logic.Quest_GetQuestBehaviorName(BaX,mCsewfX)local Xf=GetBehaviorTemplateByName(yY)
assert(Xf,"No template for name: "..yY..
" - using an invalid QuestSystemBehavior.lua?!")local UlFdiZ7v={}Table_Copy(UlFdiZ7v,Xf)
local U=Logic.Quest_GetQuestBehaviorParameter(BaX,mCsewfX)
for wFeA=1,#U do UlFdiZ7v:AddParameter(wFeA-1,U[wFeA])end
if(UlFdiZ7v.GetGoalTable~=nil)then
nArcvQl[#nArcvQl+1]=UlFdiZ7v:GetGoalTable()nArcvQl[#nArcvQl].Context=UlFdiZ7v
nArcvQl[#nArcvQl].FuncOverrideIcon=UlFdiZ7v.GetIcon
nArcvQl[#nArcvQl].FuncOverrideMsgKey=UlFdiZ7v.GetMsgKey end;if(UlFdiZ7v.GetTriggerTable~=nil)then
u[#u+1]=UlFdiZ7v:GetTriggerTable()end
if
(UlFdiZ7v.GetReprisalTable~=nil)then Gm[#Gm+1]=UlFdiZ7v:GetReprisalTable()end;if(UlFdiZ7v.GetRewardTable~=nil)then
h6Ub7U[#h6Ub7U+1]=UlFdiZ7v:GetRewardTable()end end;if(#u==0)or(#nArcvQl==0)then return end
if
Core:CheckQuestName(BaX)then
local JQgI=QuestTemplate:New(BaX,SJsW11k,Ki1HJT,nArcvQl,u,assert(tonumber(E)),h6Ub7U,Gm,nil,nil,(not wjim8xCV or(qTDt and
qTDt~="")),(not wjim8xCV or
(v and v~="")or(Ta and Ta~="")),QLam,qTDt,v,Ta)g_QuestNameToID[BaX]=JQgI else
dbg("Quest '"..tostring(questName)..
"': invalid questname! Contains forbidden characters!")end end end
function Core:SetupGlobal_HackQuestSystem()
QuestTemplate.Trigger_Orig_QSB_Core=QuestTemplate.Trigger
QuestTemplate.Trigger=function(N)
QuestTemplate.Trigger_Orig_QSB_Core(N)
for fs52REi=1,N.Objectives[0]do
if

N.Objectives[fs52REi].Type==Objective.Custom2 and N.Objectives[fs52REi].Data[1].SetDescriptionOverwrite then
local PUNkgaiM=N.Objectives[fs52REi].Data[1]:SetDescriptionOverwrite(N)
Core:ChangeCustomQuestCaptionText(N.Identifier,PUNkgaiM)break end end end;QuestTemplate.Interrupt_Orig_QSB_Core=QuestTemplate.Interrupt
QuestTemplate.Interrupt=function(s6FbB)
QuestTemplate.Interrupt_Orig_QSB_Core(s6FbB)
for X=1,s6FbB.Objectives[0]do if

s6FbB.Objectives[X].Type==Objective.Custom2 and s6FbB.Objectives[X].Data[1].Interrupt then
s6FbB.Objectives[X].Data[1]:Interrupt(s6FbB,X)end end
for dc61=1,s6FbB.Triggers[0]do if

s6FbB.Triggers[dc61].Type==Triggers.Custom2 and s6FbB.Triggers[dc61].Data[1].Interrupt then
s6FbB.Triggers[dc61].Data[1]:Interrupt(s6FbB,dc61)end end end end
function Core:SetupLocal_HackRegisterHotkey()
function g_KeyBindingsOptions:OnShow()
local aguhyl=(
Network.GetDesiredLanguage()=="de"and"de")or"en"if Game~=nil then
XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop",1)else
XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop",0)end
if
g_KeyBindingsOptions.Descriptions==nil then g_KeyBindingsOptions.Descriptions={}
DescRegister("MenuInGame")DescRegister("MenuDiplomacy")
DescRegister("MenuProduction")DescRegister("MenuPromotion")
DescRegister("MenuWeather")DescRegister("ToggleOutstockInformations")
DescRegister("JumpMarketplace")DescRegister("JumpMinimapEvent")
DescRegister("BuildingUpgrade")DescRegister("BuildLastPlaced")
DescRegister("BuildStreet")DescRegister("BuildTrail")DescRegister("KnockDown")
DescRegister("MilitaryAttack")DescRegister("MilitaryStandGround")
DescRegister("MilitaryGroupAdd")DescRegister("MilitaryGroupSelect")
DescRegister("MilitaryGroupStore")DescRegister("MilitaryToggleUnits")
DescRegister("UnitSelect")DescRegister("UnitSelectToggle")
DescRegister("UnitSelectSameType")DescRegister("StartChat")DescRegister("StopChat")
DescRegister("QuickSave")DescRegister("QuickLoad")
DescRegister("TogglePause")DescRegister("RotateBuilding")
DescRegister("ExitGame")DescRegister("Screenshot")
DescRegister("ResetCamera")DescRegister("CameraMove")
DescRegister("CameraMoveMouse")DescRegister("CameraZoom")
DescRegister("CameraZoomMouse")DescRegister("CameraRotate")
for p,gOPDv in
pairs(Core.Data.HotkeyDescriptions)do
if gOPDv then gOPDv[1]=
(type(gOPDv[1])=="table"and gOPDv[1][aguhyl])or gOPDv[1]gOPDv[2]=
(
type(gOPDv[2])=="table"and gOPDv[2][aguhyl])or gOPDv[2]
table.insert(g_KeyBindingsOptions.Descriptions,1,gOPDv)end end end
XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ShortcutList)
XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ActionList)
for aSdZU3,YKDL in ipairs(g_KeyBindingsOptions.Descriptions)do
XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ShortcutList,YKDL[1])
XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ActionList,YKDL[2])end end end
function Core:RegisterBundle(oFyb6OLp)
local oGdh_mv=string.format("Error while initialize bundle '%s': does not exist!",tostring(oFyb6OLp))assert(_G[oFyb6OLp]~=nil,oGdh_mv)
table.insert(self.Data.BundleInitializerList,oFyb6OLp)end
function Core:RegisterAddOn(WjvvK)
local TASVwBgU=string.format("Error while initialize addon '%s': does not exist!",tostring(WjvvK))assert(_G[WjvvK]~=nil,TASVwBgU)
table.insert(self.Data.BundleInitializerList,WjvvK)end
function Core:RegisterBehavior(KjUncMB)if GUI then return end
if KjUncMB.RequiresExtraNo and
KjUncMB.RequiresExtraNo>g_GameExtraNo then return end
if not _G["b_"..KjUncMB.Name]then
dbg("AddQuestBehavior: can not find "..
KjUncMB.Name.."!")else
if not _G["b_"..KjUncMB.Name].new then
_G["b_"..KjUncMB.Name].new=function(XkT,...)
local c3dr=API.InstanceTable(XkT)
if XkT.Parameter then for NGH=1,table.getn(XkT.Parameter)do
c3dr:AddParameter(NGH-1,arg[NGH])end end;return c3dr end end;table.insert(g_QuestBehaviorTypes,KjUncMB)end end
function Core:CheckQuestName(tIc)return
not string.find(tIc,"[ \"§$%&/\(\)\[\[\?ß\*+#,;:\.^\<\>\|]")end
function Core:ChangeCustomQuestCaptionText(MD2O,HQ)HQ.QuestDescription=MD2O
Logic.ExecuteInLuaLocalState(
[[
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
        local identifier = "]]..
HQ.Identifier..

[["
        for i=1, Quests[0] do
            if Quests[i].Identifier == identifier then
                local text = Quests[i].QuestDescription
                XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]]..MD2O..[[")
                break;
            end
        end
    ]])end
function Core:StackFunction(cng,lE,nI2F0id)
if
not self.Data.Overwrite.StackedFunctions[cng]then
self.Data.Overwrite.StackedFunctions[cng]={Original=self:GetFunctionInString(cng),Attachments={}}
local N4aMD_P=function(...)local pCi
for NzeoQJ,AwGfFV in
pairs(self.Data.Overwrite.StackedFunctions[cng].Attachments)do pCi=AwGfFV(unpack(arg))if pCi~=nil then return pCi end end
pCi=self.Data.Overwrite.StackedFunctions[cng].Original(unpack(arg))return pCi end;self:ReplaceFunction(cng,N4aMD_P)end
nI2F0id=nI2F0id or#
self.Data.Overwrite.StackedFunctions[cng].Attachments
table.insert(self.Data.Overwrite.StackedFunctions[cng].Attachments,nI2F0id,lE)end
function Core:AppendFunction(wCRY,d0uKSVw1,lNOqUk8)
if
not self.Data.Overwrite.AppendedFunctions[wCRY]then
self.Data.Overwrite.AppendedFunctions[wCRY]={Original=self:GetFunctionInString(wCRY),Attachments={}}
local YAnZNei=function(...)
local h8YWR44E=self.Data.Overwrite.AppendedFunctions[wCRY].Original(unpack(arg))
for VF,fTrMe in
pairs(self.Data.Overwrite.AppendedFunctions[wCRY].Attachments)do h8YWR44E=fTrMe(unpack(arg))end;return h8YWR44E end;self:ReplaceFunction(wCRY,YAnZNei)end
lNOqUk8=lNOqUk8 or#
self.Data.Overwrite.AppendedFunctions[wCRY].Attachments
table.insert(self.Data.Overwrite.AppendedFunctions[wCRY].Attachments,lNOqUk8,d0uKSVw1)end
function Core:ReplaceFunction(ypDndT8,MV65)local Y3D66Ym9,q=ypDndT8:find("%.")
if Y3D66Ym9 then
local PhJ=ypDndT8:sub(1,Y3D66Ym9-1)local h=ypDndT8:sub(q+1,ypDndT8:len())
local Y3D66Ym9,q=h:find("%.")
if Y3D66Ym9 then local j2K=h;local h=j2K:sub(1,Y3D66Ym9-1)
local r8hgwQ=j2K:sub(q+1,j2K:len())_G[PhJ][h][r8hgwQ]=MV65 else _G[PhJ][h]=MV65 end else _G[ypDndT8]=MV65;return end end
function Core:GetFunctionInString(_6U,GLSzBQs)
if not GLSzBQs then local c,xg=_6U:find("%.")
if c then
local Id2KoP_G=_6U:sub(1,c-1)local Y2or=_6U:sub(xg+1,_6U:len())return
self:GetFunctionInString(Y2or,_G[Id2KoP_G])else return _G[_6U]end end
if type(GLSzBQs)=="table"then local zN8ASHV5,iju=_6U:find("%.")
if zN8ASHV5 then
local XsWgh=_6U:sub(1,zN8ASHV5-1)local l4Hdz=_6U:sub(iju+1,_6U:len())return
self:GetFunctionInString(l4Hdz,GLSzBQs[XsWgh])else return GLSzBQs[_6U]end end end
function Core:ToBoolean(NSXCgSH)local Wq=tostring(NSXCgSH)
if
Wq==true or Wq=="true"or Wq=="Yes"or Wq=="On"or Wq=="+"then return true end
if
Wq==false or Wq=="false"or Wq=="No"or Wq=="Off"or Wq=="-"then return false end;return false end;API=API or{}QSB=QSB or{}
QSB.EffectNameToID=QSB.EffectNameToID or{}QSB.InitalizedObjekts=QSB.InitalizedObjekts or{}QSB.DestroyedSoldiers=
QSB.DestroyedSoldiers or{}function Goal_ActivateObject(...)return
b_Goal_ActivateObject:new(...)end
b_Goal_ActivateObject={Name="Goal_ActivateObject",Description={en="Goal: Activate an interactive object",de="Ziel: Aktiviere ein interaktives Objekt"},Parameter={{ParameterType.ScriptName,en="Object name",de="Skriptname"}}}function b_Goal_ActivateObject:GetGoalTable(SbOQ)return
{Objective.Object,{self.ScriptName}}end
function b_Goal_ActivateObject:AddParameter(IiuHGo,cGqxtYr)if
IiuHGo==0 then self.ScriptName=cGqxtYr end end
function b_Goal_ActivateObject:GetMsgKey()return"Quest_Object_Activate"end;Core:RegisterBehavior(b_Goal_ActivateObject)function Goal_Deliver(...)return
b_Goal_Deliver:new(...)end
b_Goal_Deliver={Name="Goal_Deliver",Description={en="Goal: Deliver goods to quest giver or to another player.",de="Ziel: Liefere Waren zum Auftraggeber oder zu einem anderen Spieler."},Parameter={{ParameterType.Custom,en="Type of good",de="Ressourcentyp"},{ParameterType.Number,en="Amount of good",de="Ressourcenmenge"},{ParameterType.Custom,en="To different player",de="Anderer Empfänger"},{ParameterType.Custom,en="Ignore capture",de="Abfangen ignorieren"}}}
function b_Goal_Deliver:GetGoalTable(bgJFKeeZ)
local yu9fg0nN=Logic.GetGoodTypeID(self.GoodTypeName)return
{Objective.Deliver,yu9fg0nN,self.GoodAmount,self.OverrideTarget,self.IgnoreCapture}end
function b_Goal_Deliver:AddParameter(wgx,zlU7X)
if(wgx==0)then self.GoodTypeName=zlU7X elseif(wgx==1)then self.GoodAmount=zlU7X*
1 elseif(wgx==2)then self.OverrideTarget=tonumber(zlU7X)elseif
(wgx==3)then self.IgnoreCapture=AcceptAlternativeBoolean(zlU7X)end end
function b_Goal_Deliver:GetCustomData(t)local f6qbO={}
if t==0 then for kk,QrubIAv in pairs(Goods)do if string.find(kk,"^G_")then
table.insert(f6qbO,kk)end end
table.sort(f6qbO)elseif t==2 then table.insert(f6qbO,"-")for bLHDW=1,8 do
table.insert(f6qbO,bLHDW)end elseif t==3 then table.insert(f6qbO,"true")
table.insert(f6qbO,"false")else assert(false)end;return f6qbO end
function b_Goal_Deliver:GetMsgKey()
local YjFd7b=Logic.GetGoodTypeID(self.GoodTypeName)local jZgPYb=Logic.GetGoodCategoryForGoodType(YjFd7b)
local zN2={[GoodCategories.GC_Clothes]="Quest_Deliver_GC_Clothes",[GoodCategories.GC_Entertainment]="Quest_Deliver_GC_Entertainment",[GoodCategories.GC_Food]="Quest_Deliver_GC_Food",[GoodCategories.GC_Gold]="Quest_Deliver_GC_Gold",[GoodCategories.GC_Hygiene]="Quest_Deliver_GC_Hygiene",[GoodCategories.GC_Medicine]="Quest_Deliver_GC_Medicine",[GoodCategories.GC_Water]="Quest_Deliver_GC_Water",[GoodCategories.GC_Weapon]="Quest_Deliver_GC_Weapon",[GoodCategories.GC_Resource]="Quest_Deliver_Resources"}
if jZgPYb then local IN69pa5=zN2[jZgPYb]if IN69pa5 then return IN69pa5 end end;return"Quest_Deliver_Goods"end;Core:RegisterBehavior(b_Goal_Deliver)function Goal_Diplomacy(...)return
b_Goal_Diplomacy:new(...)end
b_Goal_Diplomacy={Name="Goal_Diplomacy",Description={en="Goal: Reach a diplomatic state",de="Ziel: Erreiche einen bestimmten Diplomatiestatus zu einem anderen Spieler."},Parameter={{ParameterType.PlayerID,en="Party",de="Partei"},{ParameterType.DiplomacyState,en="Relation",de="Beziehung"}}}
function b_Goal_Diplomacy:GetGoalTable(U)return
{Objective.Diplomacy,self.PlayerID,DiplomacyStates[self.DiplState]}end
function b_Goal_Diplomacy:AddParameter(OWJ,WtalJw)if(OWJ==0)then self.PlayerID=WtalJw*1 elseif(OWJ==1)then
self.DiplState=WtalJw end end;function b_Goal_Diplomacy:GetIcon()return{6,3}end
Core:RegisterBehavior(b_Goal_Diplomacy)
function Goal_DiscoverPlayer(...)return b_Goal_DiscoverPlayer:new(...)end
b_Goal_DiscoverPlayer={Name="Goal_DiscoverPlayer",Description={en="Goal: Discover the home territory of another player.",de="Ziel: Entdecke das Heimatterritorium eines Spielers."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"}}}function b_Goal_DiscoverPlayer:GetGoalTable()return
{Objective.Discover,2,{self.PlayerID}}end
function b_Goal_DiscoverPlayer:AddParameter(JYrf2,KHDOUlRY)if(
JYrf2 ==0)then self.PlayerID=KHDOUlRY*1 end end
function b_Goal_DiscoverPlayer:GetMsgKey()
local I0JvPpn={[PlayerCategories.BanditsCamp]="Quest_Discover",[PlayerCategories.City]="Quest_Discover_City",[PlayerCategories.Cloister]="Quest_Discover_Cloister",[PlayerCategories.Harbour]="Quest_Discover",[PlayerCategories.Village]="Quest_Discover_Village"}local Ce4ZE=GetPlayerCategoryType(self.PlayerID)if Ce4ZE then
local OVx_mN=I0JvPpn[Ce4ZE]if OVx_mN then return OVx_mN end end
return"Quest_Discover"end;Core:RegisterBehavior(b_Goal_DiscoverPlayer)function Goal_DiscoverTerritory(...)return
b_Goal_DiscoverTerritory:new(...)end
b_Goal_DiscoverTerritory={Name="Goal_DiscoverTerritory",Description={en="Goal: Discover a territory",de="Ziel: Entdecke ein Territorium"},Parameter={{ParameterType.TerritoryName,en="Territory",de="Territorium"}}}function b_Goal_DiscoverTerritory:GetGoalTable()return
{Objective.Discover,1,{self.TerritoryID}}end
function b_Goal_DiscoverTerritory:AddParameter(lB,byE)if(
lB==0)then self.TerritoryID=tonumber(byE)if not self.TerritoryID then
self.TerritoryID=GetTerritoryIDByName(byE)end
assert(self.TerritoryID>0)end end
function b_Goal_DiscoverTerritory:GetMsgKey()return"Quest_Discover_Territory"end;Core:RegisterBehavior(b_Goal_DiscoverTerritory)function Goal_DestroyPlayer(...)return
b_Goal_DestroyPlayer:new(...)end
b_Goal_DestroyPlayer={Name="Goal_DestroyPlayer",Description={en="Goal: Destroy a player (destroy a main building)",de="Ziel: Zerstöre einen Spieler (ein Hauptgebäude muss zerstört werden)."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"}}}
function b_Goal_DestroyPlayer:GetGoalTable()
assert(self.PlayerID<=8 and self.PlayerID>=1,
"Error in "..self.Name..": GetGoalTable: PlayerID is invalid")return{Objective.DestroyPlayers,self.PlayerID}end;function b_Goal_DestroyPlayer:AddParameter(bITCI,K)
if(bITCI==0)then self.PlayerID=K*1 end end
function b_Goal_DestroyPlayer:GetMsgKey()
local F5dtVpnN={[PlayerCategories.BanditsCamp]="Quest_DestroyPlayers_Bandits",[PlayerCategories.City]="Quest_DestroyPlayers_City",[PlayerCategories.Cloister]="Quest_DestroyPlayers_Cloister",[PlayerCategories.Harbour]="Quest_DestroyEntities_Building",[PlayerCategories.Village]="Quest_DestroyPlayers_Village"}local kxeBp=GetPlayerCategoryType(self.PlayerID)if kxeBp then
local a=F5dtVpnN[kxeBp]if a then return a end end
return"Quest_DestroyEntities_Building"end;Core:RegisterBehavior(b_Goal_DestroyPlayer)function Goal_StealInformation(...)return
b_Goal_StealInformation:new(...)end
b_Goal_StealInformation={Name="Goal_StealInformation",Description={en="Goal: Steal information from another players castle",de="Ziel: Stehle Informationen aus der Burg eines Spielers"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"}}}
function b_Goal_StealInformation:GetGoalTable()
local kQ=Logic.GetHeadquarters(self.PlayerID)
if not kQ or kQ==0 then kQ=Logic.GetStoreHouse(self.PlayerID)end;assert(kQ and kQ~=0)
return{Objective.Steal,1,{kQ}}end;function b_Goal_StealInformation:AddParameter(EE9LAE,iVx)
if(EE9LAE==0)then self.PlayerID=iVx*1 end end;function b_Goal_StealInformation:GetMsgKey()return
"Quest_Steal_Info"end
Core:RegisterBehavior(b_Goal_StealInformation)function Goal_DestroyAllPlayerUnits(...)
return b_Goal_DestroyAllPlayerUnits:new(...)end
b_Goal_DestroyAllPlayerUnits={Name="Goal_DestroyAllPlayerUnits",Description={en="Goal: Destroy all units owned by player (be careful with script entities)",de="Ziel: Zerstöre alle Einheiten eines Spielers (vorsicht mit Script-Entities)"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"}}}
function b_Goal_DestroyAllPlayerUnits:GetGoalTable()return
{Objective.DestroyAllPlayerUnits,self.PlayerID}end;function b_Goal_DestroyAllPlayerUnits:AddParameter(eg,AQviNt)
if(eg==0)then self.PlayerID=AQviNt*1 end end
function b_Goal_DestroyAllPlayerUnits:GetMsgKey()
local T6={[PlayerCategories.BanditsCamp]="Quest_DestroyPlayers_Bandits",[PlayerCategories.City]="Quest_DestroyPlayers_City",[PlayerCategories.Cloister]="Quest_DestroyPlayers_Cloister",[PlayerCategories.Harbour]="Quest_DestroyEntities_Building",[PlayerCategories.Village]="Quest_DestroyPlayers_Village"}local NviN0i=GetPlayerCategoryType(self.PlayerID)if NviN0i then
local BlMQce=T6[NviN0i]if BlMQce then return BlMQce end end;return
"Quest_DestroyEntities"end
Core:RegisterBehavior(b_Goal_DestroyAllPlayerUnits)function Goal_DestroyScriptEntity(...)
return b_Goal_DestroyScriptEntity:new(...)end
b_Goal_DestroyScriptEntity={Name="Goal_DestroyScriptEntity",Description={en="Goal: Destroy an entity",de="Ziel: Zerstöre eine Entität"},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}}}
function b_Goal_DestroyScriptEntity:GetGoalTable()return
{Objective.DestroyEntities,1,{self.ScriptName}}end;function b_Goal_DestroyScriptEntity:AddParameter(o,dpRE)
if(o==0)then self.ScriptName=dpRE end end
function b_Goal_DestroyScriptEntity:GetMsgKey()
if
Logic.IsEntityAlive(self.ScriptName)then local fEiXwWq=GetID(self.ScriptName)
if fEiXwWq and fEiXwWq~=0 then
fEiXwWq=Logic.GetEntityType(fEiXwWq)
if fEiXwWq and fEiXwWq~=0 then
if
Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.AttackableBuilding)==1 then return"Quest_DestroyEntities_Building"elseif
Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.AttackableAnimal)==1 then return"Quest_DestroyEntities_Predators"elseif
Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.Hero)==1 then return"Quest_Destroy_Leader"elseif


Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.Military)==1 or
Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.AttackableSettler)==1 or
Logic.IsEntityTypeInCategory(fEiXwWq,EntityCategories.AttackableMerchant)==1 then return"Quest_DestroyEntities_Unit"end end end end;return"Quest_DestroyEntities"end;Core:RegisterBehavior(b_Goal_DestroyScriptEntity)function Goal_DestroyType(...)return
b_Goal_DestroyType:new(...)end
b_Goal_DestroyType={Name="Goal_DestroyType",Description={en="Goal: Destroy entity types",de="Ziel: Zerstöre Entitätstypen"},Parameter={{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.Custom,en="Player",de="Spieler"}}}
function b_Goal_DestroyType:GetGoalTable(r3JzMga6)return
{Objective.DestroyEntities,2,Entities[self.EntityName],self.Amount,self.PlayerID}end
function b_Goal_DestroyType:AddParameter(Tuyw,FYLcr2nu)
if(Tuyw==0)then self.EntityName=FYLcr2nu elseif(Tuyw==1)then self.Amount=
FYLcr2nu*1;self.DestroyTypeAmount=self.Amount elseif(Tuyw==2)then self.PlayerID=
FYLcr2nu*1 end end
function b_Goal_DestroyType:GetCustomData(ioS69)local AiP={}
if ioS69 ==0 then
for S2jwpoi,_ in pairs(Entities)do if
string.find(S2jwpoi,"^[ABU]_")then table.insert(AiP,S2jwpoi)end end;table.sort(AiP)elseif ioS69 ==2 then
for WX9u=0,8 do table.insert(AiP,WX9u)end else assert(false)end;return AiP end
function b_Goal_DestroyType:GetMsgKey()local u0riyU=self.EntityName
if
Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.AttackableBuilding)==1 then return"Quest_DestroyEntities_Building"elseif
Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.AttackableAnimal)==1 then return"Quest_DestroyEntities_Predators"elseif
Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.Hero)==1 then return"Quest_Destroy_Leader"elseif


Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.Military)==1 or
Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.AttackableSettler)==1 or
Logic.IsEntityTypeInCategory(u0riyU,EntityCategories.AttackableMerchant)==1 then return"Quest_DestroyEntities_Unit"end;return"Quest_DestroyEntities"end;Core:RegisterBehavior(b_Goal_DestroyType)
do
GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers=GameCallback_EntityKilled
GameCallback_EntityKilled=function(U,H,WNph,ytF,d,gRm)
if H~=0 and ytF~=0 then QSB.DestroyedSoldiers[ytF]=
QSB.DestroyedSoldiers[ytF]or{}QSB.DestroyedSoldiers[ytF][H]=
QSB.DestroyedSoldiers[ytF][H]or 0
if

Logic.IsEntityTypeInCategory(d,EntityCategories.Military)==1 and
Logic.IsEntityInCategory(U,EntityCategories.HeavyWeapon)==0 then QSB.DestroyedSoldiers[ytF][H]=
QSB.DestroyedSoldiers[ytF][H]+1 end end
GameCallback_EntityKilled_Orig_QSB_Goal_DestroySoldiers(U,H,WNph,ytF,d,gRm)end end
function Goal_DestroySoldiers(...)return b_Goal_DestroySoldiers:new(...)end
b_Goal_DestroySoldiers={Name="Goal_DestroySoldiers",Description={en="Goal: Destroy a given amount of enemy soldiers",de="Ziel: Zerstöre eine Anzahl gegnerischer Soldaten"},Parameter={{ParameterType.PlayerID,en="Attacking Player",de="Angreifer"},{ParameterType.PlayerID,en="Defending Player",de="Verteidiger"},{ParameterType.Number,en="Amount",de="Anzahl"}}}
function b_Goal_DestroySoldiers:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_DestroySoldiers:AddParameter(LPX0,g)
if(LPX0 ==0)then self.AttackingPlayer=g*1 elseif
(LPX0 ==1)then self.AttackedPlayer=g*1 elseif(LPX0 ==2)then self.KillsNeeded=g*1 end end
function b_Goal_DestroySoldiers:CustomFunction(_l)
if
not _l.QuestDescription or _l.QuestDescription==""then local ipUPIzc=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local N8=(ipUPIzc=="de"and
"SOLDATEN ZERST�REN {cr}{cr}von der Partei: ")or
"DESTROY SOLDIERS {cr}{cr}from faction: "
local Gzk=(ipUPIzc=="de"and"Anzahl: ")or"Amount: "local J7nsK=GetPlayerName(self.AttackedPlayer)if
J7nsK==""or J7nsK==nil then
J7nsK=
((ipUPIzc=="de"and"Spieler ")or"Player ")..self.AttackedPlayer end;local dXbd="{center}"..
N8 ..J7nsK.."{cr}{cr}"..Gzk.." "..
self.KillsNeeded
Core:ChangeCustomQuestCaptionText(dXbd,_l)end;local qao=0
if QSB.DestroyedSoldiers[self.AttackingPlayer]and
QSB.DestroyedSoldiers[self.AttackingPlayer][self.AttackedPlayer]then
qao=QSB.DestroyedSoldiers[self.AttackingPlayer][self.AttackedPlayer]end;self.SaveAmount=self.SaveAmount or qao;return self.KillsNeeded<=
qao-self.SaveAmount or nil end
function b_Goal_DestroySoldiers:DEBUG(vQj)
if
Logic.GetStoreHouse(self.AttackingPlayer)==0 then
dbg(vQj.Identifier.." "..self.Name..
": Player "..self.AttackinPlayer.." is dead :-(")return true elseif Logic.GetStoreHouse(self.AttackedPlayer)==0 then
dbg(
vQj.Identifier.." "..
self.Name..": Player "..self.AttackedPlayer.." is dead :-(")return true elseif self.KillsNeeded<0 then
dbg(vQj.Identifier..
" "..self.Name..": Amount negative")return true end end;function b_Goal_DestroySoldiers:GetIcon()return{7,12}end;function b_Goal_DestroySoldiers:Reset()self.SaveAmount=
nil end
Core:RegisterBehavior(b_Goal_DestroySoldiers)
function Goal_EntityDistance(...)return b_Goal_EntityDistance:new(...)end
b_Goal_EntityDistance={Name="Goal_EntityDistance",Description={en="Goal: Distance between two entities",de="Ziel: Zwei Entities sollen zueinander eine Entfernung über- oder unterschreiten."},Parameter={{ParameterType.ScriptName,en="Entity 1",de="Entity 1"},{ParameterType.ScriptName,en="Entity 2",de="Entity 2"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Distance",de="Entfernung"}}}
function b_Goal_EntityDistance:GetGoalTable(sVBxyy)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_EntityDistance:AddParameter(N9d,S7)
if(N9d==0)then self.Entity1=S7 elseif(N9d==1)then
self.Entity2=S7 elseif(N9d==2)then self.bRelSmallerThan=S7 =="<"elseif(N9d==3)then self.Distance=S7*1 end end
function b_Goal_EntityDistance:CustomFunction(bJtvRSR)
if Logic.IsEntityDestroyed(self.Entity1)or
Logic.IsEntityDestroyed(self.Entity2)then return false end;local aBhZK5=GetID(self.Entity1)local Jz8JUscj=GetID(self.Entity2)
local O=Logic.CheckEntitiesDistance(aBhZK5,Jz8JUscj,self.Distance)
if(self.bRelSmallerThan and O)or
(not self.bRelSmallerThan and not O)then return true end end
function b_Goal_EntityDistance:GetCustomData(tGmbAgE)local oU_r={}
if tGmbAgE==2 then
table.insert(oU_r,">")table.insert(oU_r,"<")else assert(false)end;return oU_r end
function b_Goal_EntityDistance:DEBUG(n_lv)
if not IsExisting(self.Entity1)or not
IsExisting(self.Entity2)then
dbg(""..n_lv.Identifier..
" "..self.Name..
": At least 1 of the entities for distance check don't exist!")return true end;return false end;Core:RegisterBehavior(b_Goal_EntityDistance)function Goal_KnightDistance(...)return
b_Goal_KnightDistance:new(...)end
b_Goal_KnightDistance={Name="Goal_KnightDistance",Description={en="Goal: Bring the knight close to a given entity",de="Ziel: Bringe den Ritter nah an eine bestimmte Entität"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.ScriptName,en="Target",de="Ziel"}}}
function b_Goal_KnightDistance:GetGoalTable()return
{Objective.Distance,Logic.GetKnightID(self.PlayerID),self.Target,2500,true}end
function b_Goal_KnightDistance:AddParameter(UYQF,WXx)if(UYQF==0)then self.PlayerID=WXx*1 elseif(UYQF==1)then
self.Target=WXx end end;Core:RegisterBehavior(b_Goal_KnightDistance)function Goal_UnitsOnTerritory(...)return
b_Goal_UnitsOnTerritory:new(...)end
b_Goal_UnitsOnTerritory={Name="Goal_UnitsOnTerritory",Description={en="Goal: Place a certain amount of units on a territory",de="Ziel: Platziere eine bestimmte Anzahl Einheiten auf einem Gebiet"},Parameter={{ParameterType.TerritoryNameWithUnknown,en="Territory",de="Territorium"},{ParameterType.Custom,en="Player",de="Spieler"},{ParameterType.Custom,en="Category",de="Kategorie"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Number of units",de="Anzahl Einheiten"}}}
function b_Goal_UnitsOnTerritory:GetGoalTable(W4EuxJXi)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_UnitsOnTerritory:AddParameter(BlYNd61h,XDPndG)
if(BlYNd61h==0)then
self.TerritoryID=tonumber(XDPndG)if self.TerritoryID==nil then
self.TerritoryID=GetTerritoryIDByName(XDPndG)end elseif(BlYNd61h==1)then self.PlayerID=
tonumber(XDPndG)*1 elseif(BlYNd61h==2)then self.Category=XDPndG elseif
(BlYNd61h==3)then
self.bRelSmallerThan=(tostring(XDPndG)=="true"or tostring(XDPndG)=="<")elseif(BlYNd61h==4)then self.NumberOfUnits=XDPndG*1 end end
function b_Goal_UnitsOnTerritory:CustomFunction(sJYFQIP4)
local Ogq0S2=GetEntitiesOfCategoryInTerritory(self.PlayerID,EntityCategories[self.Category],self.TerritoryID)
if
self.bRelSmallerThan==false and#Ogq0S2 >=self.NumberOfUnits then return true elseif
self.bRelSmallerThan==true and#Ogq0S2 <self.NumberOfUnits then return true end end
function b_Goal_UnitsOnTerritory:GetCustomData(n8Cw3SR)local GJqd7gt={}
if n8Cw3SR==1 then
table.insert(GJqd7gt,-1)for slE5aDm2=1,8 do table.insert(GJqd7gt,slE5aDm2)end elseif
n8Cw3SR==2 then for aL_g,IMUI10L in pairs(EntityCategories)do
if not string.find(aL_g,"^G_")and
aL_g~="SheepPasture"then table.insert(GJqd7gt,aL_g)end end
table.sort(GJqd7gt)elseif n8Cw3SR==3 then table.insert(GJqd7gt,">=")
table.insert(GJqd7gt,"<")else assert(false)end;return GJqd7gt end
function b_Goal_UnitsOnTerritory:DEBUG(vPA)
local pUXZ6G4={Logic.GetTerritories()}
if

tonumber(self.TerritoryID)==nil or self.TerritoryID<0 or not Inside(self.TerritoryID,pUXZ6G4)then
dbg(""..vPA.Identifier..
" "..self.Name..": got an invalid territoryID!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<0 or self.PlayerID>8 then
dbg(""..vPA.Identifier.." "..self.Name..
": got an invalid playerID!")return true elseif not EntityCategories[self.Category]then
dbg(""..
vPA.Identifier.." "..
self.Name..": got an invalid playerID!")return true elseif tonumber(self.NumberOfUnits)==nil or
self.NumberOfUnits<0 then
dbg(""..vPA.Identifier.." "..
self.Name..": amount is negative or nil!")return true end;return false end;Core:RegisterBehavior(b_Goal_UnitsOnTerritory)function Goal_ActivateBuff(...)return
b_Goal_ActivateBuff:new(...)end
b_Goal_ActivateBuff={Name="Goal_ActivateBuff",Description={en="Goal: Activate a buff",de="Ziel: Aktiviere einen Buff"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Buff",de="Buff"}}}
function b_Goal_ActivateBuff:GetGoalTable(mk)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_ActivateBuff:AddParameter(OeQex1U4,i0cV9)
if(OeQex1U4 ==0)then self.PlayerID=i0cV9*1 elseif
(OeQex1U4 ==1)then self.BuffName=i0cV9;self.Buff=Buffs[i0cV9]end end
function b_Goal_ActivateBuff:CustomFunction(EGD)
if
not EGD.QuestDescription or EGD.QuestDescription==""then local B_kkL=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local u=(B_kkL=="de"and
"BONUS AKTIVIEREN{cr}{cr}")or"ACTIVATE BUFF{cr}{cr}"
local EO6Y={["Buff_Spice"]={de="Salz",en="Salt"},["Buff_Colour"]={de="Farben",en="Color"},["Buff_Entertainers"]={de="Entertainer",en="Entertainer"},["Buff_FoodDiversity"]={de="Vielf�ltige Nahrung",en="Food diversity"},["Buff_ClothesDiversity"]={de="Vielf�ltige Kleidung",en="Clothes diversity"},["Buff_HygieneDiversity"]={de="Vielf�ltige Reinigung",en="Hygiene diversity"},["Buff_EntertainmentDiversity"]={de="Vielf�ltige Unterhaltung",en="Entertainment diversity"},["Buff_Sermon"]={de="Predigt",en="Sermon"},["Buff_Festival"]={de="Fest",en="Festival"},["Buff_ExtraPayment"]={de="Sonderzahlung",en="Extra payment"},["Buff_HighTaxes"]={de="Hohe Steuern",en="High taxes"},["Buff_NoPayment"]={de="Kein Sold",en="No payment"},["Buff_NoTaxes"]={de="Keine Steuern",en="No taxes"}}
if g_GameExtraNo>=1 then
EO6Y["Buff_Gems"]={de="Edelsteine",en="Gems"}
EO6Y["Buff_MusicalInstrument"]={de="Musikinstrumente",en="Musical instruments"}EO6Y["Buff_Olibanum"]={de="Weihrauch",en="Olibanum"}end
local i_053JPY="{center}"..u..EO6Y[self.BuffName][B_kkL]Core:ChangeCustomQuestCaptionText(i_053JPY,EGD)end;local VWiGCreH=Logic.GetBuff(self.PlayerID,self.Buff)if VWiGCreH and
VWiGCreH~=0 then return true end end
function b_Goal_ActivateBuff:GetCustomData(l)local UK={}
if l==1 then
UK={"Buff_Spice","Buff_Colour","Buff_Entertainers","Buff_FoodDiversity","Buff_ClothesDiversity","Buff_HygieneDiversity","Buff_EntertainmentDiversity","Buff_Sermon","Buff_Festival","Buff_ExtraPayment","Buff_HighTaxes","Buff_NoPayment","Buff_NoTaxes"}
if g_GameExtraNo>=1 then table.insert(UK,"Buff_Gems")
table.insert(UK,"Buff_MusicalInstrument")table.insert(UK,"Buff_Olibanum")end;table.sort(UK)else assert(false)end;return UK end
function b_Goal_ActivateBuff:GetIcon()
local NzaICo={[Buffs.Buff_Spice]="Goods.G_Salt",[Buffs.Buff_Colour]="Goods.G_Dye",[Buffs.Buff_Entertainers]="Entities.U_Entertainer_NA_FireEater",[Buffs.Buff_FoodDiversity]="Needs.Nutrition",[Buffs.Buff_ClothesDiversity]="Needs.Clothes",[Buffs.Buff_HygieneDiversity]="Needs.Hygiene",[Buffs.Buff_EntertainmentDiversity]="Needs.Entertainment",[Buffs.Buff_Sermon]="Technologies.R_Sermon",[Buffs.Buff_Festival]="Technologies.R_Festival",[Buffs.Buff_ExtraPayment]={1,8},[Buffs.Buff_HighTaxes]={1,6},[Buffs.Buff_NoPayment]={1,8},[Buffs.Buff_NoTaxes]={1,6}}
if g_GameExtraNo and g_GameExtraNo>=1 then
NzaICo[Buffs.Buff_Gems]="Goods.G_Gems"
NzaICo[Buffs.Buff_MusicalInstrument]="Goods.G_MusicalInstrument"NzaICo[Buffs.Buff_Olibanum]="Goods.G_Olibanum"end;return NzaICo[self.Buff]end
function b_Goal_ActivateBuff:DEBUG(k1X83nYm)
if not self.Buff then
dbg(""..k1X83nYm.Identifier..
" "..self.Name..": buff '"..self.BuffName..
"' does not exist!")return true elseif
not tonumber(self.PlayerID)or self.PlayerID<1 or self.PlayerID>8 then
dbg(""..
k1X83nYm.Identifier.." "..self.Name..
": got an invalid playerID!")return true end;return false end;Core:RegisterBehavior(b_Goal_ActivateBuff)function Goal_BuildRoad(...)return
b_Goal_BuildRoad:new(...)end
b_Goal_BuildRoad={Name="Goal_BuildRoad",Description={en="Goal: Connect two points with a street or a road",de="Ziel: Verbinde zwei Punkte mit einer Strasse oder einem Weg."},Parameter={{ParameterType.ScriptName,en="Entity 1",de="Entity 1"},{ParameterType.ScriptName,en="Entity 2",de="Entity 2"},{ParameterType.Custom,en="Only roads",de="Nur Strassen"}}}
function b_Goal_BuildRoad:GetGoalTable(xxzxfj)return
{Objective.BuildRoad,{GetID(self.Entity1),GetID(self.Entity2),false,0,self.bRoadsOnly}}end
function b_Goal_BuildRoad:AddParameter(_ad1m4I,H1QsS)
if(_ad1m4I==0)then self.Entity1=H1QsS elseif(_ad1m4I==1)then
self.Entity2=H1QsS elseif(_ad1m4I==2)then
self.bRoadsOnly=AcceptAlternativeBoolean(H1QsS)end end;function b_Goal_BuildRoad:GetCustomData(rIMx)local TiA
if rIMx==2 then TiA={"true","false"}end;return TiA end
function b_Goal_BuildRoad:DEBUG(Y51P)
if
not IsExisting(self.Entity1)or
not IsExisting(self.Entity2)then
dbg(""..Y51P.Identifier.." "..
self.Name..": first or second entity does not exist!")return true end;return false end;Core:RegisterBehavior(b_Goal_BuildRoad)function Goal_BuildWall(...)return
b_Goal_BuildWall:new(...)end
b_Goal_BuildWall={Name="Goal_BuildWall",Description={en="Goal: Build a wall between 2 positions bo stop the movement of an (hostile) player.",de="Ziel: Baue eine Mauer zwischen 2 Punkten, die die Bewegung eines (feindlichen) Spielers zwischen den Punkten verhindert."},Parameter={{ParameterType.PlayerID,en="Enemy",de="Feind"},{ParameterType.ScriptName,en="Entity 1",de="Entity 1"},{ParameterType.ScriptName,en="Entity 2",de="Entity 2"}}}
function b_Goal_BuildWall:GetGoalTable(ichL)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_BuildWall:AddParameter(NOK,Alv)
if(NOK==0)then self.PlayerID=Alv*1 elseif(NOK==1)then
self.EntityName1=Alv elseif(NOK==2)then self.EntityName2=Alv end end
function b_Goal_BuildWall:CustomFunction(YeLO2)local CkrmO=GetID(self.EntityName1)
local ooovsSJe=GetID(self.EntityName2)if not IsExisting(CkrmO)then return false end;if not
IsExisting(ooovsSJe)then return false end
local s5IsD,KvYEVoXt,VWWD_P=Logic.EntityGetPos(CkrmO)if Logic.IsBuilding(CkrmO)==1 then
s5IsD,KvYEVoXt=Logic.GetBuildingApproachPosition(CkrmO)end
local zsMuNkv=Logic.GetPlayerSectorAtPosition(self.PlayerID,s5IsD,KvYEVoXt)local s5IsD,KvYEVoXt,VWWD_P=Logic.EntityGetPos(ooovsSJe)if
Logic.IsBuilding(ooovsSJe)==1 then
s5IsD,KvYEVoXt=Logic.GetBuildingApproachPosition(ooovsSJe)end
local aXxi=Logic.GetPlayerSectorAtPosition(self.PlayerID,s5IsD,KvYEVoXt)if zsMuNkv~=aXxi then return true end;return nil end
function b_Goal_BuildWall:GetMsgKey()return"Quest_Create_Wall"end;function b_Goal_BuildWall:GetIcon()return{3,9}end
function b_Goal_BuildWall:DEBUG(Q18a7QTy)
if
not
IsExisting(self.EntityName1)or not IsExisting(self.EntityName2)then
dbg(""..Q18a7QTy.Identifier..
" "..self.Name..": first or second entity does not exist!")return true elseif
not tonumber(self.PlayerID)or self.PlayerID<1 or self.PlayerID>8 then
dbg(""..
Q18a7QTy.Identifier.." "..self.Name..
": got an invalid playerID!")return true end
if
GetDiplomacyState(Q18a7QTy.ReceivingPlayer,self.PlayerID)>-1 and not self.WarningPrinted then
warn(""..
Q18a7QTy.Identifier..
" "..self.Name..": player %d is neighter enemy or unknown to quest receiver!")self.WarningPrinted=true end;return false end;Core:RegisterBehavior(b_Goal_BuildWall)function Goal_Claim(...)return
b_Goal_Claim:new(...)end
b_Goal_Claim={Name="Goal_Claim",Description={en="Goal: Claim a territory",de="Ziel: Erobere ein Territorium"},Parameter={{ParameterType.TerritoryName,en="Territory",de="Territorium"}}}function b_Goal_Claim:GetGoalTable(K5Rp6)
return{Objective.Claim,1,self.TerritoryID}end
function b_Goal_Claim:AddParameter(GTIA,gdPUe)
if(GTIA==0)then
self.TerritoryID=tonumber(gdPUe)if not self.TerritoryID then
self.TerritoryID=GetTerritoryIDByName(gdPUe)end end end
function b_Goal_Claim:GetMsgKey()return"Quest_Claim_Territory"end;Core:RegisterBehavior(b_Goal_Claim)function Goal_ClaimXTerritories(...)return
b_Goal_ClaimXTerritories:new(...)end
b_Goal_ClaimXTerritories={Name="Goal_ClaimXTerritories",Description={en="Goal: Claim the given number of territories, all player territories are counted",de="Ziel: Erobere die angegebene Anzahl Territorien, alle spielereigenen Territorien werden gezählt"},Parameter={{ParameterType.Number,en="Territories",de="Territorien"}}}
function b_Goal_ClaimXTerritories:GetGoalTable(_bxEn)return
{Objective.Claim,2,self.TerritoriesToClaim}end
function b_Goal_ClaimXTerritories:AddParameter(pcN_ceXY,_P)if(pcN_ceXY==0)then
self.TerritoriesToClaim=_P*1 end end
function b_Goal_ClaimXTerritories:GetMsgKey()return"Quest_Claim_Territory"end;Core:RegisterBehavior(b_Goal_ClaimXTerritories)function Goal_Create(...)return
b_Goal_Create:new(...)end
b_Goal_Create={Name="Goal_Create",Description={en="Goal: Create Buildings/Units on a specified territory",de="Ziel: Erstelle Einheiten/Gebäude auf einem bestimmten Territorium."},Parameter={{ParameterType.Entity,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.TerritoryNameWithUnknown,en="Territory",de="Territorium"}}}
function b_Goal_Create:GetGoalTable(rq)return
{Objective.Create,assert(Entities[self.EntityName]),self.Amount,self.TerritoryID}end
function b_Goal_Create:AddParameter(mo,I)
if(mo==0)then self.EntityName=I elseif(mo==1)then self.Amount=I*1 elseif
(mo==2)then self.TerritoryID=tonumber(I)if not self.TerritoryID then
self.TerritoryID=GetTerritoryIDByName(I)end end end
function b_Goal_Create:GetMsgKey()
return


Logic.IsEntityTypeInCategory(Entities[self.EntityName],EntityCategories.AttackableBuilding)==1 and"Quest_Create_Building"or"Quest_Create_Unit"end;Core:RegisterBehavior(b_Goal_Create)function Goal_Produce(...)return
b_Goal_Produce:new(...)end
b_Goal_Produce={Name="Goal_Produce",Description={en="Goal: Produce an amount of goods",de="Ziel: Produziere eine Anzahl einer bestimmten Ware."},Parameter={{ParameterType.RawGoods,en="Type of good",de="Ressourcentyp"},{ParameterType.Number,en="Amount of good",de="Anzahl der Ressource"}}}
function b_Goal_Produce:GetGoalTable(RAAJAsR)
local c1pjj7=Logic.GetGoodTypeID(self.GoodTypeName)return{Objective.Produce,c1pjj7,self.GoodAmount}end
function b_Goal_Produce:AddParameter(BMv,NQh8)if(BMv==0)then self.GoodTypeName=NQh8 elseif(BMv==1)then
self.GoodAmount=NQh8*1 end end;function b_Goal_Produce:GetMsgKey()return"Quest_Produce"end
Core:RegisterBehavior(b_Goal_Produce)
function Goal_GoodAmount(...)return b_Goal_GoodAmount:new(...)end
b_Goal_GoodAmount={Name="Goal_GoodAmount",Description={en="Goal: Obtain an amount of goods - either by trading or producing them",de="Ziel: Beschaffe eine Anzahl Waren - entweder durch Handel oder durch eigene Produktion."},Parameter={{ParameterType.Custom,en="Type of good",de="Warentyp"},{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.Custom,en="Relation",de="Relation"}}}
function b_Goal_GoodAmount:GetGoalTable(P)
local bkTe=Logic.GetGoodTypeID(self.GoodTypeName)
return{Objective.Produce,bkTe,self.GoodAmount,self.bRelSmallerThan}end
function b_Goal_GoodAmount:AddParameter(ohmPbyDd,D)
if(ohmPbyDd==0)then self.GoodTypeName=D elseif
(ohmPbyDd==1)then self.GoodAmount=D*1 elseif(ohmPbyDd==2)then self.bRelSmallerThan=D=="<"or
tostring(D)=="true"end end
function b_Goal_GoodAmount:GetCustomData(DfDLWkT)local MTU8HP4d={}
if DfDLWkT==0 then for hIM_cG0i,jD in pairs(Goods)do
if
string.find(hIM_cG0i,"^G_")then table.insert(MTU8HP4d,hIM_cG0i)end end
table.sort(MTU8HP4d)elseif DfDLWkT==2 then table.insert(MTU8HP4d,">=")
table.insert(MTU8HP4d,"<")else assert(false)end;return MTU8HP4d end;Core:RegisterBehavior(b_Goal_GoodAmount)function Goal_SatisfyNeed(...)return
b_Goal_SatisfyNeed:new(...)end
b_Goal_SatisfyNeed={Name="Goal_SatisfyNeed",Description={en="Goal: Satisfy a need",de="Ziel: Erfuelle ein Beduerfnis"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Need,en="Need",de="Beduerfnis"}}}
function b_Goal_SatisfyNeed:GetGoalTable(me)return
{Objective.SatisfyNeed,self.PlayerID,assert(Needs[self.Need])}end
function b_Goal_SatisfyNeed:AddParameter(sgU5HAMG,FDydY)if(sgU5HAMG==0)then self.PlayerID=FDydY*1 elseif
(sgU5HAMG==1)then self.Need=FDydY end end
function b_Goal_SatisfyNeed:GetMsgKey()
local PEZ_={[Needs.Clothes]="Quest_SatisfyNeed_Clothes",[Needs.Entertainment]="Quest_SatisfyNeed_Entertainment",[Needs.Nutrition]="Quest_SatisfyNeed_Food",[Needs.Hygiene]="Quest_SatisfyNeed_Hygiene",[Needs.Medicine]="Quest_SatisfyNeed_Medicine"}local c=PEZ_[Needs[self.Need]]if c then return c end end;Core:RegisterBehavior(b_Goal_SatisfyNeed)function Goal_SettlersNumber(...)return
b_Goal_SettlersNumber:new(...)end
b_Goal_SettlersNumber={Name="Goal_SettlersNumber",Description={en="Goal: Get a given amount of settlers",de="Ziel: Erreiche eine bestimmte Anzahl Siedler."},Parameter={{ParameterType.Number,en="Amount",de="Anzahl"}}}
function b_Goal_SettlersNumber:GetGoalTable()return
{Objective.SettlersNumber,1,self.SettlersAmount}end;function b_Goal_SettlersNumber:AddParameter(ElbTbcZG,r3)
if(ElbTbcZG==0)then self.SettlersAmount=r3*1 end end;function b_Goal_SettlersNumber:GetMsgKey()return
"Quest_NumberSettlers"end
Core:RegisterBehavior(b_Goal_SettlersNumber)
function Goal_Spouses(...)return b_Goal_Spouses:new(...)end
b_Goal_Spouses={Name="Goal_Spouses",Description={en="Goal: Get a given amount of spouses",de="Ziel: Erreiche eine bestimmte Ehefrauenanzahl"},Parameter={{ParameterType.Number,en="Amount",de="Anzahl"}}}function b_Goal_Spouses:GetGoalTable()
return{Objective.Spouses,self.SpousesAmount}end
function b_Goal_Spouses:AddParameter(p,UiVYRok)if(p==0)then self.SpousesAmount=
UiVYRok*1 end end
function b_Goal_Spouses:GetMsgKey()return"Quest_NumberSpouses"end;Core:RegisterBehavior(b_Goal_Spouses)function Goal_SoldierCount(...)return
b_Goal_SoldierCount:new(...)end
b_Goal_SoldierCount={Name="Goal_SoldierCount",Description={en="Goal: Create a specified number of soldiers",de="Ziel: Erreiche eine Anzahl grösser oder kleiner der angegebenen Menge Soldaten."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Number of soldiers",de="Anzahl Soldaten"}}}
function b_Goal_SoldierCount:GetGoalTable(jvPsY9)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_SoldierCount:AddParameter(tE,Bmuypm)
if(tE==0)then self.PlayerID=Bmuypm*1 elseif(tE==1)then
self.bRelSmallerThan=
tostring(Bmuypm)=="true"or tostring(Bmuypm)=="<"elseif(tE==2)then self.NumberOfUnits=Bmuypm*1 end end
function b_Goal_SoldierCount:CustomFunction(hW)
if
not hW.QuestDescription or hW.QuestDescription==""then local kCwLIk=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local _l=(kCwLIk=="de"and
"SOLDATENANZAHL {cr}Partei: ")or"SOLDIERS {cr}faction: "local rjQ=tostring(self.bRelSmallerThan)
local Euo0={["true"]={de="Weniger als",en="Less than"},["false"]={de="Mindestens",en="At least"}}local LIV=GetPlayerName(self.PlayerID)
if LIV==""or LIV==nil then LIV=
((kCwLIk==
"de"and"Spieler ")or"Player ")..self.PlayerID end
local vydlAbZ3="{center}"..
_l..LIV.."{cr}{cr}"..
Euo0[rjQ][kCwLIk].." "..self.NumberOfUnits;Core:ChangeCustomQuestCaptionText(vydlAbZ3,hW)end;local iOcgdUx=Logic.GetCurrentSoldierCount(self.PlayerID)
if
(
self.bRelSmallerThan and iOcgdUx<self.NumberOfUnits)then return true elseif
(not self.bRelSmallerThan and iOcgdUx>=self.NumberOfUnits)then return true end;return nil end
function b_Goal_SoldierCount:GetCustomData(BXxv5z)local mKLU={}
if BXxv5z==1 then
table.insert(mKLU,">=")table.insert(mKLU,"<")else assert(false)end;return mKLU end;function b_Goal_SoldierCount:GetIcon()return{7,11}end;function b_Goal_SoldierCount:GetMsgKey()return
"Quest_Create_Unit"end
function b_Goal_SoldierCount:DEBUG(Him)
if
tonumber(self.NumberOfUnits)==nil or self.NumberOfUnits<0 then
dbg(""..

Him.Identifier.." "..self.Name..": amount can not be below 0!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<1 or self.PlayerID>8 then
dbg(""..Him.Identifier.." "..self.Name..
": got an invalid playerID!")return true end;return false end;Core:RegisterBehavior(b_Goal_SoldierCount)function Goal_KnightTitle(...)return
b_Goal_KnightTitle:new(...)end
b_Goal_KnightTitle={Name="Goal_KnightTitle",Description={en="Goal: Reach a specified knight title",de="Ziel: Erreiche einen vorgegebenen Titel"},Parameter={{ParameterType.Custom,en="Knight title",de="Titel"}}}
function b_Goal_KnightTitle:GetGoalTable()return
{Objective.KnightTitle,assert(KnightTitles[self.KnightTitle])}end;function b_Goal_KnightTitle:AddParameter(cPDhu,UQnOS)
if(cPDhu==0)then self.KnightTitle=UQnOS end end;function b_Goal_KnightTitle:GetMsgKey()return
"Quest_KnightTitle"end
function b_Goal_KnightTitle:GetCustomData(tRWU)return
{"Knight","Mayor","Baron","Earl","Marquees","Duke","Archduke"}end;Core:RegisterBehavior(b_Goal_KnightTitle)function Goal_Festivals(...)return
b_Goal_Festivals:new(...)end
b_Goal_Festivals={Name="Goal_Festivals",Description={en="Goal: The player has to start the given number of festivals.",de="Ziel: Der Spieler muss eine gewisse Anzahl Feste gestartet haben."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Number,en="Number of festivals",de="Anzahl Feste"}}}function b_Goal_Festivals:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_Festivals:AddParameter(X2Zy_nb,ITtw3N7E)
if
X2Zy_nb==0 then self.PlayerID=tonumber(ITtw3N7E)else
assert(X2Zy_nb==1,"Error in "..self.Name..
": AddParameter: Index is invalid.")self.NeededFestivals=tonumber(ITtw3N7E)end end
function b_Goal_Festivals:CustomFunction(yozOp)
if not yozOp.QuestDescription or
yozOp.QuestDescription==""then
local CLSdD=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
local Fh=(CLSdD=="de"and"FESTE FEIERN {cr}{cr}Partei: ")or
"HOLD PARTIES {cr}{cr}faction: "
local IlAPA=(CLSdD=="de"and"Anzahl: ")or"Amount: "local jLKMpQuK=GetPlayerName(self.PlayerID)
if
jLKMpQuK==""or jLKMpQuK==nil then jLKMpQuK=
((CLSdD=="de"and"Spieler ")or"Player ")..self.PlayerID end
local sUQpby="{center}"..Fh..jLKMpQuK..
"{cr}{cr}"..IlAPA.." "..self.NeededFestivals;Core:ChangeCustomQuestCaptionText(sUQpby,yozOp)end
if Logic.GetStoreHouse(self.PlayerID)==0 then return false end
local wxU={Logic.GetPlayerEntities(self.PlayerID,Entities.B_TableBeer,5,0)}local kOmS5sy=0
for mbA=2,#wxU do local _qPhpaFx=wxU[mbA]
if
Logic.GetIndexOnOutStockByGoodType(_qPhpaFx,Goods.G_Beer)~=-1 then
local zex=Logic.GetAmountOnOutStockByGoodType(_qPhpaFx,Goods.G_Beer)kOmS5sy=kOmS5sy+zex end end
if not self.FestivalStarted and kOmS5sy>0 then
self.FestivalStarted=true;self.FestivalCounter=
(self.FestivalCounter and self.FestivalCounter+1)or 1
if
self.FestivalCounter>=self.NeededFestivals then self.FestivalCounter=nil;return true end elseif kOmS5sy==0 then self.FestivalStarted=false end end
function b_Goal_Festivals:DEBUG(pPGcdu)
if
Logic.GetStoreHouse(self.PlayerID)==0 then
dbg(pPGcdu.Identifier..": Error in "..self.Name..
": Player "..self.PlayerID.." is dead :-(")return true elseif
GetPlayerCategoryType(self.PlayerID)~=PlayerCategories.City then
dbg(pPGcdu.Identifier..": Error in "..self.Name..
":  Player "..self.PlayerID.." is no city")return true elseif self.NeededFestivals<0 then
dbg(pPGcdu.Identifier..": Error in "..
self.Name..": Number of Festivals is negative")return true end;return false end
function b_Goal_Festivals:Reset()self.FestivalCounter=nil;self.FestivalStarted=nil end;function b_Goal_Festivals:GetIcon()return{4,15}end
Core:RegisterBehavior(b_Goal_Festivals)
function Goal_Capture(...)return b_Goal_Capture:new(...)end
b_Goal_Capture={Name="Goal_Capture",Description={en="Goal: Capture a cart.",de="Ziel: Ein Karren muss erobert werden."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}}}function b_Goal_Capture:GetGoalTable(rjp)
return{Objective.Capture,1,{self.ScriptName}}end
function b_Goal_Capture:AddParameter(cT2z,z)if
(cT2z==0)then self.ScriptName=z end end
function b_Goal_Capture:GetMsgKey()local ke1tWps=GetID(self.ScriptName)
if
Logic.IsEntityAlive(ke1tWps)then ke1tWps=Logic.GetEntityType(ke1tWps)
if ke1tWps and ke1tWps~=0 then
if
Logic.IsEntityTypeInCategory(ke1tWps,EntityCategories.AttackableMerchant)==1 then return"Quest_Capture_Cart"elseif
Logic.IsEntityTypeInCategory(ke1tWps,EntityCategories.SiegeEngine)==1 then return"Quest_Capture_SiegeEngine"elseif


Logic.IsEntityTypeInCategory(ke1tWps,EntityCategories.Worker)==1 or
Logic.IsEntityTypeInCategory(ke1tWps,EntityCategories.Spouse)==1 or
Logic.IsEntityTypeInCategory(ke1tWps,EntityCategories.Hero)==1 then return"Quest_Capture_VIPOfPlayer"end end end end;Core:RegisterBehavior(b_Goal_Capture)function Goal_CaptureType(...)return
b_Goal_CaptureType:new(...)end
b_Goal_CaptureType={Name="Goal_CaptureType",Description={en="Goal: Capture specified entity types",de="Ziel: Nimm bestimmte Entitätstypen gefangen"},Parameter={{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.PlayerID,en="Player",de="Spieler"}}}
function b_Goal_CaptureType:GetGoalTable(gRFA)return
{Objective.Capture,2,Entities[self.EntityName],self.Amount,self.PlayerID}end
function b_Goal_CaptureType:AddParameter(jX9a0tJX,YFy4TGc)
if(jX9a0tJX==0)then self.EntityName=YFy4TGc elseif
(jX9a0tJX==1)then self.Amount=YFy4TGc*1 elseif(jX9a0tJX==2)then self.PlayerID=YFy4TGc*1 end end
function b_Goal_CaptureType:GetCustomData(YjpbYkCb)local L1p7luJ={}
if YjpbYkCb==0 then
for eH,WpOZ in pairs(Entities)do
if

string.find(eH,"^U_.+Cart")or
Logic.IsEntityTypeInCategory(WpOZ,EntityCategories.AttackableMerchant)==1 then table.insert(L1p7luJ,eH)end end;table.sort(L1p7luJ)elseif YjpbYkCb==2 then for fD2289=0,8 do
table.insert(L1p7luJ,fD2289)end else assert(false)end;return L1p7luJ end
function b_Goal_CaptureType:GetMsgKey()local folfO=self.EntityName
if
Logic.IsEntityTypeInCategory(folfO,EntityCategories.AttackableMerchant)==1 then return"Quest_Capture_Cart"elseif
Logic.IsEntityTypeInCategory(folfO,EntityCategories.SiegeEngine)==1 then return"Quest_Capture_SiegeEngine"elseif


Logic.IsEntityTypeInCategory(folfO,EntityCategories.Worker)==1 or
Logic.IsEntityTypeInCategory(folfO,EntityCategories.Spouse)==1 or
Logic.IsEntityTypeInCategory(folfO,EntityCategories.Hero)==1 then return"Quest_Capture_VIPOfPlayer"end end;Core:RegisterBehavior(b_Goal_CaptureType)function Goal_Protect(...)return
b_Goal_Protect:new(...)end
b_Goal_Protect={Name="Goal_Protect",Description={en="Goal: Protect an entity (entity needs a script name",de="Ziel: Beschuetze eine Entität (Entität benötigt einen Skriptnamen)"},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}}}function b_Goal_Protect:GetGoalTable()
return{Objective.Protect,{self.ScriptName}}end;function b_Goal_Protect:AddParameter(vtsK,E1p4Mv)if(vtsK==0)then
self.ScriptName=E1p4Mv end end
function b_Goal_Protect:GetMsgKey()
if
Logic.IsEntityAlive(self.ScriptName)then local IHap=GetID(self.ScriptName)
if IHap and IHap~=0 then
IHap=Logic.GetEntityType(IHap)
if IHap and IHap~=0 then
if
Logic.IsEntityTypeInCategory(IHap,EntityCategories.AttackableBuilding)==1 then return"Quest_Protect_Building"elseif
Logic.IsEntityTypeInCategory(IHap,EntityCategories.SpecialBuilding)==1 then
local rDvV={[PlayerCategories.City]="Quest_Protect_City",[PlayerCategories.Cloister]="Quest_Protect_Cloister",[PlayerCategories.Village]="Quest_Protect_Village"}
local RX1L2q=GetPlayerCategoryType(Logic.EntityGetPlayer(GetID(self.ScriptName)))
if RX1L2q then local bCBtWguf=rDvV[RX1L2q]if bCBtWguf then return bCBtWguf end end;return"Quest_Protect_Building"elseif
Logic.IsEntityTypeInCategory(IHap,EntityCategories.Hero)==1 then return"Quest_Protect_Knight"elseif
Logic.IsEntityTypeInCategory(IHap,EntityCategories.AttackableMerchant)==1 then return"Quest_Protect_Cart"end end end end;return"Quest_Protect"end;Core:RegisterBehavior(b_Goal_Protect)function Goal_Refill(...)return
b_Goal_Refill:new(...)end
b_Goal_Refill={Name="Goal_Refill",Description={en="Goal: Refill an object using a geologist",de="Ziel: Eine Mine soll durch einen Geologen wieder aufgefuellt werden."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}},RequiresExtraNo=1}function b_Goal_Refill:GetGoalTable()return
{Objective.Refill,{GetID(self.ScriptName)}}end;function b_Goal_Refill:GetIcon()return
{8,1,1}end;function b_Goal_Refill:AddParameter(q,e1sXUN4f)if(q==0)then
self.ScriptName=e1sXUN4f end end
Core:RegisterBehavior(b_Goal_Refill)
function Goal_ResourceAmount(...)return b_Goal_ResourceAmount:new(...)end
b_Goal_ResourceAmount={Name="Goal_ResourceAmount",Description={en="Goal: Reach a specified amount of resources in a doodad",de="Ziel: In einer Mine soll weniger oder mehr als eine angegebene Anzahl an Rohstoffen sein."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Amount",de="Menge"}}}
function b_Goal_ResourceAmount:GetGoalTable(x)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_ResourceAmount:AddParameter(VP,IQwqq)
if(VP==0)then self.ScriptName=IQwqq elseif(VP==1)then self.bRelSmallerThan=
IQwqq=="<"elseif(VP==2)then self.Amount=IQwqq*1 end end
function b_Goal_ResourceAmount:CustomFunction(Xcc4)local fqw5=GetID(self.ScriptName)
if
fqw5 and
fqw5 ~=0 and Logic.GetResourceDoodadGoodType(fqw5)~=0 then local qnVfOeRE=Logic.GetResourceDoodadGoodAmount(fqw5)
if(
self.bRelSmallerThan and qnVfOeRE<self.Amount)or
(not
self.bRelSmallerThan and qnVfOeRE>self.Amount)then return true end end;return nil end
function b_Goal_ResourceAmount:GetCustomData(YIiSKsxK)local Ua={}
if YIiSKsxK==1 then
table.insert(Ua,">")table.insert(Ua,"<")else assert(false)end;return Ua end
function b_Goal_ResourceAmount:DEBUG(qeJtG)
if not IsExisting(self.ScriptName)then
dbg(""..

qeJtG.Identifier.." "..self.Name..
": entity '"..self.ScriptName.."' does not exist!")return true elseif
tonumber(self.Amount)==nil or self.Amount<0 then
dbg(""..qeJtG.Identifier..
" "..self.Name..": error at amount! (nil or below 0)")return true end;return false end;Core:RegisterBehavior(b_Goal_ResourceAmount)function Goal_InstantFailure()return
b_Goal_InstantFailure:new()end
b_Goal_InstantFailure={Name="Goal_InstantFailure",Description={en="Instant failure, the goal returns false.",de="Direkter Misserfolg, das Goal sendet false."}}
function b_Goal_InstantFailure:GetGoalTable(pdpNgBcZ)return{Objective.DummyFail}end;Core:RegisterBehavior(b_Goal_InstantFailure)function Goal_InstantSuccess()return
b_Goal_InstantSuccess:new()end
b_Goal_InstantSuccess={Name="Goal_InstantSuccess",Description={en="Instant success, the goal returns true.",de="Direkter Erfolg, das Goal sendet true."}}
function b_Goal_InstantSuccess:GetGoalTable(wV)return{Objective.Dummy}end;Core:RegisterBehavior(b_Goal_InstantSuccess)function Goal_NoChange()return
b_Goal_NoChange:new()end
b_Goal_NoChange={Name="Goal_NoChange",Description={en="The quest state doesn't change. Use reward functions of other quests to change the state of this quest.",de="Der Questzustand wird nicht verändert. Ein Reward einer anderen Quest sollte den Zustand dieser Quest verändern."}}
function b_Goal_NoChange:GetGoalTable()return{Objective.NoChange}end;Core:RegisterBehavior(b_Goal_NoChange)function Goal_MapScriptFunction(...)return
b_Goal_MapScriptFunction:new(...)end
b_Goal_MapScriptFunction={Name="Goal_MapScriptFunction",Description={en="Goal: Calls a function within the global map script. Return 'true' means success, 'false' means failure and 'nil' doesn't change anything.",de="Ziel: Ruft eine Funktion im globalen Skript auf, die einen Wahrheitswert zurueckgibt. Rueckgabe 'true' gilt als erfuellt, 'false' als gescheitert und 'nil' ändert nichts."},Parameter={{ParameterType.Default,en="Function name",de="Funktionsname"}}}
function b_Goal_MapScriptFunction:GetGoalTable(rLd)return
{Objective.Custom2,{self,self.CustomFunction}}end;function b_Goal_MapScriptFunction:AddParameter(z8oF,DB6A7N)
if(z8oF==0)then self.FuncName=DB6A7N end end;function b_Goal_MapScriptFunction:CustomFunction(VhYX)return
_G[self.FuncName](self,VhYX)end
function b_Goal_MapScriptFunction:DEBUG(Ha7ErH)
if
not self.FuncName or not _G[self.FuncName]then
dbg(""..

Ha7ErH.Identifier.." "..
self.Name..": function '"..self.FuncName.."' does not exist!")return true end;return false end;Core:RegisterBehavior(b_Goal_MapScriptFunction)function Goal_CustomVariables(...)return
b_Goal_CustomVariables:new(...)end
b_Goal_CustomVariables={Name="Goal_CustomVariables",Description={en="Goal: A customised variable has to assume a certain value.",de="Ziel: Eine benutzerdefinierte Variable muss einen bestimmten Wert annehmen."},Parameter={{ParameterType.Default,en="Name of Variable",de="Variablenname"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Default,en="Value or variable",de="Wert oder Variable"}}}
function b_Goal_CustomVariables:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_CustomVariables:AddParameter(rjU95v,sxBl)
if rjU95v==0 then self.VariableName=sxBl elseif rjU95v==1 then
self.Relation=sxBl elseif rjU95v==2 then local m=tonumber(sxBl)
m=(m~=nil and m)or tostring(sxBl)self.Value=m end end
function b_Goal_CustomVariables:CustomFunction()
if
_G["QSB_CustomVariables_"..self.VariableName]then
local nD4LhX6z=
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value]
if self.Relation=="=="then
if
_G["QSB_CustomVariables_"..self.VariableName]==nD4LhX6z then return true end elseif self.Relation=="~="then
if
_G["QSB_CustomVariables_"..self.VariableName]==nD4LhX6z then return true end elseif self.Relation=="<"then
if
_G["QSB_CustomVariables_"..self.VariableName]<nD4LhX6z then return true end elseif self.Relation=="<="then
if
_G["QSB_CustomVariables_"..self.VariableName]<=nD4LhX6z then return true end elseif self.Relation==">="then
if
_G["QSB_CustomVariables_"..self.VariableName]>=nD4LhX6z then return true end else if
_G["QSB_CustomVariables_"..self.VariableName]>nD4LhX6z then return true end end end;return nil end
function b_Goal_CustomVariables:GetCustomData(iN)return{"==","~=","<=","<",">",">="}end
function b_Goal_CustomVariables:DEBUG(Lq)local s9tW={"==","~=","<=","<",">",">="}
local R61K={true,false,nil}
if
not _G["QSB_CustomVariables_"..self.VariableName]then
dbg(Lq.Identifier.." "..self.Name..
": variable '"..self.VariableName.."' do not exist!")return true elseif not Inside(self.Relation,s9tW)then
dbg(Lq.Identifier.." "..
self.Name..": '"..
self.Relation.."' is an invalid relation!")return true end;return false end;Core:RegisterBehavior(b_Goal_CustomVariables)function Goal_InputDialog(...)return
b_Goal_InputDialog:new(...)end
b_Goal_InputDialog={Name="Goal_InputDialog",Description={en="Goal: Player must type in something. The passwords have to be seperated by ; and whitespaces will be ignored.",de="Ziel: Oeffnet einen Dialog, der Spieler muss Lösungswörter eingeben. Diese sind durch ; abzutrennen. Leerzeichen werden ignoriert."},Parameter={{ParameterType.Default,en="ReturnVariable",de="Name der Variable"},{ParameterType.Default,en="Message",de="Nachricht"},{ParameterType.Default,en="Passwords",de="Lösungswörter"},{ParameterType.Number,en="Trials Till Correct Password (0 = Forever)",de="Versuche (0 = unbegrenzt)"}}}
function b_Goal_InputDialog:GetGoalTable(Jf4os)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_InputDialog:AddParameter(a4xc,e)
if(a4xc==0)then self.Variable=e elseif(a4xc==1)then
self.Message=e elseif(a4xc==2)then local la5=e;self.Password={}la5=la5;la5=string.lower(la5)
la5=string.gsub(la5," ","")
while(string.len(la5)>0)do local i,R=string.find(la5,";")
if R then table.insert(self.Password,string.sub(la5,1,
R-1))la5=string.sub(la5,R+
1,string.len(la5))else
table.insert(self.Password,la5)la5=""end end elseif(a4xc==3)then
self.TryTillCorrect=(e==nil and-1)or(e*1)end end
function b_Goal_InputDialog:CustomFunction(xWVu)local function Yw8Yxix(i)
if not self.shown then
self:InitReturnVariable(i)self:ShowBox()self.shown=true end end
if not IsBriefingActive or
(
IsBriefingActive and IsBriefingActive()==false)then
if(not self.TryTillCorrect)or
(self.TryTillCorrect)==-1 then
Yw8Yxix(self.Variable,self.Message)elseif not self.shown then
self.TryCounter=self.TryCounter or self.TryTillCorrect;Yw8Yxix(self.Variable,"")
self.TryCounter=self.TryCounter-1 end
if _G[self.Variable]then
Logic.ExecuteInLuaLocalState([[
                GUI_Chat.Confirm = GUI_Chat.Confirm_Orig_Goal_InputDialog
                GUI_Chat.Confirm_Orig_Goal_InputDialog = nil
                GUI_Chat.Abort = GUI_Chat.Abort_Orig_Goal_InputDialog
                GUI_Chat.Abort_Orig_Goal_InputDialog = nil
            ]])
if self.Password then self.shown=nil
_G[self.Variable]=_G[self.Variable]
_G[self.Variable]=string.lower(_G[self.Variable])
_G[self.Variable]=string.gsub(_G[self.Variable]," ","")
if Inside(_G[self.Variable],self.Password)then return true elseif self.TryTillCorrect and
(
self.TryTillCorrect==-1 or self.TryCounter>0)then
Logic.DEBUG_AddNote(self.Message)_G[self.Variable]=nil;return else
Logic.DEBUG_AddNote(self.Message)_G[self.Variable]=nil;return false end end;return true end end end
function b_Goal_InputDialog:ShowBox()
Logic.ExecuteInLuaLocalState([[
        Input.ChatMode()
        XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",1)
        XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput", "")
        XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput")
    ]])end
function b_Goal_InputDialog:InitReturnVariable(VoXG)
Logic.ExecuteInLuaLocalState(
[[
        GUI_Chat.Abort_Orig_Goal_InputDialog = GUI_Chat.Abort
        GUI_Chat.Confirm_Orig_Goal_InputDialog = GUI_Chat.Confirm

        GUI_Chat.Confirm = function()
            local _variable = "]]..
VoXG..
[["
            Input.GameMode()

            XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",0)
            local ChatMessage = XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput")
            g_Chat.JustClosed = 1
            GUI.SendScriptCommand("_G[ \"".._variable.."\" ] = \""..ChatMessage.."\"")
        end

        GUI_Chat.Abort = function() end
    ]])end
function b_Goal_InputDialog:DEBUG(JL0I04c)
if tonumber(self.TryTillCorrect)==nil or
self.TryTillCorrect==0 then
local En6r_K97=string.format("%s %s: TryTillCorrect is nil or 0!",JL0I04c.Identifier,self.Name)dbg(En6r_K97)return true elseif type(self.Message)~="string"then
local T4AA=string.format("%s %s: Message is not valid!",JL0I04c.Identifier,self.Name)dbg(T4AA)return true elseif type(self.Variable)~="string"then
local VnuCKTdu=string.format("%s %s: Variable is not valid!",JL0I04c.Identifier,self.Name)dbg(VnuCKTdu)return true end
for XnNgn,H1JD in pairs(self.Password)do
if type(H1JD)~="string"then
local gEEa9I=string.format("%s %s: at least 1 password is not valid!",JL0I04c.Identifier,self.Name)dbg(gEEa9I)return true end end;return false end;function b_Goal_InputDialog:GetIcon()return{12,2}end
function b_Goal_InputDialog:Reset()_G[self.Variable]=
nil;self.TryCounter=nil;self.shown=nil end;Core:RegisterBehavior(b_Goal_InputDialog)function Goal_Decide(...)return
b_Goal_Decide:new(...)end
b_Goal_Decide={Name="Goal_Decide",Description={en="Opens a Yes/No Dialog. Decision = Quest Result",de="Oeffnet einen Ja/Nein-Dialog. Die Entscheidung bestimmt das Quest-Ergebnis (ja=true, nein=false)."},Parameter={{ParameterType.Default,en="Text",de="Text"},{ParameterType.Default,en="Title",de="Titel"},{ParameterType.Custom,en="Button labels",de="Button Beschriftung"}}}function b_Goal_Decide:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_Decide:AddParameter(ULLLDUm,e4F3)
if(
ULLLDUm==0)then self.Text=e4F3 elseif(ULLLDUm==1)then self.Title=e4F3 elseif(ULLLDUm==2)then self.Buttons=(
e4F3 =="Ok/Cancel")end end
function b_Goal_Decide:CustomFunction(GsfNt7)
if
not IsBriefingActive or(IsBriefingActive and
IsBriefingActive()==false)then
if not self.LocalExecuted then if QSB.DialogActive then return end;QSB.DialogActive=true;local YWPfQKb2=(
self.Buttons and"true")or"nil"
self.LocalExecuted=true
local r=[[
                Game.GameTimeSetFactor( GUI.GetPlayerID(), 0 )
                OpenRequesterDialog(%q,
                                    %q,
                                    "Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 ); GUI.SendScriptCommand( 'QSB.DecisionWindowResult = true ')",
                                    %s ,
                                    "Game.GameTimeSetFactor( GUI.GetPlayerID(), 1 ); GUI.SendScriptCommand( 'QSB.DecisionWindowResult = false ')")
            ]]
local r=string.format(r,self.Text,"{center} "..self.Title,YWPfQKb2)Logic.ExecuteInLuaLocalState(r)end;local fF0=QSB.DecisionWindowResult;if fF0 ~=nil then QSB.DecisionWindowResult=nil
QSB.DialogActive=false;return fF0 end end end;function b_Goal_Decide:Reset()self.LocalExecuted=nil end;function b_Goal_Decide:GetIcon()return
{4,12}end
function b_Goal_Decide:GetCustomData(OS0Zp3i)if OS0Zp3i==2 then return
{"Yes/No","Ok/Cancel"}end end;Core:RegisterBehavior(b_Goal_Decide)function Goal_TributeDiplomacy(...)return
b_Goal_TributeDiplomacy:new(...)end
b_Goal_TributeDiplomacy={Name="Goal_TributeDiplomacy",Description={en="Goal: AI requests periodical tribute for better Diplomacy",de="Ziel: Die KI fordert einen regelmässigen Tribut fuer bessere Diplomatie. Der Questgeber ist der fordernde Spieler."},Parameter={{ParameterType.Number,en="Amount",de="Menge"},{ParameterType.Custom,en="Length of Period in month",de="Monate bis zur nächsten Forderung"},{ParameterType.Number,en="Time to pay Tribut in seconds",de="Zeit bis zur Zahlung in Sekunden"},{ParameterType.Default,en="Start Message for TributQuest",de="Startnachricht der Tributquest"},{ParameterType.Default,en="Success Message for TributQuest",de="Erfolgsnachricht der Tributquest"},{ParameterType.Default,en="Failure Message for TributQuest",de="Niederlagenachricht der Tributquest"},{ParameterType.Custom,en="Restart if failed to pay",de="Nicht-bezahlen beendet die Quest"}}}
function b_Goal_TributeDiplomacy:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_TributeDiplomacy:AddParameter(BK,Idjbe70)
if(BK==0)then self.Amount=Idjbe70*1 elseif(BK==1)then self.PeriodLength=
Idjbe70*150 elseif(BK==2)then self.TributTime=Idjbe70*1 elseif(BK==3)then
self.StartMsg=Idjbe70 elseif(BK==4)then self.SuccessMsg=Idjbe70 elseif(BK==5)then self.FailureMsg=Idjbe70 elseif(BK==6)then
self.RestartAtFailure=AcceptAlternativeBoolean(Idjbe70)end end
function b_Goal_TributeDiplomacy:CustomFunction(B)
if not self.Time then if self.PeriodLength-150 <
self.TributTime then
Logic.DEBUG_AddNote("b_Goal_TributeDiplomacy: TributTime too long")end end
if not self.QuestStarted then
self.QuestStarted=QuestTemplate:New(B.Identifier.."TributeBanditQuest",B.SendingPlayer,B.ReceivingPlayer,{{Objective.Deliver,{Goods.G_Gold,self.Amount}}},{{Triggers.Time,0}},self.TributTime,
nil,nil,nil,nil,true,true,nil,self.StartMsg,self.SuccessMsg,self.FailureMsg)self.Time=Logic.GetTime()end;local nDjt=Quests[self.QuestStarted]
if
self.QuestStarted and
nDjt.State==QuestState.Over and not self.RestartQuest then
if nDjt.Result~=QuestResult.Success then
SetDiplomacyState(B.ReceivingPlayer,B.SendingPlayer,DiplomacyStates.Enemy)if not self.RestartAtFailure then return false end else
SetDiplomacyState(B.ReceivingPlayer,B.SendingPlayer,DiplomacyStates.TradeContact)end;self.RestartQuest=true end;local NVWt=Logic.GetStoreHouse(B.SendingPlayer)
if(NVWt==0 or
Logic.IsEntityDestroyed(NVWt))then if self.QuestStarted and
Quests[self.QuestStarted].State==QuestState.Active then
Quests[self.QuestStarted]:Interrupt()end;return true end
if
self.QuestStarted and self.RestartQuest and(
(Logic.GetTime()-self.Time)>=self.PeriodLength)then nDjt.Objectives[1].Completed=nil;nDjt.Objectives[1].Data[3]=
nil
nDjt.Objectives[1].Data[4]=nil;nDjt.Objectives[1].Data[5]=nil
nDjt.Result=nil;nDjt.State=QuestState.NotTriggered
Logic.ExecuteInLuaLocalState(
"LocalScriptCallback_OnQuestStatusChanged("..nDjt.Index..")")
Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"",QuestTemplate.Loop,1,0,{nDjt.QueueID})self.Time=Logic.GetTime()self.RestartQuest=nil end end
function b_Goal_TributeDiplomacy:DEBUG(efuUGMh)if self.Amount<0 then
dbg(efuUGMh.Identifier.." "..
self.Name..": Amount is negative")return true end end;function b_Goal_TributeDiplomacy:Reset()self.Time=nil;self.QuestStarted=nil
self.RestartQuest=nil end
function b_Goal_TributeDiplomacy:Interrupt(p4nNp)
if
self.QuestStarted and Quests[self.QuestStarted]~=nil then if
Quests[self.QuestStarted].State==QuestState.Active then
Quests[self.QuestStarted]:Interrupt()end end end
function b_Goal_TributeDiplomacy:GetCustomData(VW)
if(VW==1)then return
{"1","2","3","4","5","6","7","8","9","10","11","12"}elseif(VW==6)then return{"true","false"}end end;Core:RegisterBehavior(b_Goal_TributeDiplomacy)function Goal_TributeClaim(...)return
b_Goal_TributeClaim:new(...)end
b_Goal_TributeClaim={Name="Goal_TributeClaim",Description={en="Goal: AI requests periodical tribute for a specified Territory",de="Ziel: Die KI fordert einen regelmässigen Tribut fuer ein Territorium. Der Questgeber ist der fordernde Spieler."},Parameter={{ParameterType.TerritoryName,en="Territory",de="Territorium"},{ParameterType.PlayerID,en="PlayerID",de="PlayerID"},{ParameterType.Number,en="Amount",de="Menge"},{ParameterType.Custom,en="Length of Period in month",de="Monate bis zur nächsten Forderung"},{ParameterType.Number,en="Time to pay Tribut in seconds",de="Zeit bis zur Zahlung in Sekunden"},{ParameterType.Default,en="Start Message for TributQuest",de="Startnachricht der Tributquest"},{ParameterType.Default,en="Success Message for TributQuest",de="Erfolgsnachricht der Tributquest"},{ParameterType.Default,en="Failure Message for TributQuest",de="Niederlagenachricht der Tributquest"},{ParameterType.Number,en="How often to pay (0 = forerver)",de="Anzahl der Tributquests (0 = unendlich)"},{ParameterType.Custom,en="Other Owner cancels the Quest",de="Anderer Spieler kann Quest beenden"},{ParameterType.Custom,en="About if a rate is not payed",de="Nicht-bezahlen beendet die Quest"}}}
function b_Goal_TributeClaim:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_TributeClaim:AddParameter(Zt,V)
if(Zt==0)then
self.TerritoryID=GetTerritoryIDByName(V)elseif(Zt==1)then self.PlayerID=V*1 elseif(Zt==2)then self.Amount=V*1 elseif(Zt==3)then
self.PeriodLength=V*150 elseif(Zt==4)then self.TributTime=V*1 elseif(Zt==5)then self.StartMsg=V elseif(Zt==6)then
self.SuccessMsg=V elseif(Zt==7)then self.FailureMsg=V elseif(Zt==8)then self.HowOften=V*1 elseif(Zt==9)then
self.OtherOwnerCancels=AcceptAlternativeBoolean(V)elseif(Zt==10)then self.DontPayCancels=AcceptAlternativeBoolean(V)end end
function b_Goal_TributeClaim:CustomFunction(mzeTI)
local s=Logic.GetTerritoryAcquiringBuildingID(self.TerritoryID)if IsExisting(s)and GetHealth(s)<25 then
while
(Logic.GetEntityHealth(s)>
Logic.GetEntityMaxHealth(s)*0.6)do Logic.HurtEntity(s,1)end end
if

Logic.GetTerritoryPlayerID(self.TerritoryID)==mzeTI.ReceivingPlayer or
Logic.GetTerritoryPlayerID(self.TerritoryID)==self.PlayerID then
if self.OtherOwner then self:RestartTributeQuest()self.OtherOwner=nil end;if
not self.Time and self.PeriodLength-20 <self.TributTime then
Logic.DEBUG_AddNote("b_Goal_TributeClaim: TributTime too long")end
if
not self.Quest then
local ztJhP_u8=QuestTemplate:New(mzeTI.Identifier.."TributeClaimQuest",self.PlayerID,mzeTI.ReceivingPlayer,{{Objective.Deliver,{Goods.G_Gold,self.Amount}}},{{Triggers.Time,0}},self.TributTime,
nil,nil,nil,nil,true,true,nil,self.StartMsg,self.SuccessMsg,self.FailureMsg)self.Quest=Quests[ztJhP_u8]self.Time=Logic.GetTime()else
if
self.Quest.State==QuestState.Over then
if
self.Quest.Result==QuestResult.Failure then if IsExisting(s)then
Logic.ChangeEntityPlayerID(s,self.PlayerID)end
Logic.SetTerritoryPlayerID(self.TerritoryID,self.PlayerID)self.Time=Logic.GetTime()self.Quest.State=false;if
self.DontPayCancels then mzeTI:Interrupt()end else
if self.Quest.Result==
QuestResult.Success then
if Logic.GetTerritoryPlayerID(self.TerritoryID)==
self.PlayerID then if IsExisting(s)then
Logic.ChangeEntityPlayerID(s,mzeTI.ReceivingPlayer)end
Logic.SetTerritoryPlayerID(self.TerritoryID,mzeTI.ReceivingPlayer)end end
if Logic.GetTime()>=self.Time+self.PeriodLength then
if
self.HowOften and self.HowOften~=0 then
self.TributeCounter=self.TributeCounter or 0;self.TributeCounter=self.TributeCounter+1;if
self.TributeCounter>=self.HowOften then return false end end;self:RestartTributeQuest()end end elseif self.Quest.State==false then
if Logic.GetTime()>=
self.Time+self.PeriodLength then self:RestartTributeQuest()end end end elseif Logic.GetTerritoryPlayerID(self.TerritoryID)==0 and
self.Quest then if
self.Quest.State==QuestState.Active then self.Quest:Interrupt()end elseif
Logic.GetTerritoryPlayerID(self.TerritoryID)~=self.PlayerID then if
self.Quest.State==QuestState.Active then self.Quest:Interrupt()end;if
self.OtherOwnerCancels then mzeTI:Interrupt()end;self.OtherOwner=true end;local y4J=Logic.GetStoreHouse(self.PlayerID)
if(y4J==0 or
Logic.IsEntityDestroyed(y4J))then
if self.Quest and
self.Quest.State==QuestState.Active then self.Quest:Interrupt()end;return true end end
function b_Goal_TributeClaim:DEBUG(D)
if self.TerritoryID==0 then
dbg(D.Identifier..": "..
self.Name..": Unknown Territory")return true elseif not self.Quest and
Logic.GetStoreHouse(self.PlayerID)==0 then
dbg(D.Identifier..
": "..self.Name..": Player "..
self.PlayerID.." is dead. :-(")return true elseif self.Amount<0 then
dbg(D.Identifier..
": "..self.Name..": Amount is negative")return true elseif self.PeriodLength<1 or self.PeriodLength>600 then
dbg(
D.Identifier..": "..self.Name..": Period Length is wrong")return true elseif self.HowOften<0 then
dbg(D.Identifier..
": "..self.Name..": HowOften is negative")return true end end
function b_Goal_TributeClaim:Reset()self.Quest=nil;self.Time=nil;self.OtherOwner=nil end
function b_Goal_TributeClaim:Interrupt(XIcl)if type(self.Quest)=="table"then
if self.Quest.State==
QuestState.Active then self.Quest:Interrupt()end end end
function b_Goal_TributeClaim:RestartTributeQuest()self.Time=Logic.GetTime()self.Quest.Objectives[1].Completed=
nil;self.Quest.Objectives[1].Data[3]=
nil;self.Quest.Objectives[1].Data[4]=
nil;self.Quest.Objectives[1].Data[5]=
nil;self.Quest.Result=nil
self.Quest.State=QuestState.NotTriggered
Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..self.Quest.Index..")")
Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"",QuestTemplate.Loop,1,0,{self.Quest.QueueID})end
function b_Goal_TributeClaim:GetCustomData(ys)if(ys==3)then return
{"1","2","3","4","5","6","7","8","9","10","11","12"}elseif(ys==9)or(ys==10)then
return{"false","true"}end end;Core:RegisterBehavior(b_Goal_TributeClaim)function Reprisal_ObjectDeactivate(...)return
b_Reprisal_ObjectDeactivate:new(...)end
b_Reprisal_ObjectDeactivate={Name="Reprisal_ObjectDeactivate",Description={en="Reprisal: Deactivates an interactive object",de="Vergeltung: Deaktiviert ein interaktives Objekt"},Parameter={{ParameterType.ScriptName,en="Interactive object",de="Interaktives Objekt"}}}
function b_Reprisal_ObjectDeactivate:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_ObjectDeactivate:AddParameter(rMQ1um8,U2)
if(rMQ1um8 ==0)then self.ScriptName=U2 end end;function b_Reprisal_ObjectDeactivate:CustomFunction(X)
InteractiveObjectDeactivate(self.ScriptName)end
function b_Reprisal_ObjectDeactivate:DEBUG(zLtWO09)
if

not Logic.IsInteractiveObject(GetID(self.ScriptName))then
warn(""..zLtWO09.Identifier..
" "..self.Name..": '"..
self.ScriptName.."' is not a interactive object!")self.WarningPrinted=true end;local Z=GetID(self.ScriptName)
if QSB.InitalizedObjekts[Z]and
QSB.InitalizedObjekts[Z]==zLtWO09.Identifier then
dbg(""..

zLtWO09.Identifier.." "..
self.Name..": you can not deactivate in the same quest the object is initalized!")return true end;return false end
Core:RegisterBehavior(b_Reprisal_ObjectDeactivate)function Reprisal_ObjectActivate(...)
return b_Reprisal_ObjectActivate:new(...)end
b_Reprisal_ObjectActivate={Name="Reprisal_ObjectActivate",Description={en="Reprisal: Activates an interactive object",de="Vergeltung: Aktiviert ein interaktives Objekt"},Parameter={{ParameterType.ScriptName,en="Interactive object",de="Interaktives Objekt"},{ParameterType.Custom,en="Availability",de="Nutzbarkeit"}}}
function b_Reprisal_ObjectActivate:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_ObjectActivate:AddParameter(ZDICnKE,L)
if(ZDICnKE==0)then self.ScriptName=L elseif
(ZDICnKE==1)then local B58=0;if L=="Always"or 1 then B58=1 end;self.UsingState=B58 end end;function b_Reprisal_ObjectActivate:CustomFunction(PYVzrNl)
InteractiveObjectActivate(self.ScriptName,self.UsingState)end
function b_Reprisal_ObjectActivate:GetCustomData(KTVmRC)if
KTVmRC==1 then return{"Knight only","Always"}end end
function b_Reprisal_ObjectActivate:DEBUG(Pa)
if not
Logic.IsInteractiveObject(GetID(self.ScriptName))then
warn(""..Pa.Identifier..
" "..self.Name..": '"..
self.ScriptName.."' is not a interactive object!")self.WarningPrinted=true end;local bmK=GetID(self.ScriptName)
if QSB.InitalizedObjekts[bmK]and
QSB.InitalizedObjekts[bmK]==Pa.Identifier then
dbg(""..
Pa.Identifier..
" "..
self.Name..": you can not activate in the same quest the object is initalized!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_ObjectActivate)function Reprisal_DiplomacyDecrease()return
b_Reprisal_DiplomacyDecrease:new()end
b_Reprisal_DiplomacyDecrease={Name="Reprisal_DiplomacyDecrease",Description={en="Reprisal: Diplomacy decreases slightly to another player",de="Vergeltung: Der Diplomatiestatus zum Auftraggeber wird um eine Stufe verringert."}}
function b_Reprisal_DiplomacyDecrease:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_DiplomacyDecrease:CustomFunction(O)local JPc3R=O.SendingPlayer
local j=O.ReceivingPlayer;local vMgKnGj=GetDiplomacyState(j,JPc3R)if vMgKnGj>-2 then
SetDiplomacyState(j,JPc3R,vMgKnGj-1)end end;function b_Reprisal_DiplomacyDecrease:AddParameter(M9K,Zeu)
if(M9K==0)then self.PlayerID=Zeu*1 end end
Core:RegisterBehavior(b_Reprisal_DiplomacyDecrease)
function Reprisal_Diplomacy(...)return b_Reprisal_Diplomacy:new(...)end
b_Reprisal_Diplomacy={Name="Reprisal_Diplomacy",Description={en="Reprisal: Sets Diplomacy state of two Players to a stated value.",de="Vergeltung: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert."},Parameter={{ParameterType.PlayerID,en="PlayerID 1",de="Spieler 1"},{ParameterType.PlayerID,en="PlayerID 2",de="Spieler 2"},{ParameterType.DiplomacyState,en="Relation",de="Beziehung"}}}
function b_Reprisal_Diplomacy:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_Diplomacy:AddParameter(Q2_d,W0iTcMIt)
if(Q2_d==0)then self.PlayerID1=W0iTcMIt*1 elseif
(Q2_d==1)then self.PlayerID2=W0iTcMIt*1 elseif(Q2_d==2)then
self.Relation=DiplomacyStates[W0iTcMIt]end end;function b_Reprisal_Diplomacy:CustomFunction(N)
SetDiplomacyState(self.PlayerID1,self.PlayerID2,self.Relation)end
function b_Reprisal_Diplomacy:DEBUG(Hald6SO)
if

not tonumber(self.PlayerID1)or self.PlayerID1 <1 or self.PlayerID1 >8 then
dbg(Hald6SO.Identifier.." "..
self.Name..": PlayerID 1 is invalid!")return true elseif
not tonumber(self.PlayerID2)or self.PlayerID2 <1 or self.PlayerID2 >8 then
dbg(Hald6SO.Identifier.." "..self.Name..
": PlayerID 2 is invalid!")return true elseif
not tonumber(self.Relation)or self.Relation<-2 or self.Relation>2 then
dbg(Hald6SO.Identifier.." "..
self.Name..": '"..
self.Relation.."' is a invalid diplomacy state!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_Diplomacy)function Reprisal_DestroyEntity(...)return
b_Reprisal_DestroyEntity:new(...)end
b_Reprisal_DestroyEntity={Name="Reprisal_DestroyEntity",Description={en="Reprisal: Replaces an entity with an invisible script entity, which retains the entities name.",de="Vergeltung: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen übernimmt."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"}}}
function b_Reprisal_DestroyEntity:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_DestroyEntity:AddParameter(Dq,y3Ur)
if(Dq==0)then self.ScriptName=y3Ur end end;function b_Reprisal_DestroyEntity:CustomFunction(GL70F7uL)
ReplaceEntity(self.ScriptName,Entities.XD_ScriptEntity)end
function b_Reprisal_DestroyEntity:DEBUG(lqANrrJA)
if
not IsExisting(self.ScriptName)then
warn(lqANrrJA.Identifier.." "..
self.Name..": '"..
self.ScriptName.."' is already destroyed!")self.WarningPrinted=true end;return false end;Core:RegisterBehavior(b_Reprisal_DestroyEntity)function Reprisal_DestroyEffect(...)return
b_Reprisal_DestroyEffect:new(...)end
b_Reprisal_DestroyEffect={Name="Reprisal_DestroyEffect",Description={en="Reprisal: Destroys an effect",de="Vergeltung: Zerstört einen Effekt"},Parameter={{ParameterType.Default,en="Effect name",de="Effektname"}}}function b_Reprisal_DestroyEffect:AddParameter(WUFTXBy6,aEZf)
if WUFTXBy6 ==0 then self.EffectName=aEZf end end
function b_Reprisal_DestroyEffect:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_DestroyEffect:CustomFunction(QjQ_o)if

not QSB.EffectNameToID[self.EffectName]or not
Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName])then return end
Logic.DestroyEffect(QSB.EffectNameToID[self.EffectName])end
function b_Reprisal_DestroyEffect:DEBUG(w)if
not QSB.EffectNameToID[self.EffectName]then
dbg(w.Identifier.." "..self.Name..
": Effect "..self.EffectName.." never created")end;return false end;Core:RegisterBehavior(b_Reprisal_DestroyEffect)function Reprisal_Defeat()return
b_Reprisal_Defeat:new()end
b_Reprisal_Defeat={Name="Reprisal_Defeat",Description={en="Reprisal: The player loses the game.",de="Vergeltung: Der Spieler verliert das Spiel."}}
function b_Reprisal_Defeat:GetReprisalTable(Diq_)return{Reprisal.Defeat}end;Core:RegisterBehavior(b_Reprisal_Defeat)function Reprisal_FakeDefeat()return
b_Reprisal_FakeDefeat:new()end
b_Reprisal_FakeDefeat={Name="Reprisal_FakeDefeat",Description={en="Reprisal: Displays a defeat icon for a quest",de="Vergeltung: Zeigt ein Niederlage Icon fuer eine Quest an"}}
function b_Reprisal_FakeDefeat:GetReprisalTable()return{Reprisal.FakeDefeat}end;Core:RegisterBehavior(b_Reprisal_FakeDefeat)function Reprisal_ReplaceEntity(...)return
b_Reprisal_ReplaceEntity:new(...)end
b_Reprisal_ReplaceEntity={Name="Reprisal_ReplaceEntity",Description={en="Reprisal: Replaces an entity with a new one of a different type. The playerID can be changed too.",de="Vergeltung: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehörigkeit geändert werden."},Parameter={{ParameterType.ScriptName,en="Target",de="Ziel"},{ParameterType.Custom,en="New Type",de="Neuer Typ"},{ParameterType.Custom,en="New playerID",de="Neue Spieler ID"}}}
function b_Reprisal_ReplaceEntity:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_ReplaceEntity:AddParameter(QYA5WJOY,yliV8)
if(QYA5WJOY==0)then self.ScriptName=yliV8 elseif
(QYA5WJOY==1)then self.NewType=yliV8 elseif(QYA5WJOY==2)then self.PlayerID=tonumber(yliV8)end end
function b_Reprisal_ReplaceEntity:CustomFunction(rjpKFl)local YUGQovw=GetID(self.ScriptName)
local XZt7GyF=self.PlayerID
if XZt7GyF==Logic.EntityGetPlayer(YUGQovw)then XZt7GyF=nil end
ReplaceEntity(self.ScriptName,Entities[self.NewType],XZt7GyF)end
function b_Reprisal_ReplaceEntity:GetCustomData(Zn3SC)local D4={}
if Zn3SC==1 then
for crA9EKx,IcsJ in pairs(Entities)do
local A={"^M_","^XS_","^X_","^XT_","^Z_","^XB_"}local Wp9xT=false
for P=1,#A do if crA9EKx:find(A[P])then Wp9xT=true;break end end;if not Wp9xT then table.insert(D4,crA9EKx)end end;table.sort(D4)elseif Zn3SC==2 then
D4={"-","0","1","2","3","4","5","6","7","8"}end;return D4 end
function b_Reprisal_ReplaceEntity:DEBUG(o0_XG8FI)
if not Entities[self.NewType]then
dbg(
o0_XG8FI.Identifier.." "..self.Name..": got an invalid entity type!")return true elseif self.PlayerID~=nil and
(self.PlayerID<1 or self.PlayerID>8)then
dbg(o0_XG8FI.Identifier.." "..
self.Name..": got an invalid playerID!")return true end
if not IsExisting(self.ScriptName)then self.WarningPrinted=true
warn(
o0_XG8FI.Identifier.." "..
self.Name..": '"..self.ScriptName.."' does not exist!")end;return false end;Core:RegisterBehavior(b_Reprisal_ReplaceEntity)function Reprisal_QuestRestart(...)return
b_Reprisal_QuestRestart(...)end
b_Reprisal_QuestRestart={Name="Reprisal_QuestRestart",Description={en="Reprisal: Restarts a (completed) quest so it can be triggered and completed again",de="Vergeltung: Startet eine (beendete) Quest neu, damit diese neu ausgelöst und beendet werden kann"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reprisal_QuestRestart:GetReprisalTable(jLsxpw)return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_QuestRestart:AddParameter(x,AXNfV)
if(x==0)then self.QuestName=AXNfV end end;function b_Reprisal_QuestRestart:CustomFunction(cX)
self:ResetQuest()end
function b_Reprisal_QuestRestart:DEBUG(iyx)
if not
Quests[GetQuestID(self.QuestName)]then
dbg(iyx.Identifier..
" "..self.Name..": quest "..
self.QuestName.." does not exist!")return true end end;function b_Reprisal_QuestRestart:ResetQuest()
RestartQuestByName(self.QuestName)end
Core:RegisterBehavior(b_Reprisal_QuestRestart)
function Reprisal_QuestFailure(...)return b_Reprisal_QuestFailure(...)end
b_Reprisal_QuestFailure={Name="Reprisal_QuestFailure",Description={en="Reprisal: Lets another active quest fail",de="Vergeltung: Lässt eine andere aktive Quest fehlschlagen"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reprisal_QuestFailure:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_QuestFailure:AddParameter(bxvn,mWYrzB)
if(bxvn==0)then self.QuestName=mWYrzB end end;function b_Reprisal_QuestFailure:CustomFunction(O7kX)
FailQuestByName(self.QuestName)end
function b_Reprisal_QuestFailure:DEBUG(Q4XSpdY)if not
Quests[GetQuestID(self.QuestName)]then
dbg(""..Q4XSpdY.Identifier..
" "..self.Name..": got an invalid quest!")return true end;return
false end;Core:RegisterBehavior(b_Reprisal_QuestFailure)function Reprisal_QuestSuccess(...)return
b_Reprisal_QuestSuccess(...)end
b_Reprisal_QuestSuccess={Name="Reprisal_QuestSuccess",Description={en="Reprisal: Completes another active quest successfully",de="Vergeltung: Beendet eine andere aktive Quest erfolgreich"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reprisal_QuestSuccess:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_QuestSuccess:AddParameter(fzTyrQ9F,fAumJ0i)
if(fzTyrQ9F==0)then self.QuestName=fAumJ0i end end;function b_Reprisal_QuestSuccess:CustomFunction(i0)
WinQuestByName(self.QuestName)end
function b_Reprisal_QuestSuccess:DEBUG(tZliF4)
if not
Quests[GetQuestID(self.QuestName)]then
dbg(tZliF4.Identifier..
" "..self.Name..": quest "..
self.QuestName.." does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_QuestSuccess)function Reprisal_QuestActivate(...)return
b_Reprisal_QuestActivate(...)end
b_Reprisal_QuestActivate={Name="Reprisal_QuestActivate",Description={en="Reprisal: Activates another quest that is not triggered yet.",de="Vergeltung: Aktiviert eine andere Quest die noch nicht ausgelöst wurde."},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reprisal_QuestActivate:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_QuestActivate:AddParameter(jlmopoj,R)if(jlmopoj==0)then self.QuestName=R else
assert(false,"Error in "..
self.Name..": AddParameter: Index is invalid")end end;function b_Reprisal_QuestActivate:CustomFunction(u)
StartQuestByName(self.QuestName)end
function b_Reprisal_QuestActivate:DEBUG(S_N6)
if not
IsValidQuest(self.QuestName)then
dbg(S_N6.Identifier.." "..self.Name..
": Quest: "..self.QuestName.." does not exist")return true end end;Core:RegisterBehavior(b_Reprisal_QuestActivate)function Reprisal_QuestInterrupt(...)return
b_Reprisal_QuestInterrupt(...)end
b_Reprisal_QuestInterrupt={Name="Reprisal_QuestInterrupt",Description={en="Reprisal: Interrupts another active quest without success or failure",de="Vergeltung: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reprisal_QuestInterrupt:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_QuestInterrupt:AddParameter(o5SLRA,ztwXaCR)
if(o5SLRA==0)then self.QuestName=ztwXaCR end end
function b_Reprisal_QuestInterrupt:CustomFunction(M2WtMgiq)
if(
GetQuestID(self.QuestName)~=nil)then
local FgfME=GetQuestID(self.QuestName)local y=Quests[FgfME]if y.State==QuestState.Active then
StopQuestByName(self.QuestName)end end end
function b_Reprisal_QuestInterrupt:DEBUG(lH9o)
if
not Quests[GetQuestID(self.QuestName)]then
dbg(lH9o.Identifier.." "..self.Name..
": quest "..self.QuestName.." does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_QuestInterrupt)function Reprisal_QuestForceInterrupt(...)return
b_Reprisal_QuestForceInterrupt(...)end
b_Reprisal_QuestForceInterrupt={Name="Reprisal_QuestForceInterrupt",Description={en="Reprisal: Interrupts another quest (even when it isn't active yet) without success or failure",de="Vergeltung: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Custom,en="Ended quests",de="Beendete Quests"}}}
function b_Reprisal_QuestForceInterrupt:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_QuestForceInterrupt:AddParameter(CC4Kfjh,k)
if(CC4Kfjh==0)then self.QuestName=k elseif
(CC4Kfjh==1)then self.InterruptEnded=AcceptAlternativeBoolean(k)end end
function b_Reprisal_QuestForceInterrupt:GetCustomData(eUQ0x)local r0OR={}
if eUQ0x==1 then
table.insert(r0OR,"false")table.insert(r0OR,"true")else assert(false)end;return r0OR end
function b_Reprisal_QuestForceInterrupt:CustomFunction(pYHkv)
if
(GetQuestID(self.QuestName)~=nil)then local hxZHlgP=GetQuestID(self.QuestName)local zct=Quests[hxZHlgP]if
self.InterruptEnded or zct.State~=QuestState.Over then
zct:Interrupt()end end end
function b_Reprisal_QuestForceInterrupt:DEBUG(WQk6Wkd)
if not
Quests[GetQuestID(self.QuestName)]then
dbg(WQk6Wkd.Identifier..
" "..self.Name..": quest "..
self.QuestName.." does not exist!")return true end;return false end
Core:RegisterBehavior(b_Reprisal_QuestForceInterrupt)function Reprisal_MapScriptFunction(...)
return b_Reprisal_MapScriptFunction:new(...)end
b_Reprisal_MapScriptFunction={Name="Reprisal_MapScriptFunction",Description={en="Reprisal: Calls a function within the global map script if the quest has failed.",de="Vergeltung: Ruft eine Funktion im globalen Kartenskript auf, wenn die Quest fehlschlägt."},Parameter={{ParameterType.Default,en="Function name",de="Funktionsname"}}}
function b_Reprisal_MapScriptFunction:GetReprisalTable(t)return
{Reprisal.Custom,{self,self.CustomFunction}}end;function b_Reprisal_MapScriptFunction:AddParameter(pRCHPl,sCffg4HK)
if(pRCHPl==0)then self.FuncName=sCffg4HK end end;function b_Reprisal_MapScriptFunction:CustomFunction(E)return
_G[self.FuncName](self,E)end
function b_Reprisal_MapScriptFunction:DEBUG(yljhkFp)
if
not self.FuncName or not _G[self.FuncName]then
dbg(""..

yljhkFp.Identifier.." "..
self.Name..": function '"..self.FuncName.."' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Reprisal_MapScriptFunction)function Reprisal_CustomVariables(...)
return b_Reprisal_CustomVariables:new(...)end
b_Reprisal_CustomVariables={Name="Reprisal_CustomVariables",Description={en="Reprisal: Executes a mathematical operation with this variable. The other operand can be a number or another custom variable.",de="Vergeltung: Fuehrt eine mathematische Operation mit der Variable aus. Der andere Operand kann eine Zahl oder eine Custom-Varible sein."},Parameter={{ParameterType.Default,en="Name of variable",de="Variablenname"},{ParameterType.Custom,en="Operator",de="Operator"},{ParameterType.Default,en="Value or variable",de="Wert oder Variable"}}}
function b_Reprisal_CustomVariables:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_CustomVariables:AddParameter(uGDn542,DQ)
if uGDn542 ==0 then self.VariableName=DQ elseif uGDn542 ==1 then
self.Operator=DQ elseif uGDn542 ==2 then local s6Ahlni_=tonumber(DQ)s6Ahlni_=
(s6Ahlni_~=nil and s6Ahlni_)or tostring(DQ)
self.Value=s6Ahlni_ end end
function b_Reprisal_CustomVariables:CustomFunction()
_G["QSB_CustomVariables_"..self.VariableName]=_G[
"QSB_CustomVariables_"..self.VariableName]or 0
local T6dNu=_G["QSB_CustomVariables_"..self.VariableName]
if self.Operator=="="then
_G["QSB_CustomVariables_"..self.VariableName]=(
type(self.Value)~="string"and self.Value)or _G[
"QSB_CustomVariables_"..self.Value]elseif self.Operator=="+"then
_G["QSB_CustomVariables_"..self.VariableName]=
T6dNu+
(type(self.Value)~="string"and self.Value)or
_G["QSB_CustomVariables_"..self.Value]elseif self.Operator=="-"then
_G["QSB_CustomVariables_"..self.VariableName]=
T6dNu-
(type(self.Value)~="string"and self.Value)or
_G["QSB_CustomVariables_"..self.Value]elseif self.Operator=="*"then
_G["QSB_CustomVariables_"..self.VariableName]=
T6dNu*
(type(self.Value)~="string"and self.Value)or
_G["QSB_CustomVariables_"..self.Value]elseif self.Operator=="/"then
_G["QSB_CustomVariables_"..self.VariableName]=
T6dNu/
(type(self.Value)~="string"and self.Value)or
_G["QSB_CustomVariables_"..self.Value]elseif self.Operator=="^"then
_G["QSB_CustomVariables_"..self.VariableName]=
T6dNu^
(type(self.Value)~="string"and self.Value)or
_G["QSB_CustomVariables_"..self.Value]end end
function b_Reprisal_CustomVariables:GetCustomData(H)return{"=","+","-","*","/","^"}end
function b_Reprisal_CustomVariables:DEBUG(YlzZm)local v={"=","+","-","*","/","^"}
if not
Inside(self.Operator,v)then
dbg(YlzZm.Identifier..
" "..self.Name..": got an invalid operator!")return true elseif self.VariableName==""then
dbg(YlzZm.Identifier.." "..
self.Name..": missing name for variable!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_CustomVariables)function Reprisal_Technology(...)return
b_Reprisal_Technology:new(...)end
b_Reprisal_Technology={Name="Reprisal_Technology",Description={en="Reprisal: Locks or unlocks a technology for the given player",de="Vergeltung: Sperrt oder erlaubt eine Technolgie fuer den angegebenen Player"},Parameter={{ParameterType.PlayerID,en="PlayerID",de="SpielerID"},{ParameterType.Custom,en="Un / Lock",de="Sperren/Erlauben"},{ParameterType.Custom,en="Technology",de="Technologie"}}}
function b_Reprisal_Technology:GetReprisalTable(j9879b5)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_Technology:AddParameter(cotcYZ1f,FRcmT)
if(cotcYZ1f==0)then self.PlayerID=FRcmT*1 elseif
(cotcYZ1f==1)then self.LockType=FRcmT=="Lock"elseif(cotcYZ1f==2)then self.Technology=FRcmT end end
function b_Reprisal_Technology:CustomFunction(zfl)
if
self.PlayerID and
Logic.GetStoreHouse(self.PlayerID)~=0 and Technologies[self.Technology]then
if self.LockType then
LockFeaturesForPlayer(self.PlayerID,Technologies[self.Technology])else
UnLockFeaturesForPlayer(self.PlayerID,Technologies[self.Technology])end else return false end end
function b_Reprisal_Technology:GetCustomData(itxD)local JPHs7A={}if(itxD==1)then JPHs7A[1]="Lock"
JPHs7A[2]="UnLock"elseif(itxD==2)then
for yzYgnMtr,o in pairs(Technologies)do table.insert(JPHs7A,yzYgnMtr)end end;return
JPHs7A end
function b_Reprisal_Technology:DEBUG(wmkJ)
if not Technologies[self.Technology]then
dbg(""..

wmkJ.Identifier.." "..self.Name..": got an invalid technology type!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<1 or self.PlayerID>8 then
dbg(""..wmkJ.Identifier.." "..self.Name..
": got an invalid playerID!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_Technology)function Reward_ObjectDeactivate(...)return
b_Reward_ObjectDeactivate:new(...)end
b_Reward_ObjectDeactivate=API.InstanceTable(b_Reprisal_ObjectDeactivate)b_Reward_ObjectDeactivate.Name="Reward_ObjectDeactivate"
b_Reward_ObjectDeactivate.Description.de="Reward: Deactivates an interactive object"
b_Reward_ObjectDeactivate.Description.en="Lohn: Deaktiviert ein interaktives Objekt"b_Reward_ObjectDeactivate.GetReprisalTable=nil
b_Reward_ObjectDeactivate.GetRewardTable=function(I1,gXu5hG)return
{Reward.Custom,{I1,I1.CustomFunction}}end;Core:RegisterBehavior(b_Reward_ObjectDeactivate)function Reward_ObjectActivate(...)return
b_Reward_ObjectActivate:new(...)end
b_Reward_ObjectActivate=API.InstanceTable(b_Reprisal_ObjectActivate)b_Reward_ObjectActivate.Name="Reward_ObjectActivate"
b_Reward_ObjectActivate.Description.de="Reward: Activates an interactive object"
b_Reward_ObjectActivate.Description.en="Lohn: Aktiviert ein interaktives Objekt"b_Reward_ObjectActivate.GetReprisalTable=nil
b_Reward_ObjectActivate.GetRewardTable=function(R60Ru4bj,eQWRf)return
{Reward.Custom,{R60Ru4bj,R60Ru4bj.CustomFunction}}end;Core:RegisterBehavior(b_Reward_ObjectActivate)function Reward_ObjectInit(...)return
b_Reward_ObjectInit:new(...)end
b_Reward_ObjectInit={Name="Reward_ObjectInit",Description={en="Reward: Setup an interactive object with costs and rewards.",de="Lohn: Initialisiert ein interaktives Objekt mit seinen Kosten und Schätzen."},Parameter={{ParameterType.ScriptName,en="Interactive object",de="Interaktives Objekt"},{ParameterType.Number,en="Distance to use",de="Nutzungsentfernung"},{ParameterType.Number,en="Waittime",de="Wartezeit"},{ParameterType.Custom,en="Reward good",de="Belohnungsware"},{ParameterType.Number,en="Reward amount",de="Anzahl"},{ParameterType.Custom,en="Cost good 1",de="Kostenware 1"},{ParameterType.Number,en="Cost amount 1",de="Anzahl 1"},{ParameterType.Custom,en="Cost good 2",de="Kostenware 2"},{ParameterType.Number,en="Cost amount 2",de="Anzahl 2"},{ParameterType.Custom,en="Availability",de="Verfï¿½gbarkeit"}}}function b_Reward_ObjectInit:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_ObjectInit:AddParameter(WT2AX,_AvO)
if(
WT2AX==0)then self.ScriptName=_AvO elseif(WT2AX==1)then self.Distance=_AvO*1 elseif
(WT2AX==2)then self.Waittime=_AvO*1 elseif(WT2AX==3)then self.RewardType=_AvO elseif(WT2AX==4)then
self.RewardAmount=tonumber(_AvO)elseif(WT2AX==5)then self.FirstCostType=_AvO elseif(WT2AX==6)then
self.FirstCostAmount=tonumber(_AvO)elseif(WT2AX==7)then self.SecondCostType=_AvO elseif(WT2AX==8)then
self.SecondCostAmount=tonumber(_AvO)elseif(WT2AX==9)then local qEO=nil
if _AvO=="Always"or 1 then qEO=1 elseif _AvO=="Never"or 2 then qEO=2 elseif _AvO==
"Knight only"or 0 then qEO=0 end;self.UsingState=qEO end end
function b_Reward_ObjectInit:CustomFunction(q)local WUY7=GetID(self.ScriptName)if WUY7 ==0 then
return end;QSB.InitalizedObjekts[WUY7]=q.Identifier
Logic.InteractiveObjectClearCosts(WUY7)Logic.InteractiveObjectClearRewards(WUY7)
Logic.InteractiveObjectSetInteractionDistance(WUY7,self.Distance)
Logic.InteractiveObjectSetTimeToOpen(WUY7,self.Waittime)if self.RewardType and self.RewardType~="disabled"then
Logic.InteractiveObjectAddRewards(WUY7,Goods[self.RewardType],self.RewardAmount)end;if
self.FirstCostType and self.FirstCostType~="disabled"then
Logic.InteractiveObjectAddCosts(WUY7,Goods[self.FirstCostType],self.FirstCostAmount)end
if
self.SecondCostType and self.SecondCostType~="disabled"then
Logic.InteractiveObjectAddCosts(WUY7,Goods[self.SecondCostType],self.SecondCostAmount)end;Logic.InteractiveObjectSetAvailability(WUY7,true)
if
self.UsingState then for _puepou=1,8 do
Logic.InteractiveObjectSetPlayerState(WUY7,_puepou,self.UsingState)end end
Logic.InteractiveObjectSetRewardResourceCartType(WUY7,Entities.U_ResourceMerchant)
Logic.InteractiveObjectSetRewardGoldCartType(WUY7,Entities.U_GoldCart)
Logic.InteractiveObjectSetCostResourceCartType(WUY7,Entities.U_ResourceMerchant)
Logic.InteractiveObjectSetCostGoldCartType(WUY7,Entities.U_GoldCart)RemoveInteractiveObjectFromOpenedList(WUY7)
table.insert(HiddenTreasures,WUY7)end
function b_Reward_ObjectInit:GetCustomData(DYLeJ)
if DYLeJ==3 or DYLeJ==5 or DYLeJ==7 then
local udbF={"-","G_Beer","G_Bread","G_Broom","G_Carcass","G_Cheese","G_Clothes","G_Dye","G_Gold","G_Grain","G_Herb","G_Honeycomb","G_Iron","G_Leather","G_Medicine","G_Milk","G_RawFish","G_Salt","G_Sausage","G_SmokedFish","G_Soap","G_Stone","G_Water","G_Wood","G_Wool"}
if g_GameExtraNo>=1 then udbF[#udbF+1]="G_Gems"
udbF[#udbF+1]="G_MusicalInstrument"udbF[#udbF+1]="G_Olibanum"end;return udbF elseif DYLeJ==9 then return{"-","Knight only","Always","Never"}end end
function b_Reward_ObjectInit:DEBUG(dt1)
if
Logic.IsInteractiveObject(GetID(self.ScriptName))==false then
dbg(""..
dt1.Identifier.." "..
self.Name..": '"..self.ScriptName..
"' is not a interactive object!")return true end;if self.UsingState~=1 and self.Distance<50 then
warn(""..
dt1.Identifier.." "..
self.Name..": distance is maybe too short!")end;if
self.Waittime<0 then
dbg(""..dt1.Identifier..
" "..self.Name..": waittime must be equal or greater than 0!")return true end
if
self.RewardType and self.RewardType~="-"then
if
not Goods[self.RewardType]then
dbg(""..
dt1.Identifier.." "..self.Name..
": '"..self.RewardType.."' is invalid good type!")return true elseif self.RewardAmount<1 then
dbg(""..dt1.Identifier.." "..
self.Name..": amount can not be 0 or negative!")return true end end
if self.FirstCostType and self.FirstCostType~="-"then
if not
Goods[self.FirstCostType]then
dbg(""..dt1.Identifier..
" "..self.Name..": '"..
self.FirstCostType.."' is invalid good type!")return true elseif self.FirstCostAmount<1 then
dbg(""..dt1.Identifier.." "..
self.Name..": amount can not be 0 or negative!")return true end end
if self.SecondCostType and self.SecondCostType~="-"then
if not
Goods[self.SecondCostType]then
dbg(""..dt1.Identifier..
" "..self.Name..": '"..
self.SecondCostType.."' is invalid good type!")return true elseif self.SecondCostAmount<1 then
dbg(""..dt1.Identifier.." "..
self.Name..": amount can not be 0 or negative!")return true end end;return false end;Core:RegisterBehavior(b_Reward_ObjectInit)function Reward_ObjectSetCarts(...)return
b_Reward_ObjectSetCarts:new(...)end
b_Reward_ObjectSetCarts={Name="Reward_ObjectSetCarts",Description={en="Reward: Set the cart types of an interactive object.",de="Lohn: Setzt die Wagentypen eines interaktiven Objektes."},Parameter={{ParameterType.ScriptName,en="Interactive object",de="Interaktives Objekt"},{ParameterType.Default,en="Cost resource type",de="Rohstoffwagen Kosten"},{ParameterType.Default,en="Cost gold type",de="Goldwagen Kosten"},{ParameterType.Default,en="Reward resource type",de="Rohstoffwagen Schatz"},{ParameterType.Default,en="Reward gold type",de="Goldwagen Schatz"}}}function b_Reward_ObjectSetCarts:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_ObjectSetCarts:AddParameter(V7eMEiVW,Co1tUVas)
if
V7eMEiVW==0 then self.ScriptName=Co1tUVas elseif V7eMEiVW==1 then if
not Co1tUVas or Co1tUVas=="default"then Co1tUVas="U_ResourceMerchant"end
self.CostResourceCart=Co1tUVas elseif V7eMEiVW==2 then if not Co1tUVas or Co1tUVas=="default"then
Co1tUVas="U_GoldCart"end;self.CostGoldCart=Co1tUVas elseif V7eMEiVW==3 then
if
not Co1tUVas or Co1tUVas=="default"then Co1tUVas="U_ResourceMerchant"end;self.RewardResourceCart=Co1tUVas elseif V7eMEiVW==4 then if
not Co1tUVas or Co1tUVas=="default"then Co1tUVas="U_GoldCart"end
self.RewardGoldCart=Co1tUVas end end
function b_Reward_ObjectSetCarts:CustomFunction(B)local UjlBMb=GetID(self.ScriptName)
Logic.InteractiveObjectSetRewardResourceCartType(UjlBMb,Entities[self.RewardResourceCart])
Logic.InteractiveObjectSetRewardGoldCartType(UjlBMb,Entities[self.RewardGoldCart])
Logic.InteractiveObjectSetCostGoldCartType(UjlBMb,Entities[self.CostResourceCart])
Logic.InteractiveObjectSetCostResourceCartType(UjlBMb,Entities[self.CostGoldCart])end
function b_Reward_ObjectSetCarts:GetCustomData(PKWIJ9)
if PKWIJ9 ==2 or PKWIJ9 ==4 then return
{"U_GoldCart","U_GoldCart_Mission","U_Noblemen_Cart","U_RegaliaCart"}elseif PKWIJ9 ==1 or PKWIJ9 ==3 then
local rQYWEt={"U_ResourceMerchant","U_Medicus","U_Marketer"}if g_GameExtraNo>0 then
table.insert(rQYWEt,"U_NPC_Resource_Monk_AS")end;return rQYWEt end end
function b_Reward_ObjectSetCarts:DEBUG(nCwsa)
if



(not Entities[self.CostResourceCart])or(not Entities[self.CostGoldCart])or(not Entities[self.RewardResourceCart])or(not Entities[self.RewardGoldCart])then
dbg(""..
nCwsa.Identifier.." "..self.Name..": invalid cart type!")return true end;local IPPy=GetID(self.ScriptName)
if QSB.InitalizedObjekts[IPPy]and
QSB.InitalizedObjekts[IPPy]==nCwsa.Identifier then
dbg(""..

nCwsa.Identifier.." "..
self.Name..": you can not change carts in the same quest the object is initalized!")return true end;return false end;Core:RegisterBehavior(b_Reward_ObjectSetCarts)function Reward_Diplomacy(...)return
b_Reward_Diplomacy:new(...)end
b_Reward_Diplomacy=API.InstanceTable(b_Reprisal_Diplomacy)b_Reward_Diplomacy.Name="Reward_ObjectDeactivate"
b_Reward_Diplomacy.Description.de="Reward: Sets Diplomacy state of two Players to a stated value."
b_Reward_Diplomacy.Description.en="Lohn: Setzt den Diplomatiestatus zweier Spieler auf den angegebenen Wert."b_Reward_Diplomacy.GetReprisalTable=nil
b_Reward_Diplomacy.GetRewardTable=function(zYGA2q2,I9Mw)return
{Reward.Custom,{zYGA2q2,zYGA2q2.CustomFunction}}end;Core:RegisterBehavior(b_Reward_Diplomacy)function Reward_DiplomacyIncrease()return
b_Reward_DiplomacyIncrease:new()end
b_Reward_DiplomacyIncrease={Name="Reward_DiplomacyIncrease",Description={en="Reward: Diplomacy increases slightly to another player",de="Lohn: Verbesserug des Diplomatiestatus zu einem anderen Spieler"}}
function b_Reward_DiplomacyIncrease:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_DiplomacyIncrease:CustomFunction(e)local BUtIET=e.SendingPlayer
local NvAj=e.ReceivingPlayer;local Icg=GetDiplomacyState(NvAj,BUtIET)if Icg<2 then
SetDiplomacyState(NvAj,BUtIET,Icg+1)end end;function b_Reward_DiplomacyIncrease:AddParameter(PzMsk,axLuO)
if(PzMsk==0)then self.PlayerID=axLuO*1 end end
Core:RegisterBehavior(b_Reward_DiplomacyIncrease)
function Reward_TradeOffers(...)return b_Reward_TradeOffers:new(...)end
b_Reward_TradeOffers={Name="Reward_TradeOffers",Description={en="Reward: Deletes all existing offers for a merchant and sets new offers, if given",de="Lohn: Löscht alle Angebote eines Händlers und setzt neue, wenn angegeben"},Parameter={{ParameterType.Custom,en="PlayerID",de="PlayerID"},{ParameterType.Custom,en="Amount 1",de="Menge 1"},{ParameterType.Custom,en="Offer 1",de="Angebot 1"},{ParameterType.Custom,en="Amount 2",de="Menge 2"},{ParameterType.Custom,en="Offer 2",de="Angebot 2"},{ParameterType.Custom,en="Amount 3",de="Menge 3"},{ParameterType.Custom,en="Offer 3",de="Angebot 3"},{ParameterType.Custom,en="Amount 4",de="Menge 4"},{ParameterType.Custom,en="Offer 4",de="Angebot 4"}}}function b_Reward_TradeOffers:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_TradeOffers:AddParameter(j,As)
if(
j==0)then self.PlayerID=As elseif(j==1)then self.AmountOffer1=tonumber(As)elseif(j==2)then
self.Offer1=As elseif(j==3)then self.AmountOffer2=tonumber(As)elseif(j==4)then self.Offer2=As elseif(j==5)then
self.AmountOffer3=tonumber(As)elseif(j==6)then self.Offer3=As elseif(j==7)then self.AmountOffer4=tonumber(As)elseif(j==8)then
self.Offer4=As end end
function b_Reward_TradeOffers:CustomFunction()
if(self.PlayerID>1)and
(self.PlayerID<9)then
local JmCzKm=Logic.GetStoreHouse(self.PlayerID)Logic.RemoveAllOffers(JmCzKm)
for Mwhc=1,4 do
if self["Offer"..Mwhc]and self["Offer"..
Mwhc]~="-"then
if
Goods[self["Offer"..Mwhc]]then
AddOffer(JmCzKm,self["AmountOffer"..Mwhc],Goods[self["Offer"..Mwhc]])elseif
Logic.IsEntityTypeInCategory(Entities[self["Offer"..Mwhc]],EntityCategories.Military)==1 then
AddMercenaryOffer(JmCzKm,self["AmountOffer"..Mwhc],Entities[self[
"Offer"..Mwhc]])else
AddEntertainerOffer(JmCzKm,Entities[self["Offer"..Mwhc]])end end end end end
function b_Reward_TradeOffers:DEBUG(A6z)
if
Logic.GetStoreHouse(self.PlayerID)==0 then
dbg(A6z.Identifier..": Error in "..self.Name..
": Player "..self.PlayerID.." is dead. :-(")return true end end
function b_Reward_TradeOffers:GetCustomData(_Mk)local PXrrrSid={"2","3","4","5","6","7","8"}
local L9={"1","2","3","4","5","6","7","8","9"}
local _={"-","G_Beer","G_Bow","G_Bread","G_Broom","G_Candle","G_Carcass","G_Cheese","G_Clothes","G_Cow","G_Grain","G_Herb","G_Honeycomb","G_Iron","G_Leather","G_Medicine","G_Milk","G_RawFish","G_Sausage","G_Sheep","G_SmokedFish","G_Soap","G_Stone","G_Sword","G_Wood","G_Wool","G_Salt","G_Dye","U_AmmunitionCart","U_BatteringRamCart","U_CatapultCart","U_SiegeTowerCart","U_MilitaryBandit_Melee_ME","U_MilitaryBandit_Melee_SE","U_MilitaryBandit_Melee_NA","U_MilitaryBandit_Melee_NE","U_MilitaryBandit_Ranged_ME","U_MilitaryBandit_Ranged_NA","U_MilitaryBandit_Ranged_NE","U_MilitaryBandit_Ranged_SE","U_MilitaryBow_RedPrince","U_MilitaryBow","U_MilitarySword_RedPrince","U_MilitarySword","U_Entertainer_NA_FireEater","U_Entertainer_NA_StiltWalker","U_Entertainer_NE_StrongestMan_Barrel","U_Entertainer_NE_StrongestMan_Stone"}
if g_GameExtraNo and g_GameExtraNo>=1 then
table.insert(_,"G_Gems")table.insert(_,"G_Olibanum")
table.insert(_,"G_MusicalInstrument")table.insert(_,"G_MilitaryBandit_Ranged_AS")
table.insert(_,"G_MilitaryBandit_Melee_AS")table.insert(_,"U_MilitarySword_Khana")
table.insert(_,"U_MilitaryBow_Khana")end
if(_Mk==0)then return PXrrrSid elseif(_Mk==1)or(_Mk==3)or(_Mk==5)or
(_Mk==7)then return L9 elseif(_Mk==2)or(_Mk==4)or(_Mk==6)or(
_Mk==8)then return _ end end;Core:RegisterBehavior(b_Reward_TradeOffers)function Reward_DestroyEntity(...)return
b_Reward_DestroyEntity:new(...)end
b_Reward_DestroyEntity=API.InstanceTable(b_Reprisal_DestroyEntity)b_Reward_DestroyEntity.Name="Reward_DestroyEntity"
b_Reward_DestroyEntity.Description.en="Reward: Replaces an entity with an invisible script entity, which retains the entities name."
b_Reward_DestroyEntity.Description.de="Lohn: Ersetzt eine Entity mit einer unsichtbaren Script-Entity, die den Namen übernimmt."b_Reward_DestroyEntity.GetReprisalTable=nil
b_Reward_DestroyEntity.GetRewardTable=function(KZPScl,dbTwy)return
{Reward.Custom,{KZPScl,KZPScl.CustomFunction}}end;Core:RegisterBehavior(b_Reward_DestroyEntity)function Reward_DestroyEffect(...)return
b_Reward_DestroyEffect:new(...)end
b_Reward_DestroyEffect=API.InstanceTable(b_Reprisal_DestroyEffect)b_Reward_DestroyEffect.Name="Reward_DestroyEffect"
b_Reward_DestroyEffect.Description.en="Reward: Destroys an effect."
b_Reward_DestroyEffect.Description.de="Lohn: Zerstört einen Effekt."b_Reward_DestroyEffect.GetReprisalTable=nil
b_Reward_DestroyEffect.GetRewardTable=function(R4f819q,Kj1I)return
{Reward.Custom,{R4f819q,R4f819q.CustomFunction}}end;Core:RegisterBehavior(b_Reward_DestroyEffect)function Reward_CreateBattalion(...)return
b_Reward_CreateBattalion:new(...)end
b_Reward_CreateBattalion={Name="Reward_CreateBattalion",Description={en="Reward: Replaces a script entity with a battalion, which retains the entities name",de="Lohn: Ersetzt eine Script-Entity durch ein Bataillon, welches den Namen der Script-Entity übernimmt"},Parameter={{ParameterType.ScriptName,en="Script entity",de="Script Entity"},{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Orientation (in degrees)",de="Ausrichtung (in Grad)"},{ParameterType.Number,en="Number of soldiers",de="Anzahl Soldaten"},{ParameterType.Custom,en="Hide from AI",de="Vor KI verstecken"}}}
function b_Reward_CreateBattalion:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_CreateBattalion:AddParameter(n,TUMgqomA)
if(n==0)then self.ScriptNameEntity=TUMgqomA elseif(n==1)then self.PlayerID=
TUMgqomA*1 elseif(n==2)then self.UnitKey=TUMgqomA elseif(n==3)then
self.Orientation=TUMgqomA*1 elseif(n==4)then self.SoldierCount=TUMgqomA*1 elseif(n==5)then
self.HideFromAI=AcceptAlternativeBoolean(TUMgqomA)end end
function b_Reward_CreateBattalion:CustomFunction(Id5sIM)if
not IsExisting(self.ScriptNameEntity)then return false end
local gZM2ANLt=GetPosition(self.ScriptNameEntity)
local aC72qEnu=Logic.CreateBattalionOnUnblockedLand(Entities[self.UnitKey],gZM2ANLt.X,gZM2ANLt.Y,self.Orientation,self.PlayerID,self.SoldierCount)local B60J=GetID(self.ScriptNameEntity)if
Logic.IsBuilding(B60J)==0 then DestroyEntity(self.ScriptNameEntity)
Logic.SetEntityName(aC72qEnu,self.ScriptNameEntity)end;if self.HideFromAI then
AICore.HideEntityFromAI(self.PlayerID,aC72qEnu,true)end end
function b_Reward_CreateBattalion:GetCustomData(Y4)local f={}
if Y4 ==2 then for yeCnvcd6,Iq93c6cA in pairs(Entities)do
if
Logic.IsEntityTypeInCategory(Iq93c6cA,EntityCategories.Soldier)==1 then table.insert(f,yeCnvcd6)end end
table.sort(f)elseif Y4 ==5 then table.insert(f,"false")table.insert(f,"true")else
assert(false)end;return f end
function b_Reward_CreateBattalion:DEBUG(nsM0h)
if not Entities[self.UnitKey]then
dbg(nsM0h.Identifier..
" "..self.Name..": got an invalid entity type!")return true elseif not IsExisting(self.ScriptNameEntity)then
dbg(nsM0h.Identifier.." "..
self.Name..": spawnpoint does not exist!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<1 or self.PlayerID>8 then
dbg(nsM0h.Identifier.." "..self.Name..
": playerID is wrong!")return true elseif tonumber(self.Orientation)==nil then
dbg(nsM0h.Identifier.." "..self.Name..
": orientation must be a number!")return true elseif
tonumber(self.SoldierCount)==nil or self.SoldierCount<1 then
dbg(nsM0h.Identifier..
" "..self.Name..": you can not create a empty batallion!")return true end;return false end;Core:RegisterBehavior(b_Reward_CreateBattalion)function Reward_CreateSeveralBattalions(...)return
b_Reward_CreateSeveralBattalions:new(...)end
b_Reward_CreateSeveralBattalions={Name="Reward_CreateSeveralBattalions",Description={en="Reward: Creates a given amount of battalions",de="Lohn: Erstellt eine gegebene Anzahl Bataillone"},Parameter={{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.ScriptName,en="Script entity",de="Script Entity"},{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Orientation (in degrees)",de="Ausrichtung (in Grad)"},{ParameterType.Number,en="Number of soldiers",de="Anzahl Soldaten"},{ParameterType.Custom,en="Hide from AI",de="Vor KI verstecken"}}}
function b_Reward_CreateSeveralBattalions:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_CreateSeveralBattalions:AddParameter(Czi,IlxN)
if(Czi==0)then self.Amount=IlxN*1 elseif
(Czi==1)then self.ScriptNameEntity=IlxN elseif(Czi==2)then self.PlayerID=IlxN*1 elseif(Czi==3)then
self.UnitKey=IlxN elseif(Czi==4)then self.Orientation=IlxN*1 elseif(Czi==5)then self.SoldierCount=IlxN*1 elseif
(Czi==6)then self.HideFromAI=AcceptAlternativeBoolean(IlxN)end end
function b_Reward_CreateSeveralBattalions:CustomFunction(E)if
not IsExisting(self.ScriptNameEntity)then return false end
local A_3x01A=GetID(self.ScriptNameEntity)local m54tY2,WJWMdKI,AhbP=Logic.EntityGetPos(A_3x01A)if
Logic.IsBuilding(A_3x01A)==1 then
m54tY2,WJWMdKI=Logic.GetBuildingApproachPosition(A_3x01A)end
for QHFgYUN=1,self.Amount do
local RoEsr7So=Logic.CreateBattalionOnUnblockedLand(Entities[self.UnitKey],m54tY2,WJWMdKI,self.Orientation,self.PlayerID,self.SoldierCount)
Logic.SetEntityName(RoEsr7So,self.ScriptNameEntity.."_"..QHFgYUN)if self.HideFromAI then
AICore.HideEntityFromAI(self.PlayerID,RoEsr7So,true)end end end
function b_Reward_CreateSeveralBattalions:GetCustomData(dX)local Rz={}
if dX==3 then for j177r,j in pairs(Entities)do
if
Logic.IsEntityTypeInCategory(j,EntityCategories.Soldier)==1 then table.insert(Rz,j177r)end end
table.sort(Rz)elseif dX==6 then table.insert(Rz,"false")
table.insert(Rz,"true")else assert(false)end;return Rz end
function b_Reward_CreateSeveralBattalions:DEBUG(qCaFw)
if not Entities[self.UnitKey]then
dbg(
qCaFw.Identifier.." "..self.Name..": got an invalid entity type!")return true elseif not IsExisting(self.ScriptNameEntity)then
dbg(qCaFw.Identifier.." "..
self.Name..": spawnpoint does not exist!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<1 or self.PlayerID>8 then
dbg(qCaFw.Identifier.." "..self.Name..
": playerDI is wrong!")return true elseif tonumber(self.Orientation)==nil then
dbg(qCaFw.Identifier.." "..self.Name..
": orientation must be a number!")return true elseif
tonumber(self.SoldierCount)==nil or self.SoldierCount<1 then
dbg(qCaFw.Identifier..
" "..self.Name..": you can not create a empty batallion!")return true elseif
tonumber(self.Amount)==nil or self.Amount<0 then
dbg(qCaFw.Identifier..
" "..self.Name..": amount can not be negative!")return true end;return false end
Core:RegisterBehavior(b_Reward_CreateSeveralBattalions)
function Reward_CreateEffect(...)return b_Reward_CreateEffect:new(...)end
b_Reward_CreateEffect={Name="Reward_CreateEffect",Description={en="Reward: Creates an effect at a specified position",de="Lohn: Erstellt einen Effekt an der angegebenen Position"},Parameter={{ParameterType.Default,en="Effect name",de="Effektname"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.ScriptName,en="Location",de="Ort"},{ParameterType.Number,en="Orientation (in degrees)(-1: from locating entity)",de="Ausrichtung (in Grad)(-1: von Positionseinheit)"}}}
function b_Reward_CreateEffect:AddParameter(syvPi,NrgSK2)
if syvPi==0 then self.EffectName=NrgSK2 elseif syvPi==1 then
self.Type=EGL_Effects[NrgSK2]elseif syvPi==2 then self.PlayerID=NrgSK2*1 elseif syvPi==3 then self.Location=NrgSK2 elseif syvPi==4 then self.Orientation=
NrgSK2*1 end end
function b_Reward_CreateEffect:GetRewardTable(wIH)return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_CreateEffect:CustomFunction(TYWkpc)
if Logic.IsEntityDestroyed(self.Location)then return end
local k=assert(GetID(self.Location),TYWkpc.Identifier.."Error in "..
self.Name..": CustomFunction: Entity is invalid")
if QSB.EffectNameToID[self.EffectName]and
Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName])then return end;local J,gtlO9=Logic.GetEntityPosition(k)
local Lun=tonumber(self.Orientation)
local beUJXhjw=Logic.CreateEffectWithOrientation(self.Type,J,gtlO9,Lun,self.PlayerID)if self.EffectName~=""then
QSB.EffectNameToID[self.EffectName]=beUJXhjw end end
function b_Reward_CreateEffect:DEBUG(zY7adu)
if QSB.EffectNameToID[self.EffectName]and
Logic.IsEffectRegistered(QSB.EffectNameToID[self.EffectName])then
dbg(""..zY7adu.Identifier.." "..self.Name..
": effect already exists!")return true elseif not IsExisting(self.Location)then
sbg(""..zY7adu.Identifier.." "..
self.Name..
": location '"..self.Location.."' is missing!")return true elseif self.PlayerID and
(self.PlayerID<0 or self.PlayerID>8)then
dbg(""..zY7adu.Identifier.." "..
self.Name..": invalid playerID!")return true elseif tonumber(self.Orientation)==nil then
dbg(""..zY7adu.Identifier.." "..self.Name..
": invalid orientation!")return true end end
function b_Reward_CreateEffect:GetCustomData(Nlvw)
assert(Nlvw==1,"Error in "..
self.Name..": GetCustomData: Index is invalid.")local K55={}
for BJcMTdMi,f1MKKJ in pairs(EGL_Effects)do table.insert(K55,BJcMTdMi)end;table.sort(K55)return K55 end;Core:RegisterBehavior(b_Reward_CreateEffect)function Reward_CreateEntity(...)return
b_Reward_CreateEntity:new(...)end
b_Reward_CreateEntity={Name="Reward_CreateEntity",Description={en="Reward: Replaces an entity by a new one of a given type",de="Lohn: Ersetzt eine Entity durch eine neue gegebenen Typs"},Parameter={{ParameterType.ScriptName,en="Script entity",de="Script Entity"},{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Orientation (in degrees)",de="Ausrichtung (in Grad)"},{ParameterType.Custom,en="Hide from AI",de="Vor KI verstecken"}}}function b_Reward_CreateEntity:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_CreateEntity:AddParameter(nFf,EIqL41)
if(
nFf==0)then self.ScriptNameEntity=EIqL41 elseif(nFf==1)then self.PlayerID=EIqL41*1 elseif(
nFf==2)then self.UnitKey=EIqL41 elseif(nFf==3)then self.Orientation=EIqL41*1 elseif
(nFf==4)then self.HideFromAI=AcceptAlternativeBoolean(EIqL41)end end
function b_Reward_CreateEntity:CustomFunction(iv)if
not IsExisting(self.ScriptNameEntity)then return false end
local rfmMR4=GetPosition(self.ScriptNameEntity)local Tq2I
if
Logic.IsEntityTypeInCategory(self.UnitKey,EntityCategories.Soldier)==1 then
Tq2I=Logic.CreateBattalionOnUnblockedLand(Entities[self.UnitKey],rfmMR4.X,rfmMR4.Y,self.Orientation,self.PlayerID,1)
local e5x,QrONvWGq={Logic.GetSoldiersAttachedToLeader(Tq2I)}Logic.SetOrientation(QrONvWGq,self.Orientation)else
Tq2I=Logic.CreateEntityOnUnblockedLand(Entities[self.UnitKey],rfmMR4.X,rfmMR4.Y,self.Orientation,self.PlayerID)end;local GNo=GetID(self.ScriptNameEntity)if
Logic.IsBuilding(GNo)==0 then DestroyEntity(self.ScriptNameEntity)
Logic.SetEntityName(Tq2I,self.ScriptNameEntity)end;if self.HideFromAI then
AICore.HideEntityFromAI(self.PlayerID,Tq2I,true)end end
function b_Reward_CreateEntity:GetCustomData(D94fnZaa)local XI={}
if D94fnZaa==2 then
for FNi,pRW2nEmK in pairs(Entities)do
local OR={"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}local Arww=false
for BYH=1,#OR do if FNi:find(OR[BYH])then Arww=true;break end end;if not Arww then table.insert(XI,FNi)end end;table.sort(XI)elseif D94fnZaa==4 or D94fnZaa==5 then
table.insert(XI,"false")table.insert(XI,"true")else assert(false)end;return XI end
function b_Reward_CreateEntity:DEBUG(o7E8TLH)
if not Entities[self.UnitKey]then
dbg(o7E8TLH.Identifier..
" "..self.Name..": got an invalid entity type!")return true elseif not IsExisting(self.ScriptNameEntity)then
dbg(o7E8TLH.Identifier..
" "..self.Name..": spawnpoint does not exist!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<0 or self.PlayerID>8 then
dbg(o7E8TLH.Identifier.." "..self.Name..
": playerID is not valid!")return true elseif tonumber(self.Orientation)==nil then
dbg(o7E8TLH.Identifier.." "..self.Name..
": orientation must be a number!")return true end;return false end;Core:RegisterBehavior(b_Reward_CreateEntity)function Reward_CreateSeveralEntities(...)return
b_Reward_CreateSeveralEntities:new(...)end
b_Reward_CreateSeveralEntities={Name="Reward_CreateSeveralEntities",Description={en="Reward: Creating serveral battalions at the position of a entity. They retains the entities name and a _[index] suffix",de="Lohn: Erzeugt mehrere Entities an der Position der Entity. Sie übernimmt den Namen der Script Entity und den Suffix _[index]"},Parameter={{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.ScriptName,en="Script entity",de="Script Entity"},{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Orientation (in degrees)",de="Ausrichtung (in Grad)"},{ParameterType.Custom,en="Hide from AI",de="Vor KI verstecken"}}}
function b_Reward_CreateSeveralEntities:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_CreateSeveralEntities:AddParameter(N5N27Jd,m)
if(N5N27Jd==0)then self.Amount=m*1 elseif
(N5N27Jd==1)then self.ScriptNameEntity=m elseif(N5N27Jd==2)then self.PlayerID=m*1 elseif(N5N27Jd==3)then
self.UnitKey=m elseif(N5N27Jd==4)then self.Orientation=m*1 elseif(N5N27Jd==5)then
self.HideFromAI=AcceptAlternativeBoolean(m)end end
function b_Reward_CreateSeveralEntities:CustomFunction(nK)if
not IsExisting(self.ScriptNameEntity)then return false end
local _zr=GetPosition(self.ScriptNameEntity)local f5
for UAc=1,self.Amount do
if
Logic.IsEntityTypeInCategory(self.UnitKey,EntityCategories.Soldier)==1 then
f5=Logic.CreateBattalionOnUnblockedLand(Entities[self.UnitKey],_zr.X,_zr.Y,self.Orientation,self.PlayerID,1)
local E,f={Logic.GetSoldiersAttachedToLeader(f5)}Logic.SetOrientation(f,self.Orientation)else
f5=Logic.CreateEntityOnUnblockedLand(Entities[self.UnitKey],_zr.X,_zr.Y,self.Orientation,self.PlayerID)end
Logic.SetEntityName(f5,self.ScriptNameEntity.."_"..UAc)if self.HideFromAI then
AICore.HideEntityFromAI(self.PlayerID,f5,true)end end end
function b_Reward_CreateSeveralEntities:GetCustomData(P)local F4AWvI={}
if P==3 then
for GYVN,DNlB1V in pairs(Entities)do
local erb6G_E={"^M_*","^XS_*","^X_*","^XT_*","^Z_*"}local QFUU10K=false;for xNPDtul=1,#erb6G_E do
if GYVN:find(erb6G_E[xNPDtul])then QFUU10K=true;break end end;if not QFUU10K then
table.insert(F4AWvI,GYVN)end end;table.sort(F4AWvI)elseif P==5 or P==6 then
table.insert(F4AWvI,"false")table.insert(F4AWvI,"true")else assert(false)end;return F4AWvI end
function b_Reward_CreateSeveralEntities:DEBUG(k8)
if not Entities[self.UnitKey]then
dbg(
k8.Identifier.." "..self.Name..": got an invalid entity type!")return true elseif not IsExisting(self.ScriptNameEntity)then
dbg(k8.Identifier.." "..
self.Name..": spawnpoint does not exist!")return true elseif
tonumber(self.PlayerID)==nil or self.PlayerID<1 or self.PlayerID>8 then
dbg(k8.Identifier.." "..self.Name..
": spawnpoint does not exist!")return true elseif tonumber(self.Orientation)==nil then
dbg(k8.Identifier.." "..self.Name..
": orientation must be a number!")return true elseif
tonumber(self.Amount)==nil or self.Amount<0 then
dbg(k8.Identifier..
" "..self.Name..": amount can not be negative!")return true end;return false end
Core:RegisterBehavior(b_Reward_CreateSeveralEntities)
function Reward_MoveSettler(...)return b_Reward_MoveSettler:new(...)end
b_Reward_MoveSettler={Name="Reward_MoveSettler",Description={en="Reward: Moves a (NPC) settler to a destination. Must not be AI controlled, or it won't move",de="Lohn: Bewegt einen (NPC) Siedler zu einem Zielort. Darf keinem KI Spieler gehören, ansonsten wird sich der Siedler nicht bewegen"},Parameter={{ParameterType.ScriptName,en="Settler",de="Siedler"},{ParameterType.ScriptName,en="Destination",de="Ziel"}}}function b_Reward_MoveSettler:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_MoveSettler:AddParameter(HmgRk,UuCdpVi)if(
HmgRk==0)then self.ScriptNameUnit=UuCdpVi elseif(HmgRk==1)then
self.ScriptNameDest=UuCdpVi end end
function b_Reward_MoveSettler:CustomFunction(fghe)
if Logic.IsEntityDestroyed(self.ScriptNameUnit)or
Logic.IsEntityDestroyed(self.ScriptNameDest)then return false end;local vFXf=GetID(self.ScriptNameDest)
local CA0uX7n,ze5Vpc3=Logic.GetEntityPosition(vFXf)if Logic.IsBuilding(vFXf)==1 then
CA0uX7n,ze5Vpc3=Logic.GetBuildingApproachPosition(vFXf)end
Logic.MoveSettler(GetID(self.ScriptNameUnit),CA0uX7n,ze5Vpc3)end
function b_Reward_MoveSettler:DEBUG(vwK8)
if
not not IsExisting(self.ScriptNameUnit)then
dbg(vwK8.Identifier..
" "..self.Name..": mover entity does not exist!")return true elseif not IsExisting(self.ScriptNameDest)then
dbg(vwK8.Identifier.." "..
self.Name..": destination does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reward_MoveSettler)function Reward_Victory()return
b_Reward_Victory:new()end
b_Reward_Victory={Name="Reward_Victory",Description={en="Reward: The player wins the game.",de="Lohn: Der Spieler gewinnt das Spiel."}}
function b_Reward_Victory:GetRewardTable(Sk_SiC)return{Reward.Victory}end;Core:RegisterBehavior(b_Reward_Victory)function Reward_Defeat()return
b_Reward_Defeat:new()end
b_Reward_Defeat={Name="Reward_Defeat",Description={en="Reward: The player loses the game.",de="Lohn: Der Spieler verliert das Spiel."}}function b_Reward_Defeat:GetRewardTable(X0bgPvA)return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_Defeat:CustomFunction(M9CyqH)
M9CyqH:TerminateEventsAndStuff()
Logic.ExecuteInLuaLocalState("GUI_Window.MissionEndScreenSetVictoryReasonText("..
g_VictoryAndDefeatType.DefeatMissionFailed..")")Defeated(M9CyqH.ReceivingPlayer)end;Core:RegisterBehavior(b_Reward_Defeat)function Reward_FakeVictory()return
b_Reward_FakeVictory:new()end
b_Reward_FakeVictory={Name="Reward_FakeVictory",Description={en="Reward: Display a victory icon for a quest",de="Lohn: Zeigt ein Siegesicon fuer diese Quest"}}
function b_Reward_FakeVictory:GetRewardTable()return{Reward.FakeVictory}end;Core:RegisterBehavior(b_Reward_FakeVictory)
function Reward_AI_SpawnAndAttackTerritory(...)return
b_Reward_AI_SpawnAndAttackTerritory:new(...)end
b_Reward_AI_SpawnAndAttackTerritory={Name="Reward_AI_SpawnAndAttackTerritory",Description={en="Reward: Spawns AI troops and attacks a territory (Hint: Use for hidden quests as a surprise)",de="Lohn: Erstellt KI Truppen und greift ein Territorium an (Tipp: Fuer eine versteckte Quest als Ueberraschung verwenden)"},Parameter={{ParameterType.PlayerID,en="AI Player",de="KI Spieler"},{ParameterType.ScriptName,en="Spawn point",de="Erstellungsort"},{ParameterType.TerritoryName,en="Territory",de="Territorium"},{ParameterType.Number,en="Sword",de="Schwert"},{ParameterType.Number,en="Bow",de="Bogen"},{ParameterType.Number,en="Catapults",de="Katapulte"},{ParameterType.Number,en="Siege towers",de="Belagerungstuerme"},{ParameterType.Number,en="Rams",de="Rammen"},{ParameterType.Number,en="Ammo carts",de="Munitionswagen"},{ParameterType.Custom,en="Soldier type",de="Soldatentyp"},{ParameterType.Custom,en="Reuse troops",de="Verwende bestehende Truppen"}}}
function b_Reward_AI_SpawnAndAttackTerritory:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_SpawnAndAttackTerritory:AddParameter(z0x4qSAN,X0GTupeV)
if(z0x4qSAN==0)then
self.AIPlayerID=X0GTupeV*1 elseif(z0x4qSAN==1)then self.Spawnpoint=X0GTupeV elseif(z0x4qSAN==2)then
self.TerritoryID=tonumber(X0GTupeV)if not self.TerritoryID then
self.TerritoryID=GetTerritoryIDByName(X0GTupeV)end elseif(z0x4qSAN==3)then
self.NumSword=X0GTupeV*1 elseif(z0x4qSAN==4)then self.NumBow=X0GTupeV*1 elseif(z0x4qSAN==5)then self.NumCatapults=
X0GTupeV*1 elseif(z0x4qSAN==6)then self.NumSiegeTowers=X0GTupeV*1 elseif(
z0x4qSAN==7)then self.NumRams=X0GTupeV*1 elseif(z0x4qSAN==8)then
self.NumAmmoCarts=X0GTupeV*1 elseif(z0x4qSAN==9)then
if X0GTupeV=="Normal"or X0GTupeV==false then
self.TroopType=false elseif X0GTupeV=="RedPrince"or X0GTupeV==true then self.TroopType=true elseif
X0GTupeV=="Bandit"or X0GTupeV==2 then self.TroopType=2 elseif
X0GTupeV=="Cultist"or X0GTupeV==3 then self.TroopType=3 else assert(false)end elseif(z0x4qSAN==10)then
self.ReuseTroops=AcceptAlternativeBoolean(X0GTupeV)end end
function b_Reward_AI_SpawnAndAttackTerritory:GetCustomData(rQ)local k={}
if rQ==9 then
table.insert(k,"Normal")table.insert(k,"RedPrince")
table.insert(k,"Bandit")
if g_GameExtraNo>=1 then table.insert(k,"Cultist")end elseif rQ==10 then table.insert(k,"false")table.insert(k,"true")else
assert(false)end;return k end
function b_Reward_AI_SpawnAndAttackTerritory:CustomFunction(Oc)
local IHovU=Logic.GetTerritoryAcquiringBuildingID(self.TerritoryID)
if IHovU~=0 then
AIScript_SpawnAndAttackCity(self.AIPlayerID,IHovU,self.Spawnpoint,self.NumSword,self.NumBow,self.NumCatapults,self.NumSiegeTowers,self.NumRams,self.NumAmmoCarts,self.TroopType,self.ReuseTroops)end end
function b_Reward_AI_SpawnAndAttackTerritory:DEBUG(e_wDQjk)
if self.AIPlayerID<2 then
dbg(e_wDQjk.Identifier..
": Error in "..
self.Name..": Player "..self.AIPlayerID.." is wrong")return true elseif Logic.IsEntityDestroyed(self.Spawnpoint)then
dbg(e_wDQjk.Identifier.." "..
self.Name..
": Entity "..self.SpawnPoint.." is missing")return true elseif self.TerritoryID==0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": Territory unknown")return true elseif self.NumSword<0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": Number of Swords is negative")return true elseif self.NumBow<0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": Number of Bows is negative")return true elseif self.NumBow+self.NumSword<1 then
dbg(e_wDQjk.Identifier.." "..self.Name..
": No Soldiers?")return true elseif self.NumCatapults<0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": Catapults is negative")return true elseif self.NumSiegeTowers<0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": SiegeTowers is negative")return true elseif self.NumRams<0 then
dbg(e_wDQjk.Identifier..
" "..self.Name..": Rams is negative")return true elseif self.NumAmmoCarts<0 then
dbg(e_wDQjk.Identifier.." "..
self.Name..": AmmoCarts is negative")return true end;return false end
Core:RegisterBehavior(b_Reward_AI_SpawnAndAttackTerritory)function Reward_AI_SpawnAndAttackArea(...)
return b_Reward_AI_SpawnAndAttackArea:new(...)end
b_Reward_AI_SpawnAndAttackArea={Name="Reward_AI_SpawnAndAttackArea",Description={en="Reward: Spawns AI troops and attacks everything within the specified area, except the players main buildings",de="Lohn: Erstellt KI Truppen und greift ein angegebenes Gebiet an, aber nicht die Hauptgebauede eines Spielers"},Parameter={{ParameterType.PlayerID,en="AI Player",de="KI Spieler"},{ParameterType.ScriptName,en="Spawn point",de="Erstellungsort"},{ParameterType.ScriptName,en="Target",de="Ziel"},{ParameterType.Number,en="Radius",de="Radius"},{ParameterType.Number,en="Sword",de="Schwert"},{ParameterType.Number,en="Bow",de="Bogen"},{ParameterType.Custom,en="Soldier type",de="Soldatentyp"},{ParameterType.Custom,en="Reuse troops",de="Verwende bestehende Truppen"}}}
function b_Reward_AI_SpawnAndAttackArea:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_SpawnAndAttackArea:AddParameter(ClglY,S)
if(ClglY==0)then self.AIPlayerID=S*1 elseif
(ClglY==1)then self.Spawnpoint=S elseif(ClglY==2)then self.TargetName=S elseif(ClglY==3)then
self.Radius=S*1 elseif(ClglY==4)then self.NumSword=S*1 elseif(ClglY==5)then self.NumBow=S*1 elseif(ClglY==6)then
if S==
"Normal"or S==false then self.TroopType=false elseif
S=="RedPrince"or S==true then self.TroopType=true elseif S=="Bandit"or S==2 then self.TroopType=2 elseif
S=="Cultist"or S==3 then self.TroopType=3 else assert(false)end elseif(ClglY==7)then self.ReuseTroops=AcceptAlternativeBoolean(S)end end
function b_Reward_AI_SpawnAndAttackArea:GetCustomData(NKetZhs)local EFLZ0N1={}
if NKetZhs==6 then
table.insert(EFLZ0N1,"Normal")table.insert(EFLZ0N1,"RedPrince")
table.insert(EFLZ0N1,"Bandit")
if g_GameExtraNo>=1 then table.insert(EFLZ0N1,"Cultist")end elseif NKetZhs==7 then table.insert(EFLZ0N1,"false")
table.insert(EFLZ0N1,"true")else assert(false)end;return EFLZ0N1 end
function b_Reward_AI_SpawnAndAttackArea:CustomFunction(gL)
if

Logic.IsEntityAlive(self.TargetName)and Logic.IsEntityAlive(self.Spawnpoint)then local m4=GetID(self.TargetName)
AIScript_SpawnAndRaidSettlement(self.AIPlayerID,m4,self.Spawnpoint,self.Radius,self.NumSword,self.NumBow,self.TroopType,self.ReuseTroops)end end
function b_Reward_AI_SpawnAndAttackArea:DEBUG(rNOL8G)
if self.AIPlayerID<2 then
dbg(rNOL8G.Identifier.." "..
self.Name..
": Player "..self.AIPlayerID.." is wrong")return true elseif Logic.IsEntityDestroyed(self.Spawnpoint)then
dbg(rNOL8G.Identifier.." "..
self.Name..
": Entity "..self.SpawnPoint.." is missing")return true elseif Logic.IsEntityDestroyed(self.TargetName)then
dbg(rNOL8G.Identifier.." "..
self.Name..
": Entity "..self.TargetName.." is missing")return true elseif self.Radius<1 then
dbg(rNOL8G.Identifier.." "..
self.Name..": Radius is to small or negative")return true elseif self.NumSword<0 then
dbg(rNOL8G.Identifier.." "..
self.Name..": Number of Swords is negative")return true elseif self.NumBow<0 then
dbg(rNOL8G.Identifier.." "..
self.Name..": Number of Bows is negative")return true elseif self.NumBow+self.NumSword<1 then
dbg(rNOL8G.Identifier..": Error in "..
self.Name..": No Soldiers?")return true end;return false end
Core:RegisterBehavior(b_Reward_AI_SpawnAndAttackArea)function Reward_AI_SpawnAndProtectArea(...)
return b_Reward_AI_SpawnAndProtectArea:new(...)end
b_Reward_AI_SpawnAndProtectArea={Name="Reward_AI_SpawnAndProtectArea",Description={en="Reward: Spawns AI troops and defends a specified area",de="Lohn: Erstellt KI Truppen und verteidigt ein angegebenes Gebiet"},Parameter={{ParameterType.PlayerID,en="AI Player",de="KI Spieler"},{ParameterType.ScriptName,en="Spawn point",de="Erstellungsort"},{ParameterType.ScriptName,en="Target",de="Ziel"},{ParameterType.Number,en="Radius",de="Radius"},{ParameterType.Number,en="Time (-1 for infinite)",de="Zeit (-1 fuer unendlich)"},{ParameterType.Number,en="Sword",de="Schwert"},{ParameterType.Number,en="Bow",de="Bogen"},{ParameterType.Custom,en="Capture tradecarts",de="Handelskarren angreifen"},{ParameterType.Custom,en="Soldier type",de="Soldatentyp"},{ParameterType.Custom,en="Reuse troops",de="Verwende bestehende Truppen"}}}
function b_Reward_AI_SpawnAndProtectArea:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_SpawnAndProtectArea:AddParameter(q,lKO)
if(q==0)then self.AIPlayerID=lKO*1 elseif(q==1)then
self.Spawnpoint=lKO elseif(q==2)then self.TargetName=lKO elseif(q==3)then self.Radius=lKO*1 elseif(q==4)then
self.Time=lKO*1 elseif(q==5)then self.NumSword=lKO*1 elseif(q==6)then self.NumBow=lKO*1 elseif(q==7)then
self.CaptureTradeCarts=AcceptAlternativeBoolean(lKO)elseif(q==8)then
if lKO=="Normal"or lKO==true then self.TroopType=false elseif lKO=="RedPrince"or
lKO==false then self.TroopType=true elseif lKO=="Bandit"or lKO==2 then
self.TroopType=2 elseif lKO=="Cultist"or lKO==3 then self.TroopType=3 else assert(false)end elseif(q==9)then self.ReuseTroops=AcceptAlternativeBoolean(lKO)end end
function b_Reward_AI_SpawnAndProtectArea:GetCustomData(hcwgu)local omgCdqp8={}
if hcwgu==7 then
table.insert(omgCdqp8,"false")table.insert(omgCdqp8,"true")elseif hcwgu==8 then
table.insert(omgCdqp8,"Normal")table.insert(omgCdqp8,"RedPrince")
table.insert(omgCdqp8,"Bandit")
if g_GameExtraNo>=1 then table.insert(omgCdqp8,"Cultist")end elseif hcwgu==9 then table.insert(omgCdqp8,"false")
table.insert(omgCdqp8,"true")else assert(false)end;return omgCdqp8 end
function b_Reward_AI_SpawnAndProtectArea:CustomFunction(X17eHTx)
if

Logic.IsEntityAlive(self.TargetName)and Logic.IsEntityAlive(self.Spawnpoint)then local SGF=GetID(self.TargetName)
AIScript_SpawnAndProtectArea(self.AIPlayerID,SGF,self.Spawnpoint,self.Radius,self.NumSword,self.NumBow,self.Time,self.TroopType,self.ReuseTroops,self.CaptureTradeCarts)end end
function b_Reward_AI_SpawnAndProtectArea:DEBUG(myIHU)
if self.AIPlayerID<2 then
dbg(myIHU.Identifier.." "..
self.Name..
": Player "..self.AIPlayerID.." is wrong")return true elseif Logic.IsEntityDestroyed(self.Spawnpoint)then
dbg(myIHU.Identifier.." "..
self.Name..
": Entity "..self.SpawnPoint.." is missing")return true elseif Logic.IsEntityDestroyed(self.TargetName)then
dbg(myIHU.Identifier.." "..
self.Name..
": Entity "..self.TargetName.." is missing")return true elseif self.Radius<1 then
dbg(myIHU.Identifier.." "..
self.Name..": Radius is to small or negative")return true elseif self.Time<-1 then
dbg(myIHU.Identifier..
" "..self.Name..": Time is smaller than -1")return true elseif self.NumSword<0 then
dbg(myIHU.Identifier.." "..
self.Name..": Number of Swords is negative")return true elseif self.NumBow<0 then
dbg(myIHU.Identifier.." "..
self.Name..": Number of Bows is negative")return true elseif self.NumBow+self.NumSword<1 then
dbg(myIHU.Identifier.." "..self.Name..
": No Soldiers?")return true end;return false end
Core:RegisterBehavior(b_Reward_AI_SpawnAndProtectArea)function Reward_AI_SetNumericalFact(...)
return b_Reward_AI_SetNumericalFact:new(...)end
b_Reward_AI_SetNumericalFact={Name="Reward_AI_SetNumericalFact",Description={en="Reward: Sets a numerical fact for the AI player",de="Lohn: Setzt eine Verhaltensregel fuer den KI-Spieler. "},Parameter={{ParameterType.PlayerID,en="AI Player",de="KI Spieler"},{ParameterType.Custom,en="Numerical Fact",de="Verhaltensregel"},{ParameterType.Number,en="Value",de="Wert"}}}
function b_Reward_AI_SetNumericalFact:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_SetNumericalFact:AddParameter(xxNCdF,_)
if(xxNCdF==0)then self.AIPlayerID=_*1 elseif
(xxNCdF==1)then
local cl1b={["Courage"]="FEAR",["Reconstruction"]="BARB",["Build Order"]="BPMX",["Conquer Outposts"]="FCOP",["Mount Outposts"]="FMOP",["max. Bowmen"]="FMBM",["max. Swordmen"]="FMSM",["max. Rams"]="FMRA",["max. Catapults"]="FMCA",["max. Ammunition Carts"]="FMAC",["max. Siege Towers"]="FMST",["max. Wall Catapults"]="FMBA",["FEAR"]="FEAR",["BARB"]="BARB",["BPMX"]="BPMX",["FCOP"]="FCOP",["FMOP"]="FMOP",["FMBM"]="FMBM",["FMSM"]="FMSM",["FMRA"]="FMRA",["FMCA"]="FMCA",["FMAC"]="FMAC",["FMST"]="FMST",["FMBA"]="FMBA"}self.NumericalFact=cl1b[_]elseif(xxNCdF==2)then self.Value=_*1 end end;function b_Reward_AI_SetNumericalFact:CustomFunction(Xz18nk)
AICore.SetNumericalFact(self.AIPlayerID,self.NumericalFact,self.Value)end
function b_Reward_AI_SetNumericalFact:GetCustomData(P)
if(
P==1)then
return
{"Courage","Reconstruction","Build Order","Conquer Outposts","Mount Outposts","max. Bowmen","max. Swordmen","max. Rams","max. Catapults","max. Ammunition Carts","max. Siege Towers","max. Wall Catapults"}end end
function b_Reward_AI_SetNumericalFact:DEBUG(sTX4)
if
Logic.GetStoreHouse(self.AIPlayerID)==0 then
dbg(sTX4.Identifier.." "..self.Name..
": Player "..self.AIPlayerID.." is wrong or dead!")return true elseif not self.NumericalFact then
dbg(sTX4.Identifier.." "..
self.Name..": invalid numerical fact choosen!")return true else
if
self.NumericalFact=="BARB"or self.NumericalFact=="FCOP"or self.NumericalFact=="FMOP"then
if
self.Value~=0 and self.Value~=1 then
dbg(sTX4.Identifier.." "..self.Name..
": BARB, FCOP, FMOP: value must be 1 or 0!")return true end elseif self.NumericalFact=="FEAR"then if self.Value<=0 then
dbg(sTX4.Identifier.." "..self.Name..
": FEAR: value must greater than 0!")return true end else if
self.Value<0 then
dbg(sTX4.Identifier..
" "..self.Name..": value must always greater than or equal 0!")return true end end end;return false end
Core:RegisterBehavior(b_Reward_AI_SetNumericalFact)function Reward_AI_Aggressiveness(...)
return b_Reward_AI_Aggressiveness:new(...)end
b_Reward_AI_Aggressiveness={Name="Reward_AI_Aggressiveness",Description={en="Reward: Sets the AI player's aggressiveness.",de="Lohn: Setzt die Aggressivität des KI-Spielers fest."},Parameter={{ParameterType.PlayerID,en="AI player",de="KI-Spieler"},{ParameterType.Custom,en="Aggressiveness (1-3)",de="Aggressivität (1-3)"}}}
function b_Reward_AI_Aggressiveness:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_Aggressiveness:AddParameter(A0TJx,Nqdkw)if A0TJx==0 then self.AIPlayer=Nqdkw*1 elseif A0TJx==1 then
self.Aggressiveness=tonumber(Nqdkw)end end
function b_Reward_AI_Aggressiveness:CustomFunction()
local t=(PlayerAIs[self.AIPlayer]or
AIPlayerTable[self.AIPlayer]or
AIPlayer:new(self.AIPlayer,AIPlayerProfile_City))PlayerAIs[self.AIPlayer]=t
if self.Aggressiveness>=2 then
t.m_ProfileLoop=AIProfile_Skirmish;t.Skirmish=t.Skirmish or{}
t.Skirmish.Claim_MinTime=SkirmishDefault.Claim_MinTime+ (
self.Aggressiveness-2)*390;t.Skirmish.Claim_MaxTime=t.Skirmish.Claim_MinTime*2 else
t.m_ProfileLoop=AIPlayerProfile_City end end
function b_Reward_AI_Aggressiveness:DEBUG(QbMO)
if self.AIPlayer<2 or
Logic.GetStoreHouse(self.AIPlayer)==0 then
dbg(QbMO.Identifier..
": Error in "..self.Name..
": Player "..self.PlayerID.." is wrong")return true end end
function b_Reward_AI_Aggressiveness:GetCustomData(wYZ)
assert(wYZ==1,"Error in "..
self.Name..": GetCustomData: Index is invalid.")return{"1","2","3"}end;Core:RegisterBehavior(b_Reward_AI_Aggressiveness)function Reward_AI_SetEnemy(...)return
b_Reward_AI_SetEnemy:new(...)end
b_Reward_AI_SetEnemy={Name="Reward_AI_SetEnemy",Description={en="Reward:Sets the enemy of an AI player (the AI only handles one enemy properly).",de="Lohn: Legt den Feind eines KI-Spielers fest (die KI behandelt nur einen Feind korrekt)."},Parameter={{ParameterType.PlayerID,en="AI player",de="KI-Spieler"},{ParameterType.PlayerID,en="Enemy",de="Feind"}}}function b_Reward_AI_SetEnemy:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end;function b_Reward_AI_SetEnemy:AddParameter(aMd,o0pf)
if
aMd==0 then self.AIPlayer=o0pf*1 elseif aMd==1 then self.Enemy=o0pf*1 end end
function b_Reward_AI_SetEnemy:CustomFunction()
local tx1LD=PlayerAIs[self.AIPlayer]
if tx1LD and tx1LD.Skirmish then tx1LD.Skirmish.Enemy=self.Enemy end end
function b_Reward_AI_SetEnemy:DEBUG(N3ROeR)
if self.AIPlayer<=1 or self.AIPlayer>=8 or
Logic.PlayerGetIsHumanFlag(self.AIPlayer)then
dbg(N3ROeR.Identifier..
": Error in "..self.Name..": Player "..
self.AIPlayer.." is wrong")return true end end;Core:RegisterBehavior(b_Reward_AI_SetEnemy)function Reward_ReplaceEntity(...)return
b_Reward_ReplaceEntity:new(...)end
b_Reward_ReplaceEntity=API.InstanceTable(b_Reprisal_ReplaceEntity)b_Reward_ReplaceEntity.Name="Reward_ReplaceEntity"
b_Reward_ReplaceEntity.Description.en="Reward: Replaces an entity with a new one of a different type. The playerID can be changed too."
b_Reward_ReplaceEntity.Description.de="Lohn: Ersetzt eine Entity durch eine neue anderen Typs. Es kann auch die Spielerzugehörigkeit geändert werden."b_Reward_ReplaceEntity.GetReprisalTable=nil
b_Reward_ReplaceEntity.GetRewardTable=function(I1oQVnUd,oTX)return
{Reward.Custom,{I1oQVnUd,I1oQVnUd.CustomFunction}}end;Core:RegisterBehavior(b_Reward_ReplaceEntity)function Reward_SetResourceAmount(...)return
b_Reward_SetResourceAmount:new(...)end
b_Reward_SetResourceAmount={Name="Reward_SetResourceAmount",Description={en="Reward: Set the current and maximum amount of a resource doodad (the amount can also set to 0)",de="Lohn: Setzt die aktuellen sowie maximalen Resourcen in einem Doodad (auch 0 ist möglich)"},Parameter={{ParameterType.ScriptName,en="Ressource",de="Resource"},{ParameterType.Number,en="Amount",de="Menge"}}}
function b_Reward_SetResourceAmount:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_SetResourceAmount:AddParameter(WZlF4,IxqPDOWH)if(WZlF4 ==0)then self.ScriptName=IxqPDOWH elseif
(WZlF4 ==1)then self.Amount=IxqPDOWH*1 end end
function b_Reward_SetResourceAmount:CustomFunction(GZqV)if
Logic.IsEntityDestroyed(self.ScriptName)then return false end
local OVubrDw_=GetID(self.ScriptName)
if Logic.GetResourceDoodadGoodType(OVubrDw_)==0 then return false end
Logic.SetResourceDoodadGoodAmount(OVubrDw_,self.Amount)end
function b_Reward_SetResourceAmount:DEBUG(G2_TeR8)
if not IsExisting(self.ScriptName)then
dbg(
G2_TeR8.Identifier.." "..self.Name..": resource entity does not exist!")return true elseif
not type(self.Amount)=="number"or self.Amount<0 then
dbg(G2_TeR8.Identifier..
" "..self.Name..": resource amount can not be negative!")return true end;return false end;Core:RegisterBehavior(b_Reward_SetResourceAmount)function Reward_Resources(...)return
b_Reward_Resources:new(...)end
b_Reward_Resources={Name="Reward_Resources",Description={en="Reward: The player receives a given amount of Goods in his store.",de="Lohn: Legt der Partei die angegebenen Rohstoffe ins Lagerhaus."},Parameter={{ParameterType.RawGoods,en="Type of good",de="Resourcentyp"},{ParameterType.Number,en="Amount of good",de="Anzahl der Resource"}}}
function b_Reward_Resources:AddParameter(y,k)if(y==0)then self.GoodTypeName=k elseif(y==1)then
self.GoodAmount=k*1 end end
function b_Reward_Resources:GetRewardTable()
local OPSPMfr_=Logic.GetGoodTypeID(self.GoodTypeName)return{Reward.Resources,OPSPMfr_,self.GoodAmount}end;Core:RegisterBehavior(b_Reward_Resources)function Reward_SendCart(...)return
b_Reward_SendCart:new(...)end
b_Reward_SendCart={Name="Reward_SendCart",Description={en="Reward: Sends a cart to a player. It spawns at a building or by replacing an entity. The cart can replace the entity if it's not a building.",de="Lohn: Sendet einen Karren zu einem Spieler. Der Karren wird an einem Gebäude oder einer Entity erstellt. Er ersetzt die Entity, wenn diese kein Gebäude ist."},Parameter={{ParameterType.ScriptName,en="Script entity",de="Script Entity"},{ParameterType.PlayerID,en="Owning player",de="Besitzer"},{ParameterType.Custom,en="Type name",de="Typbezeichnung"},{ParameterType.Custom,en="Good type",de="Warentyp"},{ParameterType.Number,en="Amount",de="Anzahl"},{ParameterType.Custom,en="Override target player",de="Anderer Zielspieler"},{ParameterType.Custom,en="Ignore reservations",de="Ignoriere Reservierungen"},{ParameterType.Custom,en="Replace entity",de="Entity ersetzen"}}}function b_Reward_SendCart:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_SendCart:AddParameter(QnNOl,aQs)
if(
QnNOl==0)then self.ScriptNameEntity=aQs elseif(QnNOl==1)then self.PlayerID=aQs*1 elseif
(QnNOl==2)then self.UnitKey=aQs elseif(QnNOl==3)then self.GoodType=aQs elseif(QnNOl==4)then
self.GoodAmount=aQs*1 elseif(QnNOl==5)then self.OverrideTargetPlayer=tonumber(aQs)elseif(QnNOl==6)then
self.IgnoreReservation=AcceptAlternativeBoolean(aQs)elseif(QnNOl==7)then self.ReplaceEntity=AcceptAlternativeBoolean(aQs)end end
function b_Reward_SendCart:CustomFunction(uow_0tb)if
not IsExisting(self.ScriptNameEntity)then return false end
local tykg=SendCart(self.ScriptNameEntity,self.PlayerID,Goods[self.GoodType],self.GoodAmount,Entities[self.UnitKey],self.IgnoreReservation)
if self.ReplaceEntity and
Logic.IsBuilding(GetID(self.ScriptNameEntity))==0 then
DestroyEntity(self.ScriptNameEntity)Logic.SetEntityName(tykg,self.ScriptNameEntity)end;if self.OverrideTargetPlayer then
Logic.ResourceMerchant_OverrideTargetPlayerID(tykg,self.OverrideTargetPlayer)end end
function b_Reward_SendCart:GetCustomData(C_pPyW)local mgb4b={}
if C_pPyW==2 then
mgb4b={"U_ResourceMerchant","U_Medicus","U_Marketer","U_ThiefCart","U_GoldCart","U_Noblemen_Cart","U_RegaliaCart"}elseif C_pPyW==3 then
for LOBqxO,m8 in pairs(Goods)do if string.find(LOBqxO,"^G_")then
table.insert(mgb4b,LOBqxO)end end;table.sort(mgb4b)elseif C_pPyW==5 then table.insert(mgb4b,"-")for mcoAHO=1,8 do
table.insert(mgb4b,mcoAHO)end elseif C_pPyW==6 then table.insert(mgb4b,"false")
table.insert(mgb4b,"true")elseif C_pPyW==7 then table.insert(mgb4b,"false")
table.insert(mgb4b,"true")end;return mgb4b end
function b_Reward_SendCart:DEBUG(d3gFWO)
if not IsExisting(self.ScriptNameEntity)then
dbg(
d3gFWO.Identifier.." "..self.Name..": spawnpoint does not exist!")return true elseif
not tonumber(self.PlayerID)or self.PlayerID<1 or self.PlayerID>8 then
dbg(d3gFWO.Identifier.." "..self.Name..
": got a invalid playerID!")return true elseif not Entities[self.UnitKey]then
dbg(d3gFWO.Identifier.." "..
self.Name..": entity type '"..
self.UnitKey.."' is invalid!")return true elseif not Goods[self.GoodType]then
dbg(d3gFWO.Identifier.." "..
self.Name..": good type '"..
self.GoodType.."' is invalid!")return true elseif
not tonumber(self.GoodAmount)or self.GoodAmount<1 then
dbg(d3gFWO.Identifier..
" "..self.Name..": good amount can not be below 1!")return true elseif
tonumber(self.OverrideTargetPlayer)and(self.OverrideTargetPlayer<1 or
self.OverrideTargetPlayer>8)then
dbg(d3gFWO.Identifier.." "..
self.Name..": overwrite target player with invalid playerID!")return true end;return false end;Core:RegisterBehavior(b_Reward_SendCart)function Reward_Units(...)return
b_Reward_Units:new(...)end
b_Reward_Units={Name="Reward_Units",Description={en="Reward: Units",de="Lohn: Einheiten"},Parameter={{ParameterType.Entity,en="Type name",de="Typbezeichnung"},{ParameterType.Number,en="Amount",de="Anzahl"}}}
function b_Reward_Units:AddParameter(D,obodPKnu)if(D==0)then self.EntityName=obodPKnu elseif(D==1)then
self.Amount=obodPKnu*1 end end
function b_Reward_Units:GetRewardTable()return
{Reward.Units,assert(Entities[self.EntityName]),self.Amount}end;Core:RegisterBehavior(b_Reward_Units)function Reward_QuestRestart(...)return
b_Reward_QuestRestart:new(...)end
b_Reward_QuestRestart=API.InstanceTable(b_Reprisal_QuestRestart)b_Reward_QuestRestart.Name="Reward_ReplaceEntity"
b_Reward_QuestRestart.Description.en="Reward: Restarts a (completed) quest so it can be triggered and completed again."
b_Reward_QuestRestart.Description.de="Lohn: Startet eine (beendete) Quest neu, damit diese neu ausgelöst und beendet werden kann."b_Reward_QuestRestart.GetReprisalTable=nil
b_Reward_QuestRestart.GetRewardTable=function(kgdzk,oVSp)return
{Reward.Custom,{kgdzk,kgdzk.CustomFunction}}end;Core:RegisterBehavior(b_Reward_QuestRestart)function Reward_QuestFailure(...)return
b_Reward_QuestFailure:new(...)end
b_Reward_QuestFailure=API.InstanceTable(b_Reprisal_ReplaceEntity)b_Reward_QuestFailure.Name="Reward_QuestFailure"
b_Reward_QuestFailure.Description.en="Reward: Lets another active quest fail."
b_Reward_QuestFailure.Description.de="Lohn: Lässt eine andere aktive Quest fehlschlagen."b_Reward_QuestFailure.GetReprisalTable=nil
b_Reward_QuestFailure.GetRewardTable=function(uBJ,A)return
{Reward.Custom,{uBJ,uBJ.CustomFunction}}end;Core:RegisterBehavior(b_Reward_QuestFailure)function Reward_QuestSuccess(...)return
b_Reward_QuestSuccess:new(...)end
b_Reward_QuestSuccess=API.InstanceTable(b_Reprisal_QuestSuccess)b_Reward_QuestSuccess.Name="Reward_QuestSuccess"
b_Reward_QuestSuccess.Description.en="Reward: Completes another active quest successfully."
b_Reward_QuestSuccess.Description.de="Lohn: Beendet eine andere aktive Quest erfolgreich."b_Reward_QuestSuccess.GetReprisalTable=nil
b_Reward_QuestSuccess.GetRewardTable=function(MP,jb)return
{Reward.Custom,{MP,MP.CustomFunction}}end;Core:RegisterBehavior(b_Reward_QuestSuccess)function Reward_QuestActivate(...)return
b_Reward_QuestActivate:new(...)end
b_Reward_QuestActivate=API.InstanceTable(b_Reprisal_QuestActivate)b_Reward_QuestActivate.Name="Reward_QuestActivate"
b_Reward_QuestActivate.Description.en="Reward: Activates another quest that is not triggered yet."
b_Reward_QuestActivate.Description.de="Lohn: Aktiviert eine andere Quest die noch nicht ausgelöst wurde."b_Reward_QuestActivate.GetReprisalTable=nil
b_Reward_QuestActivate.GetRewardTable=function(u,KSj)return
{Reward.Custom,{u,u.CustomFunction}}end;Core:RegisterBehavior(b_Reward_QuestActivate)function Reward_QuestInterrupt(...)return
b_Reward_QuestInterrupt:new(...)end
b_Reward_QuestInterrupt=API.InstanceTable(b_Reprisal_QuestInterrupt)b_Reward_QuestInterrupt.Name="Reward_QuestInterrupt"
b_Reward_QuestInterrupt.Description.en="Reward: Interrupts another active quest without success or failure."
b_Reward_QuestInterrupt.Description.de="Lohn: Beendet eine andere aktive Quest ohne Erfolg oder Misserfolg."b_Reward_QuestInterrupt.GetReprisalTable=nil
b_Reward_QuestInterrupt.GetRewardTable=function(YXgXQB,bvL1X4)return
{Reward.Custom,{YXgXQB,YXgXQB.CustomFunction}}end;Core:RegisterBehavior(b_Reward_QuestInterrupt)function Reward_QuestForceInterrupt(...)return
b_Reward_QuestForceInterrupt:new(...)end
b_Reward_QuestForceInterrupt=API.InstanceTable(b_Reprisal_QuestForceInterrupt)
b_Reward_QuestForceInterrupt.Name="Reward_QuestForceInterrupt"
b_Reward_QuestForceInterrupt.Description.en="Reward: Interrupts another quest (even when it isn't active yet) without success or failure."
b_Reward_QuestForceInterrupt.Description.de="Lohn: Beendet eine andere Quest, auch wenn diese noch nicht aktiv ist ohne Erfolg oder Misserfolg."b_Reward_QuestForceInterrupt.GetReprisalTable=nil
b_Reward_QuestForceInterrupt.GetRewardTable=function(PPNahh,z2g)return
{Reward.Custom,{PPNahh,PPNahh.CustomFunction}}end
Core:RegisterBehavior(b_Reward_QuestForceInterrupt)function Reward_MapScriptFunction(...)
return b_Reward_MapScriptFunction:new(...)end
b_Reward_MapScriptFunction=API.InstanceTable(b_Reprisal_MapScriptFunction)b_Reward_MapScriptFunction.Name="Reprisal_MapScriptFunction"
b_Reward_MapScriptFunction.Description.en="Reward: Calls a function within the global map script if the quest has failed."
b_Reward_MapScriptFunction.Description.de="Lohn: Ruft eine Funktion im globalen Kartenskript auf, wenn die Quest fehlschlägt."b_Reward_MapScriptFunction.GetReprisalTable=nil
b_Reward_MapScriptFunction.GetRewardTable=function(m9JTkVv6,Q)return
{Reward.Custom,{m9JTkVv6,m9JTkVv6.CustomFunction}}end;Core:RegisterBehavior(b_Reward_MapScriptFunction)function Reward_CustomVariables(...)return
b_Reward_CustomVariables:new(...)end
b_Reward_CustomVariables=API.InstanceTable(b_Reprisal_CustomVariables)b_Reward_CustomVariables.Name="Reward_CustomVariables"
b_Reward_CustomVariables.Description.en="Reward: Executes a mathematical operation with this variable. The other operand can be a number or another custom variable."
b_Reward_CustomVariables.Description.de="Lohn: Fuehrt eine mathematische Operation mit der Variable aus. Der andere Operand kann eine Zahl oder eine Custom-Varible sein."b_Reward_CustomVariables.GetReprisalTable=nil
b_Reward_CustomVariables.GetRewardTable=function(bWkP,JtFj)return
{Reward.Custom,{bWkP,bWkP.CustomFunction}}end;Core:RegisterBehavior(b_Reward_CustomVariables)function Reward_Technology(...)return
b_Reward_Technology:new(...)end
b_Reward_Technology=API.InstanceTable(b_Reprisal_Technology)b_Reward_Technology.Name="Reward_Technology"
b_Reward_Technology.Description.en="Reward: Locks or unlocks a technology for the given player."
b_Reward_Technology.Description.de="Lohn: Sperrt oder erlaubt eine Technolgie fuer den angegebenen Player."b_Reward_Technology.GetReprisalTable=nil
b_Reward_Technology.GetRewardTable=function(PQ3,_xCtN)return
{Reward.Custom,{PQ3,PQ3.CustomFunction}}end;Core:RegisterBehavior(b_Reward_Technology)function Reward_PrestigePoints(...)return
b_Reward_PrestigePoints:mew(...)end
b_Reward_PrestigePoints={Name="Reward_PrestigePoints",Description={en="Reward: Prestige",de="Lohn: Prestige"},Parameter={{ParameterType.Number,en="Points",de="Punkte"}}}function b_Reward_PrestigePoints:AddParameter(JVpe,nG36XmZC)
if(JVpe==0)then self.Points=nG36XmZC end end;function b_Reward_PrestigePoints:GetRewardTable()return
{Reward.PrestigePoints,self.Points}end
Core:RegisterBehavior(b_Reward_PrestigePoints)
function Reward_AI_MountOutpost(...)return b_Reward_AI_MountOutpost:new(...)end
b_Reward_AI_MountOutpost={Name="Reward_AI_MountOutpost",Description={en="Reward: Places a troop of soldiers on a named outpost.",de="Lohn: Platziert einen Trupp Soldaten auf einem Aussenposten der KI."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"},{ParameterType.Custom,en="Soldiers type",de="Soldatentyp"}}}
function b_Reward_AI_MountOutpost:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_MountOutpost:AddParameter(Vf26,xUGt)if Vf26 ==0 then self.Scriptname=xUGt else
self.SoldiersType=xUGt end end
function b_Reward_AI_MountOutpost:CustomFunction(_U)
local hkI39=assert(not
Logic.IsEntityDestroyed(self.Scriptname)and GetID(self.Scriptname),
_U.Identifier..
": Error in "..self.Name..": CustomFunction: Outpost is invalid")local MwwN=Logic.EntityGetPlayer(hkI39)
local oZ9,OXlT0=Logic.GetBuildingApproachPosition(hkI39)
local V=Logic.CreateBattalionOnUnblockedLand(Entities[self.SoldiersType],oZ9,OXlT0,0,MwwN,0)AICore.HideEntityFromAI(MwwN,V,true)
Logic.CommandEntityToMountBuilding(V,hkI39)end
function b_Reward_AI_MountOutpost:GetCustomData(zIYNIXy1)
if zIYNIXy1 ==1 then local c={}
for mReHt4h,I7 in pairs(Entities)do
if


string.find(mReHt4h,"U_MilitaryBandit")or string.find(mReHt4h,"U_MilitarySword")or string.find(mReHt4h,"U_MilitaryBow")then c[#c+1]=mReHt4h end end;return c end end
function b_Reward_AI_MountOutpost:DEBUG(Upw)
if Logic.IsEntityDestroyed(self.Scriptname)then
dbg(
Upw.Identifier.." "..
self.Name..": Outpost "..self.Scriptname.." is missing")return true end end;Core:RegisterBehavior(b_Reward_AI_MountOutpost)function Reward_QuestRestartForceActive(...)return
b_Reward_QuestRestartForceActive:new(...)end
b_Reward_QuestRestartForceActive={Name="Reward_QuestRestartForceActive",Description={en="Reward: Restarts a (completed) quest and triggers it immediately.",de="Lohn: Startet eine (beendete) Quest neu und triggert sie sofort."},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Reward_QuestRestartForceActive:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_QuestRestartForceActive:AddParameter(nqBfKL,gs3a)
assert(nqBfKL==0,"Error in "..self.Name..
": AddParameter: Index is invalid.")self.QuestName=gs3a end
function b_Reward_QuestRestartForceActive:CustomFunction(AkKaBC)
local OmRH8,GY=self:ResetQuest(AkKaBC)if OmRH8 then GY:SetMsgKeyOverride()GY:SetIconOverride()
GY:Trigger()end end
b_Reward_QuestRestartForceActive.ResetQuest=b_Reward_QuestRestart.CustomFunction
function b_Reward_QuestRestartForceActive:DEBUG(oukM79R)
if not
Quests[GetQuestID(self.QuestName)]then
dbg(oukM79R.Identifier..
": Error in "..self.Name..": Quest: "..
self.QuestName.." does not exist")return true end end
Core:RegisterBehavior(b_Reward_QuestRestartForceActive)
function Reward_UpgradeBuilding(...)return b_Reward_UpgradeBuilding:new(...)end
b_Reward_UpgradeBuilding={Name="Reward_UpgradeBuilding",Description={en="Reward: Upgrades a building",de="Lohn: Baut ein Gebäude aus"},Parameter={{ParameterType.ScriptName,en="Building",de="Gebäude"}}}
function b_Reward_UpgradeBuilding:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end;function b_Reward_UpgradeBuilding:AddParameter(D_j,mZPe4w)
if D_j==0 then self.Building=mZPe4w end end
function b_Reward_UpgradeBuilding:CustomFunction(OvZ)
local cBOpf=GetID(self.Building)
if cBOpf~=0 and Logic.IsBuilding(cBOpf)==1 and
Logic.IsBuildingUpgradable(cBOpf,true)and
Logic.IsBuildingUpgradable(cBOpf,false)then
Logic.UpgradeBuilding(cBOpf)end end
function b_Reward_UpgradeBuilding:DEBUG(KZYA5y)local YoCAN7OU=GetID(self.Building)
if not
(
YoCAN7OU~=0 and Logic.IsBuilding(YoCAN7OU)==1 and
Logic.IsBuildingUpgradable(YoCAN7OU,true)and
Logic.IsBuildingUpgradable(YoCAN7OU,false))then
dbg(
KZYA5y.Identifier.." "..self.Name..": Building is wrong")return true end end;Core:RegisterBehavior(b_Reward_UpgradeBuilding)function Trigger_PlayerDiscovered(...)return
b_Trigger_PlayerDiscovered:new(...)end
b_Trigger_PlayerDiscovered={Name="Trigger_PlayerDiscovered",Description={en="Trigger: if a given player has been discovered",de="Auslöser: wenn ein angegebener Spieler entdeckt wurde"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"}}}
function b_Trigger_PlayerDiscovered:GetTriggerTable(FoP)return
{Triggers.PlayerDiscovered,self.PlayerID}end;function b_Trigger_PlayerDiscovered:AddParameter(jqtWXY,XgRb)
if(jqtWXY==0)then self.PlayerID=XgRb*1 end end
Core:RegisterBehavior(b_Trigger_PlayerDiscovered)
function Trigger_OnDiplomacy(...)return b_Trigger_OnDiplomacy:new(...)end
b_Trigger_OnDiplomacy={Name="Trigger_OnDiplomacy",Description={en="Trigger: if diplomatic relations have been established with a player",de="Auslöser: wenn ein angegebener Diplomatie-Status mit einem Spieler erreicht wurde."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.DiplomacyState,en="Relation",de="Beziehung"}}}
function b_Trigger_OnDiplomacy:GetTriggerTable(G3e)return
{Triggers.Diplomacy,self.PlayerID,assert(DiplomacyStates[self.DiplState])}end
function b_Trigger_OnDiplomacy:AddParameter(GoP6,cZ_)if(GoP6 ==0)then self.PlayerID=cZ_*1 elseif(GoP6 ==1)then
self.DiplState=cZ_ end end;Core:RegisterBehavior(b_Trigger_OnDiplomacy)function Trigger_OnNeedUnsatisfied(...)return
b_Trigger_OnNeedUnsatisfied:new(...)end
b_Trigger_OnNeedUnsatisfied={Name="Trigger_OnNeedUnsatisfied",Description={en="Trigger: if a specified need is unsatisfied",de="Auslöser: wenn ein bestimmtes Beduerfnis nicht befriedigt ist."},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.Need,en="Need",de="Beduerfnis"},{ParameterType.Number,en="Workers on strike",de="Streikende Arbeiter"}}}
function b_Trigger_OnNeedUnsatisfied:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnNeedUnsatisfied:AddParameter(NYc8,Dff8)
if(NYc8 ==0)then self.PlayerID=Dff8*1 elseif
(NYc8 ==1)then self.Need=Dff8 elseif(NYc8 ==2)then self.WorkersOnStrike=Dff8*1 end end
function b_Trigger_OnNeedUnsatisfied:CustomFunction(lEYwsOG9)
return
Logic.GetNumberOfStrikingWorkersPerNeed(self.PlayerID,Needs[self.Need])>=self.WorkersOnStrike end
function b_Trigger_OnNeedUnsatisfied:DEBUG(M)
if
Logic.GetStoreHouse(self.PlayerID)==0 then
dbg(M.Identifier.." "..
self.Name..": "..self.PlayerID.." does not exist.")return true elseif not Needs[self.Need]then
dbg(M.Identifier.." "..self.Name..": "..
self.Need.." does not exist.")return true elseif self.WorkersOnStrike<0 then
dbg(M.Identifier.." "..
self.Name..": WorkersOnStrike value negative")return true end;return false end
Core:RegisterBehavior(b_Trigger_OnNeedUnsatisfied)function Trigger_OnResourceDepleted(...)
return b_Trigger_OnResourceDepleted:new(...)end
b_Trigger_OnResourceDepleted={Name="Trigger_OnResourceDepleted",Description={en="Trigger: if a resource is (temporarily) depleted",de="Auslöser: wenn eine Ressource (zeitweilig) verbraucht ist"},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}}}
function b_Trigger_OnResourceDepleted:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_OnResourceDepleted:AddParameter(Vt95q2G,jsPbwU)
if(Vt95q2G==0)then self.ScriptName=jsPbwU end end
function b_Trigger_OnResourceDepleted:CustomFunction(Wvs3rd6o)
local UdVlP=GetID(self.ScriptName)
return not UdVlP or UdVlP==0 or
Logic.GetResourceDoodadGoodType(UdVlP)==0 or
Logic.GetResourceDoodadGoodAmount(UdVlP)==0 end
Core:RegisterBehavior(b_Trigger_OnResourceDepleted)function Trigger_OnAmountOfGoods(...)
return b_Trigger_OnAmountOfGoods:new(...)end
b_Trigger_OnAmountOfGoods={Name="Trigger_OnAmountOfGoods",Description={en="Trigger: if the player has gathered a given amount of resources in his storehouse",de="Auslöser: wenn der Spieler eine bestimmte Menge einer Ressource in seinem Lagerhaus hat"},Parameter={{ParameterType.PlayerID,en="Player",de="Spieler"},{ParameterType.RawGoods,en="Type of good",de="Resourcentyp"},{ParameterType.Number,en="Amount of good",de="Anzahl der Resource"}}}
function b_Trigger_OnAmountOfGoods:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnAmountOfGoods:AddParameter(N,v9mB_RUi)
if(N==0)then self.PlayerID=v9mB_RUi*1 elseif(N==1)then
self.GoodTypeName=v9mB_RUi elseif(N==2)then self.GoodAmount=v9mB_RUi*1 end end
function b_Trigger_OnAmountOfGoods:CustomFunction(hX)
local AVU=Logic.GetStoreHouse(self.PlayerID)if(AVU==0)then return false end
local I=Logic.GetGoodTypeID(self.GoodTypeName)local _x5O1=Logic.GetAmountOnOutStockByGoodType(AVU,I)if(_x5O1 >=
self.GoodAmount)then return true end;return false end
function b_Trigger_OnAmountOfGoods:DEBUG(eFI8dI3)
if
Logic.GetStoreHouse(self.PlayerID)==0 then
dbg(eFI8dI3.Identifier.." "..self.Name..
": "..self.PlayerID.." does not exist.")return true elseif not Goods[self.GoodTypeName]then
dbg(eFI8dI3.Identifier.." "..self.Name..
": Good type is wrong.")return true elseif self.GoodAmount<0 then
dbg(eFI8dI3.Identifier.." "..
self.Name..": Good amount is negative.")return true end;return false end;Core:RegisterBehavior(b_Trigger_OnAmountOfGoods)function Trigger_OnQuestActive(...)return
b_Trigger_OnQuestActive:new(...)end
b_Trigger_OnQuestActive={Name="Trigger_OnQuestActive",Description={en="Trigger: if a given quest has been activated. Waiting time optional",de="Auslöser: wenn eine angegebene Quest aktiviert wurde. Optional mit Wartezeit"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Waiting time",de="Wartezeit"}}}
function b_Trigger_OnQuestActive:GetTriggerTable(i)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnQuestActive:AddParameter(l6xUetCb,lOb_Sv)if(l6xUetCb==0)then self.QuestName=lOb_Sv elseif
(l6xUetCb==1)then
self.WaitTime=(lOb_Sv~=nil and tonumber(lOb_Sv))or 0 end end
function b_Trigger_OnQuestActive:CustomFunction(VspvGB9V)
local LrFLp5=GetQuestID(self.QuestName)
if LrFLp5 ~=nil then assert(type(LrFLp5)=="number")
if(
Quests[LrFLp5].State==QuestState.Active)then self.WasActivated=
self.WasActivated or true end
if self.WasActivated then
if self.WaitTime and self.WaitTime>0 then self.WaitTimeTimer=self.WaitTimeTimer or
Logic.GetTime()
if Logic.GetTime()>=self.WaitTimeTimer+
self.WaitTime then return true end else return true end end end;return false end
function b_Trigger_OnQuestActive:DEBUG(GfB7)
if type(self.QuestName)~="string"then
dbg(""..

GfB7.Identifier.." "..self.Name..": invalid quest name!")return true elseif type(self.WaitTime)~="number"then
dbg(""..
GfB7.Identifier.." "..self.Name..
": waitTime must be a number!")return true end;return false end;function b_Trigger_OnQuestActive:Interrupt()end
function b_Trigger_OnQuestActive:Reset()self.WaitTimeTimer=
nil;self.WasActivated=nil end;Core:RegisterBehavior(b_Trigger_OnQuestActive)function Trigger_OnQuestFailure(...)return
b_Trigger_OnQuestFailure:new(...)end
b_Trigger_OnQuestFailure={Name="Trigger_OnQuestFailure",Description={en="Trigger: if a given quest has failed. Waiting time optional",de="Auslöser: wenn eine angegebene Quest fehlgeschlagen ist. Optional mit Wartezeit"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Waiting time",de="Wartezeit"}}}
function b_Trigger_OnQuestFailure:GetTriggerTable(Iz_w1j)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnQuestFailure:AddParameter(G,X7YKzX)if(G==0)then self.QuestName=X7YKzX elseif(G==1)then
self.WaitTime=(
X7YKzX~=nil and tonumber(X7YKzX))or 0 end end
function b_Trigger_OnQuestFailure:CustomFunction(od0VOF)
if
(GetQuestID(self.QuestName)~=nil)then local oO6SbZ=GetQuestID(self.QuestName)
if(Quests[oO6SbZ].Result==
QuestResult.Failure)then
if
self.WaitTime and self.WaitTime>0 then
self.WaitTimeTimer=self.WaitTimeTimer or Logic.GetTime()if
Logic.GetTime()>=self.WaitTimeTimer+self.WaitTime then return true end else return true end end end;return false end
function b_Trigger_OnQuestFailure:DEBUG(UE_vrsNx)
if type(self.QuestName)~="string"then
dbg(""..

UE_vrsNx.Identifier.." "..self.Name..": invalid quest name!")return true elseif type(self.WaitTime)~="number"then
dbg(""..
UE_vrsNx.Identifier.." "..self.Name..
": waitTime must be a number!")return true end;return false end
function b_Trigger_OnQuestFailure:Interrupt()self.WaitTimeTimer=nil end
function b_Trigger_OnQuestFailure:Reset()self.WaitTimeTimer=nil end;Core:RegisterBehavior(b_Trigger_OnQuestFailure)function Trigger_OnQuestNotTriggered(...)return
b_Trigger_OnQuestNotTriggered:new(...)end
b_Trigger_OnQuestNotTriggered={Name="Trigger_OnQuestNotTriggered",Description={en="Trigger: if a given quest is not yet active. Should be used in combination with other triggers.",de="Auslöser: wenn eine angegebene Quest noch inaktiv ist. Sollte mit weiteren Triggern kombiniert werden."},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"}}}
function b_Trigger_OnQuestNotTriggered:GetTriggerTable(kef2zBS)return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_OnQuestNotTriggered:AddParameter(Z,ze0)
if(Z==0)then self.QuestName=ze0 end end
function b_Trigger_OnQuestNotTriggered:CustomFunction(y)
if(
GetQuestID(self.QuestName)~=nil)then
local lW3uC0=GetQuestID(self.QuestName)if
(Quests[lW3uC0].State==QuestState.NotTriggered)then return true end end;return false end
function b_Trigger_OnQuestNotTriggered:DEBUG(N_G1)if type(self.QuestName)~="string"then
dbg(""..

N_G1.Identifier.." "..self.Name..": invalid quest name!")return true end
return false end
Core:RegisterBehavior(b_Trigger_OnQuestNotTriggered)function Trigger_OnQuestInterrupted(...)
return b_Trigger_OnQuestInterrupted:new(...)end
b_Trigger_OnQuestInterrupted={Name="Trigger_OnQuestInterrupted",Description={en="Trigger: if a given quest has been interrupted. Should be used in combination with other triggers.",de="Auslöser: wenn eine angegebene Quest abgebrochen wurde. Sollte mit weiteren Triggern kombiniert werden."},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Waiting time",de="Wartezeit"}}}
function b_Trigger_OnQuestInterrupted:GetTriggerTable(wkGNE)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnQuestInterrupted:AddParameter(ccK,BV)if(ccK==0)then self.QuestName=BV elseif(ccK==1)then
self.WaitTime=(
BV~=nil and tonumber(BV))or 0 end end
function b_Trigger_OnQuestInterrupted:CustomFunction(HnLY)
if
(GetQuestID(self.QuestName)~=nil)then local cm51CH1n=GetQuestID(self.QuestName)
if
(Quests[cm51CH1n].State==
QuestState.Over and
Quests[cm51CH1n].Result==QuestResult.Interrupted)then
if self.WaitTime and self.WaitTime>0 then self.WaitTimeTimer=self.WaitTimeTimer or
Logic.GetTime()
if Logic.GetTime()>=self.WaitTimeTimer+
self.WaitTime then return true end else return true end end end;return false end
function b_Trigger_OnQuestInterrupted:DEBUG(iWrSgT)
if type(self.QuestName)~="string"then
dbg(""..

iWrSgT.Identifier.." "..self.Name..": invalid quest name!")return true elseif type(self.WaitTime)~="number"then
dbg(""..
iWrSgT.Identifier.." "..self.Name..
": waitTime must be a number!")return true end;return false end
function b_Trigger_OnQuestInterrupted:Interrupt()self.WaitTimeTimer=nil end
function b_Trigger_OnQuestInterrupted:Reset()self.WaitTimeTimer=nil end
Core:RegisterBehavior(b_Trigger_OnQuestInterrupted)
function Trigger_OnQuestOver(...)return b_Trigger_OnQuestOver:new(...)end
b_Trigger_OnQuestOver={Name="Trigger_OnQuestOver",Description={en="Trigger: if a given quest has been finished, regardless of its result. Waiting time optional",de="Auslöser: wenn eine angegebene Quest beendet wurde, unabhängig von deren Ergebnis. Wartezeit optional"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Waiting time",de="Wartezeit"}}}
function b_Trigger_OnQuestOver:GetTriggerTable(C)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnQuestOver:AddParameter(YK1,t96Qtz)if(YK1 ==0)then self.QuestName=t96Qtz elseif(YK1 ==1)then
self.WaitTime=(
t96Qtz~=nil and tonumber(t96Qtz))or 0 end end
function b_Trigger_OnQuestOver:CustomFunction(HjKNi)
if
(GetQuestID(self.QuestName)~=nil)then local Ub9iqg=GetQuestID(self.QuestName)
if
(Quests[Ub9iqg].State==
QuestState.Over and
Quests[Ub9iqg].Result~=QuestResult.Interrupted)then
if self.WaitTime and self.WaitTime>0 then self.WaitTimeTimer=self.WaitTimeTimer or
Logic.GetTime()
if Logic.GetTime()>=self.WaitTimeTimer+
self.WaitTime then return true end else return true end end end;return false end
function b_Trigger_OnQuestOver:DEBUG(r_S8HFRo)
if type(self.QuestName)~="string"then
dbg(""..

r_S8HFRo.Identifier.." "..self.Name..": invalid quest name!")return true elseif type(self.WaitTime)~="number"then
dbg(""..
r_S8HFRo.Identifier.." "..self.Name..
": waitTime must be a number!")return true end;return false end
function b_Trigger_OnQuestOver:Interrupt()self.WaitTimeTimer=nil end
function b_Trigger_OnQuestOver:Reset()self.WaitTimeTimer=nil end;Core:RegisterBehavior(b_Trigger_OnQuestOver)function Trigger_OnQuestSuccess(...)return
b_Trigger_OnQuestSuccess:new(...)end
b_Trigger_OnQuestSuccess={Name="Trigger_OnQuestSuccess",Description={en="Trigger: if a given quest has been finished successfully. Waiting time optional",de="Auslöser: wenn eine angegebene Quest erfolgreich abgeschlossen wurde. Wartezeit optional"},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Waiting time",de="Wartezeit"}}}
function b_Trigger_OnQuestSuccess:GetTriggerTable(qIF4RFBv)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnQuestSuccess:AddParameter(wNbC65Ta,xOiPW)if(wNbC65Ta==0)then self.QuestName=xOiPW elseif
(wNbC65Ta==1)then
self.WaitTime=(xOiPW~=nil and tonumber(xOiPW))or 0 end end
function b_Trigger_OnQuestSuccess:CustomFunction()
if
(GetQuestID(self.QuestName)~=nil)then local Z9j=GetQuestID(self.QuestName)
if(Quests[Z9j].Result==
QuestResult.Success)then
if
self.WaitTime and self.WaitTime>0 then
self.WaitTimeTimer=self.WaitTimeTimer or Logic.GetTime()if
Logic.GetTime()>=self.WaitTimeTimer+self.WaitTime then return true end else return true end end end;return false end
function b_Trigger_OnQuestSuccess:DEBUG(r)
if type(self.QuestName)~="string"then
dbg(""..

r.Identifier.." "..self.Name..": invalid quest name!")return true elseif type(self.WaitTime)~="number"then
dbg(""..r.Identifier.." "..self.Name..
": waittime must be a number!")return true end;return false end
function b_Trigger_OnQuestSuccess:Interrupt()self.WaitTimeTimer=nil end
function b_Trigger_OnQuestSuccess:Reset()self.WaitTimeTimer=nil end;Core:RegisterBehavior(b_Trigger_OnQuestSuccess)function Trigger_CustomVariables(...)return
b_Trigger_CustomVariables:new(...)end
b_Trigger_CustomVariables={Name="Trigger_CustomVariables",Description={en="Trigger: if the variable has a certain value.",de="Auslöser: wenn die Variable einen bestimmen Wert eingenommen hat."},Parameter={{ParameterType.Default,en="Name of Variable",de="Variablennamen"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Default,en="Value",de="Wert"}}}
function b_Trigger_CustomVariables:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_CustomVariables:AddParameter(O,nJ1)
if O==0 then self.VariableName=nJ1 elseif O==1 then
self.Relation=nJ1 elseif O==2 then local KFU0=tonumber(nJ1)
KFU0=(KFU0 ~=nil and KFU0)or nJ1;self.Value=KFU0 end end
function b_Trigger_CustomVariables:CustomFunction()
if
_G["QSB_CustomVariables_"..self.VariableName]~=nil then
if self.Relation=="=="then
return
_G["QSB_CustomVariables_"..self.VariableName]==
(
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value])elseif self.Relation~="~="then
return
_G["QSB_CustomVariables_"..self.VariableName]~=
(
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value])elseif self.Relation==">"then
return
_G["QSB_CustomVariables_"..self.VariableName]>
(
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value])elseif self.Relation==">="then
return
_G["QSB_CustomVariables_"..self.VariableName]>=
(
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value])elseif self.Relation=="<="then
return
_G["QSB_CustomVariables_"..self.VariableName]<=
(
(type(self.Value)~="string"and self.Value)or _G["QSB_CustomVariables_"..self.Value])else
return _G["QSB_CustomVariables_"..self.VariableName]<
((
type(self.Value)~="string"and self.Value)or _G[
"QSB_CustomVariables_"..self.Value])end end;return false end
function b_Trigger_CustomVariables:GetCustomData(Pvuq)if Pvuq==1 then
return{"==","~=","<=","<",">",">="}end end
function b_Trigger_CustomVariables:DEBUG(lOpDJ)local YLe={"==","~=","<=","<",">",">="}local lTH={true,false,
nil}
if not
_G["QSB_CustomVariables_"..self.VariableName]then
dbg(lOpDJ.Identifier..
" "..self.Name..": variable '"..
self.VariableName.."' do not exist!")return true elseif not Inside(self.Relation,YLe)then
dbg(lOpDJ.Identifier.." "..
self.Name..": '"..
self.Relation.."' is an invalid relation!")return true end;return false end;Core:RegisterBehavior(b_Trigger_CustomVariables)function Trigger_AlwaysActive()return
b_Trigger_AlwaysActive:new()end
b_Trigger_AlwaysActive={Name="Trigger_AlwaysActive",Description={en="Trigger: the map has been started.",de="Auslöser: Start der Karte."}}
function b_Trigger_AlwaysActive:GetTriggerTable(JL)return{Triggers.Time,0}end;Core:RegisterBehavior(b_Trigger_AlwaysActive)function Trigger_OnMonth(...)return
b_Trigger_OnMonth:new(...)end
b_Trigger_OnMonth={Name="Trigger_OnMonth",Description={en="Trigger: a specified month",de="Auslöser: ein bestimmter Monat"},Parameter={{ParameterType.Custom,en="Month",de="Monat"}}}
function b_Trigger_OnMonth:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_OnMonth:AddParameter(FpU_E,JWtwnQ2t)
if(FpU_E==0)then self.Month=JWtwnQ2t*1 end end
function b_Trigger_OnMonth:CustomFunction(u)return
self.Month==Logic.GetCurrentMonth()end
function b_Trigger_OnMonth:GetCustomData(EKPPpj_)local aYO4NN={}
if EKPPpj_==0 then for CtG9nSQL=1,12 do
table.insert(aYO4NN,CtG9nSQL)end else assert(false)end;return aYO4NN end
function b_Trigger_OnMonth:DEBUG(uZtK5yX)if self.Month<1 or self.Month>12 then
dbg(
uZtK5yX.Identifier.." "..self.Name..": Month has the wrong value")return true end
return false end;Core:RegisterBehavior(b_Trigger_OnMonth)function Trigger_OnMonsoon()return
b_Trigger_OnMonsoon:new()end
b_Trigger_OnMonsoon={Name="Trigger_OnMonsoon",Description={en="Trigger: on monsoon.",de="Auslöser: wenn der Monsun beginnt."},RequiresExtraNo=1}
function b_Trigger_OnMonsoon:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnMonsoon:CustomFunction(kr2CYaS)if Logic.GetWeatherDoesShallowWaterFlood(0)then
return true end end;Core:RegisterBehavior(b_Trigger_OnMonsoon)function Trigger_Time(...)return
b_Trigger_Time:new(...)end
b_Trigger_Time={Name="Trigger_Time",Description={en="Trigger: a given amount of time since map start",de="Auslöser: eine gewisse Anzahl Sekunden nach Spielbeginn"},Parameter={{ParameterType.Number,en="Time (sec.)",de="Zeit (Sek.)"}}}
function b_Trigger_Time:GetTriggerTable(hXgSzEI)return{Triggers.Time,self.Time}end
function b_Trigger_Time:AddParameter(AUQ,B)if(AUQ==0)then self.Time=B*1 end end;Core:RegisterBehavior(b_Trigger_Time)function Trigger_OnWaterFreezes()return
b_Trigger_OnWaterFreezes:new()end
b_Trigger_OnWaterFreezes={Name="Trigger_OnWaterFreezes",Description={en="Trigger: if the water starts freezing",de="Auslöser: wenn die Gewässer gefrieren"}}
function b_Trigger_OnWaterFreezes:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_OnWaterFreezes:CustomFunction(J)
if Logic.GetWeatherDoesWaterFreeze(0)then return true end end
Core:RegisterBehavior(b_Trigger_OnWaterFreezes)
function Trigger_NeverTriggered()return b_Trigger_NeverTriggered:new()end
b_Trigger_NeverTriggered={Name="Trigger_NeverTriggered",Description={en="Never triggers a Quest. The quest may be set active by Reward_QuestActivate or Reward_QuestRestartForceActive",de="Löst nie eine Quest aus. Die Quest kann von Reward_QuestActivate oder Reward_QuestRestartForceActive aktiviert werden."}}function b_Trigger_NeverTriggered:GetTriggerTable()return
{Triggers.Custom2,{self,function()end}}end
Core:RegisterBehavior(b_Trigger_NeverTriggered)function Trigger_OnAtLeastOneQuestFailure(...)
return b_Trigger_OnAtLeastOneQuestFailure:new(...)end
b_Trigger_OnAtLeastOneQuestFailure={Name="Trigger_OnAtLeastOneQuestFailure",Description={en="Trigger: if one or both of the given quests have failed.",de="Auslöser: wenn einer oder beide der angegebenen Aufträge fehlgeschlagen sind."},Parameter={{ParameterType.QuestName,en="Quest Name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest Name 2",de="Questname 2"}}}
function b_Trigger_OnAtLeastOneQuestFailure:GetTriggerTable(coSiE)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnAtLeastOneQuestFailure:AddParameter(wm,_)self.QuestTable={}if(wm==0)then
self.Quest1=_ elseif(wm==1)then self.Quest2=_ end end
function b_Trigger_OnAtLeastOneQuestFailure:CustomFunction(O)
local smj=Quests[GetQuestID(self.Quest1)]local obBu=Quests[GetQuestID(self.Quest2)]
if
(smj.State==
QuestState.Over and smj.Result==QuestResult.Failure)or
(obBu.State==QuestState.Over and obBu.Result==QuestResult.Failure)then return true end;return false end
function b_Trigger_OnAtLeastOneQuestFailure:DEBUG(cbQlG)
if self.Quest1 ==self.Quest2 then
dbg(
cbQlG.Identifier..": "..self.Name..": Both quests are identical!")return true elseif not IsValidQuest(self.Quest1)then
dbg(cbQlG.Identifier..": "..
self.Name..": Quest '"..
self.Quest1 .."' does not exist!")return true elseif not IsValidQuest(self.Quest2)then
dbg(cbQlG.Identifier..": "..
self.Name..": Quest '"..
self.Quest2 .."' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Trigger_OnAtLeastOneQuestFailure)function Trigger_OnAtLeastOneQuestSuccess(...)
return b_Trigger_OnAtLeastOneQuestSuccess:new(...)end
b_Trigger_OnAtLeastOneQuestSuccess={Name="Trigger_OnAtLeastOneQuestSuccess",Description={en="Trigger: if one or both of the given quests are won.",de="Auslöser: wenn einer oder beide der angegebenen Aufträge gewonnen wurden."},Parameter={{ParameterType.QuestName,en="Quest Name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest Name 2",de="Questname 2"}}}
function b_Trigger_OnAtLeastOneQuestSuccess:GetTriggerTable(YZQu1DR4)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnAtLeastOneQuestSuccess:AddParameter(kza,CvGDk_2)self.QuestTable={}if(kza==0)then
self.Quest1=CvGDk_2 elseif(kza==1)then self.Quest2=CvGDk_2 end end
function b_Trigger_OnAtLeastOneQuestSuccess:CustomFunction(EGpun)
local LNlhK=Quests[GetQuestID(self.Quest1)]local cnx_1g=Quests[GetQuestID(self.Quest2)]
if

(LNlhK.State==
QuestState.Over and LNlhK.Result==QuestResult.Success)or(cnx_1g.State==QuestState.Over and
cnx_1g.Result==QuestResult.Success)then return true end;return false end
function b_Trigger_OnAtLeastOneQuestSuccess:DEBUG(eV)
if self.Quest1 ==self.Quest2 then
dbg(eV.Identifier..
": "..self.Name..": Both quests are identical!")return true elseif not IsValidQuest(self.Quest1)then
dbg(eV.Identifier..": "..
self.Name..": Quest '"..
self.Quest1 .."' does not exist!")return true elseif not IsValidQuest(self.Quest2)then
dbg(eV.Identifier..": "..
self.Name..": Quest '"..
self.Quest2 .."' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Trigger_OnAtLeastOneQuestSuccess)
function Trigger_OnAtLeastXOfYQuestsSuccess(...)return
b_Trigger_OnAtLeastXOfYQuestsSuccess:new(...)end
b_Trigger_OnAtLeastXOfYQuestsSuccess={Name="Trigger_OnAtLeastXOfYQuestsSuccess",Description={en="Trigger: if at least X of Y given quests has been finished successfully.",de="Auslöser: wenn X von Y angegebener Quests erfolgreich abgeschlossen wurden."},Parameter={{ParameterType.Custom,en="Least Amount",de="Mindest Anzahl"},{ParameterType.Custom,en="Quest Amount",de="Quest Anzahl"},{ParameterType.QuestName,en="Quest name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest name 2",de="Questname 2"},{ParameterType.QuestName,en="Quest name 3",de="Questname 3"},{ParameterType.QuestName,en="Quest name 4",de="Questname 4"},{ParameterType.QuestName,en="Quest name 5",de="Questname 5"}}}
function b_Trigger_OnAtLeastXOfYQuestsSuccess:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnAtLeastXOfYQuestsSuccess:AddParameter(DGQnw,yLgHuF)
if(DGQnw==0)then
self.LeastAmount=tonumber(yLgHuF)elseif(DGQnw==1)then self.QuestAmount=tonumber(yLgHuF)elseif(DGQnw==2)then
self.QuestName1=yLgHuF elseif(DGQnw==3)then self.QuestName2=yLgHuF elseif(DGQnw==4)then self.QuestName3=yLgHuF elseif
(DGQnw==5)then self.QuestName4=yLgHuF elseif(DGQnw==6)then self.QuestName5=yLgHuF end end
function b_Trigger_OnAtLeastXOfYQuestsSuccess:CustomFunction()local fpL=0
for k6=1,self.QuestAmount do
local m=GetQuestID(self["QuestName"..k6])if IsValidQuest(m)then
if
(Quests[m].Result==QuestResult.Success)then fpL=fpL+1;if fpL>=self.LeastAmount then return true end end end end;return false end
function b_Trigger_OnAtLeastXOfYQuestsSuccess:DEBUG(rvNhq6v)local gC=self.LeastAmount
local QO=self.QuestAmount
if gC<=0 or gC>5 then
dbg(rvNhq6v.Identifier..
": Error in "..self.Name..": LeastAmount is wrong")return true elseif QO<=0 or QO>5 then
dbg(rvNhq6v.Identifier..": Error in "..
self.Name..": QuestAmount is wrong")return true elseif gC>QO then
dbg(rvNhq6v.Identifier..": Error in "..
self.Name..": LeastAmount is greater than QuestAmount")return true end
for VvzMQHj=1,QO do
if
not IsValidQuest(self["QuestName"..VvzMQHj])then
dbg(rvNhq6v.Identifier..
": Error in "..self.Name..": Quest "..
self["QuestName"..VvzMQHj].." not found")return true end end;return false end
function b_Trigger_OnAtLeastXOfYQuestsSuccess:GetCustomData(fSYJX)if
(fSYJX==0)or(fSYJX==1)then return{"1","2","3","4","5"}end end
Core:RegisterBehavior(b_Trigger_OnAtLeastXOfYQuestsSuccess)function Trigger_MapScriptFunction(...)
return b_Trigger_MapScriptFunction:new(...)end
b_Trigger_MapScriptFunction={Name="Trigger_MapScriptFunction",Description={en="Calls a function within the global map script. If the function returns true the quest will be started",de="Ruft eine Funktion im globalen Skript auf. Wenn sie true sendet, wird die Quest gestartet."},Parameter={{ParameterType.Default,en="Function name",de="Funktionsname"}}}
function b_Trigger_MapScriptFunction:GetTriggerTable(WV)return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_MapScriptFunction:AddParameter(y,Uho4MXRx)
if(y==0)then self.FuncName=Uho4MXRx end end;function b_Trigger_MapScriptFunction:CustomFunction(J2)return
_G[self.FuncName](self,J2)end
function b_Trigger_MapScriptFunction:DEBUG(hgrBfz0w)
if
not self.FuncName or not _G[self.FuncName]then
local Gi=string.format("%s Trigger_MapScriptFunction: function '%s' does not exist!",hgrBfz0w.Identifier,tostring(self.FuncName))dbg(Gi)return true end;return false end
Core:RegisterBehavior(b_Trigger_MapScriptFunction)BundleClassicBehaviors={Global={},Local={}}function BundleClassicBehaviors.Global:Install()
end
function BundleClassicBehaviors.Local:Install()end;Core:RegisterBundle("BundleClassicBehaviors")
API=API or{}QSB=QSB or{}function Goal_MoveToPosition(...)
return b_Goal_MoveToPosition:new(...)end
b_Goal_MoveToPosition={Name="Goal_MoveToPosition",Description={en="Goal: A entity have to moved as close as the distance to another entity. The target can be marked with a static marker.",de="Ziel: Eine Entity muss sich einer anderen bis auf eine bestimmte Distanz nähern. Die Lupe wird angezeigt, das Ziel kann markiert werden."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.ScriptName,en="Target",de="Ziel"},{ParameterType.Number,en="Distance",de="Entfernung"},{ParameterType.Custom,en="Marker",de="Ziel markieren"}}}
function b_Goal_MoveToPosition:GetGoalTable(wpv1)return
{Objective.Distance,self.Entity,self.Target,self.Distance,self.Marker}end
function b_Goal_MoveToPosition:AddParameter(I9IMuWm,a)
if(I9IMuWm==0)then self.Entity=a elseif(I9IMuWm==1)then
self.Target=a elseif(I9IMuWm==2)then self.Distance=a*1 elseif(I9IMuWm==3)then
self.Marker=AcceptAlternativeBoolean(a)end end
function b_Goal_MoveToPosition:GetCustomData(rZ)local VKTNfzUf={}
if rZ==3 then VKTNfzUf={"true","false"}end;return VKTNfzUf end;Core:RegisterBehavior(b_Goal_MoveToPosition)function Goal_WinQuest(...)return
b_Goal_WinQuest:new(...)end
b_Goal_WinQuest={Name="Goal_WinQuest",Description={en="Goal: The player has to win a given quest",de="Ziel: Der Spieler muss eine angegebene Quest erfolgreich abschliessen."},Parameter={{ParameterType.QuestName,en="Quest Name",de="Questname"}}}
function b_Goal_WinQuest:GetGoalTable(Oms4)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_WinQuest:AddParameter(JfA,CPu1)if(JfA==0)then self.Quest=CPu1 end end
function b_Goal_WinQuest:CustomFunction(pfyhF)
local pglFz82w=Quests[GetQuestID(self.Quest)]if pglFz82w then
if pglFz82w.Result==QuestResult.Failure then return false end
if pglFz82w.Result==QuestResult.Success then return true end end
return nil end
function b_Goal_WinQuest:DEBUG(RkeCL)
if
Quests[GetQuestID(self.Quest)]==nil then
dbg(RkeCL.Identifier..": "..self.Name..
": Quest '"..self.Quest.."' does not exist!")return true end;return false end;Core:RegisterBehavior(b_Goal_WinQuest)function Goal_StealGold(...)return
b_Goal_StealGold:new(...)end
b_Goal_StealGold={Name="Goal_StealGold",Description={en="Goal: Steal an explicit amount of gold from a players or any players city buildings.",de="Ziel: Diebe sollen eine bestimmte Menge Gold aus feindlichen Stadtgebäuden stehlen."},Parameter={{ParameterType.Number,en="Amount on Gold",de="Zu stehlende Menge"},{ParameterType.Custom,en="Print progress",de="Fortschritt ausgeben"}}}
function b_Goal_StealGold:GetGoalTable(LoW_7e)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_StealGold:AddParameter(mLgQ,ng)
if(mLgQ==0)then self.Amount=ng*1 elseif(mLgQ==1)then
ng=ng or"true"self.Printout=AcceptAlternativeBoolean(ng)end;self.StohlenGold=0 end;function b_Goal_StealGold:GetCustomData(Pp_NboV)
if Pp_NboV==1 then return{"true","false"}end end
function b_Goal_StealGold:SetDescriptionOverwrite(owAp3u2G)
local OH0C=(
Network.GetDesiredLanguage()=="de"and"de")or"en"local kmQkm9cr=self.Amount-self.StohlenGold;kmQkm9cr=
(kmQkm9cr>0 and kmQkm9cr)or 0
local IE97m={de="Gold stehlen {cr}{cr}Aus Stadtgebäuden zu stehlende Goldmenge: ",en="Steal gold {cr}{cr}Amount on gold to steal from city buildings: "}return"{center}"..IE97m[OH0C]..kmQkm9cr end
function b_Goal_StealGold:CustomFunction(wey)
Core:ChangeCustomQuestCaptionText(wey.Identifier,self:SetDescriptionOverwrite(wey))if self.StohlenGold>=self.Amount then return true end;return nil end;function b_Goal_StealGold:GetIcon()return{5,13}end
function b_Goal_StealGold:DEBUG(hThO6)
if
tonumber(self.Amount)==nil and self.Amount<0 then
dbg(hThO6.Identifier..": "..self.Name..
": amount can not be negative!")return true end;return false end;function b_Goal_StealGold:Reset()self.StohlenGold=0 end
Core:RegisterBehavior(b_Goal_StealGold)
function Goal_StealBuilding(...)return b_Goal_StealBuilding:new(...)end
b_Goal_StealBuilding={Name="Goal_StealBuilding",Description={en="Goal: The player has to steal from a building. Not a castle and not a village storehouse!",de="Ziel: Der Spieler muss ein bestimmtes Gebäude bestehlen. Dies darf keine Burg und kein Dorflagerhaus sein!"},Parameter={{ParameterType.ScriptName,en="Building",de="Gebäude"}}}
function b_Goal_StealBuilding:GetGoalTable(zXU)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_StealBuilding:AddParameter(HmJym2,Jjb7Am5)
if(HmJym2 ==0)then self.Building=Jjb7Am5 end;self.RobberList={}end;function b_Goal_StealBuilding:GetCustomData(UwqY7A)
if UwqY7A==1 then return{"true","false"}end end
function b_Goal_StealBuilding:SetDescriptionOverwrite(k)
local d7gPKcw=
Logic.IsEntityInCategory(GetID(self.Building),EntityCategories.Cathedrals)==1
local naeNp=Logic.GetEntityType(GetID(self.Building))==Entities.B_StoreHouse;local gA=
(Network.GetDesiredLanguage()=="de"and"de")or"en"local r
if d7gPKcw then
r={de="Sabotage {cr}{cr} Sabotiert die mit Pfeil markierte Kirche.",en="Sabotage {cr}{cr} Sabotage the Church of the opponent."}elseif naeNp then
r={de="Lagerhaus bestehlen {cr}{cr} Sendet einen Dieb in das markierte Lagerhaus.",en="Steal from storehouse {cr}{cr} Steal from the marked storehouse."}else
r={de="Geb�ude bestehlen {cr}{cr} Bestehlt das durch einen Pfeil markierte Gebäude.",en="Steal from building {cr}{cr} Steal from the building marked by an arrow."}end;return"{center}"..r[gA]end
function b_Goal_StealBuilding:CustomFunction(LWe)if not IsExisting(self.Building)then
if
self.Marker then Logic.DestroyEffect(self.Marker)end;return false end;if
not self.Marker then local _3Tq=GetPosition(self.Building)
self.Marker=Logic.CreateEffect(EGL_Effects.E_Questmarker,_3Tq.X,_3Tq.Y,0)end
if
self.SuccessfullyStohlen then Logic.DestroyEffect(self.Marker)return true end;return nil end;function b_Goal_StealBuilding:GetIcon()return{5,13}end
function b_Goal_StealBuilding:DEBUG(Rq1hByv)
local iFk=Logic.GetEntityTypeName(Logic.GetEntityType(GetID(self.Building)))
local sEFtmNgB=
Logic.IsEntityInCategory(GetID(self.Building),EntityCategories.Headquarters)==1
if Logic.IsBuilding(GetID(self.Building))==0 then
dbg(
Rq1hByv.Identifier..": "..self.Name..": target is not a building")return true elseif not IsExisting(self.Building)then
dbg(Rq1hByv.Identifier..": "..self.Name..
": target is destroyed :(")return true elseif
string.find(iFk,"B_NPC_BanditsHQ")or
string.find(iFk,"B_NPC_Cloister")or string.find(iFk,"B_NPC_StoreHouse")then
dbg(Rq1hByv.Identifier..
": "..self.Name..": village storehouses are not allowed!")return true elseif sEFtmNgB then
dbg(Rq1hByv.Identifier..": "..
self.Name..": use Goal_StealInformation for headquarters!")return true end;return false end;function b_Goal_StealBuilding:Reset()self.SuccessfullyStohlen=false;self.RobberList={}self.Marker=
nil end;function b_Goal_StealBuilding:Interrupt(qxiez0Cn)
Logic.DestroyEffect(self.Marker)end
Core:RegisterBehavior(b_Goal_StealBuilding)
function Goal_Infiltrate(...)return b_Goal_Infiltrate:new(...)end
b_Goal_Infiltrate={Name="Goal_Infiltrate",IconOverwrite={5,13},Description={en="Goal: Infiltrate a building with a thief. A thief must be able to steal from the target building.",de="Ziel: Infiltriere ein Gebäude mit einem Dieb. Nur mit Gebaueden moeglich, die bestohlen werden koennen."},Parameter={{ParameterType.ScriptName,en="Target Building",de="Zielgebäude"},{ParameterType.Custom,en="Destroy Thief",de="Dieb löschen"}}}
function b_Goal_Infiltrate:GetGoalTable(Ck_H)return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_Infiltrate:AddParameter(Sc,_QFw_It)
if(Sc==0)then self.Building=_QFw_It elseif(Sc==1)then
_QFw_It=_QFw_It or"true"self.Delete=AcceptAlternativeBoolean(_QFw_It)end end;function b_Goal_Infiltrate:GetCustomData(WLqHf)
if WLqHf==1 then return{"true","false"}end end
function b_Goal_Infiltrate:SetDescriptionOverwrite(vN)
if
not vN.QuestDescription then local BIwW6_=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local Vdfc3={de="Gebäude infriltrieren {cr}{cr}Spioniere das markierte Gebäude mit einem Dieb aus!",en="Infiltrate building {cr}{cr}Spy on the highlighted buildings with a thief!"}return Vdfc3[BIwW6_]else return vN.QuestDescription end end
function b_Goal_Infiltrate:CustomFunction(CzM7PG)
if not IsExisting(self.Building)then if self.Marker then
Logic.DestroyEffect(self.Marker)end;return false end;if not self.Marker then local RKf6s5=GetPosition(self.Building)
self.Marker=Logic.CreateEffect(EGL_Effects.E_Questmarker,RKf6s5.X,RKf6s5.Y,0)end
if
self.Infiltrated then Logic.DestroyEffect(self.Marker)return true end;return nil end
function b_Goal_Infiltrate:GetIcon()return self.IconOverwrite end
function b_Goal_Infiltrate:DEBUG(tP9E_)
if
Logic.IsBuilding(GetID(self.Building))==0 then
dbg(tP9E_.Identifier..
": "..self.Name..": target is not a building")return true elseif not IsExisting(self.Building)then
dbg(tP9E_.Identifier..": "..self.Name..
": target is destroyed :(")return true end;return false end
function b_Goal_Infiltrate:Reset()self.Infiltrated=false;self.Marker=nil end
function b_Goal_Infiltrate:Interrupt(Y1WX)Logic.DestroyEffect(self.Marker)end;Core:RegisterBehavior(b_Goal_Infiltrate)function Goal_AmmunitionAmount(...)return
b_Goal_AmmunitionAmount:new(...)end
b_Goal_AmmunitionAmount={Name="Goal_AmmunitionAmount",Description={en="Goal: Reach a smaller or bigger value than the given amount of ammunition in a war machine.",de="Ziel: Ueber- oder unterschreite die angegebene Anzahl Munition in einem Kriegsgerät."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Amount",de="Menge"}}}
function b_Goal_AmmunitionAmount:GetGoalTable()return
{Objective.Custom2,{self,self.CustomFunction}}end
function b_Goal_AmmunitionAmount:AddParameter(G06Z2,K)
if(G06Z2 ==0)then self.Scriptname=K elseif(G06Z2 ==1)then self.bRelSmallerThan=
tostring(K)=="true"or K=="<"elseif(G06Z2 ==2)then self.Amount=
K*1 end end
function b_Goal_AmmunitionAmount:CustomFunction()local tQx9TV=GetID(self.Scriptname)if not
IsExisting(tQx9TV)then return false end
local FL7g2o=Logic.GetAmmunitionAmount(tQx9TV)
if
(self.bRelSmallerThan and FL7g2o<self.Amount)or
(not self.bRelSmallerThan and FL7g2o>=self.Amount)then return true end;return nil end
function b_Goal_AmmunitionAmount:DEBUG(dkh7Tt9)if self.Amount<0 then
dbg(dkh7Tt9.Identifier..": Error in "..self.Name..
": Amount is negative")return true end end
function b_Goal_AmmunitionAmount:GetCustomData(XiNd_H)if XiNd_H==1 then return{"<",">="}end end;Core:RegisterBehavior(b_Goal_AmmunitionAmount)function Reprisal_SetPosition(...)return
b_Reprisal_SetPosition:new(...)end
b_Reprisal_SetPosition={Name="Reprisal_SetPosition",Description={en="Reprisal: Places an entity relative to the position of another. The entity can look the target.",de="Vergeltung: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.ScriptName,en="Target position",de="Zielposition"},{ParameterType.Custom,en="Face to face",de="Ziel ansehen"},{ParameterType.Number,en="Distance",de="Zielentfernung"}}}
function b_Reprisal_SetPosition:GetReprisalTable(Q_c4px86)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_SetPosition:AddParameter(_F6VYt,ITv3PH1i)
if(_F6VYt==0)then self.Entity=ITv3PH1i elseif
(_F6VYt==1)then self.Target=ITv3PH1i elseif(_F6VYt==2)then
self.FaceToFace=AcceptAlternativeBoolean(ITv3PH1i)elseif(_F6VYt==3)then self.Distance=
(ITv3PH1i~=nil and tonumber(ITv3PH1i))or 100 end end
function b_Reprisal_SetPosition:CustomFunction(_5fF)
if not IsExisting(self.Entity)or not
IsExisting(self.Target)then return end;local OUQqQp=GetID(self.Entity)local OyOfzTWn=GetID(self.Target)
local rx,ijvSrZA1,STNuSN6=Logic.EntityGetPos(OyOfzTWn)if Logic.IsBuilding(OyOfzTWn)==1 then
rx,ijvSrZA1=Logic.GetBuildingApproachPosition(OyOfzTWn)end;local PYOeGnAZ=
Logic.GetEntityOrientation(OyOfzTWn)+90
if self.FaceToFace then rx=rx+self.Distance*
math.cos(math.rad(PYOeGnAZ))
ijvSrZA1=
ijvSrZA1+self.Distance*math.sin(math.rad(PYOeGnAZ))
Logic.DEBUG_SetSettlerPosition(OUQqQp,rx,ijvSrZA1)LookAt(self.Entity,self.Target)else if
Logic.IsBuilding(OyOfzTWn)==1 then
rx,ijvSrZA1=Logic.GetBuildingApproachPosition(OyOfzTWn)end
Logic.DEBUG_SetSettlerPosition(OUQqQp,rx,ijvSrZA1)end end;function b_Reprisal_SetPosition:GetCustomData(s10ar5XH)
if s10ar5XH==3 then return{"true","false"}end end
function b_Reprisal_SetPosition:DEBUG(YoKhvIs)
if
self.FaceToFace then
if
tonumber(self.Distance)==nil or self.Distance<50 then
dbg(YoKhvIs.Identifier..
" "..self.Name..": Distance is nil or to short!")return true end end
if
not IsExisting(self.Entity)or not IsExisting(self.Target)then
dbg(YoKhvIs.Identifier.." "..
self.Name..": Mover entity or target entity does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_SetPosition)function Reprisal_ChangePlayer(...)return
b_Reprisal_ChangePlayer:new(...)end
b_Reprisal_ChangePlayer={Name="Reprisal_ChangePlayer",Description={en="Reprisal: Changes the owner of the entity or a battalion.",de="Vergeltung: Aendert den Besitzer einer Entity oder eines Battalions."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Custom,en="Player",de="Spieler"}}}
function b_Reprisal_ChangePlayer:GetReprisalTable(I2ipE)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_ChangePlayer:AddParameter(qS730I,PYEbnua)
if(qS730I==0)then self.Entity=PYEbnua elseif
(qS730I==1)then self.Player=tostring(PYEbnua)end end
function b_Reprisal_ChangePlayer:CustomFunction(Um4ZYiT)
if not IsExisting(self.Entity)then return end;local AF=GetID(self.Entity)
if Logic.IsLeader(AF)==1 then
Logic.ChangeSettlerPlayerID(AF,self.Player)else Logic.ChangeEntityPlayerID(AF,self.Player)end end
function b_Reprisal_ChangePlayer:GetCustomData(s)if s==1 then
return{"0","1","2","3","4","5","6","7","8"}end end
function b_Reprisal_ChangePlayer:DEBUG(hIHW)
if not IsExisting(self.Entity)then
dbg(hIHW.Identifier..
" "..
self.Name..": entity '"..self.Entity.."' does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_ChangePlayer)function Reprisal_SetVisible(...)return
b_Reprisal_SetVisible:new(...)end
b_Reprisal_SetVisible={Name="Reprisal_SetVisible",Description={en="Reprisal: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected.",de="Strafe: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Custom,en="Visible",de="Sichtbar"}}}
function b_Reprisal_SetVisible:GetReprisalTable(H5)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_SetVisible:AddParameter(HYY,C3)if(HYY==0)then self.Entity=C3 elseif(HYY==1)then
self.Visible=AcceptAlternativeBoolean(C3)end end
function b_Reprisal_SetVisible:CustomFunction(SkCMMH)
if not IsExisting(self.Entity)then return end;local kvvs=GetID(self.Entity)
local _yTx3S94=Logic.EntityGetPlayer(kvvs)local Mm=Logic.GetEntityType(kvvs)
local g524=Logic.GetEntityTypeName(Mm)
if

string.find(g524,"S_")or string.find(g524,"B_NPC_Bandits")or string.find(g524,"B_NPC_Barracks")then local WUdVeYc={Logic.GetSpawnedEntities(kvvs)}
for lHep6wo=1,#WUdVeYc
do
if Logic.IsLeader(WUdVeYc[lHep6wo])==1 then
local BKZsJ={Logic.GetSoldiersAttachedToLeader(WUdVeYc[lHep6wo])}
for Sw=2,#BKZsJ do Logic.SetVisible(BKZsJ[Sw],self.Visible)end else
Logic.SetVisible(WUdVeYc[lHep6wo],self.Visible)end end else
if Logic.IsLeader(kvvs)==1 then
local W67mm9p6={Logic.GetSoldiersAttachedToLeader(kvvs)}for oBxdTi6u=2,#W67mm9p6 do
Logic.SetVisible(W67mm9p6[oBxdTi6u],self.Visible)end else
Logic.SetVisible(kvvs,self.Visible)end end end;function b_Reprisal_SetVisible:GetCustomData(T7hLe5j)
if T7hLe5j==1 then return{"true","false"}end end
function b_Reprisal_SetVisible:DEBUG(I_)if not
IsExisting(self.Entity)then
dbg(I_.Identifier.." "..self.Name..
": entity '"..self.Entity.."' does not exist!")return true end;return
false end;Core:RegisterBehavior(b_Reprisal_SetVisible)function Reprisal_SetVulnerability(...)return
b_Reprisal_SetVulnerability:new(...)end
b_Reprisal_SetVulnerability={Name="Reprisal_SetVulnerability",Description={en="Reprisal: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected.",de="Vergeltung: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen"},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Custom,en="Vulnerability",de="Verwundbar"}}}
function b_Reprisal_SetVulnerability:GetReprisalTable(J2Jin)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_SetVulnerability:AddParameter(Rvg,HpdA)if(Rvg==0)then self.Entity=HpdA elseif(Rvg==1)then
self.Vulnerability=AcceptAlternativeBoolean(HpdA)end end
function b_Reprisal_SetVulnerability:CustomFunction(DsAJbW)
if not IsExisting(self.Entity)then return end;local AXfX=GetID(self.Entity)
local btcUUhB=Logic.GetEntityType(AXfX)local iw0S=Logic.GetEntityTypeName(btcUUhB)
if self.Vulnerability then
if
string.find(iw0S,"S_")or string.find(iw0S,"B_NPC_Bandits")or
string.find(iw0S,"B_NPC_Barracks")then
local Tjg={Logic.GetSpawnedEntities(AXfX)}
for n2srE7H=1,#Tjg do
if Logic.IsLeader(Tjg[n2srE7H])==1 then
local Rf={Logic.GetSoldiersAttachedToLeader(Tjg[n2srE7H])}for X9ZjrTz=2,#Rf do MakeVulnerable(Rf[X9ZjrTz])end end;MakeVulnerable(Tjg[n2srE7H])end else MakeVulnerable(self.Entity)end else
if

string.find(iw0S,"S_")or string.find(iw0S,"B_NPC_Bandits")or string.find(iw0S,"B_NPC_Barracks")then local tYFIuD={Logic.GetSpawnedEntities(AXfX)}
for Ht5Ge=1,#tYFIuD
do
if Logic.IsLeader(tYFIuD[Ht5Ge])==1 then
local l={Logic.GetSoldiersAttachedToLeader(tYFIuD[Ht5Ge])}for IO=2,#l do MakeInvulnerable(l[IO])end end;MakeInvulnerable(tYFIuD[Ht5Ge])end else MakeInvulnerable(self.Entity)end end end;function b_Reprisal_SetVulnerability:GetCustomData(YDJY)
if YDJY==1 then return{"true","false"}end end
function b_Reprisal_SetVulnerability:DEBUG(t)if
not IsExisting(self.Entity)then
dbg(t.Identifier..
" "..self.Name..": entity '"..self.Entity..
"' does not exist!")return true end;return
false end
Core:RegisterBehavior(b_Reprisal_SetVulnerability)
function Reprisal_SetModel(...)return b_Reprisal_SetModel:new(...)end
b_Reprisal_SetModel={Name="Reprisal_SetModel",Description={en="Reprisal: Changes the model of the entity. Be careful, some models crash the game.",de="Vergeltung: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Custom,en="Model",de="Model"}}}
function b_Reprisal_SetModel:GetReprisalTable(Rdi8NIft)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_SetModel:AddParameter(J0uTkQ9,sd6k)if(J0uTkQ9 ==0)then self.Entity=sd6k elseif(J0uTkQ9 ==1)then
self.Model=sd6k end end
function b_Reprisal_SetModel:CustomFunction(a)
if not IsExisting(self.Entity)then return end;local lK7=GetID(self.Entity)
Logic.SetModel(lK7,Models[self.Model])end
function b_Reprisal_SetModel:GetCustomData(KWMxs7a)
if KWMxs7a==1 then local T={}
for LBIp4,A5 in pairs(Models)do
if










not
string.find(LBIp4,"Animals_")and not string.find(LBIp4,"Banners_")and not string.find(LBIp4,"Goods_")and not string.find(LBIp4,"goods_")and not string.find(LBIp4,"Heads_")and not string.find(LBIp4,"MissionMap_")and not string.find(LBIp4,"R_Fish")and not string.find(LBIp4,"Units_")and not string.find(LBIp4,"XD_")and not string.find(LBIp4,"XS_")and not string.find(LBIp4,"XT_")and not string.find(LBIp4,"Z_")then table.insert(T,LBIp4)end end;return T end end
function b_Reprisal_SetModel:DEBUG(PV168s0f)
if not IsExisting(self.Entity)then
dbg(PV168s0f.Identifier..
" "..
self.Name..": entity '"..self.Entity.."' does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_SetModel)function Reward_SetPosition(...)return
b_Reward_SetPosition:new(...)end
b_Reward_SetPosition=API.InstanceTable(b_Reprisal_SetPosition)b_Reward_SetPosition.Name="Reward_SetPosition"
b_Reward_SetPosition.Description.en="Reward: Places an entity relative to the position of another. The entity can look the target."
b_Reward_SetPosition.Description.de="Lohn: Setzt eine Entity relativ zur Position einer anderen. Die Entity kann zum Ziel ausgerichtet werden."b_Reward_SetPosition.GetReprisalTable=nil
b_Reward_SetPosition.GetRewardTable=function(bjK,Us1Xh)return
{Reward.Custom,{bjK,bjK.CustomFunction}}end;Core:RegisterBehavior(b_Reward_SetPosition)function Reward_ChangePlayer(...)return
b_Reprisal_ChangePlayer:new(...)end
b_Reward_ChangePlayer=API.InstanceTable(b_Reprisal_ChangePlayer)b_Reward_ChangePlayer.Name="Reward_ChangePlayer"
b_Reward_ChangePlayer.Description.en="Reward: Changes the owner of the entity or a battalion."
b_Reward_ChangePlayer.Description.de="Lohn: Aendert den Besitzer einer Entity oder eines Battalions."b_Reward_ChangePlayer.GetReprisalTable=nil
b_Reward_ChangePlayer.GetRewardTable=function(rs59,R)return
{Reward.Custom,{rs59,rs59.CustomFunction}}end;Core:RegisterBehavior(b_Reward_ChangePlayer)function Reward_MoveToPosition(...)return
b_Reward_MoveToPosition:new(...)end
b_Reward_MoveToPosition={Name="Reward_MoveToPosition",Description={en="Reward: Moves an entity relative to another entity. If angle is zero the entities will be standing directly face to face.",de="Lohn: Bewegt eine Entity relativ zur Position einer anderen. Wenn Winkel 0 ist, stehen sich die Entities direkt gegen�ber."},Parameter={{ParameterType.ScriptName,en="Settler",de="Siedler"},{ParameterType.ScriptName,en="Destination",de="Ziel"},{ParameterType.Number,en="Distance",de="Entfernung"},{ParameterType.Number,en="Angle",de="Winkel"}}}
function b_Reward_MoveToPosition:GetRewardTable(rGa2MaGH)return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_MoveToPosition:AddParameter(i6,u33wPQT)
if(i6 ==0)then self.Entity=u33wPQT elseif(i6 ==1)then
self.Target=u33wPQT elseif(i6 ==2)then self.Distance=u33wPQT*1 elseif(i6 ==3)then self.Angle=u33wPQT*1 end end
function b_Reward_MoveToPosition:CustomFunction(aNrMnPZ)
if not IsExisting(self.Entity)or not
IsExisting(self.Target)then return end;self.Angle=self.Angle or 0;local fC=GetID(self.Entity)
local Kl=GetID(self.Target)local E=Logic.GetEntityOrientation(Kl)
local mJGBwA,_E3,j3=Logic.EntityGetPos(Kl)if Logic.IsBuilding(Kl)==1 then
mJGBwA,_E3=Logic.GetBuildingApproachPosition(Kl)E=E-90 end
mJGBwA=mJGBwA+self.Distance*math.cos(math.rad(
E+self.Angle))_E3=_E3+
self.Distance*math.sin(math.rad(E+self.Angle))
Logic.MoveSettler(fC,mJGBwA,_E3)
StartSimpleJobEx(function(f,jy)
if Logic.IsEntityMoving(f)==false then LookAt(f,jy)return true end end,fC,Kl)end
function b_Reward_MoveToPosition:DEBUG(Ifev2bUE)
if tonumber(self.Distance)==nil or
self.Distance<50 then
dbg(Ifev2bUE.Identifier.." "..
self.Name..": Distance is nil or to short!")return true elseif not IsExisting(self.Entity)or
not IsExisting(self.Target)then
dbg(Ifev2bUE.Identifier.." "..self.Name..
": Mover entity or target entity does not exist!")return true end;return false end;Core:RegisterBehavior(b_Reward_MoveToPosition)function Reward_VictoryWithParty()return
b_Reward_VictoryWithParty:new()end
b_Reward_VictoryWithParty={Name="Reward_VictoryWithParty",Description={en="Reward: The player wins the game with an animated festival on the market.",de="Lohn: Der Spieler gewinnt das Spiel mit einer animierten Siegesfeier."},Parameter={}}
function b_Reward_VictoryWithParty:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end;function b_Reward_VictoryWithParty:AddParameter(ZY,KCpJbzHT)end
function b_Reward_VictoryWithParty:CustomFunction(g)
Victory(g_VictoryAndDefeatType.VictoryMissionComplete)local dQl0xvy2=g.ReceivingPlayer
local hX=Logic.GetMarketplace(dQl0xvy2)
if IsExisting(hX)then local w=GetPosition(hX)
Logic.CreateEffect(EGL_Effects.FXFireworks01,w.X,w.Y,0)
Logic.CreateEffect(EGL_Effects.FXFireworks02,w.X,w.Y,0)
local YTrvPn={Entities.U_SmokeHouseWorker,Entities.U_Butcher,Entities.U_Carpenter,Entities.U_Tanner,Entities.U_Blacksmith,Entities.U_CandleMaker,Entities.U_Baker,Entities.U_DairyWorker,Entities.U_SpouseS01,Entities.U_SpouseS02,Entities.U_SpouseS02,Entities.U_SpouseS03,Entities.U_SpouseF01,Entities.U_SpouseF01,Entities.U_SpouseF02,Entities.U_SpouseF03}VictoryGenerateFestivalAtPlayer(dQl0xvy2,YTrvPn)
Logic.ExecuteInLuaLocalState(
[[
            if IsExisting(]]..
hX..
[[) then
                CameraAnimation.AllowAbort = false
                CameraAnimation.QueueAnimation( CameraAnimation.SetCameraToEntity, ]]..
hX..
[[)
                CameraAnimation.QueueAnimation( CameraAnimation.StartCameraRotation,  5 )
                CameraAnimation.QueueAnimation( CameraAnimation.Stay ,  9999 )
            end
            XGUIEng.ShowWidget("/InGame/InGame/MissionEndScreen/ContinuePlaying", 0);
        ]])end end;function b_Reward_VictoryWithParty:DEBUG(pB6K)return false end
Core:RegisterBehavior(b_Reward_VictoryWithParty)
function Reward_SetVisible(...)return b_Reward_SetVisible:new(...)end
b_Reward_SetVisible=API.InstanceTable(b_Reprisal_SetVisible)b_Reward_SetVisible.Name="Reward_ChangePlayer"
b_Reward_SetVisible.Description.en="Reward: Changes the visibility of an entity. If the entity is a spawner the spawned entities will be affected."
b_Reward_SetVisible.Description.de="Lohn: Setzt die Sichtbarkeit einer Entity. Handelt es sich um einen Spawner werden auch die gespawnten Entities beeinflusst."b_Reward_SetVisible.GetReprisalTable=nil
b_Reward_SetVisible.GetRewardTable=function(YV,zPm)return
{Reward.Custom,{YV,YV.CustomFunction}}end;Core:RegisterBehavior(b_Reward_SetVisible)function Reward_AI_SetEntityControlled(...)return
b_Reward_AI_SetEntityControlled:new(...)end
b_Reward_AI_SetEntityControlled={Name="Reward_AI_SetEntityControlled",Description={en="Reward: Bind or Unbind an entity or a battalion to/from an AI player. The AI player must be activated!",de="Lohn: Die KI kontrolliert die Entity oder der KI die Kontrolle entziehen. Die KI muss aktiv sein!"},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Custom,en="AI control entity",de="KI kontrolliert Entity"}}}
function b_Reward_AI_SetEntityControlled:GetRewardTable(JmEyZ5)return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_AI_SetEntityControlled:AddParameter(FGvy,KpnA)
if(FGvy==0)then self.Entity=KpnA elseif
(FGvy==1)then self.Hidden=AcceptAlternativeBoolean(KpnA)end end
function b_Reward_AI_SetEntityControlled:CustomFunction(j_F9c)if
not IsExisting(self.Entity)then return end;local q=GetID(self.Entity)
local b7G0ciz=Logic.EntityGetPlayer(q)local rF2te=Logic.GetEntityType(q)
local KG_EjN=Logic.GetEntityTypeName(rF2te)
if

string.find(KG_EjN,"S_")or string.find(KG_EjN,"B_NPC_Bandits")or string.find(KG_EjN,"B_NPC_Barracks")then local aIrjXeB={Logic.GetSpawnedEntities(q)}
for sZdri=1,#aIrjXeB do if
Logic.IsLeader(aIrjXeB[sZdri])==1 then
AICore.HideEntityFromAI(b7G0ciz,aIrjXeB[sZdri],not self.Hidden)end end else
AICore.HideEntityFromAI(b7G0ciz,q,not self.Hidden)end end;function b_Reward_AI_SetEntityControlled:GetCustomData(pT)
if pT==1 then return{"false","true"}end end
function b_Reward_AI_SetEntityControlled:DEBUG(XgkgIR9)
if
not IsExisting(self.Entity)then
dbg(XgkgIR9.Identifier..
" "..self.Name..": entity '"..self.Entity..
"' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Reward_AI_SetEntityControlled)function Reward_SetVulnerability(...)
return b_Reward_SetVulnerability:new(...)end
b_Reward_SetVulnerability=API.InstanceTable(b_Reprisal_SetVulnerability)b_Reward_SetVulnerability.Name="Reward_SetVulnerability"
b_Reward_SetVulnerability.Description.en="Reward: Changes the vulnerability of the entity. If the entity is a spawner the spawned entities will be affected."
b_Reward_SetVulnerability.Description.de="Lohn: Macht eine Entity verwundbar oder unverwundbar. Handelt es sich um einen Spawner, sind die gespawnten Entities betroffen."b_Reward_SetVulnerability.GetReprisalTable=nil
b_Reward_SetVulnerability.GetRewardTable=function(sm2,cz)return
{Reward.Custom,{sm2,sm2.CustomFunction}}end;Core:RegisterBehavior(b_Reward_SetVulnerability)function Reward_SetModel(...)return
b_Reward_SetModel:new(...)end
b_Reward_SetModel=API.InstanceTable(b_Reprisal_SetModel)b_Reward_SetModel.Name="Reward_SetModel"
b_Reward_SetModel.Description.en="Reward: Changes the model of the entity. Be careful, some models crash the game."
b_Reward_SetModel.Description.de="Lohn: Aendert das Model einer Entity. Achtung: Einige Modelle fuehren zum Absturz."b_Reward_SetModel.GetReprisalTable=nil
b_Reward_SetModel.GetRewardTable=function(pSL,ifrP9)return
{Reward.Custom,{pSL,pSL.CustomFunction}}end;Core:RegisterBehavior(b_Reward_SetModel)function Reward_RefillAmmunition(...)return
b_Reward_RefillAmmunition:new(...)end
b_Reward_RefillAmmunition={Name="Reward_RefillAmmunition",Description={en="Reward: Refills completely the ammunition of the entity.",de="Lohn: Fuellt die Munition der Entity vollständig auf."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"}}}
function b_Reward_RefillAmmunition:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end;function b_Reward_RefillAmmunition:AddParameter(Iynmp,PFvHX)
if(Iynmp==0)then self.Scriptname=PFvHX end end
function b_Reward_RefillAmmunition:CustomFunction()
local sP=GetID(self.Scriptname)if not IsExisting(sP)then return end
local Y=Logic.GetAmmunitionAmount(sP)while(Y<10)do Logic.RefillAmmunitions(sP)
Y=Logic.GetAmmunitionAmount(sP)end end
function b_Reward_RefillAmmunition:DEBUG(QHxdp58D)
if not IsExisting(self.Scriptname)then
dbg(
QHxdp58D.Identifier..": Error in "..
self.Name..": '"..self.Scriptname.."' is destroyed!")return true end;return false end;Core:RegisterBehavior(b_Reward_RefillAmmunition)
function Trigger_OnAtLeastXOfYQuestsFailed(...)return
b_Trigger_OnAtLeastXOfYQuestsFailed:new(...)end
b_Trigger_OnAtLeastXOfYQuestsFailed={Name="Trigger_OnAtLeastXOfYQuestsFailed",Description={en="Trigger: if at least X of Y given quests has been finished successfully.",de="Ausloeser: wenn X von Y angegebener Quests fehlgeschlagen sind."},Parameter={{ParameterType.Custom,en="Least Amount",de="Mindest Anzahl"},{ParameterType.Custom,en="Quest Amount",de="Quest Anzahl"},{ParameterType.QuestName,en="Quest name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest name 2",de="Questname 2"},{ParameterType.QuestName,en="Quest name 3",de="Questname 3"},{ParameterType.QuestName,en="Quest name 4",de="Questname 4"},{ParameterType.QuestName,en="Quest name 5",de="Questname 5"}}}
function b_Trigger_OnAtLeastXOfYQuestsFailed:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnAtLeastXOfYQuestsFailed:AddParameter(efdknL,YUdva)
if(efdknL==0)then
self.LeastAmount=tonumber(YUdva)elseif(efdknL==1)then self.QuestAmount=tonumber(YUdva)elseif(efdknL==2)then
self.QuestName1=YUdva elseif(efdknL==3)then self.QuestName2=YUdva elseif(efdknL==4)then self.QuestName3=YUdva elseif(efdknL==
5)then self.QuestName4=YUdva elseif(efdknL==6)then self.QuestName5=YUdva end end
function b_Trigger_OnAtLeastXOfYQuestsFailed:CustomFunction()local x8FBS=0
for LGBr=1,self.QuestAmount do
local M=GetQuestID(self["QuestName"..LGBr])if IsValidQuest(M)then
if
(Quests[M].Result==QuestResult.Failure)then x8FBS=x8FBS+1;if x8FBS>=self.LeastAmount then return true end end end end;return false end
function b_Trigger_OnAtLeastXOfYQuestsFailed:DEBUG(I)local W=self.LeastAmount
local Dx5GC=self.QuestAmount
if W<=0 or W>5 then
dbg(I.Identifier..
": Error in "..self.Name..": LeastAmount is wrong")return true elseif Dx5GC<=0 or Dx5GC>5 then
dbg(I.Identifier..": Error in "..
self.Name..": QuestAmount is wrong")return true elseif W>Dx5GC then
dbg(I.Identifier..": Error in "..
self.Name..": LeastAmount is greater than QuestAmount")return true end
for kwZhI=1,Dx5GC do
if
not IsValidQuest(self["QuestName"..kwZhI])then
dbg(I.Identifier..
": Error in "..self.Name..": Quest "..
self["QuestName"..kwZhI].." not found")return true end end;return false end
function b_Trigger_OnAtLeastXOfYQuestsFailed:GetCustomData(T0h)if(T0h==0)or(T0h==1)then return
{"1","2","3","4","5"}end end
Core:RegisterBehavior(b_Trigger_OnAtLeastXOfYQuestsFailed)function Trigger_AmmunitionDepleted(...)
return b_Trigger_AmmunitionDepleted:new(...)end
b_Trigger_AmmunitionDepleted={Name="Trigger_AmmunitionDepleted",Description={en="Trigger: if the ammunition of the entity is depleted.",de="Ausloeser: wenn die Munition der Entity aufgebraucht ist."},Parameter={{ParameterType.Scriptname,en="Script name",de="Skriptname"}}}
function b_Trigger_AmmunitionDepleted:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end;function b_Trigger_AmmunitionDepleted:AddParameter(H0,Mrz66)
if(H0 ==0)then self.Scriptname=Mrz66 end end
function b_Trigger_AmmunitionDepleted:CustomFunction()
if
not IsExisting(self.Scriptname)then return false end;local A=GetID(self.Scriptname)if
Logic.GetAmmunitionAmount(A)>0 then return false end;return true end
function b_Trigger_AmmunitionDepleted:DEBUG(RR)
if not IsExisting(self.Scriptname)then
dbg(
RR.Identifier..": Error in "..
self.Name..": '"..self.Scriptname.."' is destroyed!")return true end;return false end
Core:RegisterBehavior(b_Trigger_AmmunitionDepleted)function Trigger_OnExactOneQuestIsWon(...)
return b_Trigger_OnExactOneQuestIsWon:new(...)end
b_Trigger_OnExactOneQuestIsWon={Name="Trigger_OnExactOneQuestIsWon",Description={en="Trigger: if one of two given quests has been finished successfully, but NOT both.",de="Ausloeser: wenn eine von zwei angegebenen Quests (aber NICHT beide) erfolgreich abgeschlossen wurde."},Parameter={{ParameterType.QuestName,en="Quest Name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest Name 2",de="Questname 2"}}}
function b_Trigger_OnExactOneQuestIsWon:GetTriggerTable(Oj4B)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnExactOneQuestIsWon:AddParameter(aT,ZN0brC)self.QuestTable={}if(aT==0)then
self.Quest1=ZN0brC elseif(aT==1)then self.Quest2=ZN0brC end end
function b_Trigger_OnExactOneQuestIsWon:CustomFunction(g)
local iYIip_rt=Quests[GetQuestID(self.Quest1)]local WoJla=Quests[GetQuestID(self.Quest2)]
if
WoJla and iYIip_rt then
local jk=(iYIip_rt.State==QuestState.Over and
iYIip_rt.Result==QuestResult.Success)
local Y=(WoJla.State==QuestState.Over and WoJla.Result==QuestResult.Success)
if(jk and not Y)or(not jk and Y)then return true end end;return false end
function b_Trigger_OnExactOneQuestIsWon:DEBUG(sM)
if self.Quest1 ==self.Quest2 then
dbg(sM.Identifier..": "..
self.Name..": Both quests are identical!")return true elseif not IsValidQuest(self.Quest1)then
dbg(sM.Identifier..": "..
self.Name..": Quest '"..
self.Quest1 .."' does not exist!")return true elseif not IsValidQuest(self.Quest2)then
dbg(sM.Identifier..": "..
self.Name..": Quest '"..
self.Quest2 .."' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon)function Trigger_OnExactOneQuestIsLost(...)
return b_Trigger_OnExactOneQuestIsLost:new(...)end
b_Trigger_OnExactOneQuestIsLost={Name="Trigger_OnExactOneQuestIsLost",Description={en="Trigger: If one of two given quests has been lost, but NOT both.",de="Ausloeser: Wenn einer von zwei angegebenen Quests (aber NICHT beide) fehlschlägt."},Parameter={{ParameterType.QuestName,en="Quest Name 1",de="Questname 1"},{ParameterType.QuestName,en="Quest Name 2",de="Questname 2"}}}
function b_Trigger_OnExactOneQuestIsLost:GetTriggerTable(MMJEx)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_OnExactOneQuestIsLost:AddParameter(EB,Qy)self.QuestTable={}if(EB==0)then
self.Quest1=Qy elseif(EB==1)then self.Quest2=Qy end end
function b_Trigger_OnExactOneQuestIsLost:CustomFunction(rCWKBim)
local i=Quests[GetQuestID(self.Quest1)]local wLI=Quests[GetQuestID(self.Quest2)]
if wLI and i then
local N7h=(i.State==
QuestState.Over and i.Result==QuestResult.Failure)
local jDOa=(wLI.State==QuestState.Over and wLI.Result==QuestResult.Failure)
if(N7h and not jDOa)or(not N7h and jDOa)then return true end end;return false end
function b_Trigger_OnExactOneQuestIsLost:DEBUG(DcVHvlcZ)
if self.Quest1 ==self.Quest2 then
dbg(
DcVHvlcZ.Identifier..": "..self.Name..": Both quests are identical!")return true elseif not IsValidQuest(self.Quest1)then
dbg(DcVHvlcZ.Identifier..": "..
self.Name..
": Quest '"..self.Quest1 .."' does not exist!")return true elseif not IsValidQuest(self.Quest2)then
dbg(DcVHvlcZ.Identifier..": "..
self.Name..
": Quest '"..self.Quest2 .."' does not exist!")return true end;return false end
Core:RegisterBehavior(b_Trigger_OnExactOneQuestIsWon)BundleSymfoniaBehaviors={Global={},Local={}}
function BundleSymfoniaBehaviors.Global:Install()
GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors=GameCallback_OnThiefDeliverEarnings
GameCallback_OnThiefDeliverEarnings=function(Z,Ke2eY9,mJU4,y)
GameCallback_OnThiefDeliverEarnings_Orig_QSB_SymfoniaBehaviors(Z,Ke2eY9,mJU4,y)
for wtz=1,Quests[0]do
if
Quests[wtz]and Quests[wtz].State==QuestState.Active then
for N7=1,Quests[wtz].Objectives[0]do
if
Quests[wtz].Objectives[N7].Type==Objective.Custom2 then
if
Quests[wtz].Objectives[N7].Data[1].Name=="Goal_StealBuilding"then local LLka3VWH
for B34=1,#
Quests[wtz].Objectives[N7].Data[1].RobberList do
local S9D=Quests[wtz].Objectives[N7].Data[1].RobberList[B34]if
S9D[1]==
GetID(Quests[wtz].Objectives[N7].Data[1].Building)and S9D[2]==Ke2eY9 then LLka3VWH=true;break end end;if LLka3VWH then
Quests[wtz].Objectives[N7].Data[1].SuccessfullyStohlen=true end elseif
Quests[wtz].Objectives[N7].Data[1].Name=="Goal_StealGold"then Quests[wtz].Objectives[N7].Data[1].StohlenGold=
Quests[wtz].Objectives[N7].Data[1].StohlenGold+y
if
Quests[wtz].Objectives[N7].Data[1].Printout then local JeqL=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local RmN8={de="Talern gestohlen",en="gold stolen"}
local ePtDYbn=Quests[wtz].Objectives[N7].Data[1].StohlenGold
local dPm5lS=Quests[wtz].Objectives[N7].Data[1].Amount
API.Note(string.format("%d/%d %s",ePtDYbn,dPm5lS,RmN8[JeqL]))end end end end end end end
GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors=GameCallback_OnThiefStealBuilding
GameCallback_OnThiefStealBuilding=function(fNIe,y2R1,O,JyKiCqQo)
GameCallback_OnThiefStealBuilding_Orig_QSB_SymfoniaBehaviors(fNIe,y2R1,O,JyKiCqQo)
for wCXetPV=1,Quests[0]do
if Quests[wCXetPV]and
Quests[wCXetPV].State==QuestState.Active then
for RPo=1,Quests[wCXetPV].Objectives[0]do
if
Quests[wCXetPV].Objectives[RPo].Type==Objective.Custom2 then
if
Quests[wCXetPV].Objectives[RPo].Data[1].Name=="Goal_Infiltrate"then
if
GetID(Quests[wCXetPV].Objectives[RPo].Data[1].Building)==O and
Quests[wCXetPV].ReceivingPlayer==y2R1 then
Quests[wCXetPV].Objectives[RPo].Data[1].Infiltrated=true;if
Quests[wCXetPV].Objectives[RPo].Data[1].Delete then DestroyEntity(fNIe)end end elseif
Quests[wCXetPV].Objectives[RPo].Data[1].Name=="Goal_StealBuilding"then local k0Z;local kVpWe4Q=
Logic.IsEntityInCategory(O,EntityCategories.Cathedrals)==1;local ni=
Logic.GetEntityType(O)==Entities.B_StoreHouse
if
ni or kVpWe4Q then
Quests[wCXetPV].Objectives[RPo].Data[1].SuccessfullyStohlen=true else
for Jo1IX=1,#
Quests[wCXetPV].Objectives[RPo].Data[1].RobberList do
local Abdl=Quests[wCXetPV].Objectives[RPo].Data[1].RobberList[Jo1IX]
if Abdl[1]==O and Abdl[2]==fNIe then k0Z=true;break end end end;if not k0Z then
table.insert(Quests[wCXetPV].Objectives[RPo].Data[1].RobberList,{O,fNIe})end end end end end end end
QuestTemplate.IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors=QuestTemplate.IsObjectiveCompleted
QuestTemplate.IsObjectiveCompleted=function(I4LLjpL,vAK)local zx=vAK.Type;local hs=vAK.Data;if vAK.Completed~=nil then return
vAK.Completed end
if zx==Objective.Distance then
local v0yK_h=GetID(hs[1])local u=GetID(hs[2])hs[3]=hs[3]or 2500
if not
(
Logic.IsEntityDestroyed(v0yK_h)or Logic.IsEntityDestroyed(u))then if
Logic.GetDistanceBetweenEntities(v0yK_h,u)<=hs[3]then DestroyQuestMarker(u)
vAK.Completed=true end else
DestroyQuestMarker(u)vAK.Completed=false end else
return I4LLjpL:IsObjectiveCompleted_Orig_QSB_SymfoniaBehaviors(vAK)end end
function QuestTemplate:RemoveQuestMarkers()
for Ragi=1,self.Objectives[0]do
if
self.Objectives[Ragi].Type==Objective.Distance then if
self.Objectives[Ragi].Data[4]then
DestroyQuestMarker(self.Objectives[Ragi].Data[2])end end end end
function QuestTemplate:ShowQuestMarkers()
for N_cPM=1,self.Objectives[0]do
if
self.Objectives[N_cPM].Type==Objective.Distance then if
self.Objectives[N_cPM].Data[4]then
ShowQuestMarker(self.Objectives[N_cPM].Data[2])end end end end
function ShowQuestMarker(R)local lV=GetID(R)local eYLj,gC=Logic.GetEntityPosition(lV)
local hhkXHj=EGL_Effects.E_Questmarker_low
if Logic.IsBuilding(lV)==1 then hhkXHj=EGL_Effects.E_Questmarker end
Questmarkers[lV]=Logic.CreateEffect(hhkXHj,eYLj,gC,0)end
function DestroyQuestMarker(XXWAbp)local QzMjn=GetID(XXWAbp)
if Questmarkers[QzMjn]~=nil then
Logic.DestroyEffect(Questmarkers[QzMjn])Questmarkers[QzMjn]=nil end end end;function BundleSymfoniaBehaviors.Local:Install()end
Core:RegisterBundle("BundleSymfoniaBehaviors")API=API or{}QSB=QSB or{}
function API.AddQuest(TPgGG6_)if GUI then
API.Log("API.AddQuest: Could not execute in local script!")return end;return
BundleQuestGeneration.Global:NewQuest(TPgGG6_)end;AddQuest=API.AddQuest
function API.StartQuests()if GUI then
API.Brudge("API.StartQuests()")return end;return
BundleQuestGeneration.Global:StartQuests()end;StartQuests=API.StartQuests
function API.QuestMessage(_,PmnCOE8,wKi1TU,zmJGh,L,gK05I0EL)if GUI then
API.Log("API.QuestMessage: Could not execute in local script!")return end;return
BundleQuestGeneration.Global:QuestMessage(_,PmnCOE8,wKi1TU,zmJGh,L,gK05I0EL)end;QuestMessage=API.QuestMessage
function API.QuestDialog(hUY0OEu)if GUI then
API.Log("API.QuestDialog: Could not execute in local script!")return end;local sRd,Cu;local WbHkOLVO={}
for tRs=1,#hUY0OEu,1 do
if tRs>1 then hUY0OEu[tRs][4]=
hUY0OEu[tRs][4]or Cu.Identifier;hUY0OEu[tRs][5]=
hUY0OEu[tRs][5]or 12 end
sRd,Cu=API.QuestMessage(unpack(hUY0OEu[tRs]))table.insert(WbHkOLVO,{sRd,Cu})end;return WbHkOLVO end;QuestDialog=API.QuestDialog
BundleQuestGeneration={Global={Data={GenerationList={},QuestMessageID=0}},Local={Data={}}}
BundleQuestGeneration.Global.Data.QuestTemplate={MSGKeyOverwrite=nil,IconOverwrite=nil,Loop=nil,Callback=nil,SuggestionText=nil,SuccessText=nil,FailureText=nil,Description=nil,Identifier=
nil,OpenMessage=true,CloseMessage=true,Sender=1,Receiver=1,Time=0,Goals={},Reprisals={},Rewards={},Triggers={}}function BundleQuestGeneration.Global:Install()end
function BundleQuestGeneration.Global:QuestMessage(L,_,b,PGFeEoyz,nG9jWF,Au)self.Data.QuestMessageID=
self.Data.QuestMessageID+1
local rY5={Triggers.Custom2,{{QuestName=PGFeEoyz},function(wYc)if
not wYc.QuestName then return true end;local gL=GetQuestID(wYc.QuestName)if
(
Quests[gL].State==QuestState.Over and
Quests[gL].Result~=QuestResult.Interrupted)then return true end;return false end}}local LJqvVB2=
(Network.GetDesiredLanguage()=="de"and"de")or"en"if
type(L)=="table"then L=L[LJqvVB2]end
assert(type(L)=="string")
return
QuestTemplate:New("QSB_QuestMessage_"..self.Data.QuestMessageID,(_ or 1),(b or 1),{{Objective.NoChange}},{rY5},(
nG9jWF or 1),nil,nil,Au,nil,false,(L~=nil),nil,nil,L,nil)end
function BundleQuestGeneration.Global:NewQuest(FH5YFuU)
local VJ7LpW=(Network.GetDesiredLanguage()==
"de"and"de")or"en"
if not FH5YFuU.Name then QSB.AutomaticQuestNameCounter=
(QSB.AutomaticQuestNameCounter or 0)+1
FH5YFuU.Name=string.format("AutoNamed_Quest_%d",QSB.AutomaticQuestNameCounter)end
if not Core:CheckQuestName(FH5YFuU.Name)then
dbg("Quest '"..
tostring(FH5YFuU.Name).."': invalid questname! Contains forbidden characters!")return end
local AmrXlmse=API.InstanceTable(self.Data.QuestTemplate)AmrXlmse.Identifier=FH5YFuU.Name;AmrXlmse.MSGKeyOverwrite=nil;AmrXlmse.IconOverwrite=
nil;AmrXlmse.Loop=FH5YFuU.Loop
AmrXlmse.Callback=FH5YFuU.Callback
AmrXlmse.SuggestionText=(type(FH5YFuU.Suggestion)=="table"and
FH5YFuU.Suggestion[VJ7LpW])or
FH5YFuU.Suggestion
AmrXlmse.SuccessText=(type(FH5YFuU.Success)=="table"and
FH5YFuU.Success[VJ7LpW])or FH5YFuU.Success
AmrXlmse.FailureText=(type(FH5YFuU.Failure)=="table"and
FH5YFuU.Failure[VJ7LpW])or FH5YFuU.Failure
AmrXlmse.Description=(type(FH5YFuU.Description)=="table"and
FH5YFuU.Description[VJ7LpW])or
FH5YFuU.Description
AmrXlmse.OpenMessage=FH5YFuU.Visible==true or FH5YFuU.Suggestion~=nil
AmrXlmse.CloseMessage=FH5YFuU.EndMessage==true or(FH5YFuU.Failure~=nil or FH5YFuU.Success~=
nil)AmrXlmse.Sender=
(FH5YFuU.Sender~=nil and FH5YFuU.Sender)or 1
AmrXlmse.Receiver=(
FH5YFuU.Receiver~=nil and FH5YFuU.Receiver)or 1
AmrXlmse.Time=(FH5YFuU.Time~=nil and FH5YFuU.Time)or 0;if FH5YFuU.Arguments then
AmrXlmse.Arguments=API.InstanceTable(FH5YFuU.Arguments)end
table.insert(self.Data.GenerationList,AmrXlmse)local L=#self.Data.GenerationList
self:AttachBehavior(L,FH5YFuU)self:StartQuests()return Quests[0]end
function BundleQuestGeneration.Global:AttachBehavior(e,gNWih6)
local uwzJA0D=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
for NGfeE,Uh7tTLt in pairs(gNWih6)do
if

NGfeE~="Parameter"and type(Uh7tTLt)=="table"and Uh7tTLt.en and Uh7tTLt.de then gNWih6[NGfeE]=Uh7tTLt[uwzJA0D]end end
for uHLv,GNSwGhP in pairs(gNWih6)do
if tonumber(uHLv)~=nil then
if type(GNSwGhP)~="table"then
dbg(
self.Data.GenerationList[e].Identifier..": Some behavior entries aren't behavior!")else
if GNSwGhP.GetGoalTable then
table.insert(self.Data.GenerationList[e].Goals,GNSwGhP:GetGoalTable())
local MPsJa56=#self.Data.GenerationList[e].Goals
self.Data.GenerationList[e].Goals[MPsJa56].Context=GNSwGhP
self.Data.GenerationList[e].Goals[MPsJa56].FuncOverrideIcon=self.Data.GenerationList[e].Goals[MPsJa56].Context.GetIcon
self.Data.GenerationList[e].Goals[MPsJa56].FuncOverrideMsgKey=self.Data.GenerationList[e].Goals[MPsJa56].Context.GetMsgKey elseif GNSwGhP.GetReprisalTable then
table.insert(self.Data.GenerationList[e].Reprisals,GNSwGhP:GetReprisalTable())elseif GNSwGhP.GetRewardTable then
table.insert(self.Data.GenerationList[e].Rewards,GNSwGhP:GetRewardTable())elseif GNSwGhP.GetTriggerTable then
table.insert(self.Data.GenerationList[e].Triggers,GNSwGhP:GetTriggerTable())else
dbg(self.Data.GenerationList[e].Identifier..": Could not obtain behavior table!")end end end end end
function BundleQuestGeneration.Global:StartQuests()if
not self:ValidateQuests()then return end
while
(#self.Data.GenerationList>0)do local OR8kQwdZ=table.remove(self.Data.GenerationList,1)
if
self:DebugQuest(OR8kQwdZ)then
local bsS,teN1=QuestTemplate:New(OR8kQwdZ.Identifier,OR8kQwdZ.Sender,OR8kQwdZ.Receiver,OR8kQwdZ.Goals,OR8kQwdZ.Triggers,assert(tonumber(OR8kQwdZ.Time)),OR8kQwdZ.Rewards,OR8kQwdZ.Reprisals,OR8kQwdZ.Callback,OR8kQwdZ.Loop,OR8kQwdZ.OpenMessage,OR8kQwdZ.CloseMessage,OR8kQwdZ.Description,OR8kQwdZ.SuggestionText,OR8kQwdZ.SuccessText,OR8kQwdZ.FailureText)
if OR8kQwdZ.MSGKeyOverwrite then teN1.MsgTableOverride=self.MSGKeyOverwrite end
if OR8kQwdZ.IconOverwrite then teN1.IconOverride=self.IconOverwrite end;if OR8kQwdZ.Arguments then
teN1.Arguments=API.InstanceTable(OR8kQwdZ.Arguments)end end end end
function BundleQuestGeneration.Global:ValidateQuests()
for oTK9pYO,F_A in
pairs(self.Data.GenerationList)do if#F_A.Goals==0 then
table.insert(self.Data.GenerationList[oTK9pYO].Goals,Goal_InstantSuccess())end;if#F_A.Triggers==0 then
table.insert(self.Data.GenerationList[oTK9pYO].Triggers,Trigger_Time(0))end
if#F_A.Goals==0 and
#F_A.Triggers==0 then
local I8x=string.format("Quest '"..
F_A.Identifier.."' is missing a goal or a trigger!")return false end;local H=""
if not F_A then H=H.."quest table is invalid!"else
if F_A.Loop~=nil and
type(F_A.Loop)~="function"then H=H..
self.Identifier..": Loop must be a function!"end;if
F_A.Callback~=nil and type(F_A.Callback)~="function"then
H=H..self.Identifier..": Callback must be a function!"end;if
(F_A.Sender==nil or(
F_A.Sender<1 or F_A.Sender>8))then
H=H..F_A.Identifier..": Sender is nil or greater than 8 or lower than 1!"end;if
(F_A.Receiver==
nil or(F_A.Receiver<0 or F_A.Receiver>8))then
H=H..self.Identifier..": Receiver is nil or greater than 8 or lower than 0!"end;if
(
F_A.Time==nil or type(F_A.Time)~="number"or F_A.Time<0)then
H=H..F_A.Identifier..": Time is nil or not a number or lower than 0!"end;if
type(F_A.OpenMessage)~="boolean"then
H=H..F_A.Identifier..": Visible need to be a boolean!"end;if type(F_A.CloseMessage)~=
"boolean"then
H=H..F_A.Identifier..": EndMessage need to be a boolean!"end;if
(F_A.Description~=nil and
type(F_A.Description)~="string")then
H=H..F_A.Identifier..": Description is not a string!"end;if
(
F_A.SuggestionText~=nil and type(F_A.SuggestionText)~="string")then
H=H..F_A.Identifier..": Suggestion is not a string!"end;if
(
F_A.SuccessText~=nil and type(F_A.SuccessText)~="string")then
H=H..F_A.Identifier..": Success is not a string!"end;if
(
F_A.FailureText~=nil and type(F_A.FailureText)~="string")then
H=H..F_A.Identifier..": Failure is not a string!"end end;if H~=""then dbg(H)return false end end;return true end
function BundleQuestGeneration.Global:DebugQuest(ZMfC)return true end;function BundleQuestGeneration.Local:Install()end
Core:RegisterBundle("BundleQuestGeneration")API=API or{}QSB=QSB or{}
BundleNonPlayerCharacter={Global={NonPlayerCharacter={Data={}},NonPlayerCharacterObjects={},LastNpcEntityID=0,LastHeroEntityID=0},Local={}}
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:New(liJ)
assert(
self==BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used from instance!')
assert(IsExisting(liJ),'entity "'..liJ..'" does not exist!')local dfggtz5r=CopyTableRecursive(self)
dfggtz5r.Data.NpcName=liJ
BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[liJ]=dfggtz5r;return dfggtz5r end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetInstance(H)
assert(
self==BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used from instance!')local uVezg=GetID(H)local NQqlVm0=Logic.GetEntityName(uVezg)
if
Logic.IsEntityInCategory(uVezg,EntityCategories.Soldier)==1 then
local Wd=Logic.SoldierGetLeaderEntityID(uVezg)
if IsExisting(Wd)then NQqlVm0=Logic.GetEntityName(Wd)end end;return
BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[NQqlVm0]end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetNpcId()
assert(
self==BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used from instance!')
return BundleNonPlayerCharacter.Global.LastNpcEntityID end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetHeroId()
assert(
self==BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used from instance!')
return BundleNonPlayerCharacter.Global.LastHeroEntityID end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:GetID()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')local Z7Ssj_=GetID(self.Data.NpcName)
if
Logic.IsEntityInCategory(Z7Ssj_,EntityCategories.Leader)==1 then
local K={Logic.GetSoldiersAttachedToLeader(Z7Ssj_)}if K[1]>0 then return K[2]end end;return Z7Ssj_ end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Dispose()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self:Deactivate()BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects[self.Data.NpcName]=
nil end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Activate()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')if IsExisting(self.Data.NpcName)then
Logic.SetOnScreenInformation(self:GetID(),1)end;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Deactivate()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')if IsExisting(self.Data.NpcName)then
Logic.SetOnScreenInformation(self:GetID(),0)end;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:IsActive()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')return
Logic.GetEntityScriptingValue(self:GetID(),6)==1 end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Reset()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')
if IsExisting(self.Data.NpcName)then
Logic.SetOnScreenInformation(self:GetID(),0)self.Data.TalkedTo=nil end;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:HasTalkedTo()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')if self.Data.HeroName then return
self.Data.TalkedTo==GetID(self.Data.HeroName)end;return
self.Data.TalkedTo~=nil end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetDialogPartner(rp)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.HeroName=rp;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetWrongPartnerCallback(aS)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.WrongHeroCallback=aS;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowDestination(XhUJT)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.FollowDestination=XhUJT;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowTarget(nyo)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.FollowTarget=nyo;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetFollowAction(iig)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.FollowAction=iig;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetGuideParams(MW,PD)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.GuideDestination=MW;self.Data.GuideTarget=PD;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetGuideAction(xWD2lww)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')self.Data.GuideAction=xWD2lww;return self end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:SetCallback(VjnLG4)
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')
assert(type(VjnLG4)=="function",'callback must be a function!')self.Data.Callback=VjnLG4;return self end;function Goal_NPC(...)return b_Goal_NPC:new(...)end
b_Goal_NPC={Name="Goal_NPC",Description={en="Goal: The hero has to talk to a non-player character.",de="Ziel: Der Held muss einen Nichtspielercharakter ansprechen."},Parameter={{ParameterType.ScriptName,en="NPC",de="NPC"},{ParameterType.ScriptName,en="Hero",de="Held"}}}
function b_Goal_NPC:GetGoalTable(r2m)return
{Objective.Distance,-65565,self.Hero,self.NPC,self}end
function b_Goal_NPC:AddParameter(dwI6,TOIbK)
if(dwI6 ==0)then self.NPC=TOIbK elseif(dwI6 ==1)then self.Hero=TOIbK;if
self.Hero=="-"then self.Hero=nil end end end;function b_Goal_NPC:GetIcon()return{14,10}end
Core:RegisterBehavior(b_Goal_NPC)
function Trigger_NPC(...)return b_Trigger_NPC:new(...)end
b_Trigger_NPC={Name="Trigger_NPC",Description={en="Trigger: Starts the quest after the npc was spoken to.",de="Ausloeser: Startet den Quest, sobald der NPC angesprochen wurde."},Parameter={{ParameterType.ScriptName,en="NPC",de="NPC"},{ParameterType.ScriptName,en="Hero",de="Held"}}}function b_Trigger_NPC:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_NPC:AddParameter(JEC156,GC8)
if(
JEC156 ==0)then self.NPC=GC8 elseif(JEC156 ==1)then self.Hero=GC8;if self.Hero=="-"then self.Hero=
nil end end end
function b_Trigger_NPC:CustomFunction()
if not IsExisting(self.NPC)then return end
if not self.NpcInstance then
local P=NonPlayerCharacter:New(self.NPC)P:SetDialogPartner(self.Hero)self.NpcInstance=P end;local bJ=self.NpcInstance:HasTalkedTo(self.Hero)
if
not bJ then if not self.NpcInstance:IsActive()then
self.NpcInstance:Activate()end end;return bJ end;function b_Trigger_NPC:Reset(s4hK)
if self.NpcInstance then self.NpcInstance:Dispose()end end
function b_Trigger_NPC:DEBUG(H)return false end;Core:RegisterBehavior(b_Trigger_NPC)
function BundleNonPlayerCharacter.Global:Install()
NonPlayerCharacter=BundleNonPlayerCharacter.Global.NonPlayerCharacter
StartSimpleJobEx(function()
for CP,QJb in
pairs(BundleNonPlayerCharacter.Global.NonPlayerCharacterObjects)do NonPlayerCharacter:Control(CP)end end)
GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite=GameCallback_OnNPCInteraction
GameCallback_OnNPCInteraction=function(ows6K,yp6Si3X)
GameCallback_OnNPCInteraction_Orig_QSB_NPC_Rewrite(ows6K,yp6Si3X)Quest_OnNPCInteraction(ows6K,yp6Si3X)end
Quest_OnNPCInteraction=function(f,ZiKGn)local tDn={}Logic.GetKnights(ZiKGn,tDn)local NA=0
local jmLqyFaU=Logic.WorldGetSize()
for dpk87DtF=1,#tDn,1 do
local Vnx=Logic.GetDistanceBetweenEntities(tDn[dpk87DtF],f)if Vnx<jmLqyFaU then jmLqyFaU=Vnx;NA=tDn[dpk87DtF]end end
BundleNonPlayerCharacter.Global.LastHeroEntityID=NA;local REH=NonPlayerCharacter:GetInstance(f)
BundleNonPlayerCharacter.Global.LastNpcEntityID=REH:GetID()
if REH then
if REH.Data.FollowTarget~=nil then
if REH.Data.FollowDestination then
API.Note(Logic.GetDistanceBetweenEntities(f,GetID(REH.Data.FollowDestination)))
if
Logic.GetDistanceBetweenEntities(f,GetID(REH.Data.FollowDestination))>2000 then if REH.Data.FollowAction then
REH.Data.FollowAction(self)end;return end else
if REH.Data.FollowAction then REH.Data.FollowAction(self)end;return end end
if REH.Data.GuideTarget~=nil then
local MSsv5=GetID(REH.Data.GuideDestination)
if Logic.GetDistanceBetweenEntities(f,MSsv5)>2000 then if
REH.Data.GuideAction then REH.Data.GuideAction(REH)end;return end;Logic.SetTaskList(f,TaskLists.TL_NPC_IDLE)end;REH:RotateActors()REH.Data.TalkedTo=NA
if REH:HasTalkedTo()then
REH:Deactivate()
if REH.Data.Callback then REH.Data.Callback(REH,NA)end else
if REH.Data.WrongHeroCallback then REH.Data.WrongHeroCallback(REH,NA)end end end end
function QuestTemplate:RemoveQuestMarkers()
for pDUYq=1,self.Objectives[0]do
if
self.Objectives[pDUYq].Type==Objective.Distance then
if

(
(
type(self.Objectives[pDUYq].Data[1])=="number"and
self.Objectives[pDUYq].Data[1]>0)or(type(self.Objectives[pDUYq].Data[1])~=
"number"))and self.Objectives[pDUYq].Data[4]then
DestroyQuestMarker(self.Objectives[pDUYq].Data[2])end end end end
function QuestTemplate:ShowQuestMarkers()
for dt=1,self.Objectives[0]do
if self.Objectives[dt].Type==
Objective.Distance then
if

(
(
type(self.Objectives[dt].Data[1])=="number"and
self.Objectives[dt].Data[1]>0)or
(type(self.Objectives[dt].Data[1])~="number"))and self.Objectives[dt].Data[4]then
ShowQuestMarker(self.Objectives[dt].Data[2])end end end end
QuestTemplate.IsObjectiveCompleted_QSBU_NPC_Rewrite=QuestTemplate.IsObjectiveCompleted
QuestTemplate.IsObjectiveCompleted=function(Tx,xZ)local M=xZ.Type;local FprU1J=xZ.Data;if xZ.Completed~=nil then
return xZ.Completed end
if M~=Objective.Distance then return
Tx:IsObjectiveCompleted_QSBU_NPC_Rewrite(xZ)else
if FprU1J[1]==-65565 then
if
not IsExisting(FprU1J[3])then API.Dbg(FprU1J[3].." is dead! :(")
xZ.Completed=false else if not FprU1J[4].NpcInstance then
local a2W=NonPlayerCharacter:New(FprU1J[3])a2W:SetDialogPartner(FprU1J[2])
FprU1J[4].NpcInstance=a2W end;if
FprU1J[4].NpcInstance:HasTalkedTo(FprU1J[2])then xZ.Completed=true end
if not xZ.Completed then if not
FprU1J[4].NpcInstance:IsActive()then
FprU1J[4].NpcInstance:Activate()end end end else return Tx:IsObjectiveCompleted_QSBU_NPC_Rewrite(xZ)end end end end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:RotateActors()
assert(
self~=BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used in static context!')
local W6sFOn=Logic.EntityGetPlayer(BundleNonPlayerCharacter.Global.LastHeroEntityID)local JjyRs={}Logic.GetKnights(W6sFOn,JjyRs)
for jn1VT=1,#JjyRs,1 do
if
Logic.GetDistanceBetweenEntities(JjyRs[jn1VT],BundleNonPlayerCharacter.Global.LastNpcEntityID)<3000 then
local l6aapg,CvDYCml,XZAYA=Logic.EntityGetPos(JjyRs[jn1VT])if Logic.IsEntityMoving(JjyRs[jn1VT])then
Logic.MoveEntity(JjyRs[jn1VT],l6aapg,CvDYCml)end
LookAt(JjyRs[jn1VT],self.Data.NpcName)end end;local jl1YR7X=0;if Logic.IsKnight(GetID(self.Data.NpcName))then
jl1YR7X=15 end
LookAt(self.Data.NpcName,BundleNonPlayerCharacter.Global.LastHeroEntityID,jl1YR7X)
LookAt(BundleNonPlayerCharacter.Global.LastHeroEntityID,self.Data.NpcName,15)end
function BundleNonPlayerCharacter.Global.NonPlayerCharacter:Control(FU)
assert(
self==BundleNonPlayerCharacter.Global.NonPlayerCharacter,'Can not be used from instance!')if not IsExisting(FU)then return end
local tjNz8eMg=NonPlayerCharacter:GetInstance(FU)if not tjNz8eMg then return end
if not tjNz8eMg:IsActive()then return end
if tjNz8eMg.Data.FollowTarget~=nil then local X=tjNz8eMg:GetID()
local Lxcxu8m1=GetID(tjNz8eMg.Data.FollowTarget)local fHLa=Logic.GetDistanceBetweenEntities(X,Lxcxu8m1)
local C3f=400;if
Logic.IsEntityInCategory(X,EntityCategories.Hero)==1 then C3f=800 end;if fHLa<C3f or fHLa>3500 then
Logic.SetTaskList(X,TaskLists.TL_NPC_IDLE)return end
if fHLa>=C3f then
local wHNlhIoT,we,uMBZO=Logic.EntityGetPos(Lxcxu8m1)Logic.MoveSettler(X,wHNlhIoT,we)return end end
if tjNz8eMg.Data.GuideTarget~=nil then local c8x=tjNz8eMg:GetID()
local E9C=GetID(tjNz8eMg.Data.GuideTarget)local Ta8E=GetID(tjNz8eMg.Data.GuideDestination)
local SKju4zT9=Logic.GetDistanceBetweenEntities(c8x,E9C)local Dw2=Logic.GetDistanceBetweenEntities(c8x,Ta8E)
if
Dw2 >2000 then
if
SKju4zT9 <1500 and not Logic.IsEntityMoving(c8x)then local sGI9IM7,zX_b,Cy=Logic.EntityGetPos(Ta8E)
Logic.MoveSettler(c8x,sGI9IM7,zX_b)elseif SKju4zT9 >3000 and Logic.IsEntityMoving(c8x)then
local ZzZ,e_w,RqZA1A9s=Logic.EntityGetPos(c8x)Logic.MoveSettler(c8x,ZzZ,e_w)end end end end
function BundleNonPlayerCharacter.Local:Install()g_CurrentDisplayedQuestID=0
GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite=GUI_Interaction.DisplayQuestObjective
GUI_Interaction.DisplayQuestObjective=function(C,ptjB7)local bx=Network.GetDesiredLanguage()if
bx~="de"then bx="en"end;local KGas=tonumber(C)if KGas then C=KGas end
local m,S1f=GUI_Interaction.GetPotentialSubQuestAndType(C)local ZTs462="/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives"
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives",0)local xJ8Jb;local NPMnBOO;local d_t=Quests[C]local KagsBWw;if
d_t~=nil and type(d_t)=="table"then KagsBWw=d_t.Identifier end;local BCBpF9={}
g_CurrentDisplayedQuestID=C
if S1f==Objective.Distance then xJ8Jb=ZTs462 .."/List"
NPMnBOO=Wrapped_GetStringTableText(C,"UI_Texts/QuestInteraction")local sH={}
if m.Objectives[1].Data[1]==-65565 then
xJ8Jb=ZTs462 .."/Distance"
NPMnBOO=Wrapped_GetStringTableText(C,"UI_Texts/QuestMoveHere")SetIcon(xJ8Jb.."/QuestTypeIcon",{7,10})
local uIcE5O=GetEntityId(m.Objectives[1].Data[2])local P=Logic.GetEntityType(uIcE5O)
local b3M3x=g_TexturePositions.Entities[P]if
m.Objectives[1].Data[1]==-65567 or not b3M3x then b3M3x={16,12}end
SetIcon(xJ8Jb.."/IconMover",b3M3x)
local Uwyi2=GetEntityId(m.Objectives[1].Data[3])local bD=Logic.GetEntityType(Uwyi2)
local JqKgkiH=g_TexturePositions.Entities[bD]if not JqKgkiH then JqKgkiH={14,10}end
local DQJpOw=xJ8Jb.."/IconTarget"local u=xJ8Jb.."/TargetPlayerColor"
SetIcon(DQJpOw,JqKgkiH)XGUIEng.SetMaterialColor(u,0,255,255,255,0)SetIcon(xJ8Jb..
"/QuestTypeIcon",{16,12})
local _r2G={de="Gespräch beginnen",en="Start conversation"}NPMnBOO=_r2G[bx]
XGUIEng.SetText(xJ8Jb.."/Caption","{center}"..NPMnBOO)XGUIEng.ShowWidget(xJ8Jb,1)else
GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite(C,ptjB7)end else
GUI_Interaction.DisplayQuestObjective_Orig_QSBU_NPC_Rewrite(C,ptjB7)end end
GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite=GUI_Interaction.GetEntitiesOrTerritoryListForQuest
GUI_Interaction.GetEntitiesOrTerritoryListForQuest=function(ydY6,e)local OX9Pjj={}local h1=true
if e==Objective.Distance then
if
ydY6.Objectives[1].Data[1]==-65565 then
local m1HC9s7=GetEntityId(ydY6.Objectives[1].Data[3])table.insert(OX9Pjj,m1HC9s7)else return
GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite(ydY6,e)end else return
GUI_Interaction.GetEntitiesOrTerritoryListForQuest_Orig_QSBU_NPC_Rewrite(ydY6,e)end;return OX9Pjj,h1 end end;Core:RegisterBundle("BundleNonPlayerCharacter")API=API or
{}QSB=QSB or{}QSB.RequirementTooltipTypes={}
QSB.ConsumedGoodsCounter={}BundleKnightTitleRequirements={Global={},Local={Data={}}}function BundleKnightTitleRequirements.Global:Install()
self:OverwriteConsumedGoods()end
function BundleKnightTitleRequirements.Global:RegisterConsumedGoods(WeyidY,vS1)QSB.ConsumedGoodsCounter[WeyidY]=
QSB.ConsumedGoodsCounter[WeyidY]or{}QSB.ConsumedGoodsCounter[WeyidY][vS1]=
QSB.ConsumedGoodsCounter[WeyidY][vS1]or 0;QSB.ConsumedGoodsCounter[WeyidY][vS1]=
QSB.ConsumedGoodsCounter[WeyidY][vS1]+1 end
function BundleKnightTitleRequirements.Global:OverwriteConsumedGoods()
GameCallback_ConsumeGood_Orig_QSB_Requirements=GameCallback_ConsumeGood
GameCallback_ConsumeGood=function(cQ,i0bPk,eeu)
GameCallback_ConsumeGood_Orig_QSB_Requirements(cQ,i0bPk,eeu)local RcM=Logic.EntityGetPlayer(cQ)
BundleKnightTitleRequirements.Global:RegisterConsumedGoods(RcM,i0bPk)
Logic.ExecuteInLuaLocalState([[
            BundleKnightTitleRequirements.Global:RegisterConsumedGoods(
                ]]..RcM..[[, ]]..i0bPk..
[[
            );
        ]])end end
function BundleKnightTitleRequirements.Local:Install()
self:OverwriteTooltips()self:InitTexturePositions()
self:OverwriteUpdateRequirements()self:OverwritePromotionCelebration()end
function BundleKnightTitleRequirements.Local:RegisterConsumedGoods(HVXI,dft6l_U)QSB.ConsumedGoodsCounter[HVXI]=
QSB.ConsumedGoodsCounter[HVXI]or{}QSB.ConsumedGoodsCounter[HVXI][dft6l_U]=
QSB.ConsumedGoodsCounter[HVXI][dft6l_U]or 0;QSB.ConsumedGoodsCounter[HVXI][dft6l_U]=
QSB.ConsumedGoodsCounter[HVXI][dft6l_U]+1 end
function BundleKnightTitleRequirements.Local:InitTexturePositions()
g_TexturePositions.EntityCategories[EntityCategories.GC_Food_Supplier]={1,1}
g_TexturePositions.EntityCategories[EntityCategories.GC_Clothes_Supplier]={1,2}
g_TexturePositions.EntityCategories[EntityCategories.GC_Hygiene_Supplier]={16,1}
g_TexturePositions.EntityCategories[EntityCategories.GC_Entertainment_Supplier]={1,4}
g_TexturePositions.EntityCategories[EntityCategories.GC_Luxury_Supplier]={16,3}
g_TexturePositions.EntityCategories[EntityCategories.GC_Weapon_Supplier]={1,7}
g_TexturePositions.EntityCategories[EntityCategories.GC_Medicine_Supplier]={2,10}
g_TexturePositions.EntityCategories[EntityCategories.Outpost]={12,3}
g_TexturePositions.EntityCategories[EntityCategories.Spouse]={5,15}
g_TexturePositions.EntityCategories[EntityCategories.CattlePasture]={3,16}
g_TexturePositions.EntityCategories[EntityCategories.SheepPasture]={4,1}
g_TexturePositions.EntityCategories[EntityCategories.Soldier]={7,12}
g_TexturePositions.EntityCategories[EntityCategories.GrainField]={14,2}
g_TexturePositions.EntityCategories[EntityCategories.OuterRimBuilding]={3,4}
g_TexturePositions.EntityCategories[EntityCategories.CityBuilding]={8,1}
g_TexturePositions.EntityCategories[EntityCategories.Range]={9,8}
g_TexturePositions.EntityCategories[EntityCategories.Melee]={9,7}
g_TexturePositions.EntityCategories[EntityCategories.SiegeEngine]={2,15}
g_TexturePositions.Entities[Entities.B_Outpost]={12,3}
g_TexturePositions.Entities[Entities.B_Outpost_AS]={12,3}
g_TexturePositions.Entities[Entities.B_Outpost_ME]={12,3}
g_TexturePositions.Entities[Entities.B_Outpost_NA]={12,3}
g_TexturePositions.Entities[Entities.B_Outpost_NE]={12,3}
g_TexturePositions.Entities[Entities.B_Outpost_SE]={12,3}
g_TexturePositions.Entities[Entities.B_Cathedral_Big]={3,12}
g_TexturePositions.Entities[Entities.U_MilitaryBallista]={10,5}
g_TexturePositions.Entities[Entities.U_Trebuchet]={9,1}
g_TexturePositions.Entities[Entities.U_SiegeEngineCart]={9,4}
g_TexturePositions.Needs[Needs.Medicine]={2,10}
g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_1]={4,7}
g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_2]={4,7}
g_TexturePositions.Technologies[Technologies.R_Castle_Upgrade_3]={4,7}
g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_1]={4,5}
g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_2]={4,5}
g_TexturePositions.Technologies[Technologies.R_Cathedral_Upgrade_3]={4,5}
g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_1]={4,6}
g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_2]={4,6}
g_TexturePositions.Technologies[Technologies.R_Storehouse_Upgrade_3]={4,6}
g_TexturePositions.Buffs=g_TexturePositions.Buffs or{}
g_TexturePositions.Buffs[Buffs.Buff_ClothesDiversity]={1,2}
g_TexturePositions.Buffs[Buffs.Buff_EntertainmentDiversity]={1,4}
g_TexturePositions.Buffs[Buffs.Buff_FoodDiversity]={1,1}
g_TexturePositions.Buffs[Buffs.Buff_HygieneDiversity]={1,3}
g_TexturePositions.Buffs[Buffs.Buff_Colour]={5,11}
g_TexturePositions.Buffs[Buffs.Buff_Entertainers]={5,12}
g_TexturePositions.Buffs[Buffs.Buff_ExtraPayment]={1,8}
g_TexturePositions.Buffs[Buffs.Buff_Sermon]={4,14}
g_TexturePositions.Buffs[Buffs.Buff_Spice]={5,10}
g_TexturePositions.Buffs[Buffs.Buff_NoTaxes]={1,6}
if Framework.GetGameExtraNo()~=0 then
g_TexturePositions.Buffs[Buffs.Buff_Gems]={1,1,1}
g_TexturePositions.Buffs[Buffs.Buff_MusicalInstrument]={1,3,1}
g_TexturePositions.Buffs[Buffs.Buff_Olibanum]={1,2,1}end
g_TexturePositions.GoodCategories=g_TexturePositions.GoodCategories or{}
g_TexturePositions.GoodCategories[GoodCategories.GC_Ammunition]={10,6}
g_TexturePositions.GoodCategories[GoodCategories.GC_Animal]={4,16}
g_TexturePositions.GoodCategories[GoodCategories.GC_Clothes]={1,2}
g_TexturePositions.GoodCategories[GoodCategories.GC_Document]={5,6}
g_TexturePositions.GoodCategories[GoodCategories.GC_Entertainment]={1,4}
g_TexturePositions.GoodCategories[GoodCategories.GC_Food]={1,1}
g_TexturePositions.GoodCategories[GoodCategories.GC_Gold]={1,8}
g_TexturePositions.GoodCategories[GoodCategories.GC_Hygiene]={16,1}
g_TexturePositions.GoodCategories[GoodCategories.GC_Luxury]={16,3}
g_TexturePositions.GoodCategories[GoodCategories.GC_Medicine]={2,10}
g_TexturePositions.GoodCategories[GoodCategories.GC_None]={15,16}
g_TexturePositions.GoodCategories[GoodCategories.GC_RawFood]={3,4}
g_TexturePositions.GoodCategories[GoodCategories.GC_RawMedicine]={2,2}
g_TexturePositions.GoodCategories[GoodCategories.GC_Research]={5,6}
g_TexturePositions.GoodCategories[GoodCategories.GC_Resource]={3,4}
g_TexturePositions.GoodCategories[GoodCategories.GC_Tools]={4,12}
g_TexturePositions.GoodCategories[GoodCategories.GC_Water]={1,16}
g_TexturePositions.GoodCategories[GoodCategories.GC_Weapon]={8,5}end
function BundleKnightTitleRequirements.Local:OverwriteUpdateRequirements()
GUI_Knight.UpdateRequirements=function()
local VZwV1w=BundleKnightTitleRequirements.Local.Data.RequirementWidgets;local IEdKtSVb=1;local bYNIMy6=GUI.GetPlayerID()
local Dq=Logic.GetKnightTitle(bYNIMy6)local OHKA9l=Dq+1;local uqE=Logic.GetKnightID(bYNIMy6)
local NTOa=Logic.GetEntityType(uqE)
XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitle","{center}"..
GUI_Knight.GetTitleNameByTitleID(NTOa,OHKA9l))
XGUIEng.SetText("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/NextKnightTitleWhite","{center}"..
GUI_Knight.GetTitleNameByTitleID(NTOa,OHKA9l))
if KnightTitleRequirements[OHKA9l].Settlers~=nil then SetIcon(
VZwV1w[IEdKtSVb].."/Icon",{5,16})
local rRV,Fwg71O2,TKH=DoesNeededNumberOfSettlersForKnightTitleExist(bYNIMy6,OHKA9l)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..Fwg71O2 .."/"..TKH)if rRV then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Settlers"
IEdKtSVb=IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].RichBuildings~=nil then
SetIcon(VZwV1w[IEdKtSVb].."/Icon",{8,4})
local EuFyU,ai3L78q,oxs30=DoNeededNumberOfRichBuildingsForKnightTitleExist(bYNIMy6,OHKA9l)if oxs30 ==-1 then
oxs30=Logic.GetNumberOfPlayerEntitiesInCategory(bYNIMy6,EntityCategories.CityBuilding)end
XGUIEng.SetText(
VZwV1w[IEdKtSVb].."/Amount","{center}"..ai3L78q.."/"..oxs30)if EuFyU then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="RichBuildings"IEdKtSVb=
IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].Headquarters~=nil then
SetIcon(VZwV1w[IEdKtSVb].."/Icon",{4,7})
local whe,OZHTkyI,U=DoNeededSpecialBuildingUpgradeForKnightTitleExist(bYNIMy6,OHKA9l,EntityCategories.Headquarters)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..
OZHTkyI+1 .."/"..U+1)if whe then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Headquarters"IEdKtSVb=
IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].Storehouse~=nil then
SetIcon(VZwV1w[IEdKtSVb].."/Icon",{4,6})
local KIArgE,gQSGi,vM5wao42=DoNeededSpecialBuildingUpgradeForKnightTitleExist(bYNIMy6,OHKA9l,EntityCategories.Storehouse)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..
gQSGi+1 .."/"..vM5wao42+1)if KIArgE then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Storehouse"IEdKtSVb=
IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].Cathedrals~=nil then
SetIcon(VZwV1w[IEdKtSVb].."/Icon",{4,5})
local JU,Zkt6jmp,hWNEb9E8=DoNeededSpecialBuildingUpgradeForKnightTitleExist(bYNIMy6,OHKA9l,EntityCategories.Cathedrals)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..Zkt6jmp+1 ..
"/"..hWNEb9E8+1)if JU then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Cathedrals"IEdKtSVb=
IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].FullDecoratedBuildings~=nil then
local A3O8n,tCrogd,o=DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist(bYNIMy6,OHKA9l)
local MyM=KnightTitleRequirements[OHKA9l].FullDecoratedBuildings
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Needs[Needs.Wealth])
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..tCrogd.."/"..o)if A3O8n then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
QSB.RequirementTooltipTypes[IEdKtSVb]="FullDecoratedBuildings"IEdKtSVb=IEdKtSVb+1 end
if
KnightTitleRequirements[OHKA9l].Reputation~=nil then
SetIcon(VZwV1w[IEdKtSVb].."/Icon",{5,14})
local x9j,J0Vv9NxA,nZ6q3=DoesNeededCityReputationForKnightTitleExist(bYNIMy6,OHKA9l)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..J0Vv9NxA.."/"..nZ6q3)if x9j then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Reputation"IEdKtSVb=
IEdKtSVb+1 end
if KnightTitleRequirements[OHKA9l].Goods~=nil then
for yCPMWnq=1,#
KnightTitleRequirements[OHKA9l].Goods do
local q=KnightTitleRequirements[OHKA9l].Goods[yCPMWnq][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Goods[q])
local v7H3oo3o,cuLNsH,_Aq3vAF5=DoesNeededNumberOfGoodTypesForKnightTitleExist(bYNIMy6,OHKA9l,yCPMWnq)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..cuLNsH.."/".._Aq3vAF5)if v7H3oo3o then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
QSB.RequirementTooltipTypes[IEdKtSVb]="Goods"..yCPMWnq;IEdKtSVb=IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Category~=nil then
for tz=1,#
KnightTitleRequirements[OHKA9l].Category do
local mb4gzO=KnightTitleRequirements[OHKA9l].Category[tz][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.EntityCategories[mb4gzO])
local wsM,sRC3w,Ww=DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(bYNIMy6,OHKA9l,tz)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..sRC3w.."/"..Ww)if wsM then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
local W15={Logic.GetEntityTypesInCategory(mb4gzO)}
if
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.GC_Weapon_Supplier)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Weapons"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.SiegeEngine)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"HeavyWeapons"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.Spouse)==1 then
QSB.RequirementTooltipTypes[IEdKtSVb]="Spouse"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.Worker)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]="Worker"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.Soldier)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Soldiers"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.Outpost)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Outposts"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.CattlePasture)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Cattle"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.SheepPasture)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Sheep"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.CityBuilding)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"CityBuilding"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.OuterRimBuilding)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"OuterRimBuilding"..tz elseif
Logic.IsEntityTypeInCategory(W15[1],EntityCategories.AttackableBuilding)==1 then QSB.RequirementTooltipTypes[IEdKtSVb]=
"Buildings"..tz else QSB.RequirementTooltipTypes[IEdKtSVb]=
"EntityCategoryDefault"..tz end;IEdKtSVb=IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Entities~=nil then
for T=1,#
KnightTitleRequirements[OHKA9l].Entities do
local U=KnightTitleRequirements[OHKA9l].Entities[T][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Entities[U])
local tzp,YexFk,GKdZ=DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(bYNIMy6,OHKA9l,T)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..YexFk.."/"..GKdZ)if tzp then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Entities"..T;IEdKtSVb=
IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Consume~=nil then
for zgxPd3=1,#
KnightTitleRequirements[OHKA9l].Consume do
local tSqhJw=KnightTitleRequirements[OHKA9l].Consume[zgxPd3][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Goods[tSqhJw])
local hWI,_FyE8,kGD55u=DoNeededNumberOfConsumedGoodsForKnightTitleExist(bYNIMy6,OHKA9l,zgxPd3)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}".._FyE8 .."/"..kGD55u)if hWI then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
QSB.RequirementTooltipTypes[IEdKtSVb]="Consume"..zgxPd3;IEdKtSVb=IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Products~=nil then
for gAub_N=1,#
KnightTitleRequirements[OHKA9l].Products do
local ZlbS1=KnightTitleRequirements[OHKA9l].Products[gAub_N][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.GoodCategories[ZlbS1])
local DUHEU_Jk,xZ,qyMV=DoNumberOfProductsInCategoryExist(bYNIMy6,OHKA9l,gAub_N)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..xZ.."/"..qyMV)if DUHEU_Jk then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
QSB.RequirementTooltipTypes[IEdKtSVb]="Products"..gAub_N;IEdKtSVb=IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Buff~=nil then
for Q0=1,#
KnightTitleRequirements[OHKA9l].Buff do
local PvWYOp=KnightTitleRequirements[OHKA9l].Buff[Q0]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Buffs[PvWYOp])
local pcyPdjNz=DoNeededDiversityBuffForKnightTitleExist(bYNIMy6,OHKA9l,Q0)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","")if pcyPdjNz then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]="Buff"..Q0;IEdKtSVb=
IEdKtSVb+1 end end
if KnightTitleRequirements[OHKA9l].Custom~=nil then
for k9=1,#
KnightTitleRequirements[OHKA9l].Custom do
local J=KnightTitleRequirements[OHKA9l].Custom[k9][2]
BundleKnightTitleRequirements.Local:RequirementIcon(VZwV1w[IEdKtSVb]..
"/Icon",J)
local AkgIQ,QD,Q4v=DoCustomFunctionForKnightTitleSucceed(bYNIMy6,OHKA9l,k9)if QD and Q4v then
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..QD.."/"..Q4v)else
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","")end
if AkgIQ then XGUIEng.ShowWidget(
VZwV1w[IEdKtSVb].."/Done",1)else XGUIEng.ShowWidget(
VZwV1w[IEdKtSVb].."/Done",0)end;XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)QSB.RequirementTooltipTypes[IEdKtSVb]=
"Custom"..k9;IEdKtSVb=IEdKtSVb+1 end end
if
KnightTitleRequirements[OHKA9l].DecoratedBuildings~=nil then
for K44gmgP8=1,#KnightTitleRequirements[OHKA9l].DecoratedBuildings
do
local JVWtlQb=KnightTitleRequirements[OHKA9l].DecoratedBuildings[K44gmgP8][1]
SetIcon(VZwV1w[IEdKtSVb].."/Icon",g_TexturePositions.Goods[JVWtlQb])
local lN,GuL1gt1,nhKV=DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(bYNIMy6,OHKA9l,K44gmgP8)
XGUIEng.SetText(VZwV1w[IEdKtSVb].."/Amount","{center}"..GuL1gt1 .."/"..nhKV)if lN then
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",1)else
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb].."/Done",0)end
XGUIEng.ShowWidget(VZwV1w[IEdKtSVb],1)
QSB.RequirementTooltipTypes[IEdKtSVb]="DecoratedBuildings"..K44gmgP8;IEdKtSVb=IEdKtSVb+1 end end
for wQ=IEdKtSVb,6 do XGUIEng.ShowWidget(VZwV1w[wQ],0)end end end
function BundleKnightTitleRequirements.Local:OverwritePromotionCelebration()
StartKnightsPromotionCelebration=function(LPZI6dP,CPD,bkF)if

LPZI6dP~=GUI.GetPlayerID()or Logic.GetTime()<5 then return end
local P=Logic.GetMarketplace(LPZI6dP)
if bkF==1 then local h4sBu8xR=Logic.GetKnightID(LPZI6dP)local UN64aE
repeat UN64aE=1+
XGUIEng.GetRandom(3)until UN64aE~=g_LastGotPromotionMessageRandom;g_LastGotPromotionMessageRandom=UN64aE
local sSG="Title_GotPromotion"..UN64aE
LocalScriptCallback_QueueVoiceMessage(LPZI6dP,sSG,false,LPZI6dP)GUI.StartFestival(LPZI6dP,1)end;local q=QSB.ConsumedGoodsCounter[LPZI6dP]QSB.ConsumedGoodsCounter[LPZI6dP]=
q or{}
for uqo,p in
pairs(QSB.ConsumedGoodsCounter[LPZI6dP])do QSB.ConsumedGoodsCounter[LPZI6dP][uqo]=0 end
GUI.SendScriptCommand([[
            local Consume = QSB.ConsumedGoodsCounter[]]..
LPZI6dP..
[[];
            QSB.ConsumedGoodsCounter[]]..
LPZI6dP..

[[] = Consume or {};
            for k,v in pairs(QSB.ConsumedGoodsCounter[]]..LPZI6dP..
[[]) do
                QSB.ConsumedGoodsCounter[]]..LPZI6dP..[[][k] = 0;
            end
        ]])
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopCenter/KnightTitleMenuBig",0)g_WantsPromotionMessageInterval=30;g_TimeOfPromotionPossible=nil end end
function BundleKnightTitleRequirements.Local:OverwriteTooltips()
GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements=GUI_Tooltip.SetNameAndDescription
GUI_Tooltip.SetNameAndDescription=function(gIK41Kb,eZyNVj,UoWel1_,g,B)local qcuvjhEy=XGUIEng.GetCurrentWidgetID()
local MLW=GUI.GetSelectedEntity()local nuC7O=GUI.GetPlayerID()
for MdyAJV,_ in
pairs(BundleKnightTitleRequirements.Local.Data.RequirementWidgets)do
if _.."/Icon"==XGUIEng.GetWidgetPathByID(qcuvjhEy)then
local BI7w=QSB.RequirementTooltipTypes[MdyAJV]
local xDtU=tonumber(string.sub(BI7w,string.len(BI7w)))if xDtU~=nil then
BI7w=string.sub(BI7w,1,string.len(BI7w)-1)end
BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(BI7w,xDtU)return end end
GUI_Tooltip.SetNameAndDescription_Orig_QSB_Requirements(gIK41Kb,eZyNVj,UoWel1_,g,B)end
GUI_Knight.RequiredGoodTooltip=function()local DloKju2I=QSB.RequirementTooltipTypes[2]
local zJCi6_s=tonumber(string.sub(DloKju2I,string.len(DloKju2I)))if zJCi6_s~=nil then
DloKju2I=string.sub(DloKju2I,1,string.len(DloKju2I)-1)end
BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(DloKju2I,zJCi6_s)end
if Framework.GetGameExtraNo()~=0 then
BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_Gems]={de="Edelsteine beschaffen",en="Obtain gems"}
BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_Olibanum]={de="Weihrauch beschaffen",en="Obtain olibanum"}
BundleKnightTitleRequirements.Local.Data.BuffTypeNames[Buffs.Buff_MusicalInstrument]={de="Muskinstrumente beschaffen",en="Obtain instruments"}end end
function BundleKnightTitleRequirements.Local:RequirementIcon(Pd,AUXpi)
if
type(AUXpi)=="table"then
if type(AUXpi[3])=="string"then local A=1
if XGUIEng.IsButton(Pd)==1 then A=7 end;local jI8dau,nWm,BhsFPhR1,su;jI8dau=(AUXpi[1]-1)*64;BhsFPhR1=
(AUXpi[2]-1)*64;nWm=(AUXpi[1])*64
su=(AUXpi[2])*64;XGUIEng.SetMaterialAlpha(Pd,A,255)XGUIEng.SetMaterialTexture(Pd,A,
AUXpi[3].."big.png")
XGUIEng.SetMaterialUV(Pd,A,jI8dau,BhsFPhR1,nWm,su)else SetIcon(Pd,AUXpi)end else local WjCwOor={GUI.GetScreenSize()}local xl=330;if WjCwOor[2]>=800 then
xl=260 end;if WjCwOor[2]>=1000 then xl=210 end
XGUIEng.SetMaterialAlpha(Pd,1,255)XGUIEng.SetMaterialTexture(Pd,1,_file)
XGUIEng.SetMaterialUV(Pd,1,0,0,xl,xl)end end
function BundleKnightTitleRequirements.Local:RequirementTooltip(aLV1jBfR,Fct)
local NoLD="/InGame/Root/Normal/TooltipNormal"local fFfqpYo=XGUIEng.GetWidgetID(NoLD)
local YqXOJ=XGUIEng.GetWidgetID(NoLD.."/FadeIn/Name")
local DjTE=XGUIEng.GetWidgetID(NoLD.."/FadeIn/Text")
local _YHW_x=XGUIEng.GetWidgetID(NoLD.."/FadeIn/BG")local MK=XGUIEng.GetWidgetID(NoLD.."/FadeIn")
local fRlh=XGUIEng.GetCurrentWidgetID()GUI_Tooltip.ResizeBG(_YHW_x,DjTE)local jSmoKB9j={_YHW_x}
GUI_Tooltip.SetPosition(fFfqpYo,jSmoKB9j,fRlh)GUI_Tooltip.FadeInTooltip(MK)
XGUIEng.SetText(YqXOJ,"{center}"..aLV1jBfR)XGUIEng.SetText(DjTE,Fct)
local q_=XGUIEng.GetTextHeight(DjTE,true)local b50_fTY,lmAOU7iA=XGUIEng.GetWidgetSize(DjTE)
XGUIEng.SetWidgetSize(DjTE,b50_fTY,q_)end
function BundleKnightTitleRequirements.Local:RequirementTooltipWrapped(w3,wsT)
local u=(
Network.GetDesiredLanguage()=="de"and"de")or"en"local Ep=GUI.GetPlayerID()local G=Logic.GetKnightTitle(Ep)
local q=""local m7hp=""
if
w3 =="Consume"or w3 =="Goods"or w3 =="DecoratedBuildings"then
local Wt1=KnightTitleRequirements[G+1][w3][wsT][1]local M7qPU=Logic.GetGoodTypeName(Wt1)
local b9e=XGUIEng.GetStringTableText("UI_ObjectNames/"..M7qPU)if b9e==nil then b9e="Goods."..M7qPU end;q=b9e
m7hp=BundleKnightTitleRequirements.Local.Data.Description[w3].Text elseif w3 =="Products"then
local oiJzpt=BundleKnightTitleRequirements.Local.Data.GoodCategoryNames
local Hib8uK4=KnightTitleRequirements[G+1][w3][wsT][1]local I6eCb68=oiJzpt[Hib8uK4][u]if I6eCb68 ==nil then
I6eCb68="ERROR: Name missng!"end;q=I6eCb68
m7hp=BundleKnightTitleRequirements.Local.Data.Description[w3].Text elseif w3 =="Entities"then
local jI_=KnightTitleRequirements[G+1][w3][wsT][1]local HmxR=Logic.GetEntityTypeName(jI_)
local MXF=XGUIEng.GetStringTableText("Names/"..HmxR)if MXF==nil then MXF="Entities."..HmxR end;q=MXF
m7hp=BundleKnightTitleRequirements.Local.Data.Description[w3].Text elseif w3 =="Custom"then
local aydCLh1=KnightTitleRequirements[G+1].Custom[wsT]q=aydCLh1[3]m7hp=aydCLh1[4]elseif w3 =="Buff"then
local t0qew=BundleKnightTitleRequirements.Local.Data.BuffTypeNames
local gB=KnightTitleRequirements[G+1][w3][wsT]local ja_b0Jkx=t0qew[gB][u]
if ja_b0Jkx==nil then ja_b0Jkx="ERROR: Name missng!"end;q=ja_b0Jkx
m7hp=BundleKnightTitleRequirements.Local.Data.Description[w3].Text else
q=BundleKnightTitleRequirements.Local.Data.Description[w3].Title
m7hp=BundleKnightTitleRequirements.Local.Data.Description[w3].Text end
q=(type(q)=="table"and q[u])or q
m7hp=(type(m7hp)=="table"and m7hp[u])or m7hp;self:RequirementTooltip(q,m7hp)end
BundleKnightTitleRequirements.Local.Data.RequirementWidgets={[1]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Settlers",[2]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Goods",[3]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/RichBuildings",[4]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Castle",[5]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Storehouse",[6]="/InGame/Root/Normal/AlignBottomRight/KnightTitleMenu/Requirements/Cathedral"}
BundleKnightTitleRequirements.Local.Data.GoodCategoryNames={[GoodCategories.GC_Ammunition]={de="Munition",en="Ammunition"},[GoodCategories.GC_Animal]={de="Nutztiere",en="Livestock"},[GoodCategories.GC_Clothes]={de="Kleidung",en="Clothes"},[GoodCategories.GC_Document]={de="Dokumente",en="Documents"},[GoodCategories.GC_Entertainment]={de="Unterhaltung",en="Entertainment"},[GoodCategories.GC_Food]={de="Nahrungsmittel",en="Food"},[GoodCategories.GC_Gold]={de="Gold",en="Gold"},[GoodCategories.GC_Hygiene]={de="Hygieneartikel",en="Hygiene"},[GoodCategories.GC_Luxury]={de="Dekoration",en="Decoration"},[GoodCategories.GC_Medicine]={de="Medizin",en="Medicine"},[GoodCategories.GC_None]={de="Nichts",en="None"},[GoodCategories.GC_RawFood]={de="Nahrungsmittel",en="Food"},[GoodCategories.GC_RawMedicine]={de="Medizin",en="Medicine"},[GoodCategories.GC_Research]={de="Forschung",en="Research"},[GoodCategories.GC_Resource]={de="Rohstoffe",en="Resource"},[GoodCategories.GC_Tools]={de="Werkzeug",en="Tools"},[GoodCategories.GC_Water]={de="Wasser",en="Water"},[GoodCategories.GC_Weapon]={de="Waffen",en="Weapon"}}
BundleKnightTitleRequirements.Local.Data.BuffTypeNames={[Buffs.Buff_ClothesDiversity]={de="Abwechslungsreiche Kleidung",en="Clothes diversity"},[Buffs.Buff_Colour]={de="Farben beschaffen",en="Obtain color"},[Buffs.Buff_Entertainers]={de="Gaukler anheuern",en="Hire entertainer"},[Buffs.Buff_EntertainmentDiversity]={de="Abwechslungsreiche Unterhaltung",en="Entertainment diversity"},[Buffs.Buff_ExtraPayment]={de="Sonderzahlung",en="Extra payment"},[Buffs.Buff_Festival]={de="Fest veranstalten",en="Hold Festival"},[Buffs.Buff_FoodDiversity]={de="Abwechslungsreiche Nahrung",en="Food diversity"},[Buffs.Buff_HygieneDiversity]={de="Abwechslungsreiche Hygiene",en="Hygiene diversity"},[Buffs.Buff_NoTaxes]={de="Steuerbefreiung",en="No taxes"},[Buffs.Buff_Sermon]={de="Pregigt abhalten",en="Hold sermon"},[Buffs.Buff_Spice]={de="Salz beschaffen",en="Obtain salt"}}
BundleKnightTitleRequirements.Local.Data.Description={Settlers={Title={de="Benötigte Siedler",en="Needed settlers"},Text={de="- Benötigte Menge an Siedlern",en="- Needed number of settlers"}},RichBuildings={Title={de="Reiche Stadtgebäude",en="Rich city buildings"},Text={de="- Menge an reichen Stadtgebäuden",en="- Needed amount of rich city buildings"}},Goods={Title={de="Waren lagern",en="Store Goods"},Text={de="- Benötigte Menge",en="- Needed amount"}},FullDecoratedBuildings={Title={de="Dekorierte Stadtgebäude",en="Decorated City buildings"},Text={de="- Menge an voll dekorierten Gebäuden",en="- Amount of full decoraded city buildings"}},DecoratedBuildings={Title={de="Dekoration",en="Decoration"},Text={de="- Menge an Dekorationsgütern in der Siedlung",en="- Amount of decoration goods in settlement"}},Headquarters={Title={de="Burgstufe",en="Castle level"},Text={de="- Benötigte Ausbauten der Burg",en="- Needed castle upgrades"}},Storehouse={Title={de="Lagerhausstufe",en="Storehouse level"},Text={de="- Benötigte Ausbauten des Lagerhauses",en="- Needed storehouse upgrades"}},Cathedrals={Title={de="Kirchenstufe",en="Cathedral level"},Text={de="- Benötigte Ausbauten der Kirche",en="- Needed cathedral upgrades"}},Reputation={Title={de="Ruf der Stadt",en="City reputation"},Text={de="- Benötigter Ruf der Stadt",en="- Needed city reputation"}},EntityCategoryDefault={Title={de="",en=""},Text={de="- Benötigte Anzahl",en="- Needed amount"}},Cattle={Title={de="Kühe",en="Cattle"},Text={de="- Benötigte Menge an Kühen",en="- Needed amount of cattle"}},Sheep={Title={de="Schafe",en="Sheeps"},Text={de="- Benötigte Menge an Schafen",en="- Needed amount of sheeps"}},Outposts={Title={de="Territorien",en="Territories"},Text={de="- Zu erobernde Territorien",en="- Territories to claim"}},CityBuilding={Title={de="Stadtgebäude",en="City buildings"},Text={de="- Menge benötigter Stadtgebäude",en="- Needed amount of city buildings"}},OuterRimBuilding={Title={de="Rohstoffgebäude",en="Gatherer"},Text={de="- Menge benötigter Rohstoffgebäude",en="- Needed amount of gatherer"}},Consume={Title={de="",en=""},Text={de="- Durch Siedler zu konsumierende Menge",en="- Amount to be consumed by the settlers"}},Products={Title={de="",en=""},Text={de="- Benötigte Menge",en="- Needed amount"}},Buff={Title={de="Bonus aktivieren",en="Activate Buff"},Text={de="- Aktiviere diesen Bonus auf den Ruf der Stadt",en="- Raise the city reputatition with this buff"}},Soldiers={Title={de="Soldaten",en="Soldiers"},Text={de="- Menge an Streitkräften unterhalten",en="- Soldiers you need under your command"}},Worker={Title={de="Arbeiter",en="Workers"},Text={de="- Menge an arbeitender Bevölkerung",en="- Workers you need under your reign"}},Entities={Title={de="",en=""},Text={de="- Benötigte Menge",en="- Needed Amount"}},Buildings={Title={de="Gebäude",en="Buildings"},Text={de="- Gesamtmenge an Gebäuden",en="- Amount of buildings"}},Weapons={Title={de="Waffen",en="Weapons"},Text={de="- Benötigte Menge an Waffen",en="- Needed amount of weapons"}},HeavyWeapons={Title={de="Belagerungsgeräte",en="Siege Engines"},Text={de="- Benötigte Menge an Belagerungsgeräten",en="- Needed amount of siege engine"}},Spouse={Title={de="Ehefrauen",en="Spouses"},Text={de="- Benötigte Anzahl Ehefrauen in der Stadt",en="- Needed amount of spouses in your city"}}}
Core:RegisterBundle("BundleKnightTitleRequirements")
DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist=function(J,QL1wnu,g)if
KnightTitleRequirements[QL1wnu].Category==nil then return end
if g then
local IddjU=KnightTitleRequirements[QL1wnu].Category[g][1]
local U=KnightTitleRequirements[QL1wnu].Category[g][2]local zMl=0
if IddjU==EntityCategories.Spouse then
zMl=Logic.GetNumberOfSpouses(J)else
local JV={Logic.GetPlayerEntitiesInCategory(J,IddjU)}
for Ua10n1=1,#JV do if Logic.IsBuilding(JV[Ua10n1])==1 then if
Logic.IsConstructionComplete(JV[Ua10n1])==1 then zMl=zMl+1 end else
zMl=zMl+1 end end end;if zMl>=U then return true,zMl,U end;return false,zMl,U else local i,k,c_
for _ef=1,#
KnightTitleRequirements[QL1wnu].Category do
i,k,c_=DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(J,QL1wnu,_ef)if i==false then return i,k,c_ end end;return i end end
DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist=function(E,gY,uyD1h)if
KnightTitleRequirements[gY].Entities==nil then return end
if uyD1h then
local ixZdkZre=KnightTitleRequirements[gY].Entities[uyD1h][1]
local bPQeV=KnightTitleRequirements[gY].Entities[uyD1h][2]local axKU=GetPlayerEntities(E,ixZdkZre)local f27=0;for Vt6d=1,#axKU do
if
Logic.IsBuilding(axKU[Vt6d])==1 then if
Logic.IsConstructionComplete(axKU[Vt6d])==1 then f27=f27+1 end else f27=f27+1 end end;if
f27 >=bPQeV then return true,f27,bPQeV end;return false,f27,bPQeV else
local LZZLj,m5wX10r2,Bs4p9QC
for JLzCbfW=1,#KnightTitleRequirements[gY].Entities do
LZZLj,m5wX10r2,Bs4p9QC=DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(E,gY,JLzCbfW)if LZZLj==false then return LZZLj,m5wX10r2,Bs4p9QC end end;return LZZLj end end
DoesNeededNumberOfGoodTypesForKnightTitleExist=function(UC,V7MN2,az_DlK)if
KnightTitleRequirements[V7MN2].Goods==nil then return end
if az_DlK then
local WSk=KnightTitleRequirements[V7MN2].Goods[az_DlK][1]
local F7=KnightTitleRequirements[V7MN2].Goods[az_DlK][2]local r=GetPlayerGoodsInSettlement(WSk,UC,true)if r>=F7 then
return true,r,F7 end;return false,r,F7 else local FNE,bAPx,ys0Rp_
for gf8=1,#
KnightTitleRequirements[V7MN2].Goods do
FNE,bAPx,ys0Rp_=DoesNeededNumberOfGoodTypesForKnightTitleExist(UC,V7MN2,gf8)if FNE==false then return FNE,bAPx,ys0Rp_ end end;return FNE end end
DoNeededNumberOfConsumedGoodsForKnightTitleExist=function(z0OIkNLi,nbG,jSO9C3l)if
KnightTitleRequirements[nbG].Consume==nil then return end
if jSO9C3l then QSB.ConsumedGoodsCounter[z0OIkNLi]=
QSB.ConsumedGoodsCounter[z0OIkNLi]or{}
local _pROM=KnightTitleRequirements[nbG].Consume[jSO9C3l][1]
local sRbL=QSB.ConsumedGoodsCounter[z0OIkNLi][_pROM]or 0
local QwIBmq5=KnightTitleRequirements[nbG].Consume[jSO9C3l][2]
if sRbL>=QwIBmq5 then return true,sRbL,QwIBmq5 else return false,sRbL,QwIBmq5 end else local gsQtuSh,quRuY,iGWMf
for T7=1,#KnightTitleRequirements[nbG].Consume
do
gsQtuSh,quRuY,iGWMf=DoNeededNumberOfConsumedGoodsForKnightTitleExist(z0OIkNLi,nbG,T7)if gsQtuSh==false then return false,quRuY,iGWMf end end;return true,quRuY,iGWMf end end
DoNumberOfProductsInCategoryExist=function(YBFVDgJ8,C93rAu8s,W)if
KnightTitleRequirements[C93rAu8s].Products==nil then return end
if W then local A=0
local oCsS0bB=KnightTitleRequirements[C93rAu8s].Products[W][2]
local bCZUsux8=KnightTitleRequirements[C93rAu8s].Products[W][1]
local M5={Logic.GetGoodTypesInGoodCategory(bCZUsux8)}for N=1,#M5 do
A=A+GetPlayerGoodsInSettlement(M5[N],YBFVDgJ8,true)end;return(A>=oCsS0bB),A,oCsS0bB else
local XiCLp,ZdEKQ,jQym
for nAJt=1,#KnightTitleRequirements[C93rAu8s].Products do
XiCLp,ZdEKQ,jQym=DoNumberOfProductsInCategoryExist(YBFVDgJ8,C93rAu8s,nAJt)if XiCLp==false then return XiCLp,ZdEKQ,jQym end end;return XiCLp end end
DoNeededDiversityBuffForKnightTitleExist=function(zGnJBza,C,Kehy_OA2)if
KnightTitleRequirements[C].Buff==nil then return end
if Kehy_OA2 then
local Ck=KnightTitleRequirements[C].Buff[Kehy_OA2]if
Logic.GetBuff(zGnJBza,Ck)and Logic.GetBuff(zGnJBza,Ck)~=0 then return true end;return false else local xU,lt,z9zD
for AelHP=1,#
KnightTitleRequirements[C].Buff do
xU,lt,z9zD=DoNeededDiversityBuffForKnightTitleExist(zGnJBza,C,AelHP)if xU==false then return xU,lt,z9zD end end;return xU end end
DoCustomFunctionForKnightTitleSucceed=function(mt5,d,CHlyfc)if
KnightTitleRequirements[d].Custom==nil then return end
if CHlyfc then return
KnightTitleRequirements[d].Custom[CHlyfc][1]()else local T8SGU,p,wna1CP
for VZM7n=1,#
KnightTitleRequirements[d].Custom do
T8SGU,p,wna1CP=DoCustomFunctionForKnightTitleSucceed(mt5,d,VZM7n)if T8SGU==false then return T8SGU,p,wna1CP end end;return T8SGU end end
DoNeededNumberOfDecoratedBuildingsForKnightTitleExist=function(J5aNAL,cE9V0Ak,YsjtyXX)if
KnightTitleRequirements[cE9V0Ak].DecoratedBuildings==nil then return end
if YsjtyXX then
local scMn={Logic.GetPlayerEntitiesInCategory(J5aNAL,EntityCategories.CityBuilding)}
local Ike=KnightTitleRequirements[cE9V0Ak].DecoratedBuildings[YsjtyXX][1]
local YAtde=KnightTitleRequirements[cE9V0Ak].DecoratedBuildings[YsjtyXX][2]local ZyC2y=0
for wkVO=1,#scMn do local ShoAeW5=scMn[wkVO]
local xRFquX7=Logic.GetBuildingWealthGoodState(ShoAeW5,Ike)if xRFquX7 >0 then ZyC2y=ZyC2y+1 end end
if ZyC2y>=YAtde then return true,ZyC2y,YAtde else return false,ZyC2y,YAtde end else local lhOAIgu,_E,BNl8FF
for qdi=1,#KnightTitleRequirements[cE9V0Ak].DecoratedBuildings
do
lhOAIgu,_E,BNl8FF=DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(J5aNAL,cE9V0Ak,qdi)if lhOAIgu==false then return lhOAIgu,_E,BNl8FF end end;return lhOAIgu end end
DoNeededSpecialBuildingUpgradeForKnightTitleExist=function(HVCvb,z,j3VsR)local Mlr;local N5F0y
if
j3VsR==EntityCategories.Headquarters then Mlr=Logic.GetHeadquarters(HVCvb)N5F0y="Headquarters"elseif j3VsR==
EntityCategories.Storehouse then Mlr=Logic.GetStoreHouse(HVCvb)
N5F0y="Storehouse"elseif j3VsR==EntityCategories.Cathedrals then
Mlr=Logic.GetCathedral(HVCvb)N5F0y="Cathedrals"else return end
if KnightTitleRequirements[z][N5F0y]==nil then return end;local Oz=KnightTitleRequirements[z][N5F0y]
if Mlr~=nil then
local pNF17=Logic.GetUpgradeLevel(Mlr)
if pNF17 >=Oz then return true,pNF17,Oz else return false,pNF17,Oz end else return false,0,Oz end end
DoesNeededCityReputationForKnightTitleExist=function(ta,Z)if
KnightTitleRequirements[Z].Reputation==nil then return end
local f=KnightTitleRequirements[Z].Reputation;if not f then return end
local ueZx6g=math.floor(
(Logic.GetCityReputation(ta)*100)+0.5)if ueZx6g>=f then return true,ueZx6g,f end;return false,ueZx6g,f end
DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist=function(JU5X,JmtYoAf6)
if
KnightTitleRequirements[JmtYoAf6].FullDecoratedBuildings==nil then return end
local Z37al={Logic.GetPlayerEntitiesInCategory(JU5X,EntityCategories.CityBuilding)}
local JBqNR2s=KnightTitleRequirements[JmtYoAf6].FullDecoratedBuildings;local fCYDw0i=0
for gVH94qh_=1,#Z37al do local da=Z37al[gVH94qh_]local hKRhfrQ=0
if
Logic.GetBuildingWealthGoodState(da,Goods.G_Banner)>0 then hKRhfrQ=hKRhfrQ+1 end;if
Logic.GetBuildingWealthGoodState(da,Goods.G_Sign)>0 then hKRhfrQ=hKRhfrQ+1 end
if
Logic.GetBuildingWealthGoodState(da,Goods.G_Candle)>0 then hKRhfrQ=hKRhfrQ+1 end;if
Logic.GetBuildingWealthGoodState(da,Goods.G_Ornament)>0 then hKRhfrQ=hKRhfrQ+1 end;if hKRhfrQ>=4 then fCYDw0i=
fCYDw0i+1 end end
if fCYDw0i>=JBqNR2s then return true,fCYDw0i,JBqNR2s else return false,fCYDw0i,JBqNR2s end end
CanKnightBePromoted=function(kat,I)
if I==nil then I=Logic.GetKnightTitle(kat)+1 end
if Logic.CanStartFestival(kat,1)==true then
if














KnightTitleRequirements[I]~=
nil and
DoesNeededNumberOfSettlersForKnightTitleExist(kat,I)~=false and
DoNeededNumberOfGoodsForKnightTitleExist(kat,I)~=false and
DoNeededSpecialBuildingUpgradeForKnightTitleExist(kat,I,EntityCategories.Headquarters)~=false and
DoNeededSpecialBuildingUpgradeForKnightTitleExist(kat,I,EntityCategories.Storehouse)~=false and
DoNeededSpecialBuildingUpgradeForKnightTitleExist(kat,I,EntityCategories.Cathedrals)~=false and
DoNeededNumberOfRichBuildingsForKnightTitleExist(kat,I)~=false and
DoNeededNumberOfFullDecoratedBuildingsForKnightTitleExist(kat,I)~=false and
DoNeededNumberOfDecoratedBuildingsForKnightTitleExist(kat,I)~=false and
DoesNeededCityReputationForKnightTitleExist(kat,I)~=false and
DoesNeededNumberOfEntitiesInCategoryForKnightTitleExist(kat,I)~=false and
DoesNeededNumberOfEntitiesOfTypeForKnightTitleExist(kat,I)~=false and
DoesNeededNumberOfGoodTypesForKnightTitleExist(kat,I)~=false and DoNeededDiversityBuffForKnightTitleExist(kat,I)~=false and DoCustomFunctionForKnightTitleSucceed(kat,I)~=false and
DoNeededNumberOfConsumedGoodsForKnightTitleExist(kat,I)~=false and DoNumberOfProductsInCategoryExist(kat,I)~=false then return true end end;return false end
VictroryBecauseOfTitle=function()QuestTemplate:TerminateEventsAndStuff()
Victory(g_VictoryAndDefeatType.VictoryMissionComplete)end
InitKnightTitleTables=function()KnightTitles={}KnightTitles.Knight=0
KnightTitles.Mayor=1;KnightTitles.Baron=2;KnightTitles.Earl=3
KnightTitles.Marquees=4;KnightTitles.Duke=5;KnightTitles.Archduke=6
NeedsAndRightsByKnightTitle={}
NeedsAndRightsByKnightTitle[KnightTitles.Knight]={ActivateNeedForPlayer,{Needs.Nutrition,Needs.Medicine},ActivateRightForPlayer,{Technologies.R_Gathering,Technologies.R_Woodcutter,Technologies.R_StoneQuarry,Technologies.R_HuntersHut,Technologies.R_FishingHut,Technologies.R_CattleFarm,Technologies.R_GrainFarm,Technologies.R_SheepFarm,Technologies.R_IronMine,Technologies.R_Beekeeper,Technologies.R_HerbGatherer,Technologies.R_Nutrition,Technologies.R_Bakery,Technologies.R_Dairy,Technologies.R_Butcher,Technologies.R_SmokeHouse,Technologies.R_Clothes,Technologies.R_Tanner,Technologies.R_Weaver,Technologies.R_Construction,Technologies.R_Wall,Technologies.R_Pallisade,Technologies.R_Trail,Technologies.R_KnockDown,Technologies.R_Sermon,Technologies.R_SpecialEdition,Technologies.R_SpecialEdition_Pavilion}}
NeedsAndRightsByKnightTitle[KnightTitles.Mayor]={ActivateNeedForPlayer,{Needs.Clothes},ActivateRightForPlayer,{Technologies.R_Hygiene,Technologies.R_Soapmaker,Technologies.R_BroomMaker,Technologies.R_Military,Technologies.R_SwordSmith,Technologies.R_Barracks,Technologies.R_Thieves,Technologies.R_SpecialEdition_StatueFamily},StartKnightsPromotionCelebration}
NeedsAndRightsByKnightTitle[KnightTitles.Baron]={ActivateNeedForPlayer,{Needs.Hygiene},ActivateRightForPlayer,{Technologies.R_Medicine,Technologies.R_BowMaker,Technologies.R_BarracksArchers,Technologies.R_Entertainment,Technologies.R_Tavern,Technologies.R_Festival,Technologies.R_Street,Technologies.R_SpecialEdition_Column},StartKnightsPromotionCelebration}
NeedsAndRightsByKnightTitle[KnightTitles.Earl]={ActivateNeedForPlayer,{Needs.Entertainment,Needs.Prosperity},ActivateRightForPlayer,{Technologies.R_SiegeEngineWorkshop,Technologies.R_BatteringRam,Technologies.R_Baths,Technologies.R_AmmunitionCart,Technologies.R_Prosperity,Technologies.R_Taxes,Technologies.R_Ballista,Technologies.R_SpecialEdition_StatueSettler},StartKnightsPromotionCelebration}
NeedsAndRightsByKnightTitle[KnightTitles.Marquees]={ActivateNeedForPlayer,{Needs.Wealth},ActivateRightForPlayer,{Technologies.R_Theater,Technologies.R_Wealth,Technologies.R_BannerMaker,Technologies.R_SiegeTower,Technologies.R_SpecialEdition_StatueProduction},StartKnightsPromotionCelebration}
NeedsAndRightsByKnightTitle[KnightTitles.Duke]={ActivateNeedForPlayer,nil,ActivateRightForPlayer,{Technologies.R_Catapult,Technologies.R_Carpenter,Technologies.R_CandleMaker,Technologies.R_Blacksmith,Technologies.R_SpecialEdition_StatueDario},StartKnightsPromotionCelebration}
NeedsAndRightsByKnightTitle[KnightTitles.Archduke]={ActivateNeedForPlayer,nil,ActivateRightForPlayer,{Technologies.R_Victory},StartKnightsPromotionCelebration}
if g_GameExtraNo>=1 then local ttp=4
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][ttp],Technologies.R_Cistern)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][ttp],Technologies.R_Beautification_Brazier)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Mayor][ttp],Technologies.R_Beautification_Shrine)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Baron][ttp],Technologies.R_Beautification_Pillar)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][ttp],Technologies.R_Beautification_StoneBench)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Earl][ttp],Technologies.R_Beautification_Vase)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Marquees][ttp],Technologies.R_Beautification_Sundial)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Archduke][ttp],Technologies.R_Beautification_TriumphalArch)
table.insert(NeedsAndRightsByKnightTitle[KnightTitles.Duke][ttp],Technologies.R_Beautification_VictoryColumn)end;KnightTitleRequirements={}
KnightTitleRequirements[KnightTitles.Mayor]={}
KnightTitleRequirements[KnightTitles.Mayor].Headquarters=1
KnightTitleRequirements[KnightTitles.Mayor].Settlers=10
KnightTitleRequirements[KnightTitles.Mayor].Products={{GoodCategories.GC_Clothes,6}}KnightTitleRequirements[KnightTitles.Baron]={}
KnightTitleRequirements[KnightTitles.Baron].Settlers=30
KnightTitleRequirements[KnightTitles.Baron].Headquarters=1
KnightTitleRequirements[KnightTitles.Baron].Storehouse=1
KnightTitleRequirements[KnightTitles.Baron].Cathedrals=1
KnightTitleRequirements[KnightTitles.Baron].Products={{GoodCategories.GC_Hygiene,12}}KnightTitleRequirements[KnightTitles.Earl]={}
KnightTitleRequirements[KnightTitles.Earl].Settlers=50
KnightTitleRequirements[KnightTitles.Earl].Headquarters=2
KnightTitleRequirements[KnightTitles.Earl].Products={{GoodCategories.GC_Entertainment,18}}
KnightTitleRequirements[KnightTitles.Marquees]={}
KnightTitleRequirements[KnightTitles.Marquees].Settlers=70
KnightTitleRequirements[KnightTitles.Marquees].Headquarters=2
KnightTitleRequirements[KnightTitles.Marquees].Storehouse=2
KnightTitleRequirements[KnightTitles.Marquees].Cathedrals=2
KnightTitleRequirements[KnightTitles.Marquees].RichBuildings=20;KnightTitleRequirements[KnightTitles.Duke]={}
KnightTitleRequirements[KnightTitles.Duke].Settlers=90
KnightTitleRequirements[KnightTitles.Duke].Storehouse=2
KnightTitleRequirements[KnightTitles.Duke].Cathedrals=2
KnightTitleRequirements[KnightTitles.Duke].Headquarters=3
KnightTitleRequirements[KnightTitles.Duke].DecoratedBuildings={{Goods.G_Banner,9}}
KnightTitleRequirements[KnightTitles.Archduke]={}
KnightTitleRequirements[KnightTitles.Archduke].Settlers=150
KnightTitleRequirements[KnightTitles.Archduke].Storehouse=3
KnightTitleRequirements[KnightTitles.Archduke].Cathedrals=3
KnightTitleRequirements[KnightTitles.Archduke].Headquarters=3
KnightTitleRequirements[KnightTitles.Archduke].RichBuildings=30
KnightTitleRequirements[KnightTitles.Archduke].FullDecoratedBuildings=30;CreateTechnologyKnightTitleTable()end;API=API or{}QSB=QSB or{}QSB.PlayerNames={}
function API.HideMinimap(xw)if not GUI then
Logic.ExecuteInLuaLocalState(
"API.HideMinimap("..tostring(xw)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapOverlay",xw)
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/Minimap/MinimapTerrain",xw)end
function API.HideToggleMinimap(SqI5E)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideToggleMinimap("..tostring(SqI5E)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/MinimapButton",SqI5E)end
function API.HideDiplomacyMenu(bSgeE5)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideDiplomacyMenu("..tostring(bSgeE5)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/DiplomacyMenuButton",bSgeE5)end
function API.HideProductionMenu(wl0dKX)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideProductionMenu("..tostring(wl0dKX)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/ProductionMenuButton",wl0dKX)end
function API.HideWeatherMenu(ZrMXm44)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideWeatherMenu("..tostring(ZrMXm44)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/WeatherMenuButton",ZrMXm44)end
function API.HideBuyTerritory(lX)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideBuyTerritory("..tostring(lX)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory",lX)end
function API.HideKnightAbility(vcWpb8)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideKnightAbility("..tostring(vcWpb8)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbilityProgress",vcWpb8)
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/StartAbility",vcWpb8)end
function API.HideKnightButton(GkzQuHdY)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideKnightButton("..tostring(GkzQuHdY)..")")return end
local DBp=Logic.GetKnightID(GUI.GetPlayerID())
if GkzQuHdY==true then
GUI.SendScriptCommand("Logic.SetEntitySelectableFlag("..DBp..", 0)")GUI.DeselectEntity(DBp)else
GUI.SendScriptCommand("Logic.SetEntitySelectableFlag("..DBp..", 1)")end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButtonProgress",GkzQuHdY)
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton",GkzQuHdY)end
function API.HideSelectionButton(kW)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideSelectionButton("..tostring(kW)..")")return end
API.HideKnightButton(kW)GUI.ClearSelection()
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton",kW)end
function API.HideBuildMenu(U1WV)if not GUI then
Logic.ExecuteInLuaLocalState("API.HideBuildMenu("..tostring(U1WV)..")")return end
BundleInterfaceApperance.Local:HideInterfaceButton("/InGame/Root/Normal/AlignBottomRight/BuildMenu",U1WV)end;function API.SetTexture(es,BweVGqh)if not GUI then return end
BundleInterfaceApperance.Local:SetTexture(es,BweVGqh)end
UserSetTexture=API.SetTexture;function API.SetIcon(A,Li,yjmG0B7I,C)if not GUI then return end
BundleInterfaceApperance.Local:SetIcon(A,Li,yjmG0B7I,C)end
UserSetIcon=API.SetIcon;function API.SetTooltipNormal(tT6,fh,S)if not GUI then return end
BundleInterfaceApperance.Local:TextNormal(tT6,fh,S)end
UserSetTextNormal=API.SetTooltipNormal
function API.SetTooltipCosts(RBKUQt,Yag,bJcmH,IVom7n4,xOynA)if not GUI then return end
BundleInterfaceApperance.Local:TextCosts(RBKUQt,Yag,bJcmH,IVom7n4,xOynA)end;UserSetTextBuy=API.SetTooltipCosts
function API.GetTerritoryName(ro1k)
local ea4=Logic.GetTerritoryName(ro1k)local W_h=Framework.GetCurrentMapTypeAndCampaignName()if
W_h==1 or W_h==3 then return ea4 end
local yw1zD=Framework.GetCurrentMapName()local SWP="Map_"..yw1zD;local REfRorFU=string.gsub(ea4," ","")
REfRorFU=XGUIEng.GetStringTableText(
SWP.."/Territory_"..REfRorFU)if REfRorFU==""then REfRorFU=ea4 .."(key?)"end;return REfRorFU end;GetTerritoryName=API.GetTerritoryName
function API.GetPlayerName(n8oLLJS)
local KW7Dj=Logic.GetPlayerName(n8oLLJS)local X=QSB.PlayerNames[n8oLLJS]
if X~=nil and X~=""then KW7Dj=X end
local KJjjq=Framework.GetCurrentMapTypeAndCampaignName()
local leCk0=Framework.GetMultiplayerMapMode(Framework.GetCurrentMapName(),KJjjq)if leCk0 >0 then return KW7Dj end
if KJjjq==1 or KJjjq==3 then
local dUvpRX2,LEfAT,udQ=Framework.GetPlayerInfo(n8oLLJS)if KW7Dj~=""then return KW7Dj end;return dUvpRX2 end end;GetPlayerName_OrigName=GetPlayerName;GetPlayerName=API.GetPlayerName
function API.SetPlayerName(V,yhFYZc)assert(
type(V)=="number")
assert(type(yhFYZc)=="string")
if not GUI then
Logic.ExecuteInLuaLocalState("SetPlayerName("..V..",'"..yhFYZc.."')")else GUI_MissionStatistic.PlayerNames[V]=yhFYZc
GUI.SendScriptCommand(
"QSB.PlayerNames["..V.."] = '"..yhFYZc.."'")end;QSB.PlayerNames[V]=yhFYZc end;SetPlayerName=API.SetPlayerName
function API.SetPlayerColor(eCorPg,DaopEI,uLdXdV,K)if GUI then return end
local Zv0O2Z3M=type(DaopEI)local m8=
(type(DaopEI)=="string"and g_ColorIndex[DaopEI])or DaopEI
local BkdY=uLdXdV or-1;local Hf=K or-1;g_ColorIndex["ExtraColor1"]=16
g_ColorIndex["ExtraColor2"]=17
StartSimpleJobEx(function(m8,eCorPg,uLdXdV,K)
Logic.PlayerSetPlayerColor(eCorPg,m8,uLdXdV,K)return true end,m8,eCorPg,BkdY,Hf)end
BundleInterfaceApperance={Global={},Local={Data={HiddenWidgets={}}}}function BundleInterfaceApperance.Global:Install()
API.AddSaveGameAction(BundleInterfaceApperance.Global.RestoreAfterLoad)end
function BundleInterfaceApperance.Global.RestoreAfterLoad()
Logic.ExecuteInLuaLocalState([[
        BundleInterfaceApperance.Local:RestoreAfterLoad();
    ]])end
function BundleInterfaceApperance.Local:Install()
StartMissionGoodOrEntityCounter=function(LJR,oBXZsMdj)
if
type(LJR)=="string"then
BundleInterfaceApperance.Local:SetTexture("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon",LJR)else
if type(LJR[3])=="string"then
BundleInterfaceApperance.Local:SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon",LJR,64,LJR[3])else
SetIcon("/InGame/Root/Normal/MissionGoodOrEntityCounter/Icon",LJR)end end;g_MissionGoodOrEntityCounterAmountToReach=oBXZsMdj
g_MissionGoodOrEntityCounterIcon=LJR
XGUIEng.ShowWidget("/InGame/Root/Normal/MissionGoodOrEntityCounter",1)end
GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceApperance=GUI_Knight.ClaimTerritoryUpdate
GUI_Knight.ClaimTerritoryUpdate=function()
local PcE0ge="/InGame/Root/Normal/AlignBottomRight/DialogButtons/Knight/ClaimTerritory"if
BundleInterfaceApperance.Local.Data.HiddenWidgets[PcE0ge]==true then
BundleInterfaceApperance.Local:HideInterfaceButton(PcE0ge,true)end
GUI_Knight.ClaimTerritoryUpdate_Orig_QSB_InterfaceApperance()end end
function BundleInterfaceApperance.Local:HideInterfaceButton(nMNJQTC,JQg)self.Data.HiddenWidgets[nMNJQTC]=
JQg==true
XGUIEng.ShowWidget(nMNJQTC,(JQg==true and 0)or 1)end
function BundleInterfaceApperance.Local:RestoreAfterLoad()
for oaL,S in
pairs(self.Data.HiddenWidgets)do if S then XGUIEng.ShowWidget(oaL,0)end end end
function BundleInterfaceApperance.Local:SetTexture(uvWDB,SOH2vam)
assert((type(uvWDB)=="string"or
type(uvWDB)=="number"))local o=
(type(uvWDB)=="string"and XGUIEng.GetWidgetID(uvWDB))or uvWDB
local SUKHqlHR={GUI.GetScreenSize()}local Scux_=1;if XGUIEng.IsButton(o)==1 then Scux_=7 end
local IkA=330;if SUKHqlHR[2]>=800 then IkA=260 end
if SUKHqlHR[2]>=1000 then IkA=210 end;XGUIEng.SetMaterialAlpha(o,Scux_,255)
XGUIEng.SetMaterialTexture(o,Scux_,SOH2vam)XGUIEng.SetMaterialUV(o,Scux_,0,0,IkA,IkA)end
function BundleInterfaceApperance.Local:SetIcon(NNCUhD3C,WwHwo,w8U7WX,N1Fj0rD)if N1Fj0rD==nil then
N1Fj0rD="usericons"end;if w8U7WX==nil then w8U7WX=64 end;if w8U7WX==44 then N1Fj0rD=N1Fj0rD..
".png"end;if w8U7WX==64 then
N1Fj0rD=N1Fj0rD.."big.png"end
if w8U7WX==128 then N1Fj0rD=N1Fj0rD.."verybig.png"end;local OSoKKStA,wa8xP,w_t,ZysHLoe;OSoKKStA=(WwHwo[1]-1)*w8U7WX;w_t=
(WwHwo[2]-1)*w8U7WX;wa8xP=(WwHwo[1])*w8U7WX;ZysHLoe=
(WwHwo[2])*w8U7WX;State=1;if XGUIEng.IsButton(NNCUhD3C)==1 then
State=7 end
XGUIEng.SetMaterialAlpha(NNCUhD3C,State,255)
XGUIEng.SetMaterialTexture(NNCUhD3C,State,N1Fj0rD)
XGUIEng.SetMaterialUV(NNCUhD3C,State,OSoKKStA,w_t,wa8xP,ZysHLoe)end
function BundleInterfaceApperance.Local:TextNormal(v6Ia2,HPl,Bc8Ie)
local vkqOw5y=Network.GetDesiredLanguage()if vkqOw5y~="de"then vkqOw5y="en"end;if type(v6Ia2)=="table"then
v6Ia2=v6Ia2[vkqOw5y]end
if type(HPl)=="table"then HPl=HPl[vkqOw5y]end;HPl=HPl or""
if type(Bc8Ie)=="table"then Bc8Ie=Bc8Ie[vkqOw5y]end;local SDra="/InGame/Root/Normal/TooltipNormal"
local hjL1zQaW=XGUIEng.GetWidgetID(SDra)
local FkstCfj=XGUIEng.GetWidgetID(SDra.."/FadeIn/Name")
local frN0k=XGUIEng.GetWidgetID(SDra.."/FadeIn/Text")
local sUEZLuWE=XGUIEng.GetWidgetID(SDra.."/FadeIn/BG")local VCKVC0=XGUIEng.GetWidgetID(SDra.."/FadeIn")
local X19LX=XGUIEng.GetCurrentWidgetID()GUI_Tooltip.ResizeBG(sUEZLuWE,frN0k)
local J7UyMyyQ={sUEZLuWE}
GUI_Tooltip.SetPosition(hjL1zQaW,J7UyMyyQ,X19LX)GUI_Tooltip.FadeInTooltip(VCKVC0)Bc8Ie=Bc8Ie or""
local KIBa=""if
XGUIEng.IsButtonDisabled(X19LX)==1 and Bc8Ie~=""and HPl~=""then
KIBa=KIBa.."{cr}{@color:255,32,32,255}"..Bc8Ie end;XGUIEng.SetText(FkstCfj,
"{center}"..v6Ia2)
XGUIEng.SetText(frN0k,HPl..KIBa)local CzeZVbkz=XGUIEng.GetTextHeight(frN0k,true)
local UUawT,QN7ateI=XGUIEng.GetWidgetSize(frN0k)XGUIEng.SetWidgetSize(frN0k,UUawT,CzeZVbkz)end
function BundleInterfaceApperance.Local:TextCosts(_IZCHdRg,rU3P3r2,Q,mtEzJq,p5IT4RDF)
local C4eY=Network.GetDesiredLanguage()if C4eY~="de"then C4eY="en"end;mtEzJq=mtEzJq or{}if
type(_IZCHdRg)=="table"then _IZCHdRg=_IZCHdRg[C4eY]end;if
type(rU3P3r2)=="table"then rU3P3r2=rU3P3r2[C4eY]end
rU3P3r2=rU3P3r2 or""if type(Q)=="table"then Q=Q[C4eY]end
local BS="/InGame/Root/Normal/TooltipBuy"local KTbH=XGUIEng.GetWidgetID(BS)
local TFnCJik=XGUIEng.GetWidgetID(BS.."/FadeIn/Name")local po=XGUIEng.GetWidgetID(BS.."/FadeIn/Text")local yhy=XGUIEng.GetWidgetID(
BS.."/FadeIn/BG")local XabKkHV=XGUIEng.GetWidgetID(BS..
"/FadeIn")
local EoB2=XGUIEng.GetWidgetID(BS.."/Costs")local iI=XGUIEng.GetCurrentWidgetID()
GUI_Tooltip.ResizeBG(yhy,po)GUI_Tooltip.SetCosts(EoB2,mtEzJq,p5IT4RDF)
local k={KTbH,EoB2,yhy}GUI_Tooltip.SetPosition(KTbH,k,iI,nil,true)
GUI_Tooltip.OrderTooltip(k,XabKkHV,EoB2,iI,yhy)GUI_Tooltip.FadeInTooltip(XabKkHV)Q=Q or""local KCkR6=""if

XGUIEng.IsButtonDisabled(iI)==1 and Q~=""and rU3P3r2 ~=""then
KCkR6=KCkR6 .."{cr}{@color:255,32,32,255}"..Q end;XGUIEng.SetText(TFnCJik,
"{center}".._IZCHdRg)XGUIEng.SetText(po,
rU3P3r2 ..KCkR6)
local Gt2=XGUIEng.GetTextHeight(po,true)local t,Z7TxGd9l=XGUIEng.GetWidgetSize(po)
XGUIEng.SetWidgetSize(po,t,Gt2)end;Core:RegisterBundle("BundleInterfaceApperance")API=API or
{}QSB=QSB or{}QSB.TravelingSalesman={Harbors={}}
QSB.TraderTypes={GoodTrader=1,MercenaryTrader=2,EntertainerTrader=3,Unknown=4}
function API.GetOfferInformation(jOYC)if GUI then
API.Log("Can not execute API.GetOfferInformation in local script!")return end;return
BundleTradingFunctions.Global:GetOfferInformation(jOYC)end
function API.GetOfferCount(ger)if GUI then
API.Log("Can not execute API.GetOfferCount in local script!")return end;return
BundleTradingFunctions.Global:GetOfferCount(ger)end
function API.GetOfferAndTrader(G0jBEog,H)if GUI then
API.Log("Can not execute API.GetOfferAndTrader in local script!")return end;return
BundleTradingFunctions.Global:GetOfferAndTrader(G0jBEog,H)end
function API.GetTraderType(wP2mU7o,Ki5XQ)if GUI then
API.Log("Can not execute API.GetTraderType in local script!")return end;return
BundleTradingFunctions.Global:GetTraderType(wP2mU7o,Ki5XQ)end
function API.GetTrader(ECnd,f7l)if GUI then
API.Log("Can not execute API.GetTrader in local script!")return end;return
BundleTradingFunctions.Global:GetTrader(ECnd,f7l)end
function API.RemoveOfferByIndex(G8ZUj,uI,M0L)if GUI then
API.Bridge("API.RemoveOfferByIndex("..G8ZUj..
", "..uI..", "..M0L..")")return end;return
BundleTradingFunctions.Global:RemoveOfferByIndex(G8ZUj,uI,M0L)end
function API.RemoveOffer(X1zoNh2N,pzt)if GUI then
API.Bridge("API.RemoveOffer("..X1zoNh2N..", "..pzt..")")return end;return
BundleTradingFunctions.Global:RemoveOffer(X1zoNh2N,pzt)end
function API.ModifyTraderOffer(nv5UE,N,Ld8ab,BbxNzlIJ)if GUI then
API.Bridge("API.ModifyTraderOffer("..
nv5UE..", "..N..", "..
Ld8ab..", "..BbxNzlIJ..")")return end;return
BundleTradingFunctions.Global:ModifyTraderOffer(nv5UE,N,Ld8ab,BbxNzlIJ)end
function API.ActivateTravelingSalesman(mIVqMY,vjd,GaxvRZ,B,Qe)if GUI then
API.Log("Can not execute API.ActivateTravelingSalesman in local script!")return end;return
BundleTradingFunctions.Global:TravelingSalesman_Create(mIVqMY,vjd,Qe,GaxvRZ,B)end
function API.DisbandTravelingSalesman(Q)if GUI then
API.Bridge("API.DisbandTravelingSalesman("..Q..")")return end;return
BundleTradingFunctions.Global:TravelingSalesman_Disband(Q)end;BundleTradingFunctions={Global={Data={}},Local={Data={}}}
function BundleTradingFunctions.Global:Install()
self.OverwriteOfferFunctions()self.OverwriteBasePricesAndRefreshRates()
TravelingSalesman_Control=BundleTradingFunctions.Global.TravelingSalesman_Control end
function BundleTradingFunctions.Global:OverwriteOfferFunctions()
AddOffer=function(Azvu,mJUIsy,A2mKO,w3LESxRS,mS9ak)
local kUsG=GetID(Azvu)
if type(A2mKO)=="string"then A2mKO=Goods[A2mKO]else A2mKO=A2mKO end;local ZCRLifP=Logic.EntityGetPlayer(kUsG)
AddGoodToTradeBlackList(ZCRLifP,A2mKO)local LL35AS8C=Entities.U_Marketer;if A2mKO==Goods.G_Medicine then
LL35AS8C=Entities.U_Medicus end
if w3LESxRS==nil then
w3LESxRS=MerchantSystem.RefreshRates[A2mKO]if w3LESxRS==nil then w3LESxRS=0 end end;if mS9ak==nil then mS9ak=1 end;local v=9;return
Logic.AddGoodTraderOffer(kUsG,mJUIsy,Goods.G_Gold,0,A2mKO,v,mS9ak,w3LESxRS,LL35AS8C,Entities.U_ResourceMerchant)end
AddMercenaryOffer=function(euz2FZps,C5,f,FZbyrOw,g)local LDLLUZm0=GetID(euz2FZps)if f==nil then
f=Entities.U_MilitaryBandit_Melee_ME end
if FZbyrOw==nil then
FZbyrOw=MerchantSystem.RefreshRates[f]if FZbyrOw==nil then FZbyrOw=0 end end;local s1E1q=3;local jfg=Logic.GetEntityTypeName(f)if
string.find(jfg,"MilitaryBow")or string.find(jfg,"MilitarySword")then s1E1q=6 elseif
string.find(jfg,"Cart")then s1E1q=0 end;if g==nil then
g=1 end;return
Logic.AddMercenaryTraderOffer(LDLLUZm0,C5,Goods.G_Gold,3,f,s1E1q,g,FZbyrOw)end
AddEntertainerOffer=function(E43QsB,MnH_PDE,BPcZ)local I10ha=GetID(E43QsB)local C9R=1;if MnH_PDE==nil then
MnH_PDE=Entities.U_Entertainer_NA_FireEater end;if BPcZ==nil then BPcZ=1 end;return
Logic.AddEntertainerTraderOffer(I10ha,C9R,Goods.G_Gold,0,MnH_PDE,BPcZ,0)end end
function BundleTradingFunctions.Global:OverwriteBasePricesAndRefreshRates()
MerchantSystem.BasePrices[Entities.U_CatapultCart]=
MerchantSystem.BasePrices[Entities.U_CatapultCart]or 1000
MerchantSystem.BasePrices[Entities.U_BatteringRamCart]=
MerchantSystem.BasePrices[Entities.U_BatteringRamCart]or 450
MerchantSystem.BasePrices[Entities.U_SiegeTowerCart]=
MerchantSystem.BasePrices[Entities.U_SiegeTowerCart]or 600
MerchantSystem.BasePrices[Entities.U_AmmunitionCart]=
MerchantSystem.BasePrices[Entities.U_AmmunitionCart]or 180
MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince]=
MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince]or 150
MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana]=
MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana]or 150
MerchantSystem.BasePrices[Entities.U_MilitarySword]=
MerchantSystem.BasePrices[Entities.U_MilitarySword]or 150
MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince]=
MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince]or 220
MerchantSystem.BasePrices[Entities.U_MilitaryBow]=
MerchantSystem.BasePrices[Entities.U_MilitaryBow]or 220
MerchantSystem.RefreshRates[Entities.U_CatapultCart]=
MerchantSystem.RefreshRates[Entities.U_CatapultCart]or 270
MerchantSystem.RefreshRates[Entities.U_BatteringRamCart]=
MerchantSystem.RefreshRates[Entities.U_BatteringRamCart]or 190
MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart]=
MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart]or 220
MerchantSystem.RefreshRates[Entities.U_AmmunitionCart]=
MerchantSystem.RefreshRates[Entities.U_AmmunitionCart]or 150
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince]=
MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince]or 150
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana]=
MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana]or 150
MerchantSystem.RefreshRates[Entities.U_MilitarySword]=
MerchantSystem.RefreshRates[Entities.U_MilitarySword]or 150
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince]=
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince]or 150
MerchantSystem.RefreshRates[Entities.U_MilitaryBow]=
MerchantSystem.RefreshRates[Entities.U_MilitaryBow]or 150
if g_GameExtraNo>=1 then
MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana]=
MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana]or 220
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana]=
MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana]or 150 end end
function BundleTradingFunctions.Global:GetOfferInformation(Q)
local h3ckJGMR=Logic.GetStoreHouse(Q)if not IsExisting(h3ckJGMR)then return end
local MD={Player=Q,Storehouse=h3ckJGMR,OfferCount=0}local pgP=0;local Vrp0=Logic.GetNumberOfMerchants(h3ckJGMR)
for JjW89=0,Vrp0-1,1 do
local _={}
local _g3urPc3D={Logic.GetMerchantOfferIDs(h3ckJGMR,JjW89,Q)}
for SM=1,#_g3urPc3D do pgP=pgP+1;local cRR1,Bqw19,E6W1701,kxGV49HY
local AyUn=Module_TradingTools.Global.GetTraderType(JjW89)
if AyUn==QSB.TraderTypes.GoodTrader then
cRR1,Bqw19,E6W1701,kxGV49HY=Logic.GetGoodTraderOffer(h3ckJGMR,_g3urPc3D[SM],Q)elseif AyUn==QSB.TraderTypes.MercenaryTrader then
cRR1,Bqw19,E6W1701,kxGV49HY=Logic.GetMercenaryOffer(h3ckJGMR,_g3urPc3D[SM],Q)else
cRR1,Bqw19,E6W1701,kxGV49HY=Logic.GetEntertainerTraderOffer(h3ckJGMR,_g3urPc3D[SM],Q)end
table.insert(_,{TraderID=JjW89,OfferID=_g3urPc3D[SM],GoodType=cRR1,OfferGoodAmount=Bqw19,OfferAmount=E6W1701})end;table.insert(MD,_)end;MD.OfferCount=pgP;return MD end
function BundleTradingFunctions.Global:GetOfferCount(ef)
local _TqiEr=self:GetOfferInformation(ef)return _TqiEr.OfferCount end
function BundleTradingFunctions.Global:GetOfferAndTrader(XtH5tUhB,axx10_E)
local ZPS=self:GetOfferInformation(XtH5tUhB)
for z_1=1,#ZPS,1 do
for _Ku7c55H=1,#ZPS,1 do if ZPS[z_1][_Ku7c55H].GoodType==axx10_E then
return
ZPS[z_1][_Ku7c55H].OfferID,ZPS[z_1][_Ku7c55H].TraderID,ZPS.Storehouse end end end end
function BundleTradingFunctions.Global:GetTraderType(OxJrIIC,zS_sFFQ)
if
Logic.IsGoodTrader(BuildingID,zS_sFFQ)==true then return QSB.TraderTypes.GoodTrader elseif
Logic.IsMercenaryTrader(BuildingID,zS_sFFQ)==true then return QSB.TraderTypes.MercenaryTrader elseif
Logic.IsMercenaryTrader(BuildingID,zS_sFFQ)==true then return QSB.TraderTypes.EntertainerTrader else return
QSB.TraderTypes.Unknown end end
function BundleTradingFunctions.Global:GetTrader(Z2dF,jIQDRc)local YQKnxoK1
local paubo=Logic.GetNumberOfMerchants(BuildingID)for A=0,paubo-1,1 do
if self:GetTraderType(BuildingID)==jIQDRc then YQKnxoK1=A;break end end;return YQKnxoK1 end
function BundleTradingFunctions.Global:RemoveOfferByIndex(hB,I,Enz)
local N6upEtl=Logic.GetStoreHouse(hB)if not IsExisting(N6upEtl)then return end;Enz=Enz or 0
local JZ2=self:GetTrader(hB,I)
if JZ2 ~=nil then Logic.RemoveOffer(N6upEtl,JZ2,Enz)end end
function BundleTradingFunctions.Global:RemoveOffer(ru,PE8qH8Ae)
local KiN,oII,I=self:GetOfferAndTrader(ru,PE8qH8Ae)
if KiN and oII and I then Logic.RemoveOffer(I,oII,KiN)end end
function BundleTradingFunctions.Global:ModifyTraderOffer(iTIJNq,t9,gPhmURR,Ru)local CEnSB=GetID(iTIJNq)if not
IsExisting(CEnSB)then return end
Logic.ModifyTraderOffer(CEnSB,t9,gPhmURR,Ru)end
function BundleTradingFunctions.Global:TravelingSalesman_GetHumanPlayer()local vy8=1
for nW=1,8 do if
Logic.PlayerGetIsHumanFlag(1)==true then vy8=nW;break end end;return vy8 end
function BundleTradingFunctions.Global:TravelingSalesman_Create(RqtR,pnwh,Bx,qnz,dH)
assert(type(RqtR)=="number")assert(type(pnwh)=="table")
Bx=Bx or{{3,5},{8,10}}assert(type(Bx)=="table")
assert(type(qnz)=="table")
if not dH then dH={}for z=#qnz,1,-1 do dH[#qnz+1-z]=qnz[z]end end
if not QSB.TravelingSalesman.Harbors[RqtR]then
QSB.TravelingSalesman.Harbors[RqtR]={}
QSB.TravelingSalesman.Harbors[RqtR].Waypoints=qnz
QSB.TravelingSalesman.Harbors[RqtR].Reversed=dH
QSB.TravelingSalesman.Harbors[RqtR].SpawnPos=qnz[1]
QSB.TravelingSalesman.Harbors[RqtR].Destination=dH[1]
QSB.TravelingSalesman.Harbors[RqtR].Appearance=Bx
QSB.TravelingSalesman.Harbors[RqtR].Status=0
QSB.TravelingSalesman.Harbors[RqtR].Offer=pnwh
QSB.TravelingSalesman.Harbors[RqtR].LastOffer=0 end;math.randomseed(Logic.GetTimeMs())if not
QSB.TravelingSalesman.JobID then
QSB.TravelingSalesman.JobID=StartSimpleJob("TravelingSalesman_Control")end end
function BundleTradingFunctions.Global:TravelingSalesman_Disband(B6)
assert(type(B6)=="number")QSB.TravelingSalesman.Harbors[B6]=nil
Logic.RemoveAllOffers(Logic.GetStoreHouse(B6))
DestroyEntity("TravelingSalesmanShip_Player"..B6)end
function BundleTradingFunctions.Global:TravelingSalesman_AddOffer(h3a55v)
MerchantSystem.TradeBlackList[h3a55v]={}MerchantSystem.TradeBlackList[h3a55v][0]=#
MerchantSystem.TradeBlackList[3]
local XJw=Logic.GetStoreHouse(h3a55v)local _HqCsd=1
if#
QSB.TravelingSalesman.Harbors[h3a55v].Offer>1 then repeat
_HqCsd=math.random(1,#
QSB.TravelingSalesman.Harbors[h3a55v].Offer)until
(_HqCsd~=QSB.TravelingSalesman.Harbors[h3a55v].LastOffer)end
QSB.TravelingSalesman.Harbors[h3a55v].LastOffer=_HqCsd
local R9=QSB.TravelingSalesman.Harbors[h3a55v].Offer[_HqCsd]Logic.RemoveAllOffers(XJw)
if#R9 >0 then
for Wl5=1,#R9,1 do local E_m3=R9[Wl5][1]
local O=false;for Kb,tOJHD in pairs(Goods)do if Kb==E_m3 then O=true end end
if O then
local VY=R9[Wl5][2]AddOffer(XJw,VY,Goods[E_m3],9999)else
if
Logic.IsEntityTypeInCategory(Entities[E_m3],EntityCategories.Military)==0 then
AddEntertainerOffer(XJw,Entities[E_m3])else local KAthKTtZ=R9[Wl5][2]
AddMercenaryOffer(XJw,KAthKTtZ,Entities[E_m3],9999)end end end end
SetDiplomacyState(self:TravelingSalesman_GetHumanPlayer(),h3a55v,DiplomacyStates.TradeContact)
ActivateMerchantPermanentlyForPlayer(Logic.GetStoreHouse(h3a55v),self:TravelingSalesman_GetHumanPlayer())local xbYPhUk1=
(IsBriefingActive and not IsBriefingActive())or true
if xbYPhUk1 then
local V={de="Ein Schiff hat angelegt. Es bringt Güter von weit her.",en="A ship is at the pier. It deliver goods from far away."}local SoEK=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
QuestTemplate:New(
"TravelingSalesman_Info_P"..h3a55v,h3a55v,self:TravelingSalesman_GetHumanPlayer(),{{Objective.Dummy}},{{Triggers.Time,0}},0,
nil,nil,nil,nil,false,true,nil,nil,V[SoEK],nil)end end
function BundleTradingFunctions.Global.TravelingSalesman_Control()
for BC,gOX in
pairs(QSB.TravelingSalesman.Harbors)do
if QSB.TravelingSalesman.Harbors[BC]~=nil then
if
gOX.Status==0 then local blA=Logic.GetCurrentMonth()local M=false
for XCNzm=1,#gOX.Appearance,1 do if blA==
gOX.Appearance[XCNzm][1]then M=true end end
if M then
local W4yLXpub=Logic.GetEntityOrientation(GetID(gOX.SpawnPos))
local YTocq=CreateEntity(0,Entities.D_X_TradeShip,GetPosition(gOX.SpawnPos),"TravelingSalesmanShip_Player"..BC,W4yLXpub)
Path:new(YTocq,gOX.Waypoints,nil,nil,nil,nil,true,nil,nil,300)gOX.Status=1 end elseif gOX.Status==1 then
if
IsNear("TravelingSalesmanShip_Player"..BC,gOX.Destination,400)then
BundleTradingFunctions.Global:TravelingSalesman_AddOffer(BC)gOX.Status=2 end elseif gOX.Status==2 then local H=Logic.GetCurrentMonth()local rW_DDL=false;for S1p9l=1,#gOX.Appearance,1
do
if H==gOX.Appearance[S1p9l][2]then rW_DDL=true end end
if rW_DDL then
SetDiplomacyState(BundleTradingFunctions.Global:TravelingSalesman_GetHumanPlayer(),BC,DiplomacyStates.EstablishedContact)
Path:new(GetID("TravelingSalesmanShip_Player"..BC),gOX.Reversed,nil,nil,nil,nil,true,
nil,nil,300)
Logic.RemoveAllOffers(Logic.GetStoreHouse(BC))gOX.Status=3 end elseif gOX.Status==3 then
if
IsNear("TravelingSalesmanShip_Player"..BC,gOX.SpawnPos,400)then
DestroyEntity("TravelingSalesmanShip_Player"..BC)gOX.Status=0 end end end end end;function BundleTradingFunctions.Local:Install()end
Core:RegisterBundle("BundleTradingFunctions")API=API or{}QSB=QSB or{}
function API.StartMusic(XlKy3jRN)if GUI then
API.Log("Could not execute API.StartMusic in local script!")return end
BundleMusicTools.Global:StartSong(XlKy3jRN)end;StartMusic=API.StartMusic
function API.StartMusicSimple(X7,Na3Wmw,oK1ElTh,VjQQjk)if GUI then
API.Bridge("API.StartMusicSimple('"..X7 ..
"', "..Na3Wmw..", "..oK1ElTh..", "..VjQQjk..
")")return end
local H={File=X7,Volume=Na3Wmw,Length=oK1ElTh,Fadeout=VjQQjk*10,MuteAtmo=true,MuteUI=true}BundleMusicTools.Global:StartSong(H)end;StartMusicSimple=API.StartMusicSimple
function API.StartPlaylist(NA2LCmvR)if GUI then
API.Log("Could not execute API.StartPlaylist in local script!")return end
BundleMusicTools.Global:StartPlaylist(NA2LCmvR)end;StartPlaylist=API.StartPlaylist
function API.StartPlaylistTitle(wYCYzS)if GUI then
API.Log("Could not execute API.StartPlaylistTitle in local script!")return end
BundleMusicTools.Global:StartPlaylistTitle(wYCYzS)end;StartPlaylistTitle=API.StartPlaylistTitle;function API.StopSong()if GUI then
API.Bridge("API.StopSong()")return end
BundleMusicTools.Global:StopSong()end
StopSong=API.StopSong
function API.AbortMusic()
if GUI then API.Bridge("API.AbortMusic()")return end;BundleMusicTools.Global:AbortMusic()end;AbortSongOrPlaylist=API.AbortMusic
BundleMusicTools={Global={Data={StartSongData={},StartSongPlaylist={},StartSongQueue={}}},Local={Data={SoundBackup={}}}}function BundleMusicTools.Global:Install()end
function BundleMusicTools.Global:StartSong(ZF6g1)
if
self.Data.StartSongData.Running then table.insert(self.Data.StartSongQueue,ZF6g1)else assert(
type(ZF6g1.File)=="string")assert(type(ZF6g1.Volume)==
"number")assert(type(ZF6g1.Length)==
"number")
ZF6g1.Length=ZF6g1.Length*10
assert(type(ZF6g1.Fadeout)=="number")ZF6g1.MuteAtmo=ZF6g1.MuteAtmo==true
ZF6g1.MuteUI=ZF6g1.MuteUI==true;ZF6g1.CurrentVolume=ZF6g1.Volume;ZF6g1.Time=0
self.Data.StartSongData=ZF6g1;self.Data.StartSongData.Running=true
Logic.ExecuteInLuaLocalState(
[[
            BundleMusicTools.Local:BackupSound(
                ]]..
ZF6g1.Volume..
[[,
                "]]..ZF6g1.File..
[[",
                ]]..tostring(ZF6g1.MuteAtmo)..

[[,
                ]]..tostring(ZF6g1.MuteUI)..[[
            )
        ]])if not self.Data.StartSongJob then
self.Data.StartSongJob=StartSimpleHiResJob("StartSongControl")end end end
function BundleMusicTools.Global:StartPlaylist(ZeB)
for G=1,#ZeB,1 do
table.insert(self.Data.StartSongPlaylist,ZeB[G])self:StartSong(ZeB[G])end
self.Data.StartSongPlaylist.Repeat=ZeB.Repeat==true end
function BundleMusicTools.Global:StartPlaylistTitle(mSwrC)
local JsIicgS=self.Data.StartSongPlaylist;local aKpAgOBl=#length
if(aKpAgOBl>=mSwrC)then
self.Data.StartSongData.Running=false;self.Data.StartSongQueue={}self.Data.StartSongData={}
self:StopSong()EndJob(self.Data.StartSongJob)
self.Data.StartSongJob=nil;for f7=mSwrC,aKpAgOBl,1 do self:StartSong(JsIicgS)end end end
function BundleMusicTools.Global:StopSong()
local EZXcK4=#self.Data.StartSongQueue;local bBKWP8=self.Data.StartSongData
Logic.ExecuteInLuaLocalState(
[[
        BundleMusicTools.Local:ResetSound(
            "]]..

((bBKWP8.File~=nil and bBKWP8.File)or"")..[[",
            ]]..EZXcK4 ..[[
        )
    ]])end
function BundleMusicTools.Global:AbortMusic()self.Data.StartSongPlaylist={}
self.Data.StartSongQueue={}self:StopSong()self.Data.StartSongData={}
EndJob(self.Data.StartSongJob)self.Data.StartSongJob=nil end
function BundleMusicTools.Global.StartSongControl()
if not
BundleMusicTools.Global.Data.StartSongData.Running then
BundleMusicTools.Global.Data.StartSongData={}
BundleMusicTools.Global.Data.StartSongJob=nil
if
#BundleMusicTools.Global.Data.StartSongQueue>0 then
local U=table.remove(BundleMusicTools.Global.Data.StartSongQueue,1)BundleMusicTools.Global:StartSong(U)else if
BundleMusicTools.Global.Data.StartSongPlaylist.Repeat then
BundleMusicTools.Global:StartPlaylist(BundleMusicTools.Global.Data.StartSongPlaylist)end end;return true end
local Ozn2ob=BundleMusicTools.Global.Data.StartSongData;BundleMusicTools.Global.Data.StartSongData.Time=
Ozn2ob.Time+1
if Ozn2ob.Fadeout<5 then
if
Ozn2ob.Time>=Ozn2ob.Length then
BundleMusicTools.Global.Data.StartSongData.Running=false;BundleMusicTools.Global:StopSong()end else local nHXCWoK=Ozn2ob.Length-Ozn2ob.Fadeout+1
if
Ozn2ob.Time>=nHXCWoK then
if Ozn2ob.Time>=Ozn2ob.Length then
BundleMusicTools.Global.Data.StartSongData.Running=false;BundleMusicTools.Global:StopSong()else local Rk=
Ozn2ob.Volume/Ozn2ob.Fadeout;BundleMusicTools.Global.Data.StartSongData.CurrentVolume=
Ozn2ob.CurrentVolume-Rk
Logic.ExecuteInLuaLocalState(
[[
                    Sound.SetSpeechVolume(]]..Ozn2ob.CurrentVolume..[[)
                ]])end end end end
StartSongControl=BundleMusicTools.Global.StartSongControl;function BundleMusicTools.Local:Install()end
function BundleMusicTools.Local:BackupSound(X2L5kdSj,sv,qpVqVyu,Jch)
if
self.Data.SoundBackup.FXSP==nil then
self.Data.SoundBackup.FXSP=Sound.GetFXSoundpointVolume()
self.Data.SoundBackup.FXAtmo=Sound.GetFXAtmoVolume()self.Data.SoundBackup.FXVol=Sound.GetFXVolume()
self.Data.SoundBackup.Sound=Sound.GetGlobalVolume()
self.Data.SoundBackup.Music=Sound.GetMusicVolume()
self.Data.SoundBackup.Voice=Sound.GetSpeechVolume()self.Data.SoundBackup.UI=Sound.Get2DFXVolume()end;Sound.SetFXVolume(100)
Sound.SetSpeechVolume(X2L5kdSj)if qpVqVyu==true then Sound.SetFXSoundpointVolume(0)
Sound.SetFXAtmoVolume(0)end;if Jch==true then
Sound.Set2DFXVolume(0)Sound.SetFXVolume(0)end
Sound.SetMusicVolume(0)Sound.PlayVoice("ImportantStuff",sv)end
function BundleMusicTools.Local:ResetSound(yA3_MrG,XiL)if yA3_MrG~=nil then
Sound.StopVoice("ImportantStuff",yA3_MrG)end
if XiL<=0 then
if
self.Data.SoundBackup.FXSP~=nil then
Sound.SetFXSoundpointVolume(self.Data.SoundBackup.FXSP)
Sound.SetFXAtmoVolume(self.Data.SoundBackup.FXAtmo)
Sound.SetFXVolume(self.Data.SoundBackup.FXVol)
Sound.SetGlobalVolume(self.Data.SoundBackup.Sound)
Sound.SetMusicVolume(self.Data.SoundBackup.Music)
Sound.SetSpeechVolume(self.Data.SoundBackup.Voice)
Sound.Set2DFXVolume(self.Data.SoundBackup.UI)self.Data.SoundBackup={}end end end;Core:RegisterBundle("BundleMusicTools")API=API or{}QSB=
QSB or{}
function API.GetScale(br)if not IsExisting(br)then local e=
(type(br)=="string"and"'"..br.."'")or br;API.Dbg("API.GetScale: Target "..
e.." is invalid!")
return-1 end;return
BundleEntityScriptingValues:GetEntitySize(br)end;GetScale=API.GetScale
function API.GetPlayer(iot)
if not IsExisting(iot)then
local x4HMqofS=(type(iot)=="string"and
"'"..iot.."'")or iot
API.Dbg("API.GetPlayer: Target "..x4HMqofS.." is invalid!")return-1 end
return BundleEntityScriptingValues:GetPlayerID(_entity)end;AGetPlayer=API.GetPlayer
function API.GetMovingTarget(O8C)
if not IsExisting(O8C)then
local IcjWO7p=(
type(O8C)=="string"and"'"..O8C.."'")or O8C
API.Dbg("API.GetMovingTarget: Target "..IcjWO7p.." is invalid!")return nil end
return BundleEntityScriptingValues:GetMovingTargetPosition(O8C)end;GetMovingTarget=API.GetMovingTarget
function API.IsNpc(Vv4Mnuz)
if not IsExisting(Vv4Mnuz)then local L=
(
type(Vv4Mnuz)=="string"and"'"..Vv4Mnuz.."'")or Vv4Mnuz
API.Dbg(
"API.IsNpc: Target "..L.." is invalid!")return false end;return
BundleEntityScriptingValues:IsOnScreenInformationActive(Vv4Mnuz)end;IsNpc=API.IsNpc
function API.IsVisible(u51)
if not IsExisting(u51)then
local oNX=(type(u51)=="string"and"'"..
u51 .."'")or u51
API.Dbg("API.IsVisible: Target "..oNX.." is invalid!")return false end
return BundleEntityScriptingValues:IsEntityVisible(u51)end;IsVisible=API.IsVisible
function API.SetScale(wlr4z,FCKvK1)
if GUI or not IsExisting(wlr4z)then local Aj=(
type(wlr4z)=="string"and"'"..wlr4z.."'")or
wlr4z
API.Dbg("API.SetScale: Target "..Aj..
" is invalid!")return end;if type(FCKvK1)~="number"then
API.Dbg("API.SetScale: Scale must be a number!")return end;return
BundleEntityScriptingValues.Global:SetEntitySize(wlr4z,FCKvK1)end;SetScale=API.SetScale
function API.SetPlayer(YqjKv,iWixd2I0)
if GUI or not IsExisting(YqjKv)then local Xl1lLI=(
type(YqjKv)=="string"and"'"..YqjKv.."'")or
YqjKv
API.Dbg("API.SetPlayer: Target "..
Xl1lLI.." is invalid!")return end;if
type(iWixd2I0)~="number"or iWixd2I0 <=0 or iWixd2I0 >8 then
API.Dbg("API.SetPlayer: Player-ID must between 0 and 8!")return end;return
BundleEntityScriptingValues.Global:SetPlayerID(YqjKv,math.floor(iWixd2I0))end;ChangePlayer=API.SetPlayer
BundleEntityScriptingValues={Global={Data={}},Local={Data={}}}
function BundleEntityScriptingValues.Global:Install()end
function BundleEntityScriptingValues.Global:SetEntitySize(DMQ5HD,RLhK54E)
local eRTiz7g=GetID(DMQ5HD)
Logic.SetEntityScriptingValue(eRTiz7g,-45,BundleEntityScriptingValues:Float2Int(RLhK54E))if Logic.IsSettler(eRTiz7g)==1 then
Logic.SetSpeedFactor(eRTiz7g,RLhK54E)end end
function BundleEntityScriptingValues.Global:SetPlayerID(jXL,PkLOGsOP)local bFn=GetID(jXL)Logic.SetEntityScriptingValue(bFn,
-71,PkLOGsOP)end
function BundleEntityScriptingValues.Local:Install()end
function BundleEntityScriptingValues:GetEntitySize(oTpxIYi)local PR=GetID(oTpxIYi)local c=Logic.GetEntityScriptingValue(PR,
-45)return self.Int2Float(c)end
function BundleEntityScriptingValues:GetPlayerID(keW5h)local b6Txh=GetID(keW5h)return Logic.GetEntityScriptingValue(b6Txh,
-71)end
function BundleEntityScriptingValues:IsEntityVisible(SpoUBD7w)local ho1FzW=GetID(SpoUBD7w)
return Logic.GetEntityScriptingValue(ho1FzW,
-50)==801280 end
function BundleEntityScriptingValues:IsOnScreenInformationActive(GO9HlQ)local O7=GetID(GO9HlQ)if
Logic.IsSettler(O7)==0 then return false end;return
Logic.GetEntityScriptingValue(O7,6)==1 end
function BundleEntityScriptingValues:GetMovingTargetPosition(pQ)local CFLVvMz={}
CFLVvMz.X=self:GetValueAsFloat(pQ,19)CFLVvMz.Y=self:GetValueAsFloat(pQ,20)return CFLVvMz end
function BundleEntityScriptingValues:GetValueAsInteger(mPz,WlGwky)
local RtZZtr=Logic.GetEntityScriptingValue(GetID(mPz),WlGwky)return RtZZtr end
function BundleEntityScriptingValues:GetValueAsFloat(ePsw,rf2m)
local BiM=Logic.GetEntityScriptingValue(GetID(ePsw),rf2m)return SV.Int2Float(BiM)end;function BundleEntityScriptingValues:qmod(uOhNz2,sB3)return
uOhNz2-math.floor(uOhNz2/sB3)*sB3 end
function BundleEntityScriptingValues:Int2Float(EDVCd3v)if(
EDVCd3v==0)then return 0 end;local sFBE3=1;if(EDVCd3v<0)then
EDVCd3v=2147483648+EDVCd3v;sFBE3=-1 end
local DZyBzIT=self:qmod(EDVCd3v,8388608)local zrljL4=(EDVCd3v-DZyBzIT)/8388608
local m6=self:qmod(zrljL4,256)local aLSR=m6-127;local P3xSJvRy=1;local iQQ=0.5;local Y=4194304
for R1oor_ww=23,0,-1 do if(DZyBzIT-Y)>0 then
P3xSJvRy=P3xSJvRy+iQQ;DZyBzIT=DZyBzIT-Y end;Y=Y/2;iQQ=iQQ/2 end;return P3xSJvRy*math.pow(2,aLSR)*sFBE3 end
function BundleEntityScriptingValues:bitsInt(QKN)local oe_q={}while QKN>0 do rest=self:qmod(QKN,2)
table.insert(oe_q,1,rest)QKN=(QKN-rest)/2 end
table.remove(oe_q,1)return oe_q end
function BundleEntityScriptingValues:bitsFrac(KklVg,TWY9IDRT)
for EjuwR=1,48 do KklVg=KklVg*2
if(KklVg>=1)then
table.insert(TWY9IDRT,1)KklVg=KklVg-1 else table.insert(TWY9IDRT,0)end;if(KklVg==0)then return TWY9IDRT end end;return TWY9IDRT end
function BundleEntityScriptingValues:Float2Int(nqG_)if(nqG_==0)then return 0 end;local RL4Ijr=false;if
(nqG_<0)then RL4Ijr=true;nqG_=nqG_*-1 end;local km=0;local LnB;local Lto_pkw=0
if nqG_>=1 then
local JLPz9w=math.floor(nqG_)local i=nqG_-JLPz9w;LnB=self:bitsInt(JLPz9w)
Lto_pkw=table.getn(LnB)self:bitsFrac(i,LnB)else LnB={}self:bitsFrac(nqG_,LnB)
while(
LnB[1]==0)do Lto_pkw=Lto_pkw-1;table.remove(LnB,1)end;Lto_pkw=Lto_pkw-1;table.remove(LnB,1)end;local P=4194304;local zR=1;for E=zR,23 do local d6=LnB[E]if(not d6)then break end
if(d6 ==1)then km=km+P end;P=P/2 end;km=km+
(Lto_pkw+127)*8388608;if(RL4Ijr)then km=km-2147483648 end
return km end
Core:RegisterBundle("BundleEntityScriptingValues")API=API or{}QSB=QSB or{}
function API.AddEntity(Ozu1y)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.AddEntity("]]..
Ozu1y..[[")
        ]])else if not
Inside(_enitry,BundleConstructionControl.Local.Data.Entities)then
table.insert(BundleConstructionControl.Local.Data.Entities,Ozu1y)end end end
function API.AddEntityType(QCp0)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.AddEntityType(]]..QCp0 ..[[)
        ]])else if not
Inside(_enitry,BundleConstructionControl.Local.Data.EntityTypes)then
table.insert(BundleConstructionControl.Local.Data.EntityTypes,QCp0)end end end
function API.AddCategory(fYg9P7)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.AddCategory(]]..fYg9P7 ..[[)
        ]])else
if not
Inside(_enitry,BundleConstructionControl.Local.Data.EntityCategories)then
table.insert(BundleConstructionControl.Local.Data.EntityCategories,fYg9P7)end end end
function API.AddTerritory(iYVq)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.AddTerritory(]]..iYVq..[[)
        ]])else if not
Inside(_enitry,BundleConstructionControl.Local.Data.OnTerritory)then
table.insert(BundleConstructionControl.Local.Data.OnTerritory,iYVq)end end end
function API.RemoveEntity(wupYZnQr)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.RemoveEntity("]]..wupYZnQr..[[")
        ]])else
for J0PG0o=1,#BundleConstructionControl.Local.Data.Entities
do
if
BundleConstructionControl.Local.Data.Entities[J0PG0o]==wupYZnQr then
table.remove(BundleConstructionControl.Local.Data.Entities,J0PG0o)return end end end end
function API.RemoveEntityType(tiVZj)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.RemoveEntityType(]]..tiVZj..[[)
        ]])else
for _v6=1,#BundleConstructionControl.Local.Data.EntityTypes
do
if
BundleConstructionControl.Local.Data.EntityTypes[_v6]==tiVZj then
table.remove(BundleConstructionControl.Local.Data.EntityTypes,_v6)return end end end end
function API.RemoveCategory(vW)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.RemoveCategory(]]..vW..[[)
        ]])else
for GoJOI=1,#BundleConstructionControl.Local.Data.EntityCategories
do
if
BundleConstructionControl.Local.Data.EntityCategories[GoJOI]==vW then
table.remove(BundleConstructionControl.Local.Data.EntityCategories,GoJOI)return end end end end
function API.RemoveTerritory(L5V5)
if not GUI then
Logic.ExecuteInLuaLocalState([[
            API.RemoveTerritory(]]..L5V5 ..[[)
        ]])else
for S=1,#BundleConstructionControl.Local.Data.OnTerritory
do if
BundleConstructionControl.Local.Data.OnTerritory[S]==L5V5 then
table.remove(BundleConstructionControl.Local.Data.OnTerritory,S)return end end end end
function API.BanTypeAtTerritory(cX4,vreHvTGT)
if GUI then local s0=
(type(_center)=="string"and"'"..vreHvTGT.."'")or vreHvTGT
GUI.SendScriptCommand(
"API.BanTypeAtTerritory("..cX4 ..", "..s0 ..")")return end;if type(vreHvTGT)=="string"then
vreHvTGT=GetTerritoryIDByName(vreHvTGT)end
BundleConstructionControl.Global.Data.TerritoryBlockEntities[cX4]=
BundleConstructionControl.Global.Data.TerritoryBlockEntities[cX4]or{}
if not
Inside(vreHvTGT,BundleConstructionControl.Global.Data.TerritoryBlockEntities[cX4])then
table.insert(BundleConstructionControl.Global.Data.TerritoryBlockEntities[cX4],vreHvTGT)end end
function API.BanCategoryAtTerritory(WJ,oib23Gb)
if GUI then local DQ=
(type(_center)=="string"and"'"..oib23Gb.."'")or oib23Gb
GUI.SendScriptCommand(
"API.BanTypeAtTerritory("..WJ..", "..DQ..")")return end;if type(oib23Gb)=="string"then
oib23Gb=GetTerritoryIDByName(oib23Gb)end
BundleConstructionControl.Global.Data.TerritoryBlockCategories[WJ]=
BundleConstructionControl.Global.Data.TerritoryBlockCategories[WJ]or{}
if not
Inside(oib23Gb,BundleConstructionControl.Global.Data.TerritoryBlockCategories[WJ])then
table.insert(BundleConstructionControl.Global.Data.TerritoryBlockCategories[WJ],oib23Gb)end end
function API.BanTypeInArea(K,X8Ziqc,fm)
if GUI then local QgS=
(type(X8Ziqc)=="string"and"'"..X8Ziqc.."'")or X8Ziqc
GUI.SendScriptCommand(
"API.BanTypeInArea("..K..", "..QgS..", "..fm..")")return end
BundleConstructionControl.Global.Data.AreaBlockEntities[X8Ziqc]=
BundleConstructionControl.Global.Data.AreaBlockEntities[X8Ziqc]or{}
if not
Inside(K,BundleConstructionControl.Global.Data.AreaBlockEntities[X8Ziqc],true)then
table.insert(BundleConstructionControl.Global.Data.AreaBlockEntities[X8Ziqc],{K,fm})end end
function API.BanCategoryInArea(DNuXOE,U,bnA)
if GUI then local qtpDOuy=
(type(U)=="string"and"'"..U.."'")or U
GUI.SendScriptCommand("API.BanCategoryInArea("..DNuXOE..", "..
qtpDOuy..", "..bnA..")")return end
BundleConstructionControl.Global.Data.AreaBlockCategories[U]=
BundleConstructionControl.Global.Data.AreaBlockCategories[U]or{}
if not
Inside(DNuXOE,BundleConstructionControl.Global.Data.AreaBlockCategories[U],true)then
table.insert(BundleConstructionControl.Global.Data.AreaBlockCategories[U],{DNuXOE,bnA})end end
function API.UnBanTypeAtTerritory(pJeOTrBz,oMEOx)
if GUI then local P1=
(type(_center)=="string"and"'"..oMEOx.."'")or oMEOx
GUI.SendScriptCommand(
"API.UnBanTypeAtTerritory("..pJeOTrBz..", "..P1 ..")")return end
if type(oMEOx)=="string"then oMEOx=GetTerritoryIDByName(oMEOx)end
if not
BundleConstructionControl.Global.Data.TerritoryBlockEntities[pJeOTrBz]then return end
for A=1,BundleConstructionControl.Global.Data.TerritoryBlockEntities[pJeOTrBz],1
do
if
BundleConstructionControl.Global.Data.TerritoryBlockEntities[pJeOTrBz][A]==pJeOTrBz then
table.remove(BundleConstructionControl.Global.Data.TerritoryBlockEntities[pJeOTrBz],A)break end end end
function API.UnBanCategoryAtTerritory(AJancK03,dpxx)
if GUI then local QmtHoP2=
(type(_center)=="string"and"'"..dpxx.."'")or dpxx
GUI.SendScriptCommand(
"API.UnBanTypeAtTerritory("..AJancK03 ..", "..QmtHoP2 ..")")return end
if type(dpxx)=="string"then dpxx=GetTerritoryIDByName(dpxx)end
if not
BundleConstructionControl.Global.Data.TerritoryBlockCategories[AJancK03]then return end
for n0=1,BundleConstructionControl.Global.Data.TerritoryBlockCategories[AJancK03],1
do
if
BundleConstructionControl.Global.Data.TerritoryBlockCategories[AJancK03][n0]==_type then
table.remove(BundleConstructionControl.Global.Data.TerritoryBlockCategories[AJancK03],n0)break end end end
function API.UnBanTypeInArea(pAi,rxo)
if GUI then local eCLz=
(type(rxo)=="string"and"'"..rxo.."'")or rxo
GUI.SendScriptCommand("API.UnBanTypeInArea("..
_eCat..", "..eCLz..")")return end
if not
BundleConstructionControl.Global.Data.AreaBlockEntities[rxo]then return end
for Ku=1,BundleConstructionControl.Global.Data.AreaBlockEntities[rxo],1
do
if
BundleConstructionControl.Global.Data.AreaBlockEntities[rxo][Ku][1]==pAi then
table.remove(BundleConstructionControl.Global.Data.AreaBlockEntities[rxo],Ku)break end end end
function API.UnBanCategoryInArea(sHlcIN,D6B)
if GUI then local DpGo7MYy=
(type(D6B)=="string"and"'"..D6B.."'")or D6B
GUI.SendScriptCommand(
"API.UnBanCategoryInArea(".._type..", "..DpGo7MYy..")")return end
if not
BundleConstructionControl.Global.Data.AreaBlockCategories[D6B]then return end
for pRFHMy9=1,BundleConstructionControl.Global.Data.AreaBlockCategories[D6B],1
do
if
BundleConstructionControl.Global.Data.AreaBlockCategories[D6B][pRFHMy9][1]==sHlcIN then
table.remove(BundleConstructionControl.Global.Data.AreaBlockCategories[D6B],pRFHMy9)break end end end
BundleConstructionControl={Global={Data={TerritoryBlockCategories={},TerritoryBlockEntities={},AreaBlockCategories={},AreaBlockEntities={}}},Local={Data={Entities={},EntityTypes={},EntityCategories={},OnTerritory={}}}}
function BundleConstructionControl.Global:Install()
Core:AppendFunction("GameCallback_CanPlayerPlaceBuilding",BundleConstructionControl.Global.CanPlayerPlaceBuilding)end
function BundleConstructionControl.Global.CanPlayerPlaceBuilding(htpqxO,OiNFrve,Ld4,G)
for mxb_8EG,N in
pairs(BundleConstructionControl.Global.Data.TerritoryBlockCategories)do
if N then
for mu,eHdzI in pairs(N)do
if
eHdzI and Logic.GetTerritoryAtPosition(Ld4,G)==eHdzI then if Logic.IsEntityTypeInCategory(OiNFrve,mxb_8EG)==1 then
return false end end end end end
for A,K4bQGe in
pairs(BundleConstructionControl.Global.Data.TerritoryBlockEntities)do
if K4bQGe then
for vi4K,GUFxXd in pairs(K4bQGe)do
GUI_Note(tostring(Logic.GetTerritoryAtPosition(Ld4,G)==GUFxXd))
if
GUFxXd and Logic.GetTerritoryAtPosition(Ld4,G)==GUFxXd then if OiNFrve==A then return false end end end end end
for hmJ,suyU in
pairs(BundleConstructionControl.Global.Data.AreaBlockCategories)do
if suyU then
for iG8VIx,XDL in pairs(suyU)do if
Logic.IsEntityTypeInCategory(OiNFrve,XDL[1])==1 then
if GetDistance(hmJ,{X=Ld4,Y=G})<XDL[2]then return false end end end end end
for aSI03F,So4V_ in
pairs(BundleConstructionControl.Global.Data.AreaBlockEntities)do
if So4V_ then for jfUOP,S1wxFpt in pairs(So4V_)do
if OiNFrve==S1wxFpt[1]then if GetDistance(aSI03F,{X=Ld4,Y=G})<
S1wxFpt[2]then return false end end end end end;return true end
function BundleConstructionControl.Local:Install()
Core:AppendFunction("GameCallback_GUI_DeleteEntityStateBuilding",BundleConstructionControl.Local.DeleteEntityStateBuilding)end
function BundleConstructionControl.Local.DeleteEntityStateBuilding(yd3vMT3M)
local n=Logic.GetEntityType(yd3vMT3M)local ufu5y=Logic.GetEntityName(yd3vMT3M)
local DPXsZ=GetTerritoryUnderEntity(yd3vMT3M)
if Logic.IsConstructionComplete(yd3vMT3M)==1 then
if
Inside(ufu5y,BundleConstructionControl.Local.Data.Entities)then GUI.CancelBuildingKnockDown(yd3vMT3M)return end
if
Inside(n,BundleConstructionControl.Local.Data.EntityTypes)then GUI.CancelBuildingKnockDown(yd3vMT3M)return end
if
Inside(DPXsZ,BundleConstructionControl.Local.Data.OnTerritory)then GUI.CancelBuildingKnockDown(yd3vMT3M)return end
for eA0S,Xf9rC in
pairs(BundleConstructionControl.Local.Data.EntityCategories)do if Logic.IsEntityInCategory(yd3vMT3M,Xf9rC)==1 then
GUI.CancelBuildingKnockDown(yd3vMT3M)return end end end end;Core:RegisterBundle("BundleConstructionControl")API=
API or{}QSB=QSB or{}
function API.DisableRefillTrebuchet(zc)if not GUI then
API.Bridge("API.DisableRefillTrebuchet("..
tostring(zc)..")")return end
API.Bridge(
"BundleEntitySelection.Local.Data.RefillTrebuchet = "..tostring(not zc))
BundleEntitySelection.Local.Data.RefillTrebuchet=not zc end
function API.DisableThiefRelease(bP)if not GUI then
API.Bridge("API.DisableThiefRelease("..tostring(bP)..")")return end;BundleEntitySelection.Local.Data.ThiefRelease=
bP==true end
function API.DisableSiegeEngineRelease(xc)if not GUI then
API.Bridge("API.DisableSiegeEngineRelease("..tostring(xc)..")")return end;BundleEntitySelection.Local.Data.SiegeEngineRelease=
xc==true end
function API.DisableMilitaryRelease(BKVNy5o_)if not GUI then
API.Bridge("API.DisableMilitaryRelease("..tostring(BKVNy5o_)..")")return end;BundleEntitySelection.Local.Data.MilitaryRelease=
BKVNy5o_==true end
BundleEntitySelection={Global={Data={RefillTrebuchet=true,AmmunitionUnderway={},TrebuchetIDToCart={}}},Local={Data={RefillTrebuchet=true,ThiefRelease=true,SiegeEngineRelease=true,MilitaryRelease=true,Tooltips={KnightButton={Title={de="Ritter selektieren",en="Select Knight"},Text={de="- Klick selektiert den Ritter {cr}- Doppelklick springt zum Ritter{cr}- STRG halten selektiert alle Ritter",en="- Click selects the knight {cr}- Double click jumps to knight{cr}- Press CTRL to select all knights"}},BattalionButton={Title={de="Militär selektieren",en="Select Units"},Text={de="- Selektiert alle Militäreinheiten {cr}- SHIFT halten um auch Munitionswagen und Trebuchets auszuwählen",en="- Selects all military units {cr}- Press SHIFT to additionally select ammunition carts and trebuchets"}},ReleaseSoldiers={Title={de="Militär entlassen",en="Release military unit"},Text={de="- Eine Militäreinheit entlassen {cr}- Soldaten werden nacheinander entlassen",en="- Dismiss a military unit {cr}- Soldiers will be dismissed each after another"},Disabled={de="Kann nicht entlassen werden!",en="Releasing is impossible!"}},TrebuchetCart={Title={de="Trebuchetwagen",en="Trebuchet cart"},Text={de="- Kann einmalig zum Trebuchet ausgebaut werden",en="- Can uniquely be transmuted into a trebuchet"}},Trebuchet={Title={de="Trebuchet",en="Trebuchet"},Text={de="- Kann über weite Strecken Gebäude angreifen {cr}- Kann Gebäude in Brand stecken {cr}- Kann nur durch Munitionsanforderung befüllt werden {cr}- Trebuchet kann manuell zurückgeschickt werden",en="- Can perform long range attacks on buildings {cr}- Can set buildings on fire {cr}- Can only be filled by ammunition request {cr}- The trebuchet can be manually send back to the city"}},TrebuchetRefiller={Title={de="Aufladen",en="Refill"},Text={de="- Läd das Trebuchet mit Karren aus dem Lagerhaus nach {cr}- Benötigt die Differenz an Steinen {cr}- Kann jeweils nur einen Wagen zu selben Zeit senden",en="- Refill the Trebuchet with a cart from the storehouse {cr}- Stones for missing ammunition required {cr}- Only one cart at the time allowed"}}}}}}function BundleEntitySelection.Global:Install()end
function BundleEntitySelection.Global:DeactivateRefillTrebuchet(yBEWVGM)self.Data.RefillTrebuchet=
not yBEWVGM
Logic.ExecuteInLuaLocalState(
[[
        function BundleEntitySelection.Local:DeactivateRefillTrebuchet(]]..tostring(yBEWVGM)..[[)
    ]])end
function BundleEntitySelection.Global:MilitaryDisambleTrebuchet(vBNGHh0S)
local gT,_u3A2Kdb,sBd3=Logic.EntityGetPos(vBNGHh0S)local VGgYPo=Logic.EntityGetPlayer(vBNGHh0S)if GameCallback_QSB_OnDisambleTrebuchet then
GameCallback_QSB_OnDisambleTrebuchet(vBNGHh0S,VGgYPo,gT,_u3A2Kdb,sBd3)return end
if
self.Data.AmmunitionUnderway[vBNGHh0S]then
API.Message{de="Eine Munitionslieferung ist auf dem Weg!",en="A ammunition card is on the way!"}return end
Logic.CreateEffect(EGL_Effects.E_Shockwave01,gT,_u3A2Kdb,0)Logic.SetEntityInvulnerabilityFlag(vBNGHh0S,1)
Logic.SetEntitySelectableFlag(vBNGHh0S,0)Logic.SetVisible(vBNGHh0S,false)
local MbaSv=self.Data.TrebuchetIDToCart[vBNGHh0S]
if MbaSv~=nil then Logic.SetEntityInvulnerabilityFlag(MbaSv,0)
Logic.SetEntitySelectableFlag(MbaSv,1)Logic.SetVisible(MbaSv,true)else
MbaSv=Logic.CreateEntity(Entities.U_SiegeEngineCart,gT,_u3A2Kdb,0,VGgYPo)self.Data.TrebuchetIDToCart[vBNGHh0S]=MbaSv end;Logic.DEBUG_SetSettlerPosition(MbaSv,gT,_u3A2Kdb)
Logic.SetTaskList(MbaSv,TaskLists.TL_NPC_IDLE)
Logic.ExecuteInLuaLocalState([[
        GUI.SelectEntity(]]..MbaSv..[[)
    ]])end
function BundleEntitySelection.Global:MilitaryErectTrebuchet(c486nrm8)
local K,i,cy=Logic.EntityGetPos(c486nrm8)local t=Logic.EntityGetPlayer(c486nrm8)if GameCallback_QSB_OnErectTrebuchet then
GameCallback_QSB_OnErectTrebuchet(c486nrm8,t,K,i,cy)return end
Logic.CreateEffect(EGL_Effects.E_Shockwave01,K,i,0)Logic.SetEntityInvulnerabilityFlag(c486nrm8,1)
Logic.SetEntitySelectableFlag(c486nrm8,0)Logic.SetVisible(c486nrm8,false)local vHp
for LU_7,xIgwR in
pairs(self.Data.TrebuchetIDToCart)do if xIgwR==c486nrm8 then vHp=tonumber(LU_7)end end
if vHp==nil then
vHp=Logic.CreateEntity(Entities.U_Trebuchet,K,i,0,t)self.Data.TrebuchetIDToCart[vHp]=c486nrm8 end;Logic.SetEntityInvulnerabilityFlag(vHp,0)
Logic.SetEntitySelectableFlag(vHp,1)Logic.SetVisible(vHp,true)
Logic.DEBUG_SetSettlerPosition(vHp,K,i)
Logic.ExecuteInLuaLocalState([[
        GUI.SelectEntity(]]..vHp..[[)
    ]])end
function BundleEntitySelection.Global:MilitaryCallForRefiller(r0C1)
local dD4=Logic.EntityGetPlayer(r0C1)local bnT=Logic.GetStoreHouse(dD4)
local dTa=Logic.GetAmmunitionAmount(r0C1)local iK0=GetPlayerResources(Goods.G_Stone,dD4)if
GameCallback_tHEA_OnRefillerCartCalled then
GameCallback_tHEA_OnRefillerCartCalled(r0C1,dD4,bnT,dTa,iK0)return end
if
self.Data.AmmunitionUnderway[r0C1]or bnT==0 then
API.Message{de="Eine Munitionslieferung ist auf dem Weg!",en="A ammunition card is on the way!"}return end
if dTa==10 or iK0 <10-dTa then
API.Message{de="Nicht genug Steine oder das Trebuchet ist voll!",en="Not enough stones or the trebuchet is full!"}return end;local kmgJ,Z5nmrSn=Logic.GetBuildingApproachPosition(bnT)
local d=Logic.CreateEntity(Entities.U_AmmunitionCart,kmgJ,Z5nmrSn,0,dD4)self.Data.AmmunitionUnderway[r0C1]={d,10-dTa}
Logic.SetEntityInvulnerabilityFlag(d,1)Logic.SetEntitySelectableFlag(d,0)AddGood(Goods.G_Stone,(10-dTa)*
(-1),dD4)
StartSimpleJobEx(function(u)
local d=self.Data.AmmunitionUnderway[r0C1][1]
local DRoZO=self.Data.AmmunitionUnderway[r0C1][2]
if not IsExisting(d)or not IsExisting(u)then self.Data.AmmunitionUnderway[r0C1]=
nil;return true end
if not Logic.IsEntityMoving(d)then
local kmgJ,Z5nmrSn,LDRZuC=Logic.EntityGetPos(u)Logic.MoveSettler(d,kmgJ,Z5nmrSn)end;if IsNear(d,u,500)then
for Ja=1,DRoZO,1 do Logic.RefillAmmunitions(u)end;DestroyEntity(d)end end,r0C1)end
function BundleEntitySelection.Local:Install()
self:OverwriteSelectAllUnits()self:OverwriteSelectKnight()
self:OverwriteNamesAndDescription()self:OverwriteThiefDeliver()
self:OverwriteMilitaryDismount()self:OverwriteMultiselectIcon()
self:OverwriteMilitaryDisamble()self:OverwriteMilitaryErect()
self:OverwriteMilitaryCommands()self:OverwriteGetStringTableText()
Core:AppendFunction("GameCallback_GUI_SelectionChanged",self.OnSelectionCanged)end;function BundleEntitySelection.Local:DeactivateRefillTrebuchet(U9tg3LeC)
self.Data.RefillTrebuchet=not U9tg3LeC end
function BundleEntitySelection.Local.OnSelectionCanged(MPu)
local zcV={GUI.GetSelectedEntities()}local Kfe=GUI.GetPlayerID()local ifa=GUI.GetSelectedEntity()
local oE=Logic.GetEntityType(ifa)
if ifa~=nil then
if oE==Entities.U_SiegeEngineCart then
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngineCart",1)elseif oE==Entities.U_Trebuchet then
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/BGMilitary",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military",1)
if BundleEntitySelection.Local.Data.RefillTrebuchet then
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack",1)else
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack",0)end;GUI_Military.StrengthUpdate()
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/DialogButtons/SiegeEngine",1)end end end
function BundleEntitySelection.Local:OverwriteGetStringTableText()
GetStringTableText_Orig_BundleEntitySelection=XGUIEng.GetStringTableText
XGUIEng.GetStringTableText=function(mxYL)local k6k2N=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
if
mxYL=="UI_ObjectDescription/Attack"then local bgY=GUI.GetSelectedEntity()
if Logic.GetEntityType(bgY)==
Entities.U_Trebuchet then return
BundleEntitySelection.Local.Data.Tooltips.TrebuchetRefiller.Text[k6k2N]end end
if mxYL=="UI_ObjectNames/Attack"then local zCj2d=GUI.GetSelectedEntity()
if
Logic.GetEntityType(zCj2d)==Entities.U_Trebuchet then return
BundleEntitySelection.Local.Data.Tooltips.TrebuchetRefiller.Title[k6k2N]end end
return GetStringTableText_Orig_BundleEntitySelection(mxYL)end end
function BundleEntitySelection.Local:OverwriteMilitaryCommands()
GUI_Military.AttackClicked=function()
Sound.FXPlay2DSound("ui\\menu_click")local cIi2b={GUI.GetSelectedEntities()}
local D8JtB=Logic.GetEntityType(cIi2b[1])
if D8JtB==Entities.U_Trebuchet then
for QdzPj=1,#cIi2b,1 do
D8JtB=Logic.GetEntityType(cIi2b[QdzPj])
if D8JtB==Entities.U_Trebuchet then
GUI.SendScriptCommand(
[[
                        BundleEntitySelection.Global:MilitaryCallForRefiller(]]..cIi2b[QdzPj]..[[)
                    ]])end end else GUI.ActivateExplicitAttackCommandState()end end
GUI_Military.StandGroundClicked=function()
Sound.FXPlay2DSound("ui\\menu_click")local J={GUI.GetSelectedEntities()}
for _Bh=1,#J do local KO=J[_Bh]
local l0VzutJ=Logic.GetEntityType(KO)GUI.SendCommandStationaryDefend(KO)
if
l0VzutJ==Entities.U_Trebuchet then
GUI.SendScriptCommand([[
                    Logic.SetTaskList(]]..
KO..[[, TaskLists.TL_NPC_IDLE)
                ]])end end end
GUI_Military.StandGroundUpdate=function()
local Xy5="/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Attack"local DNjv9Ky={GUI.GetSelectedEntities()}
SetIcon(Xy5,{12,4})
if#DNjv9Ky==1 then local UmP3TiuM=DNjv9Ky[1]
local gYkgeX=Logic.GetEntityType(UmP3TiuM)
if gYkgeX==Entities.U_Trebuchet then if
Logic.GetAmmunitionAmount(UmP3TiuM)>0 then XGUIEng.ShowWidget(Xy5,0)else
XGUIEng.ShowWidget(Xy5,1)end
SetIcon(Xy5,{1,10})else XGUIEng.ShowWidget(Xy5,1)end end end end
function BundleEntitySelection.Local:OverwriteMilitaryErect()
GUI_Military.ErectClicked_Orig_BundleEntitySelection=GUI_Military.ErectClicked
GUI_Military.ErectClicked=function()
GUI_Military.ErectClicked_Orig_BundleEntitySelection()local OkoDYew1=GUI.GetPlayerID()
local z={GUI.GetSelectedEntities()}
for uXU8F5I=1,#z,1 do local TgkNMHt0=Logic.GetEntityType(z[uXU8F5I])
if TgkNMHt0 ==
Entities.U_SiegeEngineCart then
GUI.SendScriptCommand([[
                    BundleEntitySelection.Global:MilitaryErectTrebuchet(]]..
z[uXU8F5I]..[[)
                ]])end end end
GUI_Military.ErectUpdate_Orig_BundleEntitySelection=GUI_Military.ErectUpdate
GUI_Military.ErectUpdate=function()local xXE15kR0=XGUIEng.GetCurrentWidgetID()
local E_4i=GUI.GetSelectedEntity()local B1odRr=GUI.GetPlayerID()
local fe=Logic.GetEntityType(E_4i)
if fe==Entities.U_SiegeEngineCart then
XGUIEng.DisableButton(xXE15kR0,0)SetIcon(xXE15kR0,{12,6})else
GUI_Military.ErectUpdate_Orig_BundleEntitySelection()end end
GUI_Military.ErectMouseOver_Orig_BundleEntitySelection=GUI_Military.ErectMouseOver
GUI_Military.ErectMouseOver=function()local V1_9X_=GUI.GetSelectedEntity()local zP
if
Logic.GetEntityType(V1_9X_)==Entities.U_SiegeEngineCart then zP="ErectCatapult"else
GUI_Military.ErectMouseOver_Orig_BundleEntitySelection()return end;GUI_Tooltip.TooltipNormal(zP,"Erect")end end
function BundleEntitySelection.Local:OverwriteMilitaryDisamble()
GUI_Military.DisassembleClicked_Orig_BundleEntitySelection=GUI_Military.DisassembleClicked
GUI_Military.DisassembleClicked=function()
GUI_Military.DisassembleClicked_Orig_BundleEntitySelection()local c=GUI.GetPlayerID()
local RPRi={GUI.GetSelectedEntities()}
for iwACPW4_=1,#RPRi,1 do local ThG=Logic.GetEntityType(RPRi[iwACPW4_])
if ThG==
Entities.U_Trebuchet then
GUI.SendScriptCommand([[
                    BundleEntitySelection.Global:MilitaryDisambleTrebuchet(]]..
RPRi[iwACPW4_]..[[)
                ]])end end end
GUI_Military.DisassembleUpdate_Orig_BundleEntitySelection=GUI_Military.DisassembleUpdate
GUI_Military.DisassembleUpdate=function()local s=XGUIEng.GetCurrentWidgetID()
local m380zm=GUI.GetPlayerID()local DzC7FyQx=GUI.GetSelectedEntity()
local ISZGXXOA=Logic.GetEntityType(DzC7FyQx)if ISZGXXOA==Entities.U_Trebuchet then XGUIEng.DisableButton(s,0)
SetIcon(s,{12,9})else
GUI_Military.DisassembleUpdate_Orig_BundleEntitySelection()end end end
function BundleEntitySelection.Local:OverwriteMultiselectIcon()
GUI_MultiSelection.IconUpdate_Orig_BundleEntitySelection=GUI_MultiSelection.IconUpdate
GUI_MultiSelection.IconUpdate=function()local CbgC1=XGUIEng.GetCurrentWidgetID()
local u=XGUIEng.GetWidgetsMotherID(CbgC1)local jQeNH=XGUIEng.GetWidgetNameByID(u)local K=jQeNH+0
local yZY=XGUIEng.GetWidgetPathByID(u)local G=yZY.."/Health"
local SG=g_MultiSelection.EntityList[K]local wp1o=Logic.GetEntityType(SG)
local jRu=Logic.GetEntityHealth(SG)local cVyN=Logic.GetEntityMaxHealth(SG)if
wp1o~=Entities.U_SiegeEngineCart and wp1o~=Entities.U_Trebuchet then
GUI_MultiSelection.IconUpdate_Orig_BundleEntitySelection()return end;if
Logic.IsEntityAlive(SG)==false then XGUIEng.ShowWidget(u,0)
GUI_MultiSelection.CreateEX()return end
SetIcon(CbgC1,g_TexturePositions.Entities[wp1o])jRu=math.floor(jRu/cVyN*100)
if jRu<50 then local T=math.floor(2*255*
(jRu/100))
XGUIEng.SetMaterialColor(G,0,255,T,20,255)else
local Xeg2p=2*255-math.floor(2*255* (jRu/100))XGUIEng.SetMaterialColor(G,0,Xeg2p,255,20,255)end;XGUIEng.SetProgressBarValues(G,jRu,100)end
GUI_MultiSelection.IconMouseOver_Orig_BundleEntitySelection=GUI_MultiSelection.IconMouseOver
GUI_MultiSelection.IconMouseOver=function()local D2=XGUIEng.GetCurrentWidgetID()
local J6il=XGUIEng.GetWidgetsMotherID(D2)local O=XGUIEng.GetWidgetNameByID(J6il)local _4iwPl=tonumber(O)
local n=g_MultiSelection.EntityList[_4iwPl]local noV=Logic.GetEntityType(n)if noV~=Entities.U_SiegeEngineCart and noV~=
Entities.U_Trebuchet then
GUI_MultiSelection.IconMouseOver_Orig_BundleEntitySelection()return end
local Cx6TN=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
if noV==Entities.U_SiegeEngineCart then
local dj7y6V=BundleEntitySelection.Local.Data.Tooltips.TrebuchetCart
BundleEntitySelection.Local:SetTooltip(dj7y6V.Title[Cx6TN],dj7y6V.Text[Cx6TN])elseif noV==Entities.U_Trebuchet then
local V6ly=BundleEntitySelection.Local.Data.Tooltips.Trebuchet
BundleEntitySelection.Local:SetTooltip(V6ly.Title[Cx6TN],V6ly.Text[Cx6TN])end end end
function BundleEntitySelection.Local:OverwriteMilitaryDismount()
GUI_Military.DismountClicked_Orig_BundleEntitySelection=GUI_Military.DismountClicked
GUI_Military.DismountClicked=function()local vMe=GUI.GetSelectedEntity(Selected)
local jWsj0=Logic.GetEntityType(vMe)local _C=GUI.GetPlayerID()
if
Logic.GetGuardianEntityID(vMe)==0 and Logic.IsKnight(vMe)==false then
if

(





jWsj0 ==
Entities.U_SiegeEngineCart or jWsj0 ==Entities.U_MilitarySiegeTower or jWsj0 ==Entities.U_MilitaryCatapult or jWsj0 ==Entities.U_MilitaryBatteringRam or jWsj0 ==Entities.U_SiegeTowerCart or jWsj0 ==Entities.U_CatapultCart or jWsj0 ==Entities.U_BatteringRamCart or jWsj0 ==Entities.U_AmmunitionCart)and BundleEntitySelection.Local.Data.SiegeEngineRelease then Sound.FXPlay2DSound("ui\\menu_click")
GUI.SendScriptCommand(
[[DestroyEntity(]]..vMe..[[)]])return end
if
(Logic.IsLeader(vMe)==1 and
BundleEntitySelection.Local.Data.MilitaryRelease)then Sound.FXPlay2DSound("ui\\menu_click")
local XYX_rOr={Logic.GetSoldiersAttachedToLeader(vMe)}
GUI.SendScriptCommand([[DestroyEntity(]]..XYX_rOr[#XYX_rOr]..[[)]])return end else
GUI_Military.DismountClicked_Orig_BundleEntitySelection()end end
GUI_Military.DismountUpdate_Orig_BundleEntitySelection=GUI_Military.DismountUpdate
GUI_Military.DismountUpdate=function()local R=XGUIEng.GetCurrentWidgetID()
local nqBeV78J=GUI.GetSelectedEntity()local Dz8=Logic.GetEntityType(nqBeV78J)
if
(

Logic.GetGuardianEntityID(nqBeV78J)==0 and Logic.IsKnight(nqBeV78J)==false and
Logic.IsEntityInCategory(nqBeV78J,EntityCategories.AttackableMerchant)==0)then
if Logic.IsLeader(nqBeV78J)==1 and not
BundleEntitySelection.Local.Data.MilitaryRelease then
XGUIEng.DisableButton(R,1)elseif Logic.IsLeader(nqBeV78J)==0 then
if not
BundleEntitySelection.Local.Data.SiegeEngineRelease then XGUIEng.DisableButton(R,1)end
if Dz8 ==Entities.U_Trebuchet then XGUIEng.DisableButton(R,1)end else SetIcon(R,{12,1})XGUIEng.DisableButton(R,0)end;SetIcon(R,{14,12})else SetIcon(R,{12,1})
GUI_Military.DismountUpdate_Orig_BundleEntitySelection()end end end
function BundleEntitySelection.Local:OverwriteThiefDeliver()
GUI_Thief.ThiefDeliverClicked_Orig_BundleEntitySelection=GUI_Thief.ThiefDeliverClicked
GUI_Thief.ThiefDeliverClicked=function()if not self.Data.ThiefRelease then
GUI_Thief.ThiefDeliverClicked_Orig_BundleEntitySelection()return end
Sound.FXPlay2DSound("ui\\menu_click")local bfoxga=GUI.GetPlayerID()local R=GUI.GetSelectedEntity()if

R==nil or Logic.GetEntityType(R)~=Entities.U_Thief then return end
GUI.SendScriptCommand([[DestroyEntity(]]..R..[[)]])end
GUI_Thief.ThiefDeliverMouseOver_Orig_BundleEntitySelection=GUI_Thief.ThiefDeliverMouseOver
GUI_Thief.ThiefDeliverMouseOver=function()
if not
BundleEntitySelection.Local.Data.ThiefRelease then local Jtbsp=XGUIEng.GetCurrentWidgetID()
GUI_Thief.ThiefDeliverMouseOver_Orig_BundleEntitySelection()return end;local MV=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
BundleEntitySelection.Local:SetTooltip(BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Title[MV],BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Text[MV],BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Disabled[MV])end
GUI_Thief.ThiefDeliverUpdate_Orig_BundleEntitySelection=GUI_Thief.ThiefDeliverUpdate
GUI_Thief.ThiefDeliverUpdate=function()
if not
BundleEntitySelection.Local.Data.ThiefRelease then
GUI_Thief.ThiefDeliverUpdate_Orig_BundleEntitySelection()else local h9IOXT=XGUIEng.GetCurrentWidgetID()
local TZeZK=GUI.GetSelectedEntity()if
TZeZK==nil or Logic.GetEntityType(TZeZK)~=Entities.U_Thief then XGUIEng.DisableButton(h9IOXT,1)else
XGUIEng.DisableButton(h9IOXT,0)end
SetIcon(h9IOXT,{14,12})end end end
function BundleEntitySelection.Local:OverwriteNamesAndDescription()
GUI_Tooltip.SetNameAndDescription_Orig_QSB_EntitySelection=GUI_Tooltip.SetNameAndDescription
GUI_Tooltip.SetNameAndDescription=function(X,bblh2jUQ,mjrD,J,bQRIXOF6)local BHzRZg=XGUIEng.GetCurrentWidgetID()
local _=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
if
XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/KnightButton")==BHzRZg then
BundleEntitySelection.Local:SetTooltip(BundleEntitySelection.Local.Data.Tooltips.KnightButton.Title[_],BundleEntitySelection.Local.Data.Tooltips.KnightButton.Text[_])return end
if
XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/MapFrame/BattalionButton")==BHzRZg then
BundleEntitySelection.Local:SetTooltip(BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Title[_],BundleEntitySelection.Local.Data.Tooltips.BattalionButton.Text[_])return end
if
XGUIEng.GetWidgetID("/InGame/Root/Normal/AlignBottomRight/DialogButtons/Military/Dismount")==BHzRZg then
local S8_x8n=GUI.GetSelectedEntity()
if S8_x8n~=0 then
if








Logic.IsEntityInCategory(S8_x8n,EntityCategories.Leader)==1 or
Logic.IsEntityInCategory(S8_x8n,EntityCategories.Thief)==1 or
Logic.GetEntityType(S8_x8n)==Entities.U_MilitaryCatapult or
Logic.GetEntityType(S8_x8n)==Entities.U_MilitarySiegeTower or
Logic.GetEntityType(S8_x8n)==Entities.U_MilitaryBatteringRam or Logic.GetEntityType(S8_x8n)==Entities.U_CatapultCart or Logic.GetEntityType(S8_x8n)==Entities.U_SiegeTowerCart or Logic.GetEntityType(S8_x8n)==Entities.U_BatteringRamCart or Logic.GetEntityType(S8_x8n)==Entities.U_SiegeEngineCart or Logic.GetEntityType(S8_x8n)==Entities.U_Trebuchet then local OJV3L=Logic.GetGuardianEntityID(S8_x8n)
if OJV3L==0 then
BundleEntitySelection.Local:SetTooltip(BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Title[_],BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Text[_],BundleEntitySelection.Local.Data.Tooltips.ReleaseSoldiers.Disabled[_])return end end end end
GUI_Tooltip.SetNameAndDescription_Orig_QSB_EntitySelection(X,bblh2jUQ,mjrD,J,bQRIXOF6)end end
function BundleEntitySelection.Local:SetTooltip(HLV0hyF,r3ng7UL6,ApPCL)
local Ye="/InGame/Root/Normal/TooltipNormal"local lmpa=XGUIEng.GetWidgetID(Ye)
local U0tw=XGUIEng.GetWidgetID(Ye.."/FadeIn/Name")
local ugS5u9oe=XGUIEng.GetWidgetID(Ye.."/FadeIn/Text")local RNJV7Ms=XGUIEng.GetCurrentWidgetID()ApPCL=ApPCL or""
local FmaDG=""
if
XGUIEng.IsButtonDisabled(RNJV7Ms)==1 and _disabledText~=""and _text~=""then FmaDG=FmaDG..
"{cr}{@color:255,32,32,255}"..ApPCL end;XGUIEng.SetText(U0tw,"{center}"..HLV0hyF)XGUIEng.SetText(ugS5u9oe,
r3ng7UL6 ..FmaDG)
local w6gF6Ig=XGUIEng.GetTextHeight(ugS5u9oe,true)local e,H0msoK=XGUIEng.GetWidgetSize(ugS5u9oe)
XGUIEng.SetWidgetSize(ugS5u9oe,e,w6gF6Ig)end
function BundleEntitySelection.Local:OverwriteSelectKnight()
GUI_Knight.JumpToButtonClicked=function()
local gfWc=GUI.GetPlayerID()local uw26=Logic.GetKnightID(gfWc)
if uw26 >0 then
g_MultiSelection.EntityList={}g_MultiSelection.Highlighted={}GUI.ClearSelection()
if
XGUIEng.IsModifierPressed(Keys.ModifierControl)then local GIyY3={}Logic.GetKnights(gfWc,GIyY3)for VYC1x3=1,#GIyY3 do
GUI.SelectEntity(GIyY3[VYC1x3])end else
GUI.SelectEntity(Logic.GetKnightID(gfWc))
if
(
(Framework.GetTimeMs()-g_Selection.LastClickTime)<g_Selection.MaxDoubleClickTime)then local b=GetPosition(uw26)
Camera.RTS_SetLookAtPosition(b.X,b.Y)else Sound.FXPlay2DSound("ui\\mini_knight")end;g_Selection.LastClickTime=Framework.GetTimeMs()end
GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User)else GUI.AddNote("Debug: You do not have a knight")end end end
function BundleEntitySelection.Local:OverwriteSelectAllUnits()
GUI_MultiSelection.SelectAllPlayerUnitsClicked=function()
if
XGUIEng.IsModifierPressed(Keys.ModifierShift)then
BundleEntitySelection.Local:ExtendedLeaderSortOrder()else
BundleEntitySelection.Local:NormalLeaderSortOrder()end;Sound.FXPlay2DSound("ui\\menu_click")
GUI.ClearSelection()local u_LrUR3v=GUI.GetPlayerID()
for Ko_5wHh=1,#LeaderSortOrder do
local erJtM=GetPlayerEntities(u_LrUR3v,LeaderSortOrder[Ko_5wHh])for H=1,#erJtM do GUI.SelectEntity(erJtM[H])end end;local TNyTHq={}Logic.GetKnights(u_LrUR3v,TNyTHq)for KN=1,#TNyTHq do
GUI.SelectEntity(TNyTHq[KN])end
GUI_MultiSelection.CreateMultiSelection(g_SelectionChangedSource.User)end end
function BundleEntitySelection.Local:NormalLeaderSortOrder()g_MultiSelection={}
g_MultiSelection.EntityList={}g_MultiSelection.Highlighted={}LeaderSortOrder={}
LeaderSortOrder[1]=Entities.U_MilitarySword;LeaderSortOrder[2]=Entities.U_MilitaryBow
LeaderSortOrder[3]=Entities.U_MilitarySword_RedPrince;LeaderSortOrder[4]=Entities.U_MilitaryBow_RedPrince
LeaderSortOrder[5]=Entities.U_MilitaryBandit_Melee_ME;LeaderSortOrder[6]=Entities.U_MilitaryBandit_Melee_NA
LeaderSortOrder[7]=Entities.U_MilitaryBandit_Melee_NE;LeaderSortOrder[8]=Entities.U_MilitaryBandit_Melee_SE
LeaderSortOrder[9]=Entities.U_MilitaryBandit_Ranged_ME;LeaderSortOrder[10]=Entities.U_MilitaryBandit_Ranged_NA
LeaderSortOrder[11]=Entities.U_MilitaryBandit_Ranged_NE;LeaderSortOrder[12]=Entities.U_MilitaryBandit_Ranged_SE
LeaderSortOrder[13]=Entities.U_MilitaryCatapult;LeaderSortOrder[14]=Entities.U_MilitarySiegeTower
LeaderSortOrder[15]=Entities.U_MilitaryBatteringRam;LeaderSortOrder[16]=Entities.U_CatapultCart
LeaderSortOrder[17]=Entities.U_SiegeTowerCart;LeaderSortOrder[18]=Entities.U_BatteringRamCart
LeaderSortOrder[19]=Entities.U_Thief
if g_GameExtraNo>=1 then
table.insert(LeaderSortOrder,4,Entities.U_MilitarySword_Khana)
table.insert(LeaderSortOrder,6,Entities.U_MilitaryBow_Khana)
table.insert(LeaderSortOrder,7,Entities.U_MilitaryBandit_Melee_AS)
table.insert(LeaderSortOrder,12,Entities.U_MilitaryBandit_Ranged_AS)end end
function BundleEntitySelection.Local:ExtendedLeaderSortOrder()g_MultiSelection={}
g_MultiSelection.EntityList={}g_MultiSelection.Highlighted={}LeaderSortOrder={}
LeaderSortOrder[1]=Entities.U_MilitarySword;LeaderSortOrder[2]=Entities.U_MilitaryBow
LeaderSortOrder[3]=Entities.U_MilitarySword_RedPrince;LeaderSortOrder[4]=Entities.U_MilitaryBow_RedPrince
LeaderSortOrder[5]=Entities.U_MilitaryBandit_Melee_ME;LeaderSortOrder[6]=Entities.U_MilitaryBandit_Melee_NA
LeaderSortOrder[7]=Entities.U_MilitaryBandit_Melee_NE;LeaderSortOrder[8]=Entities.U_MilitaryBandit_Melee_SE
LeaderSortOrder[9]=Entities.U_MilitaryBandit_Ranged_ME;LeaderSortOrder[10]=Entities.U_MilitaryBandit_Ranged_NA
LeaderSortOrder[11]=Entities.U_MilitaryBandit_Ranged_NE;LeaderSortOrder[12]=Entities.U_MilitaryBandit_Ranged_SE
LeaderSortOrder[13]=Entities.U_MilitaryCatapult;LeaderSortOrder[14]=Entities.U_Trebuchet
LeaderSortOrder[15]=Entities.U_MilitarySiegeTower;LeaderSortOrder[16]=Entities.U_MilitaryBatteringRam
LeaderSortOrder[17]=Entities.U_CatapultCart;LeaderSortOrder[18]=Entities.U_SiegeTowerCart
LeaderSortOrder[19]=Entities.U_BatteringRamCart;LeaderSortOrder[20]=Entities.U_AmmunitionCart
LeaderSortOrder[21]=Entities.U_Thief
if g_GameExtraNo>=1 then
table.insert(LeaderSortOrder,4,Entities.U_MilitarySword_Khana)
table.insert(LeaderSortOrder,6,Entities.U_MilitaryBow_Khana)
table.insert(LeaderSortOrder,7,Entities.U_MilitaryBandit_Melee_AS)
table.insert(LeaderSortOrder,12,Entities.U_MilitaryBandit_Ranged_AS)end end;Core:RegisterBundle("BundleEntitySelection")
API=API or{}QSB=QSB or{}
function API.AutoSaveGame(de)assert(de)if not GUI then
API.Bridge('API.AutoSaveGame("'..de..'")')return end
BundleSaveGameTools.Local:AutoSaveGame(de)end
function API.SaveGameToFolder(l,wMW)assert(l)assert(wMW)if not GUI then
API.Bridge('API.SaveGameToFolder("'..l..
'", "'..wMW..'")')return end
BundleSaveGameTools.Local:SaveGameToFolder(l,wMW)end
function API.LoadGameFromFolder(Zeat0o,XbW8,XG24)assert(Zeat0o)assert(XbW8)assert(XG24)if not GUI then
API.Bridge(
'API.LoadGameFromFolder("'..
Zeat0o..'", "'..XbW8 ..'", "'..XG24 ..'")')return end
BundleSaveGameTools.Local:LoadGameFromFolder(Zeat0o,XbW8,XG24)end
function API.StartMap(eGdCE5nz,bWC,LQnI,Mf2Ge3D)assert(eGdCE5nz)assert(bWC)assert(LQnI)
assert(Mf2Ge3D)if not GUI then
API.Bridge('API.StartMap("'..
eGdCE5nz..'", "'..bWC..
'", "'..Mf2Ge3D..'", "'..Mf2Ge3D..'")')return end
BundleSaveGameTools.Local:LoadGameFromFolder(eGdCE5nz,bWC,LQnI,Mf2Ge3D)end
BundleSaveGameTools={Global={Data={}},Local={Data={AutoSaveCounter=0}}}function BundleSaveGameTools.Global:Install()end;function BundleSaveGameTools.Local:Install()
end
function BundleSaveGameTools.Local:AutoSaveGame(aqsK)aqsK=aqsK or
Framework.GetCurrentMapName()local nuh0oo=
BundleSaveGameTools.Local.Data.AutoSaveCounter+1
BundleSaveGameTools.Local.Data.AutoSaveCounter=nuh0oo;local dtI=Network.GetDesiredLanguage()
if dtI~="de"then dtI="en"end
local Jra_K_Z=(dtI=="de"and"Spiel wird gespeichert...")or"Saving game..."
if self:CanGameBeSaved()then
OpenDialog(Jra_K_Z,XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"))XGUIEng.ShowWidget("/InGame/Dialog/Ok",0)
Framework.SaveGame(
"Autosave "..nuh0oo.." --- "..aqsK,"--")else
StartSimpleJobEx(function()
if BundleSaveGameTools.Local:CanGameBeSaved()then
OpenDialog(Jra_K_Z,XGUIEng.GetStringTableText("UI_Texts/MainMenuSaveGame_center"))XGUIEng.ShowWidget("/InGame/Dialog/Ok",0)
Framework.SaveGame(
"Autosave - "..nuh0oo.." --- "..aqsK,"--")return true end end)end end
function BundleSaveGameTools.Local:CanGameBeSaved()
if BundleGameHelperFunctions and
BundleGameHelperFunctions.Local.Data.ForbidSave then return false end
if IsBriefingActive and IsBriefingActive()then return false end;if
XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen")~=0 then return false end;return true end;function BundleSaveGameTools.Local:SaveGameToFolder(RAL7,Evw6)Evw6=Evw6 or
Framework.GetCurrentMapName()
Framework.SaveGame(RAL7 .."/"..Evw6,"--")end
function BundleSaveGameTools.Local:LoadGameFromFolder(N3IGyI,f,v)v=
v or 0;assert(type(f)=="string")local e=N3IGyI.."/"..f..
GetSaveGameExtension()
local ZyT,P5t1NfP,KgUPpp=Framework.GetSaveGameMapNameAndTypeAndCampaign(e)InitLoadScreen(false,P5t1NfP,ZyT,KgUPpp,0)
Framework.ResetProgressBar()Framework.SetLoadScreenNeedButton(v)
Framework.LoadGame(e)end
function BundleSaveGameTools.Local:LoadGameFromFolder(zsY7,dQa6icK,cVT,Wp3)Wp3=Wp3 or 1
dQa6icK=dQa6icK or 0;cVT=cVT or 3
local oW,_dUUGf9d,L,i6=Framework.GetMapNameAndDescription(zsY7,cVT)
if oW~=nil and oW~=""then
XGUIEng.ShowAllSubWidgets("/InGame",0)Framework.SetLoadScreenNeedButton(Wp3)
InitLoadScreen(false,cVT,zsY7,0,dQa6icK)Framework.ResetProgressBar()
Framework.StartMap(zsY7,cVT,dQa6icK)else GUI.AddNote("ERROR: invalid mapfile!")end end;Core:RegisterBundle("BundleSaveGameTools")
API=API or{}QSB=QSB or{}
function API.GetEntitiesOfCategoriesInTerritories(i1AjOR2,q5,gbq6mM)return
BundleEntityHelperFunctions:GetEntitiesOfCategoriesInTerritories(i1AjOR2,q5,gbq6mM)end
GetEntitiesOfCategoriesInTerritories=API.GetEntitiesOfCategoriesInTerritories
function API.GetEntitiesByPrefix(xy9z)return
BundleEntityHelperFunctions:GetEntitiesByPrefix(xy9z)end;GetEntitiesNamedWith=API.GetEntitiesByPrefix
function API.SetResourceAmount(ONuQWd7g,emP73Ww,QDazjhiW)
if GUI then local q=(type(ONuQWd7g)~=
"string"and ONuQWd7g)or
"'"..ONuQWd7g.."'"
API.Bridge(
"API.SetResourceAmount("..
q..", "..emP73Ww..", "..QDazjhiW..")")return end
if not IsExisting(ONuQWd7g)then
local wxsw=
(type(ONuQWd7g)~="string"and ONuQWd7g)or"'"..ONuQWd7g.."'"
API.Dbg("API.SetResourceAmount: Entity "..wxsw.." does not exist!")return end;return
BundleEntityHelperFunctions.Global:SetResourceAmount(ONuQWd7g,emP73Ww,QDazjhiW)end;SetResourceAmount=API.SetResourceAmount
function API.GetRelativePos(Ue,INnqSjpO,Mptuc,AV)
if
not API.ValidatePosition(Ue)then if not IsExisting(Ue)then
API.Dbg("API.GetRelativePos: Target is invalid!")return end end
return BundleEntityHelperFunctions:GetRelativePos(Ue,INnqSjpO,Mptuc,AV)end;GetRelativePos=API.GetRelativePos
function API.SetPosition(sNCn4mi,yfn)
if GUI then
local paJ9=(type(sNCn4mi)~="string"and
sNCn4mi)or"'"..sNCn4mi.."'"local AxNEUFn=yfn;if type(AxNEUFn)=="table"then
AxNEUFn="{X= "..tostring(AxNEUFn.X)..", Y= "..
tostring(AxNEUFn.Y).."}"end
API.Bridge("API.SetPosition("..paJ9 ..", "..AxNEUFn..
")")return end
if not IsExisting(sNCn4mi)then
local MjNBO=
(type(sNCn4mi)~="string"and sNCn4mi)or"'"..sNCn4mi.."'"
API.Dbg("API.SetPosition: Entity "..MjNBO.." does not exist!")return end;local ksUkULF=API.LocateEntity(yfn)if
not API.ValidatePosition(ksUkULF)then API.Dbg("API.SetPosition: Position is invalid!")
return end;return
BundleEntityHelperFunctions.Global:SetPosition(sNCn4mi,ksUkULF)end;SetPosition=API.SetPosition
function API.MoveToPosition(_nbCjt,Bk,jJPO,e,K2a)if GUI then
API.Bridge("API.MoveToPosition("..GetID(_nbCjt)..
", "..
GetID(Bk)..", "..
jJPO..", "..e..", "..tostring(K2a)..")")return end
if not
IsExisting(_nbCjt)then
local Z6Awtv_1=(type(_nbCjt)~="string"and _nbCjt)or"'"..
_nbCjt.."'"
API.Dbg("API.MoveToPosition: Entity "..Z6Awtv_1 .." does not exist!")return end
if not IsExisting(Bk)then local vtak_XT=(type(Bk)~="string"and Bk)or"'"..
Bk.."'"
API.Dbg("API.MoveToPosition: Entity "..
vtak_XT.." does not exist!")return end;return
BundleEntityHelperFunctions.Global:MoveToPosition(_nbCjt,Bk,jJPO,e,K2a)end;MoveEx=API.MoveToPosition
function API.PlaceToPosition(Gd076,I,NMn,U)if GUI then
API.Bridge("API.PlaceToPosition("..
GetID(Gd076)..", "..
GetID(I)..", "..NMn..", "..U..")")return end
if not
IsExisting(Gd076)then local Eii=(type(Gd076)~="string"and Gd076)or"'"..
Gd076 .."'"
API.Dbg(
"API.PlaceToPosition: Entity "..Eii.." does not exist!")return end
if not IsExisting(I)then
local YNW=(type(I)~="string"and I)or"'"..I.."'"
API.Dbg("API.PlaceToPosition: Entity "..YNW.." does not exist!")return end;local O=API.GetRelativePos(I,NMn,U,true)
API.SetPosition(Gd076,O)end;SetPositionEx=API.PlaceToPosition
function API.GiveEntityName(OxvsR18)if IsExisting(_name)then
API.Dbg("API.GiveEntityName: Entity does not exist!")return end;if GUI then
API.Bridge("API.GiveEntityName("..
GetID(OxvsR18)..")")return end;return
BundleEntityHelperFunctions.Global:GiveEntityName(OxvsR18)end;GiveEntityName=API.GiveEntityName
function API.GetEntityName(t8iwY)
if not IsExisting(t8iwY)then
local uVQatO2p=(
type(t8iwY)~="string"and t8iwY)or"'"..t8iwY.."'"
API.Warn("API.GetEntityName: Entity "..uVQatO2p.." does not exist!")return nil end;return Logic.GetEntityName(GetID(t8iwY))end;GetEntityName=API.GetEntityName
function API.SetEntityName(PY,kwY)if GUI then
API.Bridge("API.SetEntityName("..GetID(_EntityID)..
", '"..kwY.."')")return end;if IsExisting(kwY)then
API.Dbg(
"API.SetEntityName: Entity '"..kwY.."' already exists!")return end;return
Logic.SetEntityName(GetID(PY),kwY)end;SetEntityName=API.SetEntityName
function API.SetOrientation(K7RBg,Yj)if GUI then
API.Bridge("API.SetOrientation("..GetID(K7RBg)..", "..Yj..
")")return end
if not IsExisting(K7RBg)then
local lpFAf_=(
type(K7RBg)~="string"and K7RBg)or"'"..K7RBg.."'"
API.Dbg("API.SetOrientation: Entity "..lpFAf_.." does not exist!")return end;return Logic.SetOrientation(GetID(K7RBg),Yj)end;SetOrientation=API.SetOrientation
function API.GetOrientation(R)
if not IsExisting(R)then
local at8fRO1=(
type(R)~="string"and R)or"'"..R.."'"
API.Warn("API.GetOrientation: Entity "..at8fRO1 .." does not exist!")return 0 end;return Logic.GetEntityOrientation(GetID(R))end;GetOrientation=API.GetOrientation
function API.EntityAttack(IAl6tS3,eigcO)if GUI then
API.Bridge("API.EntityAttack("..GetID(IAl6tS3)..
", "..GetID(eigcO)..")")return end
if
not IsExisting(IAl6tS3)then local Kaog=
(type(IAl6tS3)=="string"and"'"..IAl6tS3 .."'")or IAl6tS3
API.Dbg(
"API.EntityAttack: Entity "..Kaog.." does not exist!")return end
if not IsExisting(eigcO)then local ZaBF=
(type(eigcO)=="string"and"'"..eigcO.."'")or eigcO
API.Dbg(
"API.EntityAttack: Target "..ZaBF.." does not exist!")return end;return
BundleEntityHelperFunctions.Global:Attack(IAl6tS3,eigcO)end;Attack=API.EntityAttack
function API.EntityAttackMove(qSP6XQR,Og)if GUI then
API.Dbg("API.EntityAttackMove: Cannot be used from local script!")return end
if
not IsExisting(qSP6XQR)then local ag=
(type(qSP6XQR)=="string"and"'"..qSP6XQR.."'")or qSP6XQR
API.Dbg(
"API.EntityAttackMove: Entity "..ag.." does not exist!")return end;local Ym9SBy=API.LocateEntity(Og)if
not API.ValidatePosition(Ym9SBy)then
API.Dbg("API.EntityAttackMove: Position is invalid!")return end;return
BundleEntityHelperFunctions.Global:AttackMove(qSP6XQR,Ym9SBy)end;AttackMove=API.EntityAttackMove
function API.EntityMove(OCzHa,TYZe7yj2)if GUI then
API.Dbg("API.EntityMove: Cannot be used from local script!")return end
if not IsExisting(OCzHa)then local TNRh=(
type(OCzHa)=="string"and"'"..OCzHa.."'")or
OCzHa
API.Dbg("API.EntityMove: Entity "..TNRh..
" does not exist!")return end;local s60bp=API.LocateEntity(TYZe7yj2)
if
not API.ValidatePosition(s60bp)then API.Dbg("API.EntityMove: Position is invalid!")return end;return
BundleEntityHelperFunctions.Global:Move(OCzHa,s60bp)end;Move=API.EntityMove
function API.GetLeaderBySoldier(gr5Dh)
if not IsExisting(gr5Dh)then
local wVvHw=(
type(gr5Dh)=="string"and"'"..gr5Dh.."'")or _Entity
API.Dbg("API.GetLeaderBySoldier: Entity "..wVvHw.." does not exist!")return end
return Logic.SoldierGetLeaderEntityID(GetID(gr5Dh))end;GetLeaderBySoldier=API.GetLeaderBySoldier
function API.GetNearestKnight(jcS,Gb)local I={}
Logic.GetKnights(Gb,I)return API.GetNearestEntity(jcS,I)end;GetClosestKnight=API.GetNearestKnight
function API.GetNearestEntity(C,Eh)
if not IsExisting(C)then return end;if#Eh==0 then
API.Dbg("API.GetNearestEntity: The target list is empty!")return end
for IWDJnc=1,#Eh,1 do if
not IsExisting(Eh[IWDJnc])then
API.Dbg("API.GetNearestEntity: At least one target entity is dead!")return end end
return BundleEntityHelperFunctions:GetNearestEntity(C,Eh)end;GetClosestEntity=API.GetNearestEntity
BundleEntityHelperFunctions={Global={Data={RefillAmounts={}}},Local={Data={}}}function BundleEntityHelperFunctions.Global:Install()
BundleEntityHelperFunctions.Global:OverwriteGeologistRefill()end
function BundleEntityHelperFunctions.Global:OverwriteGeologistRefill()
if
Framework.GetGameExtraNo()>=1 then
GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1=GameCallback_OnGeologistRefill
GameCallback_OnGeologistRefill=function(j7VGta,_PzE54,Jd)
GameCallback_OnGeologistRefill_Orig_QSBPlusComforts1(j7VGta,_PzE54,Jd)
if
BundleEntityHelperFunctions.Global.Data.RefillAmounts[_PzE54]then
local BY=BundleEntityHelperFunctions.Global.Data.RefillAmounts[_PzE54]
local qKO=BY+math.random(1,math.floor((BY*0.2)+0.5))Logic.SetResourceDoodadGoodAmount(_PzE54,qKO)end end end end
function BundleEntityHelperFunctions.Global:SetResourceAmount(CAkS9C5d,H4v,_yPjiRy_)
assert(type(H4v)=="number")assert(type(_yPjiRy_)=="number")
local AK=GetID(CAkS9C5d)
if not IsExisting(AK)or
Logic.GetResourceDoodadGoodType(AK)==0 then
API.Dbg("SetResourceAmount: Resource entity is invalid!")return false end;if Logic.GetResourceDoodadGoodAmount(AK)==0 then
AK=ReplaceEntity(AK,Logic.GetEntityType(AK))end
Logic.SetResourceDoodadGoodAmount(AK,H4v)
if _yPjiRy_ then self.Data.RefillAmounts[AK]=_yPjiRy_ end;return true end
function BundleEntityHelperFunctions.Global:SetPosition(Cbd,rTrYdgRW)if
not IsExisting(Cbd)then return end;local rZ_gY_=GetEntityId(Cbd)
Logic.DEBUG_SetSettlerPosition(rZ_gY_,rTrYdgRW.X,rTrYdgRW.Y)
if Logic.IsLeader(rZ_gY_)==1 then
local e9OUW={Logic.GetSoldiersAttachedToLeader(rZ_gY_)}
if e9OUW[1]>0 then for oF_GhUWZ=1,#e9OUW do
Logic.DEBUG_SetSettlerPosition(e9OUW[oF_GhUWZ],rTrYdgRW.X,rTrYdgRW.Y)end end end end
function BundleEntityHelperFunctions.Global:MoveToPosition(oNOERbUT,LBSrrQQ,EPP0nUFh,KzCPNLi,wkL)if
not IsExisting(oNOERbUT)then return end;if not EPP0nUFh then EPP0nUFh=0 end
local VgHEmz=GetID(oNOERbUT)local qxin3db=GetID(LBSrrQQ)
local lQZU1Ee=GetRelativePos(LBSrrQQ,EPP0nUFh)if type(KzCPNLi)=="number"then
lQZU1Ee=BundleEntityHelperFunctions:GetRelativePos(LBSrrQQ,EPP0nUFh,KzCPNLi)end
if wkL then
Logic.MoveEntity(VgHEmz,lQZU1Ee.X,lQZU1Ee.Y)else Logic.MoveSettler(VgHEmz,lQZU1Ee.X,lQZU1Ee.Y)end
StartSimpleJobEx(function(Qxo7,RH)if not Logic.IsEntityMoving(Qxo7)then LookAt(Qxo7,RH)
return true end end,VgHEmz,qxin3db)end
function BundleEntityHelperFunctions.Global:GiveEntityName(M3x_srX)
if
type(M3x_srX)=="string"then return M3x_srX else assert(type(M3x_srX)=="number")
local w1=Logic.GetEntityName(M3x_srX)
if(type(w1)~="string"or w1 =="")then
QSB.GiveEntityNameCounter=(
QSB.GiveEntityNameCounter or 0)+1
w1="GiveEntityName_Entity_"..QSB.GiveEntityNameCounter;Logic.SetEntityName(M3x_srX,w1)end;return w1 end end
function BundleEntityHelperFunctions.Global:Attack(J,e)local gIT=GetID(J)
local VI39ihit=GetID(e)Logic.GroupAttack(gIT,VI39ihit)end
function BundleEntityHelperFunctions.Global:AttackMove(lzSek5,GBk)
local seOf0=GetID(lzSek5)Logic.GroupAttackMove(seOf0,GBk.X,GBk.Y)end;function BundleEntityHelperFunctions.Global:Move(DZVy,jjh)local JH=GetID(DZVy)
Logic.MoveSettler(JH,jjh.X,jjh.Y)end;function BundleEntityHelperFunctions.Local:Install()
end
function BundleEntityHelperFunctions:GetEntitiesOfCategoriesInTerritories(a7yVI7,n,DM_)
local RLDfKwYl=(
type(a7yVI7)=="table"and a7yVI7)or{a7yVI7}
local fXIF7=(type(n)=="table"and n)or{n}
local VSH=(type(DM_)=="table"and DM_)or{DM_}local _c={}
for LaZ=1,#RLDfKwYl,1 do
for GlscgdR1=1,#fXIF7,1 do
for KLM=1,#VSH,1 do
local v=API.GetEntitiesOfCategoryInTerritory(RLDfKwYl[LaZ],fXIF7[GlscgdR1],VSH[KLM])_c=Array_Append(_c,v)end end end;return _c end
function BundleEntityHelperFunctions:GetEntitiesByPrefix(_S)local Aj={}local t2p=1;local M6xZH=true;while M6xZH do
local Wm=GetID(_S..t2p)if Wm~=0 then table.insert(Aj,Wm)else M6xZH=false end
t2p=t2p+1 end;return Aj end
function BundleEntityHelperFunctions:GetRelativePos(keNEZzBk,UdO,wCsr5EX,M6NKH)
if not type(keNEZzBk)=="table"and not
IsExisting(keNEZzBk)then return end;if wCsr5EX==nil then wCsr5EX=0 end;local ite
if type(keNEZzBk)=="table"then
local Q4Mi=keNEZzBk;local S=0+wCsr5EX
ite={X=Q4Mi.X+UdO*math.cos(math.rad(S)),Y=
Q4Mi.Y+UdO*math.sin(math.rad(S))}else local cHSrNsX=GetID(keNEZzBk)local jnhq=GetPosition(cHSrNsX)local U=
Logic.GetEntityOrientation(cHSrNsX)+wCsr5EX
if
Logic.IsBuilding(cHSrNsX)==1 and not M6NKH then
x,y=Logic.GetBuildingApproachPosition(cHSrNsX)jnhq={X=x,Y=y}U=U-90 end
ite={X=jnhq.X+UdO*math.cos(math.rad(U)),Y=jnhq.Y+UdO*
math.sin(math.rad(U))}end;return ite end
function BundleEntityHelperFunctions:GetNearestEntity(n,qZ)local IbliJ=Logic.WorldGetSize()
local MbsRstZ2=nil;for npLq7Y=1,#qZ do
local EFP=Logic.GetDistanceBetweenEntities(qZ[npLq7Y],n)
if EFP<IbliJ and qZ[npLq7Y]~=n then IbliJ=EFP;MbsRstZ2=qZ[npLq7Y]end end;return
MbsRstZ2 end
Core:RegisterBundle("BundleEntityHelperFunctions")API=API or{}QSB=QSB or{}
function API.UndiscoverTerritory(Jfo,tTVBjj1)if GUI then
API.Bridge("API.UndiscoverTerritory("..Jfo..", "..
tTVBjj1 ..")")return end;return
BundleGameHelperFunctions.Global:UndiscoverTerritory(Jfo,tTVBjj1)end;UndiscoverTerritory=API.UndiscoverTerritory
function API.UndiscoverTerritories(eokY,W80juLWr)if GUI then
API.Bridge(
"API.UndiscoverTerritories("..eokY..", "..W80juLWr..")")return end;return
BundleGameHelperFunctions.Global:UndiscoverTerritories(eokY,W80juLWr)end;UndiscoverTerritories=API.UndiscoverTerritories
function API.SetNeedSatisfaction(Z,aGP23,kdvb)if GUI then
API.Bridge(
"API.SetNeedSatisfaction("..Z..", "..aGP23 ..", "..kdvb..")")return end;return
BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(Z,aGP23,kdvb)end;SetNeedSatisfactionLevel=API.SetNeedSatisfaction
function API.UnlockTitleForPlayer(EM45,du4t)if GUI then
API.Bridge(
"API.UnlockTitleForPlayer("..EM45 ..", "..du4t..")")return end;return
BundleGameHelperFunctions.Global:UnlockTitleForPlayer(EM45,du4t)end;UnlockTitleForPlayer=API.UnlockTitleForPlayer
function API.FocusCameraOnKnight(VtEBvR_,Id,jmk)if not GUI then
API.Bridge(
"API.SetCameraToPlayerKnight("..VtEBvR_..", "..Id..", "..jmk..")")return end;return
BundleGameHelperFunctions.Local:SetCameraToPlayerKnight(VtEBvR_,Id,jmk)end;SetCameraToPlayerKnight=API.FocusCameraOnKnight
function API.FocusCameraOnEntity(FW6Ln,mF2kWZ,YnivKpOE)
if not GUI then
local iScf5Iry=(
type(FW6Ln)~="string"and FW6Ln)or"'"..FW6Ln.."'"
API.Bridge("API.FocusCameraOnEntity("..iScf5Iry..
", "..mF2kWZ..", "..YnivKpOE..")")return end
if not IsExisting(FW6Ln)then
local ZuLLXJ8o=
(type(FW6Ln)~="string"and FW6Ln)or"'"..FW6Ln.."'"
API.Dbg("API.FocusCameraOnEntity: Entity "..ZuLLXJ8o.." does not exist!")return end;return
BundleGameHelperFunctions.Local:SetCameraToEntity(FW6Ln,mF2kWZ,YnivKpOE)end;SetCameraToEntity=API.FocusCameraOnEntity
function API.SetSpeedLimit(Ipefr)
if not GUI then API.Bridge("API.SetSpeedLimit("..
Ipefr..")")return end;return
BundleGameHelperFunctions.Local:SetSpeedLimit(Ipefr)end;SetSpeedLimit=API.SetSpeedLimit
function API.ActivateSpeedLimit(FH)if GUI then
API.Bridge("API.ActivateSpeedLimit("..
tostring(FH)..")")return end;return
API.Bridge(
"BundleGameHelperFunctions.Local:ActivateSpeedLimit("..tostring(FH)..")")end;ActivateSpeedLimit=API.ActivateSpeedLimit
function API.KillCheats()if GUI then
API.Bridge("API.KillCheats()")return end;return
BundleGameHelperFunctions.Global:KillCheats()end;KillCheats=API.KillCheats
function API.RessurectCheats()if GUI then
API.Bridge("API.RessurectCheats()")return end;return
BundleGameHelperFunctions.Global:RessurectCheats()end;RessurectCheats=API.RessurectCheats
function API.ForbidSaveGame(eBlBVcO)if GUI then
API.Bridge("API.ForbidSaveGame("..
tostring(eBlBVcO)..")")return end
API.Bridge(
[[
        BundleGameHelperFunctions.Local.Data.ForbidSave = ]]..
tostring(eBlBVcO)..[[ == true
        BundleGameHelperFunctions.Local:DisplaySaveButtons(]]..
tostring(eBlBVcO)..[[)
    ]])end;ForbidSaveGame=API.ForbidSaveGame
function API.AllowExtendedZoom(QJtAht)if GUI then
API.Bridge("API.AllowExtendedZoom("..
tostring(QJtAht)..")")return end;BundleGameHelperFunctions.Global.Data.ExtendedZoomAllowed=
QJtAht==true;if QJtAht==false then
BundleGameHelperFunctions.Global:DeactivateExtendedZoom()end end;AllowExtendedZoom=API.AllowExtendedZoom
function API.StartNormalFestival(lvWSxpXL)if GUI then
API.Bridge("API.StartNormalFestival("..
lvWSxpXL..")")return end
BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(lvWSxpXL,0,false)Logic.StartFestival(lvWSxpXL,0)end;StartNormalFestival=API.StartNormalFestival
function API.StartCityUpgradeFestival(U7kEO_p)if GUI then
API.Bridge(
"API.StartCityUpgradeFestival("..U7kEO_p..")")return end
BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(U7kEO_p,1,false)Logic.StartFestival(U7kEO_p,1)end;StartCityUpgradeFestival=API.StartCityUpgradeFestival
function API.ForbidFestival(cO)
if GUI then API.Bridge(
"API.ForbidFestival("..cO..")")return end;local G4Mkp=Logic.GetKnightTitle(cO)
local p=Technologies.R_Festival;local jlq=TechnologyStates.Locked
if

KnightTitleNeededForTechnology[p]==nil or G4Mkp>=KnightTitleNeededForTechnology[p]then jlq=TechnologyStates.Prohibited end;Logic.TechnologySetState(cO,p,jlq)
BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(cO,0,true)
API.Bridge("BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer["..cO.."] = true")end;ForbidFestival=API.ForbidFestival
function API.AllowFestival(SeM)if GUI then
API.Bridge("API.AllowFestival("..SeM..")")return end
BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(SeM,0,false)local T=Logic.GetKnightTitle(SeM)
local jPy=Technologies.R_Festival;local JoekICm=TechnologyStates.Unlocked
if
KnightTitleNeededForTechnology[jPy]==
nil or T>=KnightTitleNeededForTechnology[jPy]then JoekICm=TechnologyStates.Researched end;Logic.TechnologySetState(SeM,jPy,JoekICm)
API.Bridge(
"BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer["..SeM.."] = false")end;AllowFestival=API.AllowFestival
function API.SetControllingPlayer(FNPW0,kTe9g3,PXlYVZey,sHVG1rp)if GUI then
API.Bridge("API.SetControllingPlayer("..
FNPW0 ..", "..kTe9g3 ..

", '"..PXlYVZey.."', "..tostring(sHVG1rp)..")")return end;return
BundleGameHelperFunctions.Global:SetControllingPlayer(FNPW0,kTe9g3,PXlYVZey,sHVG1rp)end;PlayerSetPlayerID=API.SetControllingPlayer;function API.GetControllingPlayer()
if not GUI then return
BundleGameHelperFunctions.Global:GetControllingPlayer()else return GUI.GetPlayerID()end end
PlayerGetPlayerID=API.GetControllingPlayer
function API.ThridPersonActivate(oSR3DE,yIR2c6Rc)
if GUI then local F_j7LU=
(type(oSR3DE)=="string"and"'"..oSR3DE.."'")or oSR3DE
API.Bridge(
"API.ThridPersonActivate("..F_j7LU..", "..yIR2c6Rc..")")return end;return
BundleGameHelperFunctions.Global:ThridPersonActivate(oSR3DE,yIR2c6Rc)end;HeroCameraActivate=API.ThridPersonActivate
function API.ThridPersonDeactivate()if GUI then
API.Bridge("API.ThridPersonDeactivate()")return end;return
BundleGameHelperFunctions.Global:ThridPersonDeactivate()end;HeroCameraDeactivate=API.ThridPersonDeactivate
function API.ThridPersonIsRuning()
if not GUI then return
BundleGameHelperFunctions.Global:ThridPersonIsRuning()else return
BundleGameHelperFunctions.Local:ThridPersonIsRuning()end end;HeroCameraIsRuning=API.ThridPersonIsRuning
function API.AddFollowKnightSave(g,LK,A12XW,vG)
if GUI then
local nIT20_b=(
type(g)=="string"and"'"..g.."'")or g
local EEsqg=(type(LK)=="string"and"'"..LK.."'")or LK
API.Bridge("API.StopFollowKnightSave("..nIT20_b..", "..
EEsqg..", "..A12XW..","..vG..")")return end;return
BundleGameHelperFunctions.Global:AddFollowKnightSave(g,LK,A12XW,vG)end
function API.StopFollowKnightSave(icMbUi)if GUI then
API.Bridge("API.StopFollowKnightSave("..icMbUi..")")return end;return
BundleGameHelperFunctions.Global:StopFollowKnightSave(icMbUi)end
BundleGameHelperFunctions={Global={Data={HumanPlayerChangedOnce=false,HumanKnightType=0,HumanPlayerID=1,ExtendedZoomAllowed=true,FestivalBlacklist={},FollowKnightSave={}}},Local={Data={NormalFestivalLockedForPlayer={},SpeedLimit=32,ThirdPersonIsActive=false,ThirdPersonLastHero=
nil,ThirdPersonLastZoom=nil}},Shared={Data={TimeLineUniqueJobID=1,TimeLineJobs={}}}}
function BundleGameHelperFunctions.Global:Install()
self:InitExtendedZoom()
API.AddSaveGameAction(BundleGameHelperFunctions.Global.OnSaveGameLoaded)
QSB.TimeLineStart=BundleGameHelperFunctions.Shared.TimeLineStart end
function BundleGameHelperFunctions.Global:UndiscoverTerritory(RO5,O7Td)
if
DiscoveredTerritories[RO5]==nil then DiscoveredTerritories[RO5]={}end
for P=1,#DiscoveredTerritories[RO5],1 do if
DiscoveredTerritories[RO5][P]==O7Td then
table.remove(DiscoveredTerritories[RO5],P)break end end end
function BundleGameHelperFunctions.Global:UndiscoverTerritories(qUV,HOCuSE7_)
if
DiscoveredTerritories[qUV]==nil then DiscoveredTerritories[qUV]={}end;local plYwsj={}
for q,hADV in pairs(DiscoveredTerritories[qUV])do
local FiKB_BzO=Logic.GetTerritoryPlayerID(hADV)
if FiKB_BzO~=HOCuSE7_ then table.insert(plYwsj,hADV)break end end;DiscoveredTerritories[qUV][i]=plYwsj end
function BundleGameHelperFunctions.Global:SetNeedSatisfactionLevel(Jt_Rub3,ArK3,OBAhnX_P)
if not OBAhnX_P then for ts1TuG=1,8,1 do
self:SetNeedSatisfactionLevel(Jt_Rub3,ArK3,ts1TuG)end else
local dofOBz={Logic.GetPlayerEntitiesInCategory(OBAhnX_P,EntityCategories.CityBuilding)}
if
Jt_Rub3 ==Needs.Nutrition or Jt_Rub3 ==Needs.Medicine then
local ok={Logic.GetPlayerEntitiesInCategory(OBAhnX_P,EntityCategories.OuterRimBuilding)}dofOBz=Array_Append(dofOBz,ok)end
for aTIrG=1,#dofOBz,1 do if Logic.IsNeedActive(dofOBz[aTIrG],Jt_Rub3)then
Logic.SetNeedState(dofOBz[aTIrG],Jt_Rub3,ArK3)end end end end
function BundleGameHelperFunctions.Global:UnlockTitleForPlayer(QNggzrn,Ht)
if
LockedKnightTitles[QNggzrn]==Ht then LockedKnightTitles[QNggzrn]=nil
for O0N=Ht,#NeedsAndRightsByKnightTitle
do local E6zvZw=NeedsAndRightsByKnightTitle[O0N][4]
if
E6zvZw~=nil then for VWJR=1,#E6zvZw do local YiXM=E6zvZw[VWJR]
Logic.TechnologySetState(QNggzrn,YiXM,TechnologyStates.Unlocked)end end end end end
function BundleGameHelperFunctions.Global:SetControllingPlayer(XEWeum,hZ47ZL,_GaziPP0,PRKm)
assert(type(XEWeum)=="number")assert(type(hZ47ZL)=="number")
_GaziPP0=_GaziPP0 or""PRKm=(PRKm and true)or false;local tF8XJ,_vmurIq,CzMB
if PRKm then
tF8XJ=Logic.GetKnightID(XEWeum)_vmurIq=Logic.GetEntityName(tF8XJ)
CzMB=Logic.GetEntityType(tF8XJ)Logic.ChangeEntityPlayerID(tF8XJ,hZ47ZL)
Logic.SetPrimaryKnightID(hZ47ZL,GetID(_vmurIq))else tF8XJ=Logic.GetKnightID(hZ47ZL)
_vmurIq=Logic.GetEntityName(tF8XJ)CzMB=Logic.GetEntityType(tF8XJ)end;Logic.PlayerSetIsHumanFlag(XEWeum,0)
Logic.PlayerSetIsHumanFlag(hZ47ZL,1)Logic.PlayerSetGameStateToPlaying(hZ47ZL)
self.Data.HumanKnightType=CzMB;self.Data.HumanPlayerID=hZ47ZL
GameCallback_PlayerLost=function(b)
if b==
self:GetControllingPlayer()then
QuestTemplate:TerminateEventsAndStuff()
if MissionCallback_Player1Lost then MissionCallback_Player1Lost()end end end
Logic.ExecuteInLuaLocalState([[
        GUI.ClearSelection()
        GUI.SetControlledPlayer(]]..
hZ47ZL..

[[)

        for k,v in pairs(Buffs)do
            GUI_Buffs.UpdateBuffsInInterface(]]..
hZ47ZL..

[[,v)
            GUI.ResetMiniMap()
        end

        if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
            local portrait = GetKnightActor(]]..
CzMB..
[[)
            g_PlayerPortrait[GUI.GetPlayerID()] = portrait
            LocalSetKnightPicture()
        end

        local newName = "]]..

_GaziPP0 ..

[["
        if newName ~= "" then
            GUI_MissionStatistic.PlayerNames[GUI.GetPlayerID()] = newName
        end
        HideOtherMenus()

        function GUI_Knight.GetTitleNameByTitleID(_KnightType, _TitleIndex)
            local KeyName = "Title_" .. GetNameOfKeyInTable(KnightTitles, _TitleIndex) .. "_" .. KnightGender[]]..
CzMB..
[[]
            local String = XGUIEng.GetStringTableText("UI_ObjectNames/" .. KeyName)
            if String == nil or String == "" then
                String = "Knight not in Gender Table? (localscript.lua)"
            end
            return String
        end
    ]])self.Data.HumanPlayerChangedOnce=true end
function BundleGameHelperFunctions.Global:GetControllingPlayer()local YJHr=1
for VuatYZ=1,8 do if
Logic.PlayerGetIsHumanFlag(VuatYZ)==true then YJHr=VuatYZ;break end end;return YJHr end
function BundleGameHelperFunctions.Global:InitFestival()
if
not Logic.StartFestival_Orig_NothingToCelebrate then Logic.StartFestival_Orig_NothingToCelebrate=Logic.StartFestival end
Logic.StartFestival=function(k,iEMx16D8)
if
BundleGameHelperFunctions.Global.Data.FestivalBlacklist[k]then if
BundleGameHelperFunctions.Global.Data.FestivalBlacklist[k][iEMx16D8]then return end end
Logic.StartFestival_Orig_NothingToCelebrate(k,iEMx16D8)end end
function BundleGameHelperFunctions.Global:RestrictFestivalForPlayer(LNTQc,Q,aBY7)
self:InitFestival()if not self.Data.FestivalBlacklist[LNTQc]then
self.Data.FestivalBlacklist[LNTQc]={}end;self.Data.FestivalBlacklist[LNTQc][Q]=
aBY7 ==true end
function BundleGameHelperFunctions.Global:ToggleExtendedZoom()
if self.Data.ExtendedZoomAllowed then if
self.Data.ExtendedZoomActive then self:DeactivateExtendedZoom()else
self:ActivateExtendedZoom()end end end
function BundleGameHelperFunctions.Global:ActivateExtendedZoom()
self.Data.ExtendedZoomActive=true
API.Bridge("BundleGameHelperFunctions.Local:ActivateExtendedZoom()")end
function BundleGameHelperFunctions.Global:DeactivateExtendedZoom()
self.Data.ExtendedZoomActive=false
API.Bridge("BundleGameHelperFunctions.Local:DeactivateExtendedZoom()")end
function BundleGameHelperFunctions.Global:InitExtendedZoom()
API.Bridge([[
        BundleGameHelperFunctions.Local:ActivateExtendedZoomHotkey()
        BundleGameHelperFunctions.Local:RegisterExtendedZoomHotkey()
    ]])end;function BundleGameHelperFunctions.Global:KillCheats()
self.Data.CheatsForbidden=true
API.Bridge("BundleGameHelperFunctions.Local:KillCheats()")end
function BundleGameHelperFunctions.Global:RessurectCheats()
self.Data.CheatsForbidden=false
API.Bridge("BundleGameHelperFunctions.Local:RessurectCheats()")end
function BundleGameHelperFunctions.Global:ThridPersonActivate(dryHpm8,u6f1)if BriefingSystem then
BundleGameHelperFunctions.Global:ThridPersonOverwriteStartAndEndBriefing()end
local pb3tO=GetID(dryHpm8)
BundleGameHelperFunctions.Global.Data.ThridPersonIsActive=true
Logic.ExecuteInLuaLocalState([[
        BundleGameHelperFunctions.Local:ThridPersonActivate(]]..tostring(pb3tO)..[[, ]]..
tostring(u6f1)..[[);
    ]])end
function BundleGameHelperFunctions.Global:ThridPersonDeactivate()
BundleGameHelperFunctions.Global.Data.ThridPersonIsActive=false
Logic.ExecuteInLuaLocalState([[
        BundleGameHelperFunctions.Local:ThridPersonDeactivate();
    ]])end;function BundleGameHelperFunctions.Global:ThridPersonIsRuning()return
self.Data.ThridPersonIsActive end
function BundleGameHelperFunctions.Global:ThridPersonOverwriteStartAndEndBriefing()
if
BriefingSystem then
if not BriefingSystem.StartBriefing_Orig_HeroCamera then
BriefingSystem.StartBriefing_Orig_HeroCamera=BriefingSystem.StartBriefing
BriefingSystem.StartBriefing=function(MFtjGje,kofvXOKl)
if
BundleGameHelperFunctions.Global:ThridPersonIsRuning()then
BundleGameHelperFunctions.Global:ThridPersonDeactivate()
BundleGameHelperFunctions.Global.Data.ThirdPersonStoppedByCode=true end
BriefingSystem.StartBriefing_Orig_HeroCamera(MFtjGje,kofvXOKl)end;StartBriefing=BriefingSystem.StartBriefing end
if not BriefingSystem.EndBriefing_Orig_HeroCamera then
BriefingSystem.EndBriefing_Orig_HeroCamera=BriefingSystem.EndBriefing
BriefingSystem.EndBriefing=function(l,eor)
BriefingSystem.EndBriefing_Orig_HeroCamera()
if
BundleGameHelperFunctions.Global.Data.ThridPersonStoppedByCode then
BundleGameHelperFunctions.Global:ThridPersonActivate(0)
BundleGameHelperFunctions.Global.Data.ThridPersonStoppedByCode=false end end end end end
function BundleGameHelperFunctions.Global:AddFollowKnightSave(mOtS,QZymu0wx,yepeICvH,i6z)local xK=GetID(mOtS)
local Lf=GetID(QZymu0wx)i6z=i6z or 0
local M1ygP0=Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,nil,"ControlFollowKnightSave",1,{},{xK,Lf,yepeICvH,i6z})
table.insert(self.Data.FollowKnightSave,M1ygP0)return M1ygP0 end
function BundleGameHelperFunctions.Global:StopFollowKnightSave(N04qlb)
for xG,_QFI in
pairs(self.Data.FollowKnightSave)do if N04qlb==_QFI then self.Data.FollowKnightSave[xG]=nil
EndJob(N04qlb)end end end
function BundleGameHelperFunctions.Global.ControlFollowKnightSave(L1,DIlk,f,Go5boB)
if
not IsExisting(DIlk)or not IsExisting(L1)then return true end
if Logic.IsKnight(L1)and
Logic.KnightGetResurrectionProgress(L1)~=1 then return false end
if Logic.IsKnight(DIlk)and
Logic.KnightGetResurrectionProgress(DIlk)~=1 then return false end
if
Logic.IsEntityMoving(L1)==false and
Logic.IsFighting(L1)==false and IsNear(L1,DIlk,f+300)==false then local NJ3IE,hKz,g73=Logic.EntityGetPos(DIlk)local i=
Logic.GetEntityOrientation(DIlk)- (180+Go5boB)local jt1wTgy=NJ3IE+f*
math.cos(math.rad(i))local LEJ=hKz+f*
math.sin(math.rad(i))
local EhuI3=Logic.CreateEntityOnUnblockedLand(Entities.XD_ScriptEntity,jt1wTgy,LEJ,0,0)local NJ3IE,hKz,g73=Logic.EntityGetPos(EhuI3)
DestroyEntity(EhuI3)Logic.MoveSettler(L1,NJ3IE,hKz)end end
ControlFollowKnightSave=BundleGameHelperFunctions.Global.ControlFollowKnightSave
function BundleGameHelperFunctions.Global.OnSaveGameLoaded()Logic.StartFestival_Orig_NothingToCelebrate=
nil
BundleGameHelperFunctions.Global:InitFestival()if BundleGameHelperFunctions.Global.Data.ExtendedZoomActive then
BundleGameHelperFunctions.Global:ActivateExtendedZoom()end;if
BundleGameHelperFunctions.Global.Data.CheatsForbidden==true then
BundleGameHelperFunctions.Global:KillCheats()end
if
BundleGameHelperFunctions.Global.Data.HumanPlayerChangedOnce then
Logic.ExecuteInLuaLocalState([[
            GUI.SetControlledPlayer(]]..

BundleGameHelperFunctions.Global.Data.HumanPlayerID..
[[)
            for k,v in pairs(Buffs)do
                GUI_Buffs.UpdateBuffsInInterface(]]..

BundleGameHelperFunctions.Global.Data.HumanPlayerID..

[[,v)
                GUI.ResetMiniMap()
            end
            if IsExisting(Logic.GetKnightID(GUI.GetPlayerID())) then
                local portrait = GetKnightActor(]]..
BundleGameHelperFunctions.Global.Data.HumanKnightType..

[[)
                g_PlayerPortrait[]]..BundleGameHelperFunctions.Global.Data.HumanPlayerID..
[[] = portrait
                LocalSetKnightPicture()
            end
        ]])end end
function BundleGameHelperFunctions.Local:Install()
self:InitForbidSpeedUp()self:InitForbidSaveGame()
self:InitForbidFestival()
QSB.TimeLineStart=BundleGameHelperFunctions.Shared.TimeLineStart end
function BundleGameHelperFunctions.Local:SetCameraToPlayerKnight(X6,IF2H,qOO620M)
BundleGameHelperFunctions.Local:SetCameraToEntity(Logic.GetKnightID(X6),IF2H,qOO620M)end
function BundleGameHelperFunctions.Local:SetCameraToEntity(jtV6,a8Yspa,Akk6ux)
local VjdGqm=GetPosition(jtV6)local LdV=(a8Yspa or-45)local hbHc=(Akk6ux or 0.5)
Camera.RTS_SetLookAtPosition(VjdGqm.X,VjdGqm.Y)Camera.RTS_SetRotationAngle(LdV)
Camera.RTS_SetZoomFactor(hbHc)end
function BundleGameHelperFunctions.Local:SetSpeedLimit(k)k=(k<1 and 1)or
math.floor(k)self.Data.SpeedLimit=k end
function BundleGameHelperFunctions.Local:ActivateSpeedLimit(XAYG3L)self.Data.UseSpeedLimit=XAYG3L==
true;if
XAYG3L and
Game.GameTimeGetFactor(GUI.GetPlayerID())>self.Data.SpeedLimit then
Game.GameTimeSetFactor(GUI.GetPlayerID(),self.Data.SpeedLimit)end end
function BundleGameHelperFunctions.Local:InitForbidSpeedUp()
GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp=GameCallback_GameSpeedChanged
GameCallback_GameSpeedChanged=function(v310)
GameCallback_GameSpeedChanged_Orig_Preferences_ForbidSpeedUp(v310)
if
BundleGameHelperFunctions.Local.Data.UseSpeedLimit==true then
if
v310 >BundleGameHelperFunctions.Local.Data.SpeedLimit then
Game.GameTimeSetFactor(GUI.GetPlayerID(),BundleGameHelperFunctions.Local.Data.SpeedLimit)end end end end
function BundleGameHelperFunctions.Local:KillCheats()
Input.KeyBindDown(Keys.ModifierControl+
Keys.ModifierShift+Keys.Divide,"KeyBindings_EnableDebugMode(0)",2,false)end
function BundleGameHelperFunctions.Local:RessurectCheats()
Input.KeyBindDown(Keys.ModifierControl+
Keys.ModifierShift+Keys.Divide,"KeyBindings_EnableDebugMode(2)",2,false)end
function BundleGameHelperFunctions.Local:RegisterExtendedZoomHotkey()
API.AddHotKey({de="Strg + Umschalt + K",en="Ctrl + Shift + K"},{de="Alternativen Zoom ein/aus",en="Alternative zoom on/off"})end
function BundleGameHelperFunctions.Local:ActivateExtendedZoomHotkey()
Input.KeyBindDown(
Keys.ModifierControl+Keys.ModifierShift+Keys.K,"BundleGameHelperFunctions.Local:ToggleExtendedZoom()",2,false)end;function BundleGameHelperFunctions.Local:ToggleExtendedZoom()
API.Bridge("BundleGameHelperFunctions.Global:ToggleExtendedZoom()")end
function BundleGameHelperFunctions.Local:ActivateExtendedZoom()
Camera.RTS_SetZoomFactorMax(0.8701)Camera.RTS_SetZoomFactor(0.8700)
Camera.RTS_SetZoomFactorMin(0.0999)end
function BundleGameHelperFunctions.Local:DeactivateExtendedZoom()
Camera.RTS_SetZoomFactor(0.5000)Camera.RTS_SetZoomFactorMax(0.5001)
Camera.RTS_SetZoomFactorMin(0.0999)end
function BundleGameHelperFunctions.Local:InitForbidSaveGame()
KeyBindings_SaveGame_Orig_Preferences_SaveGame=KeyBindings_SaveGame
KeyBindings_SaveGame=function()if
BundleGameHelperFunctions.Local.Data.ForbidSave then return end
KeyBindings_SaveGame_Orig_Preferences_SaveGame()end end
function BundleGameHelperFunctions.Local:DisplaySaveButtons(uzG)
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",(
uzG and 0)or 1)
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave",(uzG and 0)or 1)end
function BundleGameHelperFunctions.Local:ThridPersonActivate(ngvL0wgx,a0kO)
ngvL0wgx=
(ngvL0wgx~=0 and ngvL0wgx)or self.Data.ThridPersonLastHero or
Logic.GetKnightID(GUI.GetPlayerID())
a0kO=a0kO or self.Data.ThridPersonLastZoom or 0.5;if not ngvL0wgx then return end
if
not GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera then self:ThridPersonOverwriteGetBorderScrollFactor()end;self.Data.ThridPersonLastHero=ngvL0wgx
self.Data.ThridPersonLastZoom=a0kO;self.Data.ThridPersonIsActive=true
local RnGTEUB8=Logic.GetEntityOrientation(ngvL0wgx)Camera.RTS_FollowEntity(ngvL0wgx)
Camera.RTS_SetRotationAngle(RnGTEUB8-90)Camera.RTS_SetZoomFactor(a0kO)
Camera.RTS_SetZoomFactorMax(a0kO+0.0001)end
function BundleGameHelperFunctions.Local:ThridPersonDeactivate()
self.Data.ThridPersonIsActive=false;Camera.RTS_SetZoomFactorMax(0.5)
Camera.RTS_SetZoomFactor(0.5)Camera.RTS_FollowEntity(0)end;function BundleGameHelperFunctions.Local:ThridPersonIsRuning()
return self.Data.ThridPersonIsActive end
function BundleGameHelperFunctions.Local:ThridPersonOverwriteGetBorderScrollFactor()
GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera=GameCallback_Camera_GetBorderscrollFactor
GameCallback_Camera_GetBorderscrollFactor=function()
if not
BundleGameHelperFunctions.Local.Data.ThridPersonIsActive then return
GameCallback_Camera_GetBorderscrollFactor_Orig_HeroCamera()end;local tnp=Camera.RTS_GetRotationAngle()
local x,H=GUI.GetScreenSize()local Wc,fxGSt=GUI.GetMousePosition()local Rrfxi=Wc/x;if Rrfxi<=0.02 then
tnp=tnp+0.3 elseif Rrfxi>=0.98 then tnp=tnp-0.3 else return 0 end;if
tnp>=360 then tnp=0 end;Camera.RTS_SetRotationAngle(tnp)return 0 end end
function BundleGameHelperFunctions.Local:InitForbidFestival()
NewStartFestivalUpdate=function()
local oczl2=XGUIEng.GetCurrentWidgetID()local YwCVQ=GUI.GetPlayerID()
if
BundleGameHelperFunctions.Local.Data.NormalFestivalLockedForPlayer[YwCVQ]then XGUIEng.ShowWidget(oczl2,0)return true end end
Core:StackFunction("GUI_BuildingButtons.StartFestivalUpdate",NewStartFestivalUpdate)end
function BundleGameHelperFunctions.Shared:TimeLineStart(SLXe)
local w=self.Data.TimeLineUniqueJobID;self.Data.TimeLineUniqueJobID=w+1;SLXe.Running=true
SLXe.StartTime=Logic.GetTime()SLXe.Iterator=1;local F=0
for dFLo=1,#SLXe,1 do if SLXe[dFLo].Time<F then
SLXe[dFLo].Time=F+1;F=SLXe[dFLo].Time end end;self.Data.TimeLineJobs[w]=SLXe
if
not self.Data.ControlerID then
local sFpL2IR=StartSimpleJobEx(BundleGameHelperFunctions.Shared.TimeLineControler)self.Data.ControlerID=sFpL2IR end;return w end
function BundleGameHelperFunctions.Shared:TimeLineRestart(y5sHCE)if not
self.Data.TimeLineJobs[y5sHCE]then return end
self.Data.TimeLineJobs[y5sHCE].Running=true
self.Data.TimeLineJobs[y5sHCE].StartTime=Logic.GetTime()
self.Data.TimeLineJobs[y5sHCE].Iterator=1 end
function BundleGameHelperFunctions.Shared:TimeLineIsRunning(yJW)if
self.Data.TimeLineJobs[yJW]then
return self.Data.TimeLineJobs[yJW].Running==true end;return false end
function BundleGameHelperFunctions.Shared:TimeLineYield(itPfx)if not
self.Data.TimeLineJobs[itPfx]then return end
self.Data.TimeLineJobs[itPfx].Running=false end
function BundleGameHelperFunctions.Shared:TimeLineResume(AFqc)if not
self.Data.TimeLineJobs[AFqc]then return end
self.Data.TimeLineJobs[AFqc].Running=true end
function BundleGameHelperFunctions.Shared.TimeLineControler()
for gu9,s162whv in
pairs(BundleGameHelperFunctions.Shared.Data.Jobs)do if s162whv.Iterator>#s162whv then
BundleGameHelperFunctions.Shared.Data.Jobs[gu9].Running=false end
if s162whv.Running then
if(
s162whv[s162whv.Iterator].Time+s162whv.StartTime)<=
Logic.GetTime()then
s162whv[s162whv.Iterator].Action(s162whv[s162whv.Iterator])BundleGameHelperFunctions.Shared.Data.Jobs[gu9].Iterator=
s162whv.Iterator+1 end end end end;Core:RegisterBundle("BundleGameHelperFunctions")API=
API or{}QSB=QSB or{}
function API.OpenDialog(UIArtqy,U,_fz)if not GUI then
API.Dbg("API.OpenDialog: Can only be used in the local script!")return end
local M=(
Network.GetDesiredLanguage()=="de"and"de")or"en"if type(UIArtqy)=="table"then UIArtqy=UIArtqy[M]end;if
type(U)=="table"then U=U[M]end;return
BundleDialogWindows.Local:OpenDialog(UIArtqy,U,_fz)end
function API.OpenRequesterDialog(b3aPNs9F,wT8i1YM9,FedVlsC,aTX)if not GUI then
API.Dbg("API.OpenRequesterDialog: Can only be used in the local script!")return end
local N=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
if type(b3aPNs9F)=="table"then b3aPNs9F=b3aPNs9F[N]end
if type(wT8i1YM9)=="table"then wT8i1YM9=wT8i1YM9[N]end;return
BundleDialogWindows.Local:OpenRequesterDialog(b3aPNs9F,wT8i1YM9,FedVlsC,aTX)end
function API.OpenSelectionDialog(DzN,hV77,F,c30S1HE)if not GUI then
API.Dbg("API.OpenSelectionDialog: Can only be used in the local script!")return end
local JM3hcx9_=(
Network.GetDesiredLanguage()=="de"and"de")or"en"if type(DzN)=="table"then DzN=DzN[JM3hcx9_]end;if type(hV77)==
"table"then hV77=hV77[JM3hcx9_]end
hV77=hV77 .."{cr}"return
BundleDialogWindows.Local:OpenSelectionDialog(DzN,hV77,F,c30S1HE)end
BundleDialogWindows={Global={Data={}},Local={Data={Requester={ActionFunction=nil,ActionRequester=nil,Next=nil,Queue={}}},TextWindow={Data={Shown=false,Caption="",Text="",ButtonText="",Picture=
nil,Action=nil,Callback=function()end}}}}function BundleDialogWindows.Global:Install()end
function BundleDialogWindows.Local:Install()
self:DialogOverwriteOriginal()TextWindow=self.TextWindow end
function BundleDialogWindows.Local:Callback()
if self.Data.Requester.ActionFunction then self.Data.Requester.ActionFunction(
CustomGame.Knight+1)end;self:OnDialogClosed()end
function BundleDialogWindows.Local:CallbackRequester(R1Lb)if
self.Data.Requester.ActionRequester then
self.Data.Requester.ActionRequester(R1Lb)end
self:OnDialogClosed()end
function BundleDialogWindows.Local:OnDialogClosed()
self:DialogQueueStartNext()self:RestoreSaveGame()end
function BundleDialogWindows.Local:DialogQueueStartNext()
self.Data.Requester.Next=table.remove(self.Data.Requester.Queue,1)
DialogQueueStartNext_HiResControl=function()
local ti9Wt5=BundleDialogWindows.Local.Data.Requester.Next
if ti9Wt5 and ti9Wt5[1]and ti9Wt5[2]then local GmTBm=ti9Wt5[1]
BundleDialogWindows.Local[GmTBm](BundleDialogWindows.Local,unpack(ti9Wt5[2]))BundleDialogWindows.Local.Data.Requester.Next=
nil end;return true end
StartSimpleHiResJob("DialogQueueStartNext_HiResControl")end;function BundleDialogWindows.Local:DialogQueuePush(DT,HQaqh)local Nk={DT,HQaqh}
table.insert(self.Data.Requester.Queue,Nk)end
function BundleDialogWindows.Local:OpenDialog(HE,I_aA,LD_ktC)
if
XGUIEng.IsWidgetShown(RequesterDialog)==0 then assert(type(HE)=="string")assert(
type(I_aA)=="string")HE="{center}"..HE;if
string.len(I_aA)<35 then I_aA=I_aA.."{cr}"end;g_MapAndHeroPreview.SelectKnight=function()
end
XGUIEng.ShowAllSubWidgets("/InGame/Dialog/BG",1)XGUIEng.ShowWidget("/InGame/Dialog/Backdrop",0)
XGUIEng.ShowWidget(RequesterDialog,1)XGUIEng.ShowWidget(RequesterDialog_Yes,0)
XGUIEng.ShowWidget(RequesterDialog_No,0)XGUIEng.ShowWidget(RequesterDialog_Ok,1)
if type(LD_ktC)==
"function"then self.Data.Requester.ActionFunction=LD_ktC
local VzGb7="XGUIEng.ShowWidget(RequesterDialog, 0)"VzGb7=VzGb7 .."; XGUIEng.PopPage()"
VzGb7=VzGb7 ..
"; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)"
XGUIEng.SetActionFunction(RequesterDialog_Ok,VzGb7)else self.Data.Requester.ActionFunction=nil
local H="XGUIEng.ShowWidget(RequesterDialog, 0)"H=H.."; XGUIEng.PopPage()"
H=H.."; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)"XGUIEng.SetActionFunction(RequesterDialog_Ok,H)end
XGUIEng.SetText(RequesterDialog_Message,"{center}"..I_aA)XGUIEng.SetText(RequesterDialog_Title,HE)XGUIEng.SetText(
RequesterDialog_Title.."White",HE)
XGUIEng.PushPage(RequesterDialog,false)
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave",0)
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",0)
if not KeyBindings_SaveGame_Orig_QSB_Windows then
KeyBindings_SaveGame_Orig_QSB_Windows=KeyBindings_SaveGame;KeyBindings_SaveGame=function()end end else
self:DialogQueuePush("OpenDialog",{HE,I_aA,LD_ktC})end end
function BundleDialogWindows.Local:OpenRequesterDialog(qb5,bT,wKpfb,X8x)
if
XGUIEng.IsWidgetShown(RequesterDialog)==0 then assert(type(qb5)=="string")assert(
type(bT)=="string")qb5="{center}"..qb5
self:OpenDialog(qb5,bT,wKpfb)XGUIEng.ShowWidget(RequesterDialog_Yes,1)
XGUIEng.ShowWidget(RequesterDialog_No,1)XGUIEng.ShowWidget(RequesterDialog_Ok,0)
if X8x~=nil then
XGUIEng.SetText(RequesterDialog_Yes,XGUIEng.GetStringTableText("UI_Texts/Ok_center"))
XGUIEng.SetText(RequesterDialog_No,XGUIEng.GetStringTableText("UI_Texts/Cancel_center"))else
XGUIEng.SetText(RequesterDialog_Yes,XGUIEng.GetStringTableText("UI_Texts/Yes_center"))
XGUIEng.SetText(RequesterDialog_No,XGUIEng.GetStringTableText("UI_Texts/No_center"))end;self.Data.Requester.ActionRequester=nil
if wKpfb then
assert(type(wKpfb)=="function")self.Data.Requester.ActionRequester=wKpfb end;local Wl="XGUIEng.ShowWidget(RequesterDialog, 0)"
Wl=Wl.."; XGUIEng.PopPage()"
Wl=Wl.."; BundleDialogWindows.Local.CallbackRequester(BundleDialogWindows.Local, true)"
XGUIEng.SetActionFunction(RequesterDialog_Yes,Wl)local Wl="XGUIEng.ShowWidget(RequesterDialog, 0)"
Wl=Wl.."; XGUIEng.PopPage()"
Wl=Wl.."; BundleDialogWindows.Local.CallbackRequester(BundleDialogWindows.Local, false)"XGUIEng.SetActionFunction(RequesterDialog_No,Wl)else
self:DialogQueuePush("OpenRequesterDialog",{qb5,bT,wKpfb,X8x})end end
function BundleDialogWindows.Local:OpenSelectionDialog(i5RShK,mlET3,snRTClV4,DL)
if
XGUIEng.IsWidgetShown(RequesterDialog)==0 then
self:OpenDialog(i5RShK,mlET3,snRTClV4)
local y=XGUIEng.GetWidgetID(CustomGame.Widget.KnightsList)XGUIEng.ListBoxPopAll(y)for YBMVrw0=1,#DL do
XGUIEng.ListBoxPushItem(y,DL[YBMVrw0])end
XGUIEng.ListBoxSetSelectedIndex(y,0)CustomGame.Knight=0;local WHjK3u="XGUIEng.ShowWidget(RequesterDialog, 0)"WHjK3u=
WHjK3u.."; XGUIEng.PopPage()"
WHjK3u=WHjK3u.."; XGUIEng.PopPage()"WHjK3u=WHjK3u.."; XGUIEng.PopPage()"
WHjK3u=WHjK3u..
"; BundleDialogWindows.Local.Callback(BundleDialogWindows.Local)"
XGUIEng.SetActionFunction(RequesterDialog_Ok,WHjK3u)local K="/InGame/Singleplayer/CustomGame/ContainerSelection/"XGUIEng.SetText(K..
"HeroComboBoxMain/HeroComboBox","")if
DL[1]then
XGUIEng.SetText(K.."HeroComboBoxMain/HeroComboBox",DL[1])end
XGUIEng.PushPage(K.."HeroComboBoxContainer",false)
XGUIEng.PushPage(K.."HeroComboBoxMain",false)
XGUIEng.ShowWidget(K.."HeroComboBoxContainer",0)local OQxSR={GUI.GetScreenSize()}
local s,x373FiG=XGUIEng.GetWidgetScreenPosition(RequesterDialog_Ok)
XGUIEng.SetWidgetScreenPosition(K.."HeroComboBoxMain",s-25,x373FiG-90)
XGUIEng.SetWidgetScreenPosition(K.."HeroComboBoxContainer",s-25,x373FiG-20)else
self:DialogQueuePush("OpenSelectionDialog",{i5RShK,mlET3,snRTClV4,DL})end end
function BundleDialogWindows.Local:RestoreSaveGame()
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/QuickSave",1)
XGUIEng.ShowWidget("/InGame/InGame/MainMenu/Container/SaveGame",1)
if KeyBindings_SaveGame_Orig_QSB_Windows then
KeyBindings_SaveGame=KeyBindings_SaveGame_Orig_QSB_Windows;KeyBindings_SaveGame_Orig_QSB_Windows=nil end end
function BundleDialogWindows.Local:DialogOverwriteOriginal()
OpenDialog_Orig_Windows=OpenDialog
OpenDialog=function(k,Gpkgz,AeBaKw)
if XGUIEng.IsWidgetShown(RequesterDialog)==0 then
local y="XGUIEng.ShowWidget(RequesterDialog, 0)"y=y.."; XGUIEng.PopPage()"
XGUIEng.SetActionFunction(RequesterDialog_Ok,y)OpenDialog_Orig_Windows(Gpkgz,k)end end;OpenRequesterDialog_Orig_Windows=OpenRequesterDialog
OpenRequesterDialog=function(J9iRF,ilESRrS,geCTE,_GgGjVu,EkBrp4ib)
if
XGUIEng.IsWidgetShown(RequesterDialog)==0 then local eVp="XGUIEng.ShowWidget(RequesterDialog, 0)"eVp=eVp..
"; XGUIEng.PopPage()"
XGUIEng.SetActionFunction(RequesterDialog_Yes,eVp)local eVp="XGUIEng.ShowWidget(RequesterDialog, 0)"
eVp=eVp.."; XGUIEng.PopPage()"
XGUIEng.SetActionFunction(RequesterDialog_No,eVp)
OpenRequesterDialog_Orig_Windows(J9iRF,ilESRrS,geCTE,_GgGjVu,EkBrp4ib)end end end
function BundleDialogWindows.Local.TextWindow:New(...)
assert(self==
BundleDialogWindows.Local.TextWindow,"Can not be used from instance!")local eEzA=API.InstanceTable(self)eEzA.Data.Caption=arg[1]or
eEzA.Data.Caption
eEzA.Data.Text=arg[2]or eEzA.Data.Text;eEzA.Data.Action=arg[3]
eEzA.Data.ButtonText=arg[4]or eEzA.Data.ButtonText;eEzA.Data.Callback=arg[5]or eEzA.Data.Callback
return eEzA end
function BundleDialogWindows.Local.TextWindow:AddParamater(eu,uy)
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")
assert(self.Data[eu]~=nil,"Key '"..eu.."' already exists!")self.Data[eu]=uy;return self end
function BundleDialogWindows.Local.TextWindow:SetCaption(XPhE)
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")assert(type(XPhE)=="string")
self.Data.Caption=XPhE;return self end
function BundleDialogWindows.Local.TextWindow:SetContent(qY)
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")assert(type(qY)=="string")self.Data.Text=qY
return self end
function BundleDialogWindows.Local.TextWindow:SetAction(Br5LVe)
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")
assert(nil or type(Br5LVe)=="function")self.Data.Callback=Br5LVe;return self end
function BundleDialogWindows.Local.TextWindow:SetButton(RnweC1yT,W)
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")
if RnweC1yT then assert(type(RnweC1yT)=="string")assert(
type(W)=="function")end;self.Data.ButtonText=RnweC1yT;self.Data.Action=W;return self end
function BundleDialogWindows.Local.TextWindow:Show()
assert(self~=
BundleDialogWindows.Local.TextWindow,"Can not be used in static context!")
BundleDialogWindows.Local.TextWindow.Data.Shown=true;self.Data.Shown=true;self:Prepare()
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",1)if not self.Data.Action then
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",0)end
XGUIEng.SetText("/InGame/Root/Normal/MessageLog/Name",
"{center}"..self.Data.Caption)
XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget","{center}"..self.Data.ButtonText)GUI_Chat.ClearMessageLog()
GUI_Chat.ChatlogAddMessage(self.Data.Text)local DgeRW=string.len(self.Data.Text)local cg=1;local bbWOyt=0
while(true)do
local E1y3xLZ,AAsaSz=string.find(self.Data.Text,"{cr}",cg)if not AAsaSz then break end;if AAsaSz-cg<=58 then
DgeRW=DgeRW+58- (AAsaSz-cg)end;cg=AAsaSz+1 end;if(DgeRW+ (bbWOyt*55))>1000 then
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogSlider",1)end
Game.GameTimeSetFactor(GUI.GetPlayerID(),0)end
function BundleDialogWindows.Local.TextWindow:Prepare()
function GUI_Chat.CloseChatMenu()
BundleDialogWindows.Local.TextWindow.Data.Shown=false;self.Data.Shown=false;if self.Data.Callback then
self.Data.Callback(self)end
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/BG",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Close",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Slider",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Text",1)Game.GameTimeReset(GUI.GetPlayerID())end;function GUI_Chat.ToggleWhisperTargetUpdate()
Game.GameTimeSetFactor(GUI.GetPlayerID(),0)end;function GUI_Chat.CheckboxMessageTypeWhisperUpdate()
XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/TextCheckbox",
"{center}"..self.Data.Caption)end
function GUI_Chat.ToggleWhisperTarget()if
self.Data.Action then self.Data.Action(self)end end;function GUI_Chat.ClearMessageLog()g_Chat.ChatHistory={}end
function GUI_Chat.ChatlogAddMessage(m)
table.insert(g_Chat.ChatHistory,m)local DmJnXc=""
for ak,K in ipairs(g_Chat.ChatHistory)do DmJnXc=DmJnXc..K.."{cr}"end
XGUIEng.SetText("/InGame/Root/Normal/ChatOptions/ChatLog",DmJnXc)end;local nBMvNL=
(Network.GetDesiredLanguage()=="de"and"de")or"en"if
type(self.Data.Caption)=="table"then
self.Data.Caption=self.Data.Caption[nBMvNL]end;if type(self.Data.ButtonText)==
"table"then
self.Data.ButtonText=self.Data.ButtonText[nBMvNL]end
if type(self.Data.Text)==
"table"then self.Data.Text=self.Data.Text[nBMvNL]end
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeAllPlayers",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeTeam",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatModeWhisper",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatChooseModeCaption",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/Background/TitleBig",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/Background/TitleBig/Info",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogCaption",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/BGChoose",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/BGChatLog",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatOptions/ChatLogSlider",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/BG",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Close",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Slider",0)
XGUIEng.ShowWidget("/InGame/Root/Normal/MessageLog/Text",0)
XGUIEng.DisableButton("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",0)
XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog",0,95)
XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/MessageLog/Name",0,0)
XGUIEng.SetTextColor("/InGame/Root/Normal/MessageLog/Name",51,51,121,255)
XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ChatLog",140,150)
XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/Background/DialogBG/1 (2)/2",150,400)
XGUIEng.SetWidgetPositionAndSize("/InGame/Root/Normal/ChatOptions/Background/DialogBG/1 (2)/3",400,500,350,400)
XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/ChatLog",640,580)
XGUIEng.SetWidgetSize("/InGame/Root/Normal/ChatOptions/ChatLogSlider",46,660)
XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ChatLogSlider",780,130)
XGUIEng.SetWidgetLocalPosition("/InGame/Root/Normal/ChatOptions/ToggleWhisperTarget",110,760)end;Core:RegisterBundle("BundleDialogWindows")
API=API or{}QSB=QSB or{}
function API.PauseQuestsDuringBriefings(KZiKrG)if GUI then
API.Bridge("API.PauseQuestsDuringBriefings("..
tostring(KZiKrG)..")")return end;return
BundleBriefingSystem.Global:PauseQuestsDuringBriefings(KZiKrG)end;PauseQuestsDuringBriefings=API.PauseQuestsDuringBriefings
function API.IsBriefingFinished(_87BXC)if GUI then
API.Dbg("API.IsBriefingFinished: Can only be used in the global script!")return end;return
BundleBriefingSystem.Global:IsBriefingFinished(_87BXC)end;IsBriefingFinished=API.IsBriefingFinished
function API.MCGetSelectedAnswer(OhOc2n)if GUI then
API.Dbg("API.MCGetSelectedAnswer: Can only be used in the global script!")return end;return
BundleBriefingSystem.Global:MCGetSelectedAnswer(OhOc2n)end;MCGetSelectedAnswer=API.MCGetSelectedAnswer
function API.GetCurrentBriefingPage(t)if GUI then
API.Dbg("API.GetCurrentBriefingPage: Can only be used in the global script!")return end;return
BundleBriefingSystem.Global:GetCurrentBriefingPage(t)end;GetCurrentBriefingPage=API.GetCurrentBriefingPage
function API.GetCurrentBriefing()if GUI then
API.Dbg("API.GetCurrentBriefing: Can only be used in the global script!")return end;return
BundleBriefingSystem.Global:GetCurrentBriefing()end;GetCurrentBriefing=API.GetCurrentBriefing
function API.AddPages(y3wErvEm)if GUI then
API.Dbg("API.AddPages: Can only be used in the global script!")return end;return
BundleBriefingSystem.Global:AddPages(y3wErvEm)end;AddPages=API.AddPages
function API.AddBriefingNote(CCs,sdtih)if type(CCs)~="string"and
type(CCs)~="number"then
API.Dbg("API.BriefingNote: Text must be a string or a number!")return end;if not GUI then
API.Bridge(
[[API.BriefingNote("]]..CCs..[[", ]]..tostring(sdtih)..[[)]])return end;return BriefingSystem.PushInformationText(CCs,(
sdtih*10))end;BriefingMessage=API.AddBriefingNote
BundleBriefingSystem={Global={Data={PlayedBriefings={},QuestsPausedWhileBriefingActive=true,BriefingID=0}},Local={Data={}}}function BundleBriefingSystem.Global:Install()
self:InitalizeBriefingSystem()end
function BundleBriefingSystem.Global:PauseQuestsDuringBriefings(z8QlkPC)self.Data.QuestsPausedWhileBriefingActive=
z8QlkPC==true end
function BundleBriefingSystem.Global:IsBriefingFinished(N5lime92)return
self.Data.PlayedBriefings[N5lime92]==true end
function BundleBriefingSystem.Global:MCGetSelectedAnswer(b4xAHY)if
b4xAHY.mc and b4xAHY.mc.given then return b4xAHY.mc.given end;return 0 end;function BundleBriefingSystem.Global:GetCurrentBriefingPage(z)return
BriefingSystem.currBriefing[z]end;function BundleBriefingSystem.Global:GetCurrentBriefing()return
BriefingSystem.currBriefing end
function BundleBriefingSystem.Global:AddPages(poDPM)
local E=function(Ue25a8v)
if
Ue25a8v and type(Ue25a8v)=="table"then
local gLXme=(Network.GetDesiredLanguage()==
"de"and"de")or"en"if type(Ue25a8v.title)=="table"then
Ue25a8v.title=Ue25a8v.title[gLXme]end
Ue25a8v.title=Ue25a8v.title or""if type(Ue25a8v.text)=="table"then
Ue25a8v.text=Ue25a8v.text[gLXme]end
Ue25a8v.text=Ue25a8v.text or""
if Ue25a8v.mc then
if Ue25a8v.mc.answers then
Ue25a8v.mc.amount=#Ue25a8v.mc.answers;assert(Ue25a8v.mc.amount>=1)
Ue25a8v.mc.current=1
for jpPyKze=1,Ue25a8v.mc.amount do
if Ue25a8v.mc.answers[jpPyKze]then if
type(Ue25a8v.mc.answers[jpPyKze][1])=="table"then
Ue25a8v.mc.answers[jpPyKze][1]=Ue25a8v.mc.answers[jpPyKze][1][gLXme]end end end end;if type(Ue25a8v.mc.title)=="table"then
Ue25a8v.mc.title=Ue25a8v.mc.title[gLXme]end
if
type(Ue25a8v.mc.text)=="table"then Ue25a8v.mc.text=Ue25a8v.mc.text[gLXme]end end
if Ue25a8v.view then Ue25a8v.flyTime=Ue25a8v.view.FlyTime or 0;Ue25a8v.duration=
Ue25a8v.view.Duration or 0 else
if
type(Ue25a8v.position)=="table"then
if not Ue25a8v.position.X then
Ue25a8v.zOffset=Ue25a8v.position[2]Ue25a8v.position=Ue25a8v.position[1]elseif Ue25a8v.position.Z then
Ue25a8v.zOffset=Ue25a8v.position.Z end end
if Ue25a8v.lookAt~=nil then local VX=Ue25a8v.lookAt;if type(VX)=="table"then
Ue25a8v.zOffset=VX[2]VX=VX[1]end
if type(VX)=="string"or
type(VX)=="number"then local PWB=GetID(VX)
local GtWEV=Logic.GetEntityOrientation(PWB)
if Logic.IsBuilding(PWB)==0 then GtWEV=GtWEV+90 end;local nZay6Q=0.085*string.len(Ue25a8v.text)
Ue25a8v.position=PWB;Ue25a8v.duration=Ue25a8v.duration or nZay6Q
Ue25a8v.flyTime=Ue25a8v.flyTime
Ue25a8v.rotation=(Ue25a8v.rotation or 0)+GtWEV end end end;table.insert(poDPM,Ue25a8v)else table.insert(poDPM,
(Ue25a8v~=nil and Ue25a8v)or-1)end;return Ue25a8v end
local Vap8A=function(srojWa,Yqo,h3544K,OcDu,YH)local CcC2lTC=Logic.GetEntityName(GetID(srojWa))assert(
CcC2lTC~=nil and CcC2lTC~="")local UBmbdH={}UBmbdH.zoom=(
OcDu==true and 2400)or 6250;UBmbdH.angle=(
OcDu==true and 40)or 47
UBmbdH.lookAt={CcC2lTC,100}UBmbdH.title=Yqo;UBmbdH.text=h3544K or""UBmbdH.action=YH
return E(UBmbdH)end
local qxEsDQp=function(K3FZ,f,ykVOUrKV,xI,...)local S=Logic.GetEntityName(GetID(K3FZ))
assert(S~=nil and S~="")local lVm={}lVm.zoom=(xI==true and 2400)or 6250;lVm.angle=(
xI==true and 40)or 47;lVm.lookAt={S,100}
lVm.barStyle="big"lVm.mc={title=f,text=ykVOUrKV,answers={}}local mgcN3Y={...}for dLIiqar=1,#mgcN3Y-1,2 do
lVm.mc.answers[
#lVm.mc.answers+1]={mgcN3Y[dLIiqar],mgcN3Y[dLIiqar+1]}end;return E(lVm)end;return E,Vap8A,qxEsDQp end
function BundleBriefingSystem.Global:InitalizeBriefingSystem()
DBlau="{@color:70,70,255,255}"Blau="{@color:153,210,234,255}"Weiss="{@color:255,255,255,255}"
Rot="{@color:255,32,32,255}"Gelb="{@color:244,184,0,255}"Gruen="{@color:173,255,47,255}"
Orange="{@color:255,127,0,255}"Mint="{@color:0,255,255,255}"Grau="{@color:180,180,180,255}"
Trans="{@color:0,0,0,0}"
Quest_Loop=function(Q)local u=JobQueue_GetParameter(Q)if u.LoopCallback~=nil then
u:LoopCallback()end
if u.State==QuestState.NotTriggered then local wtMEkjRL=true;for vU3I=1,u.Triggers[0]
do
wtMEkjRL=wtMEkjRL and u:IsTriggerActive(u.Triggers[vU3I])end
if wtMEkjRL then
u:SetMsgKeyOverride()u:SetIconOverride()u:Trigger()end elseif u.State==QuestState.Active then local huhxZB=true;local W5eI=false
for XS0l=1,u.Objectives[0]do
local kRU7gz06=u:IsObjectiveCompleted(u.Objectives[XS0l])if IsBriefingActive()then
if
BundleBriefingSystem.Global.Data.QuestsPausedWhileBriefingActive==true then u.StartTime=u.StartTime+1 end end
if

u.Objectives[XS0l].Type==Objective.Deliver and kRU7gz06 ==nil then if u.Objectives[XS0l].Data[4]==nil then
u.Objectives[XS0l].Data[4]=0 end
if
u.Objectives[XS0l].Data[3]~=nil then u.Objectives[XS0l].Data[4]=
u.Objectives[XS0l].Data[4]+1 end;local iEuu=u.StartTime;local fE=u.Duration
local CCb6csB3=u.Objectives[XS0l].Data[4]
local RTTNb8e=u.StartTime+u.Duration-u.Objectives[XS0l].Data[4]if
u.Duration>0 and u.StartTime+u.Duration+
u.Objectives[XS0l].Data[4]<Logic.GetTime()then kRU7gz06=false end else
if

u.Duration>0 and u.StartTime+u.Duration<Logic.GetTime()then
if
kRU7gz06 ==nil and
(

u.Objectives[XS0l].Type==Objective.Protect or u.Objectives[XS0l].Type==Objective.Dummy or u.Objectives[XS0l].Type==Objective.NoChange)then kRU7gz06=true elseif kRU7gz06 ==nil or
u.Objectives[XS0l].Type==Objective.DummyFail then kRU7gz06=false end end end;huhxZB=(kRU7gz06 ==true)and huhxZB;W5eI=kRU7gz06 ==false or
W5eI end;if huhxZB then u:Success()elseif W5eI then u:Fail()end else if
u.IsEventQuest==true then
Logic.ExecuteInLuaLocalState("StopEventMusic(nil, "..u.ReceivingPlayer..")")end
if
u.Result==QuestResult.Success then
for cUj4EHLT=1,u.Rewards[0]do u:AddReward(u.Rewards[cUj4EHLT])end elseif u.Result==QuestResult.Failure then for g161JmD=1,u.Reprisals[0]do
u:AddReprisal(u.Reprisals[g161JmD])end end;if u.EndCallback~=nil then u:EndCallback()end;return true end;BundleBriefingSystem:OverwriteGetPosition()end
BriefingSystem={isActive=false,waitList={},isInitialized=false,maxMarkerListEntry=0,currBriefingIndex=0,loadScreenHidden=false}BriefingSystem.BRIEFING_CAMERA_ANGLEDEFAULT=43;BriefingSystem.BRIEFING_CAMERA_ROTATIONDEFAULT=
-45
BriefingSystem.BRIEFING_CAMERA_ZOOMDEFAULT=6250;BriefingSystem.BRIEFING_CAMERA_FOVDEFAULT=42
BriefingSystem.BRIEFING_DLGCAMERA_ANGLEDEFAULT=29;BriefingSystem.BRIEFING_DLGCAMERA_ROTATIONDEFAULT=-45
BriefingSystem.BRIEFING_DLGCAMERA_ZOOMDEFAULT=3400;BriefingSystem.BRIEFING_DLGCAMERA_FOVDEFAULT=25
BriefingSystem.STANDARDTIME_PER_PAGE=1;BriefingSystem.SECONDS_PER_CHAR=0.05
BriefingSystem.COLOR1="{@color:255,250,0,255}"BriefingSystem.COLOR2="{@color:255,255,255,255}"
BriefingSystem.COLOR3="{@color:250,255,0,255}"BriefingSystem.BRIEFING_FLYTIME=0
BriefingSystem.POINTER_HORIZONTAL=1;BriefingSystem.POINTER_VERTICAL=4
BriefingSystem.POINTER_VERTICAL_LOW=5;BriefingSystem.POINTER_VERTICAL_HIGH=6
BriefingSystem.ANIMATED_MARKER=1;BriefingSystem.STATIC_MARKER=2
BriefingSystem.POINTER_PERMANENT_MARKER=6;BriefingSystem.ENTITY_PERMANENT_MARKER=8
BriefingSystem.SIGNAL_MARKER=0;BriefingSystem.ATTACK_MARKER=3;BriefingSystem.CRASH_MARKER=4
BriefingSystem.POINTER_MARKER=5;BriefingSystem.ENTITY_MARKER=7
BriefingSystem.BRIEFING_EXPLORATION_RANGE=6000;BriefingSystem.SKIPMODE_ALL=1;BriefingSystem.SKIPMODE_PERPAGE=2
BriefingSystem.DEFAULT_EXPLORE_ENTITY="XD_Camera"
function API.StartCutscene(E8zU_n)E8zU_n.skipPerPage=false
for b2Xs_blx=1,#E8zU_n,1 do if E8zU_n[b2Xs_blx].mc then
API.Dbg(
"API.StartCutscene: Unallowed multiple choice at page "..b2Xs_blx.." found!")return end;if
E8zU_n[b2Xs_blx].marker then
API.Dbg("API.StartCutscene: Unallowed marker at page "..b2Xs_blx.." found!")return end;if
E8zU_n[b2Xs_blx].pointer then
API.Dbg("API.StartCutscene: Unallowed pointer at page "..b2Xs_blx.." found!")return end;if
E8zU_n[b2Xs_blx].explore then
API.Dbg("API.StartCutscene: Unallowed explore at page "..b2Xs_blx.." found!")return end end;return BriefingSystem.StartBriefing(E8zU_n,true)end;BriefingSystem.StartCutscene=API.StartCutscene
StartCutscene=API.StartCutscene
function API.StartBriefing(xh,v60G)v60G=v60G or false
Logic.ExecuteInLuaLocalState(
[[
            BriefingSystem.Flight.systemEnabled = ]]..tostring(not v60G)..[[
        ]])BundleBriefingSystem.Global.Data.BriefingID=
BundleBriefingSystem.Global.Data.BriefingID+1
xh.UniqueBriefingID=BundleBriefingSystem.Global.Data.BriefingID;if#xh>0 then
xh[1].duration=(xh[1].duration or 0)+0.1 end;if xh.hideBorderPins then
Logic.ExecuteInLuaLocalState([[Display.SetRenderBorderPins(0)]])end;if xh.showSky then
Logic.ExecuteInLuaLocalState([[Display.SetRenderSky(1)]])end
Logic.ExecuteInLuaLocalState([[
            Display.SetUserOptionOcclusionEffect(0)
        ]])xh.finished_Orig_QSB_Briefing=xh.finished
xh.finished=function(hPkY9bO)if xh.hideBorderPins then
Logic.ExecuteInLuaLocalState([[Display.SetRenderBorderPins(1)]])end;if xh.showSky then
Logic.ExecuteInLuaLocalState([[Display.SetRenderSky(0)]])end
Logic.ExecuteInLuaLocalState([[
                if Options.GetIntValue("Display", "Occlusion", 0) > 0 then
                    Display.SetUserOptionOcclusionEffect(1)
                end
            ]])xh.finished_Orig_QSB_Briefing(hPkY9bO)
BundleBriefingSystem.Global.Data.PlayedBriefings[xh.UniqueBriefingID]=true end
if BriefingSystem.isActive then
table.insert(BriefingSystem.waitList,xh)if not BriefingSystem.waitList.Job then
BriefingSystem.waitList.Job=StartSimpleJob("BriefingSystem_WaitForBriefingEnd")end else
BriefingSystem.ExecuteBriefing(xh)end
return BundleBriefingSystem.Global.Data.BriefingID end;BriefingSystem.StartBriefing=API.StartBriefing
StartBriefing=API.StartBriefing
function BriefingSystem.EndBriefing()BriefingSystem.isActive=false
Logic.SetGlobalInvulnerability(0)local k2mlfc=BriefingSystem.currBriefing
BriefingSystem.currBriefing=nil
BriefingSystem[BriefingSystem.currBriefingIndex]=nil
Logic.ExecuteInLuaLocalState("BriefingSystem.EndBriefing()")EndJob(BriefingSystem.job)if k2mlfc.finished then
k2mlfc:finished()end end
function BriefingSystem_WaitForBriefingEnd()
if
not BriefingSystem.isActive and BriefingSystem.loadScreenHidden then
BriefingSystem.ExecuteBriefing(table.remove(BriefingSystem.waitList),1)if#BriefingSystem.waitList==0 then BriefingSystem.waitList.Job=
nil;return true end end end
function BriefingSystem.ExecuteBriefing(qYSV2)
if not BriefingSystem.isInitialized then
Logic.ExecuteInLuaLocalState("BriefingSystem.InitializeBriefingSystem()")BriefingSystem.isInitialized=true end;BriefingSystem.isActive=true;BriefingSystem.currBriefing=qYSV2;BriefingSystem.currBriefingIndex=
BriefingSystem.currBriefingIndex+1
BriefingSystem[BriefingSystem.currBriefingIndex]=qYSV2;BriefingSystem.timer=0;BriefingSystem.page=0
BriefingSystem.skipPlayers={}
BriefingSystem.disableSkipping=BriefingSystem.currBriefing.disableSkipping
BriefingSystem.skipAll=BriefingSystem.currBriefing.skipAll
BriefingSystem.skipPerPage=not BriefingSystem.skipAll and
BriefingSystem.currBriefing.skipPerPage;if not qYSV2.disableGlobalInvulnerability then
Logic.SetGlobalInvulnerability(1)end
Logic.ExecuteInLuaLocalState("BriefingSystem.PrepareBriefing()")
BriefingSystem.currBriefing=BriefingSystem.RemoveObsolateAnswers(BriefingSystem.currBriefing)
BriefingSystem.job=Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,"BriefingSystem_Condition_Briefing","BriefingSystem_Action_Briefing",1)
if not BriefingSystem.loadScreenHidden then
Logic.ExecuteInLuaLocalState("BriefingSystem.Briefing(true)")elseif BriefingSystem_Action_Briefing()then
EndJob(BriefingSystem.job)end end
function BriefingSystem.RemoveObsolateAnswers(g)
if g then local hzfqfggM=1
while
(g[hzfqfggM]~=nil and#g>=hzfqfggM)do
if
type(g[hzfqfggM])=="table"and g[hzfqfggM].mc and g[hzfqfggM].mc.answers then local M0lvbat=1
local wZUGT=1
while
(g[hzfqfggM].mc.answers[wZUGT]~=nil)do if
not g[hzfqfggM].mc.answers[wZUGT].ID then
g[hzfqfggM].mc.answers[wZUGT].ID=M0lvbat end
if
type(g[hzfqfggM].mc.answers[wZUGT][3])=="function"and
g[hzfqfggM].mc.answers[wZUGT][3](g[hzfqfggM].mc.answers[wZUGT])then
Logic.ExecuteInLuaLocalState(
[[
                                local b = BriefingSystem.currBriefing
                                if b and b[]]..
hzfqfggM..
[[] and b[]]..
hzfqfggM..
[[].mc then
                                    table.remove(BriefingSystem.currBriefing[]]..hzfqfggM..
[[].mc.answers, ]]..wZUGT..
[[)
                                end
                            ]])
table.remove(g[hzfqfggM].mc.answers,wZUGT)wZUGT=wZUGT-1 end;M0lvbat=M0lvbat+1;wZUGT=wZUGT+1 end;if#g[hzfqfggM].mc.answers==0 then
local yPbOWoG=Network.GetDesiredLanguage()
g[hzfqfggM].mc.answers[1]={
(yPbOWoG=="de"and"ENDE")or"END",999999}end end;hzfqfggM=hzfqfggM+1 end end;return g end
function BriefingSystem.IsBriefingActive()return BriefingSystem.isActive end;IsBriefingActive=BriefingSystem.IsBriefingActive
function BriefingSystem_Condition_Briefing()if not
BriefingSystem.loadScreenHidden then return false end;BriefingSystem.timer=
BriefingSystem.timer-0.1
return BriefingSystem.timer<=0 end
function BriefingSystem_Action_Briefing()
BriefingSystem.page=BriefingSystem.page+1;local g8q7j;if BriefingSystem.currBriefing then
g8q7j=BriefingSystem.currBriefing[BriefingSystem.page]end
if
not BriefingSystem.skipAll and not BriefingSystem.disableSkipping then
for RQpNQ=1,8 do
if
BriefingSystem.skipPlayers[RQpNQ]~=BriefingSystem.SKIPMODE_ALL then BriefingSystem.skipPlayers[RQpNQ]=
nil
if
type(g8q7j)=="table"and g8q7j.skipping==false then
Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton("..RQpNQ..", false)")else
Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton("..RQpNQ..", true)")end end end end
if not g8q7j or g8q7j==-1 then BriefingSystem.EndBriefing()return
true elseif type(g8q7j)=="number"and g8q7j>0 then
BriefingSystem.timer=0;BriefingSystem.page=g8q7j-1;return end
if g8q7j.mc then
Logic.ExecuteInLuaLocalState('XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 0)')
BriefingSystem.currBriefing[BriefingSystem.page].duration=99999999 else
local Ib=BriefingSystem.currBriefing[BriefingSystem.page+1]if not BriefingSystem.disableSkipping then
Logic.ExecuteInLuaLocalState('XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip", 1)')end end
BriefingSystem.timer=g8q7j.duration or BriefingSystem.STANDARDTIME_PER_PAGE
if g8q7j.explore then g8q7j.exploreEntities={}
if type(g8q7j.explore)=="table"then
if#
g8q7j.explore>0 or g8q7j.explore.default then
for zZq8Mf=1,8 do local QqAboSXb=
g8q7j.explore[player]or g8q7j.explore.default
if
QqAboSXb then
if type(QqAboSXb)=="table"then
BriefingSystem.CreateExploreEntity(g8q7j,QqAboSXb.exploration,
QqAboSXb.type or Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY],zZq8Mf,QqAboSXb.position)else
BriefingSystem.CreateExploreEntity(g8q7j,QqAboSXb,Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY],zZq8Mf)end end end else
BriefingSystem.CreateExploreEntity(g8q7j,g8q7j.explore.exploration,g8q7j.explore.type or
Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY],1,g8q7j.explore.position)end else
BriefingSystem.CreateExploreEntity(g8q7j,g8q7j.explore,Entities[BriefingSystem.DEFAULT_EXPLORE_ENTITY],1)end end
if g8q7j.pointer then local nxBnCeN=g8q7j.pointer;g8q7j.pointerList={}
if
type(nxBnCeN)=="table"then if#nxBnCeN>0 then for L=1,#nxBnCeN do
BriefingSystem.CreatePointer(g8q7j,nxBnCeN[L])end else
BriefingSystem.CreatePointer(g8q7j,nxBnCeN)end else
BriefingSystem.CreatePointer(g8q7j,{type=nxBnCeN,position=
g8q7j.position or g8q7j.followEntity})end end
if g8q7j.marker then
BriefingSystem.maxMarkerListEntry=BriefingSystem.maxMarkerListEntry+1;g8q7j.markerList=BriefingSystem.maxMarkerListEntry end
Logic.ExecuteInLuaLocalState("BriefingSystem.Briefing()")
if g8q7j.action then if g8q7j.actionArg and#g8q7j.actionArg>0 then
g8q7j:action(unpack(g8q7j.actionArg))else g8q7j:action()end end end
function BriefingSystem.SkipBriefing(fO7)
if not BriefingSystem.disableSkipping then
if
BriefingSystem.skipPerPage then BriefingSystem.SkipBriefingPage(fO7)return end
BriefingSystem.skipPlayers[fO7]=BriefingSystem.SKIPMODE_ALL
for IkeMo2Tp=1,8,1 do
if
Logic.PlayerGetIsHumanFlag(IkeMo2Tp)and
BriefingSystem.skipPlayers[IkeMo2Tp]~=BriefingSystem.SKIPMODE_ALL then
Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton("..fO7 ..", false)")return end end;EndJob(BriefingSystem.job)
BriefingSystem.EndBriefing()end end
function BriefingSystem.SkipBriefingPage(zxgE)
if not BriefingSystem.disableSkipping then
if not
BriefingSystem.LastSkipTimeStemp or Logic.GetTimeMs()>
BriefingSystem.LastSkipTimeStemp+500 then
BriefingSystem.LastSkipTimeStemp=Logic.GetTimeMs()if not BriefingSystem.skipPlayers[zxgE]then
BriefingSystem.skipPlayers[zxgE]=BriefingSystem.SKIPMODE_PERPAGE end
for v_2mpHj4=1,8,1 do
if

Logic.PlayerGetIsHumanFlag(zxgE)and not BriefingSystem.skipPlayers[zxgE]then if BriefingSystem.skipPerPage then
Logic.ExecuteInLuaLocalState("BriefingSystem.EnableBriefingSkipButton("..zxgE..", false)")end;return end end
if BriefingSystem.skipAll then BriefingSystem.SkipBriefing(zxgE)elseif
BriefingSystem_Action_Briefing()then EndJob(BriefingSystem.job)end end end end
function BriefingSystem.CreateExploreEntity(l,Fbj_zc,sFG,x,H6nA)local rYid8CG=H6nA or l.position
if rYid8CG then if type(rYid8CG)==
"table"and
(rYid8CG[x]or rYid8CG.default or rYid8CG.playerPositions)then
rYid8CG=rYid8CG[x]or rYid8CG.default end
if rYid8CG then
local CcFb=type(rYid8CG)if CcFb=="string"or CcFb=="number"then
rYid8CG=GetPosition(rYid8CG)end end end;if not rYid8CG then local mfEc=l.followEntity;if type(mfEc)=="table"then
mfEc=mfEc[x]or mfEc.default end
if mfEc then rYid8CG=GetPosition(mfEc)end end
assert(rYid8CG)
local AO38Nlx0=Logic.CreateEntity(sFG,rYid8CG.X,rYid8CG.Y,0,x)assert(AO38Nlx0 ~=0)
Logic.SetEntityExplorationRange(AO38Nlx0,Fbj_zc/100)table.insert(l.exploreEntities,AO38Nlx0)end
function BriefingSystem.CreatePointer(YoJiNVRT,JLuV)
local VZm9=JLuV.type or BriefingSystem.POINTER_VERTICAL;local EBupkZi=JLuV.position;assert(EBupkZi)
if
VZm9/BriefingSystem.POINTER_VERTICAL>=1 then local RpmTiVXT=EBupkZi
if type(EBupkZi)=="table"then local wi6FC5JA
wi6FC5JA,RpmTiVXT=Logic.GetEntitiesInArea(0,EBupkZi.X,EBupkZi.Y,50,1)else EBupkZi=GetPosition(EBupkZi)end;local gImQiI=EGL_Effects.E_Questmarker_low
if
VZm9 ==BriefingSystem.POINTER_VERTICAL_HIGH then gImQiI=EGL_Effects.E_Questmarker elseif
VZm9 ~=BriefingSystem.POINTER_VERTICAL_LOW then
if RpmTiVXT~=0 then if Logic.IsBuilding(RpmTiVXT)==1 then
VZm9=EGL_Effects.E_Questmarker end end end
table.insert(YoJiNVRT.pointerList,{id=Logic.CreateEffect(gImQiI,EBupkZi.X,EBupkZi.Y,JLuV.player or 0),type=VZm9})else
assert(VZm9 ==BriefingSystem.POINTER_HORIZONTAL)
if type(EBupkZi)~="table"then EBupkZi=GetPosition(EBupkZi)end
table.insert(YoJiNVRT.pointerList,{id=Logic.CreateEntityOnUnblockedLand(Entities.E_DirectionMarker,EBupkZi.X,EBupkZi.Y,
JLuV.orientation or 0,JLuV.player or 0),type=VZm9})end end
function BriefingSystem.DestroyPageMarker(Hz4UJ7T,aOBIrw3)if Hz4UJ7T.marker then
Logic.ExecuteInLuaLocalState("BriefingSystem.DestroyPageMarker("..
Hz4UJ7T.markerList..", "..aOBIrw3 ..")")end end
function BriefingSystem.RedeployPageMarkers(OaAYm,lVhSaie2)
if OaAYm.marker then if type(lVhSaie2)~="table"then
lVhSaie2=GetPosition(lVhSaie2)end
Logic.ExecuteInLuaLocalState("BriefingSystem.RedeployMarkerList("..
OaAYm.markerList..
", "..lVhSaie2.X..", "..lVhSaie2.Y..")")end end
function BriefingSystem.RedeployPageMarker(sk,k1f,CqoRoQ)
if sk.marker then if type(CqoRoQ)~="table"then
CqoRoQ=GetPosition(CqoRoQ)end
Logic.ExecuteInLuaLocalState("BriefingSystem.RedeployMarkerOfList("..sk.markerList..", "..

k1f..", "..CqoRoQ.X..", "..CqoRoQ.Y..")")end end
function BriefingSystem.RefreshPageMarkers(MAEI)if MAEI.marker then
Logic.ExecuteInLuaLocalState("BriefingSystem.RefreshMarkerList("..MAEI.markerList..
")")end end
function BriefingSystem.RefreshPageMarker(K7,W)if K7.marker then
Logic.ExecuteInLuaLocalState("BriefingSystem.RefreshMarkerOfList("..K7.markerList..", "..
W..")")end end
function BriefingSystem.ResolveBriefingPage(HLQAc2)
if HLQAc2.explore and HLQAc2.exploreEntities then
for _eaXZVx0,fEX in
ipairs(HLQAc2.exploreEntities)do Logic.DestroyEntity(fEX)end;HLQAc2.exploreEntities=nil end
if HLQAc2.pointer and HLQAc2.pointerList then
for Hxrl2,dm_mIr in ipairs(HLQAc2.pointerList)do
if
dm_mIr.type~=BriefingSystem.POINTER_HORIZONTAL then
Logic.DestroyEffect(dm_mIr.id)else Logic.DestroyEntity(dm_mIr.id)end end;HLQAc2.pointerList=nil end
if HLQAc2.marker and HLQAc2.markerList then
Logic.ExecuteInLuaLocalState("BriefingSystem.DestroyMarkerList("..
HLQAc2.markerList..")")HLQAc2.markerList=nil end end;ResolveBriefingPage=BriefingSystem.ResolveBriefingPage
function BriefingSystem.OnConfirmed(U,o9g2wCDc,kxtGbniZ)
BriefingSystem.timer=0
local e=BriefingSystem.currBriefing[BriefingSystem.page]local xnkG=BriefingSystem.page;local iCUi=o9g2wCDc
local NMeNK4x=e.mc.answers[iCUi][2]
BriefingSystem.currBriefing[xnkG].mc.given=U;if type(NMeNK4x)=="function"then BriefingSystem.page=
NMeNK4x(e.mc.answers[kxtGbniZ])-1 else
BriefingSystem.page=NMeNK4x-1 end
if
e.mc.answers[iCUi]and e.mc.answers[iCUi].remove then
table.remove(BriefingSystem.currBriefing[xnkG].mc.answers,kxtGbniZ)
if#
BriefingSystem.currBriefing[xnkG].mc.answers<kxtGbniZ then BriefingSystem.currBriefing[xnkG].mc.current=
#
BriefingSystem.currBriefing[xnkG].mc.answers end
Logic.ExecuteInLuaLocalState([[
                table.remove(BriefingSystem.currBriefing[]]..
xnkG..
[[].mc.answers, ]]..
kxtGbniZ..

[[)
                if #BriefingSystem.currBriefing[]]..
xnkG..
[[].mc.answers < ]]..
kxtGbniZ..
[[ then
                    BriefingSystem.currBriefing[]]..xnkG..
[[].mc.current = #BriefingSystem.currBriefing[]]..xnkG..
[[].mc.answers
                end
            ]])end
BriefingSystem.currBriefing=BriefingSystem.RemoveObsolateAnswers(BriefingSystem.currBriefing)end end;function BundleBriefingSystem.Local:Install()
self:InitalizeBriefingSystem()end
function BundleBriefingSystem.Local:InitalizeBriefingSystem()
GameCallback_GUI_SelectionChanged_Orig_QSB_Briefing=GameCallback_GUI_SelectionChanged
GameCallback_GUI_SelectionChanged=function(MwqB5f)
GameCallback_GUI_SelectionChanged_Orig_QSB_Briefing(MwqB5f)if IsBriefingActive()then GUI.ClearSelection()end end;DBlau="{@color:70,70,255,255}"Blau="{@color:153,210,234,255}"
Weiss="{@color:255,255,255,255}"Rot="{@color:255,32,32,255}"Gelb="{@color:244,184,0,255}"
Gruen="{@color:173,255,47,255}"Orange="{@color:255,127,0,255}"Mint="{@color:0,255,255,255}"
Grau="{@color:180,180,180,255}"Trans="{@color:0,0,0,0}"if not InitializeFader then
Script.Load("Script\\MainMenu\\Fader.lua")end
BriefingSystem={listOfMarkers={},markerUniqueID=2^10,Flight={systemEnabled=true},InformationTextQueue={}}
function BriefingSystem.InitializeBriefingSystem()
BriefingSystem.GlobalSystem=Logic.CreateReferenceToTableInGlobaLuaState("BriefingSystem")assert(BriefingSystem.GlobalSystem)if not
BriefingSystem.GlobalSystem.loadScreenHidden then
BriefingSystem.StartLoadScreenSupervising()end
BriefingSystem.GameCallback_Escape=GameCallback_Escape
GameCallback_Escape=function()if not BriefingSystem.IsBriefingActive()then
BriefingSystem.GameCallback_Escape()end end
BriefingSystem.Flight.Job=Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,nil,"ThroneRoomCameraControl",0)end
function BriefingSystem.StartLoadScreenSupervising()
if
not BriefingSystem_LoadScreenSupervising()then
Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,nil,"BriefingSystem_LoadScreenSupervising",1)end end
function BriefingSystem_LoadScreenSupervising()
if
XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen")==0 then
GUI.SendScriptCommand("BriefingSystem.loadScreenHidden = true;")return true end end
function BriefingSystem.PrepareBriefing()BriefingSystem.barType=nil
BriefingSystem.InformationTextQueue={}
BriefingSystem.currBriefing=BriefingSystem.GlobalSystem[BriefingSystem.GlobalSystem.currBriefingIndex]
Trigger.EnableTrigger(BriefingSystem.Flight.Job)
local OSrJSV=XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen")==1;if OSrJSV then XGUIEng.PopPage()end
XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay",0)XGUIEng.ShowWidget("/InGame/Root/Normal",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom",1)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Skip",
BriefingSystem.GlobalSystem.disableSkipping and 0 or 1)
BriefingSystem.EnableBriefingSkipButton(nil,true)XGUIEng.PushPage("/InGame/ThroneRoomBars",false)
XGUIEng.PushPage("/InGame/ThroneRoomBars_2",false)
XGUIEng.PushPage("/InGame/ThroneRoom/Main",false)
XGUIEng.PushPage("/InGame/ThroneRoomBars_Dodge",false)
XGUIEng.PushPage("/InGame/ThroneRoomBars_2_Dodge",false)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight",1)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/Frame",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/DialogBG",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/FrameEdges",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogBottomRight3pcs",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/KnightInfoButton",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/Briefing",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/BackButton",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/TitleContainer",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/StartButton",0)
XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text"," ")
XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Title"," ")
XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Objectives"," ")local l75hVJx4={GUI.GetScreenSize()}local jZS3=350*
(l75hVJx4[2]/1080)
XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo",1)
XGUIEng.ShowAllSubWidgets("/InGame/ThroneRoom/KnightInfo",0)
XGUIEng.ShowWidget("/InGame/ThroneRoom/KnightInfo/Text",1)
XGUIEng.PushPage("/InGame/ThroneRoom/KnightInfo",false)
XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text","Horst Hackebeil")
XGUIEng.SetTextColor("/InGame/ThroneRoom/KnightInfo/Text",255,255,255,255)
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/KnightInfo/Text",100,jZS3)local y=BriefingSystem.currBriefing[1]
BriefingSystem.SetBriefingPageOrSplashscreen(y)BriefingSystem.SetBriefingPageTextPosition(y)
if
not
Framework.IsNetworkGame()and Game.GameTimeGetFactor()~=0 then Game.GameTimeSetFactor(GUI.GetPlayerID(),1)end;if BriefingSystem.currBriefing.restoreCamera then
BriefingSystem.cameraRestore={Camera.RTS_GetLookAtPosition()}end
BriefingSystem.selectedEntities={GUI.GetSelectedEntities()}GUI.ClearSelection()
GUI.ForbidContextSensitiveCommandsInSelectionState()GUI.ActivateCutSceneState()
GUI.SetFeedbackSoundOutputState(0)GUI.EnableBattleSignals(false)Mouse.CursorHide()
Camera.SwitchCameraBehaviour(5)Input.CutsceneMode()InitializeFader()g_Fade.To=0
SetFaderAlpha(0)if OSrJSV then
XGUIEng.PushPage("/LoadScreen/LoadScreen",false)end
if BriefingSystem.currBriefing.hideFoW then
Display.SetRenderFogOfWar(0)GUI.MiniMap_SetRenderFogOfWar(0)end end
function BriefingSystem.EndBriefing()
if BriefingSystem.faderJob then
Trigger.UnrequestTrigger(BriefingSystem.faderJob)BriefingSystem.faderJob=nil end
if BriefingSystem.currBriefing.hideFoW then
Display.SetRenderFogOfWar(1)GUI.MiniMap_SetRenderFogOfWar(1)end;g_Fade.To=0;SetFaderAlpha(0)XGUIEng.PopPage()
Display.UseStandardSettings()Input.GameMode()
local i,k=Camera.ThroneRoom_GetPosition()Camera.SwitchCameraBehaviour(0)
Camera.RTS_SetLookAtPosition(i,k)Mouse.CursorShow()GUI.EnableBattleSignals(true)
GUI.SetFeedbackSoundOutputState(1)GUI.ActivateSelectionState()
GUI.PermitContextSensitiveCommandsInSelectionState()
for q,_H in ipairs(BriefingSystem.selectedEntities)do if
not Logic.IsEntityDestroyed(_H)then GUI.SelectEntity(_H)end end;if BriefingSystem.currBriefing.restoreCamera then
Camera.RTS_SetLookAtPosition(unpack(BriefingSystem.cameraRestore))end;if not
Framework.IsNetworkGame()then
Game.GameTimeSetFactor(GUI.GetPlayerID(),1)end;XGUIEng.PopPage()
XGUIEng.PopPage()XGUIEng.PopPage()XGUIEng.PopPage()
XGUIEng.PopPage()XGUIEng.ShowWidget("/InGame/ThroneRoom",0)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars",0)XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2",0)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge",0)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge",0)XGUIEng.ShowWidget("/InGame/Root/Normal",1)
XGUIEng.ShowWidget("/InGame/Root/3dOnScreenDisplay",1)
Trigger.DisableTrigger(BriefingSystem.Flight.Job)BriefingSystem.ConvertInformationToNote()end
function BriefingSystem.Briefing(ka9)if not ka9 then
if BriefingSystem.faderJob then
Trigger.UnrequestTrigger(BriefingSystem.faderJob)BriefingSystem.faderJob=nil end end
local w=BriefingSystem.currBriefing[
ka9 and 1 or BriefingSystem.GlobalSystem.page]if not w then return end;local oQlPB=w.barStyle;if oQlPB==nil then
oQlPB=BriefingSystem.currBriefing.barStyle end
BriefingSystem.SetBriefingPageOrSplashscreen(w,oQlPB)BriefingSystem.SetBriefingPageTextPosition(w)
local aJpBpxJA=GUI.GetPlayerID()
if w.text then local hF0tRNr=w.duration~=nil
local ha0Zu9=(
(oQlPB=="small"or oQlPB=="transsmall")and not w.splashscreen)
if type(w.text)=="string"then
BriefingSystem.ShowBriefingText(w.text,hF0tRNr,ha0Zu9)elseif w.text[aJpBpxJA]or w.text.default then
for SvQa=1,aJpBpxJA do if w.text[SvQa]and
Logic.GetIsHumanFlag(SvQa)then hF0tRNr=true end end
BriefingSystem.ShowBriefingText(w.text[aJpBpxJA]or w.text.default,hF0tRNr,ha0Zu9)end end
if w.title then
if type(w.title)=="string"then
BriefingSystem.ShowBriefingTitle(w.title)elseif w.title[aJpBpxJA]or w.title.default then
BriefingSystem.ShowBriefingTitle(
w.title[aJpBpxJA]or w.title.default)end end
if w.mc then BriefingSystem.Briefing_MultipleChoice()end;local dGu7zk72,aFojxj
if type(w.splashscreen)=="table"then if w.splashscreen.uv then
dGu7zk72={w.splashscreen.uv[1],w.splashscreen.uv[2]}
aFojxj={w.splashscreen.uv[3],w.splashscreen.uv[4]}end end
if not ka9 then
if w.faderAlpha then
if type(w.faderAlpha)=="table"then
g_Fade.To=w.faderAlpha[aJpBpxJA]or
w.faderAlpha.default or 0 else g_Fade.To=w.faderAlpha end;g_Fade.Duration=0 end
if w.fadeIn then local Th9qws=w.fadeIn;if type(Th9qws)=="table"then
Th9qws=Th9qws[aJpBpxJA]or Th9qws.default end
if type(Th9qws)~="number"then
Th9qws=w.duration;if not Th9qws then Th9qws=BriefingSystem.timer end end
if Th9qws<0 then
BriefingSystem.faderJob=Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,nil,"BriefingSystem_CheckFader",1,{},{1,math.abs(fadeOut)})else FadeIn(Th9qws)end end
if w.fadeOut then local h8sS=w.fadeOut;if type(h8sS)=="table"then
h8sS=h8sS[aJpBpxJA]or h8sS.default end
if type(h8sS)~="number"then h8sS=w.duration;if
not h8sS then h8sS=BriefingSystem.timer end end
if h8sS<0 then
BriefingSystem.faderJob=Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN,nil,"BriefingSystem_CheckFader",1,{},{0,math.abs(h8sS)})else FadeOut(h8sS)end end else
local sAZ9ovaF=(w.fadeOut and 0)or(w.fadeIn and 1)or w.faderValue;if sAZ9ovaF then g_Fade.To=sAZ9ovaF;g_Fade.Duration=0 end end;local Gj=w.dialogCamera;if type(Gj)=="table"then Gj=Gj[aJpBpxJA]if Gj==nil then
Gj=w.dialogCamera.default end end;Gj=
Gj and"DLG"or""
local a9sK=w.rotation or BriefingSystem.GlobalSystem["BRIEFING_"..
Gj.."CAMERA_ROTATIONDEFAULT"]if type(a9sK)=="table"then
a9sK=a9sK[aJpBpxJA]or a9sK.default end
local Dg=w.angle or BriefingSystem.GlobalSystem["BRIEFING_"..
Gj.."CAMERA_ANGLEDEFAULT"]
if type(Dg)=="table"then Dg=Dg[aJpBpxJA]or Dg.default end
local s59bbDZx=w.zoom or
BriefingSystem.GlobalSystem["BRIEFING_"..Gj.."CAMERA_ZOOMDEFAULT"]if type(s59bbDZx)=="table"then
s59bbDZx=s59bbDZx[aJpBpxJA]or s59bbDZx.default end
local bdnzXQJ7=w.FOV or BriefingSystem.GlobalSystem["BRIEFING_"..Gj..
"CAMERA_FOVDEFAULT"]BriefingSystem.CutsceneStopFlight()
BriefingSystem.StopFlight()
if w.view then if BriefingSystem.GlobalSystem.page==1 then
BriefingSystem.CutsceneSaveFlight(w.view.Position,w.view.LookAt,bdnzXQJ7)end
BriefingSystem.CutsceneFlyTo(w.view.Position,w.view.LookAt,bdnzXQJ7,
w.flyTime or 0)elseif w.position then local Mu0szy=w.position
if
type(Mu0szy)=="table"and(
Mu0szy[aJpBpxJA]or Mu0szy.default or Mu0szy.playerPositions)then Mu0szy=Mu0szy[aJpBpxJA]or Mu0szy.default end
if Mu0szy then local NDirmy=type(Mu0szy)if NDirmy=="string"or NDirmy=="number"then
Mu0szy=GetPosition(Mu0szy)elseif NDirmy=="table"then
Mu0szy={X=Mu0szy.X,Y=Mu0szy.Y,Z=Mu0szy.Z}end
local cDg=
Mu0szy.Z or Display.GetTerrainHeight(Mu0szy.X,Mu0szy.Y)if w.zOffset then cDg=cDg+w.zOffset end;Mu0szy.Z=cDg
Display.SetCameraLookAtEntity(0)if BriefingSystem.GlobalSystem.page==1 then
BriefingSystem.SaveFlight(Mu0szy,a9sK,Dg,s59bbDZx,bdnzXQJ7,dGu7zk72,aFojxj)end
BriefingSystem.FlyTo(Mu0szy,a9sK,Dg,s59bbDZx,bdnzXQJ7,
w.flyTime or BriefingSystem.GlobalSystem.BRIEFING_FLYTIME,dGu7zk72,aFojxj)end elseif w.followEntity then local lC=w.followEntity;if type(lC)=="table"then
lC=lC[aJpBpxJA]or lC.default end;lC=GetEntityId(lC)
Display.SetCameraLookAtEntity(lC)local xHEKFkR6=GetPosition(lC)xHEKFkR6.Z=xHEKFkR6.Z or nil
local dhXuZ=Display.GetTerrainHeight(xHEKFkR6.X,xHEKFkR6.Y)if w.zOffset then dhXuZ=dhXuZ+w.zOffset end;xHEKFkR6.Z=dhXuZ;if
BriefingSystem.GlobalSystem.page==1 then
BriefingSystem.SaveFlight(xHEKFkR6,a9sK,Dg,s59bbDZx,bdnzXQJ7,dGu7zk72,aFojxj)end
BriefingSystem.FollowFlight(lC,a9sK,Dg,s59bbDZx,bdnzXQJ7,
w.flyTime or 0,dhXuZ,dGu7zk72,aFojxj)end
if not ka9 then
if w.marker then local R=w.marker
if type(R)=="table"then
if#R>0 then
for fFZJEmA,H in ipairs(R)do
if not H.player or H.player==
GUI.GetPlayerID()then
BriefingSystem.CreateMarker(H,H.type,w.markerList,H.display,H.R,H.G,H.B,H.Alpha)else
table.insert(BriefingSystem.listOfMarkers[w.markerList],{})end end else
if not v.player or v.player==GUI.GetPlayerID()then
BriefingSystem.CreateMarker(R,R.type,w.markerList,R.display,R.R,R.G,R.B,R.Alpha)else
table.insert(BriefingSystem.listOfMarkers[w.markerList],{})end end else BriefingSystem.CreateMarker(w,R,w.markerList)end end end end
function OnSkipButtonPressed()local dAO1ON3q=BriefingSystem.GlobalSystem.page
if
BriefingSystem.currBriefing[dAO1ON3q]and
not BriefingSystem.currBriefing[dAO1ON3q].mc then
GUI.SendScriptCommand("BriefingSystem.SkipBriefing("..
GUI.GetPlayerID()..")")end end
function BriefingSystem.SkipBriefingPage()
local yruL=BriefingSystem.GlobalSystem.page
if BriefingSystem.currBriefing[yruL]and not
BriefingSystem.currBriefing[yruL].mc then
GUI.SendScriptCommand(
"BriefingSystem.SkipBriefingPage("..GUI.GetPlayerID()..")")end end
function BriefingSystem.ShowBriefingBar(_h)_h=_h or"big"if _h==nil then
_h=BriefingSystem.currBriefing.barStyle end
assert(
_h=='big'or _h=='small'or _h=='nobar'or _h=='transbig'or _h=='transsmall')
local wdiG=(_h=="big"or _h=="transbig")and 1 or 0;local NozvB4=(_h=="small"or _h=="transsmall")and 1 or
0
local EsWo=(_h=="transsmall"or
_h=="transbig")and 100 or 255;if _h=='nobar'then NozvB4=0;wdiG=0 end
XGUIEng.ShowWidget("/InGame/ThroneRoomBars",wdiG)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2",NozvB4)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge",wdiG)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge",NozvB4)
XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarBottom",1,EsWo)
XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars/BarTop",1,EsWo)
XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarBottom",1,EsWo)
XGUIEng.SetMaterialAlpha("/InGame/ThroneRoomBars_2/BarTop",1,EsWo)BriefingSystem.barType=_h end
function BriefingSystem.ShowBriefingText(asFvUnHl,KlrAY,vjAZVaE)
local U=XGUIEng.GetStringTableText(asFvUnHl)if U==""then U=asFvUnHl end
if not KlrAY then
GUI.SendScriptCommand("BriefingSystem.timer = "..
(
BriefingSystem.GlobalSystem.STANDARDTIME_PER_PAGE+
BriefingSystem.GlobalSystem.SECONDS_PER_CHAR*string.len(U))..";")end;if vjAZVaE then U="{cr}{cr}{cr}"..U end
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/MissionBriefing/Text",1)
XGUIEng.SetText("/InGame/ThroneRoom/Main/MissionBriefing/Text","{center}"..U)end
function BriefingSystem.ShowBriefingTitle(be)local iQ=XGUIEng.GetStringTableText(be)if
iQ==""then iQ=be end;if
BriefingSystem.GlobalSystem and string.sub(iQ,1,1)~="{"then
iQ=BriefingSystem.GlobalSystem.COLOR1 .."{center}{darkshadow}"..iQ end
XGUIEng.ShowWidget("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",1)
XGUIEng.SetText("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",iQ)end
function BriefingSystem.SchowBriefingAnswers(N)local l1ntUN={GUI.GetScreenSize()}
local s8KnRD="/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer"
BriefingSystem.OriginalBoxPosition={XGUIEng.GetWidgetScreenPosition(s8KnRD)}
local oV8WT0=XGUIEng.GetWidgetID(s8KnRD.."/ListBox")XGUIEng.ListBoxPopAll(oV8WT0)
for MSeJ0yrg=1,N.mc.amount,1 do if
N.mc.answers[MSeJ0yrg]then
XGUIEng.ListBoxPushItem(oV8WT0,N.mc.answers[MSeJ0yrg][1])end end;XGUIEng.ListBoxSetSelectedIndex(oV8WT0,0)
local I5={XGUIEng.GetWidgetScreenSize(s8KnRD)}local JoujQ=(l1ntUN[1]/1920)local yse=math.ceil((l1ntUN[1]/2)-
(I5[1]/2))local Yo=math.ceil(l1ntUN[2]-
(I5[2]-20))
XGUIEng.SetWidgetScreenPosition(s8KnRD,yse,Yo)XGUIEng.PushPage(s8KnRD,false)
XGUIEng.ShowWidget(s8KnRD,1)BriefingSystem.MCSelectionIsShown=true end
function BriefingSystem.ShowInformationText()
XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text","")local OkS4lXR=""for qfEPJE=1,#BriefingSystem.InformationTextQueue do
OkS4lXR=OkS4lXR..
BriefingSystem.InformationTextQueue[qfEPJE][1].."{cr}"end
XGUIEng.SetText("/InGame/ThroneRoom/KnightInfo/Text",OkS4lXR)end
function BriefingSystem.ConvertInformationToNote()for hzDd5=1,#BriefingSystem.InformationTextQueue do
GUI.AddNote(BriefingSystem.InformationTextQueue[hzDd5][1])end end
function BriefingSystem.PushInformationText(h4,bA6Uh)
local rrP=bA6Uh or(string.len(h4)*5)
table.insert(BriefingSystem.InformationTextQueue,{h4,rrP})end
function BriefingSystem.UnqueueInformationText(Nxb)if
#BriefingSystem.InformationTextQueue>=Nxb then
table.remove(BriefingSystem.InformationTextQueue,Nxb)end end
function BriefingSystem.ControlInformationText()local Vq={}
for TlC,J5E in
pairs(BriefingSystem.InformationTextQueue)do
BriefingSystem.InformationTextQueue[TlC][2]=J5E[2]-1;if J5E[2]<=0 then table.insert(Vq,TlC)end end;for e7Kx1,SQO in pairs(Vq)do
BriefingSystem.UnqueueInformationText(SQO)end
BriefingSystem.ShowInformationText()end
function BriefingSystem.Briefing_MultipleChoice()
local BaaU2A=BriefingSystem.currBriefing[BriefingSystem.GlobalSystem.page]
if BaaU2A and BaaU2A.mc then if BaaU2A.mc.title then
BriefingSystem.ShowBriefingTitle(BaaU2A.mc.title)end;if BaaU2A.mc.text then
BriefingSystem.ShowBriefingText(BaaU2A.mc.text,true)end;if BaaU2A.mc.answers then
BriefingSystem.SchowBriefingAnswers(BaaU2A)end
GUI.SendScriptCommand("BriefingSystem.currBriefing[BriefingSystem.page].dusation = 999999")end end
function BriefingSystem.OnConfirmed()
local N83_B="/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer"local m=BriefingSystem.OriginalBoxPosition
XGUIEng.SetWidgetScreenPosition(N83_B,m[1],m[2])XGUIEng.ShowWidget(N83_B,0)XGUIEng.PopPage()
local nqL=BriefingSystem.currBriefing[BriefingSystem.GlobalSystem.page]
if nqL.mc then local S_bM=BriefingSystem.GlobalSystem.page
local UHC1H=XGUIEng.ListBoxGetSelectedIndex(
N83_B.."/ListBox")+1
BriefingSystem.currBriefing[S_bM].mc.current=UHC1H
local M3S=BriefingSystem.currBriefing[S_bM].mc.current
local QESegOCr=BriefingSystem.currBriefing[S_bM].mc.answers[M3S].ID
GUI.SendScriptCommand([[BriefingSystem.OnConfirmed(]]..QESegOCr..[[,]]..
nqL.mc.current..[[,]]..M3S..[[)]])end end
function BriefingSystem.CreateMarker(qlr,uv_wjj1z,I,RCiLFzLF,gfMk,QUZel6wC,h7Bzdymx)local qJ=qlr.position
if qJ then if type(qJ)=="table"then
if
qJ[GUI.GetPlayerID()]or qJ.default or qJ.playerPositions then qJ=
qJ[GUI.GetPlayerID()]or qJ.default end end end
if not qJ then qJ=qlr.followEntity;if type(qJ)=="table"then qJ=qJ[GUI.GetPlayerID()]or
qJ.default end end;assert(qJ)
if type(qJ)~="table"then qJ=GetPosition(qJ)end
if
I and not BriefingSystem.listOfMarkers[I]then BriefingSystem.listOfMarkers[I]={}end;while
GUI.IsMinimapSignalExisting(BriefingSystem.markerUniqueID)==1 do
BriefingSystem.markerUniqueID=BriefingSystem.markerUniqueID+1 end
assert(
type(uv_wjj1z)=="number"and uv_wjj1z>0)RCiLFzLF=RCiLFzLF or 32;gfMk=gfMk or 245
QUZel6wC=QUZel6wC or 110;h7Bzdymx=h7Bzdymx or 255
GUI.CreateMinimapSignalRGBA(BriefingSystem.markerUniqueID,qJ.X,qJ.Y,RCiLFzLF,gfMk,QUZel6wC,h7Bzdymx,uv_wjj1z)
if I then
table.insert(BriefingSystem.listOfMarkers[I],{ID=BriefingSystem.markerUniqueID,X=qJ.X,Y=qJ.Y,R=RCiLFzLF,G=gfMk,B=QUZel6wC,Alpha=h7Bzdymx,type=uv_wjj1z})end
BriefingSystem.markerUniqueID=BriefingSystem.markerUniqueID+1 end
function BriefingSystem.DestroyMarkerList(f0T)
if BriefingSystem.listOfMarkers[f0T]then
for toGAOHR,Dymt7 in
ipairs(BriefingSystem.listOfMarkers[f0T])do
if
Dymt7.ID and GUI.IsMinimapSignalExisting(Dymt7.ID)==1 then GUI.DestroyMinimapSignal(Dymt7.ID)end end;BriefingSystem.listOfMarkers[f0T]=nil end end
function BriefingSystem.DestroyMarkerOfList(O_,YobIV)
if BriefingSystem.listOfMarkers[O_]then
local qubB3=BriefingSystem.listOfMarkers[O_][YobIV]if qubB3 and qubB3.ID and
GUI.IsMinimapSignalExisting(qubB3.ID)==1 then
GUI.DestroyMinimapSignal(qubB3.ID)qubB3.ID=nil end end end
function BriefingSystem.RedeployMarkerList(gei0,lO6cBt,F9)
if BriefingSystem.listOfMarkers[gei0]then
for AGE,NlH77co in
ipairs(BriefingSystem.listOfMarkers[gei0])do
if NlH77co.ID then NlH77co.X=lO6cBt;NlH77co.Y=F9
if
GUI.IsMinimapSignalExisting(NlH77co.ID)==1 then
GUI.RedeployMinimapSignal(NlH77co.ID,lO6cBt,F9)else
GUI.CreateMinimapSignalRGBA(NlH77co.ID,lO6cBt,F9,NlH77co.R,NlH77co.G,NlH77co.B,NlH77co.Alpha,NlH77co.type)end end end end end
function BriefingSystem.RedeployMarkerOfList(N6XLN,fBriuMK,ciY2xwYv,vVP3Z4qc)
if BriefingSystem.listOfMarkers[N6XLN]then
local VYx=BriefingSystem.listOfMarkers[N6XLN][fBriuMK]
if VYx and VYx.ID then VYx.X=ciY2xwYv;VYx.Y=vVP3Z4qc
if
GUI.IsMinimapSignalExisting(VYx.ID)==1 then
GUI.RedeployMinimapSignal(VYx.ID,ciY2xwYv,vVP3Z4qc)else
GUI.CreateMinimapSignalRGBA(VYx.ID,ciY2xwYv,vVP3Z4qc,VYx.R,VYx.G,VYx.B,VYx.Alpha,VYx.type)end end end end
function BriefingSystem.RefreshMarkerList(hpICYhx)
if BriefingSystem.listOfMarkers[hpICYhx]then
for Zh4ky,i in
ipairs(BriefingSystem.listOfMarkers[hpICYhx])do
if i.ID then
if GUI.IsMinimapSignalExisting(i.ID)==1 then
GUI.RedeployMinimapSignal(i.ID,i.X,i.Y)else
GUI.CreateMinimapSignalRGBA(i.ID,i.X,i.Y,i.R,i.G,i.B,i.Alpha,i.type)end end end end end
function BriefingSystem.RefreshMarkerOfList(y8iv,YTQ_)
if BriefingSystem.listOfMarkers[y8iv]then
local sS6A=BriefingSystem.listOfMarkers[y8iv][YTQ_]
if sS6A and sS6A.ID then
if GUI.IsMinimapSignalExisting(sS6A.ID)==1 then
GUI.RedeployMinimapSignal(sS6A.ID,sS6A.X,sS6A.Y)else
GUI.CreateMinimapSignalRGBA(sS6A.ID,sS6A.X,sS6A.Y,sS6A.R,sS6A.G,sS6A.B,sS6A.Alpha,sS6A.type)end end end end
function BriefingSystem.EnableBriefingSkipButton(bzROmd3,Pu)if
bzROmd3 ==nil or bzROmd3 ==GUI.GetPlayerID()then
XGUIEng.DisableButton("/InGame/ThroneRoom/Main/Skip",Pu and 0 or 1)end end
function BriefingSystem_CheckFader(TWz1hOn,O4p95NnC)
if BriefingSystem.GlobalSystem.timer<O4p95NnC then
if
TWz1hOn==1 then FadeIn(O4p95NnC)else FadeOut(O4p95NnC)end;BriefingSystem.faderJob=nil;return true end end
function ThroneRoomCameraControl()
if Camera.GetCameraBehaviour(5)==5 then
local yuuiHp=BriefingSystem.Flight
if yuuiHp.systemEnabled then local p=yuuiHp.StartTime;local DHwTC=yuuiHp.FlyTime;local D=yuuiHp.StartPosition or
yuuiHp.EndPosition;local R=yuuiHp.EndPosition;local k3=
yuuiHp.StartRotation or yuuiHp.EndRotation
local x=yuuiHp.EndRotation
local fYsm=yuuiHp.StartZoomAngle or yuuiHp.EndZoomAngle;local c=yuuiHp.EndZoomAngle
local Co6Pnt=yuuiHp.StartZoomDistance or yuuiHp.EndZoomDistance;local sxBUAww=yuuiHp.EndZoomDistance
local CyyGa=yuuiHp.StartFOV or yuuiHp.EndFOV;local Z=yuuiHp.EndFOV
local si=yuuiHp.StartUV0 or yuuiHp.EndUV0;local vVn4vww=yuuiHp.EndUV0
local lGSMU=yuuiHp.StartUV1 or yuuiHp.EndUV1;local vDYDgya=yuuiHp.EndUV1;local I71BEfil=Logic.GetTimeMs()/1000
local t6BK=math
if yuuiHp.Follow then local DxgC=GetPosition(yuuiHp.Follow)
if R.X~=DxgC.X and R.Y~=
DxgC.Y then yuuiHp.StartPosition=R;yuuiHp.EndPosition=DxgC end
if yuuiHp.StartPosition and
Logic.IsEntityMoving(GetEntityId(yuuiHp.Follow))then
local O=t6BK.rad(Logic.GetEntityOrientation(GetEntityId(yuuiHp.Follow)))
local xYwRtEabC,hjX7,v9rW,ha9Bwjaj=yuuiHp.StartPosition.X,yuuiHp.StartPosition.Y,DxgC.X,DxgC.Y;xYwRtEabC=xYwRtEabC-v9rW;hjX7=hjX7-ha9Bwjaj
local kanlP=t6BK.sqrt(
xYwRtEabC*xYwRtEabC+hjX7*hjX7)*10;local xP2iXC=kanlP* (DHwTC-I71BEfil+p)local ILREJu=kanlP*
(I71BEfil+p)
R={X=DxgC.X+t6BK.cos(O)*kanlP,Y=DxgC.Y+
t6BK.sin(O)*kanlP}yuuiHp.FollowTemp=yuuiHp.FollowTemp or{}
local E=BriefingSystem.InterpolationFactor(I71BEfil,I71BEfil,1,yuuiHp.FollowTemp)
xYwRtEabC,hjX7,z1=BriefingSystem.GetCameraPosition(DxgC,R,E)D={X=xYwRtEabC,Y=hjX7,Z=z1}else D=DxgC end;R=D end
local laNN7pb=BriefingSystem.InterpolationFactor(p,I71BEfil,DHwTC,yuuiHp)
local EoHp,hReWRM3q,B7WIX=BriefingSystem.GetCameraPosition(D,R,laNN7pb)
local nkgL=Co6Pnt+ (sxBUAww-Co6Pnt)*laNN7pb;local J=fYsm+ (c-fYsm)*laNN7pb
local lkr=k3+ (x-k3)*laNN7pb;local JWhvws=nkgL*t6BK.cos(t6BK.rad(J))
Camera.ThroneRoom_SetLookAt(EoHp,hReWRM3q,B7WIX)
Camera.ThroneRoom_SetPosition(EoHp+
t6BK.cos(t6BK.rad(lkr-90))*JWhvws,hReWRM3q+
t6BK.sin(t6BK.rad(lkr-90))*JWhvws,B7WIX+ (nkgL)*t6BK.sin(t6BK.rad(J)))
Camera.ThroneRoom_SetFOV(CyyGa+ (Z-CyyGa)*laNN7pb)
BriefingSystem.SetBriefingSplashscreenUV(si,vVn4vww,lGSMU,vDYDgya,laNN7pb)else local V0bDjtn=BriefingSystem.Flight.Cutscene
if V0bDjtn then local J=V0bDjtn.StartPosition or
V0bDjtn.EndPosition;local w=V0bDjtn.EndPosition;local p0x2pj=
V0bDjtn.StartLookAt or V0bDjtn.EndLookAt
local X7iiGlpy=V0bDjtn.EndLookAt;local YuuBu=V0bDjtn.StartFOV or V0bDjtn.EndFOV
local JInBq=V0bDjtn.EndFOV;local xoopiLqU=V0bDjtn.StartTime;local c01CiT6=V0bDjtn.FlyTime
local TEaUp=Logic.GetTimeMs()/1000;local T2fzd=V0bDjtn.StartUV0 or V0bDjtn.EndUV0
local Wo=V0bDjtn.EndUV0;local vUtGN4=V0bDjtn.StartUV1 or V0bDjtn.EndUV1
local KaX=V0bDjtn.EndUV1
local U=BriefingSystem.InterpolationFactor(xoopiLqU,TEaUp,c01CiT6,V0bDjtn)
if not p0x2pj.X then
local N=GetPosition(p0x2pj[1],(p0x2pj[2]or 0))
if p0x2pj[3]then N.X=N.X+
p0x2pj[3]*math.cos(math.rad(p0x2pj[4]))N.Y=N.Y+p0x2pj[3]*
math.sin(math.rad(p0x2pj[4]))end;p0x2pj=N end
if not X7iiGlpy.X then
local OioSf8pX=GetPosition(X7iiGlpy[1],(X7iiGlpy[2]or 0))
if X7iiGlpy[3]then
OioSf8pX.X=OioSf8pX.X+X7iiGlpy[3]*
math.cos(math.rad(X7iiGlpy[4]))
OioSf8pX.Y=OioSf8pX.Y+X7iiGlpy[3]*
math.sin(math.rad(X7iiGlpy[4]))end;X7iiGlpy=OioSf8pX end
local z0,nWf3lxy,NGIM=BriefingSystem.CutsceneGetPosition(p0x2pj,X7iiGlpy,U)Camera.ThroneRoom_SetLookAt(z0,nWf3lxy,NGIM)
if not J.X then local HUU7Kn=GetPosition(J[1],(
J[2]or 0))if J[3]then HUU7Kn.X=HUU7Kn.X+J[3]*
math.cos(math.rad(J[4]))
HUU7Kn.Y=HUU7Kn.Y+
J[3]*math.sin(math.rad(J[4]))end;J=HUU7Kn end
if not w.X then local yFlLsq=GetPosition(w[1],(w[2]or 0))if w[3]then
yFlLsq.X=
yFlLsq.X+w[3]*math.cos(math.rad(w[4]))
yFlLsq.Y=yFlLsq.Y+w[3]*math.sin(math.rad(w[4]))end;w=yFlLsq end
local XXYvnZ,Ofeq9l,Mbrvptw=BriefingSystem.CutsceneGetPosition(J,w,U)
Camera.ThroneRoom_SetPosition(XXYvnZ,Ofeq9l,Mbrvptw)
Camera.ThroneRoom_SetFOV(YuuBu+ (JInBq-YuuBu)*U)
BriefingSystem.SetBriefingSplashscreenUV(T2fzd,Wo,vUtGN4,KaX,factor)end end;BriefingSystem.ControlInformationText()
if
BriefingSystem.MCSelectionIsShown then
local TD="/InGame/SoundOptionsMain/RightContainer/SoundProviderComboBoxContainer"
if XGUIEng.IsWidgetShown(TD)==0 then
BriefingSystem.MCSelectionIsShown=false;BriefingSystem.OnConfirmed()end end end end;function ThroneRoomLeftClick()end
function BriefingSystem.CutsceneGetPosition(ohUzbR,FG4,HGlwCdN)local u0Cs=ohUzbR.X+
(FG4.X-ohUzbR.X)*HGlwCdN;local tN0zoS=ohUzbR.Y+
(FG4.Y-ohUzbR.Y)*HGlwCdN;local Zn=ohUzbR.Z+
(FG4.Z-ohUzbR.Z)*HGlwCdN;return u0Cs,tN0zoS,Zn end
function BriefingSystem.CutsceneSaveFlight(MloA5bTF,tbQ,oNJ7,Zg7GW,blUXv5ns)BriefingSystem.Flight.Cutscene=
BriefingSystem.Flight.Cutscene or{}
BriefingSystem.Flight.Cutscene.StartPosition=MloA5bTF
BriefingSystem.Flight.Cutscene.StartLookAt=tbQ
BriefingSystem.Flight.Cutscene.StartFOV=oNJ7
BriefingSystem.Flight.Cutscene.StartTime=Logic.GetTimeMs()/1000;BriefingSystem.Flight.Cutscene.FlyTime=0
BriefingSystem.Flight.Cutscene.StartUV0=Zg7GW
BriefingSystem.Flight.Cutscene.StartUV1=blUXv5ns end
function BriefingSystem.CutsceneFlyTo(q1M,IhaFMz22,Yn,Mwq8rV,v,Nm)BriefingSystem.Flight.Cutscene=
BriefingSystem.Flight.Cutscene or{}BriefingSystem.Flight.Cutscene.StartTime=
Logic.GetTimeMs()/1000
BriefingSystem.Flight.Cutscene.FlyTime=Mwq8rV
BriefingSystem.Flight.Cutscene.EndPosition=q1M
BriefingSystem.Flight.Cutscene.EndLookAt=IhaFMz22;BriefingSystem.Flight.Cutscene.EndFOV=Yn
BriefingSystem.Flight.Cutscene.EndUV0=v;BriefingSystem.Flight.Cutscene.EndUV1=Nm end
function BriefingSystem.CutsceneStopFlight()BriefingSystem.Flight.Cutscene=
BriefingSystem.Flight.Cutscene or{}
BriefingSystem.Flight.Cutscene.StartPosition=BriefingSystem.Flight.Cutscene.EndPosition
BriefingSystem.Flight.Cutscene.StartLookAt=BriefingSystem.Flight.Cutscene.EndLookAt
BriefingSystem.Flight.Cutscene.StartFOV=BriefingSystem.Flight.Cutscene.EndFOV end
function BriefingSystem.InterpolationFactor(Z,wMVKiK4,DL8BA,R9iF)local CS3ZU6vC=1
if Z+DL8BA>wMVKiK4 then
CS3ZU6vC=(wMVKiK4-Z)/DL8BA
if R9iF and wMVKiK4 ==R9iF.TempLastLogicTime then
CS3ZU6vC=CS3ZU6vC+
(
Framework.GetTimeMs()-R9iF.TempLastFrameworkTime)/DL8BA/1000*
Game.GameTimeGetFactor(GUI.GetPlayerID())else R9iF.TempLastLogicTime=wMVKiK4
R9iF.TempLastFrameworkTime=Framework.GetTimeMs()end end;if CS3ZU6vC>1 then CS3ZU6vC=1 end;return CS3ZU6vC end
function BriefingSystem.GetCameraPosition(hN,G,fKZ5Ao)
local Cyvh=hN.X+ (G.X-hN.X)*fKZ5Ao;local rjU=hN.Y+ (G.Y-hN.Y)*fKZ5Ao;local q
if hN.Z or G.Z then
q=(hN.Z or
Display.GetTerrainHeight(hN.X,hN.Y))+
((G.Z or
Display.GetTerrainHeight(G.X,G.Y))- (hN.Z or
Display.GetTerrainHeight(hN.X,hN.Y)))*fKZ5Ao else
q=
Display.GetTerrainHeight(Cyvh,rjU)* ((hN.ZRelative or 1)+
(
(G.ZRelative or 1)- (hN.ZRelative or 1))*fKZ5Ao)+
((hN.ZAdd or 0)+
((G.ZAdd or 0)- (hN.ZAdd or 0)))*fKZ5Ao end;return Cyvh,rjU,q end
function BriefingSystem.SaveFlight(R4Bv_P,YLt1L,GllN,hb,Ap_D1w,JeB,Qcb)
BriefingSystem.Flight.StartZoomAngle=GllN;BriefingSystem.Flight.StartZoomDistance=hb
BriefingSystem.Flight.StartRotation=YLt1L;BriefingSystem.Flight.StartPosition=R4Bv_P
BriefingSystem.Flight.StartFOV=Ap_D1w;BriefingSystem.Flight.StartUV0=JeB
BriefingSystem.Flight.StartUV1=Qcb end
function BriefingSystem.FlyTo(P3cFBkug,R,SmVH,Wm1DfLu0,hQUgbKod,WRhJsaV,vA,GDJG)local E3C9=BriefingSystem.Flight;E3C9.StartTime=
Logic.GetTimeMs()/1000;E3C9.FlyTime=WRhJsaV
E3C9.EndPosition=P3cFBkug;E3C9.EndRotation=R;E3C9.EndZoomAngle=SmVH;E3C9.EndZoomDistance=Wm1DfLu0
E3C9.EndFOV=hQUgbKod;E3C9.EndUV0=vA;E3C9.EndUV1=GDJG end
function BriefingSystem.StopFlight()local x=BriefingSystem.Flight
x.StartZoomAngle=x.EndZoomAngle;x.StartZoomDistance=x.EndZoomDistance;x.StartRotation=x.EndRotation
x.StartPosition=x.EndPosition;x.StartFOV=x.EndFOV;x.StartUV0=x.EndUV0;x.StartUV1=x.EndUV1;if x.Follow then
x.StartPosition=GetPosition(x.Follow)x.Follow=nil end end
function BriefingSystem.FollowFlight(zSudeRVt,sUYU,sW9j,Hnpk,z,MQ,Z3J,N75e,JJay)local ZXn_LqI=GetPosition(zSudeRVt)
ZXn_LqI.Z=Z3J or 0
BriefingSystem.FlyTo(ZXn_LqI,sUYU,sW9j,Hnpk,z,MQ,N75e,JJay)BriefingSystem.Flight.StartPosition=nil
BriefingSystem.Flight.Follow=zSudeRVt end;function BriefingSystem.IsBriefingActive()
return BriefingSystem.GlobalSystem~=nil and
BriefingSystem.GlobalSystem.isActive end
IsBriefingActive=BriefingSystem.IsBriefingActive
function BriefingSystem.SetBriefingPageTextPosition(pd)local G={GUI.GetScreenSize()}
local kKzIokN,QC6wgXaV=XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight")
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",kKzIokN,65)
if not pd.mc then
if BriefingSystem.BriefingTextPositionBackup then
local s=BriefingSystem.BriefingTextPositionBackup
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text",s[1],s[2])end
if pd.splashscreen then
if pd.centered then local O2=0
if pd.text then local _KUY=string.len(pd.text)O2=O2+
math.ceil((_KUY/80))local qVltI1D=0
local Dbhq,gCDkf47y=string.find(pd.text,"{cr}")while(gCDkf47y)do qVltI1D=qVltI1D+1
Dbhq,gCDkf47y=string.find(pd.text,"{cr}",gCDkf47y+1)end;O2=O2+
math.floor((qVltI1D/2))local n={GUI.GetScreenSize()}O2=(
n[2]/2)- (O2*10)end
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",kKzIokN,0+O2)
local kKzIokN,QC6wgXaV=XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text")if not BriefingSystem.BriefingTextPositionBackup then
BriefingSystem.BriefingTextPositionBackup={kKzIokN,QC6wgXaV}end
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text",kKzIokN,
38+O2)end end;return end
local kKzIokN,QC6wgXaV=XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight")if pd.mc.text and pd.mc.text~=""then
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/DialogTopChooseKnight/ChooseYourKnight",kKzIokN,5)end
local kKzIokN,QC6wgXaV=XGUIEng.GetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text")if not BriefingSystem.BriefingTextPositionBackup then
BriefingSystem.BriefingTextPositionBackup={kKzIokN,QC6wgXaV}end
XGUIEng.SetWidgetScreenPosition("/InGame/ThroneRoom/Main/MissionBriefing/Text",kKzIokN,42)end
function BriefingSystem.SetBriefingSplashscreenUV(iUTUFAj,_SrhE,pery2Ge,SR3C,QLI)if
not iUTUFAj or not _SrhE or not pery2Ge or not SR3C then return end
local Q="/InGame/ThroneRoomBars_2/BarTop"local S="/InGame/ThroneRoomBars_2/BarBottom"
local SG_q={GUI.GetScreenSize()}
local g=math.floor((SG_q[1]/SG_q[2])*10)==13
local cRpJ=iUTUFAj[1]+ (_SrhE[1]-iUTUFAj[1])*QLI
local q=iUTUFAj[2]+ (_SrhE[2]-iUTUFAj[2])*QLI
local gHF=pery2Ge[1]+ (SR3C[1]-pery2Ge[1])*QLI
local tJeWJm=pery2Ge[2]+ (SR3C[2]-pery2Ge[2])*QLI;if g then cRpJ=cRpJ+ (cRpJ*0.125)
gHF=gHF- (gHF*0.125)end
XGUIEng.SetMaterialUV(Q,1,cRpJ,q,gHF,tJeWJm)end
function BriefingSystem.SetBriefingPageOrSplashscreen(Jmwk,cWOtw3)local qKp="/InGame/ThroneRoomBars_2/BarTop"
local cR5Lq="/InGame/ThroneRoomBars_2/BarBottom"local OQ1ve={GUI.GetScreenSize()}
if not Jmwk.splashscreen then
XGUIEng.SetMaterialTexture(qKp,1,"")XGUIEng.SetMaterialTexture(cR5Lq,1,"")
XGUIEng.SetMaterialColor(qKp,1,0,0,0,255)XGUIEng.SetMaterialColor(cR5Lq,1,0,0,0,255)
if
BriefingSystem.BriefingBarSizeBackup then local fQKm=BriefingSystem.BriefingBarSizeBackup
XGUIEng.SetWidgetSize(qKp,fQKm[1],fQKm[2])BriefingSystem.BriefingBarSizeBackup=nil end;BriefingSystem.ShowBriefingBar(cWOtw3)return end
if Jmwk.splashscreen==true then
XGUIEng.SetMaterialTexture(qKp,1,"")XGUIEng.SetMaterialColor(qKp,1,0,0,0,255)
XGUIEng.SetMaterialUV(qKp,1,0,0,1,1)else XGUIEng.SetMaterialColor(cR5Lq,1,0,0,0,0)
XGUIEng.SetMaterialColor(qKp,1,255,255,255,255)
XGUIEng.SetMaterialTexture(qKp,1,Jmwk.splashscreen.image)end
if not BriefingSystem.BriefingBarSizeBackup then
local Ha_4jOX,fXhqvy=XGUIEng.GetWidgetSize(qKp)BriefingSystem.BriefingBarSizeBackup={Ha_4jOX,fXhqvy}end;local x=BriefingSystem.BriefingBarSizeBackup[1]
local Gq,TW9LRI=XGUIEng.GetWidgetSize("/InGame/ThroneRoomBars")XGUIEng.SetWidgetSize(qKp,x,TW9LRI)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars",0)XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2",1)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_Dodge",0)
XGUIEng.ShowWidget("/InGame/ThroneRoomBars_2_Dodge",0)XGUIEng.ShowWidget(qKp,1)end;BundleBriefingSystem:OverwriteGetPosition()end
function BundleBriefingSystem:OverwriteGetPosition()
GetPosition=function(N,kOC5Ih9G)kOC5Ih9G=kOC5Ih9G or 0
if
type(N)=="table"then return N else
if not IsExisting(N)then return{X=0,Y=0,Z=0+kOC5Ih9G}else
local CGsL=GetID(N)local w0Cqj,MMITWi,a04G3=Logic.EntityGetPos(CGsL)return
{X=w0Cqj,Y=MMITWi,Z=a04G3+kOC5Ih9G}end end end end;Core:RegisterBundle("BundleBriefingSystem")function Reward_Briefing(...)return
b_Reward_Briefing:new(...)end
b_Reward_Briefing={Name="Reward_Briefing",Description={en="Reward: Calls a function that creates a briefing and saves the returned briefing ID into the quest.",de="Lohn: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert."},Parameter={{ParameterType.Default,en="Briefing function",de="Funktion mit Briefing"}}}function b_Reward_Briefing:GetRewardTable()return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_Briefing:AddParameter(WnPDv,XGhZi)if(
WnPDv==0)then self.Function=XGhZi end end
function b_Reward_Briefing:CustomFunction(IutJO8Q)
local e=_G[self.Function](self,IutJO8Q)local Tj6Uj=GetQuestID(IutJO8Q.Identifier)
Quests[Tj6Uj].EmbeddedBriefing=e
if not e and QSB.DEBUG_CheckWhileRuntime then
local sy1=IutJO8Q.Identifier..": "..
self.Name..": '"..self.Function..
"' has not returned anything!"if IsBriefingActive()then GUI_Note(sy1)end;dbg(sy1)end end
function b_Reward_Briefing:DEBUG(vQU)
if
not type(_G[self.Function])=="function"then
dbg(vQU.Identifier..": "..
self.Name..": '"..self.Function.."' was not found!")return true end;return false end
function b_Reward_Briefing:Reset(TzXQ)local WP2BgOu=GetQuestID(TzXQ.Identifier)Quests[WP2BgOu].EmbeddedBriefing=
nil end;Core:RegisterBehavior(b_Reward_Briefing)function Reprisal_Briefing(...)return
b_Reprisal_Briefing:new(...)end
b_Reprisal_Briefing={Name="Reprisal_Briefing",Description={en="Reprisal: Calls a function that creates a briefing and saves the returned briefing ID into the quest.",de="Vergeltung: Ruft eine Funktion auf, die ein Briefing erzeugt und die zurueckgegebene ID in der Quest speichert."},Parameter={{ParameterType.Default,en="Briefing function",de="Funktion mit Briefing"}}}
function b_Reprisal_Briefing:GetReprisalTable()return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_Briefing:AddParameter(uR,lj)if(uR==0)then self.Function=lj end end
function b_Reprisal_Briefing:CustomFunction(Jz)
local vRq_8x1T=_G[self.Function](self,Jz)local sn=GetQuestID(Jz.Identifier)
Quests[sn].EmbeddedBriefing=vRq_8x1T
if not vRq_8x1T and QSB.DEBUG_CheckWhileRuntime then
local I_9=Jz.Identifier..": "..
self.Name..": '"..self.Function..
"' has not returned anything!"if IsBriefingActive()then GUI_Note(I_9)end;dbg(I_9)end end
function b_Reprisal_Briefing:DEBUG(CCEm1g)
if
not type(_G[self.Function])=="function"then
dbg(CCEm1g.Identifier..": "..self.Name..
": '"..self.Function.."' was not found!")return true end;return false end
function b_Reprisal_Briefing:Reset(mCSugCGp)
local K0A=GetQuestID(mCSugCGp.Identifier)Quests[K0A].EmbeddedBriefing=nil end;Core:RegisterBehavior(b_Reprisal_Briefing)function Trigger_Briefing(...)return
b_Trigger_Briefing:new(...)end
b_Trigger_Briefing={Name="Trigger_Briefing",Description={en="Trigger: after an embedded briefing of another quest has finished.",de="Ausloeser: wenn das eingebettete Briefing der angegebenen Quest beendet ist."},Parameter={{ParameterType.QuestName,en="Quest name",de="Questname"},{ParameterType.Number,en="Wait time",de="Wartezeit"}}}
function b_Trigger_Briefing:GetTriggerTable()return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_Briefing:AddParameter(FQXoHI,l7d4)if(FQXoHI==0)then self.Quest=l7d4 elseif(FQXoHI==1)then self.WaitTime=
tonumber(l7d4)or 0 end end
function b_Trigger_Briefing:CustomFunction(i)local n2kq=GetQuestID(self.Quest)
if
IsBriefingFinished(Quests[n2kq].EmbeddedBriefing)then
if self.WaitTime and self.WaitTime>0 then self.WaitTimeTimer=self.WaitTimeTimer or
Logic.GetTime()
if Logic.GetTime()>=self.WaitTimeTimer+
self.WaitTime then return true end else return true end end;return false end
function b_Trigger_Briefing:Interrupt(fjLl8iOL)local se=GetQuestID(self.Quest)Quests[se].EmbeddedBriefing=
nil;self.WaitTimeTimer=nil end
function b_Trigger_Briefing:Reset(TrMqziU)local SvII=GetQuestID(self.Quest)Quests[SvII].EmbeddedBriefing=
nil;self.WaitTimeTimer=nil end
function b_Trigger_Briefing:DEBUG(f)
if tonumber(self.WaitTime)==nil or
self.WaitTime<0 then
dbg(f.Identifier.." "..
self.Name..": waittime is nil or below 0!")return true elseif not IsValidQuest(self.Quest)then
dbg(f.Identifier..
" "..self.Name..": '"..self.Quest..
"' is not a valid quest!")return true end;return false end;Core:RegisterBehavior(b_Trigger_Briefing)
API=API or{}QSB=QSB or{}
BundleCastleStore={Global={Data={UpdateCastleStore=false,CastleStoreObjects={}},CastleStore={Data={CapacityBase=75,Goods={[Goods.G_Wood]={0,true,false,35},[Goods.G_Stone]={0,true,false,35},[Goods.G_Iron]={0,true,false,35},[Goods.G_Carcass]={0,true,false,15},[Goods.G_Grain]={0,true,false,15},[Goods.G_RawFish]={0,true,false,15},[Goods.G_Milk]={0,true,false,15},[Goods.G_Herb]={0,true,false,15},[Goods.G_Wool]={0,true,false,15},[Goods.G_Honeycomb]={0,true,false,15}}}}},Local={Data={},CastleStore={Data={}},Description={ShowCastle={Text={de="Finanzansicht",en="Financial view"}},ShowCastleStore={Text={de="Lageransicht",en="Storeage view"}},GoodButtonDisabled={Text={de="Diese Ware wird nicht angenommen.",en="This good will not be stored."}},CityTab={Title={de="Güter verwaren",en="Keep goods"},Text={de="- Lagert Waren im Burglager ein {cr}- Waren verbleiben auch im Lager, wenn Platz vorhanden ist",en="- Stores goods inside the store {cr}- Goods also remain in the warehouse when space is available"}},StorehouseTab={Title={de="Güter zwischenlagern",en="Store goods temporarily"},Text={de="- Lagert Waren im Burglager ein {cr}- Lagert waren wieder aus, sobald Platz frei wird",en="- Stores goods inside the store {cr}- Allows to extrac goods as soon as space becomes available"}},MultiTab={Title={de="Lager räumen",en="Clear store"},Text={de="- Lagert alle Waren aus {cr}- Benötigt Platz im Lagerhaus",en="- Removes all goods {cr}- Requires space in the storehouse"}}}}}
function BundleCastleStore.Global:Install()
QSB.CastleStore=BundleCastleStore.Global.CastleStore;self:OverwriteGameFunctions()
API.AddSaveGameAction(BundleCastleStore.Global.OnSaveGameLoaded)end
function BundleCastleStore.Global.CastleStore:New(tf0qkj)
assert(self==
BundleCastleStore.Global.CastleStore,"Can not be used from instance!")local jl=API.InstanceTable(self)jl.Data.PlayerID=tf0qkj
BundleCastleStore.Global.Data.CastleStoreObjects[tf0qkj]=jl;if not self.Data.UpdateCastleStore then self.Data.UpdateCastleStore=true
StartSimpleJobEx(BundleCastleStore.Global.CastleStore.UpdateStores)end
Logic.ExecuteInLuaLocalState(
[[
        QSB.CastleStore:CreateStore(]]..jl.Data.PlayerID..[[);
    ]])return jl end
function BundleCastleStore.Global.CastleStore:GetInstance(F2T)
assert(self==
BundleCastleStore.Global.CastleStore,"Can not be used from instance!")return
BundleCastleStore.Global.Data.CastleStoreObjects[F2T]end
function BundleCastleStore.Global.CastleStore:GetGoodAmountWithCastleStore(BPZ,fzyYm)
assert(
self==BundleCastleStore.Global.CastleStore,"Can not be used from instance!")local jk_dB=self:GetInstance(fzyYm)
local cW=GetPlayerGoodsInSettlement(BPZ,fzyYm,true)
if
jk_dB~=nil and BPZ~=Goods.G_Gold and
Logic.GetGoodCategoryForGoodType(BPZ)==GoodCategories.GC_Resource then cW=cW+jk_dB:GetAmount(BPZ)end;return cW end
function BundleCastleStore.Global.CastleStore:Dispose()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
Logic.ExecuteInLuaLocalState([[
        QSB.CastleStore:DeleteStore(]]..self.Data.PlayerID..[[);
    ]])BundleCastleStore.Global.Data.CastleStoreObjects[self.Data.PlayerID]=
nil end
function BundleCastleStore.Global.CastleStore:SetUperLimitInStorehouseForGoodType(te,OSCwwfL)
assert(
self~=BundleCastleStore.Global.CastleStore,"Can not be used in static context!")self.Data.Goods[te][4]=OSCwwfL
Logic.ExecuteInLuaLocalState(
[[
        BundleCastleStore.Local.Data.CastleStore[]]..self.Data.PlayerID..[[].Goods[]]..
te..[[][4] = ]]..OSCwwfL..[[
    ]])return self end
function BundleCastleStore.Global.CastleStore:SetStorageLimit(q)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")self.Data.CapacityBase=math.floor(q/2)
Logic.ExecuteInLuaLocalState(
[[
        BundleCastleStore.Local.Data.CastleStore[]]..self.Data.PlayerID..
[[].CapacityBase = ]]..math.floor(q/2)..[[
    ]])return self end
function BundleCastleStore.Global.CastleStore:GetAmount(uMMGO4)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")if self.Data.Goods[uMMGO4]then
return self.Data.Goods[uMMGO4][1]end;return 0 end
function BundleCastleStore.Global.CastleStore:GetTotalAmount()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")local Jj2oei5V=0
for f6WMU3lw,J in pairs(self.Data.Goods)do Jj2oei5V=Jj2oei5V+J[1]end;return Jj2oei5V end
function BundleCastleStore.Global.CastleStore:GetLimit()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")local TuSFS=0
local yMxua=Logic.GetHeadquarters(self.Data.PlayerID)
if yMxua~=0 then TuSFS=Logic.GetUpgradeLevel(yMxua)end;local ll=self.Data.CapacityBase;for DUP73=1,(TuSFS+1),1 do ll=ll*2 end
return ll end
function BundleCastleStore.Global.CastleStore:IsGoodAccepted(Y5y9bTM)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
return self.Data.Goods[Y5y9bTM][2]==true end
function BundleCastleStore.Global.CastleStore:SetGoodAccepted(Y,qks5vL)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")self.Data.Goods[Y][2]=qks5vL==true
Logic.ExecuteInLuaLocalState(
[[
        QSB.CastleStore:SetAccepted(
            ]]..self.Data.PlayerID..
[[, ]]..Y..[[, ]]..
tostring(qks5vL==true)..[[
        )
    ]])return self end
function BundleCastleStore.Global.CastleStore:IsGoodLocked(eW)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")return self.Data.Goods[eW][3]==true end
function BundleCastleStore.Global.CastleStore:SetGoodLocked(EaAe7cpY,kSlV)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")self.Data.Goods[EaAe7cpY][3]=kSlV==true
Logic.ExecuteInLuaLocalState(
[[
        QSB.CastleStore:SetLocked(
            ]]..self.Data.PlayerID..
[[, ]]..EaAe7cpY..[[, ]]..
tostring(kSlV==true)..[[
        )
    ]])return self end
function BundleCastleStore.Global.CastleStore:ActivateTemporaryMode()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnStorehouseTabClicked(QSB.CastleStore, ]]..
self.Data.PlayerID..[[)
    ]])return self end
function BundleCastleStore.Global.CastleStore:ActivateStockMode()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnCityTabClicked(QSB.CastleStore, ]]..
self.Data.PlayerID..[[)
    ]])return self end
function BundleCastleStore.Global.CastleStore:ActivateOutsourceMode()
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
Logic.ExecuteInLocalLuaState([[
        QSB.CastleStore.OnMultiTabClicked(QSB.CastleStore, ]]..
self.Data.PlayerID..[[)
    ]])return self end
function BundleCastleStore.Global.CastleStore:Store(lPv7H,a7wO)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
if self:IsGoodAccepted(lPv7H)then
if self:GetLimit()>=
self:GetTotalAmount()+a7wO then
local zq=Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.Data.PlayerID))
if
GetPlayerResources(lPv7H,self.Data.PlayerID)> (
self.Data.Goods[lPv7H][4]* (zq+1))then
AddGood(lPv7H,a7wO* (-1),self.Data.PlayerID)self.Data.Goods[lPv7H][1]=
self.Data.Goods[lPv7H][1]+a7wO
Logic.ExecuteInLuaLocalState(
[[
                    QSB.CastleStore:SetAmount(
                        ]]..
self.Data.PlayerID..[[, ]]..
lPv7H..[[, ]]..self.Data.Goods[lPv7H][1]..
[[
                    )
                ]])end end end;return self end
function BundleCastleStore.Global.CastleStore:Outsource(CewK,OzYBK)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
local P=Logic.GetUpgradeLevel(Logic.GetHeadquarters(self.Data.PlayerID))
if
Logic.GetPlayerUnreservedStorehouseSpace(self.Data.PlayerID)>=OzYBK then
if self:GetAmount(CewK)>=OzYBK then
AddGood(CewK,OzYBK,self.Data.PlayerID)self.Data.Goods[CewK][1]=
self.Data.Goods[CewK][1]-OzYBK
Logic.ExecuteInLuaLocalState(
[[
                QSB.CastleStore:SetAmount(
                    ]]..
self.Data.PlayerID..[[, ]]..
CewK..[[, ]]..self.Data.Goods[CewK][1]..
[[
                )
            ]])end end;return self end
function BundleCastleStore.Global.CastleStore:Add(jgY,EG)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
if self:IsGoodAccepted(jgY)then for st=1,EG,1 do
if
self:GetLimit()>self:GetTotalAmount()then self.Data.Goods[jgY][1]=self.Data.Goods[jgY][1]+
1 end end
Logic.ExecuteInLuaLocalState(
[[
            QSB.CastleStore:SetAmount(
                ]]..self.Data.PlayerID..
[[, ]]..jgY..[[, ]]..
self.Data.Goods[jgY][1]..[[
            )
        ]])end;return self end
function BundleCastleStore.Global.CastleStore:Remove(pqUzL,Ks)
assert(self~=
BundleCastleStore.Global.CastleStore,"Can not be used in static context!")
if self:GetAmount(pqUzL)>0 then
local jO0cx=
(Ks<=self:GetAmount(pqUzL)and Ks)or self:GetAmount(pqUzL)self.Data.Goods[pqUzL][1]=
self.Data.Goods[pqUzL][1]-jO0cx
Logic.ExecuteInLuaLocalState(
[[
            QSB.CastleStore:SetAmount(
                ]]..
self.Data.PlayerID..[[, ]]..
pqUzL..[[, ]]..self.Data.Goods[pqUzL][1]..
[[
            )
        ]])end;return self end
function BundleCastleStore.Global.CastleStore.UpdateStores()
assert(self==nil,"This method is only procedural!")
for kI0WSxN,seWRJAo in
pairs(BundleCastleStore.Global.Data.CastleStoreObjects)do
if seWRJAo~=nil then
local b9EtJBg=Logic.GetUpgradeLevel(Logic.GetHeadquarters(seWRJAo.Data.PlayerID))
for n,D in pairs(seWRJAo.Data.Goods)do
if D~=nil then
if D[2]==true then
local Rmb_6b2I=GetPlayerResources(n,seWRJAo.Data.PlayerID)local w7C=seWRJAo:GetAmount(n)
if
Rmb_6b2I< (
seWRJAo.Data.Goods[n][4]* (b9EtJBg+1))then
if D[3]==false then local kM9I7435=
(seWRJAo.Data.Goods[n][4]* (b9EtJBg+1))-Rmb_6b2I;kM9I7435=(
kM9I7435 >10 and 10)or kM9I7435;for bAZ=1,kM9I7435,1 do
seWRJAo:Outsource(n,1)end end else local _=(Rmb_6b2I>10 and 10)or Rmb_6b2I;for CD=1,_,1 do
seWRJAo:Store(n,1)end end else local MW=(seWRJAo:GetAmount(n)>=10 and 10)or
seWRJAo:GetAmount(n)for F=1,MW,1 do
seWRJAo:Outsource(n,1)end end end end end end end;function BundleCastleStore.Global.OnSaveGameLoaded()
API.Bridge("BundleCastleStore.Local:OverwriteGetStringTableText()")end
function BundleCastleStore.Global:OverwriteGameFunctions()
QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore=QuestTemplate.IsObjectiveCompleted
QuestTemplate.IsObjectiveCompleted=function(m,v)local rW=v.Type;local c0Z1IHx0=v.Data;if v.Completed~=nil then
return v.Completed end
if rW==Objective.Produce then
local OVX0Cw=GetPlayerGoodsInSettlement(c0Z1IHx0[1],m.ReceivingPlayer,true)
local Xg2nd=QSB.CastleStore:GetInstance(m.ReceivingPlayer)
if Xg2nd and
Logic.GetGoodCategoryForGoodType(c0Z1IHx0[1])==GoodCategories.GC_Resource then OVX0Cw=OVX0Cw+
Xg2nd:GetAmount(c0Z1IHx0[1])end;if

(not c0Z1IHx0[3]and OVX0Cw>=c0Z1IHx0[2])or(c0Z1IHx0[3]and OVX0Cw<c0Z1IHx0[2])then v.Completed=true end else return
QuestTemplate.IsObjectiveCompleted_Orig_QSB_CastleStore(m,v)end end
QuestTemplate.SendGoods=function(UhAbzx8)
for h_x7s1=1,UhAbzx8.Objectives[0]do
if
UhAbzx8.Objectives[h_x7s1].Type==Objective.Deliver then
if
UhAbzx8.Objectives[h_x7s1].Data[3]==nil then
local A1CI=UhAbzx8.Objectives[h_x7s1].Data[1]
local AIoUuI=UhAbzx8.Objectives[h_x7s1].Data[2]
local g6qy=QSB.CastleStore:GetGoodAmountWithCastleStore(A1CI,UhAbzx8.ReceivingPlayer,true)
if g6qy>=AIoUuI then local f=UhAbzx8.ReceivingPlayer
local lvqou=

UhAbzx8.Objectives[h_x7s1].Data[6]and UhAbzx8.Objectives[h_x7s1].Data[6]or UhAbzx8.SendingPlayer;local RJQT={}RJQT.Good=A1CI;RJQT.Amount=AIoUuI;RJQT.PlayerID=lvqou
RJQT.ID=nil
UhAbzx8.Objectives[h_x7s1].Data[5]=RJQT
UhAbzx8.Objectives[h_x7s1].Data[3]=1;QuestMerchants[#QuestMerchants+1]=RJQT
if A1CI==
Goods.G_Gold then local Yy=Logic.GetHeadquarters(f)if Yy==0 then
Yy=Logic.GetStoreHouse(f)end
UhAbzx8.Objectives[h_x7s1].Data[3]=Logic.CreateEntityAtBuilding(Entities.U_GoldCart,Yy,0,lvqou)
Logic.HireMerchant(UhAbzx8.Objectives[h_x7s1].Data[3],lvqou,A1CI,AIoUuI,UhAbzx8.ReceivingPlayer)Logic.RemoveGoodFromStock(Yy,A1CI,AIoUuI)if
MapCallback_DeliverCartSpawned then
MapCallback_DeliverCartSpawned(UhAbzx8,UhAbzx8.Objectives[h_x7s1].Data[3],A1CI)end elseif
A1CI==Goods.G_Water then local nhPDx=Logic.GetMarketplace(f)
UhAbzx8.Objectives[h_x7s1].Data[3]=Logic.CreateEntityAtBuilding(Entities.U_Marketer,nhPDx,0,lvqou)
Logic.HireMerchant(UhAbzx8.Objectives[h_x7s1].Data[3],lvqou,A1CI,AIoUuI,UhAbzx8.ReceivingPlayer)Logic.RemoveGoodFromStock(nhPDx,A1CI,AIoUuI)if
MapCallback_DeliverCartSpawned then
MapCallback_DeliverCartSpawned(UhAbzx8,UhAbzx8.Objectives[h_x7s1].Data[3],A1CI)end else
if
Logic.GetGoodCategoryForGoodType(A1CI)==GoodCategories.GC_Resource then
local lHm=Logic.GetStoreHouse(lvqou)local RxtOio=Logic.GetNumberOfGoodTypesOnOutStock(lHm)
if
RxtOio~=nil then
for aEU=0,RxtOio-1 do
local H=Logic.GetGoodTypeOnOutStockByIndex(lHm,aEU)local SjAQ=Logic.GetAmountOnOutStockByIndex(lHm,aEU)
if
SjAQ>=AIoUuI then Logic.RemoveGoodFromStock(lHm,H,AIoUuI,false)end end end;local s=Logic.GetStoreHouse(f)
local Kf=GetPlayerResources(A1CI,f)
if Kf<AIoUuI then local DF9=AIoUuI-Kf;AddGood(A1CI,Kf* (-1),f)
QSB.CastleStore:GetInstance(UhAbzx8.ReceivingPlayer):Remove(A1CI,DF9)else AddGood(A1CI,AIoUuI* (-1),f)end
UhAbzx8.Objectives[h_x7s1].Data[3]=Logic.CreateEntityAtBuilding(Entities.U_ResourceMerchant,s,0,lvqou)
Logic.HireMerchant(UhAbzx8.Objectives[h_x7s1].Data[3],lvqou,A1CI,AIoUuI,UhAbzx8.ReceivingPlayer)else
Logic.StartTradeGoodGathering(f,lvqou,A1CI,AIoUuI,0)end end end end end end end end
function BundleCastleStore.Local:Install()
QSB.CastleStore=BundleCastleStore.Local.CastleStore;self:OverwriteGameFunctions()
self:OverwriteGetStringTableText()end
function BundleCastleStore.Local.CastleStore:CreateStore(WF_l1)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
local t={StoreMode=1,CapacityBase=75,Goods={[Goods.G_Wood]={0,true,false,35},[Goods.G_Stone]={0,true,false,35},[Goods.G_Iron]={0,true,false,35},[Goods.G_Carcass]={0,true,false,15},[Goods.G_Grain]={0,true,false,15},[Goods.G_RawFish]={0,true,false,15},[Goods.G_Milk]={0,true,false,15},[Goods.G_Herb]={0,true,false,15},[Goods.G_Wool]={0,true,false,15},[Goods.G_Honeycomb]={0,true,false,15}}}self.Data[WF_l1]=t end
function BundleCastleStore.Local.CastleStore:DeleteStore(_)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")self.Data[_]=nil end
function BundleCastleStore.Local.CastleStore:GetAmount(uF7E2bX,chQIUjLI)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if not self:HasCastleStore(uF7E2bX)then return 0 end
return self.Data[uF7E2bX].Goods[chQIUjLI][1]end
function BundleCastleStore.Local.CastleStore:GetGoodAmountWithCastleStore(aXmg1,Ww3E)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")local qPIdVRz=GetPlayerGoodsInSettlement(aXmg1,Ww3E,true)
if
self:HasCastleStore(Ww3E)then
if
aXmg1 ~=Goods.G_Gold and Logic.GetGoodCategoryForGoodType(aXmg1)==
GoodCategories.GC_Resource then qPIdVRz=qPIdVRz+self:GetAmount(Ww3E,aXmg1)end end;return qPIdVRz end
function BundleCastleStore.Local.CastleStore:GetTotalAmount(SRIxdI1)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if not self:HasCastleStore(SRIxdI1)then return 0 end;local fO4lcG=0;for XYq2,w4Q in pairs(self.Data[SRIxdI1].Goods)do
fO4lcG=fO4lcG+w4Q[1]end;return fO4lcG end
function BundleCastleStore.Local.CastleStore:SetAmount(O,UMSpjWj,jK1jRlc)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")if not self:HasCastleStore(O)then return end
self.Data[O].Goods[UMSpjWj][1]=jK1jRlc;return self end
function BundleCastleStore.Local.CastleStore:IsAccepted(ny,P4J7c)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")if not self:HasCastleStore(ny)then return false end;if not
self.Data[ny].Goods[P4J7c]then return false end;return
self.Data[ny].Goods[P4J7c][2]==true end
function BundleCastleStore.Local.CastleStore:SetAccepted(ff,fa5H,Y)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if self:HasCastleStore(ff)then if self.Data[ff].Goods[fa5H]then self.Data[ff].Goods[fa5H][2]=
Y==true end end;return self end
function BundleCastleStore.Local.CastleStore:IsLocked(sUqw2a,Hv2H)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if not self:HasCastleStore(sUqw2a)then return false end
if not self.Data[sUqw2a].Goods[Hv2H]then return false end;return
self.Data[sUqw2a].Goods[Hv2H][3]==true end
function BundleCastleStore.Local.CastleStore:SetLocked(j,hogStN8z,EOcgN1)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if self:HasCastleStore(j)then if self.Data[j].Goods[hogStN8z]then self.Data[j].Goods[hogStN8z][3]=
EOcgN1 ==true end end;return self end
function BundleCastleStore.Local.CastleStore:HasCastleStore(jp)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")return self.Data[jp]~=nil end
function BundleCastleStore.Local.CastleStore:GetStore(aQaXL)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")return self.Data[aQaXL]end
function BundleCastleStore.Local.CastleStore:GetLimit(A)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")local OmAS=0;local jm4DF1=Logic.GetHeadquarters(A)if jm4DF1 ~=0 then
OmAS=Logic.GetUpgradeLevel(jm4DF1)end;local bkR=self.Data[A].CapacityBase;for Qe=1,(OmAS+1),1
do bkR=bkR*2 end;return bkR end
function BundleCastleStore.Local.CastleStore:OnStorehouseTabClicked(zgqnJquk)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")self.Data[zgqnJquk].StoreMode=1
self:UpdateBehaviorTabs(zgqnJquk)
GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]]..
zgqnJquk..
[[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, true);
            Store:SetGoodLocked(k, false);
        end
    ]])end
function BundleCastleStore.Local.CastleStore:OnCityTabClicked(js3OuR)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")self.Data[js3OuR].StoreMode=2
self:UpdateBehaviorTabs(js3OuR)
GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]]..
js3OuR..
[[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, true);
            Store:SetGoodLocked(k, true);
        end
    ]])end
function BundleCastleStore.Local.CastleStore:OnMultiTabClicked(Jv)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")self.Data[Jv].StoreMode=3
self:UpdateBehaviorTabs(Jv)
GUI.SendScriptCommand([[
        local Store = QSB.CastleStore:GetInstance(]]..Jv..
[[);
        for k, v in pairs(Store.Data.Goods) do
            Store:SetGoodAccepted(k, false);
        end
    ]])end
function BundleCastleStore.Local.CastleStore:GoodClicked(I9,L5jl9h_q)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if self:HasCastleStore(I9)then
local MR4jXXI=XGUIEng.GetCurrentWidgetID()
GUI.SendScriptCommand([[
            local Store = QSB.CastleStore:GetInstance(]]..
I9 ..
[[);
            local Accepted = not Store:IsGoodAccepted(]]..
L5jl9h_q..
[[)
            Store:SetGoodAccepted(]]..L5jl9h_q..[[, Accepted);
        ]])end end
function BundleCastleStore.Local.CastleStore:DestroyGoodsClicked(b)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if self:HasCastleStore(b)then QSB.CastleStore.ToggleStore()end end
function BundleCastleStore.Local.CastleStore:SelectionChanged(a69P0L)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")
if self:HasCastleStore(a69P0L)then local Xwixbug=GUI.GetSelectedEntity()if
Logic.GetHeadquarters(a69P0L)==Xwixbug then self:ShowCastleMenu()else
self:RestoreStorehouseMenu()end end end
function BundleCastleStore.Local.CastleStore:UpdateBehaviorTabs(C)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")if
not QSB.CastleStore:HasCastleStore(GUI.GetPlayerID())then return end
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons",0)
if self.Data[C].StoreMode==1 then
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonUp",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down",1)elseif self.Data[C].StoreMode==2 then
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonUp",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Down",1)else
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/StorehouseTabButtonDown",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/CityTabButtonDown",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/Tab03Up",1)end end
function BundleCastleStore.Local.CastleStore:UpdateGoodsDisplay(u,b)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")if not self:HasCastleStore(u)then return end
local qUMCqx="/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods"local NbZ=""if self:GetLimit(u)==self:GetTotalAmount(u)then
NbZ="{@color:255,32,32,255}"end
for _KOapu,N in
pairs(self.Data[u].Goods)do local Eb=Logic.GetGoodTypeName(_KOapu)
local tSsrDhy=qUMCqx.."/"..Eb.."/Amount"local kjI=qUMCqx.."/"..Eb.."/Button"local k=qUMCqx..
"/"..Eb.."/BG"
XGUIEng.SetText(tSsrDhy,"{center}"..NbZ..N[1])XGUIEng.DisableButton(kjI,0)
if self:IsAccepted(u,_KOapu)then
XGUIEng.SetMaterialColor(kjI,0,255,255,255,255)XGUIEng.SetMaterialColor(kjI,1,255,255,255,255)
XGUIEng.SetMaterialColor(kjI,7,255,255,255,255)else XGUIEng.SetMaterialColor(kjI,0,190,90,90,255)
XGUIEng.SetMaterialColor(kjI,1,190,90,90,255)XGUIEng.SetMaterialColor(kjI,7,190,90,90,255)end end end
function BundleCastleStore.Local.CastleStore:UpdateStorageLimit(aN)
assert(self==
BundleCastleStore.Local.CastleStore,"Can not be used from instance!")if not self:HasCastleStore(aN)then return end
local iBCc=XGUIEng.GetCurrentWidgetID()local w=GUI.GetPlayerID()
local J=QSB.CastleStore:GetTotalAmount(w)local qYa=QSB.CastleStore:GetLimit(w)
local YpKVWt=XGUIEng.GetStringTableText("UI_Texts/StorageLimit_colon")
local mDCOZ="{center}"..YpKVWt.." "..J.."/"..qYa;XGUIEng.SetText(iBCc,mDCOZ)end
function BundleCastleStore.Local.CastleStore:ToggleStore()
assert(self==nil,"This function is procedural!")
if QSB.CastleStore:HasCastleStore(GUI.GetPlayerID())then
if
Logic.GetHeadquarters(GUI.GetPlayerID())==GUI.GetSelectedEntity()then
if
XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle")==1 then
QSB.CastleStore.ShowCastleStoreMenu(QSB.CastleStore)else
QSB.CastleStore.ShowCastleMenu(QSB.CastleStore)end end end end
function BundleCastleStore.Local.CastleStore:RestoreStorehouseMenu()
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons",1)
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity/Goods",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InCity",0)
SetIcon("/InGame/Root/Normal/AlignBottomRight/DialogButtons/PlayerButtons/DestroyGoods",{16,8})
local EA="/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/"
SetIcon(EA.."StorehouseTabButtonUp/up/B_StoreHouse",{3,13})
SetIcon(EA.."StorehouseTabButtonDown/down/B_StoreHouse",{3,13})
SetIcon(EA.."CityTabButtonUp/up/CityBuildingsNumber",{8,1})
SetIcon(EA.."TabButtons/CityTabButtonDown/down/CityBuildingsNumber",{8,1})
SetIcon(EA.."TabButtons/Tab03Up/up/B_Castle_ME",{3,14})
SetIcon(EA.."Tab03Down/down/B_Castle_ME",{3,14})
for Sbs7O,BAcy in
ipairs{"G_Carcass","G_Grain","G_Milk","G_RawFish","G_Iron","G_Wood","G_Stone","G_Honeycomb","G_Herb","G_Wool"}do
local EA="/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/InStorehouse/Goods/"
XGUIEng.SetMaterialColor(EA..BAcy.."/Button",0,255,255,255,255)
XGUIEng.SetMaterialColor(EA..BAcy.."/Button",1,255,255,255,255)
XGUIEng.SetMaterialColor(EA..BAcy.."/Button",7,255,255,255,255)end end
function BundleCastleStore.Local.CastleStore:ShowCastleMenu()
local p="/InGame/Root/Normal/AlignBottomRight/"XGUIEng.ShowWidget(p.."Selection/BGBig",0)XGUIEng.ShowWidget(
p.."Selection/Storehouse",0)XGUIEng.ShowWidget(
p.."Selection/BGSmall",1)XGUIEng.ShowWidget(
p.."Selection/Castle",1)
if g_HideSoldierPayment~=
nil then
XGUIEng.ShowWidget(p.."Selection/Castle/Treasury/Payment",0)
XGUIEng.ShowWidget(p.."Selection/Castle/LimitSoldiers",0)end;GUI_BuildingInfo.PaymentLevelSliderUpdate()
GUI_BuildingInfo.TaxationLevelSliderUpdate()GUI_Trade.StorehouseSelected()
local ySH6,N88ly=XGUIEng.GetWidgetLocalPosition(p..
"Selection/AnchorInfoForSmall")
XGUIEng.SetWidgetLocalPosition(p.."Selection/Info",ySH6,N88ly)
XGUIEng.ShowWidget(p.."DialogButtons/PlayerButtons",1)
XGUIEng.ShowWidget(p.."DialogButtons/PlayerButtons/DestroyGoods",1)
XGUIEng.DisableButton(p.."DialogButtons/PlayerButtons/DestroyGoods",0)
SetIcon(p.."DialogButtons/PlayerButtons/DestroyGoods",{10,9})end
function BundleCastleStore.Local.CastleStore:ShowCastleStoreMenu()
local Ogr8mgSN="/InGame/Root/Normal/AlignBottomRight/"
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Selection/BGSmall",0)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Castle",0)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/BGSmall",0)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/BGBig",1)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse",1)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse/AmountContainer",0)
XGUIEng.ShowAllSubWidgets(Ogr8mgSN.."Selection/Storehouse/TabButtons",1)GUI_Trade.StorehouseSelected()
local VXpZbxT,GP2b=XGUIEng.GetWidgetLocalPosition(Ogr8mgSN..
"Selection/AnchorInfoForBig")
XGUIEng.SetWidgetLocalPosition(Ogr8mgSN.."Selection/Info",VXpZbxT,GP2b)
XGUIEng.ShowWidget(Ogr8mgSN.."DialogButtons/PlayerButtons",1)
XGUIEng.ShowWidget(Ogr8mgSN.."DialogButtons/PlayerButtons/DestroyGoods",1)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse/InStorehouse",1)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse/InMulti",0)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse/InCity",1)
XGUIEng.ShowAllSubWidgets(Ogr8mgSN.."Selection/Storehouse/InCity/Goods",0)
XGUIEng.ShowWidget(Ogr8mgSN.."Selection/Storehouse/InCity/Goods/G_Beer",1)
XGUIEng.DisableButton(Ogr8mgSN.."DialogButtons/PlayerButtons/DestroyGoods",0)local K=Ogr8mgSN.."DialogButtons/PlayerButtons/"local kzsvLS6=Ogr8mgSN..
"Selection/Storehouse/TabButtons/"
SetIcon(K.."DestroyGoods",{3,14})
SetIcon(kzsvLS6 .."StorehouseTabButtonUp/up/B_StoreHouse",{10,9})
SetIcon(kzsvLS6 .."StorehouseTabButtonDown/down/B_StoreHouse",{10,9})
SetIcon(kzsvLS6 .."CityTabButtonUp/up/CityBuildingsNumber",{15,6})
SetIcon(kzsvLS6 .."CityTabButtonDown/down/CityBuildingsNumber",{15,6})
SetIcon(kzsvLS6 .."Tab03Up/up/B_Castle_ME",{7,1})
SetIcon(kzsvLS6 .."Tab03Down/down/B_Castle_ME",{7,1})self:UpdateBehaviorTabs(GUI.GetPlayerID())end
function BundleCastleStore.Local:OverwriteGetStringTableText()
GetStringTableText_Orig_QSB_CatsleStore=XGUIEng.GetStringTableText
XGUIEng.GetStringTableText=function(SMSfEVE)local MV=
(Network.GetDesiredLanguage()=="de"and"de")or"en"
local WOvkq=GUI.GetSelectedEntity()local PK8TNd=GUI.GetPlayerID()
local x=XGUIEng.GetCurrentWidgetID()
if SMSfEVE=="UI_ObjectNames/DestroyGoods"then
if
XGUIEng.IsWidgetShown("/InGame/Root/Normal/AlignBottomRight/Selection/Castle")==1 then return
BundleCastleStore.Local.Description.ShowCastleStore.Text[MV]else return
BundleCastleStore.Local.Description.ShowCastle.Text[MV]end end
if SMSfEVE=="UI_ObjectDescription/DestroyGoods"then return""end
if SMSfEVE=="UI_ObjectNames/CityBuildingsNumber"then
if Logic.GetHeadquarters(PK8TNd)==
WOvkq then return
BundleCastleStore.Local.Description.CityTab.Title[MV]end end
if SMSfEVE=="UI_ObjectDescription/CityBuildingsNumber"then
if
Logic.GetHeadquarters(PK8TNd)==WOvkq then return
BundleCastleStore.Local.Description.CityTab.Text[MV]end end
if SMSfEVE=="UI_ObjectNames/B_StoreHouse"then
if
Logic.GetHeadquarters(PK8TNd)==WOvkq then return
BundleCastleStore.Local.Description.StorehouseTab.Title[MV]end end
if SMSfEVE=="UI_ObjectDescription/B_StoreHouse"then
if Logic.GetHeadquarters(PK8TNd)==
WOvkq then return
BundleCastleStore.Local.Description.StorehouseTab.Text[MV]end end
if SMSfEVE=="UI_ObjectNames/B_Castle_ME"then
local LMolhB="/InGame/Root/Normal/AlignBottomRight/Selection/Storehouse/TabButtons/"local mWWARyN=LMolhB.."Tab03Down/down/B_Castle_ME"
local V5pLu=LMolhB.."Tab03Up/up/B_Castle_ME"
if XGUIEng.GetWidgetPathByID(x)==mWWARyN or
XGUIEng.GetWidgetPathByID(x)==V5pLu then
if
Logic.GetHeadquarters(PK8TNd)==WOvkq then return
BundleCastleStore.Local.Description.MultiTab.Title[MV]end end end
if SMSfEVE=="UI_ObjectDescription/B_Castle_ME"then
if
Logic.GetHeadquarters(PK8TNd)==WOvkq then return
BundleCastleStore.Local.Description.MultiTab.Text[MV]end end
if SMSfEVE=="UI_ButtonDisabled/NotEnoughGoods"then
if
Logic.GetHeadquarters(PK8TNd)==WOvkq then return
BundleCastleStore.Local.Description.GoodButtonDisabled.Text[MV]end end;return GetStringTableText_Orig_QSB_CatsleStore(SMSfEVE)end end
function BundleCastleStore.Local:OverwriteGameFunctions()
GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore=GameCallback_GUI_SelectionChanged
GameCallback_GUI_SelectionChanged=function(mHHq)
GameCallback_GUI_SelectionChanged_Orig_QSB_CastleStore(mHHq)
QSB.CastleStore:SelectionChanged(GUI.GetPlayerID())end;GUI_Trade.GoodClicked_Orig_QSB_CastleStore=GUI_Trade.GoodClicked
GUI_Trade.GoodClicked=function()
local KUFxe2=Goods[XGUIEng.GetWidgetNameByID(XGUIEng.GetWidgetsMotherID(XGUIEng.GetCurrentWidgetID()))]local IwvBqpMw=GUI.GetSelectedEntity()local j6I3=GUI.GetPlayerID()if
Logic.IsEntityInCategory(IwvBqpMw,EntityCategories.Storehouse)==1 then
GUI_Trade.GoodClicked_Orig_QSB_CastleStore()return end
QSB.CastleStore:GoodClicked(j6I3,KUFxe2)end
GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore=GUI_Trade.DestroyGoodsClicked
GUI_Trade.DestroyGoodsClicked=function()local B=GUI.GetSelectedEntity()
local BiMFbf=GUI.GetPlayerID()if
Logic.IsEntityInCategory(B,EntityCategories.Storehouse)==1 then
GUI_Trade.DestroyGoodsClicked_Orig_QSB_CastleStore()return end
QSB.CastleStore:DestroyGoodsClicked(BiMFbf)end;GUI_Trade.SellUpdate_Orig_QSB_CastleStore=GUI_Trade.SellUpdate
GUI_Trade.SellUpdate=function()
local o=GUI.GetSelectedEntity()local HXWDDA=GUI.GetPlayerID()if
Logic.IsEntityInCategory(o,EntityCategories.Storehouse)==1 then
GUI_Trade.SellUpdate_Orig_QSB_CastleStore()return end
QSB.CastleStore:UpdateGoodsDisplay(HXWDDA)end
GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore=GUI_Trade.CityTabButtonClicked
GUI_Trade.CityTabButtonClicked=function()local A6lEy9=GUI.GetSelectedEntity()
local Mw=GUI.GetPlayerID()if
Logic.IsEntityInCategory(A6lEy9,EntityCategories.Storehouse)==1 then
GUI_Trade.CityTabButtonClicked_Orig_QSB_CastleStore()return end
QSB.CastleStore:OnCityTabClicked(Mw)end
GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore=GUI_Trade.StorehouseTabButtonClicked
GUI_Trade.StorehouseTabButtonClicked=function()local CX1=GUI.GetSelectedEntity()
local Xk5Sma_=GUI.GetPlayerID()if
Logic.IsEntityInCategory(CX1,EntityCategories.Storehouse)==1 then
GUI_Trade.StorehouseTabButtonClicked_Orig_QSB_CastleStore()return end
QSB.CastleStore:OnStorehouseTabClicked(Xk5Sma_)end
GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore=GUI_Trade.MultiTabButtonClicked
GUI_Trade.MultiTabButtonClicked=function()local NIFAPqV=GUI.GetSelectedEntity()
local K9JDW=GUI.GetPlayerID()if
Logic.IsEntityInCategory(NIFAPqV,EntityCategories.Storehouse)==1 then
GUI_Trade.MultiTabButtonClicked_Orig_QSB_CastleStore()return end
QSB.CastleStore:OnMultiTabClicked(K9JDW)end
GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore=GUI_BuildingInfo.StorageLimitUpdate
GUI_BuildingInfo.StorageLimitUpdate=function()local gy=GUI.GetSelectedEntity()
local Q4V7x=GUI.GetPlayerID()if
Logic.IsEntityInCategory(gy,EntityCategories.Storehouse)==1 then
GUI_BuildingInfo.StorageLimitUpdate_Orig_QSB_CastleStore()return end
QSB.CastleStore:UpdateStorageLimit(Q4V7x)end
GUI_Interaction.SendGoodsClicked=function()
local hCf3AB,jD11V0=GUI_Interaction.GetPotentialSubQuestAndType(g_Interaction.CurrentMessageQuestIndex)if not hCf3AB then return end
local GX3slY=GUI_Interaction.GetPotentialSubQuestIndex(g_Interaction.CurrentMessageQuestIndex)local jJF=hCf3AB.Objectives[1].Data[1]
local ZIz_1roD=hCf3AB.Objectives[1].Data[2]local UVyP={jJF,ZIz_1roD}
local _0_R0U,g0r=AreCostsAffordable(UVyP,true)local c=GUI.GetPlayerID()
if Logic.GetGoodCategoryForGoodType(jJF)==
GoodCategories.GC_Resource then
g0r=XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources")_0_R0U=false
if QSB.CastleStore:IsLocked(c,jJF)then _0_R0U=
GetPlayerResources(jJF,c)>=ZIz_1roD else
_0_R0U=(GetPlayerResources(jJF,c)+
QSB.CastleStore:GetAmount(c,jJF))>=ZIz_1roD end end
local PCM=hCf3AB.Objectives[1].Data[6]and
hCf3AB.Objectives[1].Data[6]or hCf3AB.SendingPlayer;local uu=PlayerSectorTypes.Thief
local K=CanEntityReachTarget(PCM,Logic.GetStoreHouse(GUI.GetPlayerID()),Logic.GetStoreHouse(PCM),
nil,uu)
if K==false then
local Zjp6E6q=XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_GenericUnreachable")Message(Zjp6E6q)return end
if _0_R0U==true then Sound.FXPlay2DSound("ui\\menu_click")
GUI.QuestTemplate_SendGoods(GX3slY)
GUI_FeedbackSpeech.Add("SpeechOnly_CartsSent",g_FeedbackSpeech.Categories.CartsUnderway,nil,nil)else Message(g0r)end end
GUI_Tooltip.SetCosts=function(PIScAA17,MMB5lhJ,_y)
local qp2NS=XGUIEng.GetWidgetPathByID(PIScAA17)local BFV=qp2NS.."/1Good"local jK1l=qp2NS.."/2Goods"local W=0;local h8FxVlg7;local S6eMwE9Z
for jUrb=2,#
MMB5lhJ,2 do if MMB5lhJ[jUrb]~=0 then W=W+1 end end
if W==0 then XGUIEng.ShowWidget(BFV,0)
XGUIEng.ShowWidget(jK1l,0)return elseif W==1 then XGUIEng.ShowWidget(BFV,1)
XGUIEng.ShowWidget(jK1l,0)h8FxVlg7=BFV.."/Good1Of1"elseif W==2 then XGUIEng.ShowWidget(BFV,0)
XGUIEng.ShowWidget(jK1l,1)h8FxVlg7=jK1l.."/Good1Of2"S6eMwE9Z=jK1l.."/Good2Of2"elseif W>2 then
GUI.AddNote("Debug: Invalid Costs table. Not more than 2 GoodTypes allowed.")end;local Vx=1
for XVq=1,#MMB5lhJ,2 do
if MMB5lhJ[XVq+1]~=0 then local K=MMB5lhJ[XVq]
local JXE=MMB5lhJ[XVq+1]local psjIkopQ;local _0KWP
if Vx==1 then psjIkopQ=h8FxVlg7 .."/Icon"
_0KWP=h8FxVlg7 .."/Amount"else psjIkopQ=S6eMwE9Z.."/Icon"_0KWP=S6eMwE9Z.."/Amount"end
SetIcon(psjIkopQ,g_TexturePositions.Goods[K],44)local WiIFZyi=GUI.GetPlayerID()local p3bFAUJ_
if _y==true then
p3bFAUJ_=GetPlayerGoodsInSettlement(K,WiIFZyi,true)
if
Logic.GetGoodCategoryForGoodType(K)==GoodCategories.GC_Resource then
if not QSB.CastleStore:IsLocked(WiIFZyi,K)then p3bFAUJ_=p3bFAUJ_+
QSB.CastleStore:GetAmount(WiIFZyi,K)end end else local HJZaK;local RN
if K==Goods.G_Gold then RN=Logic.GetHeadquarters(WiIFZyi)
HJZaK=Logic.GetIndexOnOutStockByGoodType(RN,K)else RN=Logic.GetStoreHouse(WiIFZyi)
HJZaK=Logic.GetIndexOnOutStockByGoodType(RN,K)end
if HJZaK~=-1 then
p3bFAUJ_=Logic.GetAmountOnOutStockByGoodType(RN,K)else RN=GUI.GetSelectedEntity()
if RN~=nil then if
Logic.GetIndexOnOutStockByGoodType(RN,K)==nil then
RN=Logic.GetRefillerID(GUI.GetSelectedEntity())end
p3bFAUJ_=Logic.GetAmountOnOutStockByGoodType(RN,K)else p3bFAUJ_=0 end end end;local QeIo0sp9=""
if p3bFAUJ_<JXE then QeIo0sp9="{@script:ColorRed}"end
if JXE>0 then
XGUIEng.SetText(_0KWP,"{center}"..QeIo0sp9 ..JXE)else XGUIEng.SetText(_0KWP,"")end;Vx=Vx+1 end end end end;Core:RegisterBundle("BundleCastleStore")API=API or{}QSB=
QSB or{}
function API.ActivateSingleStop()if not GUI then
API.Bridge("API.ActivateSingleStop()")return end
BundleBuildingButtons.Local:AddOptionalButton(2,BundleBuildingButtons.Local.ButtonDefaultSingleStop_Action,BundleBuildingButtons.Local.ButtonDefaultSingleStop_Tooltip,BundleBuildingButtons.Local.ButtonDefaultSingleStop_Update)end;ActivateSingleStop=API.ActivateSingleStop
function API.DeactivateSingleStop()if not GUI then
API.Bridge("API.DeactivateSingleStop()")return end
BundleBuildingButtons.Local:DeleteOptionalButton(2)end;DeactivateSingleStop=API.DeactivateSingleStop
function API.UseDowngrade(G4mFn)if not GUI then
API.Bridge(
"API.UseDowngrade("..tostring(G4mFn)..")")return end;BundleBuildingButtons.Local.Data.Downgrade=
G4mFn==true end;UseDowngrade=API.UseDowngrade
function API.UseBreedSheeps(lW2YKsYF)if not GUI then
API.Bridge("API.UseBreedSheeps("..
tostring(lW2YKsYF)..")")return end;BundleBuildingButtons.Local.Data.BreedSheeps=
lW2YKsYF==true
if lW2YKsYF==true then
local Iv=MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Sheep]MerchantSystem.BasePrices[Goods.G_Sheep]=Iv
API.Bridge(
"MerchantSystem.BasePrices[Goods.G_Sheep] = "..Iv)else
local IXUS2Byl=BundleBuildingButtons.Local.Data.SheepMoneyCost
MerchantSystem.BasePrices[Goods.G_Sheep]=IXUS2Byl
API.Bridge("MerchantSystem.BasePrices[Goods.G_Sheep] = "..IXUS2Byl)end end;UseBreedSheeps=API.UseBreedSheeps
function API.UseBreedCattle(onE1C)if not GUI then
API.Bridge("API.UseBreedCattle("..
tostring(onE1C)..")")return end;BundleBuildingButtons.Local.Data.BreedCattle=
onE1C==true
if onE1C==true then
local boxCiv=MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Cow]MerchantSystem.BasePrices[Goods.G_Cow]=boxCiv
API.Bridge(
"MerchantSystem.BasePrices[Goods.G_Cow] = "..boxCiv)else
local SE4aJ=BundleBuildingButtons.Local.Data.CattleMoneyCost;MerchantSystem.BasePrices[Goods.G_Cow]=SE4aJ
API.Bridge(
"MerchantSystem.BasePrices[Goods.G_Cow] = "..SE4aJ)end end;UseBreedCattle=API.UseBreedCattle
function API.SetSheepGrainCost(EWSmVLQF)
if not GUI then API.Bridge("API.SetSheepGrainCost("..
EWSmVLQF..")")return end
BundleBuildingButtons.Local.Data.SheepCosts=EWSmVLQF end;SetSheepGrainCost=API.SetSheepGrainCost
function API.SetCattleGrainCost(pnZTk)if not GUI then
API.Bridge(
"API.SetCattleGrainCost("..pnZTk..")")return end
BundleBuildingButtons.Local.Data.CattleCosts=pnZTk end;SetCattleGrainCost=API.SetCattleGrainCost
function API.SetSheepNeeded(L6KlrW6Q)if not GUI then
API.Bridge("API.SetSheepNeeded("..
L6KlrW6Q..")")return end;if type(L6KlrW6Q)~="number"or
L6KlrW6Q<0 or L6KlrW6Q>5 then
API.Dbg("API.SetSheepNeeded: Needed amount is invalid!")end
BundleBuildingButtons.Local.Data.SheepNeeded=L6KlrW6Q end;SetSheepNeeded=API.SetSheepNeeded
function API.SetCattleNeeded(fh)if not GUI then
API.Bridge("API.SetCattleNeeded("..fh..")")return end;if type(fh)~="number"or fh<0 or
fh>5 then
API.Dbg("API.SetCattleNeeded: Needed amount is invalid!")end
BundleBuildingButtons.Local.Data.CattleNeeded=fh end;SetCattleNeeded=API.SetCattleNeeded
function API.AddCustomBuildingButton(s,K,TI,G)
if not GUI then
API.Bridge(
"API.AddCustomBuildingButton("..tostring(s)..
","..tostring(K)..","..
tostring(TI)..","..tostring(G)..",)")return end;if(type(s)~="number"or(s<1 or s>2))then
API.Dbg("API.AddCustomBuildingButton: Index must be 1 or 2!")return end
if
(
type(K)~="function"or type(TI)~="function"or type(G)~="function")then
API.Dbg("API.AddCustomBuildingButton: Action, tooltip and update must be functions!")return end;return
BundleBuildingButtons.Local:AddOptionalButton(s,K,TI,G)end;AddBuildingButton=API.AddCustomBuildingButton
function API.RemoveCustomBuildingButton(NTsGl)if not GUI then
API.Dbg(
"API.RemoveCustomBuildingButton("..tostring(NTsGl)..")")return end;if
(type(NTsGl)~="number"or(
NTsGl<1 or NTsGl>2))then
API.Dbg("API.RemoveCustomBuildingButton: Index must be 1 or 2!")return end;return
BundleBuildingButtons.Local:DeleteOptionalButton(NTsGl)end;DeleteBuildingButton=API.RemoveCustomBuildingButton
BundleBuildingButtons={Global={Data={}},Local={Data={OptionalButton1={UseButton=false},OptionalButton2={UseButton=false},StoppedBuildings={},Downgrade=true,BreedCattle=true,CattleCosts=10,CattleNeeded=3,CattleKnightTitle=0,CattleMoneyCost=300,BreedSheeps=true,SheepCosts=10,SheepNeeded=3,SheepKnightTitle=0,SheepMoneyCost=300},Description={Downgrade={Title={de="Rückbau",en="Downgrade"},Text={de="- Reißt eine Stufe des Geb?udes ein {cr}- Der überschüssige Arbeiter wird entlassen",en="- Destroy one level of this building {cr}- The surplus worker will be dismissed"},Disabled={de="Kann nicht zurückgebaut werden!",en="Can not be downgraded yet!"}},BuyCattle={Title={de="Nutztier kaufen",en="Buy Farm animal"},Text={de="- Kauft ein Nutztier {cr}- Nutztiere produzieren Rohstoffe",en="- Buy a farm animal {cr}- Farm animals produce resources"},Disabled={de="Kauf ist nicht möglich!",en="Buy not possible!"}},SingleStop={Title={de="Arbeit anhalten/aufnehmen",en="Start/Stop Work"},Text={de="- Startet oder stoppe die Arbeit in diesem Betrieb",en="- Continue or stop work for this building"}}}}}function BundleBuildingButtons.Global:Install()end
function BundleBuildingButtons.Local:Install()
MerchantSystem.BasePricesOrigBundleBuildingButtons={}
MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Sheep]=MerchantSystem.BasePrices[Goods.G_Sheep]
MerchantSystem.BasePricesOrigBundleBuildingButtons[Goods.G_Cow]=MerchantSystem.BasePrices[Goods.G_Cow]
MerchantSystem.BasePrices[Goods.G_Sheep]=BundleBuildingButtons.Local.Data.SheepMoneyCost
MerchantSystem.BasePrices[Goods.G_Cow]=BundleBuildingButtons.Local.Data.CattleMoneyCost;self:OverwriteHouseMenuButtons()
self:OverwriteBuySiegeEngine()self:OverwriteToggleTrap()
self:OverwriteGateOpenClose()self:OverwriteAutoToggle()
Core:AppendFunction("GameCallback_GUI_SelectionChanged",self.OnSelectionChanged)end
function BundleBuildingButtons.Local:BuyAnimal(MfT3l)
Sound.FXPlay2DSound("ui\\menu_click")local QA=Logic.GetEntityType(MfT3l)
if
QA==Entities.B_CattlePasture then
local NY=BundleBuildingButtons.Local.Data.CattleCosts* (-1)
GUI.SendScriptCommand([[
            local pID = Logic.EntityGetPlayer(]]..
MfT3l..
[[)
            local x, y = Logic.GetBuildingApproachPosition(]]..MfT3l..

[[)
            Logic.CreateEntity(Entities.A_X_Cow01, x, y, 0, pID)
            AddGood(Goods.G_Grain, ]]..NY..[[, pID)
        ]])elseif QA==Entities.B_SheepPasture then local MGUnKw4B=
BundleBuildingButtons.Local.Data.SheepCosts* (-1)
GUI.SendScriptCommand(
[[
            local pID = Logic.EntityGetPlayer(]]..
MfT3l..
[[)
            local x, y = Logic.GetBuildingApproachPosition(]]..MfT3l..

[[)
            Logic.CreateEntity(Entities.A_X_Sheep01, x, y, 0, pID)
            AddGood(Goods.G_Grain, ]]..MGUnKw4B..[[, pID)
        ]])end end
function BundleBuildingButtons.Local:DowngradeBuilding()
Sound.FXPlay2DSound("ui\\menu_click")local l=GUI.GetSelectedEntity()GUI.DeselectEntity(l)
if
Logic.GetUpgradeLevel(l)>0 then
local itDmAq=math.ceil(Logic.GetEntityMaxHealth(l)/2)if Logic.GetEntityHealth(l)>=itDmAq then
GUI.SendScriptCommand([[Logic.HurtEntity(]]..l..[[, ]]..itDmAq..
[[)]])end else
local X8Rz_h=Logic.GetEntityMaxHealth(l)
GUI.SendScriptCommand([[Logic.HurtEntity(]]..l..[[, ]]..X8Rz_h..[[)]])end end
function BundleBuildingButtons.Local:AddOptionalButton(j,fD,xAUv9N,Ac33NhV)
assert(j==1 or j==2)
local yiQ1={XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateAutoToggle"),XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateOpenClose")}
BundleBuildingButtons.Local.Data["OptionalButton"..j].WidgetID=yiQ1[j]
BundleBuildingButtons.Local.Data["OptionalButton"..j].UseButton=true
BundleBuildingButtons.Local.Data["OptionalButton"..j].ActionFunction=fD
BundleBuildingButtons.Local.Data["OptionalButton"..j].TooltipFunction=xAUv9N
BundleBuildingButtons.Local.Data["OptionalButton"..j].UpdateFunction=Ac33NhV end
function BundleBuildingButtons.Local:DeleteOptionalButton(P44nujnL)
assert(P44nujnL==1 or P44nujnL==2)
local dSrAKHOd={XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateAutoToggle"),XGUIEng.GetWidgetID("/InGame/Root/Normal/BuildingButtons/GateOpenClose")}
BundleBuildingButtons.Local.Data["OptionalButton"..P44nujnL].WidgetID=dSrAKHOd[P44nujnL]
BundleBuildingButtons.Local.Data["OptionalButton"..P44nujnL].UseButton=false;BundleBuildingButtons.Local.Data["OptionalButton"..P44nujnL].ActionFunction=
nil;BundleBuildingButtons.Local.Data[
"OptionalButton"..P44nujnL].TooltipFunction=
nil;BundleBuildingButtons.Local.Data[
"OptionalButton"..P44nujnL].UpdateFunction=
nil end
function BundleBuildingButtons.Local:OverwriteAutoToggle()
GUI_BuildingButtons.GateAutoToggleClicked=function()
local B=XGUIEng.GetCurrentWidgetID()local V4n=GUI.GetSelectedEntity()
if not
BundleBuildingButtons.Local.Data.OptionalButton1.ActionFunction then return end
BundleBuildingButtons.Local.Data.OptionalButton1.ActionFunction(B,V4n)end
GUI_BuildingButtons.GateAutoToggleMouseOver=function()
local nNM=XGUIEng.GetCurrentWidgetID()local fH8B=GUI.GetSelectedEntity()
if not
BundleBuildingButtons.Local.Data.OptionalButton1.TooltipFunction then return end
BundleBuildingButtons.Local.Data.OptionalButton1.TooltipFunction(nNM,fH8B)end
GUI_BuildingButtons.GateAutoToggleUpdate=function()
local IAge97J=XGUIEng.GetCurrentWidgetID()local mx=GUI.GetSelectedEntity()
local U9KT=Logic.GetEntityMaxHealth(mx)local Vyx=Logic.GetEntityHealth(mx)
SetIcon(IAge97J,{8,16})
if


mx==nil or Logic.IsBuilding(mx)==0 or not
BundleBuildingButtons.Local.Data.OptionalButton1.UpdateFunction or not
BundleBuildingButtons.Local.Data.OptionalButton1.UseButton or Logic.IsConstructionComplete(mx)==0 then XGUIEng.ShowWidget(IAge97J,0)return end
if


Logic.BuildingDoWorkersStrike(mx)==true or
Logic.IsBuildingBeingUpgraded(mx)==true or
Logic.IsBuildingBeingKnockedDown(mx)==true or Logic.IsBurning(mx)==true or U9KT-Vyx>0 then XGUIEng.ShowWidget(IAge97J,0)return end
BundleBuildingButtons.Local.Data.OptionalButton1.UpdateFunction(IAge97J,mx)end end
function BundleBuildingButtons.Local:OverwriteGateOpenClose()
GUI_BuildingButtons.GateOpenCloseClicked=function()
local Psw=XGUIEng.GetCurrentWidgetID()local l=GUI.GetSelectedEntity()
if not
BundleBuildingButtons.Local.Data.OptionalButton2.ActionFunction then return end
BundleBuildingButtons.Local.Data.OptionalButton2.ActionFunction(Psw,l)end
GUI_BuildingButtons.GateOpenCloseMouseOver=function()
local S=XGUIEng.GetCurrentWidgetID()local Ke=GUI.GetSelectedEntity()
if not
BundleBuildingButtons.Local.Data.OptionalButton2.TooltipFunction then return end
BundleBuildingButtons.Local.Data.OptionalButton2.TooltipFunction(S,Ke)end
GUI_BuildingButtons.GateOpenCloseUpdate=function()
local N=XGUIEng.GetCurrentWidgetID()local i=GUI.GetSelectedEntity()
local NTxpD=Logic.GetEntityMaxHealth(i)local Nje9s2=Logic.GetEntityHealth(i)SetIcon(N,{8,16})
if



i==nil or
Logic.IsBuilding(i)==0 or not
BundleBuildingButtons.Local.Data.OptionalButton2.UpdateFunction or not
BundleBuildingButtons.Local.Data.OptionalButton2.UseButton or Logic.IsConstructionComplete(i)==0 or Logic.IsBuilding(i)==0 then XGUIEng.ShowWidget(N,0)return end
if


Logic.BuildingDoWorkersStrike(i)==true or
Logic.IsBuildingBeingUpgraded(i)==true or
Logic.IsBuildingBeingKnockedDown(i)==true or Logic.IsBurning(i)==true or NTxpD-Nje9s2 >0 then XGUIEng.ShowWidget(N,0)return end
BundleBuildingButtons.Local.Data.OptionalButton2.UpdateFunction(N,i)end end
function BundleBuildingButtons.Local:OverwriteToggleTrap()
GUI_BuildingButtons.TrapToggleClicked=function()
BundleBuildingButtons.Local:DowngradeBuilding()end
GUI_BuildingButtons.TrapToggleMouseOver=function()
local Fj=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
BundleBuildingButtons.Local:TextNormal(BundleBuildingButtons.Local.Description.Downgrade.Title[Fj],BundleBuildingButtons.Local.Description.Downgrade.Text[Fj],BundleBuildingButtons.Local.Description.Downgrade.Disabled[Fj])end
GUI_BuildingButtons.TrapToggleUpdate=function()
local VL1A=XGUIEng.GetCurrentWidgetID()local X=GUI.GetSelectedEntity()
local FGzDGV=Logic.GetEntityName(X)local J7Bwul=Logic.GetEntityType(X)
local cS=GetTerritoryUnderEntity(X)local L2=Logic.GetEntityMaxHealth(X)
local SRm2=Logic.GetEntityHealth(X)local e=Logic.GetUpgradeLevel(X)
local kyb9GQ,lHEx=XGUIEng.GetWidgetLocalPosition("/InGame/Root/Normal/BuildingButtons/Upgrade")SetIcon(VL1A,{3,15})
XGUIEng.SetWidgetLocalPosition(VL1A,kyb9GQ+64,lHEx)if X==nil or Logic.IsBuilding(X)==0 then
XGUIEng.ShowWidget(VL1A,0)return end
if BundleConstructionControl then
if
Inside(FGzDGV,BundleConstructionControl.Local.Data.Entities)then XGUIEng.ShowWidget(VL1A,0)return end
if
Inside(J7Bwul,BundleConstructionControl.Local.Data.EntityTypes)then XGUIEng.ShowWidget(VL1A,0)return end
if
Inside(cS,BundleConstructionControl.Local.Data.OnTerritory)then XGUIEng.ShowWidget(VL1A,0)return end
for nINusLz2,ix1VnfFX in
pairs(BundleConstructionControl.Local.Data.EntityCategories)do if Logic.IsEntityInCategory(_BuildingID,ix1VnfFX)==1 then
XGUIEng.ShowWidget(VL1A,0)return end end end
if


Logic.IsConstructionComplete(X)==0 or
(
Logic.IsEntityInCategory(X,EntityCategories.OuterRimBuilding)==0 and
Logic.IsEntityInCategory(X,EntityCategories.CityBuilding)==0)or
not BundleBuildingButtons.Local.Data.Downgrade or e==0 then XGUIEng.ShowWidget(VL1A,0)return end
if


Logic.BuildingDoWorkersStrike(X)==true or
Logic.IsBuildingBeingUpgraded(X)==true or
Logic.IsBuildingBeingKnockedDown(X)==true or Logic.IsBurning(X)==true or L2-SRm2 >0 then XGUIEng.DisableButton(VL1A,1)else
XGUIEng.DisableButton(VL1A,0)end end end
function BundleBuildingButtons.Local:OverwriteBuySiegeEngine()
GUI_BuildingButtons.BuySiegeEngineCartMouseOver=function(fEKaQyzs,bxf5zvLH)
local N8XF3=(
Network.GetDesiredLanguage()=="de"and"de")or"en"local R=XGUIEng.GetCurrentWidgetID()
local DzeDyBG=GUI.GetSelectedEntity()local f=Logic.GetEntityType(DzeDyBG)
if
f~=Entities.B_SiegeEngineWorkshop and f~=Entities.B_CattlePasture and f~=
Entities.B_SheepPasture then return end
local Dn6={Logic.GetUnitCost(DzeDyBG,fEKaQyzs)}
if f==Entities.B_CattlePasture then
BundleBuildingButtons.Local:TextCosts(BundleBuildingButtons.Local.Description.BuyCattle.Title[N8XF3],BundleBuildingButtons.Local.Description.BuyCattle.Text[N8XF3],BundleBuildingButtons.Local.Description.BuyCattle.Disabled[N8XF3],{Goods.G_Grain,BundleBuildingButtons.Local.Data.CattleCosts},false)elseif f==Entities.B_SheepPasture then
BundleBuildingButtons.Local:TextCosts(BundleBuildingButtons.Local.Description.BuyCattle.Title[N8XF3],BundleBuildingButtons.Local.Description.BuyCattle.Text[N8XF3],BundleBuildingButtons.Local.Description.BuyCattle.Disabled[N8XF3],{Goods.G_Grain,BundleBuildingButtons.Local.Data.SheepCosts},false)else GUI_Tooltip.TooltipBuy(Dn6,nil,nil,bxf5zvLH)end end
GUI_BuildingButtons.BuySiegeEngineCartClicked_OrigTHEA_Buildings=GUI_BuildingButtons.BuySiegeEngineCartClicked
GUI_BuildingButtons.BuySiegeEngineCartClicked=function(Sf2dNg8)local i=GUI.GetSelectedEntity()
local eqxty=GUI.GetPlayerID()local dVuApQ=Logic.GetEntityType(i)
if
dVuApQ==Entities.B_CattlePasture or dVuApQ==Entities.B_SheepPasture then
BundleBuildingButtons.Local:BuyAnimal(i)else
GUI_BuildingButtons.BuySiegeEngineCartClicked_OrigTHEA_Buildings(Sf2dNg8)end end
GUI_BuildingButtons.BuySiegeEngineCartUpdate=function(ebhWRw7)local Gj=GUI.GetPlayerID()
local IQvmg2C=Logic.GetKnightTitle(Gj)local DYz=XGUIEng.GetCurrentWidgetID()
local fePNjzNA=GUI.GetSelectedEntity()local qb=Logic.GetEntityType(fePNjzNA)
local wG=GetPlayerResources(Goods.G_Grain,Gj)local NqYh=GetPosition(fePNjzNA)
if qb==Entities.B_SiegeEngineWorkshop then
XGUIEng.ShowWidget(DYz,1)
if ebhWRw7 ==Technologies.R_BatteringRam then SetIcon(DYz,{9,5})elseif ebhWRw7 ==
Technologies.R_SiegeTower then SetIcon(DYz,{9,6})elseif
ebhWRw7 ==Technologies.R_Catapult then SetIcon(DYz,{9,4})end elseif qb==Entities.B_CattlePasture then
local H=GetPlayerEntities(Gj,Entities.B_CattlePasture)
local C={Logic.GetPlayerEntitiesInArea(Gj,Entities.A_X_Cow01,NqYh.X,NqYh.Y,800,16)}
local je9=Logic.GetNumberOfPlayerEntitiesInCategory(Gj,EntityCategories.CattlePasture)local raVMP=#H*5;SetIcon(DYz,{3,16})
if
ebhWRw7 ==Technologies.R_Catapult then
if BundleBuildingButtons.Local.Data.BreedCattle then
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1)
if je9 >=raVMP then XGUIEng.DisableButton(DYz,1)elseif wG<
BundleBuildingButtons.Local.Data.CattleCosts then XGUIEng.DisableButton(DYz,1)elseif IQvmg2C<
BundleBuildingButtons.Local.Data.CattleKnightTitle then XGUIEng.DisableButton(DYz,1)elseif

C[1]<BundleBuildingButtons.Local.Data.CattleNeeded then XGUIEng.DisableButton(DYz,1)else
XGUIEng.DisableButton(DYz,0)end end else XGUIEng.ShowWidget(DYz,0)end elseif qb==Entities.B_SheepPasture then
local wvGS6zV=GetPlayerEntities(Gj,Entities.B_SheepPasture)
local jk7={Logic.GetPlayerEntitiesInArea(Gj,Entities.A_X_Sheep01,NqYh.X,NqYh.Y,800,16)}table.remove(jk7,1)
local j={Logic.GetPlayerEntitiesInArea(Gj,Entities.A_X_Sheep02,NqYh.X,NqYh.Y,800,16)}table.remove(j,1)
local Zzf4Och=Logic.GetNumberOfPlayerEntitiesInCategory(Gj,EntityCategories.SheepPasture)local Cj=#wvGS6zV*5;jk7=Array_Append(jk7,j)
SetIcon(DYz,{4,1})
if ebhWRw7 ==Technologies.R_Catapult then
if
BundleBuildingButtons.Local.Data.BreedSheeps then
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/BuyCatapultCart",1)
if Zzf4Och>=Cj then XGUIEng.DisableButton(DYz,1)elseif wG<
BundleBuildingButtons.Local.Data.SheepCosts then XGUIEng.DisableButton(DYz,1)elseif#jk7 <
BundleBuildingButtons.Local.Data.SheepKnightTitle then XGUIEng.DisableButton(DYz,1)elseif

#jk7 <BundleBuildingButtons.Local.Data.SheepNeeded then XGUIEng.DisableButton(DYz,1)else
XGUIEng.DisableButton(DYz,0)end end else XGUIEng.ShowWidget(DYz,0)end else XGUIEng.ShowWidget(DYz,0)return end
if
Logic.IsConstructionComplete(GUI.GetSelectedEntity())==0 then XGUIEng.ShowWidget(DYz,0)return end
if
qb~=Entities.B_SheepPasture and qb~=Entities.B_CattlePasture then local mZXPr1=Logic.TechnologyGetState(Gj,ebhWRw7)if
EnableRights==nil or EnableRights==false then
XGUIEng.DisableButton(DYz,0)return end;if
mZXPr1 ==TechnologyStates.Researched then XGUIEng.DisableButton(DYz,0)else
XGUIEng.DisableButton(DYz,1)end end end end
function BundleBuildingButtons.Local:OverwriteHouseMenuButtons()
HouseMenuStopProductionClicked_Orig_tHEA_SingleStop=HouseMenuStopProductionClicked
HouseMenuStopProductionClicked=function()
HouseMenuStopProductionClicked_Orig_tHEA_SingleStop()local bT=HouseMenu.Widget.CurrentBuilding;local Un=Entities[bT]
local qRY1vSFl=GUI.GetPlayerID()local vrEhUe_a=GetPlayerEntities(qRY1vSFl,Un)
for VQcat=1,#vrEhUe_a,1 do
if
BundleBuildingButtons.Local.Data.StoppedBuildings[vrEhUe_a[VQcat]]~=HouseMenu.StopProductionBool then
BundleBuildingButtons.Local.Data.StoppedBuildings[vrEhUe_a[VQcat]]=HouseMenu.StopProductionBool
GUI.SetStoppedState(vrEhUe_a[VQcat],HouseMenu.StopProductionBool)end end end end
function BundleBuildingButtons.Local:HouseMenuIcon(yxfb5r,GuBfKo3)
if type(GuBfKo3)=="table"then
if
type(GuBfKo3[3])=="string"then local zcXy=1
if XGUIEng.IsButton(yxfb5r)==1 then zcXy=7 end;local X7GI,ZOIyhzA,L7J1,D;X7GI=(_Coordinates[1]-1)*64;L7J1=(
_Coordinates[2]-1)*64
ZOIyhzA=(_Coordinates[1])*64;D=(_Coordinates[2])*64
XGUIEng.SetMaterialAlpha(yxfb5r,zcXy,255)
XGUIEng.SetMaterialTexture(yxfb5r,zcXy,GuBfKo3[3].."big.png")
XGUIEng.SetMaterialUV(yxfb5r,zcXy,X7GI,L7J1,ZOIyhzA,D)else SetIcon(yxfb5r,GuBfKo3)end else local LxgPj={GUI.GetScreenSize()}local MBmUv=330;if LxgPj[2]>=800 then
MBmUv=260 end;if LxgPj[2]>=1000 then MBmUv=210 end
XGUIEng.SetMaterialAlpha(yxfb5r,1,255)XGUIEng.SetMaterialTexture(yxfb5r,1,_file)
XGUIEng.SetMaterialUV(yxfb5r,1,0,0,MBmUv,MBmUv)end end
function BundleBuildingButtons.Local:TextNormal(D,_wv,MKUKw)
local NNzyhb="/InGame/Root/Normal/TooltipNormal"local zu=XGUIEng.GetWidgetID(NNzyhb)
local MO9=XGUIEng.GetWidgetID(NNzyhb.."/FadeIn/Name")
local mbYJW=XGUIEng.GetWidgetID(NNzyhb.."/FadeIn/Text")
local IBl=XGUIEng.GetWidgetID(NNzyhb.."/FadeIn/BG")local WOZ8qcM=XGUIEng.GetWidgetID(NNzyhb.."/FadeIn")
local RO=XGUIEng.GetCurrentWidgetID()GUI_Tooltip.ResizeBG(IBl,mbYJW)local t5q0w5V={IBl}
GUI_Tooltip.SetPosition(zu,t5q0w5V,RO)GUI_Tooltip.FadeInTooltip(WOZ8qcM)MKUKw=MKUKw or""
local rCTdwCsl=""
if
XGUIEng.IsButtonDisabled(RO)==1 and MKUKw~=""and _wv~=""then rCTdwCsl=rCTdwCsl..
"{cr}{@color:255,32,32,255}"..MKUKw end;XGUIEng.SetText(MO9,"{center}"..D)XGUIEng.SetText(mbYJW,_wv..
rCTdwCsl)
local y=XGUIEng.GetTextHeight(mbYJW,true)local O5L62,kKb1MV=XGUIEng.GetWidgetSize(mbYJW)
XGUIEng.SetWidgetSize(mbYJW,O5L62,y)end
function BundleBuildingButtons.Local:TextCosts(uvj,h9ZpZN,Dz6XX9,M4b3cylW,GwhW)
local hgyT="/InGame/Root/Normal/TooltipBuy"local uh5F2f7=XGUIEng.GetWidgetID(hgyT)
local fJvrDfHT=XGUIEng.GetWidgetID(hgyT.."/FadeIn/Name")
local CgwWT2=XGUIEng.GetWidgetID(hgyT.."/FadeIn/Text")local o=XGUIEng.GetWidgetID(hgyT.."/FadeIn/BG")local i=XGUIEng.GetWidgetID(
hgyT.."/FadeIn")
local jI=XGUIEng.GetWidgetID(hgyT.."/Costs")local KcJAj5UN=XGUIEng.GetCurrentWidgetID()
GUI_Tooltip.ResizeBG(o,CgwWT2)GUI_Tooltip.SetCosts(jI,M4b3cylW,GwhW)
local cPV={uh5F2f7,jI,o}
GUI_Tooltip.SetPosition(uh5F2f7,cPV,KcJAj5UN,nil,true)GUI_Tooltip.OrderTooltip(cPV,i,jI,KcJAj5UN,o)
GUI_Tooltip.FadeInTooltip(i)Dz6XX9=Dz6XX9 or""local rjhFCKf=""if

XGUIEng.IsButtonDisabled(KcJAj5UN)==1 and Dz6XX9 ~=""and h9ZpZN~=""then
rjhFCKf=rjhFCKf.."{cr}{@color:255,32,32,255}"..Dz6XX9 end;XGUIEng.SetText(fJvrDfHT,
"{center}"..uvj)
XGUIEng.SetText(CgwWT2,h9ZpZN..rjhFCKf)local ZiQ=XGUIEng.GetTextHeight(CgwWT2,true)
local BR,PAu=XGUIEng.GetWidgetSize(CgwWT2)XGUIEng.SetWidgetSize(CgwWT2,BR,ZiQ)end
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Action(DvNist5k,a)local n3pW=
BundleBuildingButtons.Local.Data.StoppedBuildings[a]==true;GUI.SetStoppedState(a,
not n3pW)BundleBuildingButtons.Local.Data.StoppedBuildings[a]=
not n3pW end
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Tooltip(YZcKfKLY,VJa)
local w6woX8G=(
Network.GetDesiredLanguage()=="de"and"de")or"en"
BundleBuildingButtons.Local:TextNormal(BundleBuildingButtons.Local.Description.SingleStop.Title[w6woX8G],BundleBuildingButtons.Local.Description.SingleStop.Text[w6woX8G])end
function BundleBuildingButtons.Local.ButtonDefaultSingleStop_Update(dmf8vR_C,RHNsiE9_)
local USNU=
Logic.IsEntityInCategory(RHNsiE9_,EntityCategories.OuterRimBuilding)==1
local lE=Logic.IsEntityInCategory(RHNsiE9_,EntityCategories.CityBuilding)==1;if USNU==false and lE==false then
XGUIEng.ShowWidget(dmf8vR_C,0)end;if
BundleBuildingButtons.Local.Data.StoppedBuildings[RHNsiE9_]==true then SetIcon(dmf8vR_C,{4,12})else
SetIcon(dmf8vR_C,{4,13})end end
function BundleBuildingButtons.Local.OnSelectionChanged(UVY6A9)
local h6i3v27=GUI.GetSelectedEntity()local k=Logic.GetEntityType(h6i3v27)
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/GateAutoToggle",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/GateOpenClose",1)
XGUIEng.ShowWidget("/InGame/Root/Normal/BuildingButtons/TrapToggle",1)end;Core:RegisterBundle("BundleBuildingButtons")
API=API or{}QSB=QSB or{}QSB.IOList={}
function API.SetupInteractiveObject(KfVB,Mbf3)if GUI then
API.Dbg("API.SetupInteractiveObject: Can not be used from local enviorment!")return end;if
not IsExisting(KfVB)then
API.Dbg("API.SetupInteractiveObject: Entity \""..KfVB.."\" is invalid!")return end;Mbf3.Name=KfVB;return
BundleInteractiveObjects.Global:CreateObject(Mbf3)end;SetupInteractiveObject=API.SetupInteractiveObject
function API.CreateObject(cE6)if GUI then
API.Dbg("API.CreateObject: Can not be used from local enviorment!")return end;return
BundleInteractiveObjects.Global:CreateObject(cE6)end;CreateObject=API.CreateObject
function API.RemoveInteractiveObject(MLldrp)if GUI then
API.Bridge("API.RemoveInteractiveObject('"..
MLldrp.."')")return end;if not IsExisting(MLldrp)then
API.Warn(
"API.RemoveInteractiveObject: Entity \""..MLldrp.."\" is invalid!")return end;return
BundleInteractiveObjects.Global:RemoveInteractiveObject(MLldrp)end;RemoveInteractiveObject=API.RemoveInteractiveObject
function API.InteractiveObjectActivate(Vt8,O_)if GUI then
API.Bridge(
"API.InteractiveObjectActivate('"..Vt8 .."', "..tostring(O_)..")")return end;if
not IsExisting(Vt8)then
API.Warn("API.InteractiveObjectActivate: Entity \""..Vt8 .."\" is invalid!")return end
if not
Logic.IsInteractiveObject(GetID(Vt8))then if IO[Vt8]then IO[Vt8].Inactive=false
IO[Vt8].Used=false end else API.ActivateIO(Vt8,O_)end end;InteractiveObjectActivate=API.InteractiveObjectActivate
function API.InteractiveObjectDeactivate(U8eVjmxU)if GUI then
API.Bridge(
"API.InteractiveObjectDeactivate('"..U8eVjmxU.."')")return end;if
not IsExisting(U8eVjmxU)then
API.Warn("API.InteractiveObjectDeactivate: Entity \""..U8eVjmxU.."\" is invalid!")return end
if not
Logic.IsInteractiveObject(GetID(U8eVjmxU))then
if IO[U8eVjmxU]then IO[U8eVjmxU].Inactive=true end else API.DeactivateIO(U8eVjmxU)end end;InteractiveObjectDeactivate=API.InteractiveObjectDeactivate
function API.AddCustomIOName(HvSMI,Sj8)
if type(Sj8 ==
"table")then local uh=
(Network.GetDesiredLanguage()=="de"and"de")or"en"Sj8=Sj8[uh]end;if GUI then
API.Bridge("API.AddCustomIOName('"..HvSMI.."', '"..Sj8 .."')")return end;return
BundleInteractiveObjects.Global:AddCustomIOName(HvSMI,Sj8)end;AddCustomIOName=API.AddCustomIOName
BundleInteractiveObjects={Global={Data={}},Local={Data={IOCustomNames={},IOCustomNamesByEntityName={}}}}
function BundleInteractiveObjects.Global:Install()IO={}end
function BundleInteractiveObjects.Global:CreateObject(TRBGQi)
local MfwnUbM=Network.GetDesiredLanguage()self:HackOnInteractionEvent()
self:RemoveInteractiveObject(TRBGQi.Name)if type(TRBGQi.Title)=="table"then
TRBGQi.Title=TRBGQi.Title[MfwnUbM]end;if
not TRBGQi.Title or TRBGQi.Title==""then
TRBGQi.Title=(MfwnUbM=="de"and"Interaktion")or"Interaction"end
if type(TRBGQi.Text)==
"table"then TRBGQi.Text=TRBGQi.Text[MfwnUbM]end;if not TRBGQi.Text then TRBGQi.Text=""end;if
type(TRBGQi.WrongKnight)=="table"then
TRBGQi.WrongKnight=TRBGQi.WrongKnight[MfwnUbM]end
TRBGQi.WrongKnight=TRBGQi.WrongKnight or""if type(TRBGQi.ConditionUnfulfilled)=="table"then
TRBGQi.ConditionUnfulfilled=TRBGQi.ConditionUnfulfilled[MfwnUbM]end;TRBGQi.ConditionUnfulfilled=
TRBGQi.ConditionUnfulfilled or""TRBGQi.Condition=TRBGQi.Condition or function()
return true end;TRBGQi.Callback=
TRBGQi.Callback or function()end
TRBGQi.Distance=TRBGQi.Distance or 1200;TRBGQi.Waittime=TRBGQi.Waittime or 15;TRBGQi.Texture=TRBGQi.Texture or
{14,10}
TRBGQi.Reward=TRBGQi.Reward or{}TRBGQi.Costs=TRBGQi.Costs or{}
TRBGQi.State=TRBGQi.State or 0
Logic.ExecuteInLuaLocalState([[
        QSB.IOList[#QSB.IOList+1] = "]]..
TRBGQi.Name..
[["
        if not BundleInteractiveObjects.Local.Data.InteractionHackStarted then
            BundleInteractiveObjects.Local:ActivateInteractiveObjectControl()
            BundleInteractiveObjects.Local.Data.InteractionHackStarted = true;
        end
    ]])IO[TRBGQi.Name]=API.InstanceTable(TRBGQi)
local vuDEK=GetID(TRBGQi.Name)
if Logic.IsInteractiveObject(vuDEK)==true then
Logic.InteractiveObjectClearCosts(vuDEK)Logic.InteractiveObjectClearRewards(vuDEK)
Logic.InteractiveObjectSetInteractionDistance(vuDEK,TRBGQi.Distance)
Logic.InteractiveObjectSetTimeToOpen(vuDEK,TRBGQi.Waittime)
Logic.InteractiveObjectAddRewards(vuDEK,TRBGQi.Reward[1],TRBGQi.Reward[2])
Logic.InteractiveObjectAddCosts(vuDEK,TRBGQi.Costs[1],TRBGQi.Costs[2])
Logic.InteractiveObjectAddCosts(vuDEK,TRBGQi.Costs[3],TRBGQi.Costs[4])
Logic.InteractiveObjectSetAvailability(vuDEK,true)
Logic.InteractiveObjectSetPlayerState(vuDEK,TRBGQi.PlayerID or 1,TRBGQi.State)
Logic.InteractiveObjectSetRewardResourceCartType(vuDEK,Entities.U_ResourceMerchant)
Logic.InteractiveObjectSetRewardGoldCartType(vuDEK,Entities.U_GoldCart)
Logic.InteractiveObjectSetCostGoldCartType(vuDEK,Entities.U_GoldCart)
Logic.InteractiveObjectSetCostResourceCartType(vuDEK,Entities.U_ResourceMerchant)table.insert(HiddenTreasures,vuDEK)end end
function BundleInteractiveObjects.Global:RemoveInteractiveObject(XNkc)
for QBDSr,b_ in pairs(IO)do
if QBDSr==XNkc then
Logic.ExecuteInLuaLocalState(
[[
                IO["]]..XNkc..[["] = nil;
            ]])IO[XNkc]=nil end end end
function BundleInteractiveObjects.Global:AddCustomIOName(PB,o)
if type(o)=="table"then
local W=o.de;local x=o.en
Logic.ExecuteInLuaLocalState([[
            BundleInteractiveObjects.Local.Data.IOCustomNames["]]..PB..

[["] = {
                de = "]]..W..
[[",
                en = "]]..x..[["
            }
        ]])else
Logic.ExecuteInLuaLocalState([[
            BundleInteractiveObjects.Local.Data.IOCustomNames["]]..PB..
[["] = "]]..o..[["
        ]])end end
function BundleInteractiveObjects.Global:HackOnInteractionEvent()
if not
BundleInteractiveObjects.Global.Data.InteractionEventHacked then
StartSimpleJobEx(BundleInteractiveObjects.Global.ControlInteractiveObjects)
BundleInteractiveObjects.Global.Data.InteractionEventHacked=true
OnTreasureFound=function(xWN,dq)
for R2rDj=1,#HiddenTreasures do local N0f6ekP=HiddenTreasures[R2rDj]
if N0f6ekP==xWN then
Logic.InteractiveObjectSetAvailability(xWN,false)for SfT02=1,8 do
Logic.InteractiveObjectSetPlayerState(xWN,SfT02,2)end
table.remove(HiddenTreasures,R2rDj)HiddenTreasures[0]=#HiddenTreasures
local HMfwtsu="menu_left_prestige"local ZNfmbrR=Logic.GetEntityName(xWN)
if IO[ZNfmbrR]and
IO[ZNfmbrR].ActivationSound then HMfwtsu=IO[ZNfmbrR].ActivationSound end
Logic.ExecuteInLuaLocalState("Play2DSound("..dq..",'"..HMfwtsu.."')")end end end
GameCallback_OnObjectInteraction=function(ljsI,ez)OnInteractiveObjectOpened(ljsI,ez)
OnTreasureFound(ljsI,ez)local kyUU=Logic.GetEntityName(ljsI)
for bbe8l,aMhYr in pairs(IO)do if bbe8l==kyUU then
if
not aMhYr.Used then IO[bbe8l].Used=true;aMhYr.Callback(aMhYr,ez)end end end end
GameCallback_ExecuteCustomObjectReward=function(aI5j0,y,uDP,B12w89Bo)
if
not Logic.IsInteractiveObject(GetID(y))then local hyCfIcL=GetPosition(y)
local AO=Logic.GetGoodCategoryForGoodType(uDP)local sRw
if AO==GoodCategories.GC_Resource then
sRw=Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant,hyCfIcL.X,hyCfIcL.Y,0,aI5j0)elseif uDP==Goods.G_Medicine then
sRw=Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus,hyCfIcL.X,hyCfIcL.Y,0,aI5j0)elseif uDP==Goods.G_Gold then
sRw=Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart,hyCfIcL.X,hyCfIcL.Y,0,aI5j0)else
sRw=Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer,hyCfIcL.X,hyCfIcL.Y,0,aI5j0)end;Logic.HireMerchant(sRw,aI5j0,uDP,B12w89Bo,aI5j0)end end
function QuestTemplate:AreObjectsActivated(Ku67aT)
for X6JT3G=1,Ku67aT[0]do if not Ku67aT[-X6JT3G]then
Ku67aT[-X6JT3G]=GetEntityId(Ku67aT[X6JT3G])end
local B9J6=Logic.GetEntityName(Ku67aT[-X6JT3G])local JETGHKBR=IO[B9J6]
if Logic.IsInteractiveObject(Ku67aT[-X6JT3G])then
if not IsInteractiveObjectOpen(Ku67aT[
-X6JT3G])then return false end else if not JETGHKBR then return false end
if JETGHKBR.Used~=true then return false end end end;return true end end end
function BundleInteractiveObjects.Global.ControlInteractiveObjects()
for uy6Y,QEa7qV2 in pairs(IO)do if
not QEa7qV2.Used==true then
QEa7qV2.ConditionFullfilled=QEa7qV2.Condition(QEa7qV2)end end end;function BundleInteractiveObjects.Local:Install()
IO=Logic.CreateReferenceToTableInGlobaLuaState("IO")end
function BundleInteractiveObjects.Local:CanBeBought(px42,OIYDRIKK,ZgwAT)
local b=GetPlayerGoodsInSettlement(OIYDRIKK,px42,true)if b<ZgwAT then return false end;return true end
function BundleInteractiveObjects.Local:BuyObject(O8Dg4j0v,HyDK,p)
if

Logic.GetGoodCategoryForGoodType(HyDK)~=GoodCategories.GC_Resource and HyDK~=Goods.G_Gold then local CKr3oxH=GetPlayerEntities(O8Dg4j0v,0)local YdJr=p
for uhi=1,#CKr3oxH do
if
Logic.IsBuilding(CKr3oxH[uhi])==1 and YdJr>0 then
if
Logic.GetBuildingProduct(CKr3oxH[uhi])==HyDK then
local KSGwA0z=Logic.GetAmountOnOutStockByIndex(CKr3oxH[uhi],0)for y52A=1,KSGwA0z do
API.Bridge("Logic.RemoveGoodFromStock("..CKr3oxH[uhi]..","..HyDK..",1)")YdJr=YdJr-1 end end end end else
API.Bridge("AddGood("..HyDK..
",".. (p* (-1))..","..O8Dg4j0v..")")end end
function BundleInteractiveObjects.Local:ActivateInteractiveObjectControl()g_Interaction.ActiveObjectsOnScreen=
g_Interaction.ActiveObjectsOnScreen or{}g_Interaction.ActiveObjects=
g_Interaction.ActiveObjects or{}
GUI_Interaction.InteractiveObjectUpdate=function()
local _5K=GUI.GetPlayerID()if g_Interaction.ActiveObjects==nil then return end
for h_tE63z=1,#
g_Interaction.ActiveObjects do
local AXp=g_Interaction.ActiveObjects[h_tE63z]local m3bEUGF,Ynl2dx28=GUI.GetEntityInfoScreenPosition(AXp)
local oa,BSt5TDUq=GUI.GetScreenSize()
if

m3bEUGF~=0 and Ynl2dx28 ~=0 and m3bEUGF>-50 and
Ynl2dx28 >-50 and m3bEUGF< (oa+50)and Ynl2dx28 < (BSt5TDUq+50)then if
Inside(AXp,g_Interaction.ActiveObjectsOnScreen)==false then
table.insert(g_Interaction.ActiveObjectsOnScreen,AXp)end else
for h_tE63z=1,#
g_Interaction.ActiveObjectsOnScreen do if
g_Interaction.ActiveObjectsOnScreen[h_tE63z]==AXp then
table.remove(g_Interaction.ActiveObjectsOnScreen,h_tE63z)end end end end
for wNNoSq=1,#g_Interaction.ActiveObjectsOnScreen do
local ogcV="/InGame/Root/Normal/InteractiveObjects/"..wNNoSq
if XGUIEng.IsWidgetExisting(ogcV)==1 then
local BGI=g_Interaction.ActiveObjectsOnScreen[wNNoSq]local T=Logic.GetEntityType(BGI)
local THbSG8,oE=GUI.GetEntityInfoScreenPosition(BGI)local ae={XGUIEng.GetWidgetScreenSize(ogcV)}
local Z1ceWAUw={Logic.InteractiveObjectGetCosts(BGI)}
local dnHSEBJ={Logic.InteractiveObjectGetEffectiveCosts(BGI,_5K)}local I0NG=Logic.InteractiveObjectGetAvailability(BGI)
local PD_cG=Logic.GetEntityType(BGI)local psE3ibXp=Logic.GetEntityName(BGI)
local mQvK=Logic.GetEntityTypeName(PD_cG)local d=false
XGUIEng.SetWidgetScreenPosition(ogcV,THbSG8- (ae[1]/2),oE- (ae[2]/2))if
Z1ceWAUw[1]~=nil and dnHSEBJ[1]==nil and I0NG==true then d=true end
local NMz01zB=Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(BGI,_5K)if NMz01zB==false then d=true end
if d==true then
XGUIEng.DisableButton(ogcV,1)else XGUIEng.DisableButton(ogcV,0)end;if GUI_Interaction.InteractiveObjectUpdateEx1 ~=nil then
GUI_Interaction.InteractiveObjectUpdateEx1(ogcV,T)end;if IO[psE3ibXp]then
BundleInteractiveObjects.Local:SetIcon(ogcV,IO[psE3ibXp].Texture)end
XGUIEng.ShowWidget(ogcV,1)end end
for T0KzcuMx,AhxH in pairs(QSB.IOList)do local nFN=GUI.GetPlayerID()
local JfIQI8q1=Logic.GetEntityType(GetID(AhxH))local bpX=Logic.GetEntityTypeName(JfIQI8q1)
if bpX and AhxH~=""then
if


not
(string.find(bpX,"I_X_"))and not(string.find(bpX,"Mine"))and not(string.find(bpX,"B_Wel"))and not(string.find(bpX,"B_Cis"))then
if IO[AhxH].State==0 and IO[AhxH].Distance~=nil and
IO[AhxH].Distance>0 then local LZgD={}
Logic.GetKnights(nFN,LZgD)local Rk=false;for dEq=1,#LZgD do
if IsNear(LZgD[dEq],AhxH,IO[AhxH].Distance)then Rk=true;break end end
if not IO[AhxH].Used and not
IO[AhxH].Inactive then if Rk then
ScriptCallback_ObjectInteraction(nFN,GetID(AhxH))else
ScriptCallback_CloseObjectInteraction(nFN,GetID(AhxH))end else
ScriptCallback_CloseObjectInteraction(nFN,GetID(AhxH))end else
if not IO[AhxH].Used and not IO[AhxH].Inactive then
ScriptCallback_ObjectInteraction(nFN,GetID(AhxH))else
ScriptCallback_CloseObjectInteraction(nFN,GetID(AhxH))end end end end end;for TBN=#g_Interaction.ActiveObjectsOnScreen+1,2 do local qstqnyi=
"/InGame/Root/Normal/InteractiveObjects/"..TBN
XGUIEng.ShowWidget(qstqnyi,0)end end
GUI_Interaction.InteractiveObjectMouseOver=function()local gNaS8Woq=GUI.GetPlayerID()
local Lj=tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()))local CFD=g_Interaction.ActiveObjectsOnScreen[Lj]
local pjv=Logic.GetEntityType(CFD)local ePWz1yOf=XGUIEng.GetCurrentWidgetID()
local _q5TOY={Logic.InteractiveObjectGetEffectiveCosts(CFD,gNaS8Woq)}local Qh=Logic.InteractiveObjectGetAvailability(CFD)
local BnR4;local IYm;local qlEsxT=Logic.GetEntityName(CFD)
if Qh==true then
BnR4="InteractiveObjectAvailable"else BnR4="InteractiveObjectNotAvailable"end
if
Logic.InteractiveObjectHasPlayerEnoughSpaceForRewards(CFD,gNaS8Woq)==false then IYm="InteractiveObjectAvailableReward"end;local ClpHl;if
_q5TOY and _q5TOY[1]and Logic.GetGoodCategoryForGoodType(_q5TOY[1])~=
GoodCategories.GC_Resource then ClpHl=true end
if
IO[qlEsxT]and IO[qlEsxT].Used~=true then local DtLnlX;local nc;if IO[qlEsxT].Title or
IO[qlEsxT].Text then DtLnlX=IO[qlEsxT].Title or""nc=
IO[qlEsxT].Text or""end
if
Logic.IsInteractiveObject(CFD)==false then _q5TOY=IO[qlEsxT].Costs;if
_q5TOY and _q5TOY[1]and
Logic.GetGoodCategoryForGoodType(_q5TOY[1])~=GoodCategories.GC_Resource then ClpHl=true end end
BundleInteractiveObjects.Local:TextCosts(DtLnlX,nc,nil,{_q5TOY[1],_q5TOY[2],_q5TOY[3],_q5TOY[4]},ClpHl)return end
GUI_Tooltip.TooltipBuy(_q5TOY,BnR4,IYm,nil,ClpHl)end
GUI_Interaction.InteractiveObjectClicked_Orig_QSB_IO=GUI_Interaction.InteractiveObjectClicked
GUI_Interaction.InteractiveObjectClicked=function()
local B=tonumber(XGUIEng.GetWidgetNameByID(XGUIEng.GetCurrentWidgetID()))local dAR=Network.GetDesiredLanguage()
local BpOojmKs=g_Interaction.ActiveObjectsOnScreen[B]local DJnI_Wb=GUI.GetPlayerID()
for Kk5,oOM0P in pairs(IO)do
if BpOojmKs==GetID(Kk5)then
local AZJ="menu_left_prestige"if oOM0P.ActivationSound then AZJ=oOM0P.ActivationSound end
local g_5={}
if IO[Kk5].Reward and IO[Kk5].Reward[1]~=nil then
table.insert(g_5,IO[Kk5].Reward[1])table.insert(g_5,IO[Kk5].Reward[2])end;local sxUI=true
if
g_5[2]and type(g_5[2])=="number"and
g_5[1]~=Goods.G_Gold and Logic.GetGoodCategoryForGoodType(g_5[1])==
GoodCategories.GC_Resource then
local UrvQ=Logic.GetPlayerUnreservedStorehouseSpace(DJnI_Wb)if UrvQ<g_5[2]then sxUI=false end end;local mNvYGn2p
if IO[Kk5].Costs and IO[Kk5].Costs[1]then
if
Logic.GetGoodCategoryForGoodType(IO[Kk5].Costs[1])~=GoodCategories.GC_Resource then mNvYGn2p=true end
if sxUI==false then
local PxKEaHwr=XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace")Message(PxKEaHwr)return end;local y0=IO[Kk5].Costs
local hXRf=XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_NotEnough_Resources")local YtQ=true
if y0[1]then YtQ=YtQ and
BundleInteractiveObjects.Local:CanBeBought(DJnI_Wb,y0[1],y0[2])end
if y0[3]then YtQ=YtQ and
BundleInteractiveObjects.Local:CanBeBought(DJnI_Wb,y0[3],y0[4])end
if not IO[Kk5].ConditionFullfilled then if IO[Kk5].ConditionUnfulfilled and IO[Kk5].ConditionUnfulfilled~=
""then
Message(IO[Kk5].ConditionUnfulfilled)end;return end
if IO[Kk5].Opener then
if
Logic.GetDistanceBetweenEntities(GetID(IO[Kk5].Opener),GetID(Kk5))>IO[Kk5].Distance then if IO[Kk5].WrongKnight and
IO[Kk5].WrongKnight~=""then
Message(IO[Kk5].WrongKnight)end;return end end
if YtQ==true then if
y0[1]~=nil and not Logic.IsInteractiveObject(BpOojmKs)then
BundleInteractiveObjects.Local:BuyObject(DJnI_Wb,y0[1],y0[2])end;if y0[3]~=nil and not
Logic.IsInteractiveObject(BpOojmKs)then
BundleInteractiveObjects.Local:BuyObject(DJnI_Wb,y0[3],y0[4])end;if#g_5 >0 then
GUI.SendScriptCommand(
"GameCallback_ExecuteCustomObjectReward("..DJnI_Wb..",'"..
Kk5 .."',"..g_5[1]..","..g_5[2]..")")end
if
Logic.IsInteractiveObject(BpOojmKs)~=true then Play2DSound(DJnI_Wb,AZJ)
GUI.SendScriptCommand(
"GameCallback_OnObjectInteraction("..BpOojmKs..","..DJnI_Wb..")")end else Message(hXRf)end else
if sxUI==false then
local KJFFNd=XGUIEng.GetStringTableText("Feedback_TextLines/TextLine_MerchantStorehouseSpace")Message(KJFFNd)return end
if not IO[Kk5].ConditionFullfilled then if IO[Kk5].ConditionUnfulfilled and IO[Kk5].ConditionUnfulfilled~=
""then
Message(IO[Kk5].ConditionUnfulfilled)end;return end
if IO[Kk5].Opener then
if
Logic.GetDistanceBetweenEntities(GetID(IO[Kk5].Opener),GetID(Kk5))>IO[Kk5].Distance then if IO[Kk5].WrongKnight and
IO[Kk5].WrongKnight~=""then
Message(IO[Kk5].WrongKnight)end;return end end;if#g_5 >0 then
GUI.SendScriptCommand("GameCallback_ExecuteCustomObjectReward("..
DJnI_Wb..",'"..Kk5 .."',"..g_5[1]..
","..g_5[2]..")")end
if
Logic.IsInteractiveObject(BpOojmKs)~=true then Play2DSound(DJnI_Wb,AZJ)
GUI.SendScriptCommand(
"GameCallback_OnObjectInteraction("..BpOojmKs..","..DJnI_Wb..")")end end end end
GUI_Interaction.InteractiveObjectClicked_Orig_QSB_IO()end
GUI_Interaction.DisplayQuestObjective_Orig_QSB_IO=GUI_Interaction.DisplayQuestObjective
GUI_Interaction.DisplayQuestObjective=function(ld,GfW)
local jYBYw1Yj=Network.GetDesiredLanguage()if jYBYw1Yj~="de"then jYBYw1Yj="en"end;local f4_uPJ9=tonumber(ld)if f4_uPJ9 then
ld=f4_uPJ9 end
local MHsOhBmb,E=GUI_Interaction.GetPotentialSubQuestAndType(ld)local UO_sFF="/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives"
XGUIEng.ShowAllSubWidgets("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives",0)local fT2K1s;local OFZ6Sn;local zy0R=Quests[ld]local z_557jE;if
zy0R~=nil and type(zy0R)=="table"then z_557jE=zy0R.Identifier end;local fJ0={}
g_CurrentDisplayedQuestID=ld
if E==Objective.Object then fT2K1s=UO_sFF.."/List"
OFZ6Sn=Wrapped_GetStringTableText(ld,"UI_Texts/QuestInteraction")local TR8S4gVl={}
for zyErVr=1,MHsOhBmb.Objectives[1].Data[0]do local mu_
if
Logic.IsEntityDestroyed(MHsOhBmb.Objectives[1].Data[zyErVr])then
mu_=g_Interaction.SavedQuestEntityTypes[ld][zyErVr]else
mu_=Logic.GetEntityType(GetEntityId(MHsOhBmb.Objectives[1].Data[zyErVr]))end
local OxT=Logic.GetEntityName(MHsOhBmb.Objectives[1].Data[zyErVr])local HIT=""
if mu_~=0 then local pRc=Logic.GetEntityTypeName(mu_)HIT=Wrapped_GetStringTableText(ld,
"Names/"..pRc)
if HIT==""then HIT=Wrapped_GetStringTableText(ld,
"UI_ObjectNames/"..pRc)end
if HIT==""then
HIT=BundleInteractiveObjects.Local.Data.IOCustomNames[pRc]if type(HIT)=="table"then local jYBYw1Yj=Network.GetDesiredLanguage()jYBYw1Yj=(
jYBYw1Yj=="de"and"de")or"en"
HIT=HIT[jYBYw1Yj]end end
if HIT==""then
HIT=BundleInteractiveObjects.Local.Data.IOCustomNames[OxT]if type(HIT)=="table"then local jYBYw1Yj=Network.GetDesiredLanguage()jYBYw1Yj=(
jYBYw1Yj=="de"and"de")or"en"
HIT=HIT[jYBYw1Yj]end end
if HIT==""then HIT="Debug: ObjectName missing for "..pRc end end;table.insert(TR8S4gVl,HIT)end
for H=1,4 do local kWV_=TR8S4gVl[H]if kWV_==nil then kWV_=""end;XGUIEng.SetText(fT2K1s.."/Entry"..H,
"{center}"..kWV_)end;SetIcon(fT2K1s.."/QuestTypeIcon",{14,10})
XGUIEng.SetText(
fT2K1s.."/Caption","{center}"..OFZ6Sn)XGUIEng.ShowWidget(fT2K1s,1)else
GUI_Interaction.DisplayQuestObjective_Orig_QSB_IO(ld,GfW)end end end
function BundleInteractiveObjects.Local:TextCosts(yy,Y8e,jnHv9kuE,cP8iiWL,sQ)
local HV="/InGame/Root/Normal/TooltipBuy"local Ylj1_p=XGUIEng.GetWidgetID(HV)
local HyUmK=XGUIEng.GetWidgetID(HV.."/FadeIn/Name")local TbIZ=XGUIEng.GetWidgetID(HV.."/FadeIn/Text")local pKD=XGUIEng.GetWidgetID(
HV.."/FadeIn/BG")local dtj=XGUIEng.GetWidgetID(HV..
"/FadeIn")
local B4k2=XGUIEng.GetWidgetID(HV.."/Costs")local Qwj=XGUIEng.GetCurrentWidgetID()
GUI_Tooltip.ResizeBG(pKD,TbIZ)GUI_Tooltip.SetCosts(B4k2,cP8iiWL,sQ)
local ASt={Ylj1_p,B4k2,pKD}GUI_Tooltip.SetPosition(Ylj1_p,ASt,Qwj,nil,true)
GUI_Tooltip.OrderTooltip(ASt,dtj,B4k2,Qwj,pKD)GUI_Tooltip.FadeInTooltip(dtj)
jnHv9kuE=jnHv9kuE or""local akg8dT=""
if
XGUIEng.IsButtonDisabled(Qwj)==1 and jnHv9kuE~=""and Y8e~=""then akg8dT=akg8dT..
"{cr}{@color:255,32,32,255}"..jnHv9kuE end;XGUIEng.SetText(HyUmK,"{center}"..yy)XGUIEng.SetText(TbIZ,
Y8e..akg8dT)
local hBMTgj3=XGUIEng.GetTextHeight(TbIZ,true)local n,qkN0=XGUIEng.GetWidgetSize(TbIZ)
XGUIEng.SetWidgetSize(TbIZ,n,hBMTgj3)end
function BundleInteractiveObjects.Local:SetIcon(BC3W,wF)
if type(wF)=="table"then
if
type(wF[3])=="string"then local Q4jh1Kak=1
if XGUIEng.IsButton(BC3W)==1 then Q4jh1Kak=7 end;local R,Qz,u,pyRL4R;R=(wF[1]-1)*64;u=(wF[2]-1)*64
Qz=(wF[1])*64;pyRL4R=(wF[2])*64
XGUIEng.SetMaterialAlpha(BC3W,Q4jh1Kak,255)
XGUIEng.SetMaterialTexture(BC3W,Q4jh1Kak,wF[3].."big.png")XGUIEng.SetMaterialUV(BC3W,Q4jh1Kak,R,u,Qz,pyRL4R)else
SetIcon(BC3W,wF)end else local hNh={GUI.GetScreenSize()}local Lbo6veiM=330;if hNh[2]>=800 then
Lbo6veiM=260 end;if hNh[2]>=1000 then Lbo6veiM=210 end
XGUIEng.SetMaterialAlpha(BC3W,1,255)XGUIEng.SetMaterialTexture(BC3W,1,_file)
XGUIEng.SetMaterialUV(BC3W,1,0,0,Lbo6veiM,Lbo6veiM)end end;Core:RegisterBundle("BundleInteractiveObjects")function API.GetHealth(JU53A5W)return
BundleEntityHealth:GetHealth(JU53A5W)end
GetHealth=API.GetHealth
function API.SetHealth(cWpGi,uwdKc)
if GUI then local RY9dg5wU=
(type(cWpGi)=="string"and"'"..cWpGi.."'")or cWpGi
API.Bridge("API.SetHealth("..
RY9dg5wU..", "..uwdKc..")")return end
if not IsExisting(cWpGi)then local BMJ6ZOU=
(type(cWpGi)=="string"and"'"..cWpGi.."'")or cWpGi
API.Dbg("_Entity "..BMJ6ZOU..
" does not exist!")return end;if type(uwdKc)~="number"then
API.Dbg("_Percentage must be a number!")return end
uwdKc=(uwdKc<0 and 0)or uwdKc;if uwdKc>100 then
API.Warn("_Percentage is larger than 100%. This could cause problems!")end
BundleEntityHealth.Global:SetEntityHealth(cWpGi,uwdKc)end;SetHealth=API.SetHealth
function API.SetOnFire(D0,go)if GUI then local _AuA1b=
(type(D0)=="string"and"'"..D0 .."'")or D0
API.Bridge("API.SetOnFire(".._AuA1b..
", "..go..")")return end
if not
IsExisting(D0)then local vsQ3Bfbn=
(type(D0)=="string"and"'"..D0 .."'")or D0;API.Dbg("Entity "..
vsQ3Bfbn.." does not exist!")return end;if Logic.IsBuilding(GetID(D0))==0 then
API.Dbg("Only buildings can be set on fire!")return end;if type(go)~="number"then
API.Dbg("_Strength must be a number!")return end
go=(go<0 and 0)or go;Logic.DEBUG_SetBuildingOnFile(GetID(D0),go)end;SetOnFire=API.SetOnFire
function API.AddOnEntityHurtAction(hg)if GUI then
API.Dbg("API.AddOnEntityHurtAction: Can not be used in local script!")return end;if type(hg)~="function"then
API.Dbg("_Function must be a function!")return end
BundleEntityHealth.Global.AddOnEntityHurtAction(hg)end;AddOnEntityHurtAction=API.AddOnEntityHurtAction
BundleEntityHealth={Global={Data={OnEntityHurtAction={}}},Local={Data={}}}
function BundleEntityHealth.Global:Install()
BundleEntityHealth_EntityHurtEntityController=BundleEntityHealth.Global.EntityHurtEntityController
Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY,"","BundleEntityHealth_EntityHurtEntityController",1)
BundleEntityHealth_EntityDestroyedController=BundleEntityHealth.Global.EntityDestroyedController
Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED,"","BundleEntityHealth_EntityDestroyedController",1)end
function BundleEntityHealth.Global:SetEntityHealth(Olrh,lbsr8G)
if not IsExisting(Olrh)then return end;local BM81Jc=GetID(Olrh)
local gw=Logic.GetEntityMaxHealth(BM81Jc)local f=Logic.GetEntityHealth(BM81Jc)local d_jS=math.floor(
(gw* (lbsr8G/100))+0.5)
Logic.HealEntity(BM81Jc,gw-f)Logic.HurtEntity(BM81Jc,gw-d_jS)end;function BundleEntityHealth.Global.AddOnEntityHurtAction(RCp)
table.insert(BundleEntityHealth.Global.Data.OnEntityHurtAction,RCp)end
function BundleEntityHealth.Global.EntityHurtEntityController()
local aSii9F0={Event.GetEntityID1()}local bwh2={Event.GetEntityID2()}
for XIPH=1,#aSii9F0,1 do
for HWCNe=1,#bwh2,1 do
local PhHJ9mUn=aSii9F0[XIPH]local QX91Z5=bwh2[HWCNe]
if
IsExisting(PhHJ9mUn)and IsExisting(QX91Z5)then
for HiPOQK,Gp2 in
pairs(BundleEntityHealth.Global.Data.OnEntityHurtAction)do if Gp2 then Gp2(PhHJ9mUn,QX91Z5)end end end end end end;function BundleEntityHealth.Local:Install()end
function BundleEntityHealth:GetHealth(GHxTHBZy)if
not IsExisting(GHxTHBZy)then return 0 end
local Lk=GetID(GHxTHBZy)local IG=Logic.GetEntityMaxHealth(Lk)
local N=Logic.GetEntityHealth(Lk)return(N/IG)*100 end;Core:RegisterBundle("BundleEntityHealth")function Reprisal_SetHealth(...)return
b_Reprisal_SetHealth:new(...)end
b_Reprisal_SetHealth={Name="Reprisal_SetHealth",Description={en="Reprisal: Changes the health of an entity.",de="Vergeltung: Setzt die Gesundheit eines Entity."},Parameter={{ParameterType.ScriptName,en="Entity",de="Entity"},{ParameterType.Number,en="Percentage",de="Prozentsatz"}}}
function b_Reprisal_SetHealth:GetRewardTable(RQVyouh)return
{Reprisal.Custom,{self,self.CustomFunction}}end
function b_Reprisal_SetHealth:AddParameter(r5mVvUH,QXJDgco)if(r5mVvUH==0)then self.Entity=QXJDgco elseif
(r5mVvUH==1)then self.Percentage=QXJDgco end end;function b_Reprisal_SetHealth:CustomFunction(gs4)
SetHealth(self.Entity,self.Percentage)end
function b_Reprisal_SetHealth:DEBUG(t0)if not
IsExisting(self.Entity)then
dbg(t0.Identifier..
" "..self.Name..": Entity is dead! :(")end
if self.Percentage<0 or
self.Percentage>100 then
dbg(t0.Identifier.." "..
self.Name..": Percentage must be between 0 and 100!")return true end;return false end;Core:RegisterBehavior(b_Reprisal_SetHealth)function Reward_SetHealth(...)return
b_Reward_SetHealth:new(...)end
b_Reward_SetHealth=API.InstanceTable(b_Reprisal_SetHealth)b_Reward_SetHealth.Name="Reward_SetHealth"
b_Reward_SetHealth.Description.en="Reward: Changes the health of an entity."
b_Reward_SetHealth.Description.de="Lohn: Setzt die Gesundheit eines Entity."b_Reward_SetHealth.GetReprisalTable=nil
b_Reward_SetHealth.GetRewardTable=function(iQ0MouEI,J7faE5z3)return
{Reward.Custom,{iQ0MouEI,iQ0MouEI.CustomFunction}}end
function b_Reward_SetHealth:DEBUG(DY3xhgUZ)if not IsExisting(self.Entity)then
dbg(DY3xhgUZ.Identifier.." "..
self.Name..": Entity is dead! :(")return true end
if
self.Percentage<0 or self.Percentage>100 then
dbg(DY3xhgUZ.Identifier.." "..self.Name..
": Percentage must be between 0 and 100!")return true end;return false end;Core:RegisterBehavior(b_Reward_SetHealth)function Trigger_EntityHealth(...)return
b_Trigger_EntityHealth:new(...)end
b_Trigger_EntityHealth={Name="Trigger_EntityHealth",Description={en="Trigger: The health of a unit must reach a certain point.",de="Auslöser: Die Gesundheit eines Entity muss einen bestimmten Wert erreichen."},Parameter={{ParameterType.ScriptName,en="Script name",de="Skriptname"},{ParameterType.Custom,en="Relation",de="Relation"},{ParameterType.Number,en="Percentage",de="Prozentwert"}}}
function b_Trigger_EntityHealth:GetTriggerTable(eeiZVi)return
{Triggers.Custom2,{self,self.CustomFunction}}end
function b_Trigger_EntityHealth:AddParameter(JY_bDOz,IwSzAR8)if(JY_bDOz==0)then self.ScriptName=IwSzAR8 elseif
(JY_bDOz==1)then self.BeSmalerThan=IwSzAR8 =="<"elseif(JY_bDOz==2)then
self.Percentage=IwSzAR8 end end
function b_Trigger_EntityHealth:GetCustomData(O1)if O1 ==1 then return{"<",">="}end end
function b_Trigger_EntityHealth:CustomFunction(cy0UEdp)
if self.BeSmalerThan then return GetHealth(self.ScriptName)<
self.Percentage else return GetHealth(self.ScriptName)>=
self.Percentage end end
function b_Trigger_EntityHealth:DEBUG(t5ULdSIe)if not IsExisting(self.ScriptName)then
dbg(
t5ULdSIe.Identifier.." "..self.Name..": Entity is dead! :(")return true end
if
self.Percentage<0 or self.Percentage>100 then
dbg(t5ULdSIe.Identifier.." "..self.Name..
": Percentage must be between 0 and 100!")return true end;return false end;Core:RegisterBehavior(b_Trigger_EntityHealth)
API=API or{}QSB=QSB or{}AddOnQuestDebug={Global={Data={}},Local={Data={}}}
function API.ActivateDebugMode(XSi,Rabnvc,nj2aU2nO,esu)
if
GUI then
API.Bridge("API.DisbandTravelingSalesman("..
tostring(XSi)..", "..
tostring(Rabnvc)..", "..tostring(nj2aU2nO)..", "..
tostring(esu)..")")return end
AddOnQuestDebug.Global:ActivateDebug(XSi,Rabnvc,nj2aU2nO,esu)end;ActivateDebugMode=API.ActivateDebugMode;function Reward_DEBUG(...)
return b_Reward_DEBUG:new(...)end
b_Reward_DEBUG={Name="Reward_DEBUG",Description={en="Reward: Start the debug mode. See documentation for more information.",de="Lohn: Startet den Debug-Modus. Für mehr Informationen siehe Dokumentation."},Parameter={{ParameterType.Custom,en="Check quests beforehand",de="Quest vor Start prüfen"},{ParameterType.Custom,en="Check quest while runtime",de="Quests zur Laufzeit prüfen"},{ParameterType.Custom,en="Use quest trace",de="Questverfolgung"},{ParameterType.Custom,en="Activate developing mode",de="Testmodus aktivieren"}}}function b_Reward_DEBUG:GetRewardTable(Gn706MB)return
{Reward.Custom,{self,self.CustomFunction}}end
function b_Reward_DEBUG:AddParameter(A5JGj,E)
if(
A5JGj==0)then self.CheckAtStart=AcceptAlternativeBoolean(E)elseif
(A5JGj==1)then self.CheckWhileRuntime=AcceptAlternativeBoolean(E)elseif
(A5JGj==2)then self.UseQuestTrace=AcceptAlternativeBoolean(E)elseif(A5JGj==3)then
self.DelepoingMode=AcceptAlternativeBoolean(E)end end
function b_Reward_DEBUG:CustomFunction(X9Lq1Qu)
API.ActivateDebugMode(self.CheckAtStart,self.CheckWhileRuntime,self.UseQuestTrace,self.DelepoingMode)end
function b_Reward_DEBUG:GetCustomData(kgGACce)return{"true","false"}end;Core:RegisterBehavior(b_Reward_DEBUG)
function AddOnQuestDebug.Global:Install()
AddOnQuestDebug.Global.Data.DebugCommands={{"clear",AddOnQuestDebug.Global.Clear},{"diplomacy",AddOnQuestDebug.Global.Diplomacy},{"restartmap",AddOnQuestDebug.Global.RestartMap},{"shareview",AddOnQuestDebug.Global.ShareView},{"setposition",AddOnQuestDebug.Global.SetPosition},{"unfreeze",AddOnQuestDebug.Global.Unfreeze},{"win",AddOnQuestDebug.Global.QuestSuccess,true},{"winall",AddOnQuestDebug.Global.QuestSuccess,false},{"fail",AddOnQuestDebug.Global.QuestFailure,true},{"failall",AddOnQuestDebug.Global.QuestFailure,false},{"stop",AddOnQuestDebug.Global.QuestInterrupt,true},{"stopall",AddOnQuestDebug.Global.QuestInterrupt,false},{"start",AddOnQuestDebug.Global.QuestTrigger,true},{"startall",AddOnQuestDebug.Global.QuestTrigger,false},{"restart",AddOnQuestDebug.Global.QuestReset,true},{"restartall",AddOnQuestDebug.Global.QuestReset,false},{"printequal",AddOnQuestDebug.Global.PrintQuests,1},{"printactive",AddOnQuestDebug.Global.PrintQuests,2},{"printdetail",AddOnQuestDebug.Global.PrintQuests,3},{"lload",AddOnQuestDebug.Global.LoadScript,true},{"gload",AddOnQuestDebug.Global.LoadScript,false},{"lexec",AddOnQuestDebug.Global.ExecuteCommand,true},{"gexec",AddOnQuestDebug.Global.ExecuteCommand,false},{"collectgarbage",AddOnQuestDebug.Global.CollectGarbage},{"dumpmemory",AddOnQuestDebug.Global.CountLuaLoad}}
for INOtn,wNq7jW in pairs(_G)do
if

type(wNq7jW)=="table"and wNq7jW.Name and INOtn==
"b_"..wNq7jW.Name and wNq7jW.CustomFunction and not wNq7jW.CustomFunction2 then wNq7jW.CustomFunction2=wNq7jW.CustomFunction
wNq7jW.CustomFunction=function(_MnhaG,NxAiBM)
if
AddOnQuestDebug.Global.Data.CheckAtRun then if
_MnhaG.DEBUG and not _MnhaG.FOUND_ERROR and _MnhaG:DEBUG(NxAiBM)then _MnhaG.FOUND_ERROR=true end end
if not _MnhaG.FOUND_ERROR then return _MnhaG:CustomFunction2(NxAiBM)end end end end;if BundleQuestGeneration then
BundleQuestGeneration.Global.DebugQuest=AddOnQuestDebug.Global.DebugQuest end
self:OverwriteCreateQuests()API.AddSaveGameAction(self.OnSaveGameLoad)end
function AddOnQuestDebug.Global:ActivateDebug(kPP2ao,_C,qx6_V7_Q,ZhT2Ub)
if self.Data.DebugModeIsActive then return end;self.Data.DebugModeIsActive=true
self.Data.CheckAtStart=kPP2ao==true;QSB.DEBUG_CheckAtStart=kPP2ao==true
self.Data.CheckAtRun=_C==true;QSB.DEBUG_CheckAtRun=_C==true
self.Data.TraceQuests=qx6_V7_Q==true;QSB.DEBUG_TraceQuests=qx6_V7_Q==true
self.Data.DevelopingMode=ZhT2Ub==true;QSB.DEBUG_DevelopingMode=ZhT2Ub==true
self:ActivateQuestTrace()self:ActivateDevelopingMode()end
function AddOnQuestDebug.Global:ActivateQuestTrace()if self.Data.TraceQuests then
DEBUG_EnableQuestDebugKeys()DEBUG_QuestTrace(true)end end
function AddOnQuestDebug.Global:ActivateDevelopingMode()if self.Data.DevelopingMode then
Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:ActivateDevelopingMode()")end end
function AddOnQuestDebug.Global:Parser(yX9)local p=self:Tokenize(yX9)
for lAoiaix,R in
pairs(self.Data.DebugCommands)do
if R[1]==p[1]then for u8eA5KA=1,#p do local GbCv4OVA=tonumber(p[u8eA5KA])if GbCv4OVA then
p[u8eA5KA]=GbCv4OVA end end
R[2](AddOnQuestDebug.Global,p,R[3])return end end end
function AddOnQuestDebug.Global:Tokenize(N_t)local QgpDVU={}local bOpF=N_t
while
(bOpF and bOpF:len()>0)do local Y,X=string.find(bOpF," ")if X then
QgpDVU[#QgpDVU+1]=bOpF:sub(1,X-1)bOpF=bOpF:sub(X+1,bOpF:len())else
QgpDVU[#QgpDVU+1]=bOpF;bOpF=nil end end;return QgpDVU end;function AddOnQuestDebug.Global:CollectGarbage()collectgarbage()
Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:CollectGarbage()")end
function AddOnQuestDebug.Global:CountLuaLoad()
Logic.ExecuteInLuaLocalState("AddOnQuestDebug.Local:CountLuaLoad()")local GKDCh=collectgarbage("count")
API.StaticNote("Global Lua Size: "..GKDCh)end
function AddOnQuestDebug.Global:PrintQuests(nv,KGfF)local k3VGYa=""local K=0;local UlVp=function(yp3K1T,uW_J)
return yp3K1T.State==uW_J end;if KGfF==3 then
self:PrintDetail(nv)return end;if KGfF==1 then UlVp=function(Lt,QDdX)
return string.find(Lt.Identifier,QDdX)end elseif KGfF==2 then
nv[2]=QuestState.Active end
for rqJGwNsW=1,Quests[0]do
if
Quests[rqJGwNsW]then
if UlVp(Quests[rqJGwNsW],nv[2])then K=K+1
if K<=15 then
k3VGYa=k3VGYa.. (
(k3VGYa:len()>0 and"{cr}")or"")k3VGYa=k3VGYa..Quests[rqJGwNsW].Identifier end end end end
if K>=15 then k3VGYa=k3VGYa..
"{cr}{cr}(".. (K-15).." weitere Ergebnis(se) gefunden!)"end
Logic.ExecuteInLuaLocalState([[
        GUI.ClearNotes()
        GUI.AddStaticNote("]]..k3VGYa..[[")
    ]])end
function AddOnQuestDebug.Global:PrintDetail(hj)local MtcdpVP=""
local yM=GetQuestID(string.gsub(hj[2]," ",""))
if Quests[yM]then
local b472=
(Quests[yM].State==QuestState.NotTriggered and"not triggered")or
(Quests[yM].State==QuestState.Active and"active")or"over"
local TDguj=

(Quests[yM].Result==QuestResult.Success and"success")or
(Quests[yM].Result==QuestResult.Failure and"failure")or
(Quests[yM].Result==
QuestResult.Interrupted and"interrupted")or"undecided"
MtcdpVP=MtcdpVP.."Name: "..Quests[yM].Identifier.."{cr}"MtcdpVP=MtcdpVP.."State: "..b472 .."{cr}"MtcdpVP=
MtcdpVP.."Result: "..TDguj.."{cr}"
MtcdpVP=
MtcdpVP.."Sender: "..Quests[yM].SendingPlayer.."{cr}"MtcdpVP=MtcdpVP..
"Receiver: "..Quests[yM].ReceivingPlayer.."{cr}"
MtcdpVP=MtcdpVP.."Duration: "..
Quests[yM].Duration.."{cr}"
MtcdpVP=MtcdpVP.."Start Text: "..
tostring(Quests[yM].QuestStartMsg).."{cr}"
MtcdpVP=MtcdpVP.."Failure Text: "..
tostring(Quests[yM].QuestFailureMsg).."{cr}"
MtcdpVP=MtcdpVP.."Success Text: "..
tostring(Quests[yM].QuestSuccessMsg).."{cr}"
MtcdpVP=MtcdpVP.."Description: "..
tostring(Quests[yM].QuestDescription).."{cr}"MtcdpVP=MtcdpVP..
"Objectives: "..#Quests[yM].Objectives.."{cr}"
MtcdpVP=MtcdpVP.."Reprisals: "..#
Quests[yM].Reprisals.."{cr}"MtcdpVP=MtcdpVP..
"Rewards: "..#Quests[yM].Rewards.."{cr}"
MtcdpVP=MtcdpVP.."Triggers: "..#
Quests[yM].Triggers.."{cr}"else
MtcdpVP=MtcdpVP..tostring(hj[2]).." not found!"end
Logic.ExecuteInLuaLocalState([[
        GUI.ClearNotes()
        GUI.AddStaticNote("]]..MtcdpVP..[[")
    ]])end
function AddOnQuestDebug.Global:LoadScript(vRZqTR,pitSKP)
if vRZqTR[2]then
if pitSKP==true then
Logic.ExecuteInLuaLocalState(
[[Script.Load("]]..vRZqTR[2]..[[")]])elseif pitSKP==false then Script.Load(vRZqTR[2])end;if not self.Data.SurpassMessages then
Logic.DEBUG_AddNote("load script "..vRZqTR[2])end end end
function AddOnQuestDebug.Global:ExecuteCommand(jZX1zJ,GDOan)
if jZX1zJ[2]then local KZ7=""for F=2,#jZX1zJ do KZ7=KZ7 ..
" "..jZX1zJ[F]end
if GDOan==true then
jZX1zJ[2]=string.gsub(KZ7,"'","\'")
Logic.ExecuteInLuaLocalState([[]]..KZ7 ..[[]])elseif GDOan==false then
Logic.ExecuteInLuaLocalState([[GUI.SendScriptCommand("]]..KZ7 ..[[")]])end end end;function AddOnQuestDebug.Global:Clear()
Logic.ExecuteInLuaLocalState("GUI.ClearNotes()")end;function AddOnQuestDebug.Global:Diplomacy(_rRjO)
SetDiplomacyState(_rRjO[2],_rRjO[3],_rRjO[4])end;function AddOnQuestDebug.Global:RestartMap()
Logic.ExecuteInLuaLocalState("Framework.RestartMap()")end;function AddOnQuestDebug.Global:ShareView(hh)
Logic.SetShareExplorationWithPlayerFlag(hh[2],hh[3],hh[4])end
function AddOnQuestDebug.Global:SetPosition(bbfR)
local Y4mGAwwZ=GetID(bbfR[2])local Ig=GetID(bbfR[3])local qlckp,J,iFBY_Zyh=Logic.EntityGetPos(Ig)if
Logic.IsBuilding(Ig)==1 then
qlckp,J=Logic.GetBuildingApproachPosition(Ig)end
Logic.DEBUG_SetSettlerPosition(Y4mGAwwZ,qlckp,J)end
function AddOnQuestDebug.Global:QuestSuccess(mz7ro,P9j7I1)
local tNPB0=FindQuestsByName(mz7ro[2],P9j7I1)if#tNPB0 ==0 then return end
API.WinAllQuests(unpack(tNPB0))end
function AddOnQuestDebug.Global:QuestFailure(jRVhJx,k)
local Ex=FindQuestsByName(jRVhJx[2],k)if#Ex==0 then return end;API.FailAllQuests(unpack(Ex))end
function AddOnQuestDebug.Global:QuestInterrupt(Qe7GQI2,_mUlNz)
local mY8Jv=FindQuestsByName(Qe7GQI2[2],_mUlNz)if#mY8Jv==0 then return end
API.StopAllQuests(unpack(mY8Jv))end
function AddOnQuestDebug.Global:QuestTrigger(QNKVU,XZIM)
local RCZlr=FindQuestsByName(QNKVU[2],XZIM)if#RCZlr==0 then return end
API.StartAllQuests(unpack(RCZlr))end
function AddOnQuestDebug.Global:QuestReset(PD0db,Zc5t)
local kH=FindQuestsByName(PD0db[2],Zc5t)if#kH==0 then return end;API.RestartAllQuests(unpack(kH))end
function AddOnQuestDebug.Global:OverwriteCreateQuests()
self.Data.CreateQuestsOriginal=CreateQuests
CreateQuests=function()if
not AddOnQuestDebug.Global.Data.CheckAtStart then
AddOnQuestDebug.Global.Data.CreateQuestsOriginal()return end
local jgQPxNo=Logic.Quest_GetQuestNames()
for E7IYK=1,#jgQPxNo,1 do local VckH8l=jgQPxNo[E7IYK]
local v8Zt3n={Logic.Quest_GetQuestParamter(VckH8l)}local A={}
local E1s5QwZo=Logic.Quest_GetQuestNumberOfBehaviors(VckH8l)
for Mtk5vQl=0,E1s5QwZo-1,1 do
local wmtDx=Logic.Quest_GetQuestBehaviorName(VckH8l,Mtk5vQl)local SR=GetBehaviorTemplateByName(wmtDx)
assert(SR~=nil)
local k=Logic.Quest_GetQuestBehaviorParameter(VckH8l,Mtk5vQl)API.DumpTable(k)
table.insert(A,SR:new(unpack(k)))end
API.AddQuest{Name=VckH8l,Sender=v8Zt3n[1],Receiver=v8Zt3n[2],Time=v8Zt3n[4],Description=v8Zt3n[5],Suggestion=v8Zt3n[6],Failure=v8Zt3n[7],Success=v8Zt3n[8],unpack(A)}end;API.StartQuests()end end
function AddOnQuestDebug.Global.OnSaveGameLoad(zY5m7kx7,E)
AddOnQuestDebug.Global:ActivateDevelopingMode()
AddOnQuestDebug.Global:ActivateQuestTrace()end
function AddOnQuestDebug.Global.DebugQuest(q29Uv,h)
if
AddOnQuestDebug.Global.Data.CheckAtStart then
if h.Goals then
for LzA=1,#h.Goals,1 do
if type(h.Goals[LzA][2])=="table"and
type(h.Goals[LzA][2][1])=="table"then if

h.Goals[LzA][2][1].DEBUG and h.Goals[LzA][2][1]:DEBUG(h)then return false end end end end
if h.Reprisals then
for h59T9dU_=1,#h.Reprisals,1 do
if
type(h.Reprisals[h59T9dU_][2])=="table"and
type(h.Reprisals[h59T9dU_][2][1])=="table"then
if
h.Reprisals[h59T9dU_][2][1].DEBUG and
h.Reprisals[h59T9dU_][2][1]:DEBUG(h)then return false end end end end
if h.Rewards then
for tx=1,#h.Rewards,1 do
if type(h.Rewards[tx][2])=="table"and
type(h.Rewards[tx][2][1])=="table"then if

h.Rewards[tx][2][1].DEBUG and h.Rewards[tx][2][1]:DEBUG(h)then return false end end end end
if h.Triggers then
for XC=1,#h.Triggers,1 do
if type(h.Triggers[XC][2])=="table"and
type(h.Triggers[XC][2][1])=="table"then if

h.Triggers[XC][2][1].DEBUG and h.Triggers[XC][2][1]:DEBUG(h)then return false end end end end end;return true end;function AddOnQuestDebug.Local:Install()end;function AddOnQuestDebug.Local:CollectGarbage()
collectgarbage()end
function AddOnQuestDebug.Local:CountLuaLoad()
local U=collectgarbage("count")API.StaticNote("Local Lua Size: "..U)end
function AddOnQuestDebug.Local:ActivateDevelopingMode()
KeyBindings_EnableDebugMode(1)KeyBindings_EnableDebugMode(2)
KeyBindings_EnableDebugMode(3)
XGUIEng.ShowWidget("/InGame/Root/Normal/AlignTopLeft/GameClock",1)GUI_Chat.Abort=function()end
GUI_Chat.Confirm=function()Input.GameMode()
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",0)
AddOnQuestDebug.Local.Data.ChatBoxInput=XGUIEng.GetText("/InGame/Root/Normal/ChatInput/ChatInput")g_Chat.JustClosed=1
Game.GameTimeSetFactor(GUI.GetPlayerID(),1)end
QSB_DEBUG_InputBoxJob=function()
if
not AddOnQuestDebug.Local.Data.BoxShown then Input.ChatMode()
Game.GameTimeSetFactor(GUI.GetPlayerID(),0)
XGUIEng.ShowWidget("/InGame/Root/Normal/ChatInput",1)
XGUIEng.SetText("/InGame/Root/Normal/ChatInput/ChatInput","")
XGUIEng.SetFocus("/InGame/Root/Normal/ChatInput/ChatInput")AddOnQuestDebug.Local.Data.BoxShown=true elseif
AddOnQuestDebug.Local.Data.ChatBoxInput then
AddOnQuestDebug.Local.Data.ChatBoxInput=string.gsub(AddOnQuestDebug.Local.Data.ChatBoxInput,"'","\'")
GUI.SendScriptCommand("AddOnQuestDebug.Global:Parser('"..
AddOnQuestDebug.Local.Data.ChatBoxInput.."')")AddOnQuestDebug.Local.Data.BoxShown=nil
return true end end
Input.KeyBindDown(Keys.ModifierShift+Keys.OemPipe,"StartSimpleJob('QSB_DEBUG_InputBoxJob')",2,true)end;Core:RegisterBundle("AddOnQuestDebug")API=API or{}QSB=QSB or
{}
function API.CreateIOMine(Xp,c,e,sOA,rCZvJK1,D7RiOn5J,I)if GUI then
API.Dbg("API.CreateIOMine: Can not be used from local script!")return end
AddOnInteractiveObjectTemplates.Global:CreateIOMine(Xp,c,e,sOA,rCZvJK1,D7RiOn5J,I)end;CreateIOMine=API.CreateIOMine
function API.CreateIOIronMine(KG4MJ,BYzo,FMk,t1,z,T9OCU6H)if GUI then
API.Dbg("API.CreateIOIronMine: Can not be used from local script!")return end
AddOnInteractiveObjectTemplates.Global:CreateIOIronMine(KG4MJ,BYzo,FMk,t1,z,T9OCU6H)end;CreateIOIronMine=API.CreateIOIronMine
function API.CreateIOStoneMine(Z,Hlul0b,Q2x8,U,Zjolrl,oob)if GUI then
API.Dbg("API.CreateIOStoneMine: Can not be used from local script!")return end
AddOnInteractiveObjectTemplates.Global:CreateIOStoneMine(Z,Hlul0b,Q2x8,U,Zjolrl,oob)end;CreateIOStoneMine=API.CreateIOStoneMine
function API.CreateIOBuildingSite(uz1QbP,kdK,LLcX,EeTTSd,uOSMMxD,Q52N,k,Y,kMAd)if GUI then
API.Dbg("API.CreateIOBuildingSite: Can not be used from local script!")return end
AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite(uz1QbP,kdK,LLcX,EeTTSd,uOSMMxD,Q52N,k,Y,kMAd)end;CreateIOBuildingSite=API.CreateIOBuildingSite
function API.CreateRandomChest(Oa37,fOep3lxK,_rQ2,XJY4VPk,jcMzJ)if GUI then
API.Dbg("API.CreateRandomChest: Can not be used from local script!")return end
AddOnInteractiveObjectTemplates.Global:CreateRandomChest(Oa37,fOep3lxK,_rQ2,XJY4VPk,jcMzJ)end;CreateRandomChest=API.CreateRandomChest
function API.CreateRandomGoldChest(YD4oC)if GUI then
API.Dbg("API.CreateRandomGoldChest('"..
YD4oC.."')")return end
AddOnInteractiveObjectTemplates.Global:CreateRandomChest(YD4oC,Goods.G_Gold,300,600)end;CreateRandomGoldChest=API.CreateRandomGoldChest
function API.CreateRandomResourceChest(K)if GUI then
API.Bridge(
"API.CreateRandomResourceChest('"..K.."')")return end
AddOnInteractiveObjectTemplates.Global:CreateRandomResourceChest(K)end;CreateRandomResourceChest=API.CreateRandomResourceChest
function API.CreateRandomLuxuryChest(S1y5X85S)if GUI then
API.Bridge(
"API.CreateRandomLuxuryChest('"..S1y5X85S.."')")return end
AddOnInteractiveObjectTemplates.Global:CreateRandomLuxuryChest(S1y5X85S)end;CreateRandomLuxuryChest=API.CreateRandomLuxuryChest
function API.CreateTrebuchetConstructionSite(LwesnkL,wR,vZWtu5E1)if GUI then
API.Bridge(
"API.CreateTrebuchetConstructionSite('"..
LwesnkL.."', "..wR..", "..vZWtu5E1 ..")")return end
AddOnInteractiveObjectTemplates.Global:CreateTrebuchetConstructionSite(LwesnkL,wR,vZWtu5E1)end;CreateTrebuchetConstructionSite=API.CreateTrebuchetConstructionSite
function API.DestroyTrebuchetConstructionSite(FR)if
GUI then
API.Bridge("API.DestroyTrebuchetConstructionSite('"..FR.."')")return end
AddOnInteractiveObjectTemplates.Global:DestroyTrebuchetConstructionSite(FR)end;DestroyTrebuchetConstructionSite=API.DestroyTrebuchetConstructionSite
function API.GetTrebuchetByTrebuchetConstructionSite(P)if
GUI then
API.Dbg("API.GetTrebuchetByTrebuchetConstructionSite: Can only be used in global script!")return end
if not
self.Data.Trebuchet.Sites[P]then
API.Warn("API.GetTrebuchetByTrebuchetConstructionSite: Site '"..
tostring(P).."' does not exist!")return 0 end
return self.Data.Trebuchet.Sites[P].ConstructedTrebuchet end;GetTrebuchet=API.GetTrebuchetByTrebuchetConstructionSite
function API.GetReturningCartByTrebuchetConstructionSite(r)if
GUI then
API.Dbg("API.GetReturningCartByTrebuchetConstructionSite: Can only be used in global script!")return end
if not
self.Data.Trebuchet.Sites[r]then
API.Warn("API.GetReturningCartByTrebuchetConstructionSite: Site '"..
tostring(r).."' does not exist!")return 0 end
return self.Data.Trebuchet.Sites[r].ReturningCart end;GetReturningCart=API.GetReturningCartByTrebuchetConstructionSite
function API.GetConstructionCartByTrebuchetConstructionSite(LQi3b)if
GUI then
API.Dbg("API.GetConstructionCartByTrebuchetConstructionSite: Can only be used in global script!")return end
if not
self.Data.Trebuchet.Sites[LQi3b]then
API.Warn("API.GetConstructionCartByTrebuchetConstructionSite: Site '"..tostring(LQi3b)..
"' does not exist!")return 0 end
return self.Data.Trebuchet.Sites[LQi3b].ConstructionCart end;GetConstructionCart=API.GetConstructionCartByTrebuchetConstructionSite
AddOnInteractiveObjectTemplates={Global={Data={ConstructionSite={Sites={},Description={Title={de="Gebäude bauen",en="Create building"},Text={de=
"Beauftragt den Bau eines Gebäudes. Ein Siedler wird aus".." dem Lagerhaus kommen und mit dem Bau beginnen.",en=
"Order a building. A worker will come out of the".." storehouse and erect it."},Unfulfilled={de="Das Gebäude kann derzeit nicht gebaut werden.",en="The building can not be built at the moment."}}},Mines={Description={Title={de="Mine errichten",en="Build pit"},Text={de="An diesem Ort könnt Ihr eine Mine errichten!",en="You're able to create a pit at this location!"}}},Chests={Description={Title={de="Schatztruhe",en="Treasure Chest"},Text={de="Diese Truhe enthält einen geheimen Schatz. Öffnet sie um den Schatz zu bergen.",en="This chest contains a secred treasure. Open it to salvage the treasure."}}},Trebuchet={Error={de="Euer Ritter benötigt einen höheren Titel!",en="Your knight need a higher title to use this site!"},Description={Title={de="Trebuchet anfordern",en="Order trebuchet"},Text={de="- Fordert ein Trebuchet aus der Stadt an {cr}- Trebuchet wird gebaut, wenn Wagen Baustelle erreicht {cr}- Fährt zurück, wenn Munition aufgebraucht {cr}- Trebuchet kann manuell zurückgeschickt werden",en="- Order a trebuchet from your city {cr}- The trebuchet is build after the cart has arrived {cr}- Returns after ammunition is depleted {cr}- The trebuchet can be manually send back to the city"}},Sites={},NeededKnightTitle=0,IsActive=false}}},Local={Data={}}}
function AddOnInteractiveObjectTemplates.Global:Install()end
function AddOnInteractiveObjectTemplates.Global:TrebuchetActivate()
if not
self.Data.Trebuchet.IsActive then
GameCallback_QSB_OnDisambleTrebuchet=AddOnInteractiveObjectTemplates.Global.OnTrebuchetDisambled;GameCallback_QSB_OnErectTrebuchet=function()end
StartSimpleJobEx(self.WatchTrebuchetsAndCarts)API.DisableRefillTrebuchet(true)
self.Data.Trebuchet.IsActive=true end end
function AddOnInteractiveObjectTemplates.Global.TrebuchetHasSufficentTitle()local mtv=1
for vLTmF7I=1,8 do if
Logic.PlayerGetIsHumanFlag(vLTmF7I)==1 then mtv=vLTmF7I;break end end
return Logic.GetKnightTitle(mtv)>=
AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.NeededKnightTitle end;function AddOnInteractiveObjectTemplates.Global:TrebuchetSetNeededKnightTitle(DhAt)
self.Data.Trebuchet.NeededKnightTitle=DhAt end
function AddOnInteractiveObjectTemplates.Global:CreateTrebuchetConstructionSite(Ngik,p,l)
self:TrebuchetActivate()p=p or 4500;l=l or 35;local yortib=GetID(Ngik)
Logic.SetModel(yortib,Models.Buildings_B_BuildingPlot_8x8)Logic.SetVisible(yortib,true)
self.Data.Trebuchet.Sites[Ngik]={ConstructedTrebuchet=0,ConstructionCart=0,ReturningCart=0}
CreateObject{Name=Ngik,Title=self.Data.Trebuchet.Description.Title,Text=self.Data.Trebuchet.Description.Text,Costs={Goods.G_Gold,p,Goods.G_Wood,l},Distance=1000,State=0,Condition=self.TrebuchetHasSufficentTitle,ConditionUnfulfilled=self.Data.Trebuchet.Error,Callback=function(msx,yomadRP)
AddOnInteractiveObjectTemplates.Global:SpawnTrebuchetCart(yomadRP,msx.Name)end}end
function AddOnInteractiveObjectTemplates.Global:DestroyTrebuchetConstructionSite(Hg)
local gLLH8V=self.Data.Trebuchet.Sites[Hg].ConstructionCart;DestroyEntity(gLLH8V)
local b8juqURD=self.Data.Trebuchet.Sites[Hg].ConstructedTrebuchet;DestroyEntity(b8juqURD)
local R3b=self.Data.Trebuchet.Sites[Hg].ReturningCart;DestroyEntity(R3b)
self.Data.Trebuchet.Sites[Hg]=nil;Logic.SetVisible(GetID(Hg),false)
RemoveInteractiveObject(Hg)end
function AddOnInteractiveObjectTemplates.Global:SpawnTrebuchetCart(nCvVQ_,qRO)
local RwV7Nz=Logic.GetStoreHouse(nCvVQ_)local zdt,x=Logic.GetBuildingApproachPosition(RwV7Nz)
local tKhKAqHm=Logic.CreateEntity(Entities.U_SiegeEngineCart,zdt,x,0,nCvVQ_)Logic.SetEntitySelectableFlag(tKhKAqHm,0)
self.Data.Trebuchet.Sites[qRO].ConstructionCart=tKhKAqHm end
function AddOnInteractiveObjectTemplates.Global:SpawnTrebuchet(g,O1dT5mO)
local ut=GetPosition(O1dT5mO)
local eFM93=Logic.CreateEntity(Entities.U_Trebuchet,ut.X,ut.Y,0,g)
self.Data.Trebuchet.Sites[O1dT5mO].ConstructedTrebuchet=eFM93 end
function AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(c8rvHYR,VZGKX)
local X,P,U=Logic.EntityGetPos(VZGKX)
local xa=Logic.CreateEntity(Entities.U_SiegeEngineCart,X,P,0,c8rvHYR)Logic.SetEntitySelectableFlag(xa,0)local YHx7fa
for spbQC,W in
pairs(self.Data.Trebuchet.Sites)do if W.ConstructedTrebuchet==VZGKX then YHx7fa=spbQC end end
if YHx7fa then
self.Data.Trebuchet.Sites[YHx7fa].ReturningCart=xa
self.Data.Trebuchet.Sites[YHx7fa].ConstructedTrebuchet=0;Logic.SetVisible(GetID(YHx7fa),true)
DestroyEntity(VZGKX)else DestroyEntity(xa)end end
function AddOnInteractiveObjectTemplates.Global.OnTrebuchetDisambled(Chad,c,RDORLQZ0,U,D04pnwO)
AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(c,Chad)end
function AddOnInteractiveObjectTemplates.Global.WatchTrebuchetsAndCarts()
for yrho,z in
pairs(AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites)do local PcTlm=GetID(yrho)
if z.ConstructionCart~=0 then
if
not IsExisting(z.ConstructionCart)then
AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[yrho].ConstructionCart=0;API.InteractiveObjectActivate(yrho)end
if not Logic.IsEntityMoving(z.ConstructionCart)then
local PcTlm=GetID(yrho)local Q7TY8NY,RX6M,SFfj=Logic.EntityGetPos(PcTlm)
Logic.MoveSettler(z.ConstructionCart,Q7TY8NY,RX6M)end
if IsNear(z.ConstructionCart,yrho,500)then
local d,Tf7u,aJ4UY=Logic.EntityGetPos(PcTlm)local vE090BRT=Logic.EntityGetPlayer(z.ConstructionCart)
AddOnInteractiveObjectTemplates.Global:SpawnTrebuchet(vE090BRT,yrho)DestroyEntity(z.ConstructionCart)
AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[yrho].ConstructionCart=0;Logic.SetVisible(PcTlm,false)
Logic.CreateEffect(EGL_Effects.E_Shockwave01,d,Tf7u,0)end end
if z.ConstructedTrebuchet~=0 then
if
not IsExisting(z.ConstructedTrebuchet)then
AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[yrho].ConstructedTrebuchet=0;Logic.SetVisible(PcTlm,true)
API.InteractiveObjectActivate(yrho)end
if
Logic.GetAmmunitionAmount(z.ConstructedTrebuchet)==0 and
BundleEntitySelection.Local.Data.RefillTrebuchet==false then
local d0Fk=Logic.EntityGetPlayer(z.ConstructedTrebuchet)
AddOnInteractiveObjectTemplates.Global:ReturnTrebuchetToStorehouse(d0Fk,z.ConstructedTrebuchet)end end
if z.ReturningCart~=0 then
if not IsExisting(z.ReturningCart)then
AddOnInteractiveObjectTemplates.Global.Data.Trebuchet.Sites[yrho].ReturningCart=0;API.InteractiveObjectActivate(yrho)end;local MJUH=Logic.EntityGetPlayer(z.ReturningCart)
local Zd=Logic.GetStoreHouse(MJUH)
if not Logic.IsEntityMoving(z.ReturningCart)then
local ED,xebxis=Logic.GetBuildingApproachPosition(Zd)Logic.MoveSettler(z.ReturningCart,ED,xebxis)end
if IsNear(z.ReturningCart,Zd,1100)then
local MJUH=Logic.EntityGetPlayer(z.ConstructionCart)DestroyEntity(z.ReturningCart)end end end end
function AddOnInteractiveObjectTemplates.Global:CreateRandomChest(uskpT,o3WjYh,T3DvJ,ZLyg,PU)
T3DvJ=(T3DvJ~=nil and
T3DvJ>0 and T3DvJ)or 1
ZLyg=(ZLyg~=nil and ZLyg>1 and ZLyg)or 2;if not PU then PU=function(fzML)end end
assert(o3WjYh~=nil,"CreateRandomChest: Good does not exist!")
assert(T3DvJ<ZLyg,"CreateRandomChest: min amount must be smaller than max amount!")
local ngftFCT=ReplaceEntity(uskpT,Entities.XD_ScriptEntity,0)
Logic.SetModel(ngftFCT,Models.Doodads_D_X_ChestClose)Logic.SetVisible(ngftFCT,true)
CreateObject{Name=uskpT,Title=self.Data.Chests.Description.Title,Text=self.Data.Chests.Description.Text,Reward={o3WjYh,math.random(T3DvJ,ZLyg)},Texture={1,6},Distance=650,State=0,CallbackOpened=PU,Callback=function(h)
ReplaceEntity(h.Name,Entities.D_X_ChestOpenEmpty)h.CallbackOpened(h)end}end
function AddOnInteractiveObjectTemplates.Global:CreateRandomGoldChest(XU5)
AddOnInteractiveObjectTemplates.Global:CreateRandomChest(XU5,Goods.G_Gold,300,600)end
function AddOnInteractiveObjectTemplates.Global:CreateRandomResourceChest(Fsu)
local pm={Goods.G_Iron,Goods.G_Stone,Goods.G_Wood,Goods.G_Wool,Goods.G_Carcass,Goods.G_Herb,Goods.G_Honeycomb,Goods.G_Milk,Goods.G_RawFish,Goods.G_Grain}local P0Z47Ai=pm[math.random(1,#pm)]
AddOnInteractiveObjectTemplates.Global:CreateRandomChest(Fsu,P0Z47Ai,30,60)end
function AddOnInteractiveObjectTemplates.Global:CreateRandomLuxuryChest(yx7xuV)
local NfF6ElE8={Goods.G_Salt,Goods.G_Dye}
if g_GameExtraNo>=1 then table.insert(NfF6ElE8,Goods.G_Gems)
table.insert(NfF6ElE8,Goods.G_MusicalInstrument)table.insert(NfF6ElE8,Goods.G_Olibanum)end;local sgC=NfF6ElE8[math.random(1,#NfF6ElE8)]
AddOnInteractiveObjectTemplates.Global:CreateRandomChest(yx7xuV,sgC,50,100)end
function AddOnInteractiveObjectTemplates.Global:CreateIOMine(QPSlOyr,R0dXxj,R9u,PzIdLA,iu,GiTj,kxFUm3)
local YD1Y=ReplaceEntity(QPSlOyr,Entities.XD_ScriptEntity)local F=Models.Doodads_D_SE_ResourceIron_Wrecked;if
R0dXxj==Entities.R_StoneMine then F=Models.R_SE_ResorceStone_10 end
Logic.SetVisible(YD1Y,true)Logic.SetModel(YD1Y,F)
local RLauqBm,t,b=Logic.EntityGetPos(YD1Y)
local HhVQ=Logic.CreateEntity(Entities.D_ME_Rock_Set01_B_07,RLauqBm,t,0,0)Logic.SetVisible(HhVQ,false)
CreateObject{Name=QPSlOyr,Title=self.Data.Mines.Description.Title,Text=self.Data.Mines.Description.Text,Type=R0dXxj,Special=PzIdLA,Costs=R9u,InvisibleBlocker=HhVQ,Distance=1500,Condition=self.ConditionBuildIOMine,CustomCondition=iu,ConditionUnfulfilled="Not implemented yet!",CallbackCreate=GiTj,CallbackDepleted=kxFUm3,Callback=self.ActionBuildIOMine}end
function AddOnInteractiveObjectTemplates.Global:CreateIOIronMine(KxoUpqFE,u,IADfr4S3,GrL6olXS,bu6,R)
assert(IsExisting(KxoUpqFE))
if u then assert(API.TraverseTable(u,Goods))assert(
type(IADfr4S3)=="number")end
if GrL6olXS then
assert(API.TraverseTable(GrL6olXS,Goods))assert(type(bu6)=="number")end
self:CreateIOMine(KxoUpqFE,Entities.R_IronMine,{u,IADfr4S3,GrL6olXS,bu6},R)end
function AddOnInteractiveObjectTemplates.Global:CreateIOStoneMine(EtJdUZ,dtQg85m1,PZrx2RR,WNo6rk8Y,Tc,PpPWp)
assert(IsExisting(EtJdUZ))
if dtQg85m1 then
assert(API.TraverseTable(dtQg85m1,Goods))assert(type(PZrx2RR)=="number")end
if WNo6rk8Y then
assert(API.TraverseTable(WNo6rk8Y,Goods))assert(type(Tc)=="number")end
self:CreateIOMine(EtJdUZ,Entities.R_StoneMine,{dtQg85m1,PZrx2RR,WNo6rk8Y,Tc},PpPWp)end
function AddOnInteractiveObjectTemplates.Global.ConditionBuildIOMine(drh_fwOO)if
drh_fwOO.CustomCondition then
return drh_fwOO.CustomCondition(drh_fwOO)==true end;return true end
function AddOnInteractiveObjectTemplates.Global.ActionBuildIOMine(P)
ReplaceEntity(P.Name,P.Type)DestroyEntity(P.InvisibleBlocker)
if type(P.CallbackCreate)==
"function"then P.CallbackCreate(P)end
Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,"","ControlIOMine",1,{},{P.Name})end
function AddOnInteractiveObjectTemplates.Global.ControlIOMine(PE)if not IO[PE]then
return true end;if not IsExisting(PE)then return true end
local PlUYS=GetID(PE)
if Logic.GetResourceDoodadGoodAmount(PlUYS)==0 then
if
IO[PE].Special==true then local RJ=Models.Doodads_D_SE_ResourceIron_Wrecked
if IO[PE].Type==
Entities.R_StoneMine then RJ=Models.R_ResorceStone_Scaffold_Destroyed end
PlUYS=ReplaceEntity(PlUYS,Entities.XD_ScriptEntity)Logic.SetVisible(PlUYS,true)
Logic.SetModel(PlUYS,RJ)end;if type(IO[PE].CallbackDepleted)=="function"then
IO[PE].CallbackDepleted(IO[PE])end;return true end end
function AddOnInteractiveObjectTemplates.Global:ConstructionSiteActivate()if
self.Data.ConstructionSiteActivated then return end
self.Data.ConstructionSiteActivated=true
Core:AppendFunction("GameCallback_OnBuildingConstructionComplete",self.OnConstructionComplete)end
function AddOnInteractiveObjectTemplates.Global.OnConstructionComplete(Hw_tk1RM,aEdSr)
local sgm=AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[aEdSr]if sgm~=nil and sgm.CompletedCallback then
sgm.CompletedCallback(sgm,aEdSr)end end
function AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite(q1sywblh,a4OdC8A,bGCfcNC,bPJy9vB,s2JH,NYDbF3OS,E,_qg,W09fPHP)
AddOnInteractiveObjectTemplates.Global:ConstructionSiteActivate()
local U=bPJy9vB or{Logic.GetEntityTypeFullCost(bGCfcNC)}
local wtMFz1In=E or self.Data.ConstructionSite.Description.Title
local RW7ED0IS=Text or self.Data.ConstructionSite.Description.Text;local G_ZC_=GetID(q1sywblh)
Logic.SetModel(G_ZC_,Models.Buildings_B_BuildingPlot_10x10)Logic.SetVisible(G_ZC_,true)
CreateObject{Name=q1sywblh,Title=wtMFz1In,Text=RW7ED0IS,Texture=NYDbF3OS or{14,10},Distance=
s2JH or 1500,Type=bGCfcNC,Costs=U,Condition=AddOnInteractiveObjectTemplates.Global.ConditionConstructionSite,ConditionUnfulfilled=AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Description.Unfulfilled,PlayerID=a4OdC8A,CompletedCallback=W09fPHP,Callback=AddOnInteractiveObjectTemplates.Global.CallbackIOConstructionSite}end
function AddOnInteractiveObjectTemplates.Global.CallbackIOConstructionSite(G)
local mPYod=GetPosition(G.Name)local W=GetID(G.Name)local Tx=Logic.GetEntityOrientation(W)
local bo0=Logic.CreateConstructionSite(mPYod.X,mPYod.Y,Tx,G.Type,G.PlayerID)Logic.SetVisible(W,false)if(bo0 ==nil)then
API.Dbg('AddOnInteractiveObjectTemplates.Global:CreateIOBuildingSite: Failed to place construction site!')return end
AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[bo0]=G
StartSimpleJobEx(AddOnInteractiveObjectTemplates.Global.ControlConstructionSite,bo0)end
function AddOnInteractiveObjectTemplates.Global.ConditionConstructionSite(F6Lv6)
local CD8byLjb=GetID(F6Lv6.Name)local HZed1=GetTerritoryUnderEntity(CD8byLjb)
local U2F8jO=Logic.GetTerritoryPlayerID(HZed1)
if Logic.GetStoreHouse(F6Lv6.PlayerID)==0 then return false end;if F6Lv6.PlayerID~=HZed1 then return false end;return true end
function AddOnInteractiveObjectTemplates.Global.ControlConstructionSite(JO)
if
AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[JO]==nil then return true end
if not IsExisting(JO)then
local tR3r0L=AddOnInteractiveObjectTemplates.Global.Data.ConstructionSite.Sites[JO].Name;Logic.SetVisible(GetID(tR3r0L),true)
API.InteractiveObjectActivate(tR3r0L)return true end end
function AddOnInteractiveObjectTemplates.Local:Install()end
Core:RegisterAddOn("AddOnInteractiveObjectTemplates")