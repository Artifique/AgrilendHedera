import 'package:flutter/material.dart';

class AgentMainScreen extends StatelessWidget {
  const AgentMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Agent'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue Agent Local',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const Icon(Icons.assignment_turned_in, color: Colors.blue),
                title: const Text('Vérification KYC'),
                subtitle: const Text('Validez les bénéficiaires et documents.'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Encaissement'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600]),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.money_off),
                  label: const Text('Décaissement'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600]),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Profil'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600]),
                  onPressed: () {
                    Navigator.pushNamed(context, '/agent/profile');
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Suivi terrain'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Informations & Conseils'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
