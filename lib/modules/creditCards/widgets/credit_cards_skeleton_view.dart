import 'package:flutter/material.dart';
import 'package:konta_app/widgets/skeleton_container.dart';
import 'package:konta_app/widgets/shimmer_loading.dart';

class CreditCardsSkeletonView extends StatelessWidget {
  const CreditCardsSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              SkeletonContainer(width: 180, height: 28), // Título
              SkeletonContainer(width: 40, height: 40, borderRadius: 20), // Botão Voltar
            ],
          ),
          const SizedBox(height: 20),

          // Cards de Resumo (Topo)
          const Row(
            children:  [
              Expanded(child: SkeletonContainer(height: 90, borderRadius: 16)),
              SizedBox(width: 12),
              Expanded(child: SkeletonContainer(height: 90, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 24),

          // Título da Lista
          const SkeletonContainer(width: 120, height: 20),
          const SizedBox(height: 12),

          // Lista de Cartões (Simulando 3)
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SkeletonContainer(
              width: double.infinity,
              height: 200, // Altura aproximada de um cartão de crédito
              borderRadius: 16,
            ),
          )),
        ],
      ),
    );
  }
}