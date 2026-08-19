import 'package:flutter/material.dart';

/// Faixas de largura de janela usadas pelo aplicativo, seguindo os tamanhos
/// canônicos do Material 3.
///
/// - [compacta]: celulares em retrato;
/// - [media]: celulares grandes em paisagem e tablets pequenos em retrato;
/// - [expandida]: tablets em paisagem e telas maiores.
enum LarguraJanela { compacta, media, expandida }

LarguraJanela larguraDaJanela(BuildContext context) =>
    larguraJanelaPara(MediaQuery.sizeOf(context).width);

LarguraJanela larguraJanelaPara(double largura) {
  if (largura < 600) return LarguraJanela.compacta;
  if (largura < 840) return LarguraJanela.media;
  return LarguraJanela.expandida;
}

/// Alturas pequenas (paisagem em celular) pedem menos respiro vertical.
bool alturaCompacta(BuildContext context) =>
    MediaQuery.sizeOf(context).height < 480;

/// Limita e centraliza o conteúdo para que uma linha de texto não fique larga
/// demais em tablets, mantendo o comportamento normal em celulares.
class ConteudoCentralizado extends StatelessWidget {
  const ConteudoCentralizado({
    required this.child,
    this.larguraMaxima = 760,
    super.key,
  });

  final Widget child;
  final double larguraMaxima;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: child,
      ),
    );
  }
}

/// Distribui cartões em uma ou mais colunas conforme a largura disponível.
///
/// Usa [Wrap] em vez de `GridView` porque a altura dos cartões varia com o
/// conteúdo e com a escala de fonte do sistema; assim nada é cortado.
class GradeDeCartoes extends StatelessWidget {
  const GradeDeCartoes({
    required this.itens,
    this.larguraMinimaDoCartao = 340,
    this.espacamento = 12,
    super.key,
  });

  final List<Widget> itens;
  final double larguraMinimaDoCartao;
  final double espacamento;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final disponivel = constraints.maxWidth;
        final colunas = disponivel.isFinite
            ? (disponivel / larguraMinimaDoCartao).floor().clamp(1, 3)
            : 1;
        if (colunas <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var indice = 0; indice < itens.length; indice++) ...[
                itens[indice],
                if (indice != itens.length - 1) SizedBox(height: espacamento),
              ],
            ],
          );
        }
        final largura =
            (disponivel - espacamento * (colunas - 1)) / colunas -
            0.01; // evita quebra por arredondamento
        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: [
            for (final item in itens) SizedBox(width: largura, child: item),
          ],
        );
      },
    );
  }
}

/// Ocupa a altura disponível mantendo o gesto de puxar para atualizar.
///
/// Substitui alturas fixas calculadas a partir da tela, que quebravam em
/// paisagem e em telas pequenas.
class AreaVaziaRolavel extends StatelessWidget {
  const AreaVaziaRolavel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}
