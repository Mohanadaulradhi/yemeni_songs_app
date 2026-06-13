import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/cubits/auth/auth_cubit.dart';
import '../../../domain/cubits/auth/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.user == null) return SizedBox.shrink();

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      state.user!.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(state.user!.name),
                  subtitle: Text(state.user!.email),
                  trailing: state.user!.isPremium
                      ? Chip(
                          label: Text('مشترك',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: AppTheme.accentGold,
                        )
                      : TextButton(
                          onPressed: () => context.go('/plans'),
                          child: Text('اشترك الآن'),
                        ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.card_giftcard_outlined),
                  title: Text('خطط الاشتراك'),
                  trailing: Icon(Icons.chevron_left),
                  onTap: () => context.go('/plans'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('حول التطبيق'),
                  subtitle: Text('الإصدار 1.0.0'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                    icon: Icon(Icons.logout, color: AppTheme.primaryRed),
                    label: Text('تسجيل الخروج',
                        style: TextStyle(color: AppTheme.primaryRed)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryRed),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
