// enum MigrationStatus {
//   idle,
//   starting,
//   initializing,
//   inProgress,
//   validating,
//   completed,
//   failed, notStarted;

//   final progress;

//   final  type;

//   late final String statusText;

//   String get displayName {
//     switch (this) {
//       case MigrationStatus.idle:
//         return 'Idle';
//       case MigrationStatus.starting:
//         return 'Starting';
//       case MigrationStatus.initializing:
//         return 'Initializing';
//       case MigrationStatus.inProgress:
//         return 'In Progress';
//       case MigrationStatus.validating:
//         return 'Validating';
//       case MigrationStatus.completed:
//         return 'Completed';
//       case MigrationStatus.failed:
//         return 'Failed';
//     }
//   }

//   bool get isActive {
//     return this == MigrationStatus.starting ||
//            this == MigrationStatus.initializing ||
//            this == MigrationStatus.inProgress ||
//            this == MigrationStatus.validating;
//   }

//   bool get isCompleted {
//     return this == MigrationStatus.completed;
//   }

//   bool get isFailed {
//     return this == MigrationStatus.failed;
//   }
// }
