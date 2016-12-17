import 'package:prototype/prototype.dart';

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
