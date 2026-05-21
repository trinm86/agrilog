// CheckboxFormField Widget tùy chỉnh
import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    required Widget title,
    super.validator, bool? initialValue,
  }) : super( initialValue: initialValue ?? false, builder: (FormFieldState<bool> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: state.value,
            title: title,
            contentPadding: const EdgeInsets.all(0),
            onChanged: (bool? value) {
              state.didChange(value);
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (state.hasError)
            Text(
              state.errorText ?? '',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      );
    },
  );
}