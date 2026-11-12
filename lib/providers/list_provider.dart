import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/call_list_model.dart';
import '../services/api_service.dart';

class ListProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CallList> _lists = [];
  CallList? _selectedList;
  bool _isLoading = false;
  String? _errorMessage;

  // ---------- Getters ----------

  List<CallList> get lists => _lists;
  CallList? get selectedList => _selectedList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ListProvider() {
    fetchLists(ApiConstants.defaultUserId);
  }

  // ---------- Methods ----------

  /// Fetch all call lists for a user.
  Future<void> fetchLists([String? userId]) async {
    _setLoading(true);
    _clearError();

    try {
      final targetUserId = userId ?? ApiConstants.defaultUserId;
      _lists = await _apiService.getLists(userId: targetUserId);
      if (_lists.isNotEmpty && _selectedList == null) {
        _selectedList = _lists.first;
      }
    } catch (e) {
      _setError('Failed to load lists.');
      debugPrint('ListProvider fetchLists error: $e');
    }

    _setLoading(false);
  }

  /// Fetch detail for a single list.
  Future<void> fetchListDetail([String? listId]) async {
    _setLoading(true);
    _clearError();

    try {
      final targetListId = listId ?? ApiConstants.defaultListId;
      _selectedList = await _apiService.getListDetail(listId: targetListId);
    } catch (e) {
      _setError('Failed to load list detail.');
      debugPrint('ListProvider fetchListDetail error: $e');
    }

    _setLoading(false);
  }

  /// Select a list
  void selectList(CallList list) {
    _selectedList = list;
    notifyListeners();
  }

  /// Update a contact's status after dialing (e.g. 'done', 'scheduled', 'pending')
  void updateContactStatus(String contactId, String newStatus, [String? notes]) {
    if (_selectedList == null || _selectedList!.contacts == null) return;

    final updatedContacts = _selectedList!.contacts!.map((c) {
      if (c.id == contactId) {
        return c.copyWith(
          status: newStatus,
          notes: notes ?? c.notes,
          lastCalledAt: DateTime.now(),
        );
      }
      return c;
    }).toList();

    final doneCount = updatedContacts.where((c) => c.status == 'done').length;
    final pendingCount = updatedContacts.where((c) => c.status == 'pending').length;
    final scheduledCount = updatedContacts.where((c) => c.status == 'scheduled').length;

    _selectedList = CallList(
      id: _selectedList!.id,
      userId: _selectedList!.userId,
      name: _selectedList!.name,
      description: _selectedList!.description,
      totalContacts: _selectedList!.totalContacts,
      calledContacts: doneCount,
      pendingContacts: pendingCount,
      scheduledContacts: scheduledCount,
      status: _selectedList!.status,
      createdAt: _selectedList!.createdAt,
      contacts: updatedContacts,
    );

    notifyListeners();
  }

  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
