import 'package:flutter/material.dart';
import 'package:vental_go/core/theme/app_colors.dart';
import '../../data/models/location_country_data.dart';

/// Bottom sheet: first choose country, then choose city.
/// Returns the selected (country, city) pair or null if dismissed.
Future<({LocationCountry country, LocationCity city})?> showCountryCityPicker(
  BuildContext context,
) {
  return showModalBottomSheet<({LocationCountry country, LocationCity city})?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CountryCityPickerSheet(),
  );
}

class _CountryCityPickerSheet extends StatefulWidget {
  const _CountryCityPickerSheet();

  @override
  State<_CountryCityPickerSheet> createState() => _CountryCityPickerSheetState();
}

class _CountryCityPickerSheetState extends State<_CountryCityPickerSheet> {
  LocationCountry? _selectedCountry;
  String _searchCity = '';

  List<LocationCity> get _filteredCities {
    if (_selectedCountry == null) return [];
    final q = _searchCity.toLowerCase();
    return _selectedCountry!.cities
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isCountryStep = _selectedCountry == null;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            // Title + back
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  if (!isCountryStep)
                    GestureDetector(
                      onTap: () => setState(() => _selectedCountry = null),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
                    ),
                  if (!isCountryStep) const SizedBox(width: 8),
                  Text(
                    isCountryStep ? 'Выберите страну' : _selectedCountry!.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            // City search
            if (!isCountryStep) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Поиск города',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchCity = v),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                itemCount: isCountryStep
                    ? SupportedLocations.countries.length
                    : _filteredCities.length,
                itemBuilder: (context, index) {
                  if (isCountryStep) {
                    final country = SupportedLocations.countries[index];
                    return _CountryTile(
                      country: country,
                      onTap: () => setState(() => _selectedCountry = country),
                    );
                  } else {
                    final city = _filteredCities[index];
                    return _CityTile(
                      city: city,
                      onTap: () => Navigator.pop(
                        context,
                        (country: _selectedCountry!, city: city),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CountryTile extends StatelessWidget {
  final LocationCountry country;
  final VoidCallback onTap;

  const _CountryTile({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
      title: Text(country.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _CityTile extends StatelessWidget {
  final LocationCity city;
  final VoidCallback onTap;

  const _CityTile({required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 22),
      title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
    );
  }
}
