import 'package:capstone_app/mobile_screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

Future<void> _register(BuildContext context) async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Store token for 1 day
      await prefs.setString('auth_token', 'dummy_token');
      await prefs.setInt(
          'token_expiry', DateTime.now().millisecondsSinceEpoch + (24 * 60 * 60 * 1000));

      // Show success banner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            'Successful!',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.green,
          leading: Icon(Icons.check_circle, color: Colors.white),
          margin: EdgeInsets.all(10),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );

      // Auto-dismiss the banner and navigate to the dashboard
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

        if (mounted) { // Ensure the widget is still mounted before navigating
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        }
      });
    } else {
      // Show login failed banner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            'Login Failed!',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(10),
          actions: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
            ),
          ],
        ),
      );

      // Auto-dismiss the failure banner
      Future.delayed(Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextField(
                //controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                //controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                //controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                //controller: _roleController,
                decoration: InputDecoration(
                  hintText: 'Role',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _register(context),
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}