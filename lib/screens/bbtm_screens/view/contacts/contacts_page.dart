import 'package:bbtml_new/common/common_services.dart';
import 'package:bbtml_new/main.dart';
import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart' show Contact;

import '../../controllers/storage.dart';
import '../../models/contacts.dart';
import '../../widgets/contact/contact_card.dart';
import 'select_access.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();
  final StorageController _storageController = StorageController();

  Future<List<ContactsModel>> fetchContacts() async {
    return _storageController.readContacts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add_alt,
              color: Theme.of(context).appColors.background),
          onPressed: () async {
            Contact? contact = await _contactPicker.selectContact();
            if (contact != null) {
              Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                      builder: (context) => AccessRequestPage(
                            name: contact.fullName!,
                          )));
            } else {
              // TODO: Add a toast tp show its not possible to open contacts
            }
          }),
      appBar: AppBar(
        title: const Text('CONTACTS'),
      ),
      body: FutureBuilder(
          future: fetchContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                  color: Theme.of(context).appColors.buttonBackground);
            }
            if (snapshot.hasError) {
              return Center(child: Text("ERROR: ${snapshot.error}"));
            }
            if (snapshot.data != null && snapshot.data!.isEmpty) {
              return CommonServices.noDataWidget();
            }
            return ListView.separated(
              padding: EdgeInsets.all(screenWidth * 0.06),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ContactsCard(
                  contactsDetails: snapshot.data![index],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(
                  height: 16,
                );
              },
            );
          }),
    );
  }
}
