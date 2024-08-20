import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfilePictureModal extends StatelessWidget {
  final String? title;
  final List<ActionItem> actions;

  ChangeProfilePictureModal({
    this.title,
    required this.actions,
  });

  Future<void> _executeAction(
      BuildContext context, ActionItem actionItem) async {
    final picker = ImagePicker();
    final ImageSource source = actionItem.source == ActionSource.gallery
        ? ImageSource.gallery
        : ImageSource.camera;

    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen')),
      );
      return;
    }

    final imageFile = pickedFile.path;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await actionItem.onImageSelected(imageFile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Seleccione una acción'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((actionItem) {
          return ListTile(
            leading:
                Icon(actionItem.icon, color: Theme.of(context).primaryColor),
            title: Text(actionItem.text),
            onTap: () => _executeAction(context, actionItem),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}

class ActionItem {
  final IconData icon;
  final String text;
  final ActionSource source;
  final Future<void> Function(String) onImageSelected;

  ActionItem({
    required this.icon,
    required this.text,
    required this.source,
    required this.onImageSelected,
  });
}

enum ActionSource {
  gallery,
  camera,
}
