import 'dart:async';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_glow/flutter_glow.dart';

import '../widgets/app_bar/desktop_app_bar.dart';
import '../widgets/background/aura_background.dart';
import '../widgets/controls/control_row.dart';
import '../widgets/overlay/countdown_overlay.dart';

enum _Page { generator, finder, tools }

enum _Tool { scrambler, missing, typing, letters, stats }

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});
  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final Random _random = Random();
  final Set<String> _vocabulary = {
    ...nouns.map((e) => e.toLowerCase()),
    ...adjectives.map((e) => e.toLowerCase()),
  };
  final List<String> _history = [];
  final List<String> _favourites = [];
  final _starts = TextEditingController();
  final _ends = TextEditingController();
  final _contains = TextEditingController();
  final _excludes = TextEditingController();
  final _exact = TextEditingController();
  final _minimum = TextEditingController();
  final _maximum = TextEditingController();
  final _answer = TextEditingController();

  _Page _page = _Page.generator;
  _Tool _tool = _Tool.scrambler;
  String _word = '';
  String _category = '';
  String _toolWord = '';
  String _scrambled = '';
  String _feedback = '';
  Set<int> _missingIndexes = {};
  bool _reveal = false;
  Timer? _timer;
  bool _auto = false;
  bool _countdown = false;
  int _interval = 3;
  int _remaining = 3;
  int _generated = 0;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _starts,
      _ends,
      _contains,
      _excludes,
      _exact,
      _minimum,
      _maximum,
      _answer,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void _generate() {
    final roll = _random.nextInt(3);
    late String next;
    late String category;
    if (roll == 0) {
      next = WordPair.random().asPascalCase;
      category = 'WORD PAIR · ADJECTIVE + NOUN';
    } else if (roll == 1) {
      next = _cap(nouns[_random.nextInt(nouns.length)]);
      category = 'NOUN';
    } else {
      next = _cap(adjectives[_random.nextInt(adjectives.length)]);
      category = 'ADJECTIVE';
    }
    setState(() {
      _word = next;
      _category = 'CATEGORY: $category';
      _generated++;
      _history.remove(next);
      _history.insert(0, next);
      if (_history.length > 100) _history.removeLast();
    });
    if (_page == _Page.tools) _prepareTool();
  }

  void _prepareTool() {
    _toolWord = _word;
    _answer.clear();
    _feedback = '';
    _reveal = false;
    _scrambled = _shuffleWord(_toolWord);
    final indexes = List<int>.generate(_toolWord.length, (i) => i)
      ..shuffle(_random);
    final count = _toolWord.length > 2 ? max(1, _toolWord.length ~/ 3) : 1;
    _missingIndexes = indexes.take(count).toSet();
  }

  String _shuffleWord(String word) {
    final chars = word.split('');
    if (chars.length < 2) return word;
    var result = List<String>.from(chars);
    for (var i = 0; i < 8 && result.join() == word; i++) {
      result.shuffle(_random);
    }
    return result.join();
  }

  void _selectPage(_Page page) {
    if (_auto) _stopAuto();
    setState(() {
      _page = page;
      if (page == _Page.tools) _prepareTool();
    });
  }

  void _toggleAuto() {
    if (_auto) {
      _stopAuto();
    } else {
      setState(() => _countdown = true);
    }
  }

  void _startAuto() {
    setState(() {
      _auto = true;
      _countdown = false;
      _remaining = _interval;
    });
    _generate();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _generate();
          _remaining = _interval;
        }
      });
    });
  }

  void _stopAuto() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _auto = false;
      _countdown = false;
    });
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$value"'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1300),
      ),
    );
  }

  void _toggleFavourite(String word) {
    setState(
      () => _favourites.contains(word)
          ? _favourites.remove(word)
          : _favourites.insert(0, word),
    );
  }

  List<String> get _matches {
    final starts = _starts.text.trim().toLowerCase();
    final ends = _ends.text.trim().toLowerCase();
    final contains = _contains.text.trim().toLowerCase();
    final excludes = _excludes.text.trim().toLowerCase();
    final exact = int.tryParse(_exact.text.trim());
    final min = int.tryParse(_minimum.text.trim());
    final maxLength = int.tryParse(_maximum.text.trim());
    final result = _vocabulary.where((w) {
      if (starts.isNotEmpty && !w.startsWith(starts)) return false;
      if (ends.isNotEmpty && !w.endsWith(ends)) return false;
      if (contains.isNotEmpty && !w.contains(contains)) return false;
      if (excludes.isNotEmpty && w.contains(excludes)) return false;
      if (exact != null && w.length != exact) return false;
      if (min != null && w.length < min) return false;
      if (maxLength != null && w.length > maxLength) return false;
      return true;
    }).toList()..sort();
    return result;
  }

  void _clearFilters() {
    for (final c in [
      _starts,
      _ends,
      _contains,
      _excludes,
      _exact,
      _minimum,
      _maximum,
    ]) {
      c.clear();
    }
    setState(() {});
  }

  void _check() {
    final expected = _tool == _Tool.missing ? _toolWord : _toolWord;
    setState(
      () => _feedback =
          _answer.text.trim().toLowerCase() == expected.toLowerCase()
          ? 'Correct! Nicely done.'
          : 'Not quite — try again.',
    );
  }

  Widget _panel(
    Widget child, {
    EdgeInsets padding = const EdgeInsets.all(22),
  }) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xE6101019),
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: Colors.white.withOpacity(.09)),
      boxShadow: [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(.13),
          blurRadius: 26,
          offset: const Offset(0, 9),
        ),
      ],
    ),
    child: child,
  );

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
    ],
  );

  Widget _nav(String title, IconData icon, _Page page, Color accent) {
    final selected = _page == page;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectPage(page),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(.18)
                : Colors.white.withOpacity(.035),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accent.withOpacity(.55)
                  : Colors.white.withOpacity(.07),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? accent : Colors.white60, size: 17),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const DesktopAppBar(),
    body: Stack(
      children: [
        AuraBackground(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFFA78BFA),
                          size: 23,
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          'WORD LAB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_generated generated',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        _nav(
                          'Generator',
                          Icons.auto_awesome,
                          _Page.generator,
                          const Color(0xFFA78BFA),
                        ),
                        const SizedBox(width: 9),
                        _nav(
                          'Word Finder',
                          Icons.manage_search,
                          _Page.finder,
                          const Color(0xFF67D9D0),
                        ),
                        const SizedBox(width: 9),
                        _nav(
                          'Word Tools',
                          Icons.extension_rounded,
                          _Page.tools,
                          const Color(0xFFFFB86B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 230),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, .025),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: SingleChildScrollView(
                          key: ValueKey(_page),
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _page == _Page.generator
                              ? _generatorView()
                              : _page == _Page.finder
                              ? _finderView()
                              : _toolsView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_countdown) CountdownOverlay(count: 3, onFinished: _startAuto),
      ],
    ),
  );

  Widget _generatorView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading(
        'A little inspiration.',
        'Generate a word, a pair, or let the ideas keep flowing.',
      ),
      const SizedBox(height: 20),
      _panel(
        Column(
          children: [
            if (_auto) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GlowText(
                    'NEXT WORD IN  ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    glowColor: Colors.white24,
                  ),
                  GlowText(
                    '$_remaining',
                    style: const TextStyle(
                      color: Color(0xFFFF7B9C),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    glowColor: const Color(0xFFFF7B9C),
                  ),
                  const GlowText(
                    '  SECONDS',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    glowColor: Colors.white24,
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, a) => ScaleTransition(
                scale: a,
                child: FadeTransition(opacity: a, child: child),
              ),
              child: Text(
                _word,
                key: ValueKey(_word),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 9,
              children: [
                _action(Icons.copy_rounded, 'Copy', () => _copy(_word)),
                _action(
                  _favourites.contains(_word)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  _favourites.contains(_word) ? 'Saved' : 'Favourite',
                  () => _toggleFavourite(_word),
                  color: const Color(0xFFFF8BA7),
                ),
              ],
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      ),
      const SizedBox(height: 16),
      ControlRow(
        onGenerate: _generate,
        isAutoGenerating: _auto,
        onToggleAutoGenerate: _toggleAuto,
        timerDuration: _interval,
        onTimerChanged: (v) {
          setState(() {
            _interval = v;
            if (_auto) _remaining = v;
          });
          if (_auto) _startAuto();
        },
      ),
      const SizedBox(height: 19),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _wordList(
              'Recent words',
              _history,
              Icons.history,
              const Color(0xFFA78BFA),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _wordList(
              'Favourites',
              _favourites,
              Icons.favorite_border,
              const Color(0xFFFF8BA7),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _action(
    IconData icon,
    String label,
    VoidCallback tap, {
    Color color = const Color(0xFFA78BFA),
  }) => OutlinedButton.icon(
    onPressed: tap,
    icon: Icon(icon, size: 15),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withOpacity(.35)),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  Widget _wordList(
    String title,
    List<String> words,
    IconData icon,
    Color color,
  ) => _panel(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${words.length}',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
            if (words.isNotEmpty)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear $title',
                onPressed: () => setState(words.clear),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.white38,
                ),
              ),
          ],
        ),
        if (words.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Nothing here yet.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          )
        else
          ...words
              .take(5)
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          w,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _copy(w),
                        child: const Icon(
                          Icons.copy,
                          size: 13,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    ),
    padding: const EdgeInsets.all(14),
  );

  Widget _finderView() {
    final results = _matches;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Find your word.',
          'Combine letter and length conditions to explore the built-in word list.',
        ),
        const SizedBox(height: 17),
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LETTER CONDITIONS',
                style: TextStyle(
                  color: Color(0xFF67D9D0),
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, c) {
                  final width = c.maxWidth > 600
                      ? (c.maxWidth - 14) / 2
                      : c.maxWidth;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: width,
                        child: _filter('Starts with', _starts, 'e.g. m'),
                      ),
                      SizedBox(
                        width: width,
                        child: _filter('Ends with', _ends, 'e.g. t'),
                      ),
                      SizedBox(
                        width: width,
                        child: _filter('Contains', _contains, 'e.g. oo'),
                      ),
                      SizedBox(
                        width: width,
                        child: _filter('Does not contain', _excludes, 'e.g. x'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'WORD LENGTH',
                style: TextStyle(
                  color: Color(0xFF67D9D0),
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, c) {
                  final width = c.maxWidth > 600
                      ? (c.maxWidth - 28) / 3
                      : (c.maxWidth - 14) / 2;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: width,
                        child: _filter(
                          'Exact length',
                          _exact,
                          'e.g. 5',
                          digits: true,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _filter(
                          'Minimum',
                          _minimum,
                          'e.g. 3',
                          digits: true,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _filter(
                          'Maximum',
                          _maximum,
                          'e.g. 8',
                          digits: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Text(
                    '${results.length} matching words',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF67D9D0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        _panel(
          results.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No matches. Try loosening a condition.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MATCHES · TAP A WORD TO COPY',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: results
                          .take(100)
                          .map(
                            (w) => InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () => _copy(_cap(w)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF173337),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF67D9D0,
                                    ).withOpacity(.2),
                                  ),
                                ),
                                child: Text(
                                  w,
                                  style: const TextStyle(
                                    color: Color(0xFFD5FFFA),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (results.length > 100)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Showing the first 100 results. Add conditions to narrow your search.',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                  ],
                ),
          padding: const EdgeInsets.all(16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Results come from the words bundled with this app; this is not a complete dictionary.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _filter(
    String label,
    TextEditingController controller,
    String hint, {
    bool digits = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: digits ? TextInputType.number : TextInputType.text,
        inputFormatters: digits
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(.045),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF67D9D0)),
          ),
        ),
      ),
    ],
  );

  Widget _toolsView() {
    final titles = [
      'Word Scrambler',
      'Missing Letters',
      'Typing Challenge',
      'Letter Challenge',
      'Word Stats',
    ];
    final descriptions = [
      'Rearrange the letters and solve the puzzle.',
      'Fill in the hidden letters.',
      'Type the word exactly as it appears.',
      'Explore letter counts and positions.',
      'See simple facts about a word.',
    ];
    final icons = [
      Icons.shuffle,
      Icons.space_bar,
      Icons.keyboard,
      Icons.text_fields,
      Icons.query_stats,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Play with words.',
          'Pick a mini challenge. Each one uses words already in the app.',
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: List.generate(
            5,
            (i) => SizedBox(
              width: 176,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() {
                  _tool = _Tool.values[i];
                  _prepareTool();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: _tool.index == i
                        ? const Color(0xFF3A2B1C)
                        : const Color(0xD9101019),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _tool.index == i
                          ? const Color(0xFFFFB86B).withOpacity(.7)
                          : Colors.white12,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icons[i], color: const Color(0xFFFFB86B), size: 21),
                      const SizedBox(height: 9),
                      Text(
                        titles[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descriptions[i],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        _panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titles[_tool.index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(_prepareTool),
                    icon: const Icon(Icons.autorenew, size: 16),
                    label: const Text('New word'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB86B),
                    ),
                  ),
                ],
              ),
              Text(
                descriptions[_tool.index],
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 18),
              _selectedToolView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wordDisplay(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.045),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white10),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 29,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
      ),
    ),
  );

  Widget _selectedToolView() {
    if (_tool == _Tool.scrambler) {
      return Column(
        children: [
          _wordDisplay(_scrambled),
          const SizedBox(height: 14),
          _answerInput('Unscramble the word', 'Your answer'),
          _checkButton(),
        ],
      );
    }
    if (_tool == _Tool.missing) {
      final shown = _toolWord
          .split('')
          .asMap()
          .entries
          .map(
            (e) => _missingIndexes.contains(e.key) && !_reveal ? '＿' : e.value,
          )
          .join(' ');
      return Column(
        children: [
          _wordDisplay(shown),
          const SizedBox(height: 8),
          Text(
            '${_missingIndexes.length} letters missing',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 14),
          _answerInput('Complete word', 'Type the full word'),
          _checkButton(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _reveal = !_reveal),
              child: Text(
                _reveal ? 'Hide answer' : 'Reveal answer',
                style: const TextStyle(color: Color(0xFFFFB86B)),
              ),
            ),
          ),
        ],
      );
    }
    if (_tool == _Tool.typing)
      return Column(
        children: [
          _wordDisplay(_toolWord),
          const SizedBox(height: 14),
          _answerInput('Type the word', 'Start typing here'),
          _checkButton(),
        ],
      );
    if (_tool == _Tool.letters) {
      final lower = _toolWord.toLowerCase();
      final vowels = lower.split('').where((c) => 'aeiou'.contains(c)).length;
      final consonants = lower
          .split('')
          .where((c) => RegExp(r'[a-z]').hasMatch(c) && !'aeiou'.contains(c))
          .length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _wordDisplay(_toolWord),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Letters', '${_toolWord.length}'),
              _pill('Vowels', '$vowels'),
              _pill('Consonants', '$consonants'),
              _pill('Unique', '${lower.split('').toSet().length}'),
              _pill('First', _toolWord[0]),
              _pill('Last', _toolWord[_toolWord.length - 1]),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Try a letter-count challenge: how many times does a chosen letter appear? What is the third letter? Does the word contain “a”?',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _letterChallengeInput(),
        ],
      );
    }
    final lower = _toolWord.toLowerCase();
    final vowels = lower.split('').where((c) => 'aeiou'.contains(c)).length;
    final sorted = lower.split('')..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _wordDisplay(_toolWord),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _pill('Length', '${_toolWord.length}'),
            _pill('Vowels', '$vowels'),
            _pill('Consonants', '${_toolWord.length - vowels}'),
            _pill('Unique letters', '${lower.split('').toSet().length}'),
          ],
        ),
        const SizedBox(height: 14),
        _detail('Alphabetical letters', sorted.join()),
        _detail('Reversed', _toolWord.split('').reversed.join()),
        _detail('Uppercase', _toolWord.toUpperCase()),
        _detail('Lowercase', lower),
      ],
    );
  }

  Widget _letterChallengeInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Check a letter',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _answer,
        maxLength: 1,
        onChanged: (value) => setState(() {
          if (value.isEmpty) {
            _feedback = '';
          } else {
            final letter = value.toLowerCase();
            final lower = _toolWord.toLowerCase();
            final count = lower.split('').where((c) => c == letter).length;
            final positions = <int>[];
            for (var i = 0; i < lower.length; i++) {
              if (lower[i] == letter) positions.add(i + 1);
            }
            _feedback = count == 0
                ? '“$letter” does not appear in this word.'
                : '“$letter” appears $count time${count == 1 ? '' : 's'} · position${positions.length == 1 ? '' : 's'} ${positions.join(', ')}.';
          }
        }),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Enter one letter',
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(.045),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFB86B)),
          ),
        ),
      ),
      if (_feedback.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _feedback,
            style: const TextStyle(
              color: Color(0xFFFFC98F),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );

  Widget _answerInput(String label, String hint) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _answer,
        onChanged: (_) => setState(() => _feedback = ''),
        onSubmitted: (_) => _check(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withOpacity(.045),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFB86B)),
          ),
        ),
      ),
    ],
  );

  Widget _checkButton() => Column(
    children: [
      const SizedBox(height: 11),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _check,
          icon: const Icon(Icons.check, size: 17),
          label: const Text('Check answer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB86B),
            foregroundColor: const Color(0xFF24180D),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      if (_feedback.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            _feedback,
            style: TextStyle(
              color: _feedback.startsWith('Correct')
                  ? const Color(0xFF79E2B2)
                  : const Color(0xFFFFA6A6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );

  Widget _pill(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFF382B20),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFB86B).withOpacity(.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFFFC98F),
            fontSize: 9,
            letterSpacing: .8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _copy(value),
          child: const Icon(Icons.copy, color: Colors.white38, size: 14),
        ),
      ],
    ),
  );
}
