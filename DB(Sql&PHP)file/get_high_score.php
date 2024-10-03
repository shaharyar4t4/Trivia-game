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

$user_name = $_GET['username'];

$sql = "SELECT high_score FROM users WHERE username='$user_name'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  // Output data of each row
  while($row = $result->fetch_assoc()) {
    echo $row["high_score"];
  }
} else {
  echo "0";
}
$conn->close();
?>
