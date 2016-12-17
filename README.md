# prototype

[![version 1.0.0](https://img.shields.io/badge/pub-v1.0.0-brightgreen.svg)](https://pub.dartlang.org/packages/prototype)
[![build status](https://travis-ci.org/thosakwe/prototype.svg)](https://travis-ci.org/thosakwe/prototype)

Prototypal inheritance for Dart.

```dart
final ProtoType Animal = new ProtoType(
    name: 'Animal',
    prototype: {#warmblooded: false},
    constructor: (ctx, [args, named]) {
      ctx
        ..clazz = args[0]
        ..species = args[1];
    });

final ProtoType Mammal = new ProtoType.extend(Animal,
    name: 'Mammal',
    prototype: {#warmblooded: true}, constructor: (ctx, [args, named]) {
  ctx.superConstructor(['Mammalia', args[0]]);
});

final ProtoType Human = new ProtoType.extend(Mammal, name: 'Human',
    constructor: (ctx, [args, named]) {
  ctx.superConstructor(['Homo sapiens']);
  ctx.name = args[0];
}, prototype: {
  #introduce: (ctx, [args, named]) {
    return 'Hi! My name is ${ctx.name}.';
  }
});

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
```