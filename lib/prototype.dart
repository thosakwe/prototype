/// Prototypal inheritance for Dart.
library prototype;

import 'package:matcher/matcher.dart';

final RegExp _equ = new RegExp(r'=$');
final RegExp _sym = new RegExp(r'Symbol\("([^"]+)"\)');

typedef ProtoTypeFunction(ProtoTypeInstance context,
    [List args, Map<Symbol, dynamic> named]);

/// A structure that can be reflected without the use of mirrors.
class ProtoType {
  ProtoType _superClass;

  /// The parent of this type, if any.
  ProtoType get superClass => _superClass;

  /// An optional function to run when instantiating this type.
  ProtoTypeFunction constructor;

  /// The name of this type.
  final String name;

  /// A set of member fields to create on new instances.
  final Map<Symbol, dynamic> prototype = {};

  ProtoType(
      {Map<Symbol, dynamic> prototype: const {}, this.constructor, this.name}) {
    this.prototype.addAll(prototype ?? {});
  }

  /// Creates a type that inherits from another.
  factory ProtoType.extend(ProtoType superClass,
      {Map<Symbol, dynamic> prototype: const {},
      ProtoTypeFunction constructor,
      String name}) {
    return new ProtoType(
        prototype: prototype,
        constructor: constructor,
        name: name).._superClass = superClass;
  }

  /// Returns `true` if the type is, or is a child of, the given [type].
  bool isAssignableTo(ProtoType type) {
    if (type == null) return false;
    if (_superClass == type) return true;

    ProtoType search = this;

    while (search != null) {
      if (search == type) return true;
      search = search.superClass;
    }

    return false;
  }

  /// Creates an instance of this type.
  ProtoTypeInstance instance([List args, Map<Symbol, dynamic> named]) {
    // First, collect inheritance
    List<ProtoType> inheritance = [];

    ProtoType type = this;

    while (type != null) {
      inheritance.insert(0, type);
      type = type.superClass;
    }

    // Next, add all prototypes
    var instance = new _ProtoTypeInstanceImpl(this);

    for (ProtoType type in inheritance) {
      instance._members.addAll(type.prototype);
    }

    // Now, run constructor, if any
    if (constructor != null) {
      constructor(instance, args, named);
    }

    return instance;
  }
}

/// A dynamic instance of a [ProtoType].
@proxy
abstract class ProtoTypeInstance {
  Map<Symbol, dynamic> get _members;
  Map<Symbol, dynamic> get members => new Map.unmodifiable(_members);

  /// The [ProtoType] that created this instance.
  ProtoType get type;

  /// Produces a clone of this instance.
  ProtoTypeInstance clone();

  /// Returns `true` if [other] is of the same type as this, and has identical members.
  bool deepEquals(ProtoTypeInstance other) =>
      other.type == type && equals(_members).matches(other._members, {});

  /// Equivalent of calling `super(args, named)`.
  void superConstructor([List args, Map<Symbol, dynamic> named]);

  operator [](Symbol key) => _members[key];
  operator []=(Symbol key, value) => _members[key] = value;

  /// Returns `true` if this is an instance of the given [type].
  bool isInstanceOf(ProtoType type) => this.type.isAssignableTo(type);

  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.memberName != null) {
      if (invocation.isMethod) {
        ProtoTypeFunction fn = _members[invocation.memberName];
        return fn(
            this, invocation.positionalArguments, invocation.namedArguments);
      } else if (invocation.isGetter) {
        return _members[invocation.memberName];
      } else if (invocation.isSetter) {
        var str = invocation.memberName
            .toString()
            .replaceAllMapped(_sym, (match) => match[1]);
        var name = new Symbol(str.replaceAll(_equ, ''));
        return _members[name] = invocation.positionalArguments.first;
      }
    }

    super.noSuchMethod(invocation);
  }

  @override
  String toString() {
    if (_members.containsKey(#toString)) {
      return _members[#toString]();
    } else if (type.name != null) {
      return 'Instance of ${type.name}';
    } else
      return super.toString();
  }
}

class _ProtoTypeInstanceImpl extends ProtoTypeInstance {
  @override
  Map<Symbol, dynamic> _members = {};

  @override
  final ProtoType type;

  _ProtoTypeInstanceImpl(this.type);

  @override
  ProtoTypeInstance clone() =>
      new _ProtoTypeInstanceImpl(type).._members.addAll(_members);

  @override
  void superConstructor([List args, Map<Symbol, dynamic> named]) {
    if (type.superClass == null) {
      throw new ProtoTypeException.orphan();
    } else if (type.superClass.constructor == null) {
      throw new ProtoTypeException('Super class has no constructor.');
    }

    // To get super constructors to be recursive, let's just
    // make a new instance of the super class.
    // We copy members before and after.
    // Tada!
    var provisional = new _ProtoTypeInstanceImpl(type.superClass);
    provisional._members.addAll(_members);
    type.superClass.constructor(provisional, args, named);
    _members.addAll(provisional._members);
  }
}

class ProtoTypeException implements Exception {
  final String message;

  ProtoTypeException(this.message);

  factory ProtoTypeException.orphan() => new ProtoTypeException(
      'Super constructor called on type with no parent.');

  @override
  String toString() => 'ProtoTypeException: $message';
}
