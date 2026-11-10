import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/member.dart';
import '../services/member_service.dart';
import '../services/notification_service.dart';

enum MemberFilterTab { tous, actifs, aVerifier, inactifs }

class MemberController extends ChangeNotifier {
  final MemberService _memberService = MemberService();
  StreamSubscription<List<Member>>? _memberSubscription;

  List<Member> _members = [];
  bool _isLoading = false;
  String _searchQuery = '';
  MemberFilterTab _selectedTab = MemberFilterTab.tous;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  MemberFilterTab get selectedTab => _selectedTab;

  List<Member> get filteredMembers {
    return _members.where((m) {
      final matchesQuery = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.email.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesTab = true;
      switch (_selectedTab) {
        case MemberFilterTab.actifs:
          matchesTab = m.status == MemberStatus.active || m.status == MemberStatus.expiring;
          break;
        case MemberFilterTab.aVerifier:
          matchesTab = m.status == MemberStatus.toVerify;
          break;
        case MemberFilterTab.inactifs:
          matchesTab = m.status == MemberStatus.inactive;
          break;
        case MemberFilterTab.tous:
          matchesTab = true;
          break;
      }

      return matchesQuery && matchesTab;
    }).toList();
  }

  MemberController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _memberSubscription?.cancel();
    _memberSubscription = _memberService.getMembersStream().listen(
      (list) async {
        _members = list.isNotEmpty ? list : await _memberService.fetchMembers();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('Erreur MemberController stream: $e');
        _members = await _memberService.fetchMembers();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterTab(MemberFilterTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<bool> addMember({
    required String name,
    required String email,
    required String phone,
    required String subscriptionName,
  }) async {
    try {
      final newMember = await _memberService.addMember(
        name: name,
        email: email,
        phone: phone,
        subscriptionName: subscriptionName,
        status: MemberStatus.active,
      );
      if (!_members.any((m) => m.id == newMember.id)) {
        _members.insert(0, newMember);
        notifyListeners();
      }

      // Notification automatique d'inscription
      await NotificationService().createNotification(
        title: '🆕 Nouveau membre inscrit',
        body: 'L\'adhérent $name s\'est inscrit avec l\'offre "$subscriptionName".',
        target: NotificationTarget.all,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateMember(Member updated) async {
    final oldIndex = _members.indexWhere((m) => m.id == updated.id);
    final oldSub = oldIndex != -1 ? _members[oldIndex].subscriptionName : '';

    await _memberService.updateMember(updated);
    if (oldIndex != -1) {
      _members[oldIndex] = updated;
      notifyListeners();
    }

    if (oldSub.isNotEmpty && oldSub != updated.subscriptionName) {
      await NotificationService().createNotification(
        title: '💳 Abonnement choisi/renouvelé',
        body: 'L\'adhérent ${updated.name} a sélectionné l\'offre "${updated.subscriptionName}".',
        target: NotificationTarget.all,
      );
    }
  }

  Future<void> deleteMember(String memberId) async {
    await _memberService.deleteMember(memberId);
    _members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  @override
  void dispose() {
    _memberSubscription?.cancel();
    super.dispose();
  }
}
