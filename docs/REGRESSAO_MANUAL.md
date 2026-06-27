# Checklist de regressão manual — erp_alianca_dev

Documento da **Parte 0** do plano de refatoração arquitetural.  
Repetir este checklist ao final de **cada parte** implementada na branch `refactor/arquitetura-faseada`.

---

## Baseline (referência antes das mudanças)

| Item | Valor |
|------|-------|
| **Branch** | `refactor/arquitetura-faseada` |
| **Versão app** | `1.0.1+3` (`pubspec.yaml`) |
| **Data baseline** | 2026-06-18 |
| **id_empresa (mock)** | `3` — baseline congelada |
| **API base** | `https://aliancadev.com/estoque_vendas/` |
| **Plataforma principal** | Windows (desktop) + Android |

### Como rodar o app para testar

```bash
flutter pub get
flutter run -d windows
# ou
flutter run -d <device_android>
```

### Antes de cada checklist

1. `flutter analyze` — sem erros novos
2. App abre sem crash na Home
3. Console sem erros graves de rede (timeout ocasional anotar)

---

## Ritual após cada parte

- [ ] Parte N implementada
- [ ] `flutter analyze` OK
- [ ] Checklist abaixo executado
- [ ] Anotar data e resultado na tabela **Histórico de partes**
- [ ] Commit: `refactor(parte-N): descrição`

---

## 1. Home

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 1.1 | Abrir app → tela Home carrega | ☐ | |
| 1.2 | Cards exibem contadores (clientes, produtos, pedidos) | ☐ | |
| 1.3 | Navegar para outra tela e voltar — contadores permanecem | ☐ | |

---

## 2. Clientes

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 2.1 | Listagem carrega clientes | ☐ | |
| 2.2 | Busca por nome (debounce ~300ms) | ☐ | |
| 2.3 | Filtro ativo / inativo | ☐ | |
| 2.4 | Criar novo cliente — salvar com sucesso | ☐ | |
| 2.5 | Editar cliente existente — salvar | ☐ | |
| 2.6 | Ver detalhes do cliente | ☐ | |
| 2.7 | Arquivar cliente (soft delete) | ☐ | |

---

## 3. Produtos

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 3.1 | Listagem carrega produtos | ☐ | |
| 3.2 | Busca por nome | ☐ | |
| 3.3 | Filtro ativo / inativo | ☐ | |
| 3.4 | Criar produto — salvar | ☐ | |
| 3.5 | Editar produto — salvar | ☐ | |
| 3.6 | Arquivar produto | ☐ | |

---

## 4. Pedidos

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 4.1 | Listagem carrega pedidos | ☐ | |
| 4.2 | Nome do cliente aparece na listagem | ☐ | |
| 4.3 | Busca / filtros da listagem | ☐ | |
| 4.4 | Criar pedido — selecionar cliente | ☐ | |
| 4.5 | Criar pedido — adicionar produtos | ☐ | |
| 4.6 | Salvar pedido novo | ☐ | |
| 4.7 | Abrir detalhe do pedido | ☐ | |
| 4.8 | Adicionar item no detalhe | ☐ | |
| 4.9 | Remover item no detalhe | ☐ | |
| 4.10 | Visualizar cupom PDF | ☐ | |
| 4.11 | Salvar cupom PDF em disco | ☐ | |
| 4.12 | Arquivar pedido (se aplicável) | ☐ | |

---

## 5. Romaneio

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 5.1 | Listagem carrega romaneios | ☐ | |
| 5.2 | Busca / filtros | ☐ | |
| 5.3 | Criar romaneio — selecionar pedidos | ☐ | |
| 5.4 | Salvar romaneio novo | ☐ | |
| 5.5 | Abrir detalhe do romaneio | ☐ | |
| 5.6 | Alterar status do romaneio | ☐ | |
| 5.7 | Adicionar / remover pedido no detalhe | ☐ | |
| 5.8 | Faturar romaneio | ☐ | |
| 5.9 | Visualizar PDF do romaneio | ☐ | |
| 5.10 | Salvar PDF do romaneio em disco | ☐ | |

---

## 6. Navegação geral

| # | Ação | OK | Observação |
|---|------|:--:|------------|
| 6.1 | Sidebar: alternar Home → Clientes → Produtos → Pedidos → Romaneio | ☐ | |
| 6.2 | Navegação rápida entre telas (5+ vezes) — sem crash | ☐ | |
| 6.3 | Voltar / histórico de navegação funciona | ☐ | |
| 6.4 | Tema/cores da empresa carregam corretamente | ☐ | |

---

## Histórico de partes

Preencher após validar cada parte:

| Parte | Descrição | Data teste | Resultado | Testador |
|-------|-----------|------------|-----------|----------|
| 0 | Baseline + checklist | 2026-06-18 | Documentado | — |
| 1 | BaseViewModel + `_disposed` | | ☐ Passou / ☐ Falhou | |
| 2 | ProdutoService | | ☐ Passou / ☐ Falhou | |
| 3 | ApiResponse | | ☐ Passou / ☐ Falhou | |
| 4 | Desacoplar PedidoCriar | | ☐ Passou / ☐ Falhou | |
| 5 | Contratos VM/View | | ☐ Passou / ☐ Falhou | |
| 6 | Quebrar romaneio_detalhes_view | | ☐ Passou / ☐ Falhou | |
| 7 | Quebrar pedido_detalhes | | ☐ Passou / ☐ Falhou | |
| 8 | PdfExportService | | ☐ Passou / ☐ Falhou | |
| 9 | Limpeza | | ☐ Passou / ☐ Falhou | |
| 10 | Testes unitários | 2026-06-18 | ☑ Passou (28 testes) | CI/agent |
| 11 | Paginação + auth removido | 2026-06-18 | ☑ Passou (auto) | CI/agent |
| 12 | Pós-main: busca, romaneio VM, limpeza | 2026-06-18 | ☑ Passou (auto) | CI/agent |
| 13 | Testes services/VM, quebra monolitos, polish | 2026-06-18 | ☑ Passou (auto) | CI/agent |
| 14 | Baseline congelada `id_empresa=3` | 2026-06-18 | ☑ | — |

---

### Parte 14 — baseline congelada (2026-06-18)

- [x] `kDefaultIdEmpresa = 3` em `EmpresaService`
- [x] Startup persiste `id_empresa: 3` (todas as requests via Dio)
- [x] Linha **erp_alianca_dev** pronta para fork/evolução em outro repositório

---

## Validação automatizada (2026-06-18 — atualizado Parte 13)

| Verificação | Resultado |
|-------------|-----------|
| `flutter analyze` | 0 erros (58 infos) |
| `flutter test` | **37 testes** passando |
| Testes Service (mock Dio) | Cliente, Produto, Pedido, Romaneio |
| Teste ViewModel | `ClientesViewModel` |
| Widget test | `HomeView` monta com título Dashboard |
| Monolitos quebrados | `pedido_criar_viewmodel`, `romaneio_create_*`, `pedido_item_row`, modal seleção, `produto_detalhes_view` |
| Arquivos >300 linhas | 12 restantes (antes 17) |
| Getters totais listagem | `PedidosViewModel.totalGeralListagem`, `RomaneioViewModel.totalFaturadoListagem` |
| `DioClient` | Construtor opcional `dio:` para testes |

**Pendente validação manual no dispositivo:** checklist das seções 1–6 abaixo.

---

## Validação automatizada (2026-06-18 — Parte 12)

Executado após merge na `main` e hardening pós-refatoração:

| Verificação | Resultado |
|-------------|-----------|
| `flutter analyze` | 0 erros (64 infos de deprecations) |
| `flutter test` | 28 testes passando |
| Views sem Dio/HTTP | OK |
| Auth/login removido | OK (sem rotas, sem token helpers) |
| Fix `setState during build` (busca) | OK — limpeza adiada via `addPostFrameCallback` |
| `RomaneioDetalheViewModel` | Quebrado em 3 mixins + model (`~358` linhas no VM principal) |
| `ProdutoCriarViewModel` | `AppException` only; provider scoped no router |

**Pendente validação manual no dispositivo:** checklist das seções 1–6 abaixo (Home, Clientes, Produtos, Pedidos, Romaneio, PDF).

---

## Parte 0 — concluída

- [x] Branch `refactor/arquitetura-faseada` criada
- [x] Versão baseline anotada (`1.0.1+3`)
- [x] Checklist manual documentado (este arquivo)
- [x] Nenhuma alteração de código de refatoração (apenas documentação)

**Próximo passo:** Validação manual completa do checklist + push da branch.

### Parte 13 — implementada (validação automatizada 2026-06-18)

- [x] Testes: `ClienteService`, `ProdutoService`, `PedidoService`, `RomaneioService` (mock Dio)
- [x] Teste `ClientesViewModel` + widget `HomeView`
- [x] `PedidoCriarViewModel` → 3 mixins (cliente, itens, produto busca)
- [x] `romaneio_create_view` + widgets → subpasta `romaneio_create/` (<300 linhas cada)
- [x] `pedido_item_row`, `pedido_selecao_produtos_modal`, `produto_detalhes_view` quebrados
- [x] Getters de total nas listagens de Pedidos e Romaneio
- [x] `section_header`: `withOpacity` → `withValues` (amostra deprecations)

### Parte 12 — implementada (validação automatizada 2026-06-18)

- [x] Fix busca: `resetBusca(notify: false)` + limpeza pós-frame em Clientes/Produtos
- [x] `RomaneioDetalheViewModel` → mixins (`edicao`, `pedidos`, `pdf`) + `produto_agregado.dart`
- [x] `ProdutoCriarViewModel`: `AppException` (sem import Dio); provider scoped em `app_router`
- [x] Removidos helpers de token em `LocalStorageService` e pastas vazias `auth/`/`login`
- [x] Getters `podeGerarPdf` / `podeFaturar` no VM do romaneio

### Parte 11 — implementada (aguardando validação manual)

- [x] `PaginatedResult` + `ApiResponseParser.parsePaginatedList` (fallback client-side)
- [x] Services: `listar*Paginado` em Cliente, Produto, Pedido, Romaneio
- [x] ViewModels de listagem com `loadMore*` e cache local
- [x] Views com scroll infinito + `ListLoadMoreFooter`
- [x] `EmpresaService` dinâmico (persiste `id_empresa`)
- [ ] ~~Login / Auth guard~~ — removido desta linha do produto (auth ficará em fork separado)

### Parte 10 — implementada (aguardando validação manual)

- [x] Testes unitários: `ApiResponseParser` (`test/core/network/`)
- [x] Testes unitários: `PedidoCalculator`, `PedidoConfirmacaoErro` (`test/features/pedidos/utils/`)
- [x] Testes unitários: `cliente_formatters` (`test/shared/utils/`)
- [x] `flutter test` — 28 testes passando

### Parte 9 — implementada (aguardando validação manual)

- [x] Removidos repositories stub (pedidos, home, romaneio) e `navigation_usage_example.dart`
- [x] Formatters consolidados em `shared/utils/cliente_formatters.dart`
- [x] Romaneio VM usa `PedidoCupomBuilder` e `nomeArquivoReciboPedido`
- [x] Removido `AppTheme.dark` morto; migrado `core/constants/app_text_styles` → `shared/theme`
- [x] Atualizado `.cursor/rules/Vendas-base.mdc`

### Parte 8 — implementada (aguardando validação manual)

- [x] `PdfExportService` centralizado (preview + salvar/abrir)
- [x] `PdfPreviewPage` reutilizável
- [x] ViewModels de pedido e romaneio orquestram exportação PDF

### Parte 7 — implementada (aguardando validação manual)

- [x] `pedido_detalhes_view.dart` quebrada em widgets (<300 linhas)
- [x] Mixins de edição/busca + utils (`pedido_calculator`, `pedido_cupom_builder`, etc.)

### Parte 6 — implementada (aguardando validação manual)

- [x] `romaneio_detalhes_view.dart` quebrada em widgets (<300 linhas)
- [x] Atualizado `printing` para 5.14.3 (fix AssetManifest)

### Parte 5 — implementada (aguardando validação manual)

- [x] `PedidoSelecaoProdutosVm` movido para `features/pedidos/contracts/`
- [x] ViewModels não importam mais a View do modal
- [x] Modal e telas de pedido importam o contrato

### Parte 4 — implementada (aguardando validação manual)

- [x] `PedidoCriarViewModel` usa `ClienteService` (estado de busca próprio)
- [x] Removida dependência de `ClientesViewModel` no router
- [x] `PedidosViewModel` resolve nomes de clientes sob demanda com cache
- [x] `flutter analyze` sem erros nos arquivos alterados

### Parte 3 — implementada (aguardando validação manual)

- [x] `lib/core/network/api_response.dart` criado (`ApiResponseParser`)
- [x] Services migrados: `ClienteService`, `ProdutoService`, `PedidoService`, `RomaneioService`, `DashboardService`
- [x] Parsing unificado para listas, objetos e mutações (ok/success)
- [x] `flutter analyze` sem erros nos arquivos alterados

### Parte 1 — implementada (aguardando validação manual)

- [x] `lib/shared/viewmodels/base_view_model.dart` criado
- [x] `ClientesViewModel`, `ProdutosViewModel`, `PedidosViewModel`, `RomaneioViewModel` estendem `BaseViewModel`
- [x] `dispose()` cancela `Timer` de debounce (clientes e produtos)
- [x] Guards `isDisposed` em métodos async das listagens
- [x] `flutter analyze` sem issues nos arquivos alterados

### Parte 2 — implementada (aguardando validação manual)

- [x] `lib/shared/services/produto_service.dart` criado
- [x] `ProdutosRepository` removido
- [x] ViewModels e rotas atualizados para `ProdutoService`
- [x] `ProdutoService` registrado no `main.dart` (como `ClienteService`)
- [x] `flutter analyze` sem erros novos
