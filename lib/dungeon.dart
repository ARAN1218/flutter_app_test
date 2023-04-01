import 'player.dart';
import 'content.dart';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
final _audio = AudioCache();
var random = math.Random();
final int GOAL = -999;


class Dungeon extends Content {
  late var dungeon;
  late var content;
  // late var pouch = Pouch();
  late var player = Player();
  int score = 0;
  int dungeon_length = 10;

  // ダンジョン初期化
  Dungeon() : super('', 0) {
    dungeon = List<List<int>>.generate(
      dungeon_length,
          (i) => List<int>.generate(dungeon_length, (j) => dungeon_lottery(random.nextInt(10))).toList(),
    ).toList();
    content = List<List<Content>>.generate(
      dungeon_length,
          (i) => List<Content>.generate(dungeon_length, (j) => content_lottery(random.nextInt(100))).toList(),
    ).toList();

    // ゴールを作る
    content[random.nextInt(dungeon_length)][random.nextInt(dungeon_length)] = Content("GOAL", GOAL);
  }

  // dungeonの抽選に使う関数
  int dungeon_lottery(int num) {
    if(0<=num && num<=3) {
      return 0;
    } else if (4<=num && num<=5) {
      return 1;
    } else if (6<=num && num<=7) {
      return 2;
    } else {
      return 3;
    }
  }

  // 次の階に進む
  void proceedDungeon() {
    addScore(10);
    for (int i = 0; i < dungeon.length; i++) {
      for (int j = 0; j < dungeon[i].length; j++) {
        dungeon[i][j] = dungeon_lottery(random.nextInt(10));
        content[i][j] = content_lottery(random.nextInt(100));
      }
    }

    // ゴールを作る
    content[random.nextInt(dungeon.length)][random.nextInt(dungeon.length)] = Content("GOAL", GOAL);
  }

  // ダンジョンをリセットする
  void clearDungeon() {
    this.score = 0;
    for (int i = 0; i < dungeon.length; i++) {
      for (int j = 0; j < dungeon[i].length; j++) {
        dungeon[i][j] = -1;
      }
    }
  }

  // タップした座標の上下左右を調べる
  // もし上下左右がダンジョン外なら、そこは調べない
  void search(int i, int j, int target) {
    dungeon[i][j] = -1;
    addScore(1);

    // 上
    if(0 <= i-1) {
      if(dungeon[i-1][j] == target) {
        search(i-1, j, dungeon[i-1][j]);
      }
    }

    // 下
    if(i+1 <= dungeon_length-1) {
      if(dungeon[i+1][j] == target) {
        search(i+1, j, dungeon[i+1][j]);
      }
    }

    // 左
    if(0 <= j-1) {
      if(dungeon[i][j-1] == target) {
        search(i, j-1, dungeon[i][j-1]);
      }
    }

    // 右
    if(j+1 <= dungeon_length-1) {
      if(dungeon[i][j+1] == target) {
        search(i, j+1, dungeon[i][j+1]);
      }
    }
  }

  // フィールド上のアイテムをポーチの中に入れるメソッド
  void get(int fi, int fj) {
    // print("getメソッド発動！");
    for(int i=0; i<2; i++) {
      for(int j=0; j<5; j++) {
        if(this.player.pouch[i][j].status["item_id"] == 0) { // ポーチに空きがある時
          this.player.pouch[i][j] = this.content[fi][fj].content;
          this.content[fi][fj] = Content("None", 0);
          break;
        }
      }
    }
  }

  // モンスターの行動タイマーを進めるメソッド
  void timer_update() {
    // プレイヤーのSPを消費する
    // SPが0の場合、HPが削られる
    if(this.player.status["SP"]! == 1) {
      _audio.play('hungry.mp3');
    }
    if(this.player.status["SP"]! > 0) {
      this.player.status["SP"] = (this.player.status["SP"]!-1);
    } else {
      this.player.status["HP"] = (this.player.status["HP"]!-1);
    }

    for (int i = 0; i < dungeon.length; i++) {
      for (int j = 0; j < dungeon[i].length; j++) {
        if(this.content[i][j].type == "monster") { // モンスターをサーチ
          this.content[i][j].content.timer -= 1;
          if(this.dungeon[i][j] == -1 && this.content[i][j].content.timer == 0) { // 行動タイマーが0になった&パネルが空いている時
            this.content[i][j].content.attack(this);
            this.content[i][j].content.timer = this.content[i][j].content.status["speed"]; // 初期化
          } else if (this.content[i][j].content.timer == 0) { // 行動タイマーが0になった時
            this.content[i][j].content.timer = this.content[i][j].content.status["speed"]; // 初期化
          }
        }
      }
    }
  }

  // スコアを加算させるメソッド
  void addScore(int plus) {
    this.score += plus;
  }
}