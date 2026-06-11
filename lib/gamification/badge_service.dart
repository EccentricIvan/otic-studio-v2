import 'package:drift/drift.dart' show Value;
import '../db/otic_database.dart';
import '../db/providers/db_provider.dart';
import 'badge_definitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checks eligibility and awards badges, adding points to the student.
/// Call these methods after the triggering action completes.
class BadgeService {
  BadgeService(this._db);
  final OticDatabase _db;

  // ── Trigger: a lesson was marked complete ─────────────────────────────────

  Future<List<BadgeDef>> onLessonCompleted(int studentId) async {
    final awarded = <BadgeDef>[];
    final paths = await _db.pathDao.getPathsForStudent(studentId);
    final totalCompleted =
        paths.fold(0, (s, p) => s + p.completedLessons);

    // First lesson ever
    if (totalCompleted == 1) {
      await _award(studentId, 'first_lesson', awarded);
    }

    // Any path fully complete
    final hasFullPath = paths.any((p) => p.completedLessons == p.totalLessons);
    if (hasFullPath) {
      await _award(studentId, 'path_master', awarded);
    }

    // 3 distinct paths started
    if (paths.length >= 3) {
      await _award(studentId, 'polymath', awarded);
    }

    return awarded;
  }

  // ── Trigger: practice exercise answered ──────────────────────────────────

  Future<List<BadgeDef>> onPracticeAnswered(
      int studentId, int totalCorrectInSession) async {
    final awarded = <BadgeDef>[];
    await _award(studentId, 'practice_starter', awarded);
    if (totalCorrectInSession >= 5) {
      await _award(studentId, 'sharp_mind', awarded);
    }
    return awarded;
  }

  // ── Trigger: apply scenario evaluated ────────────────────────────────────

  Future<List<BadgeDef>> onApplyEvaluated(
      int studentId, int sessionScenarioCount) async {
    final awarded = <BadgeDef>[];
    if (sessionScenarioCount >= 5) {
      await _award(studentId, 'scenario_solver', awarded);
    }
    return awarded;
  }

  // ── Trigger: teach scored ─────────────────────────────────────────────────

  Future<List<BadgeDef>> onTeachScored(int studentId, int score) async {
    final awarded = <BadgeDef>[];
    if (score >= 80) {
      await _award(studentId, 'teacher', awarded);
    }
    return awarded;
  }

  // ── Trigger: project saved ────────────────────────────────────────────────

  Future<List<BadgeDef>> onProjectSaved(int studentId) async {
    final awarded = <BadgeDef>[];
    await _award(studentId, 'creator', awarded);
    return awarded;
  }

  // ── Trigger: streak updated ───────────────────────────────────────────────

  Future<List<BadgeDef>> onStreakUpdated(
      int studentId, int streakDays) async {
    final awarded = <BadgeDef>[];
    if (streakDays >= 7) {
      await _award(studentId, 'consistent_learner', awarded);
    }
    return awarded;
  }

  // ── Internal: award badge + add points if not already owned ──────────────

  Future<void> _award(
      int studentId, String badgeId, List<BadgeDef> collected) async {
    final alreadyHas = await _db.badgeDao.hasBadge(studentId, badgeId);
    if (alreadyHas) return;

    final def = badgeById(badgeId);
    if (def == null) return;

    await _db.badgeDao.awardBadge(
      studentId: studentId,
      badgeId: def.id,
      badgeName: def.name,
    );

    // Add points to student
    if (def.points > 0) {
      final student = await _db.studentDao.getStudentById(studentId);
      if (student != null) {
        final newPoints = student.totalPoints + def.points;
        await _db.studentDao.updateStudent(
          StudentsCompanion(id: Value(studentId), totalPoints: Value(newPoints)),
        );
        // Century badge
        if (newPoints >= 100) {
          await _award(studentId, 'century', collected);
        }
      }
    }

    collected.add(def);
  }

  /// Update streak — call once per day at first interaction.
  Future<int> updateStreak(int studentId) async {
    final student = await _db.studentDao.getStudentById(studentId);
    if (student == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = student.lastStreakDate;

    int newStreak = student.streakDays;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final lastDay =
          DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        newStreak = student.streakDays + 1;
      } else if (diff > 1) {
        newStreak = 1; // streak broken
      }
      // diff == 0 means already updated today, no change
    }

    await _db.studentDao.updateStudent(
      StudentsCompanion(
        id: Value(studentId),
        streakDays: Value(newStreak),
        lastStreakDate: Value(today),
      ),
    );

    return newStreak;
  }
}

final badgeServiceProvider = Provider<BadgeService>((ref) {
  final db = ref.watch(dbProvider);
  return BadgeService(db);
});
