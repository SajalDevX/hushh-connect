import 'package:flutter/material.dart';
import 'package:hushhxtinder/ui/app/vibes/vibesViewModel.dart';
import 'package:provider/provider.dart';

class VibesScreen extends StatefulWidget {
  final String vibeEventName;
  final int vibeEventId;
  final List<String> randomLikes = [
    "Check the vibe before you match",
    "Answer questions honestly to see who matches your vibe",
    "Opt out anytime in the settings"
  ];

  final List<String> questions = [
    "What's your vibe?",
    "What's your favorite activity?",
    "What's your favorite cuisine?",
  ]; // Example questions

  VibesScreen({
    required this.vibeEventName,
    required this.vibeEventId,
  });

  @override
  _VibesScreenState createState() => _VibesScreenState();
}

class _VibesScreenState extends State<VibesScreen> {
  late PageController _mainPageController;
  late PageController _likesPageController;
  late PageController _questionsPageController;
  int currentIndex = 0;

  Map<int, String?> selectedAnswers = {}; // Stores selected answers
  List<Map<String, dynamic>> questions = []; // List of questions and options

  @override
  void initState() {
    super.initState();
    _mainPageController = PageController();
    _likesPageController = PageController();
    _questionsPageController = PageController();
    _startAutoScroll();
    _fetchQuestions(); // Fetch questions on initialization
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    _likesPageController.dispose();
    _questionsPageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % widget.randomLikes.length;
          if (_likesPageController.hasClients) {
            _likesPageController.animateToPage(
              currentIndex,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
        _startAutoScroll(); // Continue auto-scrolling
      }
    });
  }

  void _goToQuestionsPage() {
    _mainPageController.animateToPage(
      1, // Navigate to the second page (questions page)
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchQuestions() async {
    try {
      final vibesViewModel =
          Provider.of<VibesViewModel>(context, listen: false);
      final fetchedQuestions = await vibesViewModel
          .fetchVibesQuestionsWithOptions(widget.vibeEventId.toString());

      setState(() {
        questions = fetchedQuestions; // Update the questions list
      });
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void _exitVibes() async {
    final vibesViewModel = Provider.of<VibesViewModel>(context, listen: false);
    await vibesViewModel.updateUserVibesStatus(
        eventId: widget.vibeEventId, status: "skipped");
    Navigator.pop(context);
  }

  void _submitAnswers() async {
    final vibesViewModel = Provider.of<VibesViewModel>(context, listen: false);

    if (selectedAnswers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please answer all the questions')),
      );
      return;
    }

    final answers = selectedAnswers.entries
        .map((entry) => {
              'question_id': questions[entry.key]['id'], // Question ID
              'response': entry.value,
              'event_id': widget.vibeEventId
            })
        .toList();

    try {
      await vibesViewModel.submitVibesAnswers(answers: answers);
      await vibesViewModel.updateUserVibesStatus(
          eventId: widget.vibeEventId, status: "answered");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Answers submitted successfully!')),
      );
      Navigator.pop(context);
      // Optionally, navigate back or reset state
    } catch (e) {
      print('Error submitting answers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _mainPageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          buildInitialPage(),
          buildQuestionsPage(),
        ],
      ),
    );
  }

  Widget buildInitialPage() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8E2DE2),
            Color(0xFFFD5E53),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 80),
          Column(
            children: [
              Text(
                'VIBES',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.8),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 60,
                child: PageView.builder(
                  controller: _likesPageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.randomLikes.length,
                  itemBuilder: (context, index) {
                    return Opacity(
                      opacity: 1.0,
                      child: Container(
                        width: 280,
                        child: Text(
                          textAlign: TextAlign.center,
                          widget.randomLikes[index],
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              Text(
                widget.vibeEventName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _goToQuestionsPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'START',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: _exitVibes,
                child: Text(
                  'NOT FEELING IT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget buildQuestionsPage() {
    return questions.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFFFD5E53),
                ],
              ),
            ),
            child: PageView.builder(
              controller: _questionsPageController,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final optionsMap = question['options'] as Map<String, dynamic>;
                final options = optionsMap['options'] as List<dynamic>;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        question['question_text'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ...options.map((option) {
                        return RadioListTile<String>(
                          title: Text(
                            option,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          value: option,
                          groupValue: selectedAnswers[index],
                          onChanged: (value) {
                            setState(() {
                              selectedAnswers[index] = value;
                            });
                          },
                          activeColor: Colors.yellow,
                        );
                      }).toList(),
                      SizedBox(height: 40),
                      if (index == questions.length - 1) ...[
                        ElevatedButton(
                          onPressed: _submitAnswers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 50),
                          ),
                          child: Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
  }
}
