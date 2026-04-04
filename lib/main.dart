import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:camera_macos/camera_macos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

bool useImagePickerForFaceCapture() {
  return defaultTargetPlatform == TargetPlatform.linux;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadMaterialIconsFont();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const GymProApp());
}

Future<void> _loadMaterialIconsFont() async {
  final loader = FontLoader('MaterialIcons');
  loader.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await loader.load();
}

class GymProApp extends StatelessWidget {
  const GymProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymPro',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F2ED),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1C3B2E),
          secondary: Color(0xFFE0A458),
          surface: Color(0xFFFFFBF6),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
      home: const GymProEntryScreen(),
    );
  }
}

class GymProEntryScreen extends StatelessWidget {
  const GymProEntryScreen({super.key});

  static const List<_BusinessTile> _businessTiles = [
    _BusinessTile('Restaurants', Icons.restaurant, '🍽️'),
    _BusinessTile('Clothing stores', Icons.checkroom, '👕'),
    _BusinessTile('Grocery stores', Icons.local_grocery_store, '🛒'),
    _BusinessTile('Hardware stores', Icons.handyman, '🛠️'),
    _BusinessTile('Butcher shops (meat cutting)', Icons.set_meal, '🥩'),
    _BusinessTile('Gyms', Icons.fitness_center, '🏋️'),
    _BusinessTile('Cafés or bakeries', Icons.coffee, '☕'),
    _BusinessTile('Electronics stores', Icons.devices_other, '💻'),
    _BusinessTile('Pharmacies', Icons.local_pharmacy, '💊'),
    _BusinessTile('Bookshops', Icons.menu_book, '📚'),
    _BusinessTile('Pet supply stores', Icons.pets, '🐾'),
    _BusinessTile('Furniture stores', Icons.chair_alt, '🪑'),
    _BusinessTile('Beauty salons (selling products)', Icons.spa, '💇'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2ED),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 3;
            const mainAxisSpacing = 10.0;
            const crossAxisSpacing = 10.0;
            final rows = (_businessTiles.length / crossAxisCount).ceil();
            final headerHeight = 54.0;
            final availableHeight =
                constraints.maxHeight - headerHeight - 16;
            final itemHeight =
                (availableHeight - (rows - 1) * mainAxisSpacing) / rows;
            final itemWidth = (constraints.maxWidth -
                    (crossAxisCount - 1) * crossAxisSpacing) /
                crossAxisCount;
            final aspectRatio = itemWidth / itemHeight;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Text(
                      'Choose Your Business Type',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _businessTiles.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: mainAxisSpacing,
                        crossAxisSpacing: crossAxisSpacing,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final tile = _businessTiles[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (tile.label == 'Gyms') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EmptyBusinessScreen(title: tile.label),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF6),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE5DED7)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0A458),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    tile.emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    tile.label,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BusinessTile {
  const _BusinessTile(this.label, this.icon, this.emoji);

  final String label;
  final IconData icon;
  final String emoji;
}

class EmptyBusinessScreen extends StatelessWidget {
  const EmptyBusinessScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<List<Member>> watchMembers() {
    return _client
        .from('members')
        .stream(primaryKey: ['id'])
        .order('name')
        .map(
          (rows) => rows
              .map(
                (row) => Member(
                  id: row['id'] as String,
                  name: row['name'] as String,
                  mobileNumber: row['mobile_number'] as String? ?? '',
                  email: row['email'] as String,
                  age: row['age'] as int,
                  paymentAmount: row['payment_amount'] as int,
                  durationMonths: row['duration_months'] as int,
                  membershipActive: row['membership_active'] as bool,
                ),
              )
              .toList(),
        );
  }

  Stream<List<AttendanceLog>> watchRecentAttendance() {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(5)
        .map(
          (rows) => rows
              .map(
                (row) => AttendanceLog(
                  id: row['id'] as String,
                  memberId: row['member_id'] as String,
                  memberName: '',
                  memberMobile: '',
                  timestamp: DateTime.parse(row['timestamp'] as String),
                ),
              )
              .toList(),
        );
  }

  Future<String> _generateUniqueMemberId() async {
    final rows = await _client.from('members').select('id');
    final existing = rows
        .map((row) => row['id'])
        .whereType<String>()
        .toSet();
    final random = Random();
    for (var attempt = 0; attempt < 9000; attempt++) {
      final id = (random.nextInt(9000) + 1000).toString();
      if (!existing.contains(id)) {
        return id;
      }
    }
    throw Exception('Unable to generate a unique member ID.');
  }

  Future<void> addMember(MemberInput input) async {
    final memberId = await _generateUniqueMemberId();
    await _client.from('members').insert({
      'id': memberId,
      'name': input.name,
      'mobile_number': input.mobileNumber,
      'email': input.email,
      'age': input.age,
      'payment_amount': input.paymentAmount,
      'duration_months': input.durationMonths,
      'membership_active': input.membershipActive,
    });
  }

  Future<String> addMemberReturningId(MemberInput input) async {
    final memberId = await _generateUniqueMemberId();
    await _client.from('members').insert({
      'id': memberId,
      'name': input.name,
      'mobile_number': input.mobileNumber,
      'email': input.email,
      'age': input.age,
      'payment_amount': input.paymentAmount,
      'duration_months': input.durationMonths,
      'membership_active': input.membershipActive,
    });
    return memberId;
  }

  Future<void> updateMember({
    required String memberId,
    required MemberInput input,
  }) async {
    await _client.from('members').update({
      'name': input.name,
      'mobile_number': input.mobileNumber,
      'email': input.email,
      'age': input.age,
      'payment_amount': input.paymentAmount,
      'duration_months': input.durationMonths,
      'membership_active': input.membershipActive,
    }).eq('id', memberId);
  }

  Future<void> deleteMember(String memberId) async {
    await _client.from('attendance').delete().eq('member_id', memberId);
    await _client.from('member_faces').delete().eq('member_id', memberId);
    await _client.from('members').delete().eq('id', memberId);
  }

  Future<void> addAttendance({
    required String memberId,
    required DateTime timestamp,
  }) async {
    await _client.from('attendance').insert({
      'member_id': memberId,
      'timestamp': timestamp.toUtc().toIso8601String(),
    });
  }

  Future<void> updateAttendance({
    required String attendanceId,
    required DateTime timestamp,
  }) async {
    await _client.from('attendance').update({
      'timestamp': timestamp.toUtc().toIso8601String(),
    }).eq('id', attendanceId);
  }

  Future<void> deleteAttendance(String attendanceId) async {
    await _client.from('attendance').delete().eq('id', attendanceId);
  }

  Future<List<AttendanceLog>> attendanceForMember(String memberId) async {
    final rows = await _client
        .from('attendance')
        .select('id, member_id, timestamp')
        .eq('member_id', memberId)
        .order('timestamp', ascending: false)
        .limit(20);

    return rows
        .map(
          (row) => AttendanceLog(
            id: row['id'] as String,
            memberId: row['member_id'] as String,
            memberName: '',
            memberMobile: '',
            timestamp: DateTime.parse(row['timestamp'] as String),
          ),
        )
        .toList();
  }

  Stream<List<AttendanceLog>> watchAttendanceSince(DateTime since) {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .gte('timestamp', since.toUtc().toIso8601String())
        .order('timestamp', ascending: true)
        .map(
          (rows) => rows
              .map(
                (row) => AttendanceLog(
                  id: row['id'] as String,
                  memberId: row['member_id'] as String,
                  memberName: '',
                  memberMobile: '',
                  timestamp: DateTime.parse(row['timestamp'] as String),
                ),
              )
              .toList(),
        );
  }

  Future<AttendanceLog?> latestAttendanceForMember(String memberId) async {
    final rows = await _client
        .from('attendance')
        .select('id, member_id, timestamp')
        .eq('member_id', memberId)
        .order('timestamp', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    final row = rows.first;
    return AttendanceLog(
      id: row['id'] as String,
      memberId: row['member_id'] as String,
      memberName: '',
      memberMobile: '',
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }

  Future<Member?> memberById(String memberId) async {
    final rows = await _client
        .from('members')
        .select(
          'id, name, mobile_number, email, age, payment_amount, duration_months, membership_active',
        )
        .eq('id', memberId)
        .limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return Member(
      id: row['id'] as String,
      name: row['name'] as String,
      mobileNumber: row['mobile_number'] as String? ?? '',
      email: row['email'] as String,
      age: row['age'] as int,
      paymentAmount: row['payment_amount'] as int,
      durationMonths: row['duration_months'] as int,
      membershipActive: row['membership_active'] as bool,
    );
  }

  Future<FaceIdResult?> recognizeFace(Uint8List imageBytes) async {
    final response = await _client.functions.invoke(
      faceIdFunctionName,
      body: <String, dynamic>{
        'image_base64': base64Encode(imageBytes),
      },
    );

    // Expected response: { "member_id": "...", "confidence": 0.92 }
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final memberId = data['member_id'];
      if (memberId is String && memberId.isNotEmpty) {
        final confidence = data['confidence'];
        return FaceIdResult(
          memberId: memberId,
          confidence: confidence is num ? confidence.toDouble() : null,
        );
      }
    }
    return null;
  }

  Future<bool> enrollFace({
    required String memberId,
    required Uint8List imageBytes,
  }) async {
    final response = await _client.functions.invoke(
      faceEnrollFunctionName,
      body: <String, dynamic>{
        'member_id': memberId,
        'image_base64': base64Encode(imageBytes),
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success is bool && success) return true;
      final error = data['error'];
      if (error != null) {
        throw Exception(error.toString());
      }
    }
    throw Exception('Face registration failed. Please try again.');
  }
}

class Member {
  const Member({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.age,
    required this.paymentAmount,
    required this.durationMonths,
    required this.membershipActive,
  });

  final String id;
  final String name;
  final String mobileNumber;
  final String email;
  final int age;
  final int paymentAmount;
  final int durationMonths;
  final bool membershipActive;
}

class MemberInput {
  const MemberInput({
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.age,
    required this.paymentAmount,
    required this.durationMonths,
    required this.membershipActive,
  });

  final String name;
  final String mobileNumber;
  final String email;
  final int age;
  final int paymentAmount;
  final int durationMonths;
  final bool membershipActive;
}

class AttendanceLog {
  const AttendanceLog({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberMobile,
    required this.timestamp,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String memberMobile;
  final DateTime timestamp;
}

class FaceIdResult {
  const FaceIdResult({
    required this.memberId,
    required this.confidence,
  });

  final String memberId;
  final double? confidence;
}

Future<bool> confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A1B1B),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
}) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2022),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (pickedDate == null) return null;
  if (!context.mounted) return null;
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  if (pickedTime == null) return null;
  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );
}

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({
    super.key,
    required this.camera,
    this.title = 'Capture Face ID',
  });

  final CameraDescription camera;
  final String title;

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCapturing = false;
  String? _errorText;
  int _tipIndex = 0;
  final List<String> _tips = const [
    'Center your face in the oval',
    'Keep your eyes open and look at the camera',
    'Hold still for a sharp capture',
  ];

  void _advanceTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % _tips.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setupCamera({bool notify = false}) {
    _controller?.dispose();
    final controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller = controller;
    _initializeControllerFuture = controller.initialize();
    if (notify && mounted) {
      setState(() {});
    }
  }

  Future<void> _capture() async {
    if (_isCapturing) return;
    final controller = _controller;
    if (controller == null) {
      setState(() {
        _errorText = 'Camera not ready yet. Please try again.';
      });
      return;
    }
    setState(() {
      _isCapturing = true;
      _errorText = null;
    });
    try {
      await _initializeControllerFuture;
      if (!controller.value.isInitialized) {
        setState(() {
          _errorText = 'Camera not ready yet. Please try again.';
        });
        return;
      }
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop(bytes);
    } catch (error) {
      setState(() {
        _errorText = 'Camera capture failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraFuture = _initializeControllerFuture;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Align your face in the frame',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Make sure your face is well-lit and centered.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: const Color(0xFFEFE8DF),
                  child: FutureBuilder<void>(
                    future: cameraFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || _controller == null) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Camera unavailable. Please check permissions.',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => _setupCamera(notify: true),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry Camera'),
                              ),
                            ],
                          ),
                        );
                      }
      final controller = _controller!;
      return Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller)),
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(102),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.center_focus_strong,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tips[_tipIndex],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: _advanceTip,
                          icon: const Icon(Icons.tips_and_updates_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withAlpha(89),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 220,
                              height: 280,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withAlpha(191),
                                  width: 2.4,
                                ),
                                borderRadius: BorderRadius.circular(140),
                              ),
                            ),
                          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(102),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                'Keep your eyes open and remove hats or masks.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
            ),
          ),
          if (_isCapturing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(120),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F2ED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF1C3B2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Detecting face...',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFF1C3B2E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  ),
                ),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorText!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: const Color(0xFF8A1B1B)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C3B2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isCapturing ? null : _capture,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(_isCapturing ? 'Capturing...' : 'Capture'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceCaptureMacOSScreen extends StatefulWidget {
  const FaceCaptureMacOSScreen({
    super.key,
    this.title = 'Capture Face ID',
  });

  final String title;

  @override
  State<FaceCaptureMacOSScreen> createState() => _FaceCaptureMacOSScreenState();
}

class _FaceCaptureMacOSScreenState extends State<FaceCaptureMacOSScreen> {
  CameraMacOSController? _controller;
  bool _isCapturing = false;
  String? _errorText;
  bool _cameraUnavailable = false;
  String? _cameraErrorMessage;
  int _cameraReloadToken = 0;
  int _tipIndex = 0;
  final List<String> _tips = const [
    'Center your face in the oval',
    'Keep your eyes open and look at the camera',
    'Hold still for a sharp capture',
  ];

  void _advanceTip() {
    setState(() {
      _tipIndex = (_tipIndex + 1) % _tips.length;
    });
  }

  Future<void> _capture() async {
    if (_isCapturing || _controller == null) return;
    setState(() {
      _isCapturing = true;
      _errorText = null;
    });
    try {
      final image = await _controller!.takePicture();
      final bytes = image?.bytes;
      if (!mounted) return;
      if (bytes == null) {
        setState(() {
          _errorText = 'Camera capture failed. Please try again.';
        });
        return;
      }
      Navigator.of(context).pop(bytes);
    } catch (error) {
      setState(() {
        _errorText = 'Camera capture failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isCapturing) return;
    setState(() {
      _isCapturing = true;
      _errorText = null;
    });
    try {
      final imagePicker = ImagePicker();
      final image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop(bytes);
    } catch (error) {
      setState(() {
        _errorText = 'Photo selection failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _retryCamera() {
    setState(() {
      _cameraUnavailable = false;
      _cameraErrorMessage = null;
      _cameraReloadToken += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Align your face in the frame',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'We will use this to match members during attendance.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: const Color(0xFFEFE8DF),
                  child: Stack(
                    children: [
                      CameraMacOSView(
                        key: ValueKey(_cameraReloadToken),
                        fit: BoxFit.cover,
                        cameraMode: CameraMacOSMode.photo,
                        enableAudio: false,
                        onCameraLoading: (error) {
                          if (error != null && !_cameraUnavailable) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              setState(() {
                                _cameraUnavailable = true;
                                _cameraErrorMessage =
                                    'Camera unavailable. Allow GymPro in System Settings > Privacy & Security > Camera.\n'
                                    'Details: ${error.toString()}';
                              });
                            });
                          }
                          if (error != null) {
                            debugPrint('CameraMacOS error: $error');
                          }
                          final message = error == null
                              ? 'Starting camera...'
                              : 'Camera unavailable. Check permissions.';
                          return Center(
                            child: Text(
                              message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                          );
                        },
                        onCameraInizialized: (controller) {
                          setState(() {
                            _controller = controller;
                            _cameraUnavailable = false;
                            _cameraErrorMessage = null;
                          });
                        },
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(102),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.center_focus_strong,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _tips[_tipIndex],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _advanceTip,
                                      icon: const Icon(
                                        Icons.tips_and_updates_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      if (_cameraUnavailable)
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFF6F2ED),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _cameraErrorMessage ??
                                        'Camera unavailable. Allow GymPro in System Settings > Privacy & Security > Camera.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _retryCamera,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry Camera'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _pickFromGallery,
                                        icon:
                                            const Icon(Icons.photo_library_outlined),
                                        label: const Text('Select Photo'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_isCapturing)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withAlpha(120),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F2ED),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Color(0xFF1C3B2E),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Detecting face...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: const Color(0xFF1C3B2E)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 220,
                          height: 280,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withAlpha(191),
                              width: 2.4,
                            ),
                            borderRadius: BorderRadius.circular(140),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(102),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Stay still for a second to get a sharper shot.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorText!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: const Color(0xFF8A1B1B)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C3B2E),
                        side: const BorderSide(color: Color(0xFF1C3B2E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _isCapturing ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Select Photo'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C3B2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _isCapturing ? null : _capture,
                      icon: _isCapturing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.camera_alt),
                      label: Text(_isCapturing ? 'Capturing...' : 'Capture'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1C3B2E),
                  Color(0xFF2D5A45),
                  Color(0xFFF6F2ED),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF6),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GymPro',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Run your gym with clarity. Log in to track members and attendance.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  _LabeledField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'coach@gympro.com',
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Password',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    hintText: 'Enter password',
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFF8A1B1B)),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C3B2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isSigningIn
                          ? null
                          : () async {
                              setState(() {
                                _isSigningIn = true;
                                _errorText = null;
                              });
                              try {
                                final response = await Supabase.instance.client
                                    .auth
                                    .signInWithPassword(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                                if (!mounted) return;
                                if (response.session == null) {
                                  setState(() {
                                    _errorText =
                                        'Login failed. Please check credentials.';
                                  });
                                  return;
                                }
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              } on AuthException catch (error) {
                                if (!mounted) return;
                                setState(() {
                                  _errorText = error.message;
                                });
                              } catch (_) {
                                if (!mounted) return;
                                setState(() {
                                  _errorText =
                                      'Something went wrong. Please try again.';
                                });
                              } finally {
                                if (mounted) {
                                  setState(() => _isSigningIn = false);
                                }
                              }
                            },
                      child: _isSigningIn
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enter Dashboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member Management',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track payments, attendance, and growth in one place.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showMembers = false;
  final Set<String> _reportFilters = {};

  Future<void> _openAttendanceDialog(
    List<Member> members,
    SupabaseService service,
  ) async {
    final controller = TextEditingController();
    Member? selectedMember;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final query = controller.text.trim().toLowerCase();
            final filteredMembers = query.isEmpty
                ? members
                : members
                    .where(
                      (member) =>
                          member.name.toLowerCase().contains(query) ||
                          member.id.toLowerCase().contains(query) ||
                          member.mobileNumber.toLowerCase().contains(query),
                    )
                    .toList();

            Future<void> submitPunch({
              required bool isPunchIn,
            }) async {
              if (selectedMember == null) return;
              setDialogState(() => isSaving = true);
              try {
                DateTime timestamp = DateTime.now();
                if (!isPunchIn) {
                  final latest =
                      await service.latestAttendanceForMember(selectedMember!.id);
                  if (latest != null) {
                    final lastLocal = latest.timestamp.toLocal();
                    final nowLocal = DateTime.now();
                    final lastDate = DateTime(
                      lastLocal.year,
                      lastLocal.month,
                      lastLocal.day,
                    );
                    final nowDate = DateTime(
                      nowLocal.year,
                      nowLocal.month,
                      nowLocal.day,
                    );
                    if (nowDate.isAfter(lastDate)) {
                      timestamp = DateTime(
                        lastDate.year,
                        lastDate.month,
                        lastDate.day,
                        23,
                        59,
                      );
                    }
                  }
                }
                await service.addAttendance(
                  memberId: selectedMember!.id,
                  timestamp: timestamp,
                );
                if (!context.mounted) return;
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isPunchIn
                            ? 'Punch-in saved for ${selectedMember!.name}.'
                            : 'Punch-out saved for ${selectedMember!.name}.',
                      ),
                    ),
                  );
                }
              } on PostgrestException catch (error) {
                if (!context.mounted) return;
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(error.message)),
                  );
                }
              } catch (_) {
                if (!context.mounted) return;
                if (mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save attendance.'),
                    ),
                  );
                }
              } finally {
                if (context.mounted && mounted) {
                  setDialogState(() => isSaving = false);
                }
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Attendance',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search by name, ID, or mobile number and record punch-in/out.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name, ID, or mobile',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF6F2ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5DED7)),
                      ),
                      child: filteredMembers.isEmpty
                          ? Text(
                              'No members found.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.black54),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                final isSelected = selectedMember?.id == member.id;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () {
                                    setDialogState(() {
                                      selectedMember = member;
                                    });
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected
                                        ? const Color(0xFF1C3B2E)
                                        : const Color(0xFFE0A458),
                                    child: Text(
                                      member.name.substring(0, 1),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(member.name),
                                  subtitle: Text(
                                    'ID: ${member.id} · ${member.mobileNumber.isEmpty ? 'Mobile number not available.' : member.mobileNumber}',
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF1C3B2E),
                                        )
                                      : null,
                                );
                              },
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 12),
                              itemCount: filteredMembers.length,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1C3B2E),
                              side: const BorderSide(color: Color(0xFF1C3B2E)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSaving
                                ? null
                                : selectedMember == null
                                    ? null
                                    : () => submitPunch(isPunchIn: true),
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Punch In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C3B2E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSaving
                                ? null
                                : selectedMember == null
                                    ? null
                                    : () => submitPunch(isPunchIn: false),
                            icon: const Icon(Icons.fingerprint_outlined),
                            label: const Text('Punch Out'),
                          ),
                        ),
                      ],
                    ),
                    if (isSaving) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(
                        color: Color(0xFF1C3B2E),
                        backgroundColor: Color(0xFFF6F2ED),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openFaceIdEditor(Member member) async {
    final imagePicker = ImagePicker();
    Uint8List? faceBytes;
    bool isCapturing = false;
    bool isSaving = false;
    String? errorText;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> captureFace() async {
              if (isCapturing) return;
              setDialogState(() {
                isCapturing = true;
                errorText = null;
              });
              try {
                Uint8List? bytes;
                if (useImagePickerForFaceCapture()) {
                  final image = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image == null) return;
                  bytes = await image.readAsBytes();
                } else if (defaultTargetPlatform == TargetPlatform.macOS) {
                  if (!context.mounted) return;
                  bytes = await Navigator.of(context).push<Uint8List>(
                    MaterialPageRoute(
                      builder: (_) => const FaceCaptureMacOSScreen(
                        title: 'Capture Face ID',
                      ),
                    ),
                  );
                  if (bytes == null) return;
                } else {
                  final cameras = await availableCameras();
                  if (cameras.isEmpty) {
                    setDialogState(() {
                      errorText = 'No camera found on this device.';
                    });
                    return;
                  }
                  final frontCamera = cameras.firstWhere(
                    (camera) => camera.lensDirection == CameraLensDirection.front,
                    orElse: () => cameras.first,
                  );
                  if (!context.mounted) return;
                  bytes = await Navigator.of(context).push<Uint8List>(
                    MaterialPageRoute(
                      builder: (_) => FaceCaptureScreen(camera: frontCamera),
                    ),
                  );
                  if (bytes == null) return;
                }
                setDialogState(() {
                  faceBytes = bytes;
                });
              } catch (error) {
                setDialogState(() {
                  errorText = 'Failed to capture face image: $error';
                });
              } finally {
                if (context.mounted) {
                  setDialogState(() => isCapturing = false);
                }
              }
            }

            Future<void> saveFace() async {
              if (faceBytes == null || isSaving) return;
              setDialogState(() {
                isSaving = true;
                errorText = null;
              });
              try {
                final success = await SupabaseService().enrollFace(
                  memberId: member.id,
                  imageBytes: faceBytes!,
                );
                if (!success) {
                  setDialogState(() {
                    errorText = 'Face registration failed. Please try again.';
                  });
                  return;
                }
                if (!context.mounted || !mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Face ID updated for ${member.name}.'),
                  ),
                );
              } on PostgrestException catch (error) {
                setDialogState(() {
                  errorText = error.message;
                });
              } catch (error) {
                setDialogState(() {
                  errorText = 'Face registration failed: $error';
                });
              } finally {
                if (context.mounted) {
                  setDialogState(() => isSaving = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Register Face ID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update face ID for ${member.name}.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  if (faceBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        faceBytes!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (faceBytes != null) const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C3B2E),
                        side: const BorderSide(color: Color(0xFF1C3B2E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isCapturing ? null : captureFace,
                      icon: const Icon(Icons.face_retouching_natural),
                      label: isCapturing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF1C3B2E),
                              ),
                            )
                          : Text(faceBytes == null
                              ? (kIsWeb
                                  ? 'Select Face ID Photo'
                                  : 'Capture Face ID')
                              : 'Retake Face ID'),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xFF8A1B1B)),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C3B2E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving ? null : saveFace,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Face ID'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, String> _buildPunchLabels(List<AttendanceLog> logs) {
    final grouped = <String, List<AttendanceLog>>{};
    for (final log in logs) {
      final local = log.timestamp.toLocal();
      final key = '${log.memberId}-${local.year}-${local.month}-${local.day}';
      grouped.putIfAbsent(key, () => []).add(log);
    }
    final labels = <String, String>{};
    for (final entry in grouped.values) {
      entry.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      for (var i = 0; i < entry.length; i++) {
        labels[entry[i].id] = i.isEven ? 'Punch In' : 'Punch Out';
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return StreamBuilder<List<Member>>(
      stream: service.watchMembers(),
      builder: (context, memberSnapshot) {
        final members = memberSnapshot.data ?? const <Member>[];
        final memberById = {
          for (final member in members) member.id: member,
        };
        final totalRevenue = members.fold<int>(
          0,
          (sum, member) => sum + member.paymentAmount,
        );

        Future<void> editLog(AttendanceLog log) async {
          final updated = await pickDateTime(
            context,
            initial: log.timestamp.toLocal(),
          );
          if (updated == null) return;
          await service.updateAttendance(
            attendanceId: log.id,
            timestamp: updated,
          );
        }

        Future<void> deleteLog(AttendanceLog log) async {
          final confirmed = await confirmDestructiveAction(
            context,
            title: 'Delete attendance?',
            message: 'This will remove the attendance record.',
            confirmLabel: 'Delete',
          );
          if (!confirmed) return;
          try {
            await service.deleteAttendance(log.id);
          } on PostgrestException catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.message)));
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to delete attendance.')),
              );
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFF6F2ED),
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddMemberScreen()),
                  );
                },
                icon: const Icon(Icons.person_add_alt),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AttendanceInputScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.fingerprint),
              ),
              IconButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Active Members',
                      value: members
                          .where((member) => member.membershipActive)
                          .length
                          .toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending Payments',
                      value: members
                          .where((member) => !member.membershipActive)
                          .length
                          .toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FaceIdCheckInCallout(
                title: 'Face ID Check-In',
                subtitle: '',
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 4),
              Text(
                'Performance Overview',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Total Revenue',
                      value: '₹$totalRevenue',
                      icon: Icons.payments,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Total Members',
                      value: members.length.toString(),
                      icon: Icons.groups,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<AttendanceLog>>(
                stream: service.watchAttendanceSince(
                  DateTime.now().subtract(const Duration(days: 180)),
                ),
                builder: (context, attendanceSnapshot) {
                  final logs = attendanceSnapshot.data ?? const <AttendanceLog>[];
                  return _KpiCharts(logs: logs);
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Month-End Reports',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _ReportChip(
                    label: 'By Date',
                    selected: _reportFilters.contains('date'),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _reportFilters.add('date')
                            : _reportFilters.remove('date');
                      });
                    },
                  ),
                  _ReportChip(
                    label: 'By Member',
                    selected: _reportFilters.contains('member'),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _reportFilters.add('member')
                            : _reportFilters.remove('member');
                      });
                    },
                  ),
                  _ReportChip(
                    label: 'By Amount',
                    selected: _reportFilters.contains('amount'),
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _reportFilters.add('amount')
                            : _reportFilters.remove('amount');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _reportFilters.isEmpty
                    ? 'Select filters to generate custom month-end reports.'
                    : 'Filters applied: ${_reportFilters.join(', ')}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Text(
                'Member List',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C3B2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _showMembers = !_showMembers);
                    },
                    child: Text(_showMembers ? 'Hide Members' : 'View Members'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _showMembers
                        ? 'Showing ${members.length} members'
                        : 'Hidden by default',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!_showMembers)
                Text(
                  'Tap "View Members" to display the full member list.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                )
              else if (members.isEmpty)
                Text(
                  'No members yet. Add your first member to get started.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                )
              else
                ...members.map(
                  (member) => _MemberTile(
                    member: member,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(member: member),
                        ),
                      );
                    },
                    onEdit: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditMemberScreen(member: member),
                        ),
                      );
                    },
                    onEditFaceId: () => _openFaceIdEditor(member),
                    onDelete: () async {
                      final confirmed = await confirmDestructiveAction(
                        context,
                        title: 'Delete member?',
                        message:
                            'This will remove the member, their attendance records, and face ID data. This action cannot be undone.',
                        confirmLabel: 'Delete Member',
                      );
                      if (!confirmed) return;
                      try {
                        await SupabaseService().deleteMember(member.id);
                      } on PostgrestException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(error.message)));
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete member.')),
                          );
                        }
                      }
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Recent Attendance',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<AttendanceLog>>(
                stream: service.watchRecentAttendance(),
                builder: (context, attendanceSnapshot) {
                  final logs = attendanceSnapshot.data ?? const <AttendanceLog>[];
                  if (logs.isEmpty) {
                    return Text(
                      'No attendance captured yet.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    );
                  }
                  final resolvedLogs = logs
                      .map(
                        (log) => AttendanceLog(
                          id: log.id,
                          memberId: log.memberId,
                          memberName:
                              memberById[log.memberId]?.name ?? 'Member',
                          memberMobile:
                              memberById[log.memberId]?.mobileNumber ?? '',
                          timestamp: log.timestamp,
                        ),
                      )
                      .toList();
                  final punchLabels = _buildPunchLabels(resolvedLogs);
                  return _AttendanceLogCard(
                    logs: resolvedLogs,
                    punchLabels: punchLabels,
                    onEdit: editLog,
                    onDelete: deleteLog,
                  );
                },
              ),
            ],
          ),
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'add-member',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddMemberScreen()),
                  );
                },
                backgroundColor: const Color(0xFF1C3B2E),
                foregroundColor: Colors.white,
                label: const Text('Add Member'),
                icon: const Icon(Icons.person_add),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                heroTag: 'add-attendance',
                onPressed: () => _openAttendanceDialog(members, service),
                backgroundColor: const Color(0xFFE0A458),
                foregroundColor: const Color(0xFF1C3B2E),
                label: const Text('Add Attendance'),
                icon: const Icon(Icons.fingerprint),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key, required this.member});

  final Member member;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Member _member;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
  }

  Future<void> _refreshMember() async {
    final updated = await SupabaseService().memberById(widget.member.id);
    if (updated != null && mounted) {
      setState(() => _member = updated);
    }
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditMemberScreen(member: _member),
      ),
    );
    if (result == true) {
      await _refreshMember();
    }
  }

  Future<void> _deleteMember() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete member?',
      message:
          'This will remove the member, their attendance records, and face ID data. This action cannot be undone.',
      confirmLabel: 'Delete Member',
    );
    if (!confirmed) return;
    try {
      await SupabaseService().deleteMember(_member.id);
      if (mounted) Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete member.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: const Text('Member Details'),
        actions: [
          IconButton(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _deleteMember,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 16,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _member.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                _DetailRow(label: 'Member ID', value: _member.id),
                _DetailRow(label: 'Mobile', value: _member.mobileNumber),
                _DetailRow(label: 'Email', value: _member.email),
                _DetailRow(label: 'Age', value: '${_member.age} years'),
                _DetailRow(
                  label: 'Membership Duration',
                  value: _member.durationMonths == 1
                      ? '1 month'
                      : '${_member.durationMonths} months',
                ),
                _DetailRow(
                  label: 'Days Left',
                  value: '${_member.durationMonths * 30} days',
                ),
                _DetailRow(
                  label: 'Duration',
                  value: '${_member.durationMonths} months',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _member.membershipActive
                        ? const Color(0xFFDFF1E5)
                        : const Color(0xFFF9DADA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _member.membershipActive
                        ? 'Membership Active'
                        : 'Payment Pending',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _member.membershipActive
                              ? const Color(0xFF1C3B2E)
                              : const Color(0xFF8A1B1B),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FaceIdCheckInCallout(
            title: 'Face ID Check-In',
            subtitle:
                'Use a live scan to log attendance for this member.',
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Log',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<AttendanceLog>>(
                  future: service.attendanceForMember(_member.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final logs = snapshot.data ?? const <AttendanceLog>[];
                    if (logs.isEmpty) {
                      return Text(
                        'No attendance records yet.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54),
                      );
                    }
                    return Column(
                      children: logs
                          .map(
                            (log) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle,
                                      size: 8, color: Color(0xFF1C3B2E)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM d, y · h:mm a')
                                          .format(log.timestamp.toLocal()),
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final updated = await pickDateTime(
                                          context,
                                          initial: log.timestamp.toLocal(),
                                        );
                                        if (updated == null) return;
                                        await SupabaseService().updateAttendance(
                                          attendanceId: log.id,
                                          timestamp: updated,
                                        );
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      } else if (value == 'delete') {
                                        final confirmed =
                                            await confirmDestructiveAction(
                                          context,
                                          title: 'Delete attendance?',
                                          message:
                                              'This will remove the attendance record.',
                                          confirmLabel: 'Delete',
                                        );
                                        if (!confirmed) return;
                                        await SupabaseService()
                                            .deleteAttendance(log.id);
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit time'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _paymentController = TextEditingController();
  final _customDaysController = TextEditingController();
  bool _membershipActive = true;
  bool _useCustomDays = false;
  bool _isSaving = false;
  bool _isCapturingFace = false;
  bool _isEnrollingFace = false;
  bool _faceEnrolled = false;
  Uint8List? _faceImageBytes;
  String? _faceErrorText;
  String? _createdMemberId;
  String? _errorText;
  int? _selectedDurationMonths;
  String? _durationErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _paymentController.dispose();
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _captureFace() async {
    if (_isCapturingFace) return;
    setState(() {
      _isCapturingFace = true;
      _faceErrorText = null;
    });
    try {
      Uint8List? bytes;
      if (useImagePickerForFaceCapture()) {
        final imagePicker = ImagePicker();
        final image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image == null) return;
        bytes = await image.readAsBytes();
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        if (!mounted) return;
        bytes = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (_) => const FaceCaptureMacOSScreen(),
          ),
        );
        if (bytes == null) return;
      } else {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          setState(() {
            _faceErrorText = 'No camera found on this device.';
          });
          return;
        }
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        if (!mounted) return;
        bytes = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (_) => FaceCaptureScreen(camera: frontCamera),
          ),
        );
        if (bytes == null) return;
      }
      setState(() {
        _faceImageBytes = bytes;
        _faceEnrolled = false;
      });
    } catch (error) {
      setState(() {
        _faceErrorText = 'Failed to capture face image: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isCapturingFace = false);
      }
    }
  }

  Future<bool> _enrollFace(String memberId) async {
    if (_faceImageBytes == null) {
      setState(() => _faceErrorText = 'Capture a face photo before saving.');
      return false;
    }
    setState(() {
      _isEnrollingFace = true;
      _faceErrorText = null;
    });
    try {
      final success = await SupabaseService().enrollFace(
        memberId: memberId,
        imageBytes: _faceImageBytes!,
      );
      if (!success) {
        setState(() {
          _faceErrorText = 'Face registration failed. Please try again.';
        });
        return false;
      }
      setState(() => _faceEnrolled = true);
      return true;
    } on PostgrestException catch (error) {
      setState(() {
        _faceErrorText = error.message;
      });
      return false;
    } catch (error) {
      setState(() {
        _faceErrorText = 'Face registration failed: $error';
      });
      return false;
    } finally {
      if (mounted) {
        setState(() => _isEnrollingFace = false);
      }
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_faceImageBytes == null) {
      setState(() {
        _faceErrorText = 'Capture a face photo to complete registration.';
      });
      return;
    }
    setState(() => _isSaving = true);
    final service = SupabaseService();
    try {
      final customDaysText = _customDaysController.text.trim();
      int? durationMonths;
      String? durationError;
      if (_useCustomDays) {
        final days = int.tryParse(customDaysText);
        if (days == null || days <= 0) {
          durationError = 'Enter valid custom days';
        } else {
          durationMonths = (days / 30).ceil();
        }
      } else if (_selectedDurationMonths != null) {
        durationMonths = _selectedDurationMonths;
      } else {
        durationError = 'Select a duration';
      }

      if (durationError != null) {
        setState(() {
          _durationErrorText = durationError;
          _isSaving = false;
        });
        return;
      }

      final memberId = _createdMemberId ??
          await service.addMemberReturningId(
            MemberInput(
              name: _nameController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              email: _emailController.text.trim(),
              age: int.parse(_ageController.text.trim()),
              paymentAmount: int.parse(_paymentController.text.trim()),
              durationMonths: durationMonths!,
              membershipActive: _membershipActive,
            ),
          );
      _createdMemberId = memberId;

      final enrolled = await _enrollFace(memberId);
      if (!enrolled) return;

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (error) {
      setState(() {
        _errorText = error.message;
      });
    } catch (_) {
      setState(() {
        _errorText = 'Failed to add member. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: const Text('Add Member'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF6),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TextFormField(
                    label: 'Name',
                    controller: _nameController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter name'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _TextFormField(
                    label: 'Mobile Number',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter mobile number'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _TextFormField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter email'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _TextFormField(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter age'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _TextFormField(
                    label: 'Payment Amount',
                    controller: _paymentController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter payment amount'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Membership Duration',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...[1, 3, 6, 12]
                        .map(
                          (months) => ChoiceChip(
                            label: Text('$months months'),
                            selected: _selectedDurationMonths == months &&
                                !_useCustomDays,
                            onSelected: (selected) {
                              setState(() {
                                _durationErrorText = null;
                                _selectedDurationMonths =
                                    selected ? months : null;
                                if (selected) {
                                  _useCustomDays = false;
                                  _customDaysController.clear();
                                }
                              });
                            },
                            selectedColor: const Color(0xFF1C3B2E),
                            labelStyle: TextStyle(
                              color: _selectedDurationMonths == months &&
                                      !_useCustomDays
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        )
                        ,
                      ChoiceChip(
                        label: const Text('Custom days'),
                        selected: _useCustomDays,
                        onSelected: (selected) {
                          setState(() {
                            _durationErrorText = null;
                            _useCustomDays = selected;
                            if (selected) {
                              _selectedDurationMonths = null;
                            } else {
                              _customDaysController.clear();
                            }
                          });
                        },
                        selectedColor: const Color(0xFF1C3B2E),
                        labelStyle: TextStyle(
                          color: _useCustomDays ? Colors.white : Colors.black87,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  if (_useCustomDays) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customDaysController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setState(() {
                          _durationErrorText = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter custom days',
                        hintText: 'e.g. 45',
                        filled: true,
                        fillColor: const Color(0xFFF6F2ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Custom days will be converted to months in records.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                  if (_durationErrorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _durationErrorText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xFF8A1B1B)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Register Face ID',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_faceImageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        _faceImageBytes!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_faceImageBytes != null) const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1C3B2E),
                        side: const BorderSide(color: Color(0xFF1C3B2E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isCapturingFace ? null : _captureFace,
                      icon: const Icon(Icons.face_retouching_natural),
                      label: _isCapturingFace
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF1C3B2E),
                              ),
                            )
                          : Text(_faceImageBytes == null
                              ? (kIsWeb
                                  ? 'Select Face ID Photo'
                                  : 'Capture Face ID')
                              : 'Retake Face ID'),
                    ),
                  ),
                  if (_faceEnrolled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Face ID linked successfully.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF1C3B2E),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  if (_faceErrorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _faceErrorText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xFF8A1B1B)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Membership Active'),
                    value: _membershipActive,
                    onChanged: (value) {
                      setState(() => _membershipActive = value);
                    },
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorText!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFF8A1B1B)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C3B2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isSaving || _isEnrollingFace ? null : _saveMember,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Register Member'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditMemberScreen extends StatefulWidget {
  const EditMemberScreen({super.key, required this.member});

  final Member member;

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;
  late final TextEditingController _paymentController;
  late final TextEditingController _durationController;
  bool _membershipActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _mobileController = TextEditingController(text: widget.member.mobileNumber);
    _emailController = TextEditingController(text: widget.member.email);
    _ageController =
        TextEditingController(text: widget.member.age.toString());
    _paymentController =
        TextEditingController(text: widget.member.paymentAmount.toString());
    _durationController =
        TextEditingController(text: widget.member.durationMonths.toString());
    _membershipActive = widget.member.membershipActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _paymentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseService().updateMember(
        memberId: widget.member.id,
        input: MemberInput(
          name: _nameController.text.trim(),
          mobileNumber: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          paymentAmount: int.parse(_paymentController.text.trim()),
          durationMonths: int.parse(_durationController.text.trim()),
          membershipActive: _membershipActive,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update member.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteMember() async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Delete member?',
      message:
          'This will remove the member, their attendance records, and face ID data. This action cannot be undone.',
      confirmLabel: 'Delete Member',
    );
    if (!confirmed) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseService().deleteMember(widget.member.id);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete member.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: const Text('Edit Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _LabeledFormField(
                    label: 'Name',
                    controller: _nameController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a name'
                            : null,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 14),
                  _LabeledFormField(
                    label: 'Mobile Number',
                    controller: _mobileController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a mobile number'
                            : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _LabeledFormField(
                    label: 'Email',
                    controller: _emailController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter an email'
                            : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _LabeledFormField(
                    label: 'Age',
                    controller: _ageController,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter a valid age'
                            : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _LabeledFormField(
                    label: 'Payment Amount',
                    controller: _paymentController,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter a valid amount'
                            : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _LabeledFormField(
                    label: 'Duration (months)',
                    controller: _durationController,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter a valid duration'
                            : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Membership Active'),
                    value: _membershipActive,
                    onChanged: (value) {
                      setState(() => _membershipActive = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C3B2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8A1B1B),
                  side: const BorderSide(color: Color(0xFF8A1B1B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSaving ? null : _deleteMember,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Member'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});

  @override
  State<AttendanceInputScreen> createState() => _AttendanceInputScreenState();
}

class _AttendanceInputScreenState extends State<AttendanceInputScreen> {
  Member? _selectedMember;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;
  bool _isRecognizing = false;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _memberSearchController = TextEditingController();

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitManual() async {
    if (_selectedMember == null) return;
    setState(() => _isSaving = true);
    final timestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    try {
      await SupabaseService().addAttendance(
        memberId: _selectedMember!.id,
        timestamp: timestamp,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save attendance.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _submitBiometric() async {
    if (_selectedMember == null) return;
    setState(() => _isSaving = true);
    try {
      await SupabaseService().addAttendance(
        memberId: _selectedMember!.id,
        timestamp: DateTime.now(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save attendance.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<String> _resolvePunchAction(
    String memberId,
    DateTime timestamp,
  ) async {
    final recent = await SupabaseService().attendanceForMember(memberId);
    final todayCount = recent.where((log) => _isSameDay(log.timestamp, timestamp));
    return todayCount.length.isEven ? 'Punch in' : 'Punch out';
  }

  Future<void> _submitFaceId() async {
    if (_isRecognizing) return;
    setState(() => _isRecognizing = true);
    final service = SupabaseService();
    try {
      Uint8List? bytes;
      if (useImagePickerForFaceCapture()) {
        final image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (image == null) return;
        bytes = await image.readAsBytes();
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        if (!mounted) return;
        bytes = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (_) => const FaceCaptureMacOSScreen(
              title: 'Capture Face ID',
            ),
          ),
        );
        if (bytes == null) return;
      } else {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No camera found on this device.')),
            );
          }
          return;
        }
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        if (!mounted) return;
        bytes = await Navigator.of(context).push<Uint8List>(
          MaterialPageRoute(
            builder: (_) => FaceCaptureScreen(camera: frontCamera),
          ),
        );
        if (bytes == null) return;
      }
      final result = await service.recognizeFace(bytes);
      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No matching member found.')),
          );
        }
        return;
      }

      final timestamp = DateTime.now();
      final action = await _resolvePunchAction(result.memberId, timestamp);
      await service.addAttendance(
        memberId: result.memberId,
        timestamp: timestamp,
      );
      final member = await service.memberById(result.memberId);
      final name = member?.name ?? 'Member';
      final confidence = result.confidence == null
          ? ''
          : ' (${(result.confidence! * 100).toStringAsFixed(1)}% match)';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action recorded for $name$confidence.')),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Face ID capture failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecognizing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: const Text('Attendance Input'),
      ),
      body: StreamBuilder<List<Member>>(
        stream: service.watchMembers(),
        builder: (context, snapshot) {
          final members = snapshot.data ?? const <Member>[];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FaceIdCheckInCallout(
                      title: 'Face ID Check-In',
                      subtitle:
                          'Use a live scan to identify members and log attendance.',
                      showButton: false,
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Member',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _memberSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or mobile',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF6F2ED),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5DED7)),
                    ),
                    child: Builder(
                      builder: (context) {
                        final query =
                            _memberSearchController.text.trim().toLowerCase();
                        final filteredMembers = query.isEmpty
                            ? members
                            : members
                                .where(
                                  (member) =>
                                      member.name
                                          .toLowerCase()
                                          .contains(query) ||
                                      member.id
                                          .toLowerCase()
                                          .contains(query) ||
                                      member.mobileNumber
                                          .toLowerCase()
                                          .contains(query),
                                )
                                .toList();
                        if (filteredMembers.isEmpty) {
                          return Text(
                            'No members found.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            final isSelected =
                                _selectedMember?.id == member.id;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () {
                                setState(() => _selectedMember = member);
                              },
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? const Color(0xFF1C3B2E)
                                    : const Color(0xFFE0A458),
                                child: Text(
                                  member.name.substring(0, 1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(member.name),
                              subtitle: Text(
                                'ID: ${member.id} · ${member.mobileNumber.isEmpty ? 'Mobile number not available.' : member.mobileNumber}',
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF1C3B2E),
                                    )
                                  : null,
                            );
                          },
                          separatorBuilder: (_, _) =>
                              const Divider(height: 12),
                          itemCount: filteredMembers.length,
                        );
                      },
                    ),
                  ),
                    const SizedBox(height: 20),
                    Text(
                      'Manual Entry',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    _SelectorTile(
                      label: 'Date',
                      value: DateFormat('MMM d, y').format(_selectedDate),
                      icon: Icons.calendar_month,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 10),
                    _SelectorTile(
                      label: 'Time',
                      value: _selectedTime.format(context),
                      icon: Icons.access_time,
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C3B2E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving ? null : _submitManual,
                        child: const Text('Save Manual Attendance'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Biometric Capture',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Press capture to store the latest biometric timestamp.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1C3B2E),
                          side: const BorderSide(color: Color(0xFF1C3B2E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving ? null : _submitBiometric,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Capture Biometric Timestamp'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Face ID Attendance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the front camera to identify the member and log punch-in/out automatically.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1C3B2E),
                          side: const BorderSide(color: Color(0xFF1C3B2E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            _isRecognizing || _isSaving ? null : _submitFaceId,
                        icon: const Icon(Icons.face_retouching_natural),
                        label: _isRecognizing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Color(0xFF1C3B2E),
                                ),
                              )
                            : const Text('Capture Face ID'),
                      ),
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
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F2ED),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1C3B2E)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F2ED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF6F2ED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledFormField extends StatelessWidget {
  const _LabeledFormField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F2ED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class FaceIdCheckInCallout extends StatelessWidget {
  const FaceIdCheckInCallout({
    super.key,
    required this.title,
    required this.subtitle,
    this.showButton = true,
    this.buttonLabel = 'Open Face ID Check-In',
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final bool showButton;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DED7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          if (subtitle.trim().isNotEmpty)
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          if (showButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C3B2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onPressed ??
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AttendanceInputScreen(),
                        ),
                      );
                    },
                icon: const Icon(Icons.face_retouching_natural),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.onTap,
    required this.onEdit,
    required this.onEditFaceId,
    required this.onDelete,
  });

  final Member member;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onEditFaceId;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1C3B2E),
                    child: Text(
                      member.name.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              member.id,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C3B2E),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member.mobileNumber.isEmpty
                              ? 'Mobile number not available.'
                              : member.mobileNumber,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.durationMonths == 1
                    ? '1 month'
                    : '${member.durationMonths} months',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${member.durationMonths * 30} days left',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: member.membershipActive
                      ? const Color(0xFFDFF1E5)
                      : const Color(0xFFF9DADA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.membershipActive ? 'Active' : 'Pending',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: member.membershipActive
                            ? const Color(0xFF1C3B2E)
                            : const Color(0xFF8A1B1B),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'face') {
                    onEditFaceId();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'face', child: Text('Edit Face ID')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceLogCard extends StatelessWidget {
  const _AttendanceLogCard({
    required this.logs,
    required this.punchLabels,
    this.onEdit,
    this.onDelete,
  });

  final List<AttendanceLog> logs;
  final Map<String, String> punchLabels;
  final Future<void> Function(AttendanceLog log)? onEdit;
  final Future<void> Function(AttendanceLog log)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: logs
            .map(
              (log) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AttendanceRow(
                          name: log.memberName,
                          mobile: log.memberMobile,
                          memberId: log.memberId,
                          punchLabel: punchLabels[log.id] ?? 'Punch',
                          time: DateFormat('MMM d, y · h:mm a')
                              .format(log.timestamp.toLocal()),
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit' && onEdit != null) {
                              await onEdit!(log);
                            } else if (value == 'delete' && onDelete != null) {
                              await onDelete!(log);
                            }
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit time'),
                              ),
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                          ],
                        ),
                    ],
                  ),
                  if (log != logs.last) const Divider(height: 22),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.name,
    required this.mobile,
    required this.memberId,
    required this.punchLabel,
    required this.time,
  });

  final String name;
  final String mobile;
  final String memberId;
  final String punchLabel;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: Color(0xFF1C3B2E)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    memberId,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF1C3B2E),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                mobile.isEmpty ? 'Mobile number not available.' : mobile,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: punchLabel == 'Punch In'
                    ? const Color(0xFFDFF1E5)
                    : const Color(0xFFF9DADA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                punchLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: punchLabel == 'Punch In'
                          ? const Color(0xFF1C3B2E)
                          : const Color(0xFF8A1B1B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE0A458),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1C3B2E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCharts extends StatelessWidget {
  const _KpiCharts({required this.logs});

  final List<AttendanceLog> logs;

  List<int> _dailyCounts(DateTime today) {
    final days = List.generate(
      7,
      (index) => DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - index)),
    );
    final counts = List<int>.filled(7, 0);
    for (final log in logs) {
      final local = log.timestamp.toLocal();
      for (var i = 0; i < days.length; i++) {
        final day = days[i];
        if (local.year == day.year &&
            local.month == day.month &&
            local.day == day.day) {
          counts[i] += 1;
          break;
        }
      }
    }
    return counts;
  }

  List<int> _monthlyCounts(DateTime today) {
    final months = List.generate(
      6,
      (index) => DateTime(today.year, today.month - (5 - index), 1),
    );
    final counts = List<int>.filled(6, 0);
    for (final log in logs) {
      final local = log.timestamp.toLocal();
      for (var i = 0; i < months.length; i++) {
        final month = months[i];
        if (local.year == month.year && local.month == month.month) {
          counts[i] += 1;
          break;
        }
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dailyCounts = _dailyCounts(now);
    final monthlyCounts = _monthlyCounts(now);
    final dailyLabels = List.generate(
      7,
      (index) => DateFormat('E')
          .format(now.subtract(Duration(days: 6 - index)))
          .substring(0, 1),
    );
    final monthlyLabels = List.generate(
      6,
      (index) => DateFormat('MMM')
          .format(DateTime(now.year, now.month - (5 - index), 1)),
    );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5DED7)),
            ),
            child: TabBar(
              labelColor: const Color(0xFF1C3B2E),
              unselectedLabelColor: Colors.black54,
              indicatorColor: const Color(0xFF1C3B2E),
              tabs: const [
                Tab(text: 'Daily'),
                Tab(text: 'Monthly'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: TabBarView(
              children: [
                _InteractiveBarChart(
                  title: 'Daily Visits',
                  subtitle: 'Last 7 days',
                  labels: dailyLabels,
                  values: dailyCounts,
                  barColor: const Color(0xFF1C3B2E),
                ),
                _InteractiveBarChart(
                  title: 'Monthly Visits',
                  subtitle: 'Last 6 months',
                  labels: monthlyLabels,
                  values: monthlyCounts,
                  barColor: const Color(0xFFE0A458),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveBarChart extends StatefulWidget {
  const _InteractiveBarChart({
    required this.title,
    required this.subtitle,
    required this.labels,
    required this.values,
    required this.barColor,
  });

  final String title;
  final String subtitle;
  final List<String> labels;
  final List<int> values;
  final Color barColor;

  @override
  State<_InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<_InteractiveBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final maxValueRaw = widget.values.isEmpty
        ? 0
        : widget.values.reduce((a, b) => a > b ? a : b);
    final maxValue = maxValueRaw == 0 ? 1 : maxValueRaw;
    final selectedValue =
        _selectedIndex == null ? null : widget.values[_selectedIndex!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (selectedValue != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F2ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedValue visits',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.values.length, (index) {
                final value = widget.values[index];
                final heightFactor = value / maxValue;
                final isSelected = _selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = isSelected ? null : index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 16 + (100 * heightFactor),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.barColor
                                  : widget.barColor.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.labels[index],
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF1C3B2E),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFF6F2ED),
      checkmarkColor: Colors.white,
    );
  }
}
