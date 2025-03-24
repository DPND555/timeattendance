// import 'package:flutter/material.dart';
// import 'package:timeattendance/api.dart';

// class LogInPage2 extends StatefulWidget {
//   const LogInPage2({super.key});

//   @override
//   State<LogInPage2> createState() => _LogInPage2State();
// }

// class _LogInPage2State extends State<LogInPage2> {
//   final username = TextEditingController();
//   final password = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage(
//                     'lib/img/backgroun.jpg',
//                   ),
//                   fit: BoxFit.cover)),
//           height: MediaQuery.of(context).size.height * 1,
//           width: MediaQuery.of(context).size.width * 1,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Card(
//                   color: Colors.white,
//                   elevation: 15,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Login to Cityparking",
//                           style: TextStyle(
//                             fontFamily: 'Bitter',
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         TextField(
//                           controller: username,
//                           cursorColor: Colors.black,
//                           textInputAction: TextInputAction.next,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide(
//                                 color: Colors.grey[600]!,
//                                 width: 2,
//                               ),
//                             ),
//                             hintText: 'Enter your email',
//                             prefixIcon: const Icon(Icons.person_outline),
//                           ),
//                         ),
//                         TextField(
//                           controller: password,
//                           cursorColor: Colors.black,
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide(
//                                 color: Colors.grey[600]!,
//                                 width: 2,
//                               ),
//                             ),
//                             hintText: 'Enter your password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: MyColors.red,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                             ),
//                             onPressed: () async {
//                               // if (username.text.isEmpty &&
//                               //     password.text.isEmpty) {
//                               //   Fluttertoast.showToast(
//                               //     msg: 'กรุณากรอกข้อมูลให้ครถ้วน',
//                               //     toastLength: Toast.LENGTH_LONG,
//                               //     gravity: ToastGravity.BOTTOM,
//                               //     backgroundColor: Colors.white,
//                               //     textColor: Colors.black,
//                               //     fontSize: 16.0,
//                               //   );
//                               // } else {
//                               //   Api.login(
//                               //     context: context,
//                               //     username: username.text,
//                               //     password: password.text,
//                               //   );
//                               //   username.clear();
//                               //   password.clear();
//                               // }
//                               await Api.login(
//                                 context: context,
//                                 username: '',
//                                 password: '',
//                               );
//                             },
//                             child: const Text(
//                               "Login",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
            
//           ),
//         ),
//       ),
//     );
//   }
// }

// //
