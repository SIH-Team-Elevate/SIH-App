import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  List<String> languages = ["English", "Hindi", "Urdu", "Tamil"];
  String currL = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Help and Support",style: GoogleFonts.poppins(fontWeight: FontWeight.w500),),
                  Container(
                    child: DropdownButton(
                      value: currL,
                      items: languages
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          currL = value!;
                        });
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
