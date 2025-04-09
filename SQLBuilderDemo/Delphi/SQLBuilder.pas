unit SQLBuilder;

interface

uses
  SysUtils, Classes, StrUtils;

type
  TDatabaseType = (dtMySQL, dtFirebird, dtPostgreSQL, dtSQLite, dtSQLServer, dtOracle);

  { Forward declarations }
  TSQL = class;
  TCondition = class;
  TParameter = class;

  { TParameter - Para consultas parametrizadas }
  TParameter = class
  private
    FName: string;
    FValue: Variant;
    FDataType: Integer; // Usar TFieldType em uma implementação real
  public
    constructor Create(const AName: string; const AValue: Variant; ADataType: Integer = 0);
    property Name: string read FName;
    property Value: Variant read FValue;
    property DataType: Integer read FDataType;
  end;

  { TParameterList }
  TParameterList = class
  private
    FParameters: TList;
    function GetCount: Integer;
    function GetParameter(Index: Integer): TParameter;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const AName: string; const AValue: Variant; ADataType: Integer = 0): TParameter;
    procedure Clear;
    property Count: Integer read GetCount;
    property Parameters[Index: Integer]: TParameter read GetParameter; default;
  end;

  { TSQL }
  TSQL = class
  private
    // Existing fields
    FSelectClause: TStringList;
    FFromClause: TStringList;
    FJoinClause: TStringList;
    FWhereClause: TStringList;
    FGroupByClause: TStringList;
    FHavingClause: TStringList;
    FOrderByClause: TStringList;
    FLimitValue: Integer;
    FOffsetValue: Integer;
    FIsDistinct: Boolean;
    FDatabaseType: TDatabaseType;
    FBeginGroup: Boolean;
    FEndGroup: Boolean;
    
    // New fields for DML operations
    FInsertTable: string;
    FInsertColumns: TStringList;
    FInsertValues: TStringList;
    FUpdateTable: string;
    FUpdateValues: TStringList;
    FDeleteTable: string;
    
    // Fields for DDL operations
    FCreateTable: string;
    FTableColumns: TStringList;
    FTableConstraints: TStringList;
    FAlterTable: string;
    FAlterActions: TStringList;
    
    // Fields for CTE
    FCTEClause: TStringList;
    
    // Fields for parametrized queries
    FParameters: TParameterList;
    
    // Fields for transactions
    FTransactionCommands: TStringList;
    
    // Additional fields
    FSQLType: (stSelect, stInsert, stUpdate, stDelete, stCreate, stAlter, stDrop, stTransaction, stOther);
    
    property DatabaseType: TDatabaseType read FDatabaseType write FDatabaseType;

    class var FInstance: TSQL;
    class function GetInstance: TSQL; static;
    
    // Private helper methods
    function GetLimitOffsetClause: string;
    function BuildInsertSQL: string;
    function BuildUpdateSQL: string;
    function BuildDeleteSQL: string;
    function BuildCreateTableSQL: string;
    function BuildAlterTableSQL: string;
    function BuildWithCTE: string;

  public
    constructor Create;
    destructor Destroy; override;

    class function SELECT(AFields: array of string): TSQL; overload;
    class function SELECT(const AFields: string): TSQL; overload;
    class function DISTINCT: TSQL;
    class function FROM(ATables: array of string): TSQL; overload;
    class function FROM(const ATable: string): TSQL; overload;
    class function JOIN(const ATable: string; const AExpression: string): TSQL;
    class function LEFT_JOIN(const ATable: string; const AExpression: string): TSQL;
    class function RIGHT_JOIN(const ATable: string; const AExpression: string): TSQL;
    class function INNER_JOIN(const ATable: string; const AExpression: string): TSQL; overload;
    class function INNER_JOIN(const ATable: string; const AKeyName: string; const AKeyValue: string): TSQL; overload;
    class function WHERE(AConditions: array of string): TSQL; overload;
    class function WHERE(const ACondition: string): TSQL; overload;
    class function WHERE(const AField: string; const AValue: Variant): TSQL; overload;
    class function AND_WHERE(const ACondition: string): TSQL; overload;
    class function AND_WHERE(const AField: string; const AValue: Variant): TSQL; overload;
    class function OR_WHERE(const ACondition: string): TSQL; overload;
    class function OR_WHERE(const AField: string; const AValue: Variant): TSQL; overload;
    class function GROUP_BY(AFields: array of string): TSQL; overload;
    class function GROUP_BY(const AField: string): TSQL; overload;
    class function HAVING(AConditions: array of string): TSQL; overload;
    class function HAVING(const ACondition: string): TSQL; overload;
    class function ORDER_BY(AFields: array of string): TSQL; overload;
    class function ORDER_BY(const AField: string): TSQL; overload;
    class function LIMIT(const AValue: Integer): TSQL;
    class function OFFSET(const AValue: Integer): TSQL;
    class function FIRST(const AValue: Integer): TSQL;
    class function SKIP(const AValue: Integer): TSQL;
    
    // New DML methods
    class function INSERT_INTO(const ATable: string): TSQL;
    class function COLUMNS(AColumns: array of string): TSQL; overload;
    class function COLUMNS(const AColumns: string): TSQL; overload;
    class function VALUES(AValues: array of Variant): TSQL; overload;
    class function VALUES(const AValues: string): TSQL; overload;
    
    class function UPDATE(const ATable: string): TSQL;
    class function &SET(const AColumn: string; const AValue: Variant): TSQL; overload;
    class function &SET(const AColumnValuePairs: array of string): TSQL; overload;
    
    class function DELETE_FROM(const ATable: string): TSQL;
    
    // DDL methods
    class function CREATE_TABLE(const ATableName: string): TSQL;
    class function ADD_COLUMN(const AColumnName: string; const ADataType: string; 
                             const AConstraints: string = ''): TSQL;
    class function PRIMARY_KEY(const AColumns: array of string): TSQL;
    class function FOREIGN_KEY(const AColumns: array of string; 
                              const ARefTable: string; 
                              const ARefColumns: array of string): TSQL;
    
    class function ALTER_TABLE(const ATableName: string): TSQL;
    class function ADD_CONSTRAINT(const AName: string; const ADefinition: string): TSQL;
    class function DROP_COLUMN(const AColumnName: string): TSQL;
    
    class function CREATE_INDEX(const AIndexName: string; const ATableName: string;
                               const AColumns: array of string; const AUnique: Boolean = False): TSQL;
    
    // Transaction support
    class function BEGIN_TRANSACTION: TSQL;
    class function COMMIT: TSQL;
    class function ROLLBACK: TSQL;
    class function SAVEPOINT(const AName: string): TSQL;
    class function ROLLBACK_TO(const ASavepointName: string): TSQL;
    
    // CTE support
    class function &WITH(const ACTE: string): TSQL; overload;
    class function &WITH(const ACTEName: string; const ASQL: TSQL): TSQL; overload;
    
    // Parametrized query support
    class function PARAM(const AName: string; const AValue: Variant; ADataType: Integer = 0): TSQL;
    class function GetParameterByName(const AName: string): TParameter;
    function GetParameterCount: Integer;
    function GetParameterList: TParameterList;
    
    // Subquery support
    function AsSubquery: string;
    
    // Advanced paging
    class function PAGINATE(const APage: Integer; const APageSize: Integer): TSQL;
    class function COUNT_RESULTS: TSQL;
    
    // Template support
    class procedure SaveAsTemplate(const AName: string; const ASQL: string);
    class function LoadTemplate(const AName: string): string;
    class function ApplyTemplate(const ATemplate: string; const AParams: array of string): string;

    class function FormatValue(const AValue: Variant; const AQuote: Boolean = True): string;

    function AsString: string;
    function AsFormattedString: string;
    procedure Clear;

    class property Instance: TSQL read GetInstance;

    class procedure SetDatabase(const ADatabaseType: TDatabaseType);
    class procedure FirebirdMode;
    class procedure MySQLMode;
    class procedure PostgreSQLMode;
    class procedure SQLiteMode;
    class procedure SQLServerMode;
    class procedure OracleMode;
  end;

  TCoalesce = class
  private
    class function ExtractAlias(const AFieldName: string; const AAlias: string): string;
  public
    class function Value(const AFieldName: string; const ADefaultValue: string; const AAlias: string = ''): string; overload;
    class function Value(const AFieldName: string; const ADefaultValue: Integer; const AAlias: string = ''): string; overload;
    class function Value(const AFieldName: string; const ADefaultValue: Double; const AAlias: string = ''): string; overload;
    class function Value(const AFieldName: string; const ADefaultValue: Boolean; const AAlias: string = ''): string; overload;
    class function Value(const AFieldName: string; const ADefaultValue: TDateTime; const AAlias: string = ''): string; overload;
    class function Value(const AFieldName, ADefaultValue: string; const AQuoted: Boolean; const AAlias: string = ''): string; overload;
  end;

  TExpr = class
  public
    // Existing methods
    class function Sum(const AValue: string): string;
    class function Max(const AValue: string): string;
    class function Min(const AValue: string): string; // Fix the typo in existing code (Mix -> Min)
    
    // Additional expression methods
    class function Count(const AValue: string = '*'): string;
    class function Avg(const AValue: string): string;
    class function Concat(const AValues: array of string): string;
    class function Cast(const AValue: string; const AType: string): string;
    class function DateAdd(const APart: string; const AValue: Integer; const ADate: string): string;
    class function DateDiff(const APart: string; const AStartDate: string; const AEndDate: string): string;
    class function CurrentDate: string;
    class function CurrentTime: string;
    class function CurrentTimestamp: string;
    class function Substring(const AValue: string; const AStart: Integer; const ALength: Integer = 0): string;
    class function Trim(const AValue: string): string;
    class function Upper(const AValue: string): string;
    class function Lower(const AValue: string): string;
    class function Round(const AValue: string; const APrecision: Integer = 0): string;
    class function Ceiling(const AValue: string): string;
    class function Floor(const AValue: string): string;
    class function NVL(const AValue: string; const ADefaultValue: string): string; // Oracle-style NULL handling
    class function IIF(const ACondition: string; const ATrueValue: string; const AFalseValue: string): string;
  end;

  { TCondition }
  TCondition = class
  private
    FFieldName: string;
    FAlias: string;

    function GetQualifiedFieldName: string;
  public
    constructor Create(const AFieldName: string; const AAlias: string = '');

    // Existing condition methods
    function Equal(const AValue: Variant): string;
    function NotEqual(const AValue: Variant): string;
    function GreaterThan(const AValue: Variant): string;
    function LessThan(const AValue: Variant): string;
    function GreaterOrEqual(const AValue: Variant): string;
    function LessOrEqual(const AValue: Variant): string;
    function IsNull: string;
    function IsNotNull: string;
    function Like(const AValue: string): string;
    function NotLike(const AValue: string): string;
    function Between(const AStartValue, AEndValue: Variant): string;
    function In_(const AValues: array of Variant): string;
    function NotIn(const AValues: array of Variant): string;
    function isTrue: string;

    // Generic comparison with operator
    function Compare(const AValue: Variant; const AOperator: string = '='): string;

    // Special conditions for common use cases
    function PorId(const AValue: Integer = -1; const AOperator: string = '='): string;
    function PorDescricao(const AValue: string = ''; const AOperator: string = 'LIKE'): string;
    function PorStatus(const AValue: Char; const AOperator: string = '='): string;
    function PorCodigo(const AValue: string = ''; const AOperator: string = '='): string;
    function PorPeriodo(const ACampoData: string; const ADataInicial, ADataFinal: TDateTime): string;
    function PorBoolean(const ACampoBoolean: string; const AValue: Boolean; const ASim: string = 'S'; const ANao: string = 'N'): string;

    // Additional condition methods
    function StartsWith(const AValue: string): string;
    function EndsWith(const AValue: string): string;
    function Contains(const AValue: string): string;
    function DateEquals(const AValue: TDateTime): string;
    function DateBefore(const AValue: TDateTime): string;
    function DateAfter(const AValue: TDateTime): string;
    function Exists(const ASubquery: string): string;
    function NotExists(const ASubquery: string): string;
    function IsEmpty: string;
    function IsNotEmpty: string;

    // Static creation methods
    class function Field(const AFieldName: string; const AAlias: string = ''): TCondition;
  end;

  // Migration support
  TMigration = class
  private
    FName: string;
    FVersion: string;
    FCommands: TStringList;
    FCommandCount: Integer;
    function GetCommandCount: integer;
  public
    constructor Create(const AName: string; const AVersion: string);
    destructor Destroy; override;

    procedure AddCommand(const ASQL: string);
    function AsScript: string;
    procedure SaveToFile(const AFileName: string);

    property Name: string read FName;
    property Version: string read FVersion;
    property CommandCount: integer read GetCommandCount;
  end;

implementation
  uses Variants, TypInfo;

{ TParameter }
constructor TParameter.Create(const AName: string; const AValue: Variant; ADataType: Integer = 0);
begin
  inherited Create;
  FName := AName;
  FValue := AValue;
  FDataType := ADataType;
end;

{ TParameterList }
constructor TParameterList.Create;
begin
  inherited Create;
  FParameters := TList.Create;
end;

destructor TParameterList.Destroy;
var
  I: Integer;
begin
  for I := 0 to FParameters.Count - 1 do
    TParameter(FParameters[I]).Free;
  FParameters.Free;
  inherited;
end;

function TParameterList.Add(const AName: string; const AValue: Variant; ADataType: Integer): TParameter;
begin
  Result := TParameter.Create(AName, AValue, ADataType);
  FParameters.Add(Result);
end;

procedure TParameterList.Clear;
var
  I: Integer;
begin
  for I := 0 to FParameters.Count - 1 do
    TParameter(FParameters[I]).Free;
  FParameters.Clear;
end;

function TParameterList.GetCount: Integer;
begin
  Result := FParameters.Count;
end;

function TParameterList.GetParameter(Index: Integer): TParameter;
begin
  Result := TParameter(FParameters[Index]);
end;

{ TSQL }
constructor TSQL.Create;
begin
  inherited;

  // Existing fields initialization
  FSelectClause  := TStringList.Create;
  FFromClause    := TStringList.Create;
  FJoinClause    := TStringList.Create;
  FWhereClause   := TStringList.Create;
  FGroupByClause := TStringList.Create;
  FHavingClause  := TStringList.Create;
  FOrderByClause := TStringList.Create;
  FLimitValue    := -1;
  FOffsetValue   := -1;
  FIsDistinct    := False;
  FDatabaseType  := dtMySQL; // Default to MySQL
  
  // Initialize new fields
  FInsertColumns := TStringList.Create;
  FInsertValues := TStringList.Create;
  FUpdateValues := TStringList.Create;
  FTableColumns := TStringList.Create;
  FTableConstraints := TStringList.Create;
  FAlterActions := TStringList.Create;
  FCTEClause := TStringList.Create;
  FParameters := TParameterList.Create;
  FTransactionCommands := TStringList.Create;
  
  // Default SQL type
  FSQLType := stSelect;
end;

destructor TSQL.Destroy;
begin
  // Free existing fields
  FSelectClause.Free;
  FFromClause.Free;
  FJoinClause.Free;
  FWhereClause.Free;
  FGroupByClause.Free;
  FHavingClause.Free;
  FOrderByClause.Free;
  
  // Free new fields
  FInsertColumns.Free;
  FInsertValues.Free;
  FUpdateValues.Free;
  FTableColumns.Free;
  FTableConstraints.Free;
  FAlterActions.Free;
  FCTEClause.Free;
  FParameters.Free;
  FTransactionCommands.Free;
  
  inherited;
end;

class function TSQL.GetInstance: TSQL;
begin
  if FInstance = nil then
    FInstance := TSQL.Create;

  Result := FInstance;
end;

class function TSQL.SELECT(AFields: array of string): TSQL;
var
  i: Integer;
begin
  Instance.Clear;
  for i := Low(AFields) to High(AFields) do
    Instance.FSelectClause.Add(AFields[i]);
  Result := Instance;
end;

class function TSQL.SELECT(const AFields: string): TSQL;
begin
  Instance.Clear;
  Instance.FSelectClause.Add(AFields);
  Result := Instance;
end;

class function TSQL.DISTINCT: TSQL;
begin
  Instance.FIsDistinct := True;
  Result := Instance;
end;

class function TSQL.FROM(ATables: array of string): TSQL;
var
  i: Integer;
begin
  for i := Low(ATables) to High(ATables) do
    Instance.FFromClause.Add(ATables[i]);
  Result := Instance;
end;

class function TSQL.FROM(const ATable: string): TSQL;
begin
  Instance.FFromClause.Add(ATable);
  Result := Instance;
end;

class function TSQL.JOIN(const ATable: string; const AExpression: string): TSQL;
begin
  Instance.FJoinClause.Add('JOIN ' + ATable + ' ON ' + AExpression);
  Result := Instance;
end;

class function TSQL.LEFT_JOIN(const ATable: string; const AExpression: string): TSQL;
begin
  Instance.FJoinClause.Add('LEFT JOIN ' + ATable + ' ON ' + AExpression);
  Result := Instance;
end;

class function TSQL.RIGHT_JOIN(const ATable: string; const AExpression: string): TSQL;
begin
  Instance.FJoinClause.Add('RIGHT JOIN ' + ATable + ' ON ' + AExpression);
  Result := Instance;
end;

class function TSQL.INNER_JOIN(const ATable: string; const AExpression: string): TSQL;
begin
  Instance.FJoinClause.Add('INNER JOIN ' + ATable + ' ON ' + AExpression);
  Result := Instance;
end;

class function TSQL.INNER_JOIN(const ATable: string; const AKeyName: string; const AKeyValue: string): TSQL;
begin
  Instance.FJoinClause.Add('INNER JOIN ' + ATable + ' ON ' + AKeyName + ' = ' + AKeyValue);
  Result := Instance;
end;

class function TSQL.WHERE(AConditions: array of string): TSQL;
var
  i: Integer;
begin
  Instance.FWhereClause.Clear;
  for i := Low(AConditions) to High(AConditions) do
  begin
    if i = Low(AConditions) then
      Instance.FWhereClause.Add(AConditions[i])
    else
      Instance.FWhereClause.Add('AND ' + AConditions[i]);
  end;
  Result := Instance;
end;

class function TSQL.WHERE(const ACondition: string): TSQL;
begin
  Instance.FWhereClause.Clear;
  Instance.FWhereClause.Add(ACondition);
  Result := Instance;
end;

class function TSQL.AND_WHERE(const ACondition: string): TSQL;
begin
  if Instance.FWhereClause.Count > 0 then
    Instance.FWhereClause.Add('AND ' + ACondition)
  else
    Instance.FWhereClause.Add(ACondition);
  Result := Instance;
end;

class function TSQL.AND_WHERE(const AField: string; const AValue: Variant): TSQL;
begin
  if Instance.FWhereClause.Count > 0 then
    Instance.FWhereClause.Add('AND ' + AField + ' = ' + TSQL.FormatValue(AValue))
  else
    Instance.FWhereClause.Add(AField + ' = ' + TSQL.FormatValue(AValue));
  Result := Instance;
end;

class function TSQL.OR_WHERE(const ACondition: string): TSQL;
begin
  if Instance.FWhereClause.Count > 0 then
    Instance.FWhereClause.Add('OR ' + ACondition)
  else
    Instance.FWhereClause.Add(ACondition);
  Result := Instance;
end;

class function TSQL.GROUP_BY(AFields: array of string): TSQL;
var
  i: Integer;
begin
  for i := Low(AFields) to High(AFields) do
    Instance.FGroupByClause.Add(AFields[i]);
  Result := Instance;
end;

class function TSQL.GROUP_BY(const AField: string): TSQL;
begin
  Instance.FGroupByClause.Add(AField);
  Result := Instance;
end;

class function TSQL.HAVING(AConditions: array of string): TSQL;
var
  i: Integer;
begin
  Instance.FHavingClause.Clear;
  for i := Low(AConditions) to High(AConditions) do
  begin
    if i = Low(AConditions) then
      Instance.FHavingClause.Add(AConditions[i])
    else
      Instance.FHavingClause.Add('AND ' + AConditions[i]);
  end;
  Result := Instance;
end;

class function TSQL.HAVING(const ACondition: string): TSQL;
begin
  Instance.FHavingClause.Clear;
  Instance.FHavingClause.Add(ACondition);
  Result := Instance;
end;

class function TSQL.ORDER_BY(AFields: array of string): TSQL;
var
  i: Integer;
begin
  for i := Low(AFields) to High(AFields) do
    Instance.FOrderByClause.Add(AFields[i]);
  Result := Instance;
end;

class function TSQL.ORDER_BY(const AField: string): TSQL;
begin
  Instance.FOrderByClause.Add(AField);
  Result := Instance;
end;

class function TSQL.OR_WHERE(const AField: string; const AValue: Variant): TSQL;
begin
  if Instance.FWhereClause.Count > 0 then
    Instance.FWhereClause.Add('OR ' + AField + ' = ' + TSQL.FormatValue(AValue))
  else
    Instance.FWhereClause.Add(AField + ' = ' + TSQL.FormatValue(AValue));
  Result := Instance;
end;

class function TSQL.LIMIT(const AValue: Integer): TSQL;
begin
  Instance.FLimitValue := AValue;
  Result := Instance;
end;

class function TSQL.OFFSET(const AValue: Integer): TSQL;
begin
  Instance.FOffsetValue := AValue;
  Result := Instance;
end;

class function TSQL.FIRST(const AValue: Integer): TSQL;
begin
  Instance.FLimitValue := AValue;
  Result := Instance;
end;

class function TSQL.SKIP(const AValue: Integer): TSQL;
begin
  Instance.FOffsetValue := AValue;
  Result := Instance;
end;

class function TSQL.WHERE(const AField: string; const AValue: Variant): TSQL;
begin
  Instance.FWhereClause.Clear;
  Instance.FWhereClause.Add(AField + ' = ' + TSQL.FormatValue(AValue));
  Result := Instance;
end;

// New DML Methods Implementation
class function TSQL.INSERT_INTO(const ATable: string): TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stInsert;
  Instance.FInsertTable := ATable;
  Result := Instance;
end;

class function TSQL.COLUMNS(AColumns: array of string): TSQL;
var
  i: Integer;
begin
  for i := Low(AColumns) to High(AColumns) do
    Instance.FInsertColumns.Add(AColumns[i]);
  Result := Instance;
end;

class function TSQL.COLUMNS(const AColumns: string): TSQL;
begin
  Instance.FInsertColumns.Add(AColumns);
  Result := Instance;
end;

class function TSQL.VALUES(AValues: array of Variant): TSQL;
var
  i: Integer;
begin
  for i := Low(AValues) to High(AValues) do
    Instance.FInsertValues.Add(FormatValue(AValues[i]));
  Result := Instance;
end;

class function TSQL.VALUES(const AValues: string): TSQL;
begin
  Instance.FInsertValues.Add(AValues);
  Result := Instance;
end;

class function TSQL.UPDATE(const ATable: string): TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stUpdate;
  Instance.FUpdateTable := ATable;
  Result := Instance;
end;

class function TSQL.&SET(const AColumn: string; const AValue: Variant): TSQL;
begin
  Instance.FUpdateValues.Add(AColumn + ' = ' + FormatValue(AValue));
  Result := Instance;
end;

class function TSQL.&SET(const AColumnValuePairs: array of string): TSQL;
var
  i: Integer;
begin
  for i := Low(AColumnValuePairs) to High(AColumnValuePairs) do
    Instance.FUpdateValues.Add(AColumnValuePairs[i]);
  Result := Instance;
end;

class function TSQL.DELETE_FROM(const ATable: string): TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stDelete;
  Instance.FDeleteTable := ATable;
  Result := Instance;
end;

// DDL Methods Implementation
class function TSQL.CREATE_TABLE(const ATableName: string): TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stCreate;
  Instance.FCreateTable := ATableName;
  Result := Instance;
end;

class function TSQL.ADD_COLUMN(const AColumnName, ADataType, AConstraints: string): TSQL;
var
  ColumnDef: string;
begin
  ColumnDef := AColumnName + ' ' + ADataType;
  if AConstraints <> '' then
    ColumnDef := ColumnDef + ' ' + AConstraints;
  
  Instance.FTableColumns.Add(ColumnDef);
  Result := Instance;
end;

class function TSQL.PRIMARY_KEY(const AColumns: array of string): TSQL;
var
  PKDef: string;
  i: Integer;
begin
  PKDef := 'PRIMARY KEY (';
  for i := Low(AColumns) to High(AColumns) do
  begin
    if i > Low(AColumns) then
      PKDef := PKDef + ', ';
    PKDef := PKDef + AColumns[i];
  end;
  PKDef := PKDef + ')';
  
  Instance.FTableConstraints.Add(PKDef);
  Result := Instance;
end;

class function TSQL.FOREIGN_KEY(const AColumns: array of string; const ARefTable: string; const ARefColumns: array of string): TSQL;
var
  FKDef: string;
  i: Integer;
begin
  FKDef := 'FOREIGN KEY (';
  
  for i := Low(AColumns) to High(AColumns) do
  begin
    if i > Low(AColumns) then
      FKDef := FKDef + ', ';
    FKDef := FKDef + AColumns[i];
  end;
  
  FKDef := FKDef + ') REFERENCES ' + ARefTable + ' (';
  
  for i := Low(ARefColumns) to High(ARefColumns) do
  begin
    if i > Low(ARefColumns) then
      FKDef := FKDef + ', ';
    FKDef := FKDef + ARefColumns[i];
  end;
  
  FKDef := FKDef + ')';
  
  Instance.FTableConstraints.Add(FKDef);
  Result := Instance;
end;

class function TSQL.ALTER_TABLE(const ATableName: string): TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stAlter;
  Instance.FAlterTable := ATableName;
  Result := Instance;
end;

class function TSQL.ADD_CONSTRAINT(const AName, ADefinition: string): TSQL;
begin
  Instance.FAlterActions.Add('ADD CONSTRAINT ' + AName + ' ' + ADefinition);
  Result := Instance;
end;

class function TSQL.DROP_COLUMN(const AColumnName: string): TSQL;
begin
  Instance.FAlterActions.Add('DROP COLUMN ' + AColumnName);
  Result := Instance;
end;

class function TSQL.CREATE_INDEX(const AIndexName, ATableName: string; const AColumns: array of string; const AUnique: Boolean): TSQL;
var
  IndexDef: string;
  i: Integer;
begin
  Instance.Clear;
  Instance.FSQLType := stOther;
  
  if AUnique then
    IndexDef := 'CREATE UNIQUE INDEX '
  else
    IndexDef := 'CREATE INDEX ';
    
  IndexDef := IndexDef + AIndexName + ' ON ' + ATableName + ' (';
  
  for i := Low(AColumns) to High(AColumns) do
  begin
    if i > Low(AColumns) then
      IndexDef := IndexDef + ', ';
    IndexDef := IndexDef + AColumns[i];
  end;
  
  IndexDef := IndexDef + ')';
  
  // Add to transaction commands for now
  Instance.FTransactionCommands.Add(IndexDef);
  Result := Instance;
end;

// Transaction Support
class function TSQL.BEGIN_TRANSACTION: TSQL;
begin
  Instance.Clear;
  Instance.FSQLType := stTransaction;
  
  case Instance.FDatabaseType of
    dtFirebird, dtOracle, dtPostgreSQL, dtSQLServer:
      Instance.FTransactionCommands.Add('BEGIN TRANSACTION');
    dtMySQL:
      Instance.FTransactionCommands.Add('START TRANSACTION');
    dtSQLite:
      Instance.FTransactionCommands.Add('BEGIN TRANSACTION');
  end;
  
  Result := Instance;
end;

class function TSQL.COMMIT: TSQL;
begin
  if Instance.FSQLType <> stTransaction then
    Instance.Clear;
    
  Instance.FSQLType := stTransaction;
  Instance.FTransactionCommands.Add('COMMIT');
  Result := Instance;
end;

class function TSQL.ROLLBACK: TSQL;
begin
  if Instance.FSQLType <> stTransaction then
    Instance.Clear;
    
  Instance.FSQLType := stTransaction;
  Instance.FTransactionCommands.Add('ROLLBACK');
  Result := Instance;
end;

class function TSQL.SAVEPOINT(const AName: string): TSQL;
begin
  if Instance.FSQLType <> stTransaction then
    Instance.Clear;
    
  Instance.FSQLType := stTransaction;
  Instance.FTransactionCommands.Add('SAVEPOINT ' + AName);
  Result := Instance;
end;

class function TSQL.ROLLBACK_TO(const ASavepointName: string): TSQL;
begin
  if Instance.FSQLType <> stTransaction then
    Instance.Clear;
    
  Instance.FSQLType := stTransaction;
  
  case Instance.FDatabaseType of
    dtFirebird, dtOracle, dtPostgreSQL:
      Instance.FTransactionCommands.Add('ROLLBACK TO SAVEPOINT ' + ASavepointName);
    dtMySQL, dtSQLServer, dtSQLite:
      Instance.FTransactionCommands.Add('ROLLBACK TO ' + ASavepointName);
  end;
  
  Result := Instance;
end;

// CTE Support
class function TSQL.&WITH(const ACTE: string): TSQL;
begin
  Instance.Clear;
  Instance.FCTEClause.Add(ACTE);
  Result := Instance;
end;

class function TSQL.&WITH(const ACTEName: string; const ASQL: TSQL): TSQL;
begin
  Instance.Clear;
  Instance.FCTEClause.Add(ACTEName + ' AS (' + ASQL.AsString + ')');
  Result := Instance;
end;

// Parametrized query support
class function TSQL.PARAM(const AName: string; const AValue: Variant; ADataType: Integer): TSQL;
begin
  Instance.FParameters.Add(AName, AValue, ADataType);
  Result := Instance;
end;

class function TSQL.GetParameterByName(const AName: string): TParameter;
var
  i: Integer;
begin
  Result := nil;
  
  for i := 0 to Instance.FParameters.Count - 1 do
  begin
    if SameText(Instance.FParameters[i].Name, AName) then
    begin
      Result := Instance.FParameters[i];
      Break;
    end;
  end;
end;

function TSQL.GetParameterCount: Integer;
begin
  Result := FParameters.Count;
end;

function TSQL.GetParameterList: TParameterList;
begin
  Result := FParameters;
end;

// Subquery support
function TSQL.AsSubquery: string;
begin
  Result := '(' + AsString + ')';
end;

// Advanced paging
class function TSQL.PAGINATE(const APage, APageSize: Integer): TSQL;
begin
  if APage <= 0 then
    raise Exception.Create('Page number must be greater than zero');
    
    if APageSize <= 0 then
      raise Exception.Create('Page size must be greater than zero');
      
    Instance.FLimitValue := APageSize;
    Instance.FOffsetValue := (APage - 1) * APageSize;
    Result := Instance;
end;

class function TSQL.COUNT_RESULTS: TSQL;
var
  SavedSelect: TStringList;
  SavedGroupBy: TStringList;
  SavedHaving: TStringList;
  SavedOrderBy: TStringList;
begin
  // Save current query parts that aren't needed for COUNT
  SavedSelect := TStringList.Create;
  SavedGroupBy := TStringList.Create;
  SavedHaving := TStringList.Create;
  SavedOrderBy := TStringList.Create;

  try
    SavedSelect.Assign(Instance.FSelectClause);
    SavedGroupBy.Assign(Instance.FGroupByClause);
    SavedHaving.Assign(Instance.FHavingClause);
    SavedOrderBy.Assign(Instance.FOrderByClause);
    
    // Modify the query to get count
    Instance.FSelectClause.Clear;
    Instance.FSelectClause.Add('COUNT(*) AS total_count');
    Instance.FGroupByClause.Clear;
    Instance.FHavingClause.Clear;
    Instance.FOrderByClause.Clear;
    Instance.FLimitValue := -1;
    Instance.FOffsetValue := -1;
    
    Result := Instance;
  finally
    SavedSelect.Free;
    SavedGroupBy.Free;
    SavedHaving.Free;
    SavedOrderBy.Free;
  end;
end;

// Template support
var
  TemplateCache: TStringList = nil;

class procedure TSQL.SaveAsTemplate(const AName: string; const ASQL: string);
begin
  if TemplateCache = nil then
    TemplateCache := TStringList.Create;
  
  TemplateCache.Values[AName] := ASQL;
end;

class function TSQL.LoadTemplate(const AName: string): string;
begin
  if (TemplateCache = nil) or (TemplateCache.IndexOfName(AName) < 0) then
    Result := ''
  else
    Result := TemplateCache.Values[AName];
end;

class function TSQL.ApplyTemplate(const ATemplate: string; const AParams: array of string): string;
var
  SQL: string;
  i: Integer;
begin
  SQL := ATemplate;
  
  for i := Low(AParams) to High(AParams) do
  begin
    if i mod 2 = 0 then // Even index = parameter name
    begin
      if (i + 1 <= High(AParams)) then // Check if we have a value
        SQL := StringReplace(SQL, '{' + AParams[i] + '}', AParams[i+1], [rfReplaceAll]);
    end;
  end;
  
  Result := SQL;
end;

function TSQL.GetLimitOffsetClause: string;
begin
  Result := '';
  
  case FDatabaseType of
    dtMySQL, dtSQLite, dtPostgreSQL:
    begin
      if FLimitValue >= 0 then
        Result := 'LIMIT ' + IntToStr(FLimitValue);
      
      if FOffsetValue >= 0 then
        Result := Result + ' OFFSET ' + IntToStr(FOffsetValue);
    end;
    
    dtFirebird:
    begin
      // Handled in the SELECT clause (FIRST X SKIP Y)
    end;
    
    dtSQLServer:
    begin
      // Use ORDER BY ... OFFSET ... ROWS FETCH NEXT ... ROWS ONLY syntax
      // This should be applied after ORDER BY in SQL Server
      if (FLimitValue >= 0) and (FOrderByClause.Count > 0) then
      begin
        if FOffsetValue < 0 then
          Result := 'OFFSET 0 ROWS FETCH NEXT ' + IntToStr(FLimitValue) + ' ROWS ONLY'
        else
          Result := 'OFFSET ' + IntToStr(FOffsetValue) + ' ROWS FETCH NEXT ' + IntToStr(FLimitValue) + ' ROWS ONLY';
      end;
    end;
    
    dtOracle:
    begin
      // For Oracle, we'd need to use ROW_NUMBER() OVER (ORDER BY ...) but this is complex
      // and beyond the scope of this implementation
    end;
  end;
end;

function TSQL.BuildInsertSQL: string;
var
  SQL: TStringBuilder;
begin
  SQL := TStringBuilder.Create;
  try
    SQL.Append('INSERT INTO ');
    SQL.Append(FInsertTable);
    
    if FInsertColumns.Count > 0 then
    begin
      SQL.Append(' (');
      SQL.Append(String.Join(', ', FInsertColumns.ToStringArray));
      SQL.Append(')');
    end;
    
    if FInsertValues.Count > 0 then
    begin
      SQL.Append(' VALUES (');
      SQL.Append(String.Join(', ', FInsertValues.ToStringArray));
      SQL.Append(')');
    end;
    
    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

function TSQL.BuildUpdateSQL: string;
var
  SQL: TStringBuilder;
begin
  SQL := TStringBuilder.Create;
  try
    SQL.Append('UPDATE ');
    SQL.Append(FUpdateTable);
    
    if FUpdateValues.Count > 0 then
    begin
      SQL.Append(' SET ');
      SQL.Append(String.Join(', ', FUpdateValues.ToStringArray));
    end;
    
    if FWhereClause.Count > 0 then
    begin
      SQL.Append(' WHERE ');
      SQL.Append(String.Join(' ', FWhereClause.ToStringArray));
    end;
    
    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

function TSQL.BuildDeleteSQL: string;
var
  SQL: TStringBuilder;
begin
  SQL := TStringBuilder.Create;
  try
    SQL.Append('DELETE FROM ');
    SQL.Append(FDeleteTable);
    
    if FWhereClause.Count > 0 then
    begin
      SQL.Append(' WHERE ');
      SQL.Append(String.Join(' ', FWhereClause.ToStringArray));
    end;
    
    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

function TSQL.BuildCreateTableSQL: string;
var
  SQL: TStringBuilder;
  AllItems: TStringList;
begin
  SQL := TStringBuilder.Create;
  AllItems := TStringList.Create;
  try
    SQL.Append('CREATE TABLE ');
    SQL.Append(FCreateTable);
    SQL.Append(' (');
    
    // Add all columns and constraints to a single list
    AllItems.AddStrings(FTableColumns);
    AllItems.AddStrings(FTableConstraints);
    
    SQL.Append(String.Join(', ', AllItems.ToStringArray));
    SQL.Append(')');
    
    Result := SQL.ToString;
  finally
    AllItems.Free;
    SQL.Free;
  end;
end;

function TSQL.BuildAlterTableSQL: string;
var
  SQL: TStringBuilder;
begin
  SQL := TStringBuilder.Create;
  try
    SQL.Append('ALTER TABLE ');
    SQL.Append(FAlterTable);
    SQL.Append(' ');
    
    SQL.Append(String.Join(', ', FAlterActions.ToStringArray));
    
    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

function TSQL.BuildWithCTE: string;
var
  SQL: TStringBuilder;
begin
  SQL := TStringBuilder.Create;
  try
    if FCTEClause.Count > 0 then
    begin
      SQL.Append('WITH ');
      SQL.Append(String.Join(', ', FCTEClause.ToStringArray));
    end;
    
    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

function TSQL.AsString: string;
var
  SQL: TStringBuilder;
  limitOffsetClause: string;
begin
  SQL := TStringBuilder.Create;
  try
    // Add CTE if exists
    if FCTEClause.Count > 0 then
    begin
      SQL.Append(BuildWithCTE);
      SQL.Append(' ');
    end;

    // Build SQL based on SQL type
    case FSQLType of
      stSelect:
      begin
        // SELECT clause
        SQL.Append('SELECT ');
        
        if FIsDistinct then
          SQL.Append('DISTINCT ');
          
        // For Firebird with FIRST/SKIP (instead of LIMIT/OFFSET)
        if (FDatabaseType = dtFirebird) then
        begin
          if(FLimitValue >= 0) then
            SQL.Append(Format('FIRST %d ', [FLimitValue]));
          
          if FOffsetValue >= 0 then
            SQL.Append(Format('SKIP %d ', [FOffsetValue]));
        end;

        if FSelectClause.Count = 0 then
          SQL.Append('*')
        else
          SQL.Append(String.Join(', ', FSelectClause.ToStringArray));
        
        // FROM clause
        if FFromClause.Count > 0 then
        begin
          SQL.Append(' FROM ');
          SQL.Append(String.Join(', ', FFromClause.ToStringArray));
        end;
        
        // JOIN clause
        if FJoinClause.Count > 0 then
        begin
          SQL.Append(' ');
          SQL.Append(String.Join(' ', FJoinClause.ToStringArray));
        end;
        
        // WHERE clause
        if FWhereClause.Count > 0 then
        begin
          SQL.Append(' WHERE ');
          SQL.Append(String.Join(' ', FWhereClause.ToStringArray));
        end;
        
        // GROUP BY clause
        if FGroupByClause.Count > 0 then
        begin
          SQL.Append(' GROUP BY ');
          SQL.Append(String.Join(', ', FGroupByClause.ToStringArray));
        end;
        
        // HAVING clause
        if FHavingClause.Count > 0 then
        begin
          SQL.Append(' HAVING ');
          SQL.Append(String.Join(' ', FHavingClause.ToStringArray));
        end;
        
        // ORDER BY clause
        if FOrderByClause.Count > 0 then
        begin
          SQL.Append(' ORDER BY ');
          SQL.Append(String.Join(', ', FOrderByClause.ToStringArray));
        end;
        
        // LIMIT/OFFSET for supported databases
        if (FDatabaseType <> dtFirebird) then
        begin
          limitOffsetClause := GetLimitOffsetClause;
          if limitOffsetClause <> '' then
            SQL.Append(' ' + limitOffsetClause);
        end;
      end;
      
      stInsert:
        SQL.Append(BuildInsertSQL);
        
      stUpdate:
        SQL.Append(BuildUpdateSQL);
        
      stDelete:
        SQL.Append(BuildDeleteSQL);
        
      stCreate:
        SQL.Append(BuildCreateTableSQL);
        
      stAlter:
        SQL.Append(BuildAlterTableSQL);
        
      stTransaction:
        SQL.Append(String.Join('; ', FTransactionCommands.ToStringArray));
    end;

    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

// We need to override or extend the existing AsFormattedString to handle all the new SQL types
function TSQL.AsFormattedString: string;
var
  SQL: TStringBuilder;
  i: Integer;
  Indent, limitOffsetClause: string;
begin
  SQL := TStringBuilder.Create;
  Indent := '  '; // Two spaces for indentation
  
  try
    // Build formatted SQL based on SQL type
    case FSQLType of
      stSelect:
      begin
        // Add CTE if exists
        if FCTEClause.Count > 0 then
        begin
          SQL.Append('WITH');
          SQL.AppendLine;
          
          for i := 0 to FCTEClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FCTEClause[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FCTEClause[i]);
          end;
          SQL.AppendLine;
        end;
      
        // SELECT clause
        SQL.Append('SELECT');
        
        if FIsDistinct then
          SQL.Append(' DISTINCT');
          
        // For Firebird with FIRST/SKIP (instead of LIMIT/OFFSET)
        if (FDatabaseType = dtFirebird) then
        begin
          if(FLimitValue >= 0) then
            SQL.Append(Format(' FIRST %d', [FLimitValue]));
          
          if FOffsetValue >= 0 then
            SQL.Append(Format(' SKIP %d', [FOffsetValue]));
        end;
        
        SQL.AppendLine;

        // Format SELECT fields with proper indentation
        if FSelectClause.Count = 0 then
          SQL.Append(Indent + '*')
        else
        begin
          for i := 0 to FSelectClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FSelectClause[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FSelectClause[i]);
          end;
        end;
        
        // FROM clause
        if FFromClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('FROM');
          SQL.AppendLine;
          
          for i := 0 to FFromClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FFromClause[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FFromClause[i]);
          end;
        end;
        
        // JOIN clause
        if FJoinClause.Count > 0 then
        begin
          SQL.AppendLine;
          
          for i := 0 to FJoinClause.Count - 1 do
            SQL.AppendLine(FJoinClause[i]);
        end;
        
        // WHERE clause
        if FWhereClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('WHERE');
          SQL.AppendLine;
          
          for i := 0 to FWhereClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FWhereClause[i])
            else if StartsText('AND ', FWhereClause[i]) or StartsText('OR ', FWhereClause[i]) then
              SQL.AppendLine.Append(Indent + FWhereClause[i])
            else
              SQL.Append(' ' + FWhereClause[i]);
          end;
        end;
        
        // GROUP BY clause
        if FGroupByClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('GROUP BY');
          SQL.AppendLine;
          
          for i := 0 to FGroupByClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FGroupByClause[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FGroupByClause[i]);
          end;
        end;
        
        // HAVING clause
        if FHavingClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('HAVING');
          SQL.AppendLine;
          
          for i := 0 to FHavingClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FHavingClause[i])
            else if StartsText('AND ', FHavingClause[i]) or StartsText('OR ', FHavingClause[i]) then
              SQL.AppendLine.Append(Indent + FHavingClause[i])
            else
              SQL.Append(' ' + FHavingClause[i]);
          end;
        end;
        
        // ORDER BY clause
        if FOrderByClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('ORDER BY');
          SQL.AppendLine;
          
          for i := 0 to FOrderByClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FOrderByClause[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FOrderByClause[i]);
          end;
        end;
        
        // LIMIT/OFFSET for supported databases
        if (FDatabaseType <> dtFirebird) then
        begin
          limitOffsetClause := GetLimitOffsetClause;
          if limitOffsetClause <> '' then
          begin
            SQL.AppendLine;
            SQL.Append(limitOffsetClause);
          end;
        end;
      end;
      
      stInsert:
      begin
        SQL.Append('INSERT INTO ');
        SQL.Append(FInsertTable);
        SQL.AppendLine;
        
        if FInsertColumns.Count > 0 then
        begin
          SQL.Append(Indent + '(');
          for i := 0 to FInsertColumns.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(FInsertColumns[i])
            else
              SQL.Append(', ' + FInsertColumns[i]);
          end;
          SQL.Append(')');
          SQL.AppendLine;
        end;
        
        if FInsertValues.Count > 0 then
        begin
          SQL.Append('VALUES');
          SQL.AppendLine;
          SQL.Append(Indent + '(');
          for i := 0 to FInsertValues.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(FInsertValues[i])
            else
              SQL.Append(', ' + FInsertValues[i]);
          end;
          SQL.Append(')');
        end;
      end;
      
      stUpdate:
      begin
        SQL.Append('UPDATE ');
        SQL.Append(FUpdateTable);
        SQL.AppendLine;
        
        if FUpdateValues.Count > 0 then
        begin
          SQL.Append('SET');
          SQL.AppendLine;
          
          for i := 0 to FUpdateValues.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FUpdateValues[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FUpdateValues[i]);
          end;
        end;
        
        if FWhereClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('WHERE');
          SQL.AppendLine;
          
          for i := 0 to FWhereClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FWhereClause[i])
            else if StartsText('AND ', FWhereClause[i]) or StartsText('OR ', FWhereClause[i]) then
              SQL.AppendLine.Append(Indent + FWhereClause[i])
            else
              SQL.Append(' ' + FWhereClause[i]);
          end;
        end;
      end;
      
      stDelete:
      begin
        SQL.Append('DELETE FROM ');
        SQL.Append(FDeleteTable);
        
        if FWhereClause.Count > 0 then
        begin
          SQL.AppendLine;
          SQL.Append('WHERE');
          SQL.AppendLine;
          
          for i := 0 to FWhereClause.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FWhereClause[i])
            else if StartsText('AND ', FWhereClause[i]) or StartsText('OR ', FWhereClause[i]) then
              SQL.AppendLine.Append(Indent + FWhereClause[i])
            else
              SQL.Append(' ' + FWhereClause[i]);
          end;
        end;
      end;
      
      stCreate:
      begin
        SQL.Append('CREATE TABLE ');
        SQL.Append(FCreateTable);
        SQL.Append(' (');
        SQL.AppendLine;
        
        // Add columns
        for i := 0 to FTableColumns.Count - 1 do
        begin
          if i = 0 then
            SQL.Append(Indent + FTableColumns[i])
          else
            SQL.Append(',' + sLineBreak + Indent + FTableColumns[i]);
        end;
        
        // Add constraints
        if FTableConstraints.Count > 0 then
        begin
          if FTableColumns.Count > 0 then
            SQL.Append(',');
          SQL.AppendLine;
          
          for i := 0 to FTableConstraints.Count - 1 do
          begin
            if i = 0 then
              SQL.Append(Indent + FTableConstraints[i])
            else
              SQL.Append(',' + sLineBreak + Indent + FTableConstraints[i]);
          end;
        end;
        
        SQL.AppendLine;
        SQL.Append(')');
      end;
      
      stAlter:
      begin
        SQL.Append('ALTER TABLE ');
        SQL.Append(FAlterTable);
        SQL.AppendLine;
        
        for i := 0 to FAlterActions.Count - 1 do
        begin
          if i = 0 then
            SQL.Append(Indent + FAlterActions[i])
          else
            SQL.Append(',' + sLineBreak + Indent + FAlterActions[i]);
        end;
      end;
      
      stTransaction:
      begin
        for i := 0 to FTransactionCommands.Count - 1 do
        begin
          if i > 0 then
            SQL.AppendLine;
          SQL.Append(FTransactionCommands[i]);
        end;
      end;
    end;

    Result := SQL.ToString;
  finally
    SQL.Free;
  end;
end;

procedure TSQL.Clear;
begin
  // Clear existing fields
  FSelectClause.Clear;
  FFromClause.Clear;
  FJoinClause.Clear;
  FWhereClause.Clear;
  FGroupByClause.Clear;
  FHavingClause.Clear;
  FOrderByClause.Clear;
  FLimitValue  := -1;
  FOffsetValue := -1;
  FIsDistinct  := False;
  
  // Clear new fields
  FInsertTable := '';
  FInsertColumns.Clear;
  FInsertValues.Clear;
  FUpdateTable := '';
  FUpdateValues.Clear;
  FDeleteTable := '';
  FCreateTable := '';
  FTableColumns.Clear;
  FTableConstraints.Clear;
  FAlterTable := '';
  FAlterActions.Clear;
  FCTEClause.Clear;
  FParameters.Clear;
  FTransactionCommands.Clear;
  
  // Default SQL type
  FSQLType := stSelect;
  FBeginGroup := False;
  FEndGroup := False;
end;

class procedure TSQL.SetDatabase(const ADatabaseType: TDatabaseType);
begin
  Instance.DatabaseType := ADatabaseType;
end;

class function TSQL.FormatValue(const AValue: Variant; const AQuote: Boolean = True): string;
begin
  if VarIsNull(AValue) or VarIsClear(AValue) then
    Result := 'NULL'
  else if VarIsStr(AValue) then
  begin
    if AQuote then
      Result := QuotedStr(AValue)
    else
      Result := AValue;
  end
  else if VarIsType(AValue, varBoolean) then
  begin
    if Boolean(AValue) then
      Result := '1'
    else
      Result := '0';
  end
  else if VarIsOrdinal(AValue) or VarIsFloat(AValue) then
    Result := VarToStr(AValue)
  else if VarIsType(AValue, varDate) then
    Result := QuotedStr(FormatDateTime('yyyy-mm-dd', TDateTime(AValue)))
  else
    Result := QuotedStr(VarToStr(AValue));
end;

class procedure TSQL.FirebirdMode;
begin
  TSQL.SetDatabase(dtFirebird);
end;

class procedure TSQL.MySQLMode;
begin
  TSQL.SetDatabase(dtMySQL);
end;

class procedure TSQL.PostgreSQLMode;
begin
  TSQL.SetDatabase(dtPostgreSQL);
end;

class procedure TSQL.SQLiteMode;
begin
  TSQL.SetDatabase(dtSQLite);
end;

class procedure TSQL.SQLServerMode;
begin
  TSQL.SetDatabase(dtSQLServer);
end;

class procedure TSQL.OracleMode;
begin
  TSQL.SetDatabase(dtOracle);
end;

{ TCoalesce }

class function TCoalesce.ExtractAlias(const AFieldName: string; const AAlias: string): string;
var
  DotPos: Integer;
begin
  Result := AAlias;

  // If no alias provided, try to extract one from the field name
  if Result = '' then
  begin
    DotPos := LastDelimiter('.', AFieldName);
    if DotPos > 0 then
      Result := Copy(AFieldName, DotPos + 1, Length(AFieldName));
  end;
end;

class function TCoalesce.Value(const AFieldName: string; const ADefaultValue: string; const AAlias: string = ''): string;
begin
  Result := Value(AFieldName, ADefaultValue, True, AAlias);
end;

class function TCoalesce.Value(const AFieldName: string; const ADefaultValue: Integer; const AAlias: string = ''): string;
var
  Base: string;
  EffectiveAlias: string;
begin
  Base := Format('COALESCE(%s, %d)', [AFieldName, ADefaultValue]);
  EffectiveAlias := ExtractAlias(AFieldName, AAlias);

  if EffectiveAlias <> '' then
    Result := Base + ' AS ' + EffectiveAlias
  else
    Result := Base  + ' AS ' + AFieldName;
end;

class function TCoalesce.Value(const AFieldName: string; const ADefaultValue: Double; const AAlias: string = ''): string;
var
  Base: string;
  EffectiveAlias: string;
begin
  Base := Format('COALESCE(%s, %f)', [AFieldName, ADefaultValue]);
  EffectiveAlias := ExtractAlias(AFieldName, AAlias);

  if EffectiveAlias <> '' then
    Result := Base + ' AS ' + EffectiveAlias
  else
    Result := Base  + ' AS ' + AFieldName;
end;

class function TCoalesce.Value(const AFieldName: string; const ADefaultValue: Boolean; const AAlias: string = ''): string;
var
  BoolValue: string;
  Base: string;
  EffectiveAlias: string;
begin
  if ADefaultValue then
    BoolValue := '1'
  else
    BoolValue := '0';

  Base := Format('COALESCE(%s, %s)', [AFieldName, BoolValue]);
  EffectiveAlias := ExtractAlias(AFieldName, AAlias);

  if EffectiveAlias <> '' then
    Result := Base + ' AS ' + EffectiveAlias
  else
    Result := Base  + ' AS ' + AFieldName;
end;

class function TCoalesce.Value(const AFieldName: string; const ADefaultValue: TDateTime; const AAlias: string = ''): string;
var
  Base: string;
  EffectiveAlias: string;
begin
  Base := Format('COALESCE(%s, ''%s'')', [AFieldName, FormatDateTime('yyyy-mm-dd hh:nn:ss', ADefaultValue)]);
  EffectiveAlias := ExtractAlias(AFieldName, AAlias);

  if EffectiveAlias <> '' then
    Result := Base + ' AS ' + EffectiveAlias
  else
    Result := Base  + ' AS ' + AFieldName;
end;

class function TCoalesce.Value(const AFieldName, ADefaultValue: string; const AQuoted: Boolean; const AAlias: string = ''): string;
var
  Base: string;
  EffectiveAlias: string;
begin
  if AQuoted then
    Base := Format('COALESCE(%s, ''%s'')', [AFieldName, ADefaultValue])
  else
    Base := Format('COALESCE(%s, %s)', [AFieldName, ADefaultValue]);

  EffectiveAlias := ExtractAlias(AFieldName, AAlias);

  if EffectiveAlias <> '' then
    Result := Base + ' AS ' + EffectiveAlias
  else
    Result := Base  + ' AS ' + AFieldName;
end;

class function TExpr.Max(const AValue: string): string;
begin
  Result := 'MAX(' + AValue + ')';
end;

class function TExpr.MiN(const AValue: string): string;
begin
  Result := 'MIN(' + AValue + ')';
end;

class function TExpr.Sum(const AValue: string): string;
begin
  Result := 'SUM(' + AValue + ')';
end;

class function TExpr.Count(const AValue: string): string;
begin
  Result := 'COUNT(' + AValue + ')';
end;

class function TExpr.Avg(const AValue: string): string;
begin
  Result := 'AVG(' + AValue + ')';
end;

class function TExpr.Concat(const AValues: array of string): string;
var
  i: Integer;
  Expression: string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtSQLServer:
      begin
        Expression := 'CONCAT(';
        for i := Low(AValues) to High(AValues) do
        begin
          if i > Low(AValues) then
            Expression := Expression + ', ';
          Expression := Expression + AValues[i];
        end;
        Expression := Expression + ')';
      end;
      
    dtOracle:
      begin
        Expression := '';
        for i := Low(AValues) to High(AValues) do
        begin
          if i > Low(AValues) then
            Expression := Expression + ' || ';
          Expression := Expression + AValues[i];
        end;
      end;
      
    else
      begin
        // PostgreSQL, SQLite, Firebird
        Expression := '';
        for i := Low(AValues) to High(AValues) do
        begin
          if i > Low(AValues) then
            Expression := Expression + ' || ';
          Expression := Expression + AValues[i];
        end;
      end;
  end;
  
  Result := Expression;
end;

class function TExpr.Cast(const AValue: string; const AType: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'CAST(' + AValue + ' AS ' + AType + ')';
    else
      Result := 'CAST(' + AValue + ' AS ' + AType + ')';
  end;
end;

class function TExpr.DateAdd(const APart: string; const AValue: Integer; const ADate: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL:
      Result := 'DATE_ADD(' + ADate + ', INTERVAL ' + IntToStr(AValue) + ' ' + APart + ')';
    
    dtSQLServer:
      Result := 'DATEADD(' + APart + ', ' + IntToStr(AValue) + ', ' + ADate + ')';
    
    dtPostgreSQL, dtSQLite:
      begin
        if AValue >= 0 then
          Result := '(' + ADate + ' + INTERVAL ''' + IntToStr(AValue) + ' ' + APart + ''')'
        else
          Result := '(' + ADate + ' - INTERVAL ''' + IntToStr(Abs(AValue)) + ' ' + APart + ''')';
      end;
    
    dtOracle:
      begin
        if CompareText(APart, 'day') = 0 then
          Result := '(' + ADate + ' + ' + IntToStr(AValue) + ')'
        else if CompareText(APart, 'month') = 0 then
          Result := 'ADD_MONTHS(' + ADate + ', ' + IntToStr(AValue) + ')'
        else if CompareText(APart, 'year') = 0 then
          Result := 'ADD_MONTHS(' + ADate + ', ' + IntToStr(AValue * 12) + ')'
        else
          Result := ADate; // Unsupported interval
      end;
    
    dtFirebird:
      begin
        if CompareText(APart, 'day') = 0 then
          Result := 'DATEADD(DAY, ' + IntToStr(AValue) + ', ' + ADate + ')'
        else if CompareText(APart, 'month') = 0 then
          Result := 'DATEADD(MONTH, ' + IntToStr(AValue) + ', ' + ADate + ')'
        else if CompareText(APart, 'year') = 0 then
          Result := 'DATEADD(YEAR, ' + IntToStr(AValue) + ', ' + ADate + ')'
        else
          Result := 'DATEADD(' + APart + ', ' + IntToStr(AValue) + ', ' + ADate + ')';
      end;
    
    else
      Result := ADate; // Unsupported database
  end;
end;

class function TExpr.DateDiff(const APart: string; const AStartDate, AEndDate: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL:
      Result := 'DATEDIFF(' + AEndDate + ', ' + AStartDate + ')';
    
    dtSQLServer:
      Result := 'DATEDIFF(' + APart + ', ' + AStartDate + ', ' + AEndDate + ')';
    
    dtPostgreSQL:
      begin
        if CompareText(APart, 'day') = 0 then
          Result := 'DATE_PART(''day'', ' + AEndDate + '::timestamp - ' + AStartDate + '::timestamp)'
        else
          Result := 'DATE_PART(''' + APart + ''', ' + AEndDate + '::timestamp - ' + AStartDate + '::timestamp)';
      end;
    
        dtOracle:
      begin
        if CompareText(APart, 'day') = 0 then
          Result := '(' + AEndDate + ' - ' + AStartDate + ')'
        else if CompareText(APart, 'month') = 0 then
          Result := 'MONTHS_BETWEEN(' + AEndDate + ', ' + AStartDate + ')'
        else if CompareText(APart, 'year') = 0 then
          Result := 'TRUNC(MONTHS_BETWEEN(' + AEndDate + ', ' + AStartDate + ') / 12)'
        else
          Result := '(' + AEndDate + ' - ' + AStartDate + ')'; // Default to days
      end;
    
    dtFirebird:
      begin
        if CompareText(APart, 'day') = 0 then
          Result := 'DATEDIFF(DAY, ' + AStartDate + ', ' + AEndDate + ')'
        else if CompareText(APart, 'month') = 0 then
          Result := 'DATEDIFF(MONTH, ' + AStartDate + ', ' + AEndDate + ')'
        else if CompareText(APart, 'year') = 0 then
          Result := 'DATEDIFF(YEAR, ' + AStartDate + ', ' + AEndDate + ')'
        else
          Result := 'DATEDIFF(' + APart + ', ' + AStartDate + ', ' + AEndDate + ')';
      end;
    
    else
      Result := '(' + AEndDate + ' - ' + AStartDate + ')'; // Generic fallback
  end;
end;

class function TExpr.CurrentDate: string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtPostgreSQL, dtSQLite:
      Result := 'CURRENT_DATE';
    
    dtSQLServer:
      Result := 'CONVERT(date, GETDATE())';
    
    dtOracle:
      Result := 'TRUNC(SYSDATE)';
    
    dtFirebird:
      Result := 'CURRENT_DATE';
    
    else
      Result := 'CURRENT_DATE';
  end;
end;

class function TExpr.CurrentTime: string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtPostgreSQL, dtSQLite:
      Result := 'CURRENT_TIME';
    
    dtSQLServer:
      Result := 'CONVERT(time, GETDATE())';
    
    dtOracle:
      Result := 'TO_CHAR(SYSDATE, ''HH24:MI:SS'')';
    
    dtFirebird:
      Result := 'CURRENT_TIME';
    
    else
      Result := 'CURRENT_TIME';
  end;
end;

class function TExpr.CurrentTimestamp: string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtPostgreSQL, dtSQLite:
      Result := 'CURRENT_TIMESTAMP';
    
    dtSQLServer:
      Result := 'GETDATE()';
    
    dtOracle:
      Result := 'SYSDATE';
    
    dtFirebird:
      Result := 'CURRENT_TIMESTAMP';
    
    else
      Result := 'CURRENT_TIMESTAMP';
  end;
end;

class function TExpr.Substring(const AValue: string; const AStart: Integer; const ALength: Integer): string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL:
      begin
        if ALength <= 0 then
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ')'
        else
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ', ' + IntToStr(ALength) + ')';
      end;
    
    dtSQLServer:
      begin
        if ALength <= 0 then
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ', 8000)'
        else
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ', ' + IntToStr(ALength) + ')';
      end;
    
    dtOracle:
      begin
        if ALength <= 0 then
          Result := 'SUBSTR(' + AValue + ', ' + IntToStr(AStart) + ')'
        else
          Result := 'SUBSTR(' + AValue + ', ' + IntToStr(AStart) + ', ' + IntToStr(ALength) + ')';
      end;
    
    else
      begin
        if ALength <= 0 then
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ')'
        else
          Result := 'SUBSTRING(' + AValue + ', ' + IntToStr(AStart) + ', ' + IntToStr(ALength) + ')';
      end;
  end;
end;

class function TExpr.Trim(const AValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'TRIM(' + AValue + ')';
    
    else
      Result := 'TRIM(' + AValue + ')';
  end;
end;

class function TExpr.Upper(const AValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'UPPER(' + AValue + ')';
    
    else
      Result := 'UPPER(' + AValue + ')';
  end;
end;

class function TExpr.Lower(const AValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'LOWER(' + AValue + ')';
    
    else
      Result := 'LOWER(' + AValue + ')';
  end;
end;

class function TExpr.Round(const AValue: string; const APrecision: Integer): string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtPostgreSQL:
      Result := 'ROUND(' + AValue + ', ' + IntToStr(APrecision) + ')';
    
    dtSQLServer:
      Result := 'ROUND(' + AValue + ', ' + IntToStr(APrecision) + ', 0)';
    
    dtOracle, dtFirebird, dtSQLite:
      Result := 'ROUND(' + AValue + ', ' + IntToStr(APrecision) + ')';
    
    else
      Result := 'ROUND(' + AValue + ', ' + IntToStr(APrecision) + ')';
  end;
end;

class function TExpr.Ceiling(const AValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtMySQL, dtPostgreSQL:
      Result := 'CEILING(' + AValue + ')';
    
    dtSQLServer:
      Result := 'CEILING(' + AValue + ')';
    
    dtOracle:
      Result := 'CEIL(' + AValue + ')';
    
    dtFirebird:
      Result := 'CEILING(' + AValue + ')';
    
    dtSQLite:
      Result := 'ROUND(' + AValue + ' + 0.5)';
    
    else
      Result := 'CEILING(' + AValue + ')';
  end;
end;

class function TExpr.Floor(const AValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtSQLite:
      Result := 'ROUND(' + AValue + ' - 0.5)';
    
    else
      Result := 'FLOOR(' + AValue + ')';
  end;
end;

class function TExpr.NVL(const AValue, ADefaultValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'NVL(' + AValue + ', ' + ADefaultValue + ')';
    
    dtSQLServer:
      Result := 'ISNULL(' + AValue + ', ' + ADefaultValue + ')';
    
    else
      Result := 'COALESCE(' + AValue + ', ' + ADefaultValue + ')';
  end;
end;

class function TExpr.IIF(const ACondition, ATrueValue, AFalseValue: string): string;
begin
  case TSQL.Instance.DatabaseType of
    dtSQLServer:
      Result := 'IIF(' + ACondition + ', ' + ATrueValue + ', ' + AFalseValue + ')';
    
    dtOracle:
      Result := 'CASE WHEN ' + ACondition + ' THEN ' + ATrueValue + ' ELSE ' + AFalseValue + ' END';
    
    else
      Result := 'CASE WHEN ' + ACondition + ' THEN ' + ATrueValue + ' ELSE ' + AFalseValue + ' END';
  end;
end;

{ TCondition }

constructor TCondition.Create(const AFieldName: string; const AAlias: string = '');
begin
  inherited Create;
  FFieldName := AFieldName;
  FAlias := AAlias;
end;

function TCondition.GetQualifiedFieldName: string;
begin
  if FAlias <> '' then
    Result := FAlias + '.' + FFieldName
  else
    Result := FFieldName;
end;

function TCondition.Equal(const AValue: Variant): string;
begin
  Result := Compare(AValue, '=');
end;

function TCondition.NotEqual(const AValue: Variant): string;
begin
  Result := Compare(AValue, '<>');
end;

function TCondition.GreaterThan(const AValue: Variant): string;
begin
  Result := Compare(AValue, '>');
end;

function TCondition.LessThan(const AValue: Variant): string;
begin
  Result := Compare(AValue, '<');
end;

function TCondition.GreaterOrEqual(const AValue: Variant): string;
begin
  Result := Compare(AValue, '>=');
end;

function TCondition.LessOrEqual(const AValue: Variant): string;
begin
  Result := Compare(AValue, '<=');
end;

function TCondition.IsNull: string;
begin
  Result := GetQualifiedFieldName + ' IS NULL';
end;

function TCondition.isTrue: string;
begin
  Result := GetQualifiedFieldName + ' = ' + QuotedStr('S');
end;

function TCondition.IsNotNull: string;
begin
  Result := GetQualifiedFieldName + ' IS NOT NULL';
end;

function TCondition.Like(const AValue: string): string;
begin
  Result := GetQualifiedFieldName + ' LIKE ' + QuotedStr('%' + AValue + '%');
end;

function TCondition.NotLike(const AValue: string): string;
begin
  Result := GetQualifiedFieldName + ' NOT LIKE ' + QuotedStr('%' + AValue + '%');
end;

function TCondition.Between(const AStartValue, AEndValue: Variant): string;
begin
  Result := GetQualifiedFieldName + ' BETWEEN ' +
            TSQL.FormatValue(AStartValue) + ' AND ' + TSQL.FormatValue(AEndValue);
end;

function TCondition.In_(const AValues: array of Variant): string;
var
  i: Integer;
  ValuesList: TStringList;
begin
  ValuesList := TStringList.Create;
  try
    for i := Low(AValues) to High(AValues) do
      ValuesList.Add(TSQL.FormatValue(AValues[i]));

    Result := GetQualifiedFieldName + ' IN (' + ValuesList.CommaText + ')';
  finally
    ValuesList.Free;
  end;
end;

function TCondition.NotIn(const AValues: array of Variant): string;
var
  i: Integer;
  ValuesList: TStringList;
begin
  ValuesList := TStringList.Create;
  try
    for i := Low(AValues) to High(AValues) do
      ValuesList.Add(TSQL.FormatValue(AValues[i]));

    Result := GetQualifiedFieldName + ' NOT IN (' + ValuesList.CommaText + ')';
  finally
    ValuesList.Free;
  end;
end;

function TCondition.Compare(const AValue: Variant; const AOperator: string = '='): string;
begin
  if VarIsNull(AValue) or VarIsClear(AValue) then
  begin
    if AOperator = '=' then
      Result := IsNull
    else if AOperator = '<>' then
      Result := IsNotNull
    else
      Result := GetQualifiedFieldName;
  end
  else if (AOperator = 'LIKE') and VarIsStr(AValue) then
    Result := Like(AValue)
  else
    Result := GetQualifiedFieldName + ' ' + AOperator + ' ' + TSQL.FormatValue(AValue);
end;

function TCondition.PorId(const AValue: Integer = -1; const AOperator: string = '='): string;
begin
  if AValue = -1 then
    Result := GetQualifiedFieldName
  else
    Result := GetQualifiedFieldName + ' ' + AOperator + ' ' + IntToStr(AValue);
end;

function TCondition.PorDescricao(const AValue: string = ''; const AOperator: string = 'LIKE'): string;
begin
  if AValue = '' then
    Result := GetQualifiedFieldName
  else if AOperator = 'LIKE' then
    Result := Like(AValue)
  else
    Result := GetQualifiedFieldName + ' ' + AOperator + ' ' + QuotedStr(AValue);
end;

function TCondition.PorStatus(const AValue: Char; const AOperator: string = '='): string;
begin
  Result := GetQualifiedFieldName + ' ' + AOperator + ' ' + QuotedStr(AValue);
end;

function TCondition.PorCodigo(const AValue: string = ''; const AOperator: string = '='): string;
begin
  if AValue = '' then
    Result := GetQualifiedFieldName
  else
    Result := GetQualifiedFieldName + ' ' + AOperator + ' ' + QuotedStr(AValue);
end;

function TCondition.PorPeriodo(const ACampoData: string; const ADataInicial, ADataFinal: TDateTime): string;
var
  QualifiedDateField: string;
begin
  if ACampoData <> '' then
  begin
    if FAlias <> '' then
      QualifiedDateField := FAlias + '.' + ACampoData
    else
      QualifiedDateField := ACampoData;
  end
  else
    QualifiedDateField := GetQualifiedFieldName;

  Result := QualifiedDateField + ' BETWEEN ' +
            QuotedStr(FormatDateTime('yyyy-mm-dd', ADataInicial)) +
            ' AND ' +
            QuotedStr(FormatDateTime('yyyy-mm-dd', ADataFinal));
end;

function TCondition.PorBoolean(const ACampoBoolean: string; const AValue: Boolean;
  const ASim: string = 'S'; const ANao: string = 'N'): string;
var
  QualifiedBoolField: string;
  Value: string;
begin
  if ACampoBoolean <> '' then
  begin
    if FAlias <> '' then
      QualifiedBoolField := FAlias + '.' + ACampoBoolean
    else
      QualifiedBoolField := ACampoBoolean;
  end
  else
    QualifiedBoolField := GetQualifiedFieldName;

  if AValue then
    Value := QuotedStr(ASim)
  else
    Value := QuotedStr(ANao);

  Result := QualifiedBoolField + ' = ' + Value;
end;

class function TCondition.Field(const AFieldName: string; const AAlias: string = ''): TCondition;
begin
  Result := TCondition.Create(AFieldName, AAlias);
end;

function TCondition.StartsWith(const AValue: string): string;
begin
  Result := GetQualifiedFieldName + ' LIKE ' + QuotedStr(AValue + '%');
end;

function TCondition.EndsWith(const AValue: string): string;
begin
  Result := GetQualifiedFieldName + ' LIKE ' + QuotedStr('%' + AValue);
end;

function TCondition.Contains(const AValue: string): string;
begin
  Result := GetQualifiedFieldName + ' LIKE ' + QuotedStr('%' + AValue + '%');
end;

function TCondition.DateEquals(const AValue: TDateTime): string;
var
  DateStr: string;
begin
  DateStr := FormatDateTime('yyyy-mm-dd', AValue);
  
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'TRUNC(' + GetQualifiedFieldName + ') = TO_DATE(''' + DateStr + ''', ''YYYY-MM-DD'')';
    
    dtSQLServer:
      Result := 'CONVERT(date, ' + GetQualifiedFieldName + ') = ''' + DateStr + '''';
    
    else
      Result := 'DATE(' + GetQualifiedFieldName + ') = ''' + DateStr + '''';
  end;
end;

function TCondition.DateBefore(const AValue: TDateTime): string;
var
  DateStr: string;
begin
  DateStr := FormatDateTime('yyyy-mm-dd', AValue);
  
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'TRUNC(' + GetQualifiedFieldName + ') < TO_DATE(''' + DateStr + ''', ''YYYY-MM-DD'')';
    
    dtSQLServer:
      Result := 'CONVERT(date, ' + GetQualifiedFieldName + ') < ''' + DateStr + '''';
    
    else
      Result := 'DATE(' + GetQualifiedFieldName + ') < ''' + DateStr + '''';
  end;
end;

function TCondition.DateAfter(const AValue: TDateTime): string;
var
  DateStr: string;
begin
  DateStr := FormatDateTime('yyyy-mm-dd', AValue);
  
  case TSQL.Instance.DatabaseType of
    dtOracle:
      Result := 'TRUNC(' + GetQualifiedFieldName + ') > TO_DATE(''' + DateStr + ''', ''YYYY-MM-DD'')';
    
    dtSQLServer:
      Result := 'CONVERT(date, ' + GetQualifiedFieldName + ') > ''' + DateStr + '''';
    
    else
      Result := 'DATE(' + GetQualifiedFieldName + ') > ''' + DateStr + '''';
  end;
end;

function TCondition.Exists(const ASubquery: string): string;
begin
  Result := 'EXISTS (' + ASubquery + ')';
end;

function TCondition.NotExists(const ASubquery: string): string;
begin
  Result := 'NOT EXISTS (' + ASubquery + ')';
end;

function TCondition.IsEmpty: string;
begin
  Result := '(' + GetQualifiedFieldName + ' IS NULL OR ' + GetQualifiedFieldName + ' = '''')';
end;

function TCondition.IsNotEmpty: string;
begin
  Result := '(' + GetQualifiedFieldName + ' IS NOT NULL AND ' + GetQualifiedFieldName + ' <> '''')';
end;

{ TMigration }

constructor TMigration.Create(const AName, AVersion: string);
begin
  inherited Create;
  FName := AName;
  FVersion := AVersion;
  FCommands := TStringList.Create;
end;

destructor TMigration.Destroy;
begin
  FCommands.Free;
  inherited;
end;

function TMigration.GetCommandCount: integer;
begin
  Result := FCommands.Count;
end;

procedure TMigration.AddCommand(const ASQL: string);
begin
  FCommands.Add(ASQL);
end;

function TMigration.AsScript: string;
var
  Script: TStringBuilder;
begin
  Script := TStringBuilder.Create;
  try
    Script.AppendLine('-- Migration: ' + FName);
    Script.AppendLine('-- Version: ' + FVersion);
    Script.AppendLine('-- Created: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    Script.AppendLine;
    
    Script.Append(FCommands.Text);
    
    Result := Script.ToString;
  finally
    Script.Free;
  end;
end;

procedure TMigration.SaveToFile(const AFileName: string);
begin
  FCommands.SaveToFile(AFileName);
end;

initialization
  TSQL.FInstance := nil;
  TemplateCache := nil;

finalization
  if Assigned(TSQL.FInstance) then
    TSQL.FInstance.Free;
    
  if Assigned(TemplateCache) then
    TemplateCache.Free;

end.
