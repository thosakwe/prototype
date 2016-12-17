import 'package:test/test.dart';
import 'common.dart';

main() {
  test('human', () {
    var bob = Human.instance(['Bob']);
    expect(bob.isInstanceOf(Human), isTrue);
    expect(bob.isInstanceOf(Mammal), isTrue);
    expect(bob.isInstanceOf(Animal), isTrue);
    expect(bob.warmblooded, isTrue);
    expect(bob.clazz, equals('Mammalia'));
    expect(bob.species, equals('Homo sapiens'));
    expect(bob.name, equals('Bob'));
    bob.name = 'Tim';
    expect(bob.introduce(), equals('Hi! My name is Tim.'));
  });

  test('clone', () {
    var kingOfPop = Human.instance(['Michael Jackson']);
    var imposter = kingOfPop.clone();

    // People can mimic...
    expect(imposter.deepEquals(kingOfPop), isTrue);

    // But none can ever copy another's identity.
    expect(imposter == kingOfPop, isFalse);
  });
}
