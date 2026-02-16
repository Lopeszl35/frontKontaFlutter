import 'package:flutter/material.dart';
import 'package:konta_app/widgets/skeleton_container.dart';
import 'package:konta_app/widgets/shimmer_loading.dart'; // <--- Importe o novo widget

class DashboardSkeletonView extends StatelessWidget {
  const DashboardSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos tudo no ShimmerLoading para sincronizar a onda de luz
    return ShimmerLoading(
      isLoading: true,
      // Como seu SkeletonContainer original usa opacity 0.05, 
      // aqui usamos cores que contrastem levemente em cima do fundo escuro
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.2), 
      
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                 SkeletonContainer(width: 48, height: 48, borderRadius: 24),
                 SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonContainer(width: 120, height: 14),
                    SizedBox(height: 8),
                    SkeletonContainer(width: 80, height: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Card Principal
            const SkeletonContainer(
              width: double.infinity,
              height: 140,
              borderRadius: 16,
            ),
            const SizedBox(height: 24),

            // Lista
            ...List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SkeletonContainer(width: 40, height: 40, borderRadius: 8),
                      SizedBox(width: 12),
                      SkeletonContainer(width: 100, height: 14),
                    ],
                  ),
                  SkeletonContainer(width: 60, height: 14),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}