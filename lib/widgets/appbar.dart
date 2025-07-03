import 'package:flutter/material.dart';
import 'package:theloanapp/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

PreferredSizeWidget? showAppBar(context,WidgetRef ref) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/logo.jpg"),
            radius: 16,
          ),
          SizedBox(width: 8),
          Text(
            "InstingLoan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    ),
    actions: [

      IconButton(
        icon: Icon(Icons.notifications_none, color: Colors.black),
        onPressed: () {},
      ),

      GestureDetector(
        onTap: () async {
          await AuthService().logout(context,ref);
          GoRouter.of(context).go('/signin');
        },
        child: const Icon(Icons.logout, color: Colors.black),
      ),

      SizedBox(width: 20,)
    ],

  );
}
