import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/legal/legal_links.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentDriverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(currentDriverProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: authState.when(
        data: (driver) {
          if (driver == null) return const SizedBox();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                driver.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                driver.email,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: const Text('Vehículo'),
                subtitle: Text('${driver.vehicleType} - ${driver.licensePlate ?? "Sin placa"}'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Teléfono'),
                subtitle: Text(driver.phone),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Términos y condiciones'),
                onTap: () => LegalLinks.open(context, LegalLinks.terms),
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Política de privacidad'),
                onTap: () => LegalLinks.open(context, LegalLinks.privacy),
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Permisos del dispositivo'),
                subtitle: const Text('Ubicación y notificaciones'),
                onTap: () => openAppSettings(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => const Center(child: Text('Error al cargar el perfil')),
      ),
    );
  }
}
