object dmAsyncDemo: TdmAsyncDemo
  OldCreateOrder = True
  Height = 479
  Width = 742
  object waAsyncAction: TwhAsyncAction
    ComponentOptions = [tpUpdateOnLoad]
    OnExecute = waAsyncActionExecute
    TicksExpires = 3600000
    AsyncState = asInit
    Left = 35
    Top = 53
  end
end
