object DMForWHFishStore: TDMForWHFishStore
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object ProjMgr: TtpProject
    InstanceMonitoringMode = simmIgnoreInstanceNum
    OnBeforeFirstCreate = ProjMgrBeforeFirstCreate
    OnDataModulesCreate1 = ProjMgrDataModulesCreate1
    OnDataModulesCreate2 = ProjMgrDataModulesCreate2
    OnDataModulesCreate3 = ProjMgrDataModulesCreate3
    OnDataModulesInit = ProjMgrDataModulesInit
    OnGUICreate = ProjMgrGUICreate
    OnGUIInit = ProjMgrGUIInit
    OnStartupComplete = ProjMgrStartupComplete
    OnStartupError = ProjMgrStartupError
    OnStop = ProjMgrStop
    Left = 40
    Top = 32
  end
end
