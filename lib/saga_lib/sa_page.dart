import 'package:flutter/material.dart';
import 'package:saga_test/informativo/informativo_page.dart';
import 'package:saga_test/saga_lib/sa_header.dart';

class SaPage extends StatelessWidget {
  const SaPage({
    Key? key,
    required this.title,
    required this.children,
    this.canBack = false,
  }) : super(key: key);

  final String title;
  final List<Widget> children;
  final bool canBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F8),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SaHeader(
                    title: title,
                    noIcons: true,
                    canBack: canBack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 24, 48, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...children,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              children: [
                SaHeader(
                  title: "Informativo",
                  showInfoLogin: title != "Login",
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(48, 24, 48, 0),
                  child: InformativoPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
