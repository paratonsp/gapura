import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:gapura/controllers/user_controller.dart';
import 'package:gapura/screens/user/user_add_modal.dart';
import 'package:gapura/screens/user/user_edit_modal.dart';

import 'package:gapura/constants.dart';
import 'package:gapura/models/user_model.dart';
import 'package:gapura/screens/components/header.dart';

class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _StateUserScreen();
}

class _StateUserScreen extends State<UserScreen> {
  List<UserModel> _listUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userList();
  }

  userList() async {
    await ListUserController.load().then((value) {
      setState(() {
        _listUser = value;
        isLoading = false;
      });
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(titlePage: "Manajemen Pengguna"),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      subHeader(context),
                      (isLoading)
                          ? Center(
                              child: LinearProgressIndicator(),
                            )
                          : table(context),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  subHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // <-- Radius
                ),
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: defaultPadding,
                ),
              ),
              icon: Icon(Icons.add),
              label: Text("Tambah"),
              onPressed: () async {
                await Navigator.of(context)
                    .push(
                  PageRouteBuilder(
                    barrierDismissible: true,
                    barrierColor: Colors.black.withOpacity(0.5),
                    transitionDuration: Duration(milliseconds: 300),
                    opaque: false,
                    pageBuilder: (_, __, ___) => UserAddModal(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: begin, end: end);
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      );

                      return SlideTransition(
                        position: tween.animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                )
                    .then((value) {
                  setState(() {
                    userList();
                  });
                });
              },
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
      ],
    );
  }

  table(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: fontColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
        color: greyColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "List Pengguna",
            style: TextStyle(fontSize: 16, color: fontColor),
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable2(
              border: TableBorder(
                  horizontalInside: BorderSide(color: fontColor, width: 1)),
              bottomMargin: 10,
              columnSpacing: defaultPadding,
              minWidth: 600,
              columns: [
                DataColumn(
                  label: Text("Nama Lengkap"),
                ),
                DataColumn(
                  label: Text("Nama User"),
                ),
                DataColumn(
                  label: Text("Surel"),
                ),
                DataColumn(
                  label: Text("Aksi"),
                ),
              ],
              rows: List.generate(
                _listUser.length,
                (index) => recentFileDataRow(_listUser[index], context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow recentFileDataRow(UserModel data, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(Text((data.fullname == null) ? "" : data.fullname)),
        DataCell(Text((data.username == null) ? "" : data.username)),
        DataCell(Text((data.email == null) ? "" : data.email)),
        DataCell(
          Text("Ubah"),
          onTap: (() {
            navigateModalEdit(context, data.id.toString());
          }),
        )
      ],
    );
  }

  navigateModalEdit(BuildContext context, String dataid) async {
    await Navigator.of(context)
        .push(
      PageRouteBuilder(
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 300),
        opaque: false,
        pageBuilder: (_, __, ___) => UserEditModal(user_id: dataid),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    )
        .then((value) {
      setState(() {
        userList();
      });
    });
  }
}
