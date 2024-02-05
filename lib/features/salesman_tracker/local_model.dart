class User{
  String name;
  String image;
  String lastSeen;
  String travelDuration;
  double travelDistance;
  String travelTime;
  String statusOfEvent;
  int checkins;
  String eventAddress;
  String eventTime;
  String eventDate;
  String currentPositionAddress;
  String phoneNumber;
  String altPhoneNumber;

  User({
    required this.name,
    required this.image,
    required this.lastSeen,
    required this.travelDuration,
    required this.travelDistance,
    required this.travelTime,
    required this.checkins,
    required this.eventAddress,
    required this.eventTime,
    required this.eventDate,
    required this.currentPositionAddress,
    required this.statusOfEvent,
    required this.phoneNumber,
    required this.altPhoneNumber,
  });
}

List<User> userList = [
  User(
    name: "John Doe",
    image: "john_doe.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 2).toString(),
    travelDistance: 50.5,
    travelTime: Duration(minutes: 30).toString(),
    checkins: 3,
    eventAddress: "Suryam Industrial estate, D 70, Sardar Patel Ring Rd, nr. Torrent sub station, Odhav Industrial Estate, Odhav, Ahmedabad, Kathwada, Gujarat 382345",
    eventTime: "6:00 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "Suryam Industrial estate, D 70, Sardar Patel Ring Rd, nr. Torrent sub station, Odhav Industrial Estate, Odhav, Ahmedabad, Kathwada, Gujarat 382345",
    statusOfEvent: "Logged In",
    phoneNumber: "123-456-7890",
    altPhoneNumber: "987-654-3210",
  ),
  User(
    name: "Jane Smith",
    image: "jane_smith.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 1).toString(),
    travelDistance: 30.2,
    travelTime: Duration(minutes: 20).toString(),
    checkins: 1,
    eventAddress: "442, Maruti Plaza, BRTS, Sardar Chowk, nr. Vijay Park Society Road, Krishnanagar, Ahmedabad, Gujarat 382346",
    eventTime: "7:30 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "789 Pine Rd, Hamletville",
    statusOfEvent: "Check In",
    phoneNumber: "555-555-5555",
    altPhoneNumber: "999-999-9999",
  ),
  User(
    name: "Jane Marker",
    image: "jane_smith.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 1).toString(),
    travelDistance: 30.2,
    travelTime: Duration(minutes: 20).toString(),
    checkins: 1,
    eventAddress: "1, Jivankala, Jignasa Society, Vibhavari Society, Vejalpur, Ahmedabad, Gujarat 380051",
    eventTime: "8:30 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "789 Pine Rd, Hamletville",
    statusOfEvent: "Check Out",
    phoneNumber: "555-555-5555",
    altPhoneNumber: "999-999-9999",
  ),
  User(
    name: "David Warner",
    image: "jane_smith.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 1).toString(),
    travelDistance: 30.2,
    travelTime: Duration(minutes: 20).toString(),
    checkins: 1,
    eventAddress: " 7/210, Second Floor, Ratnam Complex, nr. Time Square Building, Ellisbridge, Ahmedabad, Gujarat 380006",
    eventTime: "8:35 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "789 Pine Rd, Hamletville",
    statusOfEvent: "Waiting",
    phoneNumber: "555-555-5555",
    altPhoneNumber: "999-999-9999",
  ),
  User(
    name: "Virat Kohli",
    image: "jane_smith.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 1).toString(),
    travelDistance: 30.2,
    travelTime: Duration(minutes: 20).toString(),
    checkins: 1,
    eventAddress: "Police Station, Cross Rd, nr. Chakudiya Mahadev Road, opp. Rakhial, Rakhial, Ahmedabad, Gujarat 380023",
    eventTime: "9:30 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "789 Pine Rd, Hamletville",
    statusOfEvent: "Gps",
    phoneNumber: "555-555-5555",
    altPhoneNumber: "999-999-9999",
  ),
  User(
    name: "Rohit Sharma",
    image: "jane_smith.jpg",
    lastSeen: DateTime.now().toString(),
    travelDuration: Duration(hours: 1).toString(),
    travelDistance: 30.2,
    travelTime: Duration(minutes: 20).toString(),
    checkins: 1,
    eventAddress: "Kathwada Rd, New India Colony, Naroda, Ahmedabad, Gujarat 382325",
    eventTime: "10:20 PM",
    eventDate: "05 Jan 2023",
    currentPositionAddress: "789 Pine Rd, Hamletville",
    statusOfEvent: "Logged Out",
    phoneNumber: "555-555-5555",
    altPhoneNumber: "999-999-9999",
  ),
  // Add more users as needed
];