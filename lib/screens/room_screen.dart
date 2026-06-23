import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart'; 
import 'package:http/http.dart' as http; // Package untuk nembak API internet

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  // 1. Variabel State Utama
  String statusPosisi = 'berdiri'; 
  String statusCuaca = 'Memuat...'; // Default sebelum data internet masuk
  int tingkatBaterai = 100;
  String ekspresiMood = 'Biasa / Flat';
  bool sedangLoadingCuaca = true;

  // GANTI KODE DI BAWAH INI dengan API Key milik lu dari OpenWeatherMap!
  final String apiKeyOpenWeather = '2723f9e0b9addea9c1f0e6e4298af615';
  // Tulis nama kota tempat tinggal lu saat ini agar presisi
  final String namaKota = 'Banda Aceh'; 

  final Battery _battery = Battery();

  @override
  void initState() {
    super.initState();
    _inisialisasiData();
  }

  // Fungsi awal untuk mengawinkan baterai dan cuaca internet
  void _inisialisasiData() async {
    await _ambilCuacaRealTime();
    _pantauBateraiHP();
  }

  // 🌍 FUNGSI MEMBACA CUACA NYATA LEWAT INTERNET
  Future<void> _ambilCuacaRealTime() async {
    final String url = 'https://api.openweathermap.org/data/2.5/weather?q=$namaKota&appid=$apiKeyOpenWeather';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mengambil kondisi utama cuaca, misal: 'Rain', 'Clouds', 'Clear'
        String cuacaUtama = data['weather'][0]['main']; 

        setState(() {
          // Kita sederhanakan logika sesuai tabel lu: Kalau bukan 'Clear' (Cerah), kita anggap mendung/Hujan
          if (cuacaUtama.toLowerCase() == 'clear') {
            statusCuaca = 'Cerah';
          } else {
            statusCuaca = 'Hujan'; // Termasuk Clouds, Rain, Thunderstorm, dll.
          }
          sedangLoadingCuaca = false;
        });
      } else {
        setState(() {
          statusCuaca = 'Cerah (Offline)'; // Fallback kalau API key salah
          sedangLoadingCuaca = false;
        });
      }
    } catch (e) {
      setState(() {
        statusCuaca = 'Cerah (No Internet)'; // Fallback kalau HP tidak ada kuota
        sedangLoadingCuaca = false;
      });
    }
  }

  // 🔋 FUNGSI MEMBACA BATERAI HP ASLI
  void _pantauBateraiHP() async {
    final level = await _battery.batteryLevel;
    setState(() {
      tingkatBaterai = level;
      _hitungMatriksMood(); 
    });

    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final currentLevel = await _battery.batteryLevel;
      setState(() {
        tingkatBaterai = currentLevel;
        _hitungMatriksMood();
      });
    });
  }

  // 🎭 MATRIKS MOOD OTOMATIS (Tanpa Klik Tombol Lagi)
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

              // SENSOR TAP KASUR
              Positioned(
                left: 0,
                top: screenHeight * 0.5,
                width: screenWidth * 0.5,
                height: screenHeight * 0.4,
                child: GestureDetector(
                  onTap: () => setState(() => statusPosisi = 'tidur_kasur'),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // SENSOR TAP MEJA
              Positioned(
                right: 0,
                top: screenHeight * 0.55,
                width: screenWidth * 0.5,
                height: screenHeight * 0.35,
                child: GestureDetector(
                  onTap: () => setState(() => statusPosisi = 'duduk_meja'),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // KARAKTER UTAMA
              _buildKarakter(screenWidth, screenHeight),

              // INDIKATOR HUD REAL-TIME (Pojok Kiri Atas)
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
                      Row(
                        children: [
                          Text('☁️ Cuaca ($namaKota): ', style: GoogleFonts.outfit(color: Colors.lightBlueAccent, fontSize: 13)),
                          sedangLoadingCuaca 
                            ? const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.lightBlueAccent))
                            : Text(statusCuaca, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
              
              // TOMBOL RESET POSISI (Pojok Kanan Atas)
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  backgroundColor: Colors.black54,
                  onPressed: () {
                    setState(() {
                      statusPosisi = 'berdiri';
                      sedangLoadingCuaca = true;
                    });
                    _ambilCuacaRealTime(); // Segarkan cuaca saat di-reset
                  },
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