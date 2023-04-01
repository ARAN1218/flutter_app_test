import 'dart:math';
import 'dungeon.dart';
import 'package:audioplayers/audioplayers.dart';
final _audio = AudioCache();


// アイテム系(type)
// 100...武器
// 200...ガシェット
// 300...食べ物
final List<int> ITEM_ID_LIST = [
  100,101,102, // 武器
  150,151,152, // 頭装備
  180,181,182, // 体装備
  200, // 工具
  300,301 // 食べ物
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
  300 : "鳩サブレー",
  301 : "ずんだ餅"
};

final Map<int, Map<String, int>> ITEM_ID_TO_STATUS = {
  0 : {"type" : 0},
  100 : {"type" : 100, "rare" : 10, "level" : 1, "attack" : 10, "stamina" : 20},
  101 : {"type" : 100, "rare" : 5, "level" : 1, "attack" : 15, "stamina" : 10},
  102 : {"type" : 100, "rare" : 1, "level" : 1, "attack" : 20, "stamina" : 5},
  150 : {"type" : 110, "rare" : 10, "defence" : 5, "command" : 0},
  151 : {"type" : 110, "rare" : 3, "defence" : 10, "command" : 0},
  152 : {"type" : 110, "rare" : 1, "defence" : 20, "command" : 0},
  180 : {"type" : 111, "rare" : 10, "defence" : 5, "command" : 0},
  181 : {"type" : 111, "rare" : 5, "defence" : 10, "command" : 0},
  182 : {"type" : 111, "rare" : 1, "defence" : 20, "command" : 0},
  200 : {"type" : 200, "rare" : 10, "command" : 0, "effect" : 10}, // 逐一確認して個別対応します...?
  300 : {"type" : 300, "rare" : 5, "HP_effect" : 15, "SP_effect" : 10},
  301 : {"type" : 300, "rare" : 5, "HP_effect" : 5, "SP_effect" : 25},
};

// アイテム抽選の抽選袋
final List<int> ITEM_LOTTERY_LIST = [
  for(int item_id in ITEM_ID_LIST) for(int j=0; j<ITEM_ID_TO_STATUS[item_id]!["rare"]!; j++) item_id
];

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
  -1 : {"attack" : 5, "HP" : 10, "speed" : 2, "command" : 0},
  -2 : {"attack" : 10, "HP" : 20, "speed" : 3, "command" : 0},
  -3 : {"attack" : 15, "HP" : 30, "speed" : 4, "command" : 0},
};


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

  // プレイヤーを回復するアイテム処理メソッド
  void cure(Dungeon dungeon, var Index) {
    dungeon.player.status["HP"] = min(
      (dungeon.player.status["HP"]! + this.status["HP_effect"]!),
      100
    );
    dungeon.player.status["SP"] = min(
        (dungeon.player.status["SP"]! + this.status["SP_effect"]!),
        100
    );
    dungeon.player.pouch[Index[0]][Index[1]] = Item(0);
  }

  String show() {
    var level = this.status["level"];
    var stamina = this.status["stamina"];
    return this.status["type"]==100
        ? this.name.toString() + "($level:$stamina)"
        : this.name.toString();
  }
}

// モンスタークラス
class Monster {
  late var name;
  late int timer;
  late Map<String, int> status;
  // 該当のモンスターになりきる
  Monster(int monster_id) {
    var tmp;
    name = MONSTER_ID_TO_NAME_MAP[monster_id];
    tmp = MONSTER_ID_TO_STATUS[monster_id];
    status = {...tmp};
    timer = status["speed"]!;
  }

  String show() {
    return this.name.toString() + "(" + this.timer.toString() + ")";
  }

  // モンスターがダメージを受けるメソッド
  void damage(Dungeon dungeon, var ij, int damage) {
    // print("$name に $damage ダメージを与えた！");
    dungeon.addScore(min(this.status["HP"]!, damage));
    this.status["HP"] = (this.status["HP"]! - damage);
    // print(min(this.status["HP"]!, damage));
    dungeon.player.break_equipments();

    if(this.status["HP"]! <= 0) { // モンスターのHPが0になった時
      dungeon.content[ij[0]][ij[1]] = Content("None", 0);
      // print("$name をやっつけた！");
    } // else { // 自身の攻撃と合わせて攻撃させたいなら起動
    //   this.attack(dungeon);
    // }
  }

  // モンスターが攻撃するメソッド
  void attack(Dungeon dungeon) {
    _audio.play('monster_attack.mp3');
    int damage = (this.status["attack"]! * (1-dungeon.player.status["defence"]!/100)).toInt();
    dungeon.player.status["HP"] = dungeon.player.status["HP"]! - damage;
    // print("$name は冒険者に $damage ダメージを与えた！");
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
    return ITEM_LOTTERY_LIST[random.nextInt(ITEM_LOTTERY_LIST.length)];
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