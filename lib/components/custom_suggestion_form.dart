import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CustomSuggestionForm extends StatelessWidget {
  const CustomSuggestionForm({super.key, this.controller, this.itemBuilder, this.onSelected, this.suggestionsCallback, this.prefixIcon, this.hintText, this.labelText});

  final controller;
  final itemBuilder;
  final onSelected;
  final suggestionsCallback;
  final prefixIcon;
  final hintText;
  final labelText;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField(
        controller: this.controller,
        itemBuilder: this.itemBuilder,
        onSelected: this.onSelected,
        suggestionsCallback: this.suggestionsCallback,
    );
  }
}
