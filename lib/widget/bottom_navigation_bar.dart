import 'package:flutter/material.dart';
import 'package:hanout/color.dart';
import 'package:hanout/screen/Favoris.dart';
import 'package:hanout/screen/My_Account/My_Account.dart';
import 'package:hanout/screen/Recherche.dart';
import 'package:hanout/screen/acceuil.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const MyBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  void _handleItemTap(BuildContext context, int index) {
    onItemSelected(index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Acceuil()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Search()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Favori()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyAccount()));
        break;
      default:
        print('Unhandled tap');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 6.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.primaryColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: currentIndex == 0 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: currentIndex == 1 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline, color: currentIndex == 2 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined, color: currentIndex == 3 ? AppColors.primaryColor : AppColors.thirdColor),
            label: 'Mon compte',
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
