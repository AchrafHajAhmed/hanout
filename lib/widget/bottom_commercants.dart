import 'package:flutter/material.dart';
import 'package:hanout/color.dart';
//import 'package:hanout/screen/Commercants/Commercants_commands.dart';
import 'package:hanout/Commercants/Commercant_market.dart';
import 'package:hanout/screen/My_Account/My_Account.dart';

class CommercantsBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CommercantsBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  void _handleItemTap(BuildContext context, int index) {
    onItemSelected(index);

    switch (index) {
      case 0:
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommercantsMarket()));
        break;
      case 1:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommercantsCommands()));
        break;
      case 2:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommercantsMarket()));
        break;
      default:
        print('Unhandled tap');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 6.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined, color: currentIndex == 0 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: currentIndex == 1 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: currentIndex == 2 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Account',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => _handleItemTap(context, index),
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.thirdColor,
      ),
    );
  }
}
