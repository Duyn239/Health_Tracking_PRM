import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalSourcesPage extends StatelessWidget {
  const MedicalSourcesPage({super.key});

  // Hàm xử lý mở liên kết ngoài
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Không thể mở liên kết $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền xám nhạt hiện đại
      appBar: AppBar(
        title: const Text('Cơ sở y khoa',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header trang trí
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF1A237E), size: 50),
                  const SizedBox(height: 12),
                  const Text('Minh bạch & Tin cậy',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Text(
                    'Dữ liệu phân tích dựa trên các hướng dẫn (Guidelines) lâm sàng quốc tế và Việt Nam.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildMedicalCard(
                    title: 'Huyết áp (Blood Pressure)',
                    subtitle: 'Khuyến cáo của Hội Tim mạch học Việt Nam (VNHA) & AHA',
                    content: 'Phân loại mức độ dựa trên hướng dẫn lâm sàng mới nhất về chẩn đoán và điều trị tăng huyết áp.',
                    icon: Icons.favorite,
                    accentColor: Colors.red.shade400,
                    link: 'https://vnha.org.vn/',
                  ),
                  _buildMedicalCard(
                    title: 'Đường huyết (Blood Glucose)',
                    subtitle: 'Tiêu chuẩn American Diabetes Association (ADA) 2024',
                    content: 'Ngưỡng đường huyết lúc đói và sau ăn được tham chiếu theo Standards of Care in Diabetes.',
                    icon: Icons.bloodtype,
                    accentColor: Colors.orange.shade400,
                    link: 'https://diabetes.org/',
                  ),
                  _buildMedicalCard(
                    title: 'BMI & Cân nặng',
                    subtitle: 'Phân loại dành riêng cho khu vực Châu Á (WHO)',
                    content: 'Sử dụng bảng chỉ số BMI hiệu chỉnh cho người Châu Á để đánh giá tình trạng béo phì.',
                    icon: Icons.monitor_weight,
                    accentColor: Colors.green.shade400,
                    link: 'https://www.who.int/vietnam',
                  ),
                  _buildMedicalCard(
                    title: 'SpO2 (Nồng độ Oxy)',
                    subtitle: 'Hướng dẫn từ Mayo Clinic & NHS Anh Quốc',
                    content: 'Ngưỡng an toàn và cảnh báo hạ oxy máu dựa trên tiêu chuẩn theo dõi lâm sàng.',
                    icon: Icons.air,
                    accentColor: Colors.blue.shade400,
                    link: 'https://www.mayoclinic.org/',
                  ),

                  const SizedBox(height: 10),

                  // Disclaimer Card
                  Card(
                    elevation: 0,
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.red.shade800),
                              const SizedBox(width: 10),
                              Text('LƯU Ý QUAN TRỌNG',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ứng dụng không thay thế lời khuyên y khoa từ bác sĩ. Mọi thông tin chỉ mang tính chất tham khảo để hỗ trợ theo dõi sức khỏe cá nhân.',
                            style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard({
    required String title,
    required String subtitle,
    required String content,
    required IconData icon,
    required Color accentColor,
    required String link,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(height: 4, color: accentColor), // Thanh màu phía trên Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: accentColor.withOpacity(0.1),
                        child: Icon(icon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: accentColor)),
                  const SizedBox(height: 6),
                  Text(content,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                  const SizedBox(height: 12),
                  const Divider(),
                  TextButton.icon(
                    onPressed: () => _launchURL(link),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Xem tài liệu gốc'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1A237E),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}