import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert'; // لاستخدام json.decode و json.encode

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Arm Control Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RobotArmHomePage(),
    );
  }
}

class RobotArmHomePage extends StatefulWidget {
  const RobotArmHomePage({super.key});

  @override
  State<RobotArmHomePage> createState() => _RobotArmHomePageState();
}

class _RobotArmHomePageState extends State<RobotArmHomePage> {
  // قيم المحركات الحالية، تمثل الشرائح
  List<double> motorValues = List.generate(6, (index) => 90.0);

  // قائمة لحفظ الوضعيات المحملة من قاعدة البيانات
  List<Map<String, dynamic>> savedPoses = [];

  // عنوان URL الأساسي لملفات PHP.
  // إذا كنتِ تختبرين على محاكي Android: استخدمي 10.0.2.2 بدلاً من localhost
  // إذا كنتِ تختبرين على جهاز حقيقي متصل بنفس الشبكة: استخدمي عنوان IP لجهاز الكمبيوتر الخاص بكِ
  // تأكدي أن XAMPP يعمل وأن Apache Server يعمل.
  final String baseUrl = "http://192.168.8.203/robot_arm_flutter"; // استبدلي بالمسار الصحيح لملفات PHP لديك

  @override
  void initState() {
    super.initState();
    _loadPoseTable(); // تحميل الوضعيات عند بدء التطبيق
  }

  // دالة لتحديث قيمة شريط التمرير وعرضها
  void _updateValue(int index, double newValue) {
    setState(() {
      motorValues[index] = newValue;
    });
  }

  // دالة لإعادة تعيين جميع الشرائح إلى 90
  void _resetSliders() {
    setState(() {
      motorValues = List.generate(6, (index) => 90.0);
    });
  }

  // دالة لحفظ الوضعية الحالية
  Future<void> _savePose() async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_pose.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, List<double>>{
        'pose': motorValues,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
      _loadPoseTable(); // إعادة تحميل الجدول بعد الحفظ
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save pose.')),
      );
    }
  }

  // دالة لتحميل الوضعيات من قاعدة البيانات وعرضها في الجدول
  Future<void> _loadPoseTable() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_run_pose.php'));

      if (response.statusCode == 200) {
        // بما أن get_run_pose.php يعيد HTML مباشرة، نحتاج لتحليلها.
        // هذه طريقة بسيطة. لتطبيق أكثر قوة، يمكنكِ تعديل PHP لإرجاع JSON.
        // في الوقت الحالي، سنقوم بتحليل HTML يدوياً لاستخراج البيانات.
        // هذا الجزء سيكون أكثر تعقيداً قليلاً من المتوقع لأن PHP الخاص بكِ لا يعيد JSON.
        // البديل الأفضل: تعديل get_run_pose.php ليعيد JSON. سأفترض هذا للتسهيل.

        // ** اقتراح: تعديل get_run_pose.php لإرجاع JSON **
        // غيري get_run_pose.php إلى:
        /*
        <?php
        include 'connectToDB.php';
        $result = $conn->query("SELECT * FROM robot_arm_flutt WHERE status = 1");
        $poses = [];
        while($row = $result->fetch_assoc()) {
            $poses[] = $row;
        }
        echo json_encode($poses);
        $conn->close();
        ?>
        */
        // إذا قمتِ بذلك، سيكون الكود التالي في Flutter أسهل بكثير:
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          savedPoses = data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load poses.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading poses: $e')),
      );
    }
  }

// دالة لتحميل قيم وضعية معينة إلى الشرائح
  Future<void> _loadPose(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/load_pose_values.php?id=$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        motorValues[0] = double.parse(data['motor1'].toString());
        motorValues[1] = double.parse(data['motor2'].toString());
        motorValues[2] = double.parse(data['motor3'].toString());
        motorValues[3] = double.parse(data['motor4'].toString());
        motorValues[4] = double.parse(data['motor5'].toString());
        motorValues[5] = double.parse(data['motor6'].toString());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load pose values.')),
      );
    }
  }

  // دالة لإزالة (تغيير status إلى 0) وضعية
  Future<void> _removePose(int id) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to remove this pose?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      final response = await http.get(Uri.parse('$baseUrl/remove_pose.php?id=$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pose removed successfully!')),
        );
        _loadPoseTable(); // إعادة تحميل الجدول بعد الإزالة
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove pose.')),
        );
      }
    }
  }

  // دالة لتشغيل الوضعية (تفتح نافذة جديدة بالقيم)
  Future<void> _runPose() async {
  String query =
      'motor1=${motorValues[0].round()}&motor2=${motorValues[1].round()}&motor3=${motorValues[2].round()}&motor4=${motorValues[3].round()}&motor5=${motorValues[4].round()}&motor6=${motorValues[5].round()}';

  final Uri url = Uri.parse('$baseUrl/run_pose.php?$query'); // بناء الـ URL الكامل

  if (!await launchUrl(url)) { // محاولة فتح الـ URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not launch $url')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Arm Control Panel'),
      ),
      body: SingleChildScrollView( // لضمان التمرير إذا كان المحتوى أطول من الشاشة
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // شرائح المحركات
            for (int i = 0; i < 6; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 100, // لتحديد عرض ثابت للعنوان
                      child: Text('Motor ${i + 1}:', style: const TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      child: Slider(
                        value: motorValues[i],min: 0,
                        max: 180,
                        divisions: 180, // لزيادة دقة الشرائح
                        label: motorValues[i].round().toString(),
                        onChanged: (newValue) {
                          _updateValue(i, newValue);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40, // لعرض قيمة المحرك
                      child: Text(motorValues[i].round().toString(), style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // الأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _resetSliders,
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: _savePose,
                  child: const Text('Save Pose'),
                ),
                ElevatedButton(
                  onPressed: _runPose,
                  child: const Text('Run'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // جدول الوضعيات المحفوظة
            const Text('Saved Poses:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // لتمرير أفقي للجدول إذا كان عريضاً
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('M1')),
                  DataColumn(label: Text('M2')),
                  DataColumn(label: Text('M3')),
                  DataColumn(label: Text('M4')),
                  DataColumn(label: Text('M5')),
                  DataColumn(label: Text('M6')),
                  DataColumn(label: Text('Action')),
                ],
                rows: savedPoses.map((pose) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text(pose['id'].toString())),
                      DataCell(Text(pose['motor1'].toString())),
                      DataCell(Text(pose['motor2'].toString())),
                      DataCell(Text(pose['motor3'].toString())),
                      DataCell(Text(pose['motor4'].toString())),
                      DataCell(Text(pose['motor5'].toString())),
                      DataCell(Text(pose['motor6'].toString())),
                      DataCell(Row(
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.blue),
                            onPressed: () => _loadPose(int.parse(pose['id'].toString())),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removePose(int.parse(pose['id'].toString())),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}