import 'package:flutter/material.dart';
import '../home/home_page.dart'; // Đảm bảo import đúng đường dẫn
import '../profile/profile_page.dart'; // Giả sử bạn có trang này

class MainHeader extends StatelessWidget implements PreferredSizeWidget {
  final String subTitle;

  const MainHeader({
    super.key,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 90,
          // 1. CLICK VÀO LOGO VỀ HOMEPAGE
          leading: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false, // Xóa hết các trang trước đó trong stack
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Image.asset('assets/logo-removebg.png', fit: BoxFit.contain),
            ),
          ),
          title: const Text(
            'Health Tracker',
            style: TextStyle(
              color: Color(0xFF379AE6),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            // 2. CLICK VÀO AVATAR TỚI PROFILE
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1A237E),
                  child: Text('A', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 50,
          color: const Color(0xFF379AE6),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(106);
}