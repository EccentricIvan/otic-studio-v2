import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/session_dao.dart';
import 'daos/student_dao.dart';
import 'tables/session_summaries_table.dart';
import 'tables/students_table.dart';
import 'tables/topic_progress_table.dart';

part 'otic_database.g.dart';

@DriftDatabase(
  tables: [Students, SessionSummaries, TopicProgress],
  daos: [StudentDao, SessionDao],
)
class OticDatabase extends _$OticDatabase {
  OticDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'otic_student_db');
  }
}
