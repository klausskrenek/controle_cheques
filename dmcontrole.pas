unit dmcontrole;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, DB, Dialogs;

type

  { TDataModuleControle }

  TDataModuleControle = class(TDataModule)
    DataSourceCheques: TDataSource;
    SQLite3ConnectionControle: TSQLite3Connection;
    SQLQueryCheques: TSQLQuery;
    SQLQueryChequesagencia: TStringField;
    SQLQueryChequesbanco: TStringField;
    SQLQueryChequescodigo: TAutoIncField;
    SQLQueryChequesconta: TStringField;
    SQLQueryChequesdata_cadastro: TDateField;
    SQLQueryChequesdata_compensado: TDateField;
    SQLQueryChequesdata_emissao: TDateField;
    SQLQueryChequesdescricao: TStringField;
    SQLQueryChequesfavorecido: TStringField;
    SQLQueryChequesnumero_cheque: TStringField;
    SQLQueryChequesstatus: TStringField;
    SQLQueryChequesvalor: TFloatField;
    SQLTransactionControle: TSQLTransaction;
    procedure SQLQueryChequesAfterPost(DataSet: TDataSet);
    procedure SQLQueryChequesdata_emissaoSetText(Sender: TField;
      const aText: string);
    procedure SQLQueryChequesNewRecord(DataSet: TDataSet);
    procedure SQLQueryChequesvalorSetText(Sender: TField; const aText: string);
  private

  public

  end;

var
  DataModuleControle: TDataModuleControle;

implementation

{$R *.lfm}

{ TDataModuleControle }

procedure TDataModuleControle.SQLQueryChequesvalorSetText(Sender: TField;
  const aText: string);
begin
  try
    if Trim(aText) = '' then
      Sender.Value := null
    else
      Sender.Value := StrToFloat(aText);
  except
    ShowMessage('Valor inválido!');
    Exit;
  end;
end;

procedure TDataModuleControle.SQLQueryChequesdata_emissaoSetText(Sender: TField;
  const aText: string);
begin
  try
    if aText = '  /  /    ' then
      Sender.Value := null
    else
      Sender.Value := StrToDate(aText);
  except
    ShowMessage('Data inválida!');
    Exit;
  end;
end;

procedure TDataModuleControle.SQLQueryChequesAfterPost(DataSet: TDataSet);
begin
  try
    SQLQueryCheques.ApplyUpdates;
    SQLTransactionControle.CommitRetaining;
    SQLQueryCheques.Refresh;
  except
    on e: Exception do
    begin
      SQLQueryCheques.CancelUpdates;
      SQLTransactionControle.RollbackRetaining;
      SQLQueryCheques.Refresh;
      ShowMessage('Não foi possível alterar o banco de dados!' +
        #13 + #13 + 'ERRO: ' + e.ClassName + #13 + 'MENSAGEM: ' + e.Message);
    end;
  end;
end;

procedure TDataModuleControle.SQLQueryChequesNewRecord(DataSet: TDataSet);
begin
  SQLQueryCheques.FieldByName('data_cadastro').AsDateTime := Date;
  SQLQueryCheques.FieldByName('status').AsString := 'A Compensar';
end;

end.

