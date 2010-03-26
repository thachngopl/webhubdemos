inherited fmDBPanel: TfmDBPanel
  Left = 316
  Top = 151
  Width = 565
  Height = 447
  Caption = '&Database'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pa: TPanel
    Width = 557
    Height = 384
    object tpComponentPanel2: TtpComponentPanel
      Left = 5
      Top = 5
      Width = 172
      Height = 374
      TabOrder = 0
      object GroupBox1: TGroupBox
        Left = 1
        Top = 145
        Width = 170
        Height = 72
        Align = alTop
        Caption = 'dbExpress'
        TabOrder = 0
      end
      object GroupBox2: TGroupBox
        Left = 1
        Top = 1
        Width = 170
        Height = 72
        Align = alTop
        Caption = 'Scrolling Grid'
        TabOrder = 1
      end
      object GroupBox3: TGroupBox
        Left = 1
        Top = 73
        Width = 170
        Height = 72
        Align = alTop
        Caption = 'BDE'
        TabOrder = 2
      end
    end
    object Panel1: TPanel
      Left = 177
      Top = 5
      Width = 375
      Height = 374
      Align = alClient
      TabOrder = 1
      object DBGrid2: TDBGrid
        Left = 1
        Top = 66
        Width = 373
        Height = 307
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'MS Sans Serif'
        TitleFont.Style = []
      end
      object DBNavigator2: TDBNavigator
        Left = 1
        Top = 41
        Width = 373
        Height = 25
        Align = alTop
        TabOrder = 1
      end
      object tpToolBar: TtpToolBar
        Left = 1
        Top = 1
        Width = 373
        TabOrder = 2
        object tpToolButton1: TtpToolButton
          Left = 1
          Top = 1
          Width = 83
          Caption = 'Show Database'
          OnClick = tpToolButton1Click
          MinWidth = 28
        end
        object cbUseBDE: TCheckBox
          Left = 136
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Use BDE'
          TabOrder = 0
          OnClick = cbUseBDEClick
        end
      end
    end
  end
  object tpStatusBar1: TtpStatusBar
    Left = 0
    Top = 384
    Width = 557
    Height = 19
    Panels = <
      item
        Text = 'whbdeSource2: Not Updated'
        Width = 50
      end>
    ParentShowHint = False
    ShowHint = True
    PanelStatusIndex = 0
  end
  object BrowseScan: TwhdbScan
    OnUpdate = BrowseScanUpdate
    ComponentOptions = [tpUpdateOnLoad, tpStatusPanel]
    DataScanOptions = [dsbFirst, dsbPrior, dsbNext, dsbLast]
    ScanMode = dsByKey
    ButtonAutoHide = False
    OverlapScroll = True
    OnRowStart = BrowseScanRowStart
    OnInit = BrowseScanInit
    OnFinish = BrowseScanFinish
    WebDataSource = disabledBDE
    Left = 12
    Top = 24
  end
  object DataSource1: TDataSource
    DataSet = sdsScanDemo
    Left = 72
    Top = 24
  end
  object sdsScanDemo: TSimpleDataSet
    Aggregates = <>
    Connection.ConnectionName = 'IBConnection'
    Connection.DriverName = 'Interbase'
    Connection.GetDriverFunc = 'getSQLDriverINTERBASE'
    Connection.LibraryName = 'dbexpint.dll'
    Connection.LoginPrompt = False
    Connection.Params.Strings = (
      'DriverName=Interbase'
      'Database=demos.href.com:demowhScanTable'
      'RoleName=RoleName'
      'User_Name=sysdba'
      'Password=masterkey'
      'ServerCharSet=UTF8'
      'SQLDialect=3'
      'ErrorResourceFile='
      'LocaleCode=0000'
      'BlobSize=-1'
      'CommitRetain=False'
      'WaitOnLocks=True'
      'Interbase TransIsolation=ReadCommited'
      'Trim Char=False')
    Connection.VendorLib = 'gds32.dll'
    Connection.Connected = True
    DataSet.CommandText = 'GRAPHICS'
    DataSet.CommandType = ctTable
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    ReadOnly = True
    Left = 62
    Top = 174
  end
  object disabledDBX: TwhdbxSource
    ComponentOptions = [tpUpdateOnLoad, tpStatusPanel]
    GotoMode = wgGotoKey
    MaxOpenDataSets = 1
    OpenDataSets = 0
    OpenDataSetRetain = 600
    SaveTableName = False
    DataSource = DataSource1
    Left = 22
    Top = 174
  end
  object disabledBDE: TwhbdeSource
    ComponentOptions = [tpUpdateOnLoad, tpStatusPanel]
    GotoMode = wgGotoKey
    MaxOpenDataSets = 1
    OpenDataSets = 0
    OpenDataSetRetain = 600
    SaveTableName = False
    DataSource = DataSource1
    Left = 22
    Top = 102
  end
  object Table1: TtpTable
    TableMode = tmData
    PostBeforeClose = False
    HideLinkingKeys = False
    LeaveOpen = False
    Left = 118
    Top = 102
  end
  object DataSource2: TDataSource
    DataSet = Table1
    Left = 70
    Top = 102
  end
end
