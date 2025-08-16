import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:google_fonts/google_fonts.dart';

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
  bool isAanHetBestellen = false;
  int bestelNummer = 0;
  bool laatBestelNummerzien = false;
  final TextEditingController _nameController = TextEditingController();
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
    if (activeStep == 3) {
    
    }
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
    
    if (laatBestelNummerzien) {
      List<double> fluidStops = stops.take(stops.length - 2).toList();
      if (fluidStops.isEmpty) {
        return [0.0, 1.0];
      }
      return [...fluidStops, fluidStops.last, 1.0];
    }
    
    return stops;
  }

  List<Color> _generateGradientColors(List<Color> baseColors) {
    if (laatBestelNummerzien) {
      List<String> allSelectedIngredients = [
        ...selections[1]!,
        ...selections[2]!,
        ...selections[3]!,
      ];
      
      if (allSelectedIngredients.isNotEmpty) {
        List<Color> selectedColors = allSelectedIngredients
            .map((ingredient) => ingredientColors[ingredient] ?? Colors.white)
            .toList();
        Color blendedColor = _blendColors(selectedColors);
        
        List<Color> finalColors = [];
        List<double> stops = _generateColorStops(baseColors);
        
        for (int i = 0; i < stops.length - 2; i++) {
          finalColors.add(blendedColor);
        }
        finalColors.addAll([Colors.white, Colors.white]);
        
        return finalColors;
      }
    }
    
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
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme()
      ),
      home: Scaffold(
        backgroundColor: Color(0xffFFC7A2),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xffFFEEE4),
              Color(0xffFFC7A2),
            ])
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      children: [
                        if (laatBestelNummerzien)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(),
                              Container(
                                width: 372,
                                height: 312,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xffFFC7A2),
                                      blurRadius: 5,
                                      spreadRadius: 2
                                    )
                                  ]
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Bestelnummer",
                                      style: TextStyle(
                                        fontSize: 32,
                                        color: Color(0xff6C3D51),
                                        fontWeight: FontWeight.bold
                                      ),
                                      ),
                                      Text('"${_nameController.text}"',
                                      style: TextStyle(
                                        color: Color(0xffFC8A41),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600
                                      ),
                                      ),
                                      Text(bestelNummer.toString(),
                                        style: TextStyle(
                                          fontSize: 128,
                                          color: Color(0xff6C3D51),
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 16,
                                  children: [
                                    Text("Bestel een nieuwe smoothie",
                                    style: TextStyle(
                                      color: Color(0xffFC8A41),
                                      fontWeight: FontWeight.w600
                                    ),
                                    ),
                                    IconButton(
                                    onPressed: (){
                                      setState(() {
                                        _reset();
                                      });
                                    },
                                    style: ButtonStyle(
                                      foregroundColor: WidgetStatePropertyAll(Color(0xffFC8A41)),
                                      backgroundColor: WidgetStatePropertyAll(Colors.white)
                                    ),
                                    icon: Icon(Icons.arrow_forward),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                          ),
                        if (!laatBestelNummerzien)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              if (!isAanHetBestellen)
                              OptionContainer(
                                isExpanded: activeStep == 1,
                                title: 'Basis',
                                step: 1,
                                options: ["Melk", "Water", "Yoghurt", "Havermelk"],
                                selections: selections[1]!,
                                allSelections: selections,
                                onTap: () => setActiveStep(1),
                                onSelectionChanged: (option, isSelected) => updateSelection(1, option, isSelected),
                              ),
                              if (!isAanHetBestellen)
                              OptionContainer(
                                isExpanded: activeStep == 2,
                                title: 'Fruit',
                                step: 2,
                                options: ["Aardbei", "Banaan", "Mango", "Blauwe bes", "Avocado"],
                                selections: selections[2]!,
                                allSelections: selections,
                                onTap: () => setActiveStep(2),
                                onSelectionChanged: (option, isSelected) => updateSelection(2, option, isSelected),
                                onNextStep: goToNextStep,
                              ),
                              if (!isAanHetBestellen)
                              OptionContainer(
                                isExpanded: activeStep == 3,
                                title: 'Extra\'s',
                                step: 3,
                                options: ["Proteïne", "Vitamine boost", "Chiazaad", "Lijnzaad"],
                                selections: selections[3]!,
                                allSelections: selections,
                                onTap: () => setActiveStep(3),
                                onSelectionChanged: (option, isSelected) => updateSelection(3, option, isSelected),
                                onNextStep: () => selections[1]!.isNotEmpty && selections[2]!.isNotEmpty ?  setState(() { isAanHetBestellen = true;}) : null,
                              ),
                              if (isAanHetBestellen)
                              SizedBox(
                                width: 400,
                                child: Column(
                                  children: [
                                    Row(
                                      spacing: 20,
                                      children: [
                                        IconButton(
                                          style: ButtonStyle(
                                            foregroundColor: WidgetStatePropertyAll(Color(0xffFC8A41)),
                                            backgroundColor: WidgetStatePropertyAll(Colors.white)
                                          ),
                                          onPressed: () {
                                          setState(() {
                                            isAanHetBestellen = false;
                                          });
                                        }, icon: Icon(Icons.arrow_back)),
                                        Text("Pas je bestelling aan",
                                        style: TextStyle(color: Color(0xffFC8A41), fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 100,
                                    )
                                  ],
                                ),
                              ),
                              if (isAanHetBestellen)
                             Container(
                              height: 300,
                              width: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  spacing: 20,
                                  children: [
                                    Text("Geef je smoothie een naam",
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.kanit().fontFamily,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xff6C3D51),
                                      fontSize: 40
                                    ),
                                    ),
                                    TextField(
                                      controller: _nameController,
                                      onChanged: (value) {
                                        setState(() {
                                          
                                        });
                                      },
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffAA5498),
                                            width: 2
                                          ),
                                          borderRadius: BorderRadius.circular(24)
                                        ),
                                        border:OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xffAA5498),
                                            width: 4
                                          ),
                                          borderRadius: BorderRadius.circular(24)
                                        ),
                                        hintStyle: TextStyle(color: Color(0xffAA5498).withAlpha(100), fontWeight: FontWeight.bold, fontFamily: GoogleFonts.kanit().fontFamily),
                                        hintText: "Voer een naam in..."
                                      ),
                                    ),
                                    SizedBox(
                                      width: 380,
                                      height: 50,
                                      child: TextButton(
                                        style: ButtonStyle(
                                          backgroundColor: 
                                          _nameController.value.text.isEmpty ?
                                          WidgetStatePropertyAll(Color(0xffAA5498).withAlpha(100))
                                          :
                                          WidgetStatePropertyAll(Color(0xffAA5498))
                                        ),
                                        onPressed: 
                                        _nameController.value.text.isEmpty ?
                                         null :
                                        (){
                                          setState(() {
                                            laatBestelNummerzien = true;
                                            bestelNummer++;
                                          });
                                        },
                                      child: Text("Bestellen", 
                                      style: TextStyle(
                                        fontFamily: GoogleFonts.kanit().fontFamily,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600
                                      ),
                                      ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                             )
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [
                              Color(0xffFFC7A2),
                              Color(0xffFFEEE4),
                            ])
                          ),
                          child: Cup(colorStops: colorStops, gradientColors: gradientColors),
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
      ),
    );
  }
  
  void _reset() {
    activeStep = 1;
    isAanHetBestellen = false;
    laatBestelNummerzien = false;
    _nameController.clear();
    selections = {
      1: [], 
      2: [],
      3: [],
    };
  }
}

class Cup extends StatefulWidget {
  const Cup({
    super.key,
    required this.colorStops,
    required this.gradientColors,
  });

  final List<double> colorStops;
  final List<Color> gradientColors;

  @override
  State<Cup> createState() => _CupState();
}

class _CupState extends State<Cup> with TickerProviderStateMixin {
  ui.Image? cupImage;

  @override
  void initState() {
    super.initState();
    _loadCupImage();
  }

  Future<void> _loadCupImage() async {
    final AssetImage assetImage = AssetImage('assets/cup.png');
    final ImageStream stream = assetImage.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    
    cupImage = await completer.future;
    if (mounted) {
      setState(() {});
    }
  }

  Color _getWaveColor() {
    return widget.gradientColors.lastWhere((color) => color != Colors.white, orElse: () => Colors.white,);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.gradientColors.toString()),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Stack(
          children: [
           CustomPaint(
              foregroundPainter: WaveFunction(_getWaveColor(), _calculateWavePosition(value),shift: value, cupImage: cupImage),
              child: Image.asset("assets/cup.png", fit: BoxFit.contain,),
            ),
            ShaderMask(
              blendMode: BlendMode.modulate,
              shaderCallback: (bounds) {
                return LinearGradient(
                  transform: GradientRotation(
                    calcutlateRotation(value)
                  ),
                  begin: Alignment.bottomCenter,
                  end: Alignment(0.0, -value),
                  stops: widget.colorStops,
                  colors: widget.gradientColors,
                ).createShader(bounds);
              },
              child: Image.asset(
                "assets/cup.png",
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      }
    );
  }

  double calcutlateRotation(double value) {
    return 0.1 * math.sin(value * math.pi * 2);
  }
  
  double _calculateWavePosition(double shift) {
    if (widget.colorStops.length < 2) return 300.0;
    
    double lastIngredientStop = widget.colorStops[widget.colorStops.length - 2];
    
    double canvasHeight = 600.0;
    double wavePosition = canvasHeight * (1.0 - lastIngredientStop);
    
    return wavePosition;
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
    required this.allSelections,
  });
  final bool isExpanded;
  final String title;
  final int step;
  final List<String> options;
  final VoidCallback onTap;
  final List<String> selections;
  final Function(String, bool) onSelectionChanged;
  final VoidCallback? onNextStep;
  final Map<int, List<String>> allSelections;

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
                    SizedBox(
                      width: 250,
                      child: Text(
                        widget.selections.join(", "),
                        style: TextStyle(
                          color: Color(0xffFC8A41),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                ],
              ),
              if (widget.isExpanded) SizedBox(height: 8),
              if (widget.isExpanded && widget.step == 2)
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
                      SizedBox(height: 4),
                      if (widget.step != 1)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              widget.selections.isEmpty && widget.step == 2
                              || (widget.allSelections[1]!.isEmpty || widget.allSelections[2]!.isEmpty) && widget.step == 3
                                ? Color(0xffFC8A41).withAlpha(100)
                                : Color(0xffFC8A41)
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Colors.white
                            ),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                          onPressed: widget.selections.isEmpty && widget.step == 2 || (widget.allSelections[1]!.isEmpty || widget.allSelections[2]!.isEmpty) && widget.step == 3 ? null : () {
                            if (widget.onNextStep != null) {
                              widget.onNextStep!();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 14
                            ),
                            child: Text(
                              widget.step == 2 ? 'Kies je extra\'s' : 'Door naar bestellen',
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
      selected: isSelected,
      showCheckmark: false, 
      side: BorderSide(color: Color(0xffFC8A41), width: 2),
      backgroundColor: isSelected ? Color(0xFFFFF8DC) :  Colors.white,
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Color(0xffFC8A41),
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isSelected
                    ? SizedBox(
                        key: ValueKey('check'),
                        width: 21,
                        height: 14,
                        child: CustomPaint(
                          painter: ThickCheckPainter(),
                        ),
                      )
                    : SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
      onSelected: (value) {
        onSelectionChanged(!isSelected);
      },
    );
  }
}
//deze is super irritant ik kon geen f*cking weight property van de icon widget gebruiken
//dat werkte gewoon niet donders irritant, dat ik nu een painter moet gebruiken

class ThickCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 3, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}


class WaveFunction extends CustomPainter {
  final double shift;
  final ui.Image? cupImage;
  final Color color;
  final double startHeight;

  WaveFunction(this.color, this.startHeight, {super.repaint, required this.shift, this.cupImage});
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    if (cupImage != null) {
      final cupPaint = Paint();
      canvas.drawImageRect(
        cupImage!,
        Rect.fromLTWH(0, 0, cupImage!.width.toDouble(), cupImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        cupPaint,
      );
    }
    
    final wavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.srcIn;
      
    final path = Path();
    
    double amplitude = 10.0; 
    double frequency = 0.05;
    double horizontalShift = shift * 10.0;
    //dit moet 2 zijn omdat hij van omhoog moet gaan en moet eindigen bij 1 want startheight * 1 = startheight
    double waveY = startHeight * (2 - shift); 
    path.moveTo(0, waveY);

    for (double x = 0; x <= size.width; x += 1) {
      double y = waveY + (amplitude - (shift * amplitude)) * math.sin((x * frequency) + horizontalShift);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height + startHeight);
    path.close();
    
    canvas.drawPath(path, wavePaint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


