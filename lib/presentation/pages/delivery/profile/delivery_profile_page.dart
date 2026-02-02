import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasty_go/presentation/pages/delivery/layout/delivery_layout.dart';
import 'package:tasty_go/presentation/pages/delivery/profile/delivery_profile_controller.dart';

class DeliveryProfilePage extends GetView<DeliveryProfileController> {
  const DeliveryProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeliveryLayout(
      title: 'My Profile',
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userData;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(theme, user),
              const SizedBox(height: 32),
              _buildInfoSection(theme, 'Personal Information', [
                _buildInfoTile(Icons.person_outline, 'Full Name', user['displayName'] ?? 'N/A'),
                _buildInfoTile(Icons.email_outlined, 'Email', user['email'] ?? 'N/A'),
                _buildInfoTile(Icons.phone_outlined, 'Phone', user['phone'] ?? '+91 98765 43210'),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection(theme, 'Vehicle Details', [
                _buildInfoTile(Icons.directions_bike, 'Vehicle Type', 'Motorcycle'),
                _buildInfoTile(Icons.numbers, 'Plate Number', 'KA 01 XY 1234'),
              ]),
              const SizedBox(height: 32),
              _buildActionButtons(theme),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, Map<String, dynamic> user) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['displayName'] ?? 'Delivery Partner',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Verified Partner',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Help & Support'),
          ),
        ),
      ],
    );
  }
}
