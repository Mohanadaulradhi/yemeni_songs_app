import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/cubits/subscription/subscription_cubit.dart';
import '../../../domain/cubits/subscription/subscription_state.dart';
import '../../../data/models/subscription_model.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطط الاشتراك')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state.status == SubscriptionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.plans.isEmpty) {
            return const Center(child: Text('لا توجد خطط متاحة'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.plans.length,
            itemBuilder: (context, index) {
              final plan = state.plans[index];
              return _PlanCard(plan: plan);
            },
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isFree = plan.tier == SubscriptionTier.free;
    final isPremium = plan.tier == SubscriptionTier.premium;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: isPremium
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.05),
                    AppTheme.accentGold.withValues(alpha: 0.05),
                  ],
                ),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'الأكثر طلباً',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  if (isPremium) SizedBox(width: 8),
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(plan.description),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.price == 0 ? 'مجاني' : '${plan.price.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  if (plan.durationDays > 0) ...[
                    SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ ${plan.durationDays} يوم',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 16),
              ...plan.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 20, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              )),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isFree
                      ? null
                      : () => context.go('/payment/${plan.id}'),
                  child: Text(isFree ? 'الخطة الحالية' : 'اشتراك'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
