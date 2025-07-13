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

## Typical flutter app file folder structure

![Flutter file folder structure](https://firebasestorage.googleapis.com/v0/b/flutter-firebase-project-11493.firebasestorage.app/o/public%2FScreenshot%202025-07-10%20192101.png?alt=media&token=ba41da2f-ff80-4bda-a660-198c9a180c5b)

## Description of methods

## 1. Octobase server method

you have to register your Octobase server first. This method initializes the Octobase singleton instance with a base server URL and configures the Dio client(s) and logger(Enables debug logging).Returns Octobase - The initialized singleton instance, ready to use for login, register, CRUD operations, etc.Call this once, ideally at app startup (e.g., inside main() or in an app initializer).Optionally can configures a mock Dio instance for testing environments and allows attaching custom interceptors.

you have to send below parameters by below order to the this method for use this method

- serverURL(String) - required, The base URL of your backend server (e.g., http://serverurl.com)

- mainRoute(String) - required, The primary route prefix for API endpoints (e.g., api, v1, etc.)

- debugLogs(bool) - optional, Enables LogInterceptor to print request/response logs in debug mode. Default is false.

- dio(Dio?) - optional, Provide your own Dio instance for full control.

- mockDio(Dio?) - optional, Optional Dio instance used when mocking (isMock: true).

- interceptors(List<Interceptor>) - optional, Custom interceptors to attach to the main Dio instance.

- mockInterceptors(List<Interceptor>) - optional, Custom interceptors to attach the mock Dio instance.

example 1
```dart
Octobase octobase =
        OctobaseServer.init('http://serverurl.com', 'api/school/v1');
```
example 2
```dart
import 'package:octobase_flutter/octobase_flutter.dart';

class OctobaseService {
  static final Octobase octobase = OctobaseServer.init(
    'http://10.0.2.2/october-v3.7/october', // replace with your actual server URL
    'api/school/v1',
    debugLogs: true //you can enable this if you want to view debug logs
  );
}
```

please note your API routes must start with octobase eg: octobase/api/school/v1

example php API code snippet
```php
<?php

use Dilexus\Octobase\Classes\Api\Lib\Octobase;

  Route::prefix('octobase/api/school/v1')->group(function () { // api route must starts with octobase 

    (new Octobase)->crud('peter\universitymanagement\Models\Student',
        ['obRegistered'], // List All records
        ['obRegistered'], // List single record
        ['obRegistered'], // add single record
        ['obRegistered'], // update single record
        ['obRegistered']  // delete single record
    );

});
```

## 2.Register method

Registers a new user with the server.Returns Future<OctobaseResponse<UserInfo>> - a response object containing a UserInfo instance if the registration is successful.

you have to send below parameters by below order to the register method for use this method

parameters by order

- firstName(string) - required, User's first name

- lastName(String) - required, User's last name

- email(String) - required, user's email

- userName(String) - required, for username you can send either user's email again or you can provide a separate username

- passwowrd(String) - required, password that will be used for future login of user

- confirmPassword(String) - required, confirm password should perfectly match the original password otherwise server will reject the request

- cacheToken(bool) - optional, Whether to store the token locally using SharedPreferences (default: true)

- appCheckToken(String) - optional, Firebase App Check token

- isMock(bool) - optional, Use the mock Dio instance instead of the real one (for testing)

example code 

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
```
## 3.Login method

For already registered users you can grant access of the server by sending credentials. Returns
Future<OctobaseResponse<UserInfo>> - A response object containing a UserInfo instance if login is successful.

you have to send below parameters by below order to the login method for use this method

parameters by order

- email(String) - required, email address that using for login

- password(String) - required, password associated with the account

- cacheToken(bool) - optional, Whether to store the token in SharedPreferences (default: true)

- appCheckToken(String) - optional, Firebase App Check token for extra validation

- isMock(bool) - optional, Use the mock Dio instance instead of the real one (for testing)

example code

```dart
//Login User

 octobase.login('hello@gmail.com', 'hello12345').then((value) {
      debugPrint(value.token);
    }).catchError((error, stackTrace) {
      debugPrint(error);
    });
```

## 4.Refresh method

Sends a POST request to /refresh with the token in the Authorization header: .If the current token is valid, it returns a new refreshed token.The refreshed token can optionally be cached for persistent authentication.

you have to send below parameters by below order to the refresh method for use this method

parameters by order

- cacheToken(bool) - optional, Whether to store the new token in SharedPreferences (default: true)

- appCheckToken(String) - optional, Firebase App Check token for extra security. 

- isMock(bool) - optional, Use mock Dio instance instead of the real one (for testing)

exampel code
```dart
// Refresh Token   
 octobase.refresh().then((userInfo) {
        debugPrint(userInfo.token);
      }).catchError((error, stackTrace) {
        debugPrint(error);
      });
```
## 5.user method

Sends a GET request to the /user endpoint with the Authorization header.Retrieves the current user's profile data (such as name, email, etc.). Uses the token previously saved during login or registration. Returns
Future<OctobaseResponse<UserInfo>> - A response object containing the user's information (UserInfo) if the token is valid.

there is only one parameter

- isMoack(bool) - optional, If true, uses the mock Dio client instead of the real one (used for testing). Default is false.

example code 
```dart
// Get User Information
   octobase.user().then((userInfo) {
        debugPrint(userInfo.token);
      }).catchError((error, stackTrace) {
        debugPrint(error);
      });
```
## Creating a model

please note that we are communicating with the server through json objects and json arrays. So when we receive json data from server we have to convert this json objects to dart objects and vise versa when sending data to the server. For that we have to build a model for passing and receiving data with server. We are doing that using json serialization and deserialization. Below there is a example code for how to build a model.

```dart
// Select from a Model. You need to generate the model using JSON Serializable

// Student model
import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart'; // Required for code generation

@JsonSerializable()
class Student {
  int? id;
  String? name;
  String? address;
  String? gender;

  Student({this.id, this.name, this.address, this.gender});

// Factory method for deserialization
  factory Student.fromJson(Map<String, dynamic> json) {
    return _$StudentFromJson(json);
  }

// Method for serialization
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
```
After coding the model you have to run below command. This generates the student.g.dart file that contains the code used by fromJson() and toJson().

```bash
flutter pub run build_runner build
```
## Crud operations methods

## 1. selectAll method

Fetches list of objects from the server. Performs a GET request to retrieve multiple records (e.g., a list of users, students, posts, etc.).Automatically maps the response to a list of objects using the fromJson function you provide. Returns a list of objects.

you have to send below parameters by below order to the method for use this method

parameters by order

- fromJson(Function) -	Required, Converts each JSON map into a Dart object.

- controller(String?) - Optional, override for controller name. Defaults to plural form of T.

- mainRoute(String?) -	Optional, override for base route (defaults to value passed to Octobase.init).

- action(String) - Optional, action segment in the route (e.g., active, archived).

- page(int?) - optional,	Page number for pagination.

- perPage(int?) - optional, Number of items per page.

- userId(String?) -	optional, Filters items belonging to a specific user.

- own(String?) -	optional, Include items owned by the authenticated user.

- withOthers(String?) - optional, Join related data (e.g., with=comments).

- select(String?) - optional,	Select specific columns (e.g., id,name).

- where(String?) -	optional, Apply filters (e.g., status=active).

- order(String?) - optional,	Sorting (e.g., created_at desc).

- isMock(bool) -	optional, If true, uses the mock Dio instance for testing.

code example
```dart
// Select
octobase.selectAll<Student>(Student.fromJson).then((value) {
      print(value.data?[0].gender);
    }).onError((error, stackTrace) {
      print(error);
    });
```
## 2. add method

Sends a POST request to the server to create a new record.Automatically serializes the data and deserializes the response into a model object. Returns the object containing data that created on the backend.

you have to send below parameters by below order to the method for use this method

parameters by order

- fromJson(Function) - 	Required. Converts JSON response into a Dart object.

- data(Map<String, dynamic>?) -	Optional, The data to send in the request body (e.g., {'name': 'Jane'}).

- controller(String?) -	Optional, controller override. Defaults to plural of T.

- mainRoute(String?) -	Optional base route. Defaults to the one passed into Octobase.init().

- action(String) -	Optional, Additional route segment (e.g., 'custom-create').

- isMock(bool) - Optional, Uses mock Dio instance if set to true.

example code
```dart
// Add
octobase.add<Student>(Student.fromJson, data: {
      'name': 'Peter',
      'address': "Flower Road",
      "gender": "male"
    }).then((response) {
      print(response.name);
    });
```
## 3. update method
Sends a POST request to update an existing record by ID.Returns the updated object and maps the server response back to a Dart object 

you have to send below parameters by below order to the method for use this method

parameters by order

- fromJson(Function) -	Required. Converts JSON response into a Dart object.

- id(int) -	Required. The ID of the record to update.

- data(Map<String, dynamic>?) -	Optional, Data fields to be updated (e.g., {'name': 'Jane Updated'}).

- controller(String?) -	Optional controller override. Defaults to plural of model name.

- mainRoute(String?) -	Optional base route. Defaults to the value set in Octobase.init().

- action(String) -	Optional, Additional route segment, if needed.

- isMock(bool) - Optional, Uses mock Dio if true.

example code
```dart

//Update
    octobase.update<Student>(Student.fromJson, 4, data: {'name': 'Dilan'}).then(
        (response) {
      print(response.name);
    });
```
## 4. delete method 

Sends a DELETE request to remove a record from the backend by its ID. Returns status of the deleting process.

you have to send below parameters by below order to the method for use this method

parameters by order

- id(int) -	Required. ID of the record to delete.

- controller(String?) -	Optional override for the controller name. Defaults to plural form of T.

- mainRoute (String?) -	Optional base path. Defaults to the one set in Octobase.init().

- action(String) - Optional extra segment for custom delete routes.

- isMock(bool) - Optional,If true, uses the mock Dio instance for testing.

example code

```dart
//Delete
    octobase.delete<Student>(8).then((response) {});
```


## License

License (MIT)
Copyright (c) 2021 Chatura Dilan Perera

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Support
Please contact dilan@dilan.me for support and Sample Application
