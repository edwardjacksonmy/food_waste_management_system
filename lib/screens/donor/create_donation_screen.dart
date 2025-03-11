// create_donation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../providers/donation_provider.dart';
import '../services/location_service.dart';
import '../widgets/map_widget.dart';

class CreateDonationScreen extends StatefulWidget {
  @override
  _CreateDonationScreenState createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();

  String _title = '';
  String _description = '';
  int? _foodTypeId;
  double _quantity = 0;
  String _quantityUnit = 'portions';
  DateTime _expirationDate = DateTime.now().add(Duration(days: 1));
  DateTime _pickupStartTime = DateTime.now();
  DateTime _pickupEndTime = DateTime.now().add(Duration(hours: 4));
  bool _isPerishable = true;
  bool _useCurrentLocation = true;
  String _pickupAddress = '';
  double? _pickupLatitude;
  double? _pickupLongitude;
  bool _isLoading = false;
  bool _isLoadingLocation = false;

  List<Map<String, dynamic>> _foodTypeOptions = [
    {'id': 1, 'name': 'Fresh Produce'},
    {'id': 2, 'name': 'Dairy'},
    {'id': 3, 'name': 'Prepared Meals'},
    {'id': 4, 'name': 'Canned Goods'},
    {'id': 5, 'name': 'Bakery Items'},
  ];

  List<String> _unitOptions = [
    'portions',
    'kg',
    'lb',
    'packages',
    'items',
    'boxes',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (_useCurrentLocation) {
      setState(() {
        _isLoadingLocation = true;
      });

      try {
        final position = await _locationService.getCurrentLocation();
        setState(() {
          _pickupLatitude = position.latitude;
          _pickupLongitude = position.longitude;
          _isLoadingLocation = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingLocation = false;
          _useCurrentLocation = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_pickupLatitude == null || _pickupLongitude == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please set a pickup location')));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final donation = FoodDonation(
          donorId:
              Provider.of<DonationProvider>(
                context,
                listen: false,
              ).currentUserId!,
          title: _title,
          description: _description,
          foodType: _foodTypeId,
          quantity: _quantity,
          quantityUnit: _quantityUnit,
          expirationDate: _expirationDate,
          pickupAddress: _pickupAddress,
          pickupLatitude: _pickupLatitude,
          pickupLongitude: _pickupLongitude,
          isDifferentLocation: !_useCurrentLocation,
          pickupStartTime: _pickupStartTime,
          pickupEndTime: _pickupEndTime,
          isPerishable: _isPerishable,
        );

        await Provider.of<DonationProvider>(
          context,
          listen: false,
        ).createDonation(donation);

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating donation: $e')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Food Donation')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      'Donation Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g., Leftover Catering Food',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the food in detail',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Food Type',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _foodTypeOptions.map((type) {
                            return DropdownMenuItem(
                              value: type['id'],
                              child: Text(type['name']),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _foodTypeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a food type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _quantity = double.parse(value!);
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            value: _quantityUnit,
                            items:
                                _unitOptions.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _quantityUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Pickup Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Use Current Location'),
                      value: _useCurrentLocation,
                      onChanged: (value) {
                        setState(() {
                          _useCurrentLocation = value;
                          if (value) {
                            _getCurrentLocation();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (!_useCurrentLocation)
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Pickup Address',
                          hintText: 'Enter full address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_useCurrentLocation &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter an address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _pickupAddress = value ?? '';
                        },
                      ),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child:
                          _isLoadingLocation
                              ? Center(child: CircularProgressIndicator())
                              : (_pickupLatitude == null ||
                                  _pickupLongitude == null)
                              ? Center(child: Text('Location not available'))
                              : MapWidget(
                                latitude: _pickupLatitude!,
                                longitude: _pickupLongitude!,
                                onLocationChanged: (lat, lng) {
                                  setState(() {
                                    _pickupLatitude = lat;
                                    _pickupLongitude = lng;
                                    _useCurrentLocation = false;
                                  });
                                },
                              ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Date & Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Expiration Date'),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(_expirationDate),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() {
                            _expirationDate = date;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Pickup Time Window Start'),
                      subtitle: Text(
                        DateFormat(
                          'MMM dd, yyyy – hh:mm a',
                        ).format(_pickupStartTime),
                      ),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _pickupStartTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 7)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              _pickupStartTime,
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              _pickupStartTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              // Ensure end time is after start time
                              if (_pickupEndTime.isBefore(_pickupStartTime)) {
                                _pickupEndTime = _pickupStartTime.add(
                                  Duration(hours: 2),
                                );
                              }
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Pickup Time Window End'),
                      subtitle: Text(
                        DateFormat(
                          'MMM dd, yyyy – hh:mm a',
                        ).format(_pickupEndTime),
                      ),
                      trailing: Icon(Icons.access_time),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _pickupEndTime,
                          firstDate: _pickupStartTime,
                          lastDate: _pickupStartTime.add(Duration(days: 7)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_pickupEndTime),
                          );
                          if (time != null) {
                            setState(() {
                              _pickupEndTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Perishable Food'),
                      subtitle: Text(
                        'Requires refrigeration or special handling',
                      ),
                      value: _isPerishable,
                      onChanged: (value) {
                        setState(() {
                          _isPerishable = value;
                        });
                      },
                    ),
                    SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitDonation,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Create Donation'),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
