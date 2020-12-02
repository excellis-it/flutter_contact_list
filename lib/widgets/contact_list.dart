import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact_list/models/simplified_contact.dart';
import 'package:permission_handler/permission_handler.dart';

import 'action_button.dart';

class ContactList extends StatefulWidget {
  final Function(List<SimplifiedContact>, List<int>) onDone;
  final List<int> selectedContactIndices;

  ContactList({
    Key key,
    this.onDone,
    this.selectedContactIndices,
  }) : super(key: key);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<SimplifiedContact> contactList;
  List<int> selectedIndices = [];

  @override
  void initState() {
    super.initState();

    selectedIndices = widget.selectedContactIndices;
    getContacts();
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    final PermissionStatus granted = PermissionStatus.granted;
    final PermissionStatus denied = PermissionStatus.denied;
    final PermissionStatus undetermined = PermissionStatus.undetermined;

    if (permission != granted && permission != denied) {
      final permissionStatusMap = await [Permission.contacts].request();

      return permissionStatusMap[Permission.contacts] ?? undetermined;
    } else {
      return permission;
    }
  }

  Future<void> getContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();

    if (permissionStatus == PermissionStatus.granted) {
      int index = 0;
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      // final List<SimplifiedContact> tempContacts = [];

      setState(() {
        contactList = [];
        contacts.forEach((contact) {
          contact.phones.forEach((phoneData) {
            contactList.add(SimplifiedContact(
              index,
              contact.displayName,
              phoneData.value,
            ));

            index++;
          });
        });
      });

      // setState(() {
      //   contactList = tempContacts;
      // });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Permissions error'),
          content: Text('Grant contacts permission to see the contacts'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  void onContactSelect(int index) {
    setState(() {
      selectedIndices.add(index);
    });
  }

  void onContactRemove(int index) {
    int elementIndex = selectedIndices.indexOf(index);

    if (elementIndex > -1) {
      setState(() {
        selectedIndices.removeAt(elementIndex);
      });
    }
  }

  void selectAll(BuildContext context) {
    List<int> indexList = [];
    int index = 0;

    contactList.forEach((element) {
      indexList.add(index++);
    });

    setState(() {
      selectedIndices = indexList;
    });
  }

  void unselectAll(BuildContext context) {
    setState(() {
      selectedIndices = [];
    });
  }

  void onDone(BuildContext context) {
    int index = 0;
    List<SimplifiedContact> tempSelected = [];

    if (contactList != null) {
      contactList.forEach((element) {
        if (selectedIndices.indexOf(index++) > -1) {
          tempSelected.add(element);
        }
      });

      widget.onDone(tempSelected, selectedIndices);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      return Flexible(
        child: Center(
          child: const CircularProgressIndicator(),
        ),
      );
    }

    return Flexible(
      child: Column(
        children: [
          Flexible(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: contactList?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                SimplifiedContact contact = contactList?.elementAt(index);

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 18,
                      ),
                      title: Text(contact.name ?? ''),
                      subtitle: Text(contact.phone),
                      trailing: new ActionButton(
                        isSelected: selectedIndices.indexOf(index) > -1,
                        onRemove: () {
                          onContactRemove(index);
                        },
                        onSelect: () {
                          onContactSelect(index);
                        },
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
            child: contactList != null &&
                    selectedIndices.length == contactList.length
                ? ElevatedButton(
                    child: Text('Unselect All'),
                    onPressed: () {
                      unselectAll(context);
                    },
                  )
                : ElevatedButton(
                    child: Text('Select All'),
                    onPressed: () {
                      selectAll(context);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
