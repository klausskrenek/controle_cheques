unit uprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, ExtCtrls,
  DBCtrls, StdCtrls;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    ButtonFiltrar: TButton;
    ComboBoxFiltra: TComboBox;
    DBComboBoxStatus: TDBComboBox;
    DBEditCodigo: TDBEdit;
    DBEditFavorecido: TDBEdit;
    DBEdit1DataCompensado: TDBEdit;
    DBEditDataCadastro: TDBEdit;
    DBEditConta: TDBEdit;
    DBEditAgencia: TDBEdit;
    DBEditBanco: TDBEdit;
    DBEditDataEmissao: TDBEdit;
    DBEditNumeroCheque: TDBEdit;
    DBEditDescricao: TDBEdit;
    DBEditValor: TDBEdit;
    DBGridDados: TDBGrid;
    DBNavegador: TDBNavigator;
    EditFiltrar: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    procedure ButtonFiltrarClick(Sender: TObject);
    procedure ComboBoxFiltraSelect(Sender: TObject);
    procedure DBGridDadosTitleClick(Column: TColumn);
    procedure DBNavegadorBeforeAction(Sender: TObject; Button: TDBNavButtonType);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FormPrincipal: TFormPrincipal;

implementation

uses
  dmcontrole;

{$R *.lfm}

{ TFormPrincipal }

procedure TFormPrincipal.FormShow(Sender: TObject);
var
  sql: string;
begin
  DefaultFormatSettings.DateSeparator := '/';
  DefaultFormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  DefaultFormatSettings.ThousandSeparator := '.';
  DefaultFormatSettings.DecimalSeparator := ',';
  DefaultFormatSettings.CurrencyFormat := 2;
  DefaultFormatSettings.CurrencyString := 'R$';

  sql := 'CREATE TABLE IF NOT EXISTS cheques (' +
    'codigo INTEGER NOT NULL PRIMARY KEY,' + 'data_cadastro DATE,' +
    'conta VARCHAR(20),' + 'agencia VARCHAR(20),' + 'banco VARCHAR(50),' +
    'data_emissao DATE,' + 'numero_cheque VARCHAR(20),' +
    'descricao VARCHAR(200),' + 'favorecido VARCHAR(100),' +
    'valor DOUBLE PRECISION,' + 'status VARCHAR(12),' + 'data_compensado DATE);';

  try
    DataModuleControle.SQLite3ConnectionControle.DatabaseName :=
      ExtractFilePath(ParamStr(0)) + 'dados.db';
    DataModuleControle.SQLTransactionControle.Active := True;
    DataModuleControle.SQLite3ConnectionControle.ExecuteDirect(sql);
    DataModuleControle.SQLTransactionControle.CommitRetaining;
    DataModuleControle.SQLQueryCheques.Open;
  except
    on e: Exception do
    begin
      DataModuleControle.SQLTransactionControle.RollbackRetaining;
      ShowMessage('Não foi possível ativar o banco de dados, ' +
        'o aplicativo será fechado!' + #13 + #13 + 'ERRO: ' +
        e.ClassName + #13 + 'MENSAGEM: ' + e.Message);

      FormPrincipal.Hide;
      Application.ProcessMessages;
      Application.Terminate;
    end;
  end;

  ComboBoxFiltra.ItemIndex := 4;

  DBNavegador.ConfirmDelete := False;
end;

procedure TFormPrincipal.ComboBoxFiltraSelect(Sender: TObject);
begin
  EditFiltrar.Text := '';

  case ComboBoxFiltra.ItemIndex of
    0: DataModuleControle.SQLQueryCheques.Filter :=
        'status = ' + QuotedStr('A Compensar');
    1: DataModuleControle.SQLQueryCheques.Filter :=
        'status = ' + QuotedStr('Compensado');
    2: DataModuleControle.SQLQueryCheques.Filter :=
        'status = ' + QuotedStr('Cancelado');
    3: DataModuleControle.SQLQueryCheques.Filter :=
        'status = ' + QuotedStr('Voltou');
    4: DataModuleControle.SQLQueryCheques.Filter := '';
  end;
end;

procedure TFormPrincipal.DBGridDadosTitleClick(Column: TColumn);
begin
  DataModuleControle.SQLQueryCheques.Close;

  if Pos(Column.FieldName + 'ASC', DataModuleControle.SQLQueryCheques.SQL.Text) <= 0 then
    DataModuleControle.SQLQueryCheques.SQL.Text :=
      'SELECT * FROM cheques ORDER BY ' + Column.FieldName + ' ASC'
  else
    DataModuleControle.SQLQueryCheques.SQL.Text :=
      'SELECT * FROM cheques ORDER BY ' + Column.FieldName + ' DESC';

  DataModuleControle.SQLQueryCheques.Open;
end;

procedure TFormPrincipal.DBNavegadorBeforeAction(Sender: TObject;
  Button: TDBNavButtonType);
begin
  if Button = nbInsert then
    DBEditConta.SetFocus;

  if Button = nbPost then
  begin
    DBNavegador.SetFocus;
    if Trim(DBEditDescricao.Text) = '' then
    begin
      ShowMessage('Preencha a Descrição!');
      DBEditDescricao.SetFocus;
      Abort;
    end;
  end;

  if Button = nbDelete then
    if MessageDlg('Confirmação', 'Excluir Registro?', mtConfirmation,
      mbYesNo, '') <> 6 then
      Abort;
end;

procedure TFormPrincipal.ButtonFiltrarClick(Sender: TObject);
begin
  ComboBoxFiltra.ItemIndex := -1;

  if Trim(EditFiltrar.Text) = '' then
    DataModuleControle.SQLQueryCheques.Filter := ''
  else
    DataModuleControle.SQLQueryCheques.Filter :=
      'favorecido = ' + QuotedStr(EditFiltrar.Text + '*');
end;

end.
