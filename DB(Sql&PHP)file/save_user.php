<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "trivia_game";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$user_name = $_POST['username'];
$high_score = $_POST['high_score'];

$sql = "INSERT INTO users (username, high_score) VALUES ('$user_name', $high_score)
        ON DUPLICATE KEY UPDATE high_score = GREATEST(high_score, $high_score)";

if ($conn->query($sql) === TRUE) {
  echo "New record created successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
