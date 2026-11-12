import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/api_constants.dart';
import '../constants/app_colors.dart';
import '../models/call_list_model.dart';
import '../providers/list_provider.dart';
import '../widgets/shimmer_loading.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    this.listId = ApiConstants.defaultListId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListProvider>().fetchListDetail(widget.listId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Contact> _getFilteredContacts(List<Contact> contacts) {
    var result = contacts;
    if (_filterStatus != 'all') {
      result = result.where((c) => c.status.toLowerCase() == _filterStatus).toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(query) ||
              c.phone.replaceAll(' ', '').contains(query))
          .toList();
    }
    return result;
  }

  void _simulateCall(Contact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text(contact.name, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number: ${contact.phone}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Notes: ${contact.notes ?? "No notes recorded"}',
                style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
            const SizedBox(height: 16),
            const Text('Log Call Outcome:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context
                  .read<ListProvider>()
                  .updateContactStatus(contact.id, 'pending');
              Navigator.pop(ctx);
            },
            child: const Text('Pending', style: TextStyle(color: Color(0xFFF59E0B))),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<ListProvider>()
                  .updateContactStatus(contact.id, 'scheduled', 'Callback required');
              Navigator.pop(ctx);
            },
            child: const Text('Schedule', style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context
                  .read<ListProvider>()
                  .updateContactStatus(contact.id, 'done', 'Call connected, lead interested');
              Navigator.pop(ctx);
            },
            child: const Text('Mark Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = context.watch<ListProvider>();
    final callList = listProvider.selectedList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          callList?.name ?? 'Test List Details',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded,
                color: AppColors.textLight, size: 20),
            onPressed: () {
              listProvider.fetchListDetail(widget.listId);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          callList?.name ?? 'Test List',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          callList?.description ?? 'Calley calling test batch',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildStatTag('${callList?.totalContacts ?? 50} Total',
                                AppColors.primaryBlue),
                            const SizedBox(width: 6),
                            _buildStatTag('${callList?.calledContacts ?? 22} Done',
                                const Color(0xFF10B981)),
                            const SizedBox(width: 6),
                            _buildStatTag(
                                '${callList?.pendingContacts ?? 28} Pending',
                                const Color(0xFFF59E0B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Progress percentage circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: (callList?.completionPercentage ?? 44) / 100,
                          strokeWidth: 5,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue),
                        ),
                      ),
                      Text(
                        '${(callList?.completionPercentage ?? 44).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search contact or phone...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.textLight),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter Row
                  Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('done', 'Done'),
                      const SizedBox(width: 8),
                      _buildFilterChip('scheduled', 'Scheduled'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Contacts List
            Expanded(
              child: listProvider.isLoading
                  ? const ShimmerContactList()
                  : Builder(
                      builder: (context) {
                        final contacts = _getFilteredContacts(
                            callList?.contacts ?? []);

                        if (contacts.isEmpty) {
                          return const Center(
                            child: Text(
                              'No contacts found matching criteria.',
                              style: TextStyle(color: AppColors.textLight),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: contacts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return _buildContactTile(contact);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filterStatus == key;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(Contact contact) {
    Color statusColor;
    switch (contact.status.toLowerCase()) {
      case 'done':
        statusColor = const Color(0xFF10B981);
        break;
      case 'scheduled':
        statusColor = const Color(0xFF8B5CF6);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0] : 'C',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                if (contact.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.notes!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              contact.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.phone_rounded,
                color: Color(0xFF10B981), size: 22),
            onPressed: () => _simulateCall(contact),
          ),
        ],
      ),
    );
  }
}
