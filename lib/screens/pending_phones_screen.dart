import 'package:flutter/material.dart';
import 'package:pphonedex/models/phone_model.dart';
import 'package:pphonedex/services/phone_service.dart';

class PendingPhonesScreen extends StatelessWidget {
  const PendingPhonesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneService = PhoneService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Celulares Pendentes'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<List<Phone>>(
        stream: phoneService.getPendingPhones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum celular pendente de aprovação.'));
          }

          final pendingPhones = snapshot.data!;

          return ListView.builder(
            itemCount: pendingPhones.length,
            itemBuilder: (context, index) {
              final phone = pendingPhones[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(phone.imageUrl, width: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.phone)),
                  title: Text(phone.name),
                  subtitle: Text('Enviado por: ${phone.userId}'), // Você pode buscar o nome do usuário aqui se quiser
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await phoneService.approvePhone(phone.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${phone.name} aprovado!'))
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await phoneService.deletePhone(phone.id);
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${phone.name} rejeitado.'))
                          );
                        },
                      ),

                      IconButton(onPressed: (){Navigator.pushNamed(context, '/details',arguments: {'docId': phone.id});}, icon:const Icon(Icons.info, color: Colors.blue),
                  )],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}