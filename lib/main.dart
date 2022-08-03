import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:envision/cpu.dart';
import 'package:envision/memory.dart';
import 'package:envision/storage.dart';
import 'package:flutter/src/widgets/list_wheel_scroll_view.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'bottombar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

void main() => runApp(AlgoApp());

// void main() => runApp(MyStatefulWidget());
enum DataChoice { First, Second, Third, Own }

enum Component { CPU, Memory, Storage }

class AlgoApp extends StatefulWidget {
  @override
  _AlgoAppState createState() => _AlgoAppState();
}

class _AlgoAppState extends State<AlgoApp> {
  DataChoice? dataChoice = DataChoice.First;
  Component? component = Component.CPU;
  TextEditingController? _controller;
  late List<bool> selectedAlgo;
  bool hasResult = false;
  bool error = false;
  String choiceText = "";
  int curr_idx = 0;
  Widget? resWidget;
  FocusNode focus = FocusNode(); //Keyboard EVENTS MANAGEMENT

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        component = Component.CPU;
      } else if (index == 2) {
        component = Component.Memory;
      } else if (index == 3) {
        component = Component.Storage;
      }
      resWidget = Padding(
        padding: EdgeInsets.all(50.0),
      );
      setSelectedAlgoList();
    });
  }

  @override
  void initState() {
    setSelectedAlgoList();
    _controller = TextEditingController(text: choiceText);
    resWidget = Padding(padding: EdgeInsets.all(50.0));
    focus.addListener(() {
      if (focus.hasFocus) setState(() => dataChoice = DataChoice.Own);
    });
    super.initState();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Resource Scheduling',
        theme: ThemeData(
          primaryColor: Colors.white,
          primaryColorDark: Colors.white,
          highlightColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withAlpha(0),
          ),
        ),
        home: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xff654ea3 ), Color(0xffeaafc8)])
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.black54.withOpacity(0.7),
              elevation: 2,
              title: Center(
                  child:
                      Text('${component.toString().split(".")[1]} Scheduling',style: TextStyle(fontFamily: 'Nutino',),)),
            ),
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          // border: Border.all(
                          //   color: Colors.black,
                          //   width: 3,
                          // ),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black54.withOpacity(0.5),
                        ),
                        child: Center(
                            child: Text("Choose Algorithm:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold, color: Colors.white,
                                  fontFamily: 'Nutino',))),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) =>
                          buildAlgoToggle(constraints),
                    ),
                    IntrinsicHeight(
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            width: 100.0,
                            height: 20.0,
                          ),
                          Column(children: [
                            Container(
                              width: 250,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black54.withOpacity(0.5),
                              ),
                              child: Center(
                                  child: Text("Create Your Process List:",
                                      style: TextStyle(
                                          fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Nutino',

                                      ))),
                            ),
                            generateDataInputList()
                          ]),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15.0, 0),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    width: 100.0,
                                    height: 20.0,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Container(
                                        width: 250,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          // border: Border.all(
                                          //   color: Colors.black,
                                          //   width: 3,
                                          // ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.black54.withOpacity(0.5),
                                        ),

                                        child: Center(
                                            child: Text("Process Table:",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold,color: Colors.white,
                                                  fontFamily: 'Nutino',))),
                                      )),
                                  const SizedBox(
                                    width: 100.0,
                                    height: 10.0,
                                  ),
                                  Flexible(
                                    child: Builder(
                                      builder: (context) {
                                        List processes;
                                        if (choiceText.isEmpty &&
                                            dataChoice == DataChoice.Own) {
                                          return const TableErrorContainer(
                                            text: "Enter List For Output",
                                          );
                                        }
                                        try {
                                          if (component == Component.Storage) {
                                            processes =
                                                parseStorageOperations();
                                          } else {
                                            processes =
                                                parseComputationProcesses();
                                            processes[processes.length - 1][1];
                                          }
                                        } catch (e) {
                                          return const TableErrorContainer(
                                            text: "Invalid Input",
                                          );
                                        }
                                        switch (component) {
                                          case Component.CPU:
                                            return ProcessTable.fromProcessList(
                                                processes as List<List<num>>,
                                                "Arrival time",
                                                "Length",
                                                (int index) => "P${index + 1}");
                                          case Component.Memory:
                                            return ProcessTable.fromProcessList(
                                                processes as List<List<num>>,
                                                "Memory",
                                                "Length",
                                                (int index) =>
                                                    MemoryProcess.generateName(
                                                        index));
                                          case Component.Storage:
                                            return ProcessTable.fromStorageList(
                                                processes
                                                    as List<StorageOperation>);
                                          default:
                                            return TableErrorContainer(
                                              text: "No Component Selected",
                                            );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                          color: Colors.black54.withOpacity(0.5)
                        ),
                        child: Center(
                            child: Text("Output:",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,color: Colors.white,
                                  fontFamily: 'Nutino',))),
                      ),
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal, child: IntrinsicHeight(child: resWidget!)),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              // ),
              // ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedLabelStyle: TextStyle(fontFamily: 'Nutino'),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/INFO.svg",
                    height: 40.0,
                    width: 50.0,
                    allowDrawingOutsideViewBox: true,
                  ),
                  label: 'INFO',

                  backgroundColor: Colors.black54.withOpacity(0.7),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/CPU.svg",
                    height: 40.0,
                    width: 50.0,
                    allowDrawingOutsideViewBox: true,
                  ),
                  label: 'CPU',

                  backgroundColor: Colors.black54.withOpacity(0.7),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/RAM.svg",
                    height: 40.0,
                    width: 50.0,
                    allowDrawingOutsideViewBox: true,
                  ),
                  label: 'Memory',
                  backgroundColor: Colors.black54.withOpacity(0.7),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/icons/SSD.svg",
                    height: 40.0,
                    width: 50.0,
                    allowDrawingOutsideViewBox: true,
                  ),
                  label: 'Storage',
                  backgroundColor: Colors.black54.withOpacity(0.7),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              onTap: _onItemTapped,
            ),
          ),
        ));
  }

  Widget buildAlgoToggle(BoxConstraints constraints) {
    List algoEnum = getComponentAlgoEnum()!;
    return ToggleSwitch(
      activeBorders: [

        Border.all(
          color: Color(0xff5f65bf),
          width: 3.0,
        ),
        Border.all(
          color: Color(0xff5f65bf),
          width: 3.0,
        ),
        Border.all(
          color: Color(0xff5f65bf),
          width: 3.0,
        ),
        Border.all(
          color: Color(0xff5f65bf),
          width: 3.0,
        ),
      ],
      activeFgColor: Colors.white,
      inactiveFgColor: Colors.white,
      isVertical: true,
      minWidth: 200.0,
      radiusStyle: true,
      cornerRadius: 20.0,
      initialLabelIndex: curr_idx,
      activeBgColors: [
        const [Color(0xffa29fd9)],
        const [Color(0xffa29fd9)],
        const [Color(0xffa29fd9)],
        const [Color(0xffa29fd9)],
        const [Color(0xffa29fd9)],
      ],
      labels: List.generate(
        algoEnum.length,
        (index) => algoEnum[index].toString().split(".")[1],
      ),
      onToggle: (index) {
        if (index != null && selectedAlgo[index]) {
          setState(() {
            // selectedAlgo[index] = false;
            // error = false;
            // resWidget = Padding(padding: EdgeInsets.all(10.0));
            // curr_idx = index;
            // print("IDX= $index");
          });
        }
        else {
          setState(() {
            curr_idx = index!;
          });
          runAlgo(index!);
        }
        print('switched to: $index');
      },
    );
  }

  Widget generateDataInputList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: TextField(
        cursorColor: Colors.orangeAccent,
        focusNode: focus,
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Enter Here",
          errorText: error ? "Enter Vaild Input" : null,
          errorStyle: TextStyle(color: Colors.white,fontFamily: 'Nutino',)
        ),
        onChanged: (s) {
          setState(() {
            choiceText = s;
            for (int i = 0; i < selectedAlgo.length; i++)
              if (selectedAlgo[i]) runAlgo(i);
          });
        },
      ),
    );
  }

  List? getComponentAlgoEnum() {
    List? algoEnum;
    switch (component) {
      case Component.CPU:
        algoEnum = CpuAlgo.values;//["First Come First Serve","Shortest Job First","Round Robin",""];//CpuAlgo.values;
        break;
      case Component.Memory:
        algoEnum = MemoryAlgo.values;
        break;
      case Component.Storage:
        algoEnum = StorageAlgo.values;
        break;
    }
    return algoEnum;
  }

  void setSelectedAlgoList() {
    setState(() {
      selectedAlgo =
          List.generate(getComponentAlgoEnum()!.length, (index) => false);
    });
  }

  String getData(DataChoice? choice) {
    if (choice == DataChoice.Own) {
      return choiceText;
    }
    switch (component) {
      case Component.CPU:
        return getCpuData(choice);
      case Component.Memory:
        return getMemoryData(choice);
      case Component.Storage:
        return getStorageData(choice);
      default:
        return "";
    }
  }

  List<List<num>> parseComputationProcesses() {
    var rawInput = getData(dataChoice).split(";");
    return List.generate(rawInput.length, (i) {
      var str = rawInput[i].split(",");
      return [int.parse(str[0]), int.parse(str[1])];
    });
  }

  List<StorageOperation> parseStorageOperations() {
    var rawInput = getData(dataChoice).split(';');
    return List.generate(
        rawInput.length, (index) => StorageOperation(rawInput[index]));
  }

  void runAlgo(int algoIndex) {
    StringBuffer log = new StringBuffer();
    log.writeln("Parsing input");
    try {
      Widget? algoResult;
      switch (component) {
        case Component.CPU:
          algoResult = runCpuAlgo(
              CpuAlgo.values[algoIndex], log, parseComputationProcesses());
          break;
        case Component.Memory:
          algoResult = runMemoryAlgo(
              MemoryAlgo.values[algoIndex], log, parseComputationProcesses());
          break;
        case Component.Storage:
          algoResult = runStorageAlgo(log, parseStorageOperations());
          break;
      }
      setState(() {
        resWidget = AlgoResult(algoResult, log);
        error = false;
        for (int i = 0; i < selectedAlgo.length; i++) {
          selectedAlgo[i] = i == algoIndex;
        }
      });
    } catch (e, s) {
      setState(() {
        print("$e\n$s");
        error = true;
        resWidget = AlgoResult(Container(), log);
      });
    }
  }
}

class TableErrorContainer extends StatelessWidget {
  const TableErrorContainer({
    Key? key,
    this.text,
  }) : super(key: key);

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white.withOpacity(0.5),
      width: 200,
      height: 20,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.5)
      ),
      alignment: Alignment.center,
      child: Text(text!,style: TextStyle(fontFamily: 'Nutino',fontWeight: FontWeight.bold),),
    );
  }
}

class TableCellPadded extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;
  final TableCellVerticalAlignment? verticalAlignment;

  const TableCellPadded(
      {Key? key, this.padding, required this.child, this.verticalAlignment})
      : super(key: key);

  @override
  TableCell build(BuildContext context) => TableCell(
      verticalAlignment: verticalAlignment,
      child: Padding(padding: padding ?? EdgeInsets.all(5.0), child: child));
}

class ProcessTable extends StatelessWidget {
  final List<TableRow> rows;
  static const TextStyle heading = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 15,
    fontFamily: 'Nutino',
  );

  static ProcessTable fromProcessList(List<List<num>> processes,
      String firstProperty, String secondProperty, Function generateID) {
    List<TableRow> rowList = List.generate(
      processes.length,
      (index) {
        List<TableCellPadded> cellList = List.generate(
            processes[index].length,
            (secondIndex) => TableCellPadded(
                child: Center(child: Text(processes[index][secondIndex].toString()))));
        cellList.insert(
            0,
            TableCellPadded(
                child: Center(
                  child: Text(
              generateID(index),
              style: TextStyle(color: Colors.black,fontFamily: 'Nutino',),
            ),
                )));
        return TableRow(
          children: cellList,
        );
      },
    );
    rowList.insert(
        0,
        TableRow(
          children: [
            const TableCellPadded(
              child: Center(
                child: Text(
                  "ID",
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(

              child: Center(
                child: Text(
                  firstProperty,
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  secondProperty,
                  style: heading,
                ),
              ),
            ),
          ],
        ));
    return ProcessTable(rows: rowList);
  }

  static ProcessTable fromStorageList(List<StorageOperation> operations) {
    List<TableRow> rowList = List.generate(
      operations.length,
      (index) {
        var operation = operations[index];
        List<TableCellPadded> cellList = [
          TableCellPadded(child: Center(child: Text((index + 1).toString(),style: TextStyle(fontFamily: 'Nutino',),))),
          TableCellPadded(
              child: Center(child: Text(operation.operationType.toString().split('.')[1]))),
          TableCellPadded(child: Center(child: Text(operation.fileName!,style: TextStyle(fontFamily: 'Nutino',)))),
        ];
        if (operation.operationType == StorageOperationType.DELETE) {
          cellList.add(const TableCellPadded(child: Center(child: Text('Entire file',style:  TextStyle(fontFamily: 'Nutino',)))));
        } else {
          cellList.add(TableCellPadded(child: Center(child: Text(operation.size.toString(), style:TextStyle(fontFamily: 'Nutino',)))));
        }
        return TableRow(
          children: cellList,
        );
      },
    );
    rowList.insert(
        0,
        const TableRow(
          children: [
            TableCellPadded(
              child: Center(
                child: Text(
                  'Step',
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  'Operation',
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  "Filename",
                  style: heading,
                ),
              ),
            ),
            TableCellPadded(
              child: Center(
                child: Text(
                  'Size',
                  style: heading,
                ),
              ),
            ),
          ],
        ));
    return ProcessTable(rows: rowList);
  }

  const ProcessTable({
    Key? key,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: Table(
        border: TableBorder.all(),
        children: rows,
      ),
    );
  }
}

class AlgoResult extends StatelessWidget {
  final Widget? resultWidget;
  final StringBuffer log;
  const AlgoResult(this.resultWidget, this.log);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 800,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white.withOpacity(0.25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.fromLTRB(0, 10.0, 0.0, 20.0),
              child: resultWidget!),
        ],
      ),
    );
  }
}


