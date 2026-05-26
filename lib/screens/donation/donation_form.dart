import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/donation_service.dart';
import '../../theme/app_theme.dart';

class DonationForm extends StatefulWidget {
  final String programId;

  const DonationForm({super.key, required this.programId});

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();

  final DonationService _donationService = DonationService();

  bool _isLoading = false;
  String _paymentMethod = 'card'; // Default payment method

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Utilisateur non authentifié.');
        }

        final programSnapshot = await FirebaseFirestore.instance
            .collection('programs')
            .doc(widget.programId)
            .get();
        final programData = programSnapshot.data() ?? {};

        final programTitle = programData['title'] ?? 'Programme';
        final ongId = programData['ongId'] ?? '';
        final ongName = programData['ongName'] ?? 'ONG';

        final donorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final donorName = donorDoc.data()?['name'] ?? 'Donateur';

        final amount = double.parse(_amountController.text);
        await _donationService.makeDonation(
          programId: widget.programId,
          programTitle: programTitle,
          ongId: ongId,
          ongName: ongName,
          donorName: donorName,
          amount: amount,
          paymentMethod: _paymentMethod,
          message: _messageController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Don en attente de confirmation par l\'ONG.'),
            backgroundColor: AppTheme.gold,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Le don n\'a pas pu etre enregistre : $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Donation'),
        backgroundColor: AppTheme.gold,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.goldGradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Message (Optional)',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                    DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
                    DropdownMenuItem(
                      value: 'bank',
                      child: Text('Bank Transfer'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('Donate', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
