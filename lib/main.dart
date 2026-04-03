import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const GymProApp());
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
      home: const LoginScreen(),
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
                  timestamp: DateTime.parse(row['timestamp'] as String),
                ),
              )
              .toList(),
        );
  }

  Future<void> addMember(MemberInput input) async {
    await _client.from('members').insert({
      'name': input.name,
      'email': input.email,
      'age': input.age,
      'payment_amount': input.paymentAmount,
      'duration_months': input.durationMonths,
      'membership_active': input.membershipActive,
    });
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
            timestamp: DateTime.parse(row['timestamp'] as String),
          ),
        )
        .toList();
  }
}

class Member {
  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.paymentAmount,
    required this.durationMonths,
    required this.membershipActive,
  });

  final String id;
  final String name;
  final String email;
  final int age;
  final int paymentAmount;
  final int durationMonths;
  final bool membershipActive;
}

class MemberInput {
  const MemberInput({
    required this.name,
    required this.email,
    required this.age,
    required this.paymentAmount,
    required this.durationMonths,
    required this.membershipActive,
  });

  final String name;
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
    required this.timestamp,
  });

  final String id;
  final String memberId;
  final String memberName;
  final DateTime timestamp;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: 'owner@gympro.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '••••••••');
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
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
      body: StreamBuilder<List<Member>>(
        stream: service.watchMembers(),
        builder: (context, memberSnapshot) {
          final members = memberSnapshot.data ?? const <Member>[];
          final memberNameById = {
            for (final member in members) member.id: member.name,
          };
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0A458), Color(0xFFF6D7A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today’s Check-ins',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: const Color(0xFF1C3B2E)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Biometric device is connected and streaming timestamps.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: const Color(0xFF1C3B2E)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C3B2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 20),
              Text(
                'Member List',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
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
                              memberNameById[log.memberId] ?? 'Member',
                          timestamp: log.timestamp,
                        ),
                      )
                      .toList();
                  return _AttendanceLogCard(logs: resolvedLogs);
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F2ED),
        elevation: 0,
        title: const Text('Member Details'),
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
                  member.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                _DetailRow(label: 'Email', value: member.email),
                _DetailRow(label: 'Age', value: '${member.age} years'),
                _DetailRow(
                  label: 'Payment Amount',
                  value: '₹${member.paymentAmount}',
                ),
                _DetailRow(
                  label: 'Duration',
                  value: '${member.durationMonths} months',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: member.membershipActive
                        ? const Color(0xFFDFF1E5)
                        : const Color(0xFFF9DADA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member.membershipActive
                        ? 'Membership Active'
                        : 'Payment Pending',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: member.membershipActive
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
                  future: service.attendanceForMember(member.id),
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
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _paymentController = TextEditingController();
  final _durationController = TextEditingController();
  bool _membershipActive = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _paymentController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final service = SupabaseService();
    await service.addMember(
      MemberInput(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        paymentAmount: int.parse(_paymentController.text.trim()),
        durationMonths: int.parse(_durationController.text.trim()),
        membershipActive: _membershipActive,
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
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
                  _TextFormField(
                    label: 'Membership Duration (months)',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Enter duration'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Membership Active'),
                    value: _membershipActive,
                    onChanged: (value) {
                      setState(() => _membershipActive = value);
                    },
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
                      onPressed: _isSaving ? null : _saveMember,
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Member'),
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
    await SupabaseService().addAttendance(
      memberId: _selectedMember!.id,
      timestamp: timestamp,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitBiometric() async {
    if (_selectedMember == null) return;
    setState(() => _isSaving = true);
    await SupabaseService().addAttendance(
      memberId: _selectedMember!.id,
      timestamp: DateTime.now(),
    );
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
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
                    Text(
                      'Member',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Member>(
                      key: ValueKey(_selectedMember?.id ?? ''),
                      initialValue: _selectedMember,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF6F2ED),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text('Select member'),
                      items: members
                          .map(
                            (member) => DropdownMenuItem<Member>(
                              value: member,
                              child: Text(member.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedMember = value);
                      },
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
  const _MemberTile({required this.member, required this.onTap});

  final Member member;
  final VoidCallback onTap;

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
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.email,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${member.paymentAmount}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceLogCard extends StatelessWidget {
  const _AttendanceLogCard({required this.logs});

  final List<AttendanceLog> logs;

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
                  _AttendanceRow(
                    name: log.memberName,
                    time: DateFormat('h:mm a').format(log.timestamp.toLocal()),
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
  const _AttendanceRow({required this.name, required this.time});

  final String name;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: Color(0xFF1C3B2E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          time,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
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
