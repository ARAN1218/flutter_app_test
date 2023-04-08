import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'dungeon.dart';
import 'player.dart';
import 'content.dart';
var random = math.Random();
final _audio = AudioCache();
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
      title: 'Dungeon Creators',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Dungeon Creators', level: 1,),
    );
  }
}

// ホームのページ
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.level});
  final String title;
  final int level;

  @override
  State<MyHomePage> createState() => MyHomeState();
}

class MyHomeState extends State<MyHomePage> {
  String error_massage = "あなた好みにカスタマイズしましょう！";
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),  // レスポンシブな空白

            Text(
              "Dungeon Creators",
              style: TextStyle(fontSize: 30),
            ),

            Spacer(),  // レスポンシブな空白

            TextButton(
              child: Text(
                "初級ダンジョン",
                style: TextStyle(fontSize: 20),
              ),
              onPressed: (){
                _audio.play('select.mp3');
                // （1） 指定した画面に遷移する
                Navigator.push(context, MaterialPageRoute(
                  // （2） 実際に表示するページ(ウィジェット)を指定する
                    builder: (context) => MyDungeonPage(title: '初級', level: 10,)
                ));
              },
            ), // 初級ダンジョン
            TextButton(
              child: Text(
                "中級ダンジョン",
                style: TextStyle(fontSize: 20),
              ),
              onPressed: (){
                _audio.play('select.mp3');
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MyDungeonPage(title: '中級', level: 20,)
                ));
              },
            ), // 中級ダンジョン
            TextButton(
              child: Text(
                  "上級ダンジョン",
                  style: TextStyle(fontSize: 20),
              ),
              onPressed: (){
                _audio.play('select.mp3');
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MyDungeonPage(title: '上級', level: 30,)
                ));
              },
            ), // 上級ダンジョン
            TextButton(
              child: Text(
                "カスタムモード",
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () async{
                _audio.play('select.mp3');
                await Custom(context);
              },
            ), // カスタムモード
            TextButton(
              child: Text(
                "ゲーム説明",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async{
                _audio.play('select.mp3');
                await Tutorial(context);
              },
            ), // ゲーム説明

            Spacer(),  // レスポンシブな空白
          ],
        ),
      ),
    );
  }


  // カスタムモードモーダル
  Future<bool?> Custom(BuildContext context) async {
    final dateTextController = TextEditingController();
    bool? res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return AlertDialog(
            title: Text('カスタムモード'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$error_massage',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '①階層数を入力してください(半角数字・1以上)',
                  style: TextStyle(fontSize: 18),
                ),
                TextField(
                  controller: dateTextController,
                  decoration: InputDecoration(
                    hintText: "階層数を入力してください(半角数字・1以上)",
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),

                Text(
                  '②未実装',
                  style: TextStyle(fontSize: 18),
                ),
                Text('アイデア：手持ちの武器、落ちてるアイテムの確率等...'),
              ],
            ),
            actions:
              <Widget>[
                TextButton(
                  child: Text("スタート"),
                  onPressed: () {
                    _audio.play('select.mp3');
                    int floor_num = int.parse(dateTextController.text, onError: (value) => -1);
                    if(floor_num != null && floor_num >= 1) {
                      setState(() {error_massage = "あなた好みにカスタマイズしましょう！";});
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyDungeonPage(title: 'カスタム', level: floor_num,)
                      ));
                    }
                    else {
                      setState(() {error_massage = "正しく入力してください!";});
                    }
                  },
                ),
                TextButton(
                  child: Text("キャンセル"),
                  onPressed: () {
                    _audio.play('select.mp3');
                    setState(() {error_massage = "あなた好みにカスタマイズしましょう！";});
                    Navigator.pop(context);
                  },
                ),
              ]
          );},);
        }
    );
    return res;
  }


  // ゲーム説明モーダル
  Future<bool?> Tutorial(BuildContext context) async {
    bool? res = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('ゲーム説明'),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    "モンスターを退け、パネルをめくり、紫色の階段を見つけてダンジョンの奥に進もう！",
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "武器の下にある(1:30)のような表記の内、左が武器レベル、右が武器の耐久力を表している！同じ武器はドラッグ&ドロップで合成してレベルを上げて強化でき、耐久力がなくなると壊れてしまうぞ！",
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "モンスターの下にある(2)のような数字は、モンスターが攻撃するまでの時間を表している！これが0になるとプレイヤーに攻撃してHPを減らしてくるぞ！その前にモンスターをタップして攻撃し、倒してしまおう！",
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "最下層目指して頑張ってね〜",
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "このメニューを閉じる",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    _audio.play('select.mp3');
                    Navigator.pop(context);
                  },
                ),
              ]
          );
        }
    );
    return res;
  }
}



// ダンジョンのページ
class MyDungeonPage extends StatefulWidget {
  const MyDungeonPage({super.key, required this.title, required this.level});
  final String title;
  final int level;

  @override
  State<MyDungeonPage> createState() => DungeonState();
}

class DungeonState extends State<MyDungeonPage> {
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
    _audio.play('search.mp3');
    _TurnText++;
    _timer_update();
    setState(() {
      dungeon.search(i, j, target);
    });
  }

  void _proceedDungeon(int i, int j) {
    _audio.play('search.mp3');
    setState(() {
      _FloorText++;
      _TurnText = 0;
      dungeon.proceedDungeon();
    });
  }

  void _clearDungeon() {
    _audio.play('search.mp3');
    // _FloorText = 0;
    _TurnText = 0;
    setState(() {
      dungeon.clearDungeon();
    });
  }

  void _timer_update() {
    dungeon.timer_update();
    if(dungeon.player.status["HP"]! <= 0) { // プレイヤーのHPが0になった時
      setState(() {dungeon_gameover(context);});
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    int _MaxFloorText = widget.level;
    return Scaffold(
      body: Center(
        // child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ]
                    ), // debug

                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Floor: $_FloorText / $_MaxFloorText　score: '+dungeon.score.toString(),
                                ),
                              ]
                          ),
                        ]
                    ), // dungeon status

                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              fixedSize: Size(5, 5),
                            ),
                            child: Text('menu'),
                            onPressed: () async{
                              _audio.play('menu.mp3');
                              await dungeon_menu(context);
                            },
                            onLongPress: _clearDungeon,
                          ),
                        ]
                    ) // menu
                  ],
                )
            ), // メニューバー

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

            SizedBox( // ステータスメニュー
                width: size.width,
                height: size.height/6,
                child: status(
                  dungeon.player.status["HP"]!,
                  dungeon.player.status["SP"]!,
                  dungeon.player.status["attack"]!,
                  dungeon.player.status["defence"]!,
                ) // ステータスメニュー
            ), // ステータスメニュー

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
        // ),
      ),
    );
  }

  // ステータスメニュー
  Container status(int HP, int SP, int atk, int def) =>
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
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ), // STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'HP: $HP',
                    style: TextStyle(
                      fontSize: 15,
                      color: dungeon.player.status["HP"]! < 20
                        ? Colors.red
                        : Colors.black,
                    ),
                  ),
                ],
              ), // HPの表示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SP: $SP',
                    style: TextStyle(
                      fontSize: 15,
                      color: dungeon.player.status["SP"]! < 20
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ],
              ), // ATKの表示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ATK: $atk',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ), // ATKの表示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'DEF: $def',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ), // DEFの表示
              Spacer(),  // レスポンシブな空白
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
          _audio.play('equip.mp3');
          setState(() {dungeon.player.exit_equipments(type);});
        },
      );
    },
    onAccept: (data) {
      final data_ = data as List;
      if(dungeon.player.pouch[data_[0]][data_[1]].status["type"] == 200
      && type == "weapon") {
        setState(() {dungeon.player.cure_equipments(type, data);});
      } else {
        setState(() {dungeon.player.composite_equipments(type, data);});
      }
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
      _audio.play('equip.mp3');
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
            style: TextStyle(fontSize: 12),
          ),
          color: _changeCellColor(i, j),
          height: MediaQuery.of(context).size.width/10,
          // width: MediaQuery.of(context).size.width/20
        ),
        // タップされた時、2次元配列の対応するindexにbool値を反転させる
          onTap: () {
            setState(() {
              if (dungeon.dungeon[i][j] != -1) { // パネルを外してない時
                _search(i, j, dungeon.dungeon[i][j]);
              } else
              if (dungeon.content[i][j].type == "monster") { // モンスターにタップした時
                _audio.play('attack.mp3');
                dungeon.content[i][j].content.damage(dungeon, [i, j], dungeon.player.status["attack"]);
                _timer_update();
              } else if (dungeon.content[i][j].content is Item && dungeon.content[i][j].content.status["type"] != 0) { // フィールドに落ちているアイテムをタップした時
                _audio.play('drop.mp3');
                dungeon.get(i, j);
              } else if (dungeon.content[i][j].content == GOAL && widget.level == _FloorText) { // 最下層でゴールを触った時
                _audio.play('dungeon_clear.mp3');
                dungeon_clear(context);
              } else if (dungeon.content[i][j].content == GOAL) { // 普通にゴールの時
                _proceedDungeon(i, j);
              }
            });
        }
      );
    },
    onAccept: (data) {
      final data_ = data as List;
      if(dungeon.dungeon[i][j] == -1 && dungeon.content[i][j].type == "None") { // 何もない場所にポーチのアイテムをドロップした時
        // print(data);
        // print([i, j]);
        setState(() {
          _audio.play('drop.mp3');
          dungeon.player.drop(dungeon, data, [i, j]);
        });
      } else if(dungeon.dungeon[i][j] == -1 && dungeon.content[i][j].type == "monster" && dungeon.player.pouch[data_[0]][data_[1]].status["type"] == 100) { // モンスターの上に武器をドロップした時
        setState(() {
          _audio.play('attack.mp3');
          dungeon.content[i][j].content.damage(dungeon, [i, j], dungeon.player.pouch[data_[0]][data_[1]].status["attack"]*2);
          dungeon.player.pouch[data_[0]][data_[1]] = Item(0);
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
        onTapDown: (details) { // 選択音
          _audio.play('select.mp3');
        },
        onDoubleTap: () {
            if(dungeon.player.pouch[i][j].status["type"] == 100) { // 武器
              _audio.play('equip.mp3');
              setState(() {dungeon.player.equip_equipments("weapon", [i,j]);});
            } else if (dungeon.player.pouch[i][j].status["type"] == 110) { // 頭装備
              _audio.play('equip.mp3');
              setState(() {dungeon.player.equip_equipments("head", [i,j]);});
            } else if (dungeon.player.pouch[i][j].status["type"] == 111) { // 体装備
              _audio.play('equip.mp3');
              setState(() {dungeon.player.equip_equipments("body", [i,j]);});
            } else if (dungeon.player.pouch[i][j].status["type"] == 300) { // 回復アイテム
              _audio.play('cure.mp3');
              setState(() {dungeon.player.pouch[i][j].cure(dungeon, [i,j]);});
            }
        },
      );
    },
    onAccept: (data) {
      final data_ = data as List;
      setState(() {
        if(dungeon.player.pouch[data_[0]][data_[1]].status["type"]==100
            && dungeon.player.pouch[i][j].status["type"]==100) { // 武器同士だった時
          dungeon.player.composite(data, [i,j]);
        } else if(dungeon.player.pouch[data_[0]][data_[1]].status["type"]==200 // 工具をドロップした時
            && dungeon.player.pouch[i][j].status["type"]==100) {
          dungeon.player.cure(data, [i,j]);
        } else {
          dungeon.player.swap(data, [i,j]);
        }
      });
    },
  );

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

  // ダンジョンメニューモーダル
  Future<bool?> dungeon_menu(BuildContext context) async {
    bool? res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text('ダンジョンメニュー'),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    "タイトルに戻る",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    _audio.play('select.mp3');
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                SimpleDialogOption(
                  child: Text("このメニューを閉じる"),
                  onPressed: () {
                    _audio.play('select.mp3');
                    Navigator.pop(context);
                    },
                ),
              ]
          );
        }
    );
    return res;
  }


  // クリア画面モーダル
  Future<bool?> dungeon_clear(BuildContext context) async {
    int score = dungeon.score;
    int floor = widget.level;
    bool? res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                  'Dungeon Clear🎉',
                  style: TextStyle(fontSize: 30),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    "到達階数：$floor",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "あなたのスコア：$score",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
                SimpleDialogOption(
                  child: Text(
                    "まだ探索を続ける",
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SimpleDialogOption(
                  child: Text(
                    "タイトルに戻る",
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ]
          );
        }
    );
    return res;
  }


  // ゲームオーバー画面モーダル
  Future<bool?> dungeon_gameover(BuildContext context) async {
    bool? res = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                'Game Over...',
                style: TextStyle(fontSize: 30),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text(
                    "タイトルに戻る",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ]
          );
        }
    );
    return res;
  }
}