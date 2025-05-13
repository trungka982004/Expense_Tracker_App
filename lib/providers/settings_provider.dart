import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsProvider with ChangeNotifier {
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userAvatarKey = 'user_avatar';

  late SharedPreferences _prefs;
  String _currency = 'USD';
  String _language = 'en';
  String _userName = 'User Name';
  String _userEmail = 'user@example.com';
  String? _userAvatar; // base64 string or null

  String get currency => _currency;
  String get language => _language;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userAvatar => _userAvatar;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _currency = _prefs.getString(_currencyKey) ?? 'USD';
    _language = _prefs.getString(_languageKey) ?? 'en';
    _userName = _prefs.getString(_userNameKey) ?? 'User Name';
    _userEmail = _prefs.getString(_userEmailKey) ?? 'user@example.com';
    _userAvatar = _prefs.getString(_userAvatarKey);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _prefs.setString(_currencyKey, currency);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _prefs.setString(_languageKey, language);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString(_userNameKey, name);
    notifyListeners();
  }

  Future<void> setUserEmail(String email) async {
    _userEmail = email;
    await _prefs.setString(_userEmailKey, email);
    notifyListeners();
  }

  Future<void> setUserAvatar(String? base64Image) async {
    _userAvatar = base64Image;
    if (base64Image == null) {
      await _prefs.remove(_userAvatarKey);
    } else {
      await _prefs.setString(_userAvatarKey, base64Image);
    }
    notifyListeners();
  }

  String formatCurrency(double amount) {
    if (_currency == 'VND') {
      return '₫${amount.toStringAsFixed(0)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  Map<String, String> get translations {
    if (_language == 'vi') {
      return {
        'app_title': 'Theo Dõi Chi Tiêu',
        'home': 'Trang Chủ',
        'statistics': 'Thống Kê',
        'categories': 'Danh Mục',
        'profile': 'Hồ Sơ',
        'add_transaction': 'Thêm Giao Dịch',
        'total_balance': 'Số Dư Tổng',
        'settings': 'Cài Đặt',
        'notifications': 'Thông Báo',
        'dark_mode': 'Chế Độ Tối',
        'currency': 'Tiền Tệ',
        'language': 'Ngôn Ngữ',
        'about': 'Giới Thiệu',
        'privacy_policy': 'Chính Sách Bảo Mật',
        'terms_of_service': 'Điều Khoản Sử Dụng',
        'no_transactions': 'Chưa Có Giao Dịch',
        'delete_transaction': 'Xóa Giao Dịch',
        'delete_confirmation': 'Bạn có chắc muốn xóa giao dịch này?',
        'cancel': 'Hủy',
        'delete': 'Xóa',
        'expense': 'Chi Tiêu',
        'income': 'Thu Nhập',
        'title': 'Tiêu Đề',
        'amount': 'Số Tiền',
        'date': 'Ngày',
        'category': 'Danh Mục',
        'please_enter_title': 'Vui lòng nhập tiêu đề',
        'please_enter_amount': 'Vui lòng nhập số tiền',
        'please_enter_valid_number': 'Vui lòng nhập số hợp lệ',
        'please_select_category': 'Vui lòng chọn danh mục',
        'add_expense': 'Thêm Chi Tiêu',
        'add_income': 'Thêm Thu Nhập',
      };
    }
    return {
      'app_title': 'Expense Tracker',
      'home': 'Home',
      'statistics': 'Statistics',
      'categories': 'Categories',
      'profile': 'Profile',
      'add_transaction': 'Add Transaction',
      'total_balance': 'Total Balance',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'currency': 'Currency',
      'language': 'Language',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'no_transactions': 'No Transactions Yet',
      'delete_transaction': 'Delete Transaction',
      'delete_confirmation': 'Are you sure you want to delete this transaction?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'expense': 'Expense',
      'income': 'Income',
      'title': 'Title',
      'amount': 'Amount',
      'date': 'Date',
      'category': 'Category',
      'please_enter_title': 'Please enter a title',
      'please_enter_amount': 'Please enter an amount',
      'please_enter_valid_number': 'Please enter a valid number',
      'please_select_category': 'Please select a category',
      'add_expense': 'Add Expense',
      'add_income': 'Add Income',
    };
  }

  String translate(String key) {
    return translations[key] ?? key;
  }
} 