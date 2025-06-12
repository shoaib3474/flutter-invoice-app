class MigrationConfig {
  final String sourceType;
  final Map<String, dynamic> sourceConfig;
  final String targetType;
  final Map<String, dynamic> targetConfig;
  final bool migrateInvoices;
  final bool migrateCustomers;
  final bool migrateGSTR1;
  final bool migrateGSTR3B;
  final bool migrateGSTR9;
  final bool migrateGSTR9C;
  final bool migrateSettings;
  final bool validateAfterMigration;
  final bool cleanTargetBeforeMigration;

  const MigrationConfig({
    required this.sourceType,
    required this.sourceConfig,
    required this.targetType,
    required this.targetConfig,
    this.migrateInvoices = true,
    this.migrateCustomers = true,
    this.migrateGSTR1 = true,
    this.migrateGSTR3B = true,
    this.migrateGSTR9 = true,
    this.migrateGSTR9C = true,
    this.migrateSettings = true,
    this.validateAfterMigration = true,
    this.cleanTargetBeforeMigration = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType,
      'sourceConfig': sourceConfig,
      'targetType': targetType,
      'targetConfig': targetConfig,
      'migrateInvoices': migrateInvoices,
      'migrateCustomers': migrateCustomers,
      'migrateGSTR1': migrateGSTR1,
      'migrateGSTR3B': migrateGSTR3B,
      'migrateGSTR9': migrateGSTR9,
      'migrateGSTR9C': migrateGSTR9C,
      'migrateSettings': migrateSettings,
      'validateAfterMigration': validateAfterMigration,
      'cleanTargetBeforeMigration': cleanTargetBeforeMigration,
    };
  }

  factory MigrationConfig.fromJson(Map<String, dynamic> json) {
    return MigrationConfig(
      sourceType: json['sourceType'] ?? '',
      sourceConfig: Map<String, dynamic>.from(json['sourceConfig'] ?? {}),
      targetType: json['targetType'] ?? '',
      targetConfig: Map<String, dynamic>.from(json['targetConfig'] ?? {}),
      migrateInvoices: json['migrateInvoices'] ?? true,
      migrateCustomers: json['migrateCustomers'] ?? true,
      migrateGSTR1: json['migrateGSTR1'] ?? true,
      migrateGSTR3B: json['migrateGSTR3B'] ?? true,
      migrateGSTR9: json['migrateGSTR9'] ?? true,
      migrateGSTR9C: json['migrateGSTR9C'] ?? true,
      migrateSettings: json['migrateSettings'] ?? true,
      validateAfterMigration: json['validateAfterMigration'] ?? true,
      cleanTargetBeforeMigration: json['cleanTargetBeforeMigration'] ?? false,
    );
  }
}
