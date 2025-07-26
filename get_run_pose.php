<?php
include 'connectToDB.php';

// جلب فقط الصفوف التي status = 1
$result = $conn->query("SELECT * FROM robot_arm_flutt WHERE status = 1");

$poses = [];
while($row = $result->fetch_assoc()) {
    $poses[] = $row; // إضافة كل صف كمصفوفة إلى قائمة الوضعيات
}

header('Content-Type: application/json'); // إرسال ترويسة تشير إلى أن المحتوى JSON
echo json_encode($poses); // تحويل قائمة الوضعيات إلى JSON وإرجاعها

$conn->close();
?>