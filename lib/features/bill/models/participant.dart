class Participant {
  const Participant({required this.id, required this.name});

  factory Participant.fromJson(Map<String, dynamic> json) =>
      Participant(id: json['id'] as String, name: json['name'] as String);

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) => other is Participant && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
