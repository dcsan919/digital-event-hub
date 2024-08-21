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
        const Divider(
          color: Colors.white,
          thickness: 0.2,
          indent: 75,
          endIndent: 110,
        ),
        SizedBox(
          height: 3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextButton(0, 'Detalles'),
            const SizedBox(width: 20),
            _buildTextButton(1, 'Comentarios'),
          ],
        ),
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
                    ? WidgetStateProperty.all(Colors.transparent)
                    : WidgetStateProperty.all(Colors.transparent),
                overlayColor: isSelected
                    ? WidgetStateProperty.all(Colors.transparent)
                    : WidgetStateProperty.all(Color.fromARGB(100, 217, 0, 255)),
                splashFactory: NoSplash.splashFactory,
                padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 25, vertical: 10)),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: isSelected ? Colors.white : Colors.black,
                    width: 0.8,
                  ),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
