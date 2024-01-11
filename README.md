<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Connect OctoberCMS with Flutter using Octobase Plugin.

## Features

Register, Login, View User Information, Check Token, Register with Firebase
Select, Add, Update, Delete Operations 

## Getting started

1. Register your Octobase server first
```dart
Octobase octobase =
        OctobaseServer.init('http://serverurl.com', 'api/school/v1');
```
please note your API routes must start with octobase eg: octobase/api/school/v1

## Usage

Examples

```dart

// Register User
octobase
        .register('Hello', 'Dilan', 'hello@gmail.com', 'hello', 'hello12345',
            'hello12345')
        .then((value) {
      debugPrint(value.email);
    }).catchError((error, stackTrace) {
      debugPrint(error);
    });

//Login User

 octobase.login('hello@gmail.com', 'hello12345').then((value) {
      debugPrint(value.token);
    }).catchError((error, stackTrace) {
      debugPrint(error);
    });

// Refresh Token   
 octobase.refresh().then((userInfo) {
        debugPrint(userInfo.token);
      }).catchError((error, stackTrace) {
        debugPrint(error);
      });

// Get User Information
   octobase.user().then((userInfo) {
        debugPrint(userInfo.token);
      }).catchError((error, stackTrace) {
        debugPrint(error);
      });

// Select from a Model. You need to generate the model using JSON Serializable

// Student model
import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  int? id;
  String? name;
  String? address;
  String? gender;

  Student({this.id, this.name, this.address, this.gender});

  factory Student.fromJson(Map<String, dynamic> json) {
    return _$StudentFromJson(json);
  }
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

// Select
octobase.selectAll<Student>(Student.fromJson).then((value) {
      print(value.data?[0].gender);
    }).onError((error, stackTrace) {
      print(error);
    });

// Add
octobase.add<Student>(Student.fromJson, data: {
      'name': 'Peter',
      'address': "Flower Road",
      "gender": "male"
    }).then((response) {
      print(response.name);
    });

//Update
    octobase.update<Student>(Student.fromJson, 4, data: {'name': 'Dilan'}).then(
        (response) {
      print(response.name);
    });

//Delete
    octobase.delete<Student>(8).then((response) {});


```

License (MIT)
Copyright (c) 2021 Chatura Dilan Perera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Support
Please contact dilan@dilan.me for support and Sample Application
