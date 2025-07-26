<?php
include 'connectToDB.php';

$id = $_GET['id'];
$conn->query("UPDATE robot_arm_flutt SET status = 0 WHERE id = $id");
$conn->close();
?>