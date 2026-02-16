import 'package:flutter/material.dart';
import 'package:konta_app/widgets/skeleton_container.dart';
import 'package:konta_app/widgets/shimmer_loading.dart';

class FinancingsSkeletonView extends StatelessWidget {
  const FinancingsSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonContainer(width: 180, height: 28),
                SkeletonContainer(width: 40, height: 40, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Scroll (Chips)
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const SkeletonContainer(width: 160, height: 90, borderRadius: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Título Lista
            const SkeletonContainer(width: 120, height: 20),
            const SizedBox(height: 12),

            // Lista de Cards
            ...List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SkeletonContainer(
                width: double.infinity,
                height: 140, // Altura estimada do card
                borderRadius: 16,
              ),
            )),
          ],
        ),
      ),
    );
  }
}