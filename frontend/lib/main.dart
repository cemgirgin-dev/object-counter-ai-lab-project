import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'advanced_mode_screen.dart';

const String baseHost = String.fromEnvironment('BASE_HOST', defaultValue: '127.0.0.1');

void main() {
  runApp(const AIObjectCounterApp());
}

class AIObjectCounterApp extends StatelessWidget {
  const AIObjectCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Object Counter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const ObjectCounterScreen(),
    const AdvancedModeScreen(),
    const ImageGeneratorScreen(),
    const MonitorScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Basic Mode',
      color: const Color(0xFF6366F1),
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      selectedIcon: Icons.psychology,
      label: 'Advanced',
      color: const Color(0xFF8B5CF6),
    ),
    NavigationItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'Generator',
      color: const Color(0xFF06B6D4),
    ),
    NavigationItem(
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart,
      label: 'Monitor',
      color: const Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index != _selectedIndex) {
      _animationController.reset();
      setState(() => _selectedIndex = index);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Object Counter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              _navigationItems[_selectedIndex].label,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _screens[_selectedIndex],
                    ),
                  ),
                ),
              ),
              // Custom Bottom Navigation
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _navigationItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      NavigationItem item = entry.value;
                      bool isSelected = index == _selectedIndex;

                      return GestureDetector(
                        onTap: () => _onDestinationSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? item.color.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected
                                      ? item.color
                                      : Colors.grey[600],
                                  size: 24,
                                  key: ValueKey('$index-$isSelected'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? item.color
                                      : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });
}

class ObjectCounterScreen extends StatefulWidget {
  const ObjectCounterScreen({super.key});

  @override
  State<ObjectCounterScreen> createState() => _ObjectCounterScreenState();
}

class _ObjectCounterScreenState extends State<ObjectCounterScreen>
    with TickerProviderStateMixin {
  final String baseUrl = 'http://$baseHost:8000';

  String? selectedObjectType;
  Uint8List? selectedImage;
  String? imageName;
  bool isProcessing = false;
  CountResult? lastResult;
  List<String> objectTypes = [];

  final TextEditingController correctionController = TextEditingController();

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadObjectTypes();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    correctionController.dispose();
    super.dispose();
  }

  Future<void> _loadObjectTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/object-types'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          objectTypes = List<String>.from(data['object_types']);
        });
      }
    } catch (e) {
      print('Error loading object types: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          setState(() {
            selectedImage = fileBytes;
            imageName = result.files.first.name;
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _processImage() async {
    if (selectedImage == null || selectedObjectType == null) {
      _showSnackBar('Please select an image and object type');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // Start pulsing animation
    _pulseController.repeat(reverse: true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/count'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedImage!,
          filename: imageName ?? 'image.jpg',
        ),
      );

      request.fields['object_type'] = selectedObjectType!;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          lastResult = CountResult.fromJson(data);
        });
        _showSnackBar('✨ Processing completed successfully!');
        HapticFeedback.lightImpact();
      } else if (response.statusCode == 403) {
        // Handle safety system block
        try {
          final errorData = json.decode(responseBody);
          final reason = errorData['reason'] ?? 'Unknown safety reason';
          final message =
              errorData['message'] ?? 'Request blocked by safety system';

          setState(() {
            lastResult = null; // Clear any previous results
          });

          _showSnackBar('🛡️ SAFETY BLOCKED: $message', isError: true);
          _showDetailedError('Safety Check Failed', message, reason, errorData);
          HapticFeedback.heavyImpact();
        } catch (e) {
          _showSnackBar(
            '🛡️ SAFETY BLOCKED: Request blocked by safety system',
            isError: true,
          );
          HapticFeedback.heavyImpact();
        }
      } else {
        _showSnackBar('❌ Error processing image: ${response.statusCode}');
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      _showSnackBar('❌ Error processing image: $e');
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        isProcessing = false;
      });
      _pulseController.stop();
    }
  }

  Future<void> _submitCorrection() async {
    if (lastResult == null || correctionController.text.isEmpty) {
      _showSnackBar('Please enter a correction');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/correct'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'result_id': lastResult!.resultId,
          'corrected_count': int.parse(correctionController.text),
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Correction submitted successfully!');
        correctionController.clear();
      } else {
        _showSnackBar('Error submitting correction');
      }
    } catch (e) {
      _showSnackBar('Error submitting correction: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDetailedError(
    String title,
    String message,
    String reason,
    Map<String, dynamic> errorData,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF5F5), Color(0xFFFFEBEE)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Safety System Protection',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7F1D1D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reason',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Safety Details
                if (errorData['safety_details'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Safety Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Confidence',
                          '${(errorData['safety_details']['confidence'] * 100).toStringAsFixed(1)}%',
                          Icons.analytics,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Processing Time',
                          '${errorData['safety_details']['processing_time']?.toStringAsFixed(3)}s',
                          Icons.timer,
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Model',
                          errorData['safety_details']['model_used'] ??
                              'Unknown',
                          Icons.smart_toy,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Understood'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getObjectIcon(String objectType) {
    switch (objectType.toLowerCase()) {
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      case 'car':
        return Icons.directions_car;
      case 'person':
        return Icons.person;
      case 'tree':
        return Icons.park;
      case 'building':
        return Icons.business;
      case 'sky':
        return Icons.wb_sunny;
      case 'ground':
        return Icons.landscape;
      case 'hardware':
        return Icons.hardware;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isProcessing ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AI Object Counter',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload an image and count objects using advanced AI technology',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isProcessing) ...[
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'AI is analyzing your image...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'This may take a few seconds',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Image Upload Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Upload Image',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DragTarget<Uint8List>(
                    onWillAcceptWithDetails: (details) => !isProcessing,
                    onAcceptWithDetails: (details) {
                      if (!isProcessing) {
                        setState(() {
                          selectedImage = details.data;
                          imageName = 'Dropped Image';
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: isProcessing ? null : _pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? const Color(0xFF6366F1)
                                  : selectedImage != null
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFE5E7EB),
                              width:
                                  candidateData.isNotEmpty ||
                                      selectedImage != null
                                  ? 2
                                  : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: candidateData.isNotEmpty
                                ? const Color(0xFF6366F1).withOpacity(0.1)
                                : selectedImage != null
                                ? const Color(0xFF6366F1).withOpacity(0.05)
                                : const Color(0xFFF9FAFB),
                          ),
                          child: selectedImage != null
                              ? Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.memory(
                                                selectedImage!,
                                                height: 120,
                                                width: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              imageName ?? 'Selected Image',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6366F1),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedImage = null;
                                            imageName = null;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: candidateData.isNotEmpty
                                            ? const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.2)
                                            : const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        candidateData.isNotEmpty
                                            ? Icons.cloud_download
                                            : Icons.cloud_upload_outlined,
                                        size: 40,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      candidateData.isNotEmpty
                                          ? 'Drop image here'
                                          : 'Tap or drag to select image',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Supports JPG, PNG, and other formats',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Object Type Selection
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Color(0xFF8B5CF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Select Object Type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedObjectType,
                    decoration: InputDecoration(
                      labelText: 'Object Type',
                      hintText: 'Select object type to count',
                      prefixIcon: const Icon(Icons.category),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                    items: objectTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getObjectIcon(type),
                                size: 18,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: isProcessing
                        ? null
                        : (String? newValue) {
                            setState(() {
                              selectedObjectType = newValue;
                            });
                            HapticFeedback.lightImpact();
                          },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Process Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : _processImage,
                icon: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.analytics, size: 24),
                label: Text(
                  isProcessing ? 'Processing...' : 'Count Objects',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProcessing
                      ? Colors.grey[400]
                      : const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: isProcessing ? 0 : 8,
                  shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Results Section
            if (lastResult != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Detection Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultCard(
                            'Count',
                            lastResult!.count.toString(),
                            Icons.numbers,
                            Colors.white,
                            const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResultCard(
                            'Confidence',
                            '${(lastResult!.confidence * 100).toStringAsFixed(1)}%',
                            Icons.analytics,
                            Colors.white,
                            const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultCard(
                            'Object Type',
                            lastResult!.objectType.toUpperCase(),
                            Icons.category,
                            Colors.white,
                            const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildResultCard(
                            'Processing Time',
                            '${lastResult!.processingTime?.toStringAsFixed(2)}s',
                            Icons.timer,
                            Colors.white,
                            const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Correction Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFF59E0B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Correction',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'If the count is incorrect, please provide the correct count:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: correctionController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Correct count',
                              hintText: 'Enter the actual count',
                              prefixIcon: const Icon(Icons.edit),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _submitCorrection,
                          icon: const Icon(Icons.send, size: 20),
                          label: const Text('Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon,
    Color textColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class CountResult {
  final String resultId;
  final String objectType;
  final int count;
  final double confidence;
  final String? segmentedImagePath;
  final double? processingTime;

  CountResult({
    required this.resultId,
    required this.objectType,
    required this.count,
    required this.confidence,
    this.segmentedImagePath,
    this.processingTime,
  });

  factory CountResult.fromJson(Map<String, dynamic> json) {
    return CountResult(
      resultId: json['result_id'],
      objectType: json['object_type'],
      count: json['count'],
      confidence: json['confidence'].toDouble(),
      segmentedImagePath: json['segmented_image_path'],
      processingTime: json['processing_time']?.toDouble(),
    );
  }
}

// Image Generator Screen
class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({super.key});

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final String baseUrl = 'http://$baseHost:8000';
  String selectedObjectType = 'cat';
  int imageCount = 3;
  double blurLevel = 0.0;
  double rotationRange = 0.0;
  double noiseLevel = 0.0;
  bool isGenerating = false;
  List<String> generatedImages = [];

  final List<String> objectTypes = [
    'cat',
    'dog',
    'car',
    'person',
    'tree',
    'building',
    'sky',
    'ground',
    'hardware',
  ];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _generateImages() async {
    setState(() => isGenerating = true);
    try {
      // Call the image generation script
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate-images'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'object_type': selectedObjectType,
          'count': imageCount,
          'blur_level': blurLevel,
          'rotation_range': rotationRange,
          'noise_level': noiseLevel,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          generatedImages = List<String>.from(data['generated_images'] ?? []);
        });
        _showSnackBar(
          'Generated ${generatedImages.length} images successfully!',
        );
      } else {
        _showSnackBar('Error generating images: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error generating images: $e');
    } finally {
      setState(() => isGenerating = false);
    }
  }

  IconData _getObjectIcon(String objectType) {
    switch (objectType.toLowerCase()) {
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      case 'car':
        return Icons.directions_car;
      case 'person':
        return Icons.person;
      case 'tree':
        return Icons.park;
      case 'building':
        return Icons.business;
      case 'sky':
        return Icons.wb_sunny;
      case 'ground':
        return Icons.landscape;
      case 'hardware':
        return Icons.hardware;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Image Generator',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate test images with various augmentations for training',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Generation Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedObjectType,
                    decoration: const InputDecoration(
                      labelText: 'Object Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: objectTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              _getObjectIcon(type),
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(type.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => selectedObjectType = newValue!);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Number of Images: $imageCount',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: imageCount.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) =>
                        setState(() => imageCount = value.round()),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Blur Level: ${blurLevel.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: blurLevel,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) => setState(() => blurLevel = value),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rotation Range: ${rotationRange.toStringAsFixed(0)}°',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: rotationRange,
                    min: 0.0,
                    max: 45.0,
                    divisions: 9,
                    onChanged: (value) => setState(() => rotationRange = value),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Noise Level: ${noiseLevel.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: noiseLevel,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) => setState(() => noiseLevel = value),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: isGenerating ? null : _generateImages,
                      icon: isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        isGenerating ? 'Generating...' : 'Generate Images',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (generatedImages.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Generated Images',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: generatedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              generatedImages[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFFF9FAFB),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Color(0xFF6366F1)),
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF9FAFB),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Monitor Screen
class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  final String baseUrl = 'http://$baseHost:8000';
  Map<String, dynamic>? metrics;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/metrics'));
      if (response.statusCode == 200) {
        // Parse Prometheus metrics (simplified)
        setState(() {
          metrics = {
            'status': 'Connected',
            'timestamp': DateTime.now().toIso8601String(),
          };
        });
      }
    } catch (e) {
      setState(() {
        metrics = {'status': 'Error', 'error': e.toString()};
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.monitor_heart,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'System Monitoring',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor system performance and metrics in real-time',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Metrics Status',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _loadMetrics,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh metrics',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (metrics != null) ...[
                    _buildMetricCard(
                      'Backend Status',
                      metrics!['status'],
                      metrics!['status'] == 'Connected'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricCard(
                      'Last Updated',
                      metrics!['timestamp']?.substring(11, 19) ?? 'Unknown',
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Monitoring Links',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLinkCard(
                    'Prometheus',
                    'http://$baseHost:9090',
                    Icons.analytics,
                  ),
                  const SizedBox(height: 12),
                  _buildLinkCard(
                    'Grafana',
                    'http://$baseHost:3001',
                    Icons.dashboard,
                  ),
                  const SizedBox(height: 12),
                  _buildLinkCard(
                    'API Metrics',
                    'http://$baseHost:8000/metrics',
                    Icons.api,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(String title, String url, IconData icon) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not open $url')));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    url,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
