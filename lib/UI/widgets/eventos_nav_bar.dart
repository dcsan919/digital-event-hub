import 'package:flutter/material.dart';

class NabTop extends StatefulWidget {
  final ValueNotifier<int> selectedIndexNotifier;

  const NabTop({required this.selectedIndexNotifier, Key? key})
      : super(key: key);

  @override
  State<NabTop> createState() => _NabTopState();
}

class _NabTopState extends State<NabTop> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextButton(0, 'Detalles'),
            const SizedBox(width: 20),
            _buildTextButton(1, 'Comentarios'),
          ],
        ),
        const Divider(
          color: Colors.black,
          thickness: 0.3,
          indent: 20,
          endIndent: 20,
        )
      ],
    );
  }

  Widget _buildTextButton(int index, String text) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        bool isSelected = selectedIndex == index;
        return Column(
          children: [
            TextButton(
              onPressed: () {
                widget.selectedIndexNotifier.value = index;
              },
              style: ButtonStyle(
                backgroundColor: isSelected
                    ? WidgetStateProperty.all(Colors.black)
                    : WidgetStateProperty.all(Colors.transparent),
                overlayColor: isSelected
                    ? WidgetStateProperty.all(Colors.transparent)
                    : WidgetStateProperty.all(Color.fromARGB(100, 217, 0, 255)),
                splashFactory: NoSplash.splashFactory,
                padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: isSelected ? Colors.white : Colors.black,
                    width: 0.5,
                  ),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
