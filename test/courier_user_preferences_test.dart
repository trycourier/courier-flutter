import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Preference topic JSON', () {
    // The single-topic read leaves out the section fields for a topic that isn't in a section
    test('a topic without a section decodes', () {
      final topic = CourierUserPreferencesTopic.fromJson({
        'default_status': 'OPTED_IN',
        'has_custom_routing': false,
        'custom_routing': [],
        'status': 'OPTED_OUT',
        'topic_id': 't',
        'topic_name': 'Topic',
      });
      expect(topic.topicId, 't');
      expect(topic.status, CourierUserPreferencesStatus.optedOut);
      expect(topic.sectionName, '');
      expect(topic.sectionId, '');
    });

    test('a topic without routing fields decodes', () {
      final topic = CourierUserPreferencesTopic.fromJson({
        'default_status': 'OPTED_IN',
        'status': 'OPTED_IN',
        'topic_id': 't',
        'topic_name': 'Topic',
        'section_name': 'S',
        'section_id': 's',
      });
      expect(topic.customRouting, isEmpty);
      expect(topic.hasCustomRouting, false);
      expect(topic.sectionName, 'S');
    });

    test('a topic without an id still fails', () {
      expect(
        () => CourierUserPreferencesTopic.fromJson({
          'default_status': 'OPTED_IN',
          'status': 'OPTED_IN',
          'topic_name': 'Topic',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
