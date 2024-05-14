import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanout/screen/acceuil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Done extends StatefulWidget {
  const Done({Key? key}) : super(key: key);

  @override
  State<Done> createState() => _DoneState();
}

class _DoneState extends State<Done> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Acceuil()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/Done.svg',height: 100,),
              SizedBox(height: 50),
              Text(
                'Order Confirmed',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  fontSize: 28.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
