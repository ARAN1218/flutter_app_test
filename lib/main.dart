import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'content.dart';
import 'player.dart';
var random = math.Random();
final GOAL = -999;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon Dungeon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dungeon Creators'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _FloorText = 1;
  int _TurnText = 0;
  int score = 0;
  Dungeon dungeon = Dungeon();

  void initState() {
    super.initState();
  }

  Color _changeCellColor(int i, int j) {
    if(dungeon.dungeon[i][j] == -1 && dungeon.content[i][j].content == GOAL) { // GOAL
      return Colors.deepPurpleAccent;
    } else if (dungeon.dungeon[i][j] == -1) { // 探索済み
      return Colors.white;
    } else if (dungeon.dungeon[i][j] == 0) {
      return Colors.orangeAccent;
    } else if (dungeon.dungeon[i][j] == 1) {
      return Colors.green;
    } else if (dungeon.dungeon[i][j] == 2) {
      return Colors.blueAccent;
    } else {
      return Colors.redAccent;
    }
  }

  void _search(int i, int j, int target) {
    _TurnText++;
    setState(() {
      dungeon.search(i, j, target);
    });
  }

  void _proceedDungeon(int i, int j) {
    setState(() {
      if(dungeon.content[i][j].content is Item && dungeon.content[i][j].content.status["type"] != 0) {
        dungeon.get(i, j);
      } else if(dungeon.content[i][j].content == GOAL) {
        _FloorText++;
        _TurnText = 0;
        dungeon.proceedDungeon();
      }
    });
  }

  void _clearDungeon() {
    _FloorText = 0;
    _TurnText = 0;
    setState(() {
      dungeon.clearDungeon();
    });
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   toolbarHeight: 30,
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox( // ここから勝手に入れた
              width: size.width,//dungeon.dungeon_length * 30.0,
              height: size.height/6,
              child: status() // ステータスメニュー
            ),

            Spacer(),  // レスポンシブな空白

            SizedBox(
              width: size.width,//dungeon.dungeon_length * 30.0,
              height: size.width,//dungeon.dungeon_length * 30.0,
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: List<TableRow>.generate(
                  dungeon.dungeon_length,
                      (i) => TableRow(
                    children: List<Widget>.generate(
                      dungeon.dungeon_length,
                          (widgetIndex) => field(i, widgetIndex)
                    ),
                  ),
                ),
              ),
            ),

            Spacer(),  // レスポンシブな空白

            SizedBox(
              // width: 5,
              // height: 5,
              child: TextButton(
                // color: Colors.blue,
                style: TextButton.styleFrom(
                  fixedSize: Size(5, 5),
                ),
                child: Text('クリア'),
                onPressed: _clearDungeon,
              ),
            ),

            Spacer(),  // レスポンシブな空白

            SizedBox(
              width: size.width,//dungeon.dungeon_length * 30.0,
              // height: size.height/3,//100.0,
              child: Table(
                border: TableBorder.all(color: Colors.black),
                children: List<TableRow>.generate(
                  2,
                  (i) => TableRow(
                    children: List<Widget>.generate(
                      5,
                      (widgetIndex) => dungeon.player.pouch[i][widgetIndex].name!="" // アイテム無しの場合
                          ? buildDraggable(i, widgetIndex)
                          : buildDragTarget(i, widgetIndex)
                    )
                  )
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ステータスメニュー
  Container status() =>
    Container(
      color: Colors.lightGreenAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Spacer(),  // レスポンシブな空白
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Spacer(),  // レスポンシブな空白
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'STATUS',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ), // STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Floor: $_FloorText / 10',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ), // 階層数
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Turn: $_TurnText',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ), // 経過ターン数
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'score: '+dungeon.score.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          )
        ],
          ),
          Spacer(),  // レスポンシブな空白
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Spacer(),  // レスポンシブな空白
                Text(
                  '武器',
                  style: TextStyle(fontSize: 18),
                ),
                dungeon.player.equipments["weapon"]?.name!="" // アイテム無しの場合
                    ? equipmentPouch("weapon")
                    : noequipmentPouch("weapon"),
                Spacer(),  // レスポンシブな空白
              ],
          ),
          Spacer(),  // レスポンシブな空白
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Spacer(),  // レスポンシブな空白
              Text(
                '頭',
                style: TextStyle(fontSize: 18),
              ),
              dungeon.player.equipments["head"]?.name!="" // アイテム無しの場合
                  ? equipmentPouch("head")
                  : noequipmentPouch("head"),
              Spacer(),  // レスポンシブな空白
            ],
          ),
          Spacer(),  // レスポンシブな空白
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Spacer(),  // レスポンシブな空白
              Text(
                '体',
                style: TextStyle(fontSize: 18),
              ),
              dungeon.player.equipments["body"]?.name!="" // アイテム無しの場合
                  ? equipmentPouch("body")
                  : noequipmentPouch("body"),
              Spacer(),  // レスポンシブな空白
            ],
          ),
          Spacer(),  // レスポンシブな空白
        ]
      )
    );

  // 装備のマス目(ダブルタップで装備、タップで装備解除)
  DragTarget equipmentPouch(String type) => new DragTarget(
    builder: (context, candidateData, rejectedData) {
    return new GestureDetector(
        child: Container(
          child: Text(
            dungeon.player.equipments[type]!.show(),
            style: TextStyle(fontSize: 15),
          ),
          height: MediaQuery.of(context).size.width/7,
          width: MediaQuery.of(context).size.width/7,
          color: Colors.grey,
          alignment: Alignment.center,
        ),
        onTap: () {
          print("一回タップで反応したよ");
          setState(() {dungeon.player.exit_equipments(type);});
        },
      );
    },
      onAccept: (data) {
        setState(() {dungeon.player.composite_equipments(type, data);});
      },
  );

  // 装備がついてない時のマス
  DragTarget noequipmentPouch(String type) => new DragTarget(
    builder: (context, candidateData, rejectedData) {
      return Container(
        height: 54,
        width: 54,
        color: Colors.grey,
        alignment: Alignment.center,
      );
    },
    onAccept: (data) {
      setState(() {dungeon.player.equip_equipments(type, data);});
    },
  );

  // ダンジョンのマス目
  DragTarget field(int i, int j) => DragTarget(
    builder: (context, candidateData, rejectedData) {
      return new GestureDetector(
        child: Container(
          child: Text(
            dungeon.dungeon[i][j] != -1
                ? ""
                : dungeon.content[i][j].show(),
            style: TextStyle(fontSize: 15),
          ),
          color: _changeCellColor(i, j),
          height: MediaQuery.of(context).size.width/10,
          // width: MediaQuery.of(context).size.width/20
        ),
        // タップされた時、2次元配列の対応するindexにbool値を反転させる
        onTap: () =>
            setState(() =>
              dungeon.dungeon[i][j] != -1
                  ? _search(i, j, dungeon.dungeon[i][j])
                  : dungeon.content[i][j].type == "monster"
                    ? dungeon.content[i][j].content.damage(dungeon, [i,j], dungeon.player.status["attack"])
                    : _proceedDungeon(i, j)
            ),
      );
    },
    onAccept: (data) {
      print(dungeon.content[i][j].type);
      if(dungeon.dungeon[i][j] == -1 && dungeon.content[i][j].type == "None") {
        print(data);
        print([i, j]);
        setState(() {
          dungeon.player.drop(dungeon, data, [i, j]);
        });
      }
    },
  );

  // アイテムが入っているマスのポーチ
  DragTarget buildDraggable(int i, int j) => new DragTarget(
    builder: (context, candidateData, rejectedData) {
      return new GestureDetector(
          child: new Draggable(
            data: [i, j], //dungeon.player.pouch[i][j],
            child: Container(
              child: Text(
                dungeon.player.pouch[i][j].show(),
                style: TextStyle(fontSize: 15),
              ),
              height: 64,
              width: 128,
              color: Colors.grey,
              alignment: Alignment.center,
            ),
          feedback: Material( //ドラッグ中に表示するWidgetを設定
            child: Container(
              child: Text(
                dungeon.player.pouch[i][j].show(),
                style: TextStyle(fontSize: 15),
              ),
              color: Colors.red.withOpacity(0.5),
              alignment: Alignment.center,
              width: 64,
              height: 64,
            ),
          )
      ),
        onDoubleTap: () {
            print("二回タップされたよ");
            if(dungeon.player.pouch[i][j].status["type"] == 100) { // 武器
              setState(() {dungeon.player.equip_equipments("weapon", [i,j]);});
            } else if (dungeon.player.pouch[i][j].status["type"] == 110) { // 頭装備
              setState(() {dungeon.player.equip_equipments("head", [i,j]);});
            } else if (dungeon.player.pouch[i][j].status["type"] == 111) { // 体装備
              setState(() {dungeon.player.equip_equipments("body", [i,j]);});
            }
        },
      );
    },
    onAccept: (data) {
      if(dungeon.player.pouch[i][j].status["type"]==100) { // 武器を武器にドラッグした時
        setState(() {dungeon.player.composite(data, [i,j]);});
      } else {
        setState(() {dungeon.player.swap(data, [i,j]);});
      }
    },);

  // アイテムが入っていないマスのポーチ
  DragTarget buildDragTarget(int i, int j) => new DragTarget(
      builder: (context, candidateData, rejectedData) {
        return Container(
          child: Text(
            dungeon.player.pouch[i][j].show(),
            style: TextStyle(fontSize: 15),
          ),
          height: 64,
          width: 128,
          color: Colors.grey,
          alignment: Alignment.center,
        );
      },
      onAccept: (data) {
        setState(() {dungeon.player.swap(data, [i,j]);});
      },
  );

  // ポーチのアイテムをタップすると出てくる小さいボタン
  Visibility Itemmenu(int i, int j) {
    return new Visibility(
      visible: true,
      child: Container(
        height: 640,
        width: 1280,
        child: const Text('Visibilityテスト'),
        color: Colors.lightGreenAccent,
      ),
    );
  }
}
