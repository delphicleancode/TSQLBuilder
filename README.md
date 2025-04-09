# TSQLBuilder
Biblioteca de SQL fluente (Fluent SQL Builder) em Object Pascal com compatibilidade para Delphi e Lazarus.

# Sobre
A biblioteca SQLBuilder oferece uma maneira mais segura, legível e manutenível de criar consultas SQL em seus projetos Object Pascal. 
Através da interface fluente, você pode construir desde consultas simples até operações complexas com múltiplos JOINs, CTEs, transações e migrações de bancos de dados.
Além disso, a biblioteca tem suporte para diferentes bancos de dados.

# Exemplos de Uso da Biblioteca SQLBuilder

Exemplos práticos de como utilizar a biblioteca SQLBuilder em projetos Delphi e Lazarus. 

## Tabela de Conteúdos

### Consultas Simples
- SELECT Básico
  - Selecionar todos os registros
  - Selecionar campos específicos
- INSERT Simples
- UPDATE Simples
- DELETE Simples

### Consultas de Complexidade Média
- SELECT com JOIN
- Condições Complexas
- Subconsultas
- Funções de Agregação
- INSERT com Subconsulta

### Consultas Complexas
- Múltiplos JOINs
- CTEs (Common Table Expressions)
- Transações
- Paginação
- Migrations
  - Criar Tabelas
  - Adicionar Índices
  - Adicionar Chaves Estrangeiras

### Configuração
- Configuração do Dialeto SQL
  - MySQL
  - Firebird
  - PostgreSQL
  - SQLite
  - SQL Server
  - Oracle

### Formatação
- Formatação e Visualização do SQL
- Usando o Helper para Evitar SQL Injection

### Consultas Simples

#### SELECT Básico
Selecionar todos os registros de uma tabela:
```
var SQL: string;
begin
  SQL := TSQL.SELECT('*')
           .FROM('clientes')
           .WHERE('ativo = ''S''')
           .ORDER_BY('nome')
           .AsString;
  
  // Resultado:
  // SELECT * FROM clientes WHERE ativo = 'S' ORDER BY nome
end;
```

#### Selecionar campos específicos:
```
begin
  SQL := TSQL.SELECT(['id', 'nome', 'email'])
           .FROM('usuarios')
           .LIMIT(10)
           .AsString;
  
  // Resultado:
  // SELECT id, nome, email FROM usuarios LIMIT 10
end;
```
#### INSERT Simples
```
begin
  SQL := TSQL.INSERT_INTO('produtos')
           .COLUMNS(['descricao', 'preco', 'estoque'])
           .VALUES(['Teclado Mecânico', 299.90, 15])
           .AsString;
  
  // Resultado:
  // INSERT INTO produtos (descricao, preco, estoque) 
  // VALUES ('Teclado Mecânico', 299.90, 15)
end;
```

#### UPDATE Simples
```
begin
           .SET('nome', 'Periféricos')
           .SET('ativo', True)
           .WHERE('id = 5')
           .AsString;
  
  // Resultado:
  // UPDATE categorias SET nome = 'Periféricos', ativo = 1 WHERE id = 5
end;
```

#### DELETE Simples
```
begin
  SQL := TSQL.DELETE_FROM('log_acessos')
           .WHERE('data < ''2023-01-01''')
           .AsString;
  
  // Resultado:
  // DELETE FROM log_acessos WHERE data < '2023-01-01'
end;
```

#### SELECT com JOIN
```
begin
  SQL := TSQL.SELECT(['p.id', 'p.descricao', 'c.nome as categoria'])
           .FROM('produtos p')
           .INNER_JOIN('categorias c', 'c.id = p.categoria_id')
           .WHERE('p.ativo = ''S''')
           .AND_WHERE('p.preco > 100')
           .ORDER_BY('p.descricao')
           .AsString;
  
  // Resultado:
  // SELECT p.id, p.descricao, c.nome as categoria 
  // FROM produtos p 
  // INNER JOIN categorias c ON c.id = p.categoria_id 
  // WHERE p.ativo = 'S' AND p.preco > 100 
  // ORDER BY p.descricao
end;
```

#### Condições Complexas
Utilização da classe TCondition para construir condições:
```
begin
  SQL := TSQL.SELECT(['id', 'nome', 'email', 'telefone'])
           .FROM('clientes')
           .WHERE(TCondition.Field('status').Equal('A'))
           .AND_WHERE(TCondition.Field('ultima_compra')
                               .GreaterThan(EncodeDate(2023, 1, 1)))
           .AND_WHERE('(saldo_devedor = 0 OR possui_credito = ''S'')')
           .ORDER_BY('nome')
           .AsString;
  
  // Resultado:
  // SELECT id, nome, email, telefone 
  // FROM clientes 
  // WHERE status = 'A' AND ultima_compra > '2023-01-01' 
  // AND (saldo_devedor = 0 OR possui_credito = 'S') 
  // ORDER BY nome
end;
```

#### Subconsultas
```
begin
  var SubQuery := TSQL.SELECT('id')
                     .FROM('categorias')
                     .WHERE('tipo = ''PRIORITARIA''')
                     .AsSubquery();
                     
  SQL := TSQL.SELECT(['p.id', 'p.descricao', 'p.preco'])
           .FROM('produtos p')
           .WHERE('p.categoria_id IN ' + SubQuery)
           .ORDER_BY('p.preco DESC')
           .AsString;
  
  // Resultado:
  // SELECT p.id, p.descricao, p.preco 
  // FROM produtos p 
  // WHERE p.categoria_id IN (SELECT id FROM categorias WHERE tipo = 'PRIORITARIA') 
  // ORDER BY p.preco DESC
end;
```

#### Funções de Agregação
```
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
  
  // Resultado:
  // SELECT c.id, c.nome, SUM(v.valor_total) as valor_total, COUNT(v.id) as qtd_vendas 
  // FROM clientes c 
  // LEFT JOIN vendas v ON v.cliente_id = c.id 
  // WHERE v.data BETWEEN '2023-01-01' AND '2023-12-31' 
  // GROUP BY c.id, c.nome 
  // HAVING SUM(v.valor_total) > 10000 
  // ORDER BY valor_total DESC
end;
```
#### INSERT com Subconsulta
```
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
  
  // Resultado:
  // INSERT INTO produtos_promocao (produto_id, descricao, preco_promocional) 
  // SELECT id, descricao, preco * 0.8 
  // FROM produtos 
  // WHERE estoque > 20
end;
```

#### Consultas Complexas Múltiplos JOINs
```
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
end;
```

#### CTEs (Common Table Expressions)
```
begin
  TSQL.MySQLMode; // Assegurar compatibilidade MySQL

  SQL := TSQL.WITH('vendas_por_cliente AS (
                 SELECT 
                   cliente_id,
                   SUM(valor_total) as total_vendas,
                   COUNT(*) as qtd_vendas,
                   MAX(data) as ultima_venda
                 FROM 
                   vendas
                 WHERE 
                   data >= ''2023-01-01''
                 GROUP BY 
                   cliente_id
               )')
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
end;
```

#### Transações
```
begin
  // Iniciar transação
  TSQL.BEGIN_TRANSACTION;
  
  // Atualizar estoque
  var SQL1 := TSQL.UPDATE('produtos')
                .SET('estoque', TExpr.Sum('estoque') + ' - :quantidade')
                .WHERE('id = :produto_id')
                .PARAM('quantidade', 5)
                .PARAM('produto_id', 123)
                .AsString;
  
  // Inserir pedido
  var SQL2 := TSQL.INSERT_INTO('pedidos')
                .COLUMNS(['cliente_id', 'data', 'valor_total', 'status'])
                .VALUES([42, TExpr.CurrentDate, 1250.99, 'P'])
                .AsString;
  
  // Obter ID do último pedido inserido (específico MySQL)
  var SQL3 := 'SELECT LAST_INSERT_ID() as pedido_id';
  
  // Inserir itens do pedido
  var SQL4 := TSQL.INSERT_INTO('itens_pedido')
                .COLUMNS(['pedido_id', 'produto_id', 'quantidade', 'valor_unitario'])
                .VALUES([':pedido_id', 123, 5, 250.20])
                .AsString;
  
  // Completar a transação
  var SQL5 := TSQL.COMMIT.AsString;
  
  // Todas as consultas acima seriam executadas em sequência dentro de uma transação
end;
```

#### Paginação
```
procedure ExemploPaginacao(const APagina, ATamanhoPagina: Integer);
var
  SQLCount, SQLData: string;
begin
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
              .PAGINATE(APagina, ATamanhoPagina)
              .AsString;
end;
```

#### Migrations
```
function CriarMigration: string;
var
  Migration: TMigration;
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
    
    Result := Migration.AsScript;
  finally
    Migration.Free;
  end;
end;
```

## Configuração do Dialeto SQL

A biblioteca SQLBuilder suporta vários bancos de dados, cada um com suas peculiaridades sintáticas. Veja como configurar:

```pascal
// Configurar para MySQL (padrão)
TSQL.MySQLMode;

// Configurar para Firebird
TSQL.FirebirdMode;

// Configurar para PostgreSQL
TSQL.PostgreSQLMode;

// Configurar para SQLite
TSQL.SQLiteMode;

// Configurar para SQL Server
TSQL.SQLServerMode;

// Configurar para Oracle
TSQL.OracleMode;
```

## Formatação e Visualização do SQL

```pascal
begin
  var SQL := TSQL.SELECT(['id', 'nome', 'email'])
                .FROM('usuarios')
                .WHERE('status = ''A''')
                .AND_WHERE('ultimo_acesso > ''2023-01-01''')
                .ORDER_BY('nome');
  
  // SQL como string simples
  Memo1.Lines.Text := SQL.AsString;
  
  // SQL formatado com indentação
  Memo2.Lines.Text := SQL.AsFormattedString;
end;
```

## Usando o Helper para Evitar SQL Injection

```pascal
begin
  var IdUsuario := 10;
  var NomeProduto := 'Monitor LED 24"';
  
  // Errado (vulnerável a SQL Injection):
  // var SQL := 'SELECT * FROM produtos WHERE id = ' + IntToStr(IdUsuario);
  
  // Correto usando SQLBuilder:
  var SQL := TSQL.SELECT('*')
                .FROM('produtos')
                .WHERE('id = ' + TSQL.FormatValue(IdUsuario))
                .AND_WHERE('nome LIKE ' + TSQL.FormatValue('%' + NomeProduto + '%'))
                .AsString;
end;
```

## Trabalhando com Valores NULL

```pascal
begin
  var DataVenda: TDateTime := 0;
  var Observacao: string := '';
  var ValorDesconto: Double := 0;
  
  SQL := TSQL.UPDATE('vendas')
           .SET('data_venda', DataVenda) // Se DataVenda = 0, será tratado como NULL
           .SET('observacao', Observacao) // Se Observacao estiver vazia, será tratado como NULL
           .SET('valor_desconto', ValorDesconto) // Se ValorDesconto = 0, será incluído como 0, não NULL
           .WHERE('id = 123')
           .AsString;
           
  // Para forçar NULL explicitamente:
  SQL := TSQL.UPDATE('vendas')
           .SET('data_cancelamento', Null)
           .WHERE('id = 123')
           .AsString;
end;
```

## Expressões CASE e Condições Avançadas

```pascal
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
end;
```

## Consultas Dinâmicas

```pascal
procedure ConsultaDinamica(const AFiltros: TDictionary<string, Variant>);
var
  Query: TSQL;
begin
  Query := TSQL.SELECT('*')
              .FROM('clientes');
  
  // Aplicar filtros dinamicamente
  if AFiltros.ContainsKey('nome') and (AFiltros['nome'] <> '') then
    Query.AND_WHERE(TCondition.Field('nome').Contains(AFiltros['nome']));
    
  if AFiltros.ContainsKey('cidade') and (AFiltros['cidade'] <> '') then
    Query.AND_WHERE(TCondition.Field('cidade').Equal(AFiltros['cidade']));
    
  if AFiltros.ContainsKey('data_inicio') and (AFiltros['data_inicio'] <> 0) then
    Query.AND_WHERE(TCondition.Field('data_cadastro').GreaterOrEqual(AFiltros['data_inicio']));
    
  if AFiltros.ContainsKey('data_fim') and (AFiltros['data_fim'] <> 0) then
    Query.AND_WHERE(TCondition.Field('data_cadastro').LessOrEqual(AFiltros['data_fim']));
    
  if AFiltros.ContainsKey('apenas_ativos') and AFiltros['apenas_ativos'] then
    Query.AND_WHERE(TCondition.Field('status').Equal('A'));
  
  // Ordenação
  if AFiltros.ContainsKey('ordenacao') then
    Query.ORDER_BY(AFiltros['ordenacao']);
  else
    Query.ORDER_BY('nome');
  
  // Paginação
  if AFiltros.ContainsKey('pagina') and AFiltros.ContainsKey('registros_por_pagina') then
    Query.PAGINATE(AFiltros['pagina'], AFiltros['registros_por_pagina']);
  
  SQL := Query.AsString;
end;
```
