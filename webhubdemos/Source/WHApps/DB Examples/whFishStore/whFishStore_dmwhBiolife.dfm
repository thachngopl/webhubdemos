object DMFishStoreBiolife: TDMFishStoreBiolife
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 422
  Width = 603
  object DataSourceA1: TDataSource
    DataSet = TableA1
    Left = 268
    Top = 193
  end
  object wdsa1: TwhdbSource
    ComponentOptions = []
    GotoMode = wgGotoKey
    KeyFieldNames = 'Species No'
    MaxOpenDataSets = 1
    OpenDataSets = 0
    OpenDataSetRetain = 600
    SaveTableName = False
    DataSource = DataSourceA1
    Left = 145
    Top = 193
  end
  object gfa1: TwhdbGrid
    ComponentOptions = []
    DataScanOptions = [dsbFirst, dsbPrior, dsbNext, dsbLast]
    ScanMode = dsByKey
    ButtonAutoHide = False
    OverlapScroll = False
    WebDataSource = wdsa1
    TR = '<tr>'
    TD = '<td>'
    Caption = ''
    ShowRecno = False
    Preformat = False
    Left = 54
    Top = 193
  end
  object DataSourceBiolife: TDataSource
    DataSet = FDMemTableBiolife
    Left = 276
    Top = 102
  end
  object WebDataSourceBiolife: TwhdbSource
    ComponentOptions = []
    GotoMode = wgGotoKey
    KeyFieldNames = 'Species No'
    MaxOpenDataSets = 1
    OpenDataSets = 0
    OpenDataSetRetain = 600
    SaveTableName = False
    DataSource = DataSourceBiolife
    Left = 145
    Top = 104
  end
  object gf: TwhdbGrid
    ComponentOptions = []
    DataScanOptions = [dsbFirst, dsbPrior, dsbNext, dsbLast]
    PageHeight = 3
    ScanMode = dsByKey
    ButtonAutoHide = False
    OverlapScroll = False
    WebDataSource = WebDataSourceBiolife
    Border = 'cellspacing="0"'
    TR = '<tr>'
    TD = '<td>'
    Caption = ''
    ShowRecno = False
    Preformat = False
    Left = 54
    Top = 102
  end
  object WebListGrid1: TwhListGrid
    ComponentOptions = []
    CaptionDelimiter = '@'
    LinesMode = wlgAsGrid
    Left = 53
    Top = 28
  end
  object TableA1: TClientDataSet
    Aggregates = <>
    FileName = 'D:\Projects\webhubdemos\Live\Database\embSample\biolife.xml'
    Params = <>
    Left = 416
    Top = 200
  end
  object waGrabFish: TwhWebAction
    ComponentOptions = []
    OnExecute = waGrabFishExecute
    Left = 56
    Top = 284
  end
  object waSaveCurrentFish: TwhWebActionEx
    ComponentOptions = []
    OnExecute = waSaveCurrentFishExecute
    Left = 176
    Top = 288
  end
  object FDMemTableBiolife: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 416
    Top = 104
  end
  object FDStanStorageBinLink1: TFDStanStorageBinLink
    Left = 472
    Top = 296
  end
end
