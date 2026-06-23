import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart'; // Package cek baterai

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  // 1. Variabel State Posisi & Mood
  String statusPosisi = 'berdiri'; 
  String statusCuaca = 'Cerah'; // Pilihan simulasi: 'Cerah' atau 'Hujan'
  int tingkatBaterai = 100;
  String ekspresiMood = 'Ceria / Senang';

  // Sensor Baterai bawaan HP
  final Battery _battery = Battery();

  @override
  void initState() {
    super.overrideWith(() {});
    super.initState();
    _pantauBateraiHP(); // Mulai lacak baterai pas aplikasi dibuka
  }

  // Fungsi untuk mengambil data baterai asli dari HP lu
  void _pantauBateraiHP() async {
    // Ambil persentase awal saat ini
    final level = await _battery.batteryLevel;
    setState(() {
      tingkatBaterai = level;
      _hitungMatriksMood(); // Hitung mood berdasarkan baterai awal
    });

    // Pantau terus kalau baterainya berubah (naik/turun)
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final currentLevel = await _battery.batteryLevel;
      setState(() {
        tingkatBaterai = currentLevel;
        _hitungMatriksMood();
      });
    });
  }

  // 2. LOGIKA MATRIKS MOOD (Sesuai Tabel Rencana Lu)
  void _hitungMatriksMood() {
    if (tingkatBaterai > 60) {
      if (statusCuaca == 'Cerah') {
        ekspresiMood = 'Ceria / Senang';
      } else {
        ekspresiMood = 'Santai / Bengong';
      }
    } else if (tingkatBaterai >= 35 && tingkatBaterai <= 60) {
      if (statusCuaca == 'Cerah') {
        ekspresiMood = 'Biasa / Flat';
      } else {
        ekspresiMood = 'Sedikit Bosan';
      }
    } else {
      // Di bawah 35% (Lowbat)
      if (statusCuaca == 'Cerah') {
        ekspresiMood = 'Lelah / Mengantuk';
      } else {
        ekspresiMood = 'Sedih / Meringkuk';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // BACKGROUND KAMAR
              Positioned.fill(
                child: Image.asset(
                  'assets/images/anime_landscape.png',
                  fit: BoxFit.cover,
                ),
              ),

              // SENSOR KASUR (Kiri Bawah)
              Positioned(
                left: 0,
                top: screenHeight * 0.5,
                width: screenWidth * 0.5,
                height: screenHeight * 0.4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      statusPosisi = 'tidur_kasur';
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

              // SENSOR MEJA (Kanan Bawah)
              Positioned(
                right: 0,
                top: screenHeight * 0.55,
                width: screenWidth * 0.5,
                height: screenHeight * 0.35,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      statusPosisi = 'duduk_meja';
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

              // KARAKTER UTAMA (Posisi dinamis)
              _buildKarakter(screenWidth, screenHeight),

              // PANEL INDIKATOR HUD (Pojok Kiri Atas)
              Positioned(
                top: 40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Posisi: ${statusPosisi.toUpperCase()}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('🔋 Baterai HP: $tingkatBaterai%', style: GoogleFonts.outfit(color: tingkatBaterai < 35 ? Colors.redAccent : Colors.greenAccent, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('☁️ Cuaca: $statusCuaca', style: GoogleFonts.outfit(color: Colors.lightBlueAccent, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE53170), borderRadius: BorderRadius.circular(6)),
                        child: Text('🎭 Mood Aki: $ekspresiMood', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              
              // PANEL REMOT KONTROL SIMULASI (Pojok Kanan Atas)
              // (Untuk ngetes ganti cuaca & batre secara manual di emulator)
              Positioned(
                top: 40,
                right: 20,
                child: Column(
                  children: [
                    // Tombol Ganti Cuaca
                    IconButton(
                      icon: Icon(statusCuaca == 'Cerah' ? Icons.wb_sunny : Icons.cloudy_snowing, color: Colors.amber),
                      backgroundColor: Colors.black54,
                      onPressed: () {
                        setState(() {
                          statusCuaca = statusCuaca == 'Cerah' ? 'Hujan' : 'Cerah';
                          _hitungMatriksMood();
                        });
                      },
                    ),
                    const SizedBox(height: 5),
                    // Tombol Reset Posisi Berdiri
                    IconButton(
                      icon: const Icon(Icons.accessibility_new, color: Colors.white),
                      backgroundColor: Colors.black54,
                      onPressed: () => setState(() => statusPosisi = 'berdiri'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKarakter(double width, double height) {
    double leftPos = width * 0.32;
    double bottomPos = height * 0.15;

    if (statusPosisi == 'tidur_kasur') {
      leftPos = width * 0.15;
      bottomPos = height * 0.25;
    } else if (statusPosisi == 'duduk_meja') {
      leftPos = width * 0.50;
      bottomPos = height * 0.2;
    }

    return Positioned(
      left: leftPos,
      bottom: bottomPos,
      width: width * 0.36,
      child: Column(
        children: [
          // Nanti di sini ditaruh layer wajah terpisah.
          // Sementara kita tampilkan teks mood di atas kepalanya dulu sebagai penanda!
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(5)),
            child: Text(
              '[$ekspresiMood]',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(height: 4),
          Image.asset(
            'assets/images/anime_character.png',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}