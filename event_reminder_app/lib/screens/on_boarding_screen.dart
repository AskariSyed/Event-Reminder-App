import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'lib/assets/Reminders.png',
      'title': 'Set Reminders',
      'description':
          'Never miss an important event again. Set and manage reminders easily.',
    },
    {
      'image': 'lib/assets/schedule.png',
      'title': 'Stay Organized',
      'description':
          'Keep track of all your events in one place with our clean calendar.',
    },
    {
      'image': 'lib/assets/notify.png',
      'title': 'Get Notified',
      'description':
          'Receive timely notifications so you’re always on time and prepared.',
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(
      context,
      '/auth',
    ); // or your main screen route
  }

  Widget _buildPage(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(page['image']!, height: 250),
        const SizedBox(height: 40),
        Text(
          page['title']!,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            page['description']!,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentIndex == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color:
            _currentIndex == index ? const Color(0xFF6F61EF) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(onboardingData[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onboardingData.length, _buildIndicator),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _goToHome,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F61EF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentIndex == onboardingData.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
