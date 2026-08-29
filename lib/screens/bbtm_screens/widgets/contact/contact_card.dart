import 'package:bbtml_new/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/contacts.dart';

class ContactsCard extends StatelessWidget {
  final ContactsModel contactsDetails;
  ContactsCard({
    required this.contactsDetails,
    super.key,
  });
  final StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .appColors
                  .textSecondary
                  .withValues(alpha: 0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(2, 2),
            ),
          ],
          color: Theme.of(context).appColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Contact Name : ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  contactsDetails.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Access Permission : ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Start and End Date : ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType.contains("Timed")
                      ? "${contactsDetails.startDateTime.day}/${contactsDetails.startDateTime.month}/${contactsDetails.startDateTime.year}-${contactsDetails.endDateTime.day}/${contactsDetails.endDateTime.month}/${contactsDetails.endDateTime.year}"
                      : "00-00",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Start and End Time : ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType.contains("Timed")
                      ? "${contactsDetails.startDateTime.hour}:${contactsDetails.startDateTime.minute}-${contactsDetails.endDateTime.hour}:${contactsDetails.endDateTime.minute}"
                      : "00:00-00:00",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).appColors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (cont) {
                            return AlertDialog(
                              title: const Text('BBT Switch'),
                              content:
                                  const Text('This will delete the Switch'),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    _storageController
                                        .deleteOneContact(contactsDetails);
                                    Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            const TabsPage(),
                                      ),
                                      (route) =>
                                          false, //if you want to disable back feature set to false
                                    );
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).appColors.textPrimary,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
