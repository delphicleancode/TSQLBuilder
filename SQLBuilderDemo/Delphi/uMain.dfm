object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SQLBuilder Demo'
  ClientHeight = 600
  ClientWidth = 1289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1289
    Height = 49
    Align = alTop
    TabOrder = 0
    object cmbExamples: TComboBox
      Left = 16
      Top = 13
      Width = 649
      Height = 23
      Style = csDropDownList
      TabOrder = 0
      OnClick = buildSQL
    end
    object btnExecute: TButton
      Left = 680
      Top = 13
      Width = 105
      Height = 23
      Caption = 'Build SQL'
      TabOrder = 1
      OnClick = buildSQL
    end
  end
  object Panel1: TPanel
    Left = 625
    Top = 49
    Width = 664
    Height = 551
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object lblFormattedSQL: TLabel
      Left = 1
      Top = 1
      Width = 662
      Height = 15
      Align = alTop
      Caption = 'Formatted SQL:'
    end
    object memoFormattedSQL: TMemo
      Left = 1
      Top = 16
      Width = 662
      Height = 534
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 49
    Width = 625
    Height = 551
    Align = alLeft
    Caption = 'Panel2'
    TabOrder = 2
    object lblRawSQL: TLabel
      Left = 1
      Top = 1
      Width = 623
      Height = 15
      Align = alTop
      Caption = 'Raw SQL:'
    end
    object memoSQL: TMemo
      Left = 1
      Top = 16
      Width = 623
      Height = 534
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
end
