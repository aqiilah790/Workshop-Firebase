import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Future<void> addNote() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) return;

    await firestore
        .collection('notes')
        .doc(user.uid)
        .collection('user_notes')
        .add({
      'title': titleController.text,
      'content': contentController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    titleController.clear();
    contentController.clear();
  }

  Future<void> deleteNote(String docId) async {
    await firestore
        .collection('notes')
        .doc(user.uid)
        .collection('user_notes')
        .doc(docId)
        .delete();
  }

  Future<void> editNote(
      String docId, String oldTitle, String oldContent) async {
    titleController.text = oldTitle;
    contentController.text = oldContent;

    await showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Catatan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul')),
                TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Isi')),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal')),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setState(() => isSaving = true);
                        await firestore
                            .collection('notes')
                            .doc(user.uid)
                            .collection('user_notes')
                            .doc(docId)
                            .update({
                          'title': titleController.text,
                          'content': contentController.text,
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );

    titleController.clear();
    contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final notesRef = firestore
        .collection('notes')
        .doc(user.uid)
        .collection('user_notes')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return const Center(child: Text('Belum ada catatan.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final doc = notes[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['content'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () =>
                          editNote(doc.id, data['title'], data['content']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteNote(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) {
              bool isSaving = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Tambah Catatan'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Judul')),
                        TextField(
                            controller: contentController,
                            decoration:
                                const InputDecoration(labelText: 'Isi')),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setState(() => isSaving = true);
                                await addNote();

                                if (mounted) Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Catatan berhasil ditambahkan!'),
                                  ),
                                );
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Simpan'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
