import '../core/constants/app_constants.dart';

class StoreSettings {
  String storeName;
  String tagline;
  String address;
  String phone;
  String email;
  String taxId;
  double taxRate;
  String currencySymbol;
  String receiptHeader;
  String receiptFooter;
  bool isDarkMode;
  bool isDemoFrameVisible;
  bool autoPrintReceipt;
  bool soundEffects;

  StoreSettings({
    this.storeName = AppConstants.defaultStoreName,
    this.tagline = 'Fresh Essentials & Daily Retail',
    this.address = AppConstants.defaultStoreAddress,
    this.phone = AppConstants.defaultStorePhone,
    this.email = AppConstants.defaultStoreEmail,
    this.taxId = AppConstants.defaultTaxId,
    this.taxRate = AppConstants.defaultTaxRate,
    this.currencySymbol = AppConstants.defaultCurrencySymbol,
    this.receiptHeader = AppConstants.defaultReceiptHeader,
    this.receiptFooter = AppConstants.defaultReceiptFooter,
    this.isDarkMode = true,
    this.isDemoFrameVisible = false,
    this.autoPrintReceipt = false,
    this.soundEffects = true,
  });

  StoreSettings copyWith({
    String? storeName,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? taxId,
    double? taxRate,
    String? currencySymbol,
    String? receiptHeader,
    String? receiptFooter,
    bool? isDarkMode,
    bool? isDemoFrameVisible,
    bool? autoPrintReceipt,
    bool? soundEffects,
  }) {
    return StoreSettings(
      storeName: storeName ?? this.storeName,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      taxId: taxId ?? this.taxId,
      taxRate: taxRate ?? this.taxRate,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isDemoFrameVisible: isDemoFrameVisible ?? this.isDemoFrameVisible,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
      soundEffects: soundEffects ?? this.soundEffects,
    );
  }
}
