import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:vental_go/core/theme/app_colors.dart';
import 'package:vental_go/core/localization/app_localizations.dart';
import 'package:vental_go/core/geocoding/geocoding_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final IconData icon;
  final String hintKey;
  final LatLng? biasPosition;
  final String? cityName;
  final String? initialValue;
  final void Function(String address, LatLng coordinates) onAddressSelected;

  const AddressAutocompleteField({
    super.key,
    required this.icon,
    required this.hintKey,
    required this.onAddressSelected,
    this.biasPosition,
    this.cityName,
    this.initialValue,
    this.externalLoading = false,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<AddressSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _loading = false;
  final bool externalLoading;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(AddressAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем текст, если адрес пришёл извне (например, с перетаскивания
    // карты центр-пином), но только если пользователь сейчас не печатает сам.
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        !_focusNode.hasFocus) {
      _controller.text = widget.initialValue!;
      setState(() => _suggestions = []);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 3) {
        setState(() => _suggestions = []);
        return;
      }
      setState(() => _loading = true);
      final results = await GeocodingService.search(value, biasPosition: widget.biasPosition, cityName: widget.cityName);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loading = false;
      });
    });
  }

  void _select(AddressSuggestion suggestion) {
    _controller.text = suggestion.displayName;
    setState(() => _suggestions = []);
    widget.onAddressSelected(suggestion.displayName, suggestion.position);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  decoration: InputDecoration(hintText: context.l10n.t(widget.hintKey), border: InputBorder.none, isDense: true),
                ),
              ),
              if (_loading || widget.externalLoading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                  title: Text(suggestion.displayName, style: const TextStyle(fontSize: 13)),
                  onTap: () => _select(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}