import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class PointsProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  int _totalPoints = 0;
  bool _isLoading = false;
  String? _error;

  // Add debounce mechanism and caching
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  DateTime? _lastSuccessfulFetch;
  static const Duration _cacheDuration = Duration(seconds: 30);

  // Getters
  int get totalPoints => _totalPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PointsProvider() {
    _initialize();
  }

  void _initialize() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await Future.delayed(const Duration(milliseconds: 100));
        await fetchPoints();
      } else {
        clearData();
      }
    });

    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      fetchPoints();
    }
  }

  // Optimized fetch with debounce and caching
  Future<void> fetchPoints({bool forceRefresh = false}) async {
    _debounceTimer?.cancel();
    
    // Check cache
    if (!forceRefresh && _lastSuccessfulFetch != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastSuccessfulFetch!);
      if (timeSinceLastFetch < _cacheDuration) {
        debugPrint('Using cached points data');
        return;
      }
    }

    _debounceTimer = Timer(_debounceDuration, () async {
      await _performFetch();
    });
  }

  Future<void> _performFetch() async {
    try {
      if (_totalPoints == 0) {
        _setLoading(true);
      }
      _error = null;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      debugPrint('Fetching points for user: $userId');
      
      final response = await _fetchWithRetry(userId);
      final newPoints = response['total_poin'] as int? ?? 0;
      
      if (_totalPoints != newPoints) {
        _totalPoints = newPoints;
        debugPrint('Points updated: $_totalPoints');
      }
      
      _error = null;
      _lastSuccessfulFetch = DateTime.now();
      notifyListeners();

    } catch (e) {
      _error = _getErrorMessage(e);
      debugPrint('Error fetching points: $e');
      
      if (e.toString().contains('tidak terautentikasi')) {
        _totalPoints = 0;
        _lastSuccessfulFetch = null;
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Retry mechanism
  Future<Map<String, dynamic>> _fetchWithRetry(String userId, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        final response = await _supabase
            .from('pengguna')
            .select('total_poin')
            .eq('id_pengguna', userId)
            .single();
        
        return response;
      } catch (e) {
        attempts++;
        debugPrint('Fetch attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) rethrow;
        
        await Future.delayed(Duration(milliseconds: 200 * attempts));
      }
    }
    
    throw Exception('Failed to fetch points after $maxRetries attempts');
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('tidak terautentikasi') || 
        errorString.contains('not authenticated')) {
      return 'Sesi berakhir, silakan login kembali';
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      return 'Masalah koneksi internet';
    } else if (errorString.contains('permission denied')) {
      return 'Tidak memiliki izin akses data';
    } else {
      return 'Gagal memuat data poin';
    }
  }

  // Refresh points (force refresh)
  Future<void> refreshPoints() async {
    _lastSuccessfulFetch = null;
    await fetchPoints(forceRefresh: true);
  }

  // Validate if user has enough points for transaction
  Future<bool> validatePointsForTransaction(int requiredPoints) async {
    await fetchPoints(forceRefresh: true);
    
    if (_error != null) {
      throw Exception(_error);
    }
    
    return _totalPoints >= requiredPoints;
  }

  // Update points locally (optimistic update)
  void updatePointsLocally(int pointChange) {
    final newPoints = _totalPoints + pointChange;
    if (newPoints >= 0) {
      _totalPoints = newPoints;
      _error = null;
      notifyListeners();
      
      // Schedule sync with server
      Future.delayed(const Duration(milliseconds: 1000), () {
        fetchPoints(forceRefresh: true);
      });
    }
  }

  // Update points in database (called after successful transaction)
  Future<void> updatePointsInDatabase(int newTotal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('pengguna')
          .update({'total_poin': newTotal})
          .eq('id_pengguna', userId);

      _totalPoints = newTotal;
      _lastSuccessfulFetch = DateTime.now();
      notifyListeners();

    } catch (e) {
      debugPrint('Error updating points in database: $e');
      await fetchPoints(forceRefresh: true);
      rethrow;
    }
  }

  // Deduct points for exchange (with database update)
  Future<bool> deductPoints(int points, String transactionType, String transactionId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user has enough points
      if (_totalPoints < points) {
        return false;
      }

      final newTotal = _totalPoints - points;

      // Update pengguna table
      await _supabase
          .from('pengguna')
          .update({'total_poin': newTotal})
          .eq('id_pengguna', userId);

      // Add to riwayat_poin
      await _addPointHistory(userId, -points, transactionType, transactionId);

      _totalPoints = newTotal;
      _lastSuccessfulFetch = DateTime.now();
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('Error deducting points: $e');
      return false;
    }
  }

  // Add points (for earning points)
  Future<void> addPoints(int points, String transactionType, [String? transactionId]) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final newTotal = _totalPoints + points;

      // Update pengguna table
      await _supabase
          .from('pengguna')
          .update({'total_poin': newTotal})
          .eq('id_pengguna', userId);

      // Add to riwayat_poin
      await _addPointHistory(userId, points, transactionType, transactionId);

      _totalPoints = newTotal;
      _lastSuccessfulFetch = DateTime.now();
      notifyListeners();

    } catch (e) {
      debugPrint('Error adding points: $e');
      rethrow;
    }
  }

  // Add entry to riwayat_poin table
  Future<void> _addPointHistory(String userId, int pointChange, String transactionType, [String? transactionId]) async {
    try {
      final historyId = await _generateHistoryId();
      
      await _supabase.from('riwayat_poin').insert({
        'id_riwayat': historyId,
        'waktu': DateTime.now().toIso8601String(),
        'jenis_perubahan': transactionType,
        'jumlah_poin': pointChange,
        'id_pengguna': userId,
      });

    } catch (e) {
      debugPrint('Error adding point history: $e');
    }
  }

  // Generate unique ID for riwayat_poin
  Future<String> _generateHistoryId() async {
    try {
      final response = await _supabase
          .from('riwayat_poin')
          .select('id_riwayat')
          .order('id_riwayat', ascending: false)
          .limit(1)
          .maybeSingle();

      int nextNumber = 1;
      if (response != null) {
        final lastId = response['id_riwayat'] as String;
        final numberPart = lastId.substring(2);
        nextNumber = int.parse(numberPart) + 1;
      }

      return 'RP${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
      return 'RP${timestamp.toString().padLeft(3, '0')}';
    }
  }

  // Initialize provider
  Future<void> initialize() async {
    await fetchPoints();
  }

  // Clear data (call this when user logs out)
  void clearData() {
    _totalPoints = 0;
    _error = null;
    _isLoading = false;
    _lastSuccessfulFetch = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}