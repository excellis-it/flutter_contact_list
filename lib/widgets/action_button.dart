import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final bool isSelected;
  final Function() onRemove;
  final Function() onSelect;

  ActionButton({this.isSelected, this.onRemove, this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return RaisedButton(
        color: Colors.white,
        elevation: 0,
        child: Text(
          'Remove',
          style: TextStyle(color: Colors.redAccent),
        ),
        onPressed: onRemove,
      );
    }

    return RaisedButton(
      color: Colors.white,
      elevation: 0,
      child: Text(
        'Select',
        style: TextStyle(color: Colors.blueAccent),
      ),
      onPressed: onSelect,
    );
  }
}
