class CallList {
  final String id;
  final String userId;
  final String name;
  final String description;
  final int totalContacts;
  final int calledContacts;
  final int pendingContacts;
  final int scheduledContacts;
  final String status;
  final DateTime createdAt;
  final List<Contact>? contacts;

  CallList({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.totalContacts,
    required this.calledContacts,
    this.pendingContacts = 28,
    this.scheduledContacts = 9,
    required this.status,
    required this.createdAt,
    this.contacts,
  });

  factory CallList.fromJson(Map<String, dynamic> json) {
    final total = json['totalContacts'] is int
        ? json['totalContacts'] as int
        : int.tryParse(json['totalContacts']?.toString() ?? '50') ?? 50;
    final called = json['calledContacts'] is int
        ? json['calledContacts'] as int
        : int.tryParse(json['calledContacts']?.toString() ?? '22') ?? 22;
    final pending = json['pendingContacts'] is int
        ? json['pendingContacts'] as int
        : int.tryParse(json['pendingContacts']?.toString() ?? '28') ?? 28;
    final scheduled = json['scheduledContacts'] is int
        ? json['scheduledContacts'] as int
        : int.tryParse(json['scheduledContacts']?.toString() ?? '9') ?? 9;

    return CallList(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '68626fb697757cb741f449b9',
      userId: json['userId']?.toString() ?? '68626f9497757cb741f449b0',
      name: json['name']?.toString() ?? 'Test List',
      description: json['description']?.toString() ?? 'Calley calling test batch',
      totalContacts: total,
      calledContacts: called,
      pendingContacts: pending,
      scheduledContacts: scheduled,
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      contacts: json['contacts'] != null
          ? (json['contacts'] as List)
              .map((c) => Contact.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'totalContacts': totalContacts,
      'calledContacts': calledContacts,
      'pendingContacts': pendingContacts,
      'scheduledContacts': scheduledContacts,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (contacts != null)
        'contacts': contacts!.map((c) => c.toJson()).toList(),
    };
  }

  double get completionPercentage {
    if (totalContacts == 0) return 0;
    return (calledContacts / totalContacts) * 100;
  }

  @override
  String toString() {
    return 'CallList(id: $id, name: $name, total: $totalContacts, called: $calledContacts, pending: $pendingContacts)';
  }
}

class Contact {
  final String id;
  final String name;
  final String phone;
  final String status; // 'pending', 'done', 'scheduled'
  final DateTime? lastCalledAt;
  final String? notes;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    this.lastCalledAt,
    this.notes,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() ?? 'pending',
      lastCalledAt: json['lastCalledAt'] != null
          ? DateTime.tryParse(json['lastCalledAt'].toString())
          : null,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'status': status,
      'lastCalledAt': lastCalledAt?.toIso8601String(),
      'notes': notes,
    };
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? status,
    DateTime? lastCalledAt,
    String? notes,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      lastCalledAt: lastCalledAt ?? this.lastCalledAt,
      notes: notes ?? this.notes,
    );
  }
}
