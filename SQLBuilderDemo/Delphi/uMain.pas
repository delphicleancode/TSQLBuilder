unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Generics.Collections, SQLBuilder;

type
  TFormMain = class(TForm)
    pnlTop: TPanel;
    cmbExamples: TComboBox;
    btnExecute: TButton;
    Panel1: TPanel;
    lblFormattedSQL: TLabel;
    memoFormattedSQL: TMemo;
    Panel2: TPanel;
    lblRawSQL: TLabel;
    memoSQL: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure buildSQL(Sender: TObject);
  private
    procedure PopulateExamplesList;
    procedure RunExample(ExampleIndex: Integer);
    
    // Simple Queries
    procedure SelectBasic;
    procedure SelectFields;
    procedure InsertSimple;
    procedure UpdateSimple;
    procedure DeleteSimple;
    
    // Medium Complexity Queries
    procedure SelectWithJoin;
    procedure ComplexConditions;
    procedure Subqueries;
    procedure AggregationFunctions;
    procedure InsertWithSubquery;
    
    // Complex Queries
    procedure MultipleJoins;
    procedure CTEExample;
    procedure TransactionExample;
    procedure PaginationExample;
    procedure MigrationExample;
    
    // Configuration
    procedure SQLDialectConfig;
    
    // Formatting
    procedure FormattingAndVisualization;
    procedure SqlInjectionPrevention;
    
    // Advanced
    procedure NullValueHandling;
    procedure CaseExpressions;
    procedure DynamicQueries;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  PopulateExamplesList;
end;

procedure TFormMain.PopulateExamplesList;
begin
  cmbExamples.Items.Clear;
  
  // Simple Queries
  cmbExamples.Items.Add('SELECT Basic - All Records');
  cmbExamples.Items.Add('SELECT Specific Fields');
  cmbExamples.Items.Add('INSERT Simple');
  cmbExamples.Items.Add('UPDATE Simple');
  cmbExamples.Items.Add('DELETE Simple');
  
  // Medium Complexity Queries
  cmbExamples.Items.Add('SELECT with JOIN');
  cmbExamples.Items.Add('Complex Conditions');
  cmbExamples.Items.Add('Subqueries');
  cmbExamples.Items.Add('Aggregation Functions');
  cmbExamples.Items.Add('INSERT with Subquery');
  
  // Complex Queries
  cmbExamples.Items.Add('Multiple JOINs');
  cmbExamples.Items.Add('CTE Example');
  cmbExamples.Items.Add('Transaction Example');
  cmbExamples.Items.Add('Pagination Example');
  cmbExamples.Items.Add('Migration Example');
  
  // Configuration
  cmbExamples.Items.Add('SQL Dialect Configuration');
  
  // Formatting
  cmbExamples.Items.Add('Formatting and Visualization');
  cmbExamples.Items.Add('SQL Injection Prevention');
  
  // Advanced
  cmbExamples.Items.Add('NULL Value Handling');
  cmbExamples.Items.Add('CASE Expressions');
  cmbExamples.Items.Add('Dynamic Queries');
  
  if cmbExamples.Items.Count > 0 then
    cmbExamples.ItemIndex := 0;
end;

procedure TFormMain.buildSQL(Sender: TObject);
begin
  if cmbExamples.ItemIndex >= 0 then
    RunExample(cmbExamples.ItemIndex);
end;

procedure TFormMain.RunExample(ExampleIndex: Integer);
begin
  memoSQL.Clear;
  memoFormattedSQL.Clear;
  
  case ExampleIndex of
    0: SelectBasic;
    1: SelectFields;
    2: InsertSimple;
    3: UpdateSimple;
    4: DeleteSimple;
    5: SelectWithJoin;
    6: ComplexConditions;
    7: Subqueries;
    8: AggregationFunctions;
    9: InsertWithSubquery;
    10: MultipleJoins;
    11: CTEExample;
    12: TransactionExample;
    13: PaginationExample;
    14: MigrationExample;
    15: SQLDialectConfig;
    16: FormattingAndVisualization;
    17: SqlInjectionPrevention;
    18: NullValueHandling;
    19: CaseExpressions;
    20: DynamicQueries;
  end;
end;

// Simple Queries
procedure TFormMain.SelectBasic;
var
  SQL: string;
begin
  SQL := TSQL.SELECT('*')
           .FROM('clientes')
           .WHERE('ativo = ''S''')
           .ORDER_BY('nome')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT('*')
                              .FROM('clientes')
                              .WHERE('ativo = ''S''')
                              .ORDER_BY('nome')
                              .AsFormattedString;
end;

procedure TFormMain.SelectFields;
var
  SQL: string;
begin
  SQL := TSQL.SELECT(['id', 'nome', 'email'])
           .FROM('usuarios')
           .LIMIT(10)
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT(['id', 'nome', 'email'])
                              .FROM('usuarios')
                              .LIMIT(10)
                              .AsFormattedString;
end;

procedure TFormMain.InsertSimple;
var
  SQL: string;
begin
  SQL := TSQL.INSERT_INTO('produtos')
           .COLUMNS(['descricao', 'preco', 'estoque'])
           .VALUES(['Teclado Mecânico', 299.90, 15])
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.INSERT_INTO('produtos')
                              .COLUMNS(['descricao', 'preco', 'estoque'])
                              .VALUES(['Teclado Mecânico', 299.90, 15])
                              .AsFormattedString;
end;

procedure TFormMain.UpdateSimple;
var
  SQL: string;
begin
  SQL := TSQL.UPDATE('categorias')
           .&SET('nome', 'Periféricos')
           .&SET('ativo', True)
           .WHERE('id = 5')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.UPDATE('categorias')
                              .&SET('nome', 'Periféricos')
                              .&SET('ativo', True)
                              .WHERE('id = 5')
                              .AsFormattedString;
end;

procedure TFormMain.DeleteSimple;
var
  SQL: string;
begin
  SQL := TSQL.DELETE_FROM('log_acessos')
           .WHERE('data < ''2023-01-01''')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.DELETE_FROM('log_acessos')
                              .WHERE('data < ''2023-01-01''')
                              .AsFormattedString;
end;

// Medium Complexity Queries
procedure TFormMain.SelectWithJoin;
var
  SQL: string;
begin
  SQL := TSQL.SELECT(['p.id', 'p.descricao', 'c.nome as categoria'])
           .FROM('produtos p')
           .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
           .WHERE('p.ativo = ''S''')
           .AND_WHERE('p.preco > 100')
           .ORDER_BY('p.descricao')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT(['p.id', 'p.descricao', 'c.nome as categoria'])
                              .FROM('produtos p')
                              .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
                              .WHERE('p.ativo = ''S''')
                              .AND_WHERE('p.preco > 100')
                              .ORDER_BY('p.descricao')
                              .AsFormattedString;
end;

procedure TFormMain.ComplexConditions;
var
  SQL: string;
begin
  SQL := TSQL.SELECT(['id', 'nome', 'email', 'telefone'])
           .FROM('clientes')
           .WHERE(TCondition.Field('status').Equal('A'))
           .AND_WHERE(TCondition.Field('ultima_compra')
                               .GreaterThan(EncodeDate(2023, 1, 1)))
           .AND_WHERE('(saldo_devedor = 0 OR possui_credito = ''S'')')
           .ORDER_BY('nome')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT(['id', 'nome', 'email', 'telefone'])
                              .FROM('clientes')
                              .WHERE(TCondition.Field('status').Equal('A'))
                              .AND_WHERE(TCondition.Field('ultima_compra')
                                                  .GreaterThan(EncodeDate(2023, 1, 1)))
                              .AND_WHERE('(saldo_devedor = 0 OR possui_credito = ''S'')')
                              .ORDER_BY('nome')
                              .AsFormattedString;
end;

procedure TFormMain.Subqueries;
var
  SQL: string;
  SubQuery: string;
begin
  SubQuery := TSQL.SELECT('id')
                 .FROM('categorias')
                 .WHERE('tipo = ''PRIORITARIA''')
                 .AsSubquery();
                 
  SQL := TSQL.SELECT(['p.id', 'p.descricao', 'p.preco'])
           .FROM('produtos p')
           .WHERE('p.categoria_id IN ' + SubQuery)
           .ORDER_BY('p.preco DESC')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT(['p.id', 'p.descricao', 'p.preco'])
                              .FROM('produtos p')
                              .WHERE('p.categoria_id IN ' + SubQuery)
                              .ORDER_BY('p.preco DESC')
                              .AsFormattedString;
end;

procedure TFormMain.AggregationFunctions;
var
  SQL: string;
begin
  SQL := TSQL.SELECT([
               'c.id', 
               'c.nome',
               TExpr.Sum('v.valor_total') + ' as valor_total',
               TExpr.Count('v.id') + ' as qtd_vendas'
             ])
           .FROM('clientes c')
           .LEFT_JOIN('vendas v', 'v.cliente_id = c.id')
           .WHERE('v.data BETWEEN ''2023-01-01'' AND ''2023-12-31''')
           .GROUP_BY(['c.id', 'c.nome'])
           .HAVING(TExpr.Sum('v.valor_total') + ' > 10000')
           .ORDER_BY('valor_total DESC')
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT([
                                'c.id', 
                                'c.nome',
                                TExpr.Sum('v.valor_total') + ' as valor_total',
                                TExpr.Count('v.id') + ' as qtd_vendas'
                              ])
                              .FROM('clientes c')
                              .LEFT_JOIN('vendas v', 'v.cliente_id = c.id')
                              .WHERE('v.data BETWEEN ''2023-01-01'' AND ''2023-12-31''')
                              .GROUP_BY(['c.id', 'c.nome'])
                              .HAVING(TExpr.Sum('v.valor_total') + ' > 10000')
                              .ORDER_BY('valor_total DESC')
                              .AsFormattedString;
end;

procedure TFormMain.InsertWithSubquery;
var
  SQL: string;
begin
  SQL := TSQL.INSERT_INTO('produtos_promocao')
           .COLUMNS(['produto_id', 'descricao', 'preco_promocional'])
           .VALUES(
             TSQL.SELECT(['id', 'descricao', 'preco * 0.8'])
                .FROM('produtos')
                .WHERE('estoque > 20')
                .AsString
           )
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.INSERT_INTO('produtos_promocao')
                              .COLUMNS(['produto_id', 'descricao', 'preco_promocional'])
                              .VALUES(
                                TSQL.SELECT(['id', 'descricao', 'preco * 0.8'])
                                   .FROM('produtos')
                                   .WHERE('estoque > 20')
                                   .AsString
                              )
                              .AsFormattedString;
end;

// Complex Queries
procedure TFormMain.MultipleJoins;
var
  SQL: string;
begin
  SQL := TSQL.SELECT([
               'p.id',
               'p.numero_pedido',
               'c.nome AS cliente',
               'v.nome AS vendedor',
               'SUM(i.quantidade * i.valor_unitario) AS valor_total',
               'p.data_pedido',
               TCoalesce.Value('p.data_entrega', 'Pendente') + ' AS entrega',
               'f.descricao AS forma_pagamento'
             ])
           .FROM('pedidos p')
           .INNER_JOIN('clientes c', 'c.id = p.cliente_id')
           .INNER_JOIN('vendedores v', 'v.id = p.vendedor_id')
           .INNER_JOIN('itens_pedido i', 'i.pedido_id = p.id')
           .LEFT_JOIN('produtos pr', 'pr.id = i.produto_id')
           .LEFT_JOIN('formas_pagamento f', 'f.id = p.forma_pagamento_id')
           .WHERE('p.status <> ''C''')
           .AND_WHERE(TCondition.Field('p.data_pedido').Between(
              EncodeDate(2023, 1, 1), 
              EncodeDate(2023, 12, 31)
           ))
           .AND_WHERE(TCondition.Field('pr.categoria_id').In_([1, 3, 5, 8]))
           .GROUP_BY([
              'p.id', 'p.numero_pedido', 'c.nome', 'v.nome', 
              'p.data_pedido', 'p.data_entrega', 'f.descricao'
           ])
           .HAVING('SUM(i.quantidade * i.valor_unitario) > 500')
           .ORDER_BY('p.data_pedido DESC')
           .LIMIT(50)
           .AsString;
  
  memoSQL.Text := SQL;
  memoFormattedSQL.Text := SQL; // Using AsFormattedString would be too long for this example
end;

procedure TFormMain.CTEExample;
var
  SQL: string;
  cteDefinition: string;
begin
  TSQL.MySQLMode; // Assegurar compatibilidade MySQL

  // Define the CTE properly using correct string formatting
  cteDefinition := 
    'vendas_por_cliente AS (' + sLineBreak +
    '  SELECT ' + sLineBreak +
    '    cliente_id,' + sLineBreak +
    '    SUM(valor_total) as total_vendas,' + sLineBreak +
    '    COUNT(*) as qtd_vendas,' + sLineBreak +
    '    MAX(data) as ultima_venda' + sLineBreak +
    '  FROM ' + sLineBreak +
    '    vendas' + sLineBreak +
    '  WHERE ' + sLineBreak +
    '    data >= ''2023-01-01''' + sLineBreak +
    '  GROUP BY ' + sLineBreak +
    '    cliente_id' + sLineBreak +
    ')';

  SQL := TSQL.WITH(cteDefinition)
           .SELECT([
               'c.id',
               'c.nome',
               'c.email',
               'COALESCE(vpc.total_vendas, 0) as total_compras',
               'COALESCE(vpc.qtd_vendas, 0) as quantidade_compras',
               'vpc.ultima_venda',
               'CASE WHEN vpc.total_vendas > 10000 THEN ''VIP'' ELSE ''Regular'' END as categoria_cliente'
           ])
           .FROM('clientes c')
           .LEFT_JOIN('vendas_por_cliente vpc', 'vpc.cliente_id = c.id')
           .WHERE('c.ativo = 1')
           .ORDER_BY('total_compras DESC')
           .AsString;
  
  memoSQL.Text := SQL;
  
  // For the formatted version, do the same construction but use AsFormattedString
  memoFormattedSQL.Text := TSQL.WITH(cteDefinition)
                              .SELECT([
                                  'c.id',
                                  'c.nome',
                                  'c.email',
                                  'COALESCE(vpc.total_vendas, 0) as total_compras',
                                  'COALESCE(vpc.qtd_vendas, 0) as quantidade_compras',
                                  'vpc.ultima_venda',
                                  'CASE WHEN vpc.total_vendas > 10000 THEN ''VIP'' ELSE ''Regular'' END as categoria_cliente'
                              ])
                              .FROM('clientes c')
                              .LEFT_JOIN('vendas_por_cliente vpc', 'vpc.cliente_id = c.id')
                              .WHERE('c.ativo = 1')
                              .ORDER_BY('total_compras DESC')
                              .AsFormattedString;
end;


procedure TFormMain.TransactionExample;
var
  SQL1, SQL2, SQL3, SQL4, SQL5: string;
begin
  // Iniciar transação
  SQL1 := TSQL.BEGIN_TRANSACTION.AsString;
  
  // Atualizar estoque
  SQL2 := TSQL.UPDATE('produtos')
            .&SET('estoque', TExpr.Sum('estoque') + ' - :quantidade')
            .WHERE('id = :produto_id')
            .PARAM('quantidade', 5)
            .PARAM('produto_id', 123)
            .AsString;
  
  // Inserir pedido
  SQL3 := TSQL.INSERT_INTO('pedidos')
            .COLUMNS(['cliente_id', 'data', 'valor_total', 'status'])
            .VALUES([42, TExpr.CurrentDate, 1250.99, 'P'])
            .AsString;
  
  // Obter ID do último pedido inserido (específico MySQL)
  SQL4 := 'SELECT LAST_INSERT_ID() as pedido_id';
  
  // Inserir itens do pedido
  SQL5 := TSQL.INSERT_INTO('itens_pedido')
            .COLUMNS(['pedido_id', 'produto_id', 'quantidade', 'valor_unitario'])
            .VALUES([':pedido_id', 123, 5, 250.20])
            .AsString;
  
  memoSQL.Text := SQL1 + sLineBreak + SQL2 + sLineBreak + SQL3 + sLineBreak + 
                  SQL4 + sLineBreak + SQL5 + sLineBreak + TSQL.COMMIT.AsString;
  
  memoFormattedSQL.Text := 'TRANSACTION EXAMPLE:' + sLineBreak + sLineBreak +
                           '1. BEGIN TRANSACTION' + sLineBreak +
                           '2. Update products stock' + sLineBreak +
                           '3. Insert order' + sLineBreak +
                           '4. Get last inserted ID' + sLineBreak +
                           '5. Insert order items' + sLineBreak +
                           '6. COMMIT';
end;

procedure TFormMain.PaginationExample;
var
  SQLCount, SQLData: string;
  Page, PageSize: Integer;
begin
  Page := 2;
  PageSize := 10;
  
  // Primeiro obter contagem total para calcular número de páginas
  SQLCount := TSQL.SELECT('COUNT(*) as total')
                 .FROM('produtos p')
                 .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
                 .INNER_JOIN('fornecedores f', 'f.id = p.fornecedor_id')
                 .WHERE('p.preco BETWEEN 100 AND 1000')
                 .AND_WHERE('p.estoque > 0')
                 .AND_WHERE('c.ativo = 1')
                 .AsString;
  
  // Depois obter registros da página atual
  SQLData := TSQL.SELECT([
                'p.id',
                'p.codigo',
                'p.descricao',
                'p.preco',
                'p.estoque',
                'c.nome as categoria',
                'f.nome as fornecedor'
              ])
              .FROM('produtos p')
              .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
              .INNER_JOIN('fornecedores f', 'f.id = p.fornecedor_id')
              .WHERE('p.preco BETWEEN 100 AND 1000')
              .AND_WHERE('p.estoque > 0')
              .AND_WHERE('c.ativo = 1')
              .ORDER_BY('p.descricao')
              .PAGINATE(Page, PageSize)
              .AsString;
  
  memoSQL.Text := 'Count Query:' + sLineBreak + SQLCount + sLineBreak + sLineBreak +
                  'Data Query (Page ' + IntToStr(Page) + ', ' + IntToStr(PageSize) + ' per page):' + sLineBreak + SQLData;
                  
  memoFormattedSQL.Text := TSQL.SELECT([
                                'p.id',
                                'p.codigo',
                                'p.descricao',
                                'p.preco',
                                'p.estoque',
                                'c.nome as categoria',
                                'f.nome as fornecedor'
                              ])
                              .FROM('produtos p')
                              .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
                              .INNER_JOIN('fornecedores f', 'f.id = p.fornecedor_id')
                              .WHERE('p.preco BETWEEN 100 AND 1000')
                              .AND_WHERE('p.estoque > 0')
                              .AND_WHERE('c.ativo = 1')
                              .ORDER_BY('p.descricao')
                              .PAGINATE(Page, PageSize)
                              .AsFormattedString;
end;

procedure TFormMain.MigrationExample;
var
  Migration: TMigration;
  Script: string;
begin
  Migration := TMigration.Create('criar_tabela_produtos', '1.0.0');
  try
    // Adicionar comando para criar tabela
    Migration.AddCommand(
      TSQL.CREATE_TABLE('produtos')
         .ADD_COLUMN('id', 'INT', 'NOT NULL AUTO_INCREMENT')
         .ADD_COLUMN('codigo', 'VARCHAR(20)', 'NOT NULL')
         .ADD_COLUMN('descricao', 'VARCHAR(200)', 'NOT NULL')
         .ADD_COLUMN('preco', 'DECIMAL(10,2)', 'NOT NULL DEFAULT 0')
         .ADD_COLUMN('estoque', 'INT', 'NOT NULL DEFAULT 0')
         .ADD_COLUMN('categoria_id', 'INT', 'NULL')
         .ADD_COLUMN('fornecedor_id', 'INT', 'NULL')
         .ADD_COLUMN('data_cadastro', 'DATETIME', 'NOT NULL')
         .ADD_COLUMN('ativo', 'TINYINT(1)', 'NOT NULL DEFAULT 1')
         .PRIMARY_KEY(['id'])
         .AsString
    );
    
    // Adicionar comandos para índices
    Migration.AddCommand(
      TSQL.CREATE_INDEX('idx_produto_codigo', 'produtos', ['codigo'], True).AsString
    );
    
    Migration.AddCommand(
      TSQL.CREATE_INDEX('idx_produto_categoria', 'produtos', ['categoria_id']).AsString
    );
    
    // Adicionar comandos para chaves estrangeiras
    Migration.AddCommand(
      TSQL.ALTER_TABLE('produtos')
         .ADD_CONSTRAINT('fk_produto_categoria', 
                         'FOREIGN KEY (categoria_id) REFERENCES categorias(id)')
         .AsString
    );
    
    Migration.AddCommand(
      TSQL.ALTER_TABLE('produtos')
         .ADD_CONSTRAINT('fk_produto_fornecedor', 
                         'FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)')
         .AsString
    );
    
    Script := Migration.AsScript;

    memoSQL.Text := Script;
    memoFormattedSQL.Text := 'Migration: ' + Migration.Name + ' (Version: ' + Migration.Version + ')' + sLineBreak +
                             'Contains ' + IntToStr(Migration.CommandCount) + ' commands.' + sLineBreak +
                             Migration.AsScript;
  finally
    Migration.Free;
  end;
end;

procedure TFormMain.SQLDialectConfig;
var
  SQLMySQL, SQLFirebird, SQLPostgreSQL, SQLSQLite, SQLSQLServer, SQLOracle: string;
begin
  // MySQL
  TSQL.MySQLMode;
  SQLMySQL := TSQL.SELECT('*')
                 .FROM('users')
                 .LIMIT(10)
                 .AsString;
                 
  // Firebird
  TSQL.FirebirdMode;
  SQLFirebird := TSQL.SELECT('*')
                    .FROM('users')
                    .FIRST(10)
                    .AsString;

  // PostgreSQL
  TSQL.PostgreSQLMode;
  SQLPostgreSQL := TSQL.SELECT('*')
                      .FROM('users')
                      .LIMIT(10)
                      .AsString;
                      
  // SQLite
  TSQL.SQLiteMode;
  SQLSQLite := TSQL.SELECT('*')
                  .FROM('users')
                  .LIMIT(10)
                  .AsString;
                  
  // SQL Server
  TSQL.SQLServerMode;
  SQLSQLServer := TSQL.SELECT('TOP 10 *')
                     .FROM('users')
                     .AsString;
                     
  // Oracle
  TSQL.OracleMode;
  SQLOracle := TSQL.SELECT('*')
                  .FROM('users')
                  .WHERE('ROWNUM <= 10')
                  .AsString;
                  
  // Reset to default MySQL mode
  TSQL.MySQLMode;
  
  memoSQL.Text := 'MySQL: ' + SQLMySQL + sLineBreak + sLineBreak +
                  'Firebird: ' + SQLFirebird + sLineBreak + sLineBreak +
                  'PostgreSQL: ' + SQLPostgreSQL + sLineBreak + sLineBreak +
                  'SQLite: ' + SQLSQLite + sLineBreak + sLineBreak +
                  'SQL Server: ' + SQLSQLServer + sLineBreak + sLineBreak +
                  'Oracle: ' + SQLOracle;
                  
  memoFormattedSQL.Text := memoSQL.Text;
end;

procedure TFormMain.FormattingAndVisualization;
var
  SQL: TSQL;
begin
  SQL := TSQL.SELECT(['id', 'nome', 'email'])
            .FROM('usuarios')
            .WHERE('status = ''A''')
            .AND_WHERE('ultimo_acesso > ''2023-01-01''')
            .ORDER_BY('nome');
  
  // SQL como string simples
  memoSQL.Text := SQL.AsString;
  
  // SQL formatado com indentação
  memoFormattedSQL.Text := SQL.AsFormattedString;
end;

procedure TFormMain.SqlInjectionPrevention;
var
  SQL: string;
  IdUsuario: Integer;
  NomeProduto: string;
begin
  IdUsuario := 10;

  SQL := TSQL.Select(['SUM(i.quantidade * i.valor_unitario) AS valor_total',
                      'p.data_pedido',
                      TCoalesce.Value('p.data_entrega', 'Pendente') + ' AS entrega',
                      'f.descricao AS forma_pagamento'
          ])
          .FROM('pedidos p')
          .INNER_JOIN('clientes c', 'c.id = p.cliente_id')
          .INNER_JOIN('vendedores v', 'v.id = p.vendedor_id')
          .INNER_JOIN('itens_pedido i', 'i.pedido_id = p.id')
          .LEFT_JOIN('produtos pr', 'pr.id = i.produto_id')
          .LEFT_JOIN('formas_pagamento f', 'f.id = p.forma_pagamento_id')
          .WHERE('p.status <> ''C''')
          .AND_WHERE(TCondition.Field('p.data_pedido').Between(
            EncodeDate(2023, 1, 1),
            EncodeDate(2023, 12, 31)
          ))
          .AND_WHERE(TCondition.Field('pr.categoria_id').In_([1, 3, 5, 8]))
          .GROUP_BY([
            'p.id', 'p.numero_pedido', 'c.nome', 'v.nome',
            'p.data_pedido', 'p.data_entrega', 'f.descricao'
          ])
          .HAVING('SUM(i.quantidade * i.valor_unitario) > 500')
          .ORDER_BY('p.data_pedido DESC')
          .LIMIT(50)
          .AsFormattedString;

  memoSQL.Text := SQL;
  memoFormattedSQL.Text := SQL;
end;

procedure TFormMain.NullValueHandling;
var
  SQL: string;
  DataVenda: TDateTime;
  Observacao: string;
  ValorDesconto: Double;
begin
  DataVenda := 0;
  Observacao := '';
  ValorDesconto := 0;

  SQL := TSQL.UPDATE('vendas')
           .&SET('data_venda', DataVenda) // Se DataVenda = 0, será tratado como NULL
           .&SET('observacao', Observacao) // Se Observacao estiver vazia, será tratado como NULL
           .&SET('valor_desconto', ValorDesconto) // Se ValorDesconto = 0, será incluído como 0, não NULL
           .WHERE('id = 123')
           .AsString;

  // Para forçar NULL explicitamente:
  var SQLWithNull := TSQL.UPDATE('vendas')
                         .&SET('data_cancelamento', Null)
                         .WHERE('id = 123')
                         .AsString;

  memoSQL.Text := 'Update with potential NULL values:' + sLineBreak + SQL + sLineBreak + sLineBreak +
                  'Update with explicit NULL:' + sLineBreak + SQLWithNull;

  memoFormattedSQL.Text := TSQL.UPDATE('vendas')
                              .&SET('data_venda', DataVenda)
                              .&SET('observacao', Observacao)
                              .&SET('valor_desconto', ValorDesconto)
                              .WHERE('id = 123')
                              .AsFormattedString + sLineBreak + sLineBreak +
                           TSQL.UPDATE('vendas')
                              .&SET('data_cancelamento', Null)
                              .WHERE('id = 123')
                              .AsFormattedString;
end;

procedure TFormMain.CaseExpressions;
var
  SQL: string;
begin
  SQL := TSQL.SELECT([
             'id',
             'nome',
             'CASE WHEN tipo = ''F'' THEN ''Física'' ' +
             'WHEN tipo = ''J'' THEN ''Jurídica'' ' +
             'ELSE ''Desconhecido'' END AS tipo_pessoa',
             TExpr.IIF('ativo = 1', '''Sim''', '''Não''') + ' AS situacao'
           ])
           .FROM('pessoas')
           .WHERE(TCondition.Field('cidade').In_(['São Paulo', 'Rio de Janeiro', 'Belo Horizonte']))
           .AND_WHERE(TCondition.Field('cadastro').GreaterOrEqual(EncodeDate(2023, 1, 1)))
           .ORDER_BY('nome')
           .AsString;

  memoSQL.Text := SQL;
  memoFormattedSQL.Text := TSQL.SELECT([
                               'id',
                               'nome',
                               'CASE WHEN tipo = ''F'' THEN ''Física'' ' +
                               'WHEN tipo = ''J'' THEN ''Jurídica'' ' +
                               'ELSE ''Desconhecido'' END AS tipo_pessoa',
                               TExpr.IIF('ativo = 1', '''Sim''', '''Não''') + ' AS situacao'
                             ])
                             .FROM('pessoas')
                             .WHERE(TCondition.Field('cidade').In_(['São Paulo', 'Rio de Janeiro', 'Belo Horizonte']))
                             .AND_WHERE(TCondition.Field('cadastro').GreaterOrEqual(EncodeDate(2023, 1, 1)))
                             .ORDER_BY('nome')
                             .AsFormattedString;
end;

procedure TFormMain.DynamicQueries;
var
  Filtros: TDictionary<string, Variant>;
  Query: TSQL;
  SQL: string;
begin
  Filtros := TDictionary<string, Variant>.Create;
  try
    // Example with some filters
    Filtros.Add('nome', 'Maria');
    Filtros.Add('cidade', 'São Paulo');
    Filtros.Add('data_inicio', EncodeDate(2023, 1, 1));
    Filtros.Add('apenas_ativos', True);
    Filtros.Add('ordenacao', 'nome ASC');
    Filtros.Add('pagina', 2);
    Filtros.Add('registros_por_pagina', 15);
    
    Query := TSQL.SELECT('*')
                .FROM('clientes');
    
    // Aplicar filtros dinamicamente
    if Filtros.ContainsKey('nome') and (Filtros['nome'] <> '') then
      Query.AND_WHERE(TCondition.Field('nome').Contains(Filtros['nome']));
      
    if Filtros.ContainsKey('cidade') and (Filtros['cidade'] <> '') then
      Query.AND_WHERE(TCondition.Field('cidade').Equal(Filtros['cidade']));
      
    if Filtros.ContainsKey('data_inicio') and (Filtros['data_inicio'] <> 0) then
      Query.AND_WHERE(TCondition.Field('data_cadastro').GreaterOrEqual(Filtros['data_inicio']));
      
    if Filtros.ContainsKey('data_fim') and (Filtros['data_fim'] <> 0) then
      Query.AND_WHERE(TCondition.Field('data_cadastro').LessOrEqual(Filtros['data_fim']));
      
    if Filtros.ContainsKey('apenas_ativos') and Filtros['apenas_ativos'] then
      Query.AND_WHERE(TCondition.Field('status').Equal('A'));
    
    // Ordenação
    if Filtros.ContainsKey('ordenacao') then
      Query.ORDER_BY(Filtros['ordenacao'])
    else
      Query.ORDER_BY('nome');
    
    // Paginação
    if Filtros.ContainsKey('pagina') and Filtros.ContainsKey('registros_por_pagina') then
      Query.PAGINATE(Filtros['pagina'], Filtros['registros_por_pagina']);
    
    SQL := Query.AsString;
    
    memoSQL.Text := 'Dynamic Query with Filters:' + sLineBreak + 
                    '- Name: ' + VarToStr(Filtros['nome']) + sLineBreak +
                    '- City: ' + VarToStr(Filtros['cidade']) + sLineBreak +
                    '- Start Date: ' + DateToStr(Filtros['data_inicio']) + sLineBreak +
                    '- Active Only: ' + BoolToStr(Filtros['apenas_ativos'], True) + sLineBreak +
                    '- Page: ' + VarToStr(Filtros['pagina']) + sLineBreak +
                    '- Records per page: ' + VarToStr(Filtros['registros_por_pagina']) + sLineBreak + sLineBreak +
                    SQL;
                    
    memoFormattedSQL.Text := Query.AsFormattedString;
  finally
    Filtros.Free;
  end;
end;

end.


