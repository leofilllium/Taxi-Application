import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../generated/app_localizations.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/profile/profile_cubit.dart';
import '../../../logic/profile/profile_state.dart';
import 'edit_profile_screen.dart';

/// Profile screen showing user information and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => ProfileCubit(context.read())..loadProfile(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            showAppSnackBar(context, state.message, isError: true);
          } else if (state is ProfileDeleted) {
            // Logout after account deletion
            context.read<AuthCubit>().logout();
          }
        },
        child: CupertinoPageScaffold(
          backgroundColor: AppColors.backgroundSecondary,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: AppColors.background.withOpacity(0.9),
            border: null,
            middle: Text(l10n.profile, style: AppStyles.headline),
            trailing: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      l10n.editProfile,
                      style: AppStyles.body.copyWith(color: AppColors.accentBlue),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => EditProfileScreen(profileData: state.profileData),
                        ),
                      );
                      if (result == true && context.mounted) {
                        context.read<ProfileCubit>().loadProfile();
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading ||
                    state is ProfileInitial ||
                    state is ProfileDeleting) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (state is ProfileError) {
                  return _buildErrorState(context, state.message);
                }

                if (state is ProfileLoaded || state is ProfileUpdated) {
                  final profileData = state is ProfileLoaded
                      ? state.profileData
                      : (state as ProfileUpdated).profileData;
                  return _buildProfileContent(context, profileData, l10n);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: AppStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            child: const Text('Retry'),
            onPressed: () => context.read<ProfileCubit>().retry(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Map<String, dynamic> user,
    AppLocalizations l10n,
  ) {
    final isDriver = user['driver'] != null;
    ImageProvider profileImage = const AssetImage('assets/images/logo.png');
    if (user['profileImageUrl'] != null) {
      profileImage = NetworkImage(user['profileImageUrl']);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Profile header
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: profileImage,
                backgroundColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                user['name'] ?? "Unknown",
                style: AppStyles.title2,
                textAlign: TextAlign.center,
              ),
              Text(
                isDriver ? l10n.userTypeDriver : l10n.userTypeClient,
                style: AppStyles.footnote.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Profile info card
          _buildInfoCard(
            context,
            [
              _buildInfoRow(CupertinoIcons.mail, l10n.emailLabel, user['email'] ?? ''),
              _buildInfoRow(CupertinoIcons.phone, l10n.phoneLabel, user['phone'] ?? ''),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          _buildActionCard(
            context,
            [
              _buildActionButton(
                context,
                CupertinoIcons.square_arrow_right,
                l10n.logout,
                AppColors.textPrimary,
                () => _confirmLogout(context, l10n),
              ),
              const Divider(height: 1),
              _buildActionButton(
                context,
                CupertinoIcons.delete,
                l10n.deleteAccount,
                AppColors.error,
                () => _confirmDeleteAccount(context, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppStyles.cardShadow],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.caption1),
                Text(value, style: AppStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppStyles.body.copyWith(color: color),
            ),
          ),
          Icon(CupertinoIcons.chevron_right, size: 16, color: color),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.logout),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AppLocalizations l10n) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.deleteAccountConfirmationTitle),
        content: Text(l10n.deleteAccountConfirmationMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.actionDelete),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileCubit>().deleteAccount();
            },
          ),
        ],
      ),
    );
  }
}
