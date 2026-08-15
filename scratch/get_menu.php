<?php
$conn = mysqli_connect('127.0.0.1', 'amhtechn_intern', 'j4l4nm4sihp4nj4ng', 'amhtechn_intern');
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}

$sql = "SELECT menu_id, menu_title, parent_id, fidsys, url FROM m_menu WHERE menu_title LIKE '%Status Transaksi%' OR menu_title LIKE '%Order Produk%' OR menu_title LIKE '%Pebisnis%'";
$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {
    while($row = mysqli_fetch_assoc($result)) {
        print_r($row);
    }
} else {
    echo "0 results";
}
mysqli_close($conn);
