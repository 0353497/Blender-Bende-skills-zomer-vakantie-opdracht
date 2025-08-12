import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int activeStep = 1;
  Map<int, List<String>> selections = {
    1: [], 
    2: [],
    3: [],
  };

  Map<String, Color> ingredientColors = {
    "Melk": Color(0xFFF8F8FF),
    "Water": Color(0xFFE6F3FF),
    "Yoghurt": Color(0xFFFFF8DC),
    "Havermelk": Color(0xFFF5DEB3),
    
    "Aardbei": Color(0xFFFF6B6B),
    "Banaan": Color(0xFFFFE66D),
    "Mango": Color(0xFFFF8E53),
    "Blauwe bes": Color(0xFF4ECDC4),
    "Avocado": Color(0xFF95E1D3),
    
    "Proteïne": Color(0xFFDDA0DD),
    "Vitamine boost": Color(0xFFFFB347),
    "Chiazaad": Color(0xFF8B4513),
    "Lijnzaad": Color(0xFFA0522D),
  };

  void setActiveStep(int step) {
    setState(() {
      activeStep = step;
    });
  }

  void goToNextStep() {
    setState(() {
      if (activeStep < 3) {
        activeStep++;
      }
    });
  }

  void updateSelection(int step, String option, bool isSelected) {
    setState(() {
      if (step == 1) {
        selections[step] = isSelected ? [option] : [];
        if (isSelected) {
          activeStep = 2;
        }
      } else {
        if (isSelected) {
          if (!selections[step]!.contains(option)) {
            selections[step]!.add(option);
          }
        } else {
          selections[step]!.remove(option);
        }
      }
    });
  }

  List<Color> _generateSmoothieColors() {
    List<Color> colors = [];
    
    if (selections[1]!.isNotEmpty) {
      colors.add(ingredientColors[selections[1]!.first] ?? Colors.white);
    }
    
    for (String fruit in selections[2]!) {
      colors.add(ingredientColors[fruit] ?? Colors.pink);
    }
    
    for (String extra in selections[3]!) {
      colors.add(ingredientColors[extra] ?? Colors.brown);
    }
    
    if (colors.isEmpty) {
      colors = [Colors.white];
    }
    
    return colors;
  }

  List<double> _generateColorStops(List<Color> colors) {
    List<double> stops = [];
    
    double currentStop = 0.0;
    
    if (selections[1]!.isNotEmpty) {
      stops.addAll([0.0, 0.33]);
      currentStop = 0.33;
    }
    
    if (selections[2]!.isNotEmpty) {
      if (currentStop == 0.0) {
        stops.addAll([0.0, 0.17]);
        currentStop = 0.17;
      } else {
        stops.addAll([0.33, 0.5]);
        currentStop = 0.5;
      }
    }
    
    if (selections[3]!.isNotEmpty) {
      if (currentStop == 0.0) {
        stops.addAll([0.0, 0.1]);
        currentStop = 0.1;
      } else if (currentStop == 0.33) {
        stops.addAll([0.33, 0.43]);
        currentStop = 0.43;
      } else {
        stops.addAll([0.5, 0.6]);
        currentStop = 0.6;
      }
    }
    
    if (currentStop > 0.0 && currentStop < 1.0) {
      stops.addAll([currentStop, 1.0]);
    } else if (stops.isEmpty) {
      stops = [0.0, 1.0];
    }
    
    return stops;
  }

  List<Color> _generateGradientColors(List<Color> baseColors) {
    List<Color> gradientColors = [];
    
    if (selections[1]!.isNotEmpty) {
      Color basisColor = ingredientColors[selections[1]!.first] ?? Colors.white;
      gradientColors.addAll([basisColor, basisColor]);
    }
    
    if (selections[2]!.isNotEmpty) {
      Color fruitColor;
      if (selections[2]!.length == 1) {
        fruitColor = ingredientColors[selections[2]!.first] ?? Colors.pink;
      } else {
        List<Color> fruitColors = selections[2]!.map((fruit) => 
          ingredientColors[fruit] ?? Colors.pink).toList();
        fruitColor = _blendColors(fruitColors);
      }
      gradientColors.addAll([fruitColor, fruitColor]);
    }
    
    if (selections[3]!.isNotEmpty) {
      Color extraColor;
      if (selections[3]!.length == 1) {
        extraColor = ingredientColors[selections[3]!.first] ?? Colors.brown;
      } else {
        List<Color> extraColors = selections[3]!.map((extra) => 
          ingredientColors[extra] ?? Colors.brown).toList();
        extraColor = _blendColors(extraColors);
      }
      gradientColors.addAll([extraColor, extraColor]);
    }
    
    if (gradientColors.isNotEmpty) {
      gradientColors.addAll([Colors.white, Colors.white]);
    } else {
      gradientColors = [Colors.white, Colors.white];
    }
    
    return gradientColors;
  }

  Color _blendColors(List<Color> colors) {
    if (colors.isEmpty) return Colors.white;
    if (colors.length == 1) return colors.first;
    
    int r = 0, g = 0, b = 0;
    for (Color color in colors) {
      r += (color.r * 255.0).round();
      g += (color.g * 255.0).round();
      b += (color.b * 255.0).round();
    }
    
    return Color.fromARGB(
      255,
      (r / colors.length).round(),
      (g / colors.length).round(),
      (b / colors.length).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Color> smoothieColors = _generateSmoothieColors();
    List<double> colorStops = _generateColorStops(smoothieColors);
    List<Color> gradientColors = _generateGradientColors(smoothieColors);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffFFC7A2),
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          spacing: 10,
                          children: [
                            OptionContainer(
                              isExpanded: activeStep == 1,
                              title: 'Basis',
                              step: 1,
                              options: ["Melk", "Water", "Yoghurt", "Havermelk"],
                              selections: selections[1]!,
                              onTap: () => setActiveStep(1),
                              onSelectionChanged: (option, isSelected) => updateSelection(1, option, isSelected),
                            ),
                            
                            OptionContainer(
                              isExpanded: activeStep == 2,
                              title: 'Fruit',
                              step: 2,
                              options: ["Aardbei", "Banaan", "Mango", "Blauwe bes", "Avocado"],
                              selections: selections[2]!,
                              onTap: () => setActiveStep(2),
                              onSelectionChanged: (option, isSelected) => updateSelection(2, option, isSelected),
                              onNextStep: goToNextStep,
                            ),
                            
                            OptionContainer(
                              isExpanded: activeStep == 3,
                              title: 'Extra\'s',
                              step: 3,
                              options: ["Proteïne", "Vitamine boost", "Chiazaad", "Lijnzaad"],
                              selections: selections[3]!,
                              onTap: () => setActiveStep(3),
                              onSelectionChanged: (option, isSelected) => updateSelection(3, option, isSelected),
                              onNextStep: goToNextStep,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: Center(
                  child: Stack(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.modulate,
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: colorStops,
                            colors: gradientColors,
                          ).createShader(bounds);
                        },
                        child: Image.asset(
                          "assets/cup.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Stack(
                          children: [
                            Image.asset(
                                "assets/logo.png",
                                width: 250,
                                fit: BoxFit.contain,
                                colorBlendMode: BlendMode.dstIn,
                              ),
                          ],
                        ),
                        ),
                    ],
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

class OptionContainer extends StatefulWidget {
  const OptionContainer({
    super.key,
    required this.isExpanded,
    required this.title,
    required this.step,
    required this.options,
    required this.onTap,
    required this.selections,
    required this.onSelectionChanged,
    this.onNextStep,
  });
  final bool isExpanded;
  final String title;
  final int step;
  final List<String> options;
  final VoidCallback onTap;
  final List<String> selections;
  final Function(String, bool) onSelectionChanged;
  final VoidCallback? onNextStep;

  @override
  State<OptionContainer> createState() => _OptionContainerState();
}

class _OptionContainerState extends State<OptionContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: widget.isExpanded
            ? MediaQuery.of(context).size.width / 3
            : MediaQuery.of(context).size.width / 3.5,
            height: null,
        constraints: BoxConstraints(
          maxHeight: calculateOptionContainerHeight(context),
          minHeight: 60,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isExpanded ? 0.1 : 0.05),
              blurRadius: widget.isExpanded ? 8 : 4,
              offset: Offset(0, widget.isExpanded ? 3 : 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "stap ${widget.step}",
                style: TextStyle(
                  color: Color(0xff6C3D51),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: Color(0xff6C3D51),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (!widget.isExpanded && widget.selections.isNotEmpty)
                    Text(
                      widget.selections.join(", "),
                      style: TextStyle(
                        color: Color(0xffFC8A41),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    )
                ],
              ),
              if (widget.isExpanded) SizedBox(height: 8),
              if (widget.isExpanded && widget.step != 1)
                Text(
                  "Kies minimaal 1 ingredient",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              if (widget.isExpanded) SizedBox(height: 8),
              if (widget.isExpanded)
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...widget.options.map((option) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: OptionChip(
                              text: option,
                              isSelected: widget.selections.contains(option),
                              onSelectionChanged: (isSelected) {
                                widget.onSelectionChanged(option, isSelected);
                              },
                            ),
                          )),
                      SizedBox(height: 10),
                      if (widget.step != 1)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              widget.selections.isEmpty 
                                ? Colors.grey.shade300 
                                : Color(0xffFC8A41)
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              widget.selections.isEmpty 
                                ? Colors.grey.shade600 
                                : Colors.white
                            ),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                          onPressed: widget.selections.isEmpty ? null : () {
                            if (widget.onNextStep != null) {
                              widget.onNextStep!();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.step == 2 ? 'Naar extra\'s' : 'Maak smoothie',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double calculateOptionContainerHeight(BuildContext context) {
    if (!widget.isExpanded) {
      return 80;
    }
    if (widget.step == 1) return MediaQuery.of(context).size.height * 0.5;
    if (widget.step == 2) return MediaQuery.of(context).size.height * 0.66;
    return MediaQuery.of(context).size.height * 0.57;
  }
}

class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.onSelectionChanged,
  });
  final String text;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      side: BorderSide(color: Color(0xffFC8A41), width: 2),
      backgroundColor: isSelected ? Color(0xFFFFF8DC) : Colors.white,
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.28,
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xffFC8A41),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onSelected: (value) {
        onSelectionChanged(!isSelected);
      },
    );
  }
}
