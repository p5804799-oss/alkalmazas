class Friend {
  final String id;
  final String name;
  final String status;
  final bool isOnline;

  Friend({required this.id, required this.name, required this.status, this.isOnline = false});
}

class CommunityDatabase {
  static List<Friend> get mockFriends => [
    Friend(id: 'u1', name: 'Gábor', status: 'Felsőtest edzésen...', isOnline: true),
    Friend(id: 'u2', name: 'Béla', status: 'Pihenőnap', isOnline: false),
    Friend(id: 'u3', name: 'Anna', status: 'Épp étkezést rögzít', isOnline: true),
  ];
}
