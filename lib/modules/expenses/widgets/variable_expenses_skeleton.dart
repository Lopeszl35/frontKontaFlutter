import 'package:flutter/material.dart';
import 'package:konta_app/widgets/skeleton_container.dart';
import 'package:konta_app/widgets/shimmer_loading.dart';

class VariableExpensesSkeleton extends StatelessWidget {
  const VariableExpensesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo do Mês (Card Grande)
            const SkeletonContainer(width: double.infinity, height: 160, borderRadius: 24),
            const SizedBox(height: 32),

            // Header de Ações
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonContainer(width: 150, height: 24),
                SkeletonContainer(width: 100, height: 36, borderRadius: 18),
              ],
            ),
            const SizedBox(height: 24),

            // Grid de Categorias (Simulando 4 itens)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Ajuste conforme seu card real
              ),
              itemCount: 4,
              itemBuilder: (_, __) => const SkeletonContainer(
                height: double.infinity, // Preenche o grid
                borderRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}