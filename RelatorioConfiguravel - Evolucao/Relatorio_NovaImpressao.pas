unit Relatorio_NovaImpressao;

interface

uses Windows, SysUtils, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, QuickRpt, QRPrntr, QRCtrls, DB, DBClient, QRPDFFilt,
  CJVQRBarCode;

type
  TTipoBand = (tHeaderUnico, tHeaderPagina, tDetalhe, tSubDetalhe, tRodape);

  TRelatorioNovaImpressao = class(TQuickRep)
    QRBandDetalhe: TQRBand;
    QRBandRodape: TQRBand;
    QRPDFFilter1: TQRPDFFilter;
    QRBandSubDetalhe01: TQRSubDetail;
    QRBandCabecalhoProduto: TQRChildBand;
    QRBandDetalhe02: TQRChildBand;
    QRBandCabecalhoGeral: TQRBand;
    QRBand1: TQRBand;
    QRBand2: TQRBand;
    procedure QRBandCabecalhoGeralBeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
  private
    procedure ConfigurarCampoLabel(var Componente: TQRCustomLabel; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);
    procedure AdicionarCampoLabel(Texto: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);
    procedure AdicionarCampoDBLabel(Field: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);

    function GetParent(NomeComponente: String): TWinControl;
    procedure RedimensionarParent(Componente: TWinControl);

    procedure AdicionarBand(Nome: String; TipoBand: TTipoBand);
  public
    Constructor Create(AOwner: TComponent); override;
    procedure MontarRelatorio();
    procedure Preview();
  end;

implementation

{$R *.DFM}
{ TRelatorioNovaImpressao }

Constructor TRelatorioNovaImpressao.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;
  for I := 0 to ComponentCount - 1 do
    if (TComponent(Components[I]).ClassType = TQRBand) or (TComponent(Components[I]).ClassType = TQRSubDetail) or (TComponent(Components[I]).ClassType = TQRChildBand) then
    begin
      TQRCustomBand(Components[I]).Visible := False;
      TQRCustomBand(Components[I]).Height := 0;
      TQRCustomBand(Components[I]).TransparentBand := False;
    end;
end;

procedure TRelatorioNovaImpressao.Preview;
begin
  Self.PrevInitialZoom := qrZoom100;
  Self.PreviewInitialState := wsMaximized;
  Self.PrevShowThumbs := False;
  Self.PrevShowSearch := False;
  Self.PreviewModal;
end;

procedure TRelatorioNovaImpressao.ConfigurarCampoLabel(var Componente: TQRCustomLabel; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);
begin
  Componente.Parent := GetParent(NomeBand);
  Componente.Left := Coluna;
  Componente.Top := Linha;
  Componente.Font.Size := TamanhoFonte;
  Componente.Width := TamanhoMaxTexto;
  Componente.AutoSize := False;
  if (TamanhoMaxTexto = 0) then
    Componente.AutoSize := True;
  RedimensionarParent(Componente);
end;

procedure TRelatorioNovaImpressao.AdicionarCampoLabel(Texto: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);
var
  Componente: TQRCustomLabel;
begin
  Componente := TQRLabel.Create(Self);
  TQRLabel(Componente).Transparent := True;
  TQRLabel(Componente).Caption := Texto;
  ConfigurarCampoLabel(Componente, Linha, Coluna, TamanhoMaxTexto, TamanhoFonte, NomeBand);
end;

procedure TRelatorioNovaImpressao.AdicionarCampoDBLabel(Field: String; Linha, Coluna, TamanhoMaxTexto, TamanhoFonte: Integer; NomeBand: String);
var
  Componente: TQRCustomLabel;
  Parent: TComponent;
begin
  Componente := TQRDBText.Create(Self);
  TQRDBText(Componente).Transparent := True;

  Parent := GetParent(NomeBand);
  if (Parent <> nil) then
  begin
    if (Parent.ClassType = TQRSubDetail) then
      TQRDBText(Componente).DataSet := TQRSubDetail(Parent).DataSet
    else
      if (Parent.ClassType = TQRBand) or (Parent.ClassType = TQRChildBand) then
        TQRDBText(Componente).DataSet := Self.DataSet;
  end;

  TQRDBText(Componente).DataField := Field;
  ConfigurarCampoLabel(Componente, Linha, Coluna, TamanhoMaxTexto, TamanhoFonte, NomeBand);
end;

procedure TRelatorioNovaImpressao.AdicionarBand(Nome: String; TipoBand: TTipoBand);
var
  ABand: TComponent;
begin
  case TipoBand of
    tHeaderUnico: ABand := TComponent.Create(Self);
    tHeaderPagina: ABand := TComponent.Create(Self);
    tDetalhe: ABand := TComponent.Create(Self);
    tSubDetalhe: ABand := TComponent.Create(Self);
    tRodape: ABand := TComponent.Create(Self);
  end;
end;

function TRelatorioNovaImpressao.GetParent(NomeComponente: String): TWinControl;
begin
  Result := TWinControl(FindComponent(NomeComponente));
end;

procedure TRelatorioNovaImpressao.RedimensionarParent(Componente: TWinControl);
var
  TamanhoOcupadoComponente: Integer;
begin
  TamanhoOcupadoComponente := Componente.Top + Componente.Height;
  if (Componente.Parent <> nil) then // evitar exception de parent inexistente
    if (Componente.Parent.Height < TamanhoOcupadoComponente) then
      Componente.Parent.Height := TamanhoOcupadoComponente;
end;

procedure TRelatorioNovaImpressao.QRBandCabecalhoGeralBeforePrint(Sender: TQRCustomBand; var PrintBand: Boolean);
begin
  // PrintBand := (Self.PageNumber > 1);
end;

procedure TRelatorioNovaImpressao.MontarRelatorio();
const
  CabecalhoGeral = 'QRBandCabecalhoGeral';
  Detalhe = 'QRBandDetalhe';
  SubDetalhe01 = 'QRBandSubDetalhe01';
  SubDetalhe02 = 'QRBandSubDetalhe02';
  SubDetalhe03 = 'QRBandSubDetalhe03';
  RodapeGeral = 'QRBandRodape';
begin
  // AdicionarCampoLabel('texto cabe�alho unico', 1, 300, 0, 12, 'QRBandCabecalhoUnico');
  // AdicionarCampoLabel('Total Itens: ' + IntToStr(Self.DataSet.RecordCount), 1, 300, 0, 12, 'QRBandCabecalhoGeral');
  // AdicionarCampoLabel('texto fixo geral  ', 1, 100, 0, 12, 'QRBandCabecalhoGeral');
  // AdicionarCampoLabel('texto fixo produto', 1, 100, 0, 12, 'QRBandCabecalhoProduto');
  // AdicionarCampoLabel('texto fixo rodape ', 1, 100, 0, 12, 'QRBandRodape');
  // AdicionarCampoDBLabel('numero', 1, 50, 50, 12, 'QRBandCabecalhoUnico', 'D');
  // AdicionarCampoLabel('texto fixo detalhe', 1, 50, 0, 12, 'QRBandDetalhe');
  // AdicionarCampoDBLabel('numero', 100, 50, 0, 12, 'QRBandDetalhe', 'D');
  // AdicionarCampoDBLabel('numero', 2, 50, 0, 12, 'QRBand2', 'D');
  // AdicionarCampoDBLabel('numero', 1, 50, 0, 10, 'QRBandSubDetalhe', 'S');
  // AdicionarCampoDBLabel('produto', 1, 200, 0, 10, 'QRBandSubDetalhe', 'S');
  // AdicionarCampoLabel('texto fixo sub detalhe', 1, 300, 0, 10, 'QRBandSubDetalhe');

  AdicionarCampoLabel('Total Itens: ' + IntToStr(Self.DataSet.RecordCount), 1, 300, 0, 12, CabecalhoGeral);
  AdicionarCampoLabel('texto fixo em toda pagina  ', 1, 100, 0, 12, CabecalhoGeral);

  AdicionarCampoLabel('texto fixo em todo rodape ', 1, 100, 0, 12, RodapeGeral);

  AdicionarCampoLabel('texto corpo', 1, 300, 0, 12, Detalhe);
  AdicionarCampoDBLabel('numero', 1, 50, 50, 12, Detalhe);
  AdicionarCampoDBLabel('emissao', 1, 150, 0, 12, Detalhe);

  AdicionarCampoDBLabel('numero', 1, 50, 0, 10, SubDetalhe01);
  AdicionarCampoDBLabel('produto', 1, 200, 0, 10, SubDetalhe01);
  AdicionarCampoLabel('texto fixo sub detalhe', 10, 300, 0, 10, SubDetalhe01);
end;

end.