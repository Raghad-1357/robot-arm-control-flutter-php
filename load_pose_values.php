<?php
include 'connectToDB.php';

$id = $_GET['id'];
$result = $conn->query("SELECT * FROM robot_arm_flutt WHERE id = $id");

$row = $result->fetch_assoc();
echo json_encode($row);

$conn->close();
?>