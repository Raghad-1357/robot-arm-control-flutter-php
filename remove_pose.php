<?php
include 'connectToDB.php';

$id = $_GET['id'];
// بدلاً من الحذف، نغير حالة status إلى 0
$conn->query("UPDATE robot_arm_flutt SET status = 0 WHERE id = $id");
$conn->close();
?>