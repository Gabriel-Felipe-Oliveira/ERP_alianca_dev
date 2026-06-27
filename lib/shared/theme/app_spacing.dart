/// Espaçamentos padronizados do Design System. Não usar números mágicos no código.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // --- Grid base desktop (telas principais) ---

  /// Padding lateral padrão da tela (esquerda e direita). Evita conteúdo colado na borda.
  static const double screenPaddingLateral = 24;

  /// Espaçamento vertical entre blocos principais: barra de busca, filtros, contador, lista, seções.
  static const double section = 16;

  /// Padding interno vertical dos tiles (itens de lista).
  static const double tilePaddingVertical = 12;

  /// Padding interno horizontal dos tiles (itens de lista).
  static const double tilePaddingHorizontal = 16;

  /// Espaço entre tiles na listagem.
  static const double tileGap = sm;

  /// Altura entre campos de formulário
  static const double fieldSpacing = md;

  /// Altura entre seções do formulário
  static const double sectionSpacing = lg;

  /// Espaçamento antes do título de seção (hierarquia visual)
  static const double sectionTitleSpacingBefore = xl;

  /// Largura máxima do container de formulário (desktop)
  static const double formMaxWidth = 700;

  /// Abaixo desta largura o layout de criação de romaneio usa coluna única.
  static const double layoutBreakpointTwoColumns = 900;

  /// Abaixo desta largura: tela pequena (coluna única, padding reduzido).
  static const double layoutBreakpointSmall = 640;

  /// Padding da tela em modo médio (2 colunas, reduzido).
  static const double screenPaddingMedium = 12;

  /// Padding da tela em modo pequeno (coluna única).
  static const double screenPaddingSmall = 12;

  /// Padding compacto para cards (romaneio create).
  static const double cardPaddingCompact = 12;

  /// Espaço entre seções (compacto).
  static const double sectionSpacingCompact = 12;

  /// Espaço entre campos (compacto).
  static const double fieldSpacingCompact = 8;

  /// Border radius dos inputs (TextField, Dropdown)
  static const double inputBorderRadius = 12;

  /// Border radius do container de formulário
  static const double formContainerBorderRadius = 12;

  /// Padding horizontal dos inputs
  static const double inputPaddingHorizontal = 16;

  /// Padding vertical dos inputs
  static const double inputPaddingVertical = 18;

  /// Largura da borda em foco (input) — mais perceptível
  static const double inputFocusedBorderWidth = 2.5;

  /// Padding interno do container de formulário (card)
  static const double formContainerPadding = lg;

  /// Altura do botão primário
  static const double buttonHeight = 48;

  /// Altura do botão secundário (outlined/ghost) — não compete com o primário
  static const double buttonHeightSecondary = 40;

  /// Blur da sombra do card (profissional)
  static const double formContainerShadowBlurRadius = 20;

  /// Deslocamento vertical da sombra do card
  static const double formContainerShadowOffsetY = 10;

  /// Altura da barra de ações (área de decisão)
  static const double actionBarHeight = 64;

  /// Padding horizontal da barra de ações
  static const double actionBarPaddingHorizontal = lg;

  /// Padding vertical da barra de ações
  static const double actionBarPaddingVertical = md;

  /// Espaço entre os botões na barra de ações
  static const double actionBarButtonSpacing = 12;

  /// Largura do painel de ferramentas ao lado do formulário
  static const double toolPanelWidth = 220;

  /// Largura do painel em modo compacto (apenas ícones).
  static const double toolPanelWidthCompact = 56;

  /// Abaixo desta largura da área de conteúdo o painel exibe só ícones.
  /// Valor alto para priorizar o formulário: painel compacto quando a janela não está 100%.
  static const double toolPanelBreakpoint = 1200;

  /// Border radius do painel de ferramentas
  static const double toolPanelBorderRadius = 16;

  /// Largura máxima da barra de pesquisa nas telas de listagem (centralizada).
  static const double listagemSearchBarMaxWidth = 500;

  /// Border radius dos cards nas telas de listagem (header, lista).
  static const double listagemCardBorderRadius = 16;

  /// Padding das telas de listagem (header e lista).
  static const double listagemScreenPadding = lg;

  /// Border radius da barra de busca na listagem (visual leve).
  static const double listagemSearchBarBorderRadius = 12;

  /// Border radius do header de entidade na listagem.
  static const double listagemHeaderBorderRadius = 18;

  /// Border radius do badge de código no header.
  static const double listagemCodeBadgeBorderRadius = 8;

  /// Border radius do item da lista na listagem.
  static const double listagemItemBorderRadius = 14;

  /// Largura máxima do bloco central da listagem (busca + header + lista).
  static const double listagemContentMaxWidth = 700;

  /// Elevação do card que agrupa filtro de período + lista.
  static const double listagemContentCardElevation = 8;

  /// Padding interno do card filtro + lista.
  static const double listagemContentCardPadding = 16;
}
