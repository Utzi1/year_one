# Preamble

I don't really like flutter (probably just because of it's name) but dart is pretty ok, hover, I got to use it anyways and therefor it's a good idea to get comfortable with it.

# Dart

## Intro

A simple `hello world` in dart:

```dart
void main() {
  print('Hello, World!');
}
```

Where we can see, that there is the requirement for a top-level main function to get the app running and that the `print` function is used to output text to the console.

Dart uses type inference which is cool but there is also the possibility to define types explicitly. Keep in mind that dart is type safe which means that you can't assign a value of one type to a variable of another type.

```dart
void main() {
  String name = 'Dart';
  print('Hello, $name!');
}
// or
var name = 'Dart';
var year = 2011;
print('Hello, $name! Dart was released in $year.');

// or:
var stuff = ["coffee", "cup", "table"];
var imgages = {
  'tag': 'coffee',
  'url': 'https://example.com/coffee.jpg'
};  
```

And of course dart also knows the usual control structures like `if`, `else`, `for`, `while` and `switch`:

```dart
// if-else
if (year >= 2011) {
  print('Dart was released in $year.');
} else {
  print('Dart was not released in $year.');
}

// for
for (final item in stuff) {
  print(item);
}

// or
for (var i = 0; i < stuff.length; i++) {
  print(stuff[i]);
}

// while
var i = 0;
while (i < stuff.length) {
  print(stuff[i]);
  i++;
}

// switch
switch (name) {
  case 'Dart':
    print('Dart is a programming language.');
    break;
  case 'Flutter':
    print('Flutter is a UI toolkit.');
    break;
  default:
    print('I don\'t know what $name is.');
}
```

To define a function in dart you can use the `=>` syntax for one-liners or the `return` keyword for more complex functions:

```dart
String greet(String name) => 'Hello, $name!';

String greet(String name) {
  return 'Hello, $name!';
}

// or 
void greet(String name) {
  print('Hello, $name!');
}

// or 
int add(int a, int b) {
  return a + b;
}

int fibonacci(int n) {
  if (n == 0 || n == 1) {
    return n;
  }
  return fibonacci(n - 1) + fibonacci(n - 2);
}

var result = fibonacci(10);
```

Classes in dart are defined with the `class` keyword and can have constructors, methods and fields.
But also getters for fields that can't be set directly and setters for fields that need some validation.

```dart
class SpaceObject{
    String name;
    // to allow null values use the ? operator
    DateTime? launchDate;

    // read-only field
    String get launchDateFormatted => launchDate?.year ?? 'unknown';year

    // constructor with syntactic sugar for assigning values to members
    SpaceObject(this.name, this.launchDate) {
        // do some validation
        if (launchDate == null) {
            throw ArgumentError('launchDate must not be null');
        }

        // do some initialization

    }

    // named constructor which forwards to the default constructor
    SpaceObject.unlaunched(String name) : this(name, null);

    // method
    void describe() {
        print('SpaceObject: $name, launched in $launchDateFormatted');
        // type promotion does not work on getters
        if (launchDate != null) {
            int years = DateTime.now().difference(launchDate!).inDays ~/ 365;
            print('It has been in space for $years years.');
            
    } else {
        print('It has not been launched yet.');
    }
}
```
Type promotion refers to the ability of the compiler to infer the type of a variable based on the context in which it is used. Dart supports type promotion for local variables, but not for getters.
In that context the `!` operator is used to tell the compiler that the value is not null.

To use the class `SpaceObject` you can do the following:

```dart
var sputnik = SpaceObject('Sputnik', DateTime(1957, 10, 4));
sputnik.describe();

var voyager = SpaceObject.unlaunched('Voyager');
voyager.describe();
```

Dart also knows so-called Enums.
Enums are used to define a collection of constant values or instances where there is ensured that there cannot be any other instances of that type.

```dart
enum CoffeeType {
  espresso,
  filter,
  coldBrew,
}

void main() {
  var type = CoffeeType.espresso;
  switch (type) {
    case CoffeeType.espresso:
      print('Espresso');
      break;
    case CoffeeType.filter:
      print('Filter coffee');
      break;
    case CoffeeType.coldBrew:
      print('Cold brew');
      break;
  }
}
```

As an example of a more complex class, here is a class that represents the machines to brew that coffee with:

```dart
enum CoffeeMachine {
  espressomachine(coffeType: CoffeeType.espresso, brand: 'La Marzocco', pressure: 9, hasMilkFrother: true),
  filtermachine(coffeType: CoffeeType.filter, brand: 'Moccamaster', pressure: 0, hasMilkFrother: false),
  coldbrewmachine(coffeType: CoffeeType.coldBrew, brand: 'Hario', pressure: 0, hasMilkFrother: false);

  // a constant constructor
  cosnt CoffeeMachine({required this.coffeeType, required this.brand, required this.pressure, required this.hasMilkFrother});

  // all instance variables are final
  final CoffeeType coffeeType;
  final String brand;
  final int pressure;
  final bool hasMilkFrother;

  // enhanced enums support getters and methods
  bool get isEspressoMachine => coffeeType == CoffeeType.espresso;
  bool get usesPressure => pressure > 0;
}


// to use it:
final machine = CoffeeMachine.espressomachine;

if (machine.isEspressoMachine) {
  print('This is an espresso machine.');  
}
```

Regarding inheritance, dart supports single inheritance.
Single inheritance means that a class can only inherit from one superclass.
But dart supports mixins which are a way to reuse code in multiple classes.

```dart
class AutomaticCoffeeMachine extends CoffeeMachine {
  double cupsPerDay;

  AutomaticCoffeeMachine(super.coffeeType, super.brand, super.pressure, super.hasMilkFrother, this.cupsPerDay);
}
```

We'll focus on the `@override` annotation as we focus on flutter, it's used to indicate that a method is overriding a method from a superclass.
Mixins are used to reuse code in multiple class hierarchies, to declare a mixin you use the `mixin` keyword.

```dart
mixin MilkFrother {
  int milkTemperature = 60;

  void frothMilk() {
    print('Frothing milk at $milkTemperature degrees.');
  }
}
```

To use a mixin in a class you use the `with` keyword:

```dart
class AutomaticCoffeeMachine extends CoffeeMachine with MilkFrother {
  double cupsPerDay;

  AutomaticCoffeeMachine(super.coffeeType, super.brand, super.pressure, super.hasMilkFrother, this.cupsPerDay);
}
```

All classes implicitly define a interface, therefor you can implement any class in dart.
Interface in that context means that a class can be used. The `implements` keyword is used to implement a class.

```dart
class Grinder implements CoffeeMachine {
 // here some implementation
}
```

Abstract classes allow you to use concrete classes to extend them.
In this context 'abstract' means that the class has abstract methods that have empty bodies.
One can create abstract classes in dart by using the `abstract` keyword.

```dart
abstract class CoffeeBean {
  void describe();

  void tastingNotes() {
    print('Tasting notes: $describe');
  }
}
```

To avoid callbacks and to work with asynchronous code `assync` and `await` are used.
`async` is used to mark a function as asynchronous and `await` is used to wait for the result of an asynchronous function.

```dart
const brewinTime = Duration(seconds: 30);

//....

Future<void> brewCoffee() async {
  print('Brewing coffee...');
  await Future.delayed(brewingTime);
  print('Coffee is ready!');
}
```

This is equivalent to:

```dart
Future<void> brewCoffee() {
  print('Brewing coffee...');
  return Future.delayed(brewingTime).then((_) => print('Coffee is ready!'));
}
```

This helps to make asynchronous code more readable and easier to understand, here a more complex example.
Here the 

```dart
Future<void> createDescription(Iterable<String> tastingNotes) async {
    for (final notes in tastingNotes) {
        try {
            var file = File('$notes.txt');
            if (await file.exists()) {
                print('File $notes.txt already exists.');
                continue;
            }
            await file.create();
            await file.writeAsString('Tasting notes: $notes');
            print('File $notes.txt created.');
        } on IOException catch (e) {
            print('An error occurred: $e');
        }
}
```

To build streams in dart you can use the `assync*` keyword.
Streams are used to handle a sequence of events or values over time.
To create a stream you can use the `Stream` class.

```dart
Stream<String> taste(coffeeBean, coffeeMachine, createDescription) async* {
  yield 'Tasting coffee...';
  yield 'Tasting notes: ${coffeeBean.describe()}';
  yield 'Brewing coffee...';
  await coffeeMachine.brewCoffee();
  yield 'Coffee is ready!';
  await createDescription(coffeeBean.tastingNotes());
  yield 'Description created.';
}
```

## Variables

Variables in Dart store references to objects.
Consider `var name = "Dart";` the variable `name` stores a reference to a string object with the value `Dart`.
`name` is typed as `String` but can be reassigned if an `Object` is not restricted to a specific type (or by using the `dynamic` type).

```dart
Object name = "Dart";
```

Also consider that you can explicitly define the type of a variable:

```dart
String name = "Dart";
```

Variables are nullsafe by default in Dart, which means that you can't assign `null` to a variable that is not explicitly typed as nullable.
This however can be changed by using the `?` operator:

```dart
String? name = null;
```

However keep in mind that `null` leads to runtime errors if not handled properly.
When initialising a variable with a nullable type it will be null by default:

```dart
String? name;
assert(name == null);
```

When initialising a variable with a non-nullable type it needs to be assigned a value before it can be used:

```dart
String name = "Dart";
assert(name != null);
```

In case that it'll be assigned prior to usage it's also possible to use it without default assignment:

```dart
String name;

if (name is not assigned) {
  name = "Dart";
}

print(name);
```

Another option to handle this is to use the `late` keyword which tells the compiler that the variable will be assigned before it's used:

```dart
late String name;

void main() {
  name = "Dart";
  print(name);
}
```

When you mark a variable as late but initialize it at its declaration, then the initializer runs the first time the variable is used. 
This lazy initialization is handy in a couple of cases:
The variable might not be needed, and initializing it is costly.
You're initializing an instance variable, and its initializer needs access to this.
Sometime its crucial that some value does not change over time, in that case you can use the `final` keyword:

```dart
final String name = "Dart";
```

Or if you want to make sure that the value is not changed after the initial assignment:

```dart
const String name = "Dart";
```

`const` is used to declare compile-time constants, which means that the value is known at compile time.
Any variable marked as `const` is implicitly `final` and can't be reassigned.
Also any variable can be `const`:

```dart
var foo = const [];

foo = [1, 2, 3]; // Error: foo is a const variable

final bar = const [];

bar = [1, 2, 3]; // Error: bar is a final variable

// equivalent to const []
const baz = const [];
```

### Metadata

Dart supports metadata which is used to provide additional information about the program.
Here it uses the `@` symbol to indicate that it's metadata:

```dart
Deprecated('Use newMethod() instead')
void oldMethod() {
  print('This is the old method.');
}

@deprecated // won't show a specific message
```

It's also possible to define custom metadata:

```dart
class Todo {
  final String who;
  final String what;

  const Todo(this.who, this.what);
}

// and use it like this
@Todo('author', 'write documentation')
void doSomething() {
  print('Do something...');
}
```

### Collections

Dart has built-in support for lists, sets, and maps.
Lists are ordered collections of objects, sets are unordered collections of unique objects, and maps are collections of key-value pairs.

```dart
// a list
var variaty = ["Guji", "Catuarra", "SL34"];

// when creating an empty set you need to specify the type
var uniqueVariety = <String>{};

// or a set with unique items
var uniqueVariety = {"Guji", "Catuarra", "SL34"};

// or a set with a specific type
var moreUniqueVariety = <String>{"Catiguà", "Typica", "Heriloom"};
// possible set operations:
uniqueVariety.add("Burbon");

// add all:
uniqueVariety.addAll(moreUniqueVariety);

// remove:
uniqueVariety.remove("SL34");

// check if an item is in the set:
uniqueVariety.contains("Guji");
uniqueVariety.containsAll(moreUniqueVariety);

final uniqueVarietyList = uniqueVariety.toList();
final uniqueVarietySet = const {"Guji", "Catuarra", "SL34"};

// and a map
var coffee = {
  'variety': 'Guji',
  'origin': 'Ethiopia',
  'process': 'natural'
};

// or a map with a specific type
var coffee = <String, String>{
  'variety': 'Heriloom',
  'origin': 'Ethiopia',
  'process': 'wahsed'
};

// to get the keys and values of a map
var keys = coffee.keys;
var values = coffee.values;

// create  the same map with a map constructor
var coffee = Map<String, String>.from({
  'variety': 'Heriloom',
  'origin': 'Ethiopia',
  'process': 'wahsed'
});

// or
var coffee = Map<String, String>();
coffee['variety'] = 'Heriloom';
coffee['origin'] = 'Ethiopia';
coffee['process'] = 'wahsed';
```

## Classes

Dart is an object-oriented language and supports classes and interfaces, in that context, every object is an instance of a class (besides null).
Classes in dart are defined with the `class` keyword and can have constructors, methods, and fields.
Mixin-based-inheritance means that every class, besides the top class `Object?`, inherits from exactly one superclass.
With class modifiers it's possible to gain control how libraries subtype classes.
Class members, like functions and data (methods and instance variables), are public by default but can be marked as private using the `_` symbol.
```dart
var p = Point(2, 2);

// get the value of y:
assert(p.y == 2);

// invoke distanceTo() method:
num distance = p.distanceTo(Point(4, 4));

// in case some point might be null:
var a = p?.y; // a will be null if p is null
```

When creating an object from a class, constructors are used.
Constructors are special methods that are called when an object is created.
If no constructor is defined, a default constructor is used
They either get called directly by `ClassName` or an associated identifier `ClassName.identifier`.
```dart
var p1 = Point(2, 2);
var p2 = Point.fromJson({'x': 1, 'y': 2});

// the keyword `new` is optional
var p3 = new Point(2, 2);
var p4 = new Point.fromJson({'x': 1, 'y': 2});

// constant constructors are used to create compile-time constants
var p = const ImmutablePoint(2, 2);
```
Factory constructors either return a new instance of a subclass or return an already existing instance from cache.
There is two scenarios when factory constructors come in handy:

1. The constructor does not always create a new instance of it's class but can't return `null` either. So it might return an existing instance from cache or a new instance of a subtype.
2. Some kind of non-trivial initialization is required that can't be done in the initializer list.

```dart
class Logger {
  final String name;
  bool mute = false;

  // _cache is library-private, thanks to the _ in front of its name.
  static final Map<String, Logger> _cache = <String, Logger>{};

  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }

  factory Logger.fromJson(Map<String, Object> json) {
    return Logger(json['name'].toString());
  }

  Logger._internal(this.name);

  void log(String msg) {
    if (!mute) print(msg);
  }
}

// and use it like this
var logger = Logger('UI');
logger.log('Button clicked');
var logMap = {'name': 'UI'};
var loggerJson = Logger.fromJson(logMap);
```

## Extend classes

Dart supports single inheritance, which means that a class can only inherit from one superclass.
Use the `extends` keyword to create a subclass and the `super` keyword to refer to the superclass.
```dart
class Television {
  void turnOn() {
    _illuminateDisplay();
    _activateScreen();
  }

  set contrast(int value) {
    // do some validation
  }

  // _illuminateDisplay() and _activateScreen() are private functions
}

class SmartTelevision extends Television {
  void turnOn() {
    super.turnOn();
    _bootNetworkInterface();
    _initializeMemory();
    _upgradeApps();
  }

  // _bootNetworkInterface(), _initializeMemory(), and _upgradeApps() are private functions
}
```

Some cases require a reimplementation of instance methods of the superclass.
To do so, use the `@override` annotation to indicate that a method is overriding a method from a superclass.
```dart
class SmartTelevision extends Television {
  @override
  set contrast(num value) {
    // do some validation
  }
}
```

# Flutter

Building a flutter app is done by composing widgets, which are the building blocks of a flutter app.
Widgets are used to create the user interface of the app and can be either stateless or stateful.
Stateless widgets are immutable and can't change their state during the runtime of the app.
Stateful widgets can change their state during the runtime of the app.

A simple `Hello World` app in flutter is simply calling the `runApp` function with a widget as an argument.
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
  // the widget that is passed to runApp is the root widget of the app
    Center(
    // the child of the Center widget is a Text widget
      child: Text(
      // the text that is displayed
        'Hello, World!',
        // textDirection is used to set the direction of the text and ltr stands for left-to-right
        textDirection: TextDirection.ltr,
      ),
    ),
  );
}
```

`runApp` is a function that is used to run the app and takes a widget and makes it the root of the widget tree.
The widget tree is a tree of widgets that are used to build the user interface of the app.
In this case the widget tree constists of a `Center` widget with a `Text` widget as a child.
Some basic widgets that are used to build the user interface of a flutter app are:

- `Container`: A widget that is used to contain other widgets.
- `Row`: A widget that is used to display its children in a horizontal row.
- `Column`: A widget that is used to display its children in a vertical column.
- `Stack`: A widget that is used to display its children in a stack.
- `Text`: A widget that is used to display text.


# Unit testing

To keep the app working as expected, it's a good idea to write unit tests.
Unit tests are used to test individual units of code, like functions or classes.
In flutter, the `test` package is used to write unit tests.
The `test` package provides a `test` function that is used to define a test.
Tests are stored individually in files and are run by the test runner.

Our clas we want to test counts stuff:

```dart
class Counter {
  int value = 0;

  void increment() {
    value++;
  }

  void decrement() {
    value--;
  }
}
```

To test the `Counter` class we write a test:

```dart
// import the test package
import 'package:test/test.dart';
// import the class we want to test:
import 'package:dart_diary/counter.dart';

void main() {
  // define the test
  test('Counter value should be incremented', () {
    // create an instance of the class we want to test
    final counter = Counter();
    // call the increment method
    counter.increment();
    // check if the value is incremented
    expect(counter.value, 1);
  });
}
```

If there is several tests to run, you can group them together using the `group` function:

```dart
void main() {
  group('Counter', () {
    test('value should be incremented', () {
      final counter = Counter();
      counter.increment();
      expect(counter.value, 1);
    });

    test('value should be decremented', () {
      final counter = Counter();
      counter.decrement();
      expect(counter.value, -1);
    });
  });
}
```

To run such tests on the terminal you can use the `flutter test` command:

```bash
flutter test
```

## `TextField` class

Is a Material Design text field and can be used to get user input.
The `TextField` class has several properties that can be used to customize the appearance and behavior of the text field.
It calls the `onChanged` callback whenever the user changes the text in the text field and calls the `onSubmitted` callback when the user submits the text.
Another useful property is the `controller` property which can be used to control the text field and gives the user an idea what kind of nature his input should be.

```dart
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
    const MyTextField({super.key});

    @override
    Widget build(BuildContext context) {
        return const SizedBox(
            width: 200,
            child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your name',
                ),
                onChanged: (text) {
                    print('Text changed: $text');
                },
                onSubmitted: (text) {
                    print('Text submitted: $text');
                },
            ),
        );
    }
}

void main() {
    runApp(
        MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('Text Field Example'),
                ),
                body: const Center(
                    child: MyTextField(),
                ),
            ),
        ),
    );
}
```

In case of passwords one can use the `obscureText` property to hide the text:

```dart
TextField(
    decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Enter your password',
    ),
    obscureText: true,
    onChanged: (text) {
        print('Text changed: $text');
    },
    onSubmitted: (text) {
        print('Text submitted: $text');
    },
),
```

## `TextFormField` class

Is a Material Design text field and can be used to get user input, it's a convenience widget that wraps a `TextField` in a `FormField`.
For example, it can be used to validate user input and to display error messages:
```dart
import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
    const MyTextFormField({super.key});

    @override
    Widget build(BuildContext context) {
        return const SizedBox(
            width: 200,
            child: TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'What does it say on your birth certificate?',
                    labelText: 'Enter your name',
                ),
                validator: (value) {
                    if (value.isEmpty) {
                        return 'Please enter your name';
                    }
                    return null;
                },
                onSaved: (value) {
                    print('Name saved: $value');
                },
                validator: (String? value) {
                    return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
            ),
        );
    }
}

void main() {
    runApp(
        MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('Text Form Field Example'),
                ),
                body: const Center(
                    child: MyTextFormField(),
                ),
            ),
        ),
    );
}
```



## `ListView` class

Is a scrollable list of widgets and can be used to display a list of items.
The `ListView` class has several properties that can be used to customize the appearance and behavior of the list.
`children` property is used to specify the widgets that are displayed in the list.
`scrollDirection` property is used to specify the direction in which the list is scrolled, horizontal, diagonally eg.
For more: `https://api.flutter.dev/flutter/widgets/ListView-class.html`.

```dart
import 'package:flutter/material.dart';

class MyListView extends StatelessWidget {
    const MyListView({super.key});

    @override
    Widget build(BuildContext context) {
        return ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
                Container(
                    width: 160.0,
                    color: Colors.red,
                ),
                Container(
                    width: 160.0,
                    color: Colors.blue,
                ),
                Container(
                    width: 160.0,
                    color: Colors.green,
                ),
                Container(
                    width: 160.0,
                    color: Colors.yellow,
                ),
                Container(
                    width: 160.0,
                    color: Colors.orange,
                ),
            ],
        );
    }
}

void main() {
    runApp(
        MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('List View Example'),
                ),
                body: const Center(
                    child: MyListView(),
                ),
            ),
        ),
    );
}
```
