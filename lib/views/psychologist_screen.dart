import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/constants/app_colors.dart';
import 'package:mindcare/views/profile_screen.dart';

class PsychologistScreen extends StatefulWidget {
  const PsychologistScreen({super.key});

  @override
  State<PsychologistScreen> createState() => _PsychologistScreenState();
}

class _PsychologistScreenState extends State<PsychologistScreen> {
  int _selectedMode = 0; // 0: Tatap Muka, 1: Online
  String _selectedRadius = '10 km';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _psychologists = [
    {
      'name': 'Dra. Sarah Wijaya, M.Psi., Psikolog',
      'title': 'SIPP: 1234-21-2-1 • 8 Tahun Pengalaman',
      'location': 'Biro Psikologi Harmoni (1.8 km)',
      'rating': '4.9',
      'reviews': '128',
      'price': 'Rp 150.000',
      'tags': ['#Stres', '#Kecemasan'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBldQ1wE951RCtO7Kx-_OPOVUTn9trGUse8Pnv0T8AxrL7eMY_RUIV5YDFk1B_DckIW7YGMdXQQU4Kb7rr6Burjf1k-pyAEK0m76ZtJJjfno8fTMZ5-MOFi48ufyKYNRzWKVrmI_wSTAeOzOfFqN8lwrYKv1rDmFyansLL2hE6oPLF9SUoUr1mdvk9iCQArhrhDg08LKz6m8-6ZCraZ5j3m50UjBDm60qXB8u5mXJJ7diqZZUWHpgca7A',
      'about':
          'Spesialis dalam penanganan stres kerja, kecemasan berlebih, dan terapi perilaku kognitif (CBT). Berpengalaman mendampingi ratusan klien mencapai ketenangan mental.',
    },
    {
      'name': 'Dimas Pratama, M.Psi., Psikolog',
      'title': 'SIPP: 5678-22-1-2 • 5 Tahun Pengalaman',
      'location': 'Klinik Jiwa Bahagia (3.4 km)',
      'rating': '4.8',
      'reviews': '94',
      'price': 'Rp 125.000',
      'tags': ['#Burnout', '#Karir'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC3XjjMpyujltQzD8uo_JbKtLdCZPkvq_ZW2UVWPsqREd0kqukoUdbbFWW33Hzc7bhZD036bqVxVmihsZdpcfTWlcPBobCrV4u8nJtkJpJ1yFtKVGOEd1cpc83uodOoq0xO4T-hzGnDzN2F77P9MbXDNdQzcIpH26xUQ1XXK5bUOpk8K25DrlT0c50kpeYCTsFUXIN_MhdIjP6-mCmqzQEhiSoPH-y0WsARSqi73NlunCydchIfFCKGDQ',
      'about':
          'Fokus pada kesehatan mental profesional muda, mengatasi sindrom burnout, self-doubt, serta manajemen work-life balance yang sehat.',
    },
    {
      'name': 'dr. Amanda Putri, Sp.KJ',
      'title': 'SIP: 9912-30-3-1 • 10 Tahun Pengalaman',
      'location': 'RSIA Harapan Sehat (5.2 km)',
      'rating': '5.0',
      'reviews': '210',
      'price': 'Rp 200.000',
      'tags': ['#Depresi', '#Trauma'],
      'image':
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=300&q=80',
      'about':
          'Dokter spesialis kedokteran jiwa dengan pendekatan holistik medis dan psikoterapi mendalam untuk pemulihan trauma serta gangguan suasana hati.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBookingSheet(Map<String, dynamic> doc) {
    String selectedDate = 'Besok, 10:00 WIB';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          doc['image'],
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              doc['location'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tentang Psikolog:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc['about'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih Jadwal Sesi:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Besok, 10:00 WIB',
                      'Besok, 14:00 WIB',
                      'Jumat, 16:30 WIB',
                      'Sabtu, 09:00 WIB',
                    ].map((time) {
                      final isSelected = selectedDate == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        ),
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedDate = time);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Biaya Konsultasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          Text(doc['price'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Jadwal konsultasi bersama ${doc['name']} berhasil diajukan! ✨'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Konfirmasi Booking'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = _psychologists.where((doc) {
      final nameMatches = (doc['name'] as String).toLowerCase().contains(query);
      final tagMatches = (doc['tags'] as List).any((t) => (t as String).toLowerCase().contains(query));
      return query.isEmpty || nameMatches || tagMatches;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top AppBar
            _buildAppBar(),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 14),

                    // Consultation Mode Toggle (Tatap Muka vs Online)
                    _buildModeToggle(),
                    const SizedBox(height: 20),

                    // Location & Radius Section with Map
                    _buildLocationMapCard(),
                    const SizedBox(height: 24),

                    // Results Header
                    Text(
                      '✨ Psikolog Terdekat (${filtered.length} Ditemukan)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Psychologists List
                    ...filtered.map((doc) => _buildPsychologistCard(doc)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top AppBar ---
  Widget _buildAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.softSunshine,
                    border: Border.all(color: AppColors.primaryContainer, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCXHf3pkOU1XE_ClnFc2VI48jYIn96xVYuF35b8KKzMVbs3aKcoaXFGAwyb6Sh96ZTpXMINfkGAbzR_osNQ7U_reP71KxZkljP03U8ASMhLiMKdIzseDHnfeAN3cQ1r6DQGJidUXQ6DBLO6YiALpCQgi0F94nvv-AJsH_fCn5u6zs_EDc1-uutOeJp_Jd1r2QVoW39FHTmoZksm5l9ix56Jtjqe3jt7PUthLMpiIWcApqokgrCl72MD-Q',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Temukan Psikolog',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Layanan Psikolog Resmi terdaftar HIMPSI.')),
              );
            },
            icon: const Icon(Icons.verified_outlined, color: AppColors.secondary, size: 22),
          ),
        ],
      ),
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          icon: const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
          hintText: 'Cari nama psikolog, spesialisasi (#Stres)...',
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // --- Mode Toggle ---
  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMode = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedMode == 0 ? AppColors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedMode == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '📍 Tatap Muka (Sekitar)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: _selectedMode == 0 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedMode == 0 ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMode = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedMode == 1 ? AppColors.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedMode == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '🌐 Online (Daring)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: _selectedMode == 1 ? FontWeight.bold : FontWeight.w500,
                      color: _selectedMode == 1 ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Location & Map Card ---
  Widget _buildLocationMapCard() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lokasi Anda', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text('Kebayoran Baru, Jaksel', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi diperbarui secara otomatis menggunakan GPS.')));
                },
                child: Text('Ubah Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Radius Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['5 km', '10 km', '25 km', '50 km'].map((radius) {
                final isSelected = _selectedRadius == radius;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRadius = radius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceCanvas,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.4)),
                      ),
                      child: Text(
                        radius,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Styled Map Preview Card
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD9BhyH8xyqKHJde3wrrZFsv5zzSvTNbua1Cioi2lGWaOKmCTgwI5ZjTEGUfadBZhdNU6CNEekLybKhXk4mUBSHALYwCzm85sRECypwra90AFXj3fxQFFb5bM6ehBFigBwhsKuU5x269IwkP1X4j7nM4dbJfAt-eQRuimRdmGmCzcn1MGn7iBJ2FA_AQh_caqfQHMwjEbHKTFNpJxOx72lKVu9xPRJgMA7U4BPQPYmLhmdp7J0TMrLZFw',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Cari di Area Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Psychologist Card ---
  Widget _buildPsychologistCard(Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.25)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(45, 49, 66, 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Image.network(
                  doc['image'],
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 58,
                    height: 58,
                    color: AppColors.primaryFixed,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['name'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doc['location'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating & Tags Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.softSunshine.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          '${doc['rating']} (${doc['reviews']})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...(doc['tags'] as List).map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCanvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                        ),
                        child: Text(
                          t,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.surfaceVariant),
          const SizedBox(height: 10),

          // Price & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biaya Sesi (60 mnt)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    doc['price'],
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka rute maps menuju ${doc['location']}')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.directions_outlined, size: 16, color: AppColors.onSurface),
                    label: Text('Rute', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurface)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showBookingSheet(doc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text('Konsultasi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
