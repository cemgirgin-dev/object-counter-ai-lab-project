import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

const String baseHost = String.fromEnvironment('BASE_HOST', defaultValue: '127.0.0.1');

class AdvancedModeScreen extends StatefulWidget {
  const AdvancedModeScreen({super.key});

  @override
  State<AdvancedModeScreen> createState() => _AdvancedModeScreenState();
}

class _AdvancedModeScreenState extends State<AdvancedModeScreen> {
  final String baseUrl = 'http://$baseHost:8000';
  List<String> learnedObjects = [];
  bool isLoading = false;

  // Learning section state
  String selectedObjectType = '';
  final TextEditingController objectTypeController = TextEditingController();
  List<Uint8List> trainingImages = [];
  List<String> trainingImageNames = [];
  bool isLearning = false;

  // Testing section state
  Uint8List? testImage;
  String? testImageName;
  String? testObjectType;
  bool isTesting = false;
  Map<String, dynamic>? testResult;

  @override
  void initState() {
    super.initState();
    _loadLearnedObjects();
  }

  @override
  void dispose() {
    objectTypeController.dispose();
    super.dispose();
  }

  Future<void> _loadLearnedObjects() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/learned-objects'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          learnedObjects = List<String>.from(data['learned_object_types']);
        });
      }
    } catch (e) {
      _showSnackBar('Error loading learned objects: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _learnNewObject() async {
    if (objectTypeController.text.trim().isEmpty) {
      _showSnackBar('Please enter an object type');
      return;
    }

    if (trainingImages.length < 3) {
      _showSnackBar('Please upload at least 3 training images');
      return;
    }

    setState(() => isLearning = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/learn-object'),
      );

      request.fields['object_type'] = objectTypeController.text.trim();

      for (int i = 0; i < trainingImages.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'files',
            trainingImages[i],
            filename: trainingImageNames[i],
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _showSnackBar(
          'Successfully learned ${objectTypeController.text.trim()}!',
        );
        _loadLearnedObjects();
        setState(() {
          trainingImages.clear();
          objectTypeController.clear();
        });
      } else {
        _showSnackBar('Error learning object: $responseBody');
      }
    } catch (e) {
      _showSnackBar('Error learning object: $e');
    } finally {
      setState(() => isLearning = false);
    }
  }

  Future<void> _testLearnedModel() async {
    if (testImage == null || testObjectType == null) {
      _showSnackBar('Please select an image and object type');
      return;
    }

    setState(() => isTesting = true);
    _showSnackBar(
      '🧠 Testing few-shot learned model... This may take a moment.',
    );

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/count-learned'),
      );

      request.fields['object_type'] = testObjectType!;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          testImage!,
          filename: testImageName ?? 'test_image.jpg',
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          testResult = data;
        });

        // Show detailed feedback about the few-shot model
        final trainingCount = data['training_images_count'] ?? 0;
        final processingTime = data['processing_time'] ?? 0;

        _showSnackBar(
          '✅ Few-shot model test completed! (Trained on $trainingCount images, ${processingTime.toStringAsFixed(2)}s)',
        );
      } else {
        _showSnackBar('Error testing model: $responseBody');
      }
    } catch (e) {
      _showSnackBar('Error testing model: $e');
    } finally {
      setState(() => isTesting = false);
    }
  }

  Future<void> _pickTrainingImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          trainingImages = result.files.map((file) => file.bytes!).toList();
          trainingImageNames = result.files.map((file) => file.name).toList();
        });
        _showSnackBar('${result.files.length} training images selected');
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    }
  }

  Future<void> _pickTestImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          testImage = result.files.single.bytes;
          testImageName = result.files.single.name;
        });
        _showSnackBar('Test image selected: ${result.files.single.name}');
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Advanced Mode - Few-Shot Learning',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Teach the AI new object types using few-shot learning. Upload training images to create custom detection models, then test them with new images.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 1. Learn New Object Type Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1. Learn New Object Type',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Object Type Input
                  TextFormField(
                    controller: objectTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Object Type to Learn',
                      hintText:
                          'e.g., bicycle, motorcycle, airplane, boat, etc.',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedObjectType = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Upload Training Images
                  DragTarget<Uint8List>(
                    onWillAcceptWithDetails: (details) => !isLearning,
                    onAcceptWithDetails: (details) {
                      if (!isLearning) {
                        setState(() {
                          trainingImages.add(details.data);
                          trainingImageNames.add(
                            'Dropped Image ${trainingImages.length}',
                          );
                        });
                        _showSnackBar('Image added to training set');
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: isLearning ? null : _pickTrainingImages,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? const Color(0xFF8B5CF6)
                                  : trainingImages.isNotEmpty
                                  ? const Color(0xFF8B5CF6)
                                  : const Color(0xFFE5E7EB),
                              width:
                                  candidateData.isNotEmpty ||
                                      trainingImages.isNotEmpty
                                  ? 2
                                  : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: candidateData.isNotEmpty
                                ? const Color(0xFF8B5CF6).withOpacity(0.1)
                                : trainingImages.isNotEmpty
                                ? const Color(0xFF8B5CF6).withOpacity(0.05)
                                : const Color(0xFFF9FAFB),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                candidateData.isNotEmpty
                                    ? Icons.cloud_download
                                    : Icons.upload_file,
                                size: 40,
                                color: const Color(0xFF8B5CF6),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                candidateData.isNotEmpty
                                    ? 'Drop image here'
                                    : 'Upload Training Images',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap or drag to select 3+ images of the same object type',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (trainingImages.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8B5CF6,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${trainingImages.length} images selected',
                                    style: const TextStyle(
                                      color: Color(0xFF8B5CF6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Learn Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isLearning ? null : _learnNewObject,
                      icon: isLearning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.school),
                      label: Text(
                        isLearning ? 'Learning...' : 'Learn Object Type',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Test Learned Model Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2. Test Learned Model',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Test Image Selection
                  DragTarget<Uint8List>(
                    onWillAcceptWithDetails: (details) => !isTesting,
                    onAcceptWithDetails: (details) {
                      if (!isTesting) {
                        setState(() {
                          testImage = details.data;
                          testImageName = 'Dropped Test Image';
                        });
                        _showSnackBar('Test image added');
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GestureDetector(
                        onTap: isTesting ? null : _pickTestImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: candidateData.isNotEmpty
                                  ? const Color(0xFF06B6D4)
                                  : testImage != null
                                  ? const Color(0xFF06B6D4)
                                  : const Color(0xFFE5E7EB),
                              width:
                                  candidateData.isNotEmpty || testImage != null
                                  ? 2
                                  : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: candidateData.isNotEmpty
                                ? const Color(0xFF06B6D4).withOpacity(0.1)
                                : testImage != null
                                ? const Color(0xFF06B6D4).withOpacity(0.05)
                                : const Color(0xFFF9FAFB),
                          ),
                          child: testImage != null
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
                                                testImage!,
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
                                                0xFF06B6D4,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              testImageName ?? 'Test Image',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF06B6D4),
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
                                            testImage = null;
                                            testImageName = null;
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
                                    Icon(
                                      candidateData.isNotEmpty
                                          ? Icons.cloud_download
                                          : Icons.image,
                                      size: 40,
                                      color: const Color(0xFF06B6D4),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      candidateData.isNotEmpty
                                          ? 'Drop test image here'
                                          : 'Select Test Image',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap or drag to choose an image to test the learned model',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Object Type Selection for Testing
                  if (learnedObjects.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: testObjectType,
                      decoration: const InputDecoration(
                        labelText: 'Learned Object Type',
                        border: OutlineInputBorder(),
                      ),
                      items: learnedObjects.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          testObjectType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Test Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (isTesting || learnedObjects.isEmpty)
                          ? null
                          : _testLearnedModel,
                      icon: isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.science),
                      label: Text(isTesting ? 'Testing...' : 'Test Model'),
                    ),
                  ),

                  // Test Results
                  if (testResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Results',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Object Type: ${testResult!['object_type']}'),
                          Text('Count: ${testResult!['count']}'),
                          Text(
                            'Confidence: ${(testResult!['confidence'] * 100).toStringAsFixed(1)}%',
                          ),
                          Text(
                            'Processing Time: ${testResult!['processing_time']}s',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. Manage Learned Objects Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '3. Manage Learned Objects',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (learnedObjects.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No learned object types yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Learn your first object type above to get started!',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: learnedObjects.map((object) {
                        return Chip(
                          label: Text(
                            object.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          onDeleted: () => _deleteLearnedObject(object),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLearnedObject(String objectType) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/learned-objects/$objectType'),
      );
      if (response.statusCode == 200) {
        _loadLearnedObjects();
        _showSnackBar('Deleted $objectType successfully!');
      } else {
        _showSnackBar('Error deleting $objectType');
      }
    } catch (e) {
      _showSnackBar('Error deleting $objectType: $e');
    }
  }
}
