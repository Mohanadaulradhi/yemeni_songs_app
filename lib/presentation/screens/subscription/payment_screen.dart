import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/cubits/subscription/subscription_cubit.dart';
import '../../../domain/cubits/subscription/subscription_state.dart';

class PaymentScreen extends StatelessWidget {
  final String planId;

  const PaymentScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SubscriptionCubit>().state;
    final plan = state.plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => state.plans.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('الدفع')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'ملخص الطلب',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الخطة'),
                        Text(plan.name),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المدة'),
                        Text('${plan.durationDays} يوم'),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المبلغ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${plan.price.toStringAsFixed(0)} ريال',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                              fontSize: 18,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'اختر طريقة الدفع',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            _PaymentMethodCard(
              name: 'كريمي',
              icon: Icons.account_balance,
              description: 'تحويل عبر كريمي',
              isSelected: true,
              onTap: () {},
            ),
            _PaymentMethodCard(
              name: 'جيب',
              icon: Icons.phone_android,
              description: 'جيب موبايل',
              isSelected: false,
              onTap: () {},
            ),
            _PaymentMethodCard(
              name: 'جوالي',
              icon: Icons.phone_iphone,
              description: 'محفظة جوالي',
              isSelected: false,
              onTap: () {},
            ),
            _PaymentMethodCard(
              name: 'حاسب',
              icon: Icons.payment,
              description: 'بطاقة حاسب',
              isSelected: false,
              onTap: () {},
            ),
            SizedBox(height: 24),
            BlocConsumer<SubscriptionCubit, SubscriptionState>(
              listener: (context, state) {
                if (state.status == SubscriptionStatus.active) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تفعيل الاشتراك بنجاح!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                  context.go('/home');
                }

                if (state.status == SubscriptionStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'فشلت عملية الدفع'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == SubscriptionStatus.processing) {
                  return Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                      SizedBox(height: 16),
                      Text('جاري معالجة الدفع...'),
                    ],
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<SubscriptionCubit>().purchasePlan(plan);
                    },
                    child: Text('تأكيد الدفع - ${plan.price.toStringAsFixed(0)} ريال'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.name,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? AppTheme.primaryGreen : Colors.grey[200],
          child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
        ),
        title: Text(name),
        subtitle: Text(description),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.primaryGreen)
            : null,
        onTap: onTap,
      ),
    );
  }
}
