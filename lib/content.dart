import 'player.dart';
import 'dart:math' as math;
var random = math.Random();
final int GOAL = -999;

// アイテム系(type)
// 100...武器
// 200...ガシェット
// 300...食べ物
final List<int> ITEM_ID_LIST = [
  100,101,102, // 武器
  150,151,152, // 頭装備
  180,181,182, // 体装備
  200,300
]; // 0は入れない

final Map<int, String> ITEM_ID_TO_NAME_MAP = {
  0 : "", // アイテム無し
  100 : "銅の剣",
  101 : "銀の剣",
  102 : "金の剣",
  150 : "銅の兜",
  151 : "銀の兜",
  152 : "金の兜",
  180 : "銅の鎧",
  181 : "銀の鎧",
  182 : "金の鎧",
  200 : "工具",
  300 : "えだまめ",
};

final Map<int, Map<String, int>> ITEM_ID_TO_STATUS = {
  0 : {"type" : 0},
  100 : {"type" : 100, "level" : 1, "attack" : 10, "stamina" : 10},
  101 : {"type" : 100, "level" : 1, "attack" : 15, "stamina" : 10},
  102 : {"type" : 100, "level" : 1, "attack" : 20, "stamina" : 10},
  150 : {"type" : 110, "defence" : 10, "command" : 0},
  151 : {"type" : 110, "defence" : 20, "command" : 0},
  152 : {"type" : 110, "defence" : 30, "command" : 0},
  180 : {"type" : 111, "defence" : 10, "command" : 0},
  181 : {"type" : 111, "defence" : 20, "command" : 0},
  182 : {"type" : 111, "defence" : 30, "command" : 0},
  200 : {"type" : 200, "command" : 0}, // 逐一確認して個別対応します...?
  300 : {"type" : 300, "for" : 0, "effect" : 10},
};

final Map<String, int> ITEM_ID_TO_EQUIP = {
  "weapon" : 100,
  "head" : 110,
  "body" : 111,
};

// モンスター系
final List<int> MONSTER_ID_LIST = [-1,-2,-3];
final Map<int, String> MONSTER_ID_TO_NAME_MAP = {
  -1 : "スライム",
  -2 : "ゾンビ",
  -3 : "トロール",
};
final Map<int, Map<String, int>> MONSTER_ID_TO_STATUS = {
  -1 : {"attack" : 10, "HP" : 10, "speed" : 2, "command" : 0},
  -2 : {"attack" : 10, "HP" : 20, "speed" : 3, "command" : 0},
  -3 : {"attack" : 10, "HP" : 30, "speed" : 4, "command" : 0},
};


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
    _addScore(10);
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
    _addScore(1);

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
    print("getメソッド発動！");
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

  // スコアを加算させるメソッド
  void _addScore(int plus) {
    this.score += plus;
  }
}

// アイテムクラス
// 各アイテムそれぞれとして振る舞うオブジェクトが必要なので作る
class Item {
  late var name;
  late Map<String, int> status;
  Item(int item_id) {
    var tmp;
    name = ITEM_ID_TO_NAME_MAP[item_id];
    tmp = ITEM_ID_TO_STATUS[item_id];
    status = {...tmp};
    status["item_id"] = item_id;
  }

  String show() {
    var level = this.status["level"];
    return this.status["type"]==100
        ? this.name.toString() + "($level)"
        : this.name.toString();
  }
}

// モンスタークラス
class Monster {
  late var name;
  late Map<String, int> status;
  // 該当のモンスターになりきる
  Monster(int monster_id) {
    var tmp;
    name = MONSTER_ID_TO_NAME_MAP[monster_id];
    tmp = MONSTER_ID_TO_STATUS[monster_id];
    status = {...tmp};
  }

  String show() {
    return this.name.toString();
  }

  // モンスターがダメージを受けるメソッド
  void damage(Dungeon dungeon, var ij, int damage) {
    print("$name に $damage ダメージを与えた！");
    this.status["HP"] = (this.status["HP"]! - damage);
    if(this.status["HP"]! <= 0) { // HPが0になった時
      dungeon.content[ij[0]][ij[1]] = Content("None", 0);
      print("$name をやっつけた！");
    }
  }

  // モンスターが攻撃するメソッド
  void attack() {

  }
}

// アイテム・モンスタークラス
class Content {
  late var content;
  late var type;
  Content(String type, int id) {
    this.type = type;
    if(type == "item") {
      content = Item(id);
    } else if (type == "monster") {
      content = Monster(id);
    } else if (id == GOAL) { // ゴールの時
      content = GOAL;
    } else {
      content = Item(0);
    }
  }

  // メソッド系
  int item_lottery() {
    return ITEM_ID_LIST[random.nextInt(ITEM_ID_LIST.length)];
  }
  int monster_lottery() {
    return MONSTER_ID_LIST[random.nextInt(MONSTER_ID_LIST.length)];
  }
  Content content_lottery(int num) {
    if(0<=num && num<=79) {
      return Content("None", 0);
    } else if (80<=num && num<=89) {
      return Content("item", item_lottery());
    } else {
      return Content("monster", monster_lottery());
    }
  }

  String show() {
    if(this.content is int) {
      return "";
    } else if (this.content == GOAL) {
      return "GOAL";
    } else {
      return this.content.show();
    }
  }
}