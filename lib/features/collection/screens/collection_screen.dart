import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/features/collection/cubit/collection_cubit.dart';
import 'package:promoter_app/features/collection/models/collection_model.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch collections when the screen is initialized
    context.read<CollectionCubit>().fetchCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      body: BlocConsumer<CollectionCubit, CollectionState>(
        listener: (context, state) {
          if (state is CollectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
          if (state is CollectionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Collection created successfully!')),
            );
          }
        },
        builder: (context, state) {
          if (state is CollectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CollectionLoaded) {
            if (state.collections.isEmpty) {
              return const Center(child: Text('No collections found.'));
            }
            return ListView.builder(
              itemCount: state.collections.length,
              itemBuilder: (context, index) {
                final collection = state.collections[index];
                return ListTile(
                  title: Text(collection.clientName),
                  subtitle: Text(
                      'Amount: ${collection.amount} - Method: ${collection.paymentMethod}'),
                  trailing: Text(collection.createdAt
                      .substring(0, 10)), // Display date part
                );
              },
            );
          }
          return const Center(
              child: Text('Press button to fetch collections.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement navigation to a form to create a new collection
          // For now, we can trigger a test creation
          // context.read<CollectionCubit>().createCollection(
          //       clientId: 1, // Example client ID
          //       amount: 100.0, // Example amount
          //       paymentMethod: 'Cash', // Example payment method
          //       notes: 'Test collection',
          //     );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Navigate to Create Collection Screen (TODO)')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
