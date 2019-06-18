--emmmmmm这个MOD的代码真的是惨不忍睹……太惨了 本来一开始已经规划好模块的
--但是之后又想增加很多新功能所以就越写越臃肿 现在这个MOD的代码就跟屎一样
--让我自己理清逻辑都难
--BUG还贼JB多 总之你要又什么关于MOD的问题想问的直接找我就行了  --卤蛋


local slay = RegisterMod("slay", 1);
---------------人物---------------
local testVectorVar = Vector(0,0)
local testStringVar = 0
local debug = false
--[[local pause = {
savedTime = 0,
Freeze = 0,
room2 = -1,
zeroV = Vector(0,0),
randomV = Vector(0,0),
currentP = 0,

StandCharge = 0,
StandKey = Keyboard.KEY_LEFT_SHIFT, --Which keyboard key activates wraith mode
StandActive = false,
StandGainPoints = 0.25,
StandCooldown = 0,
StandCooldownPoints = 10,
StandOn = true,
StandCooldownOn = false,
}--]]

local IroncladID = Isaac.GetPlayerTypeByName("Ironclad")
local newStart = true --是否新开了一局
local maxCharge = 0 --最大充能
local maxChargeMulti = 3 --最大充能数的倍率

local DrawCardNum = 3 --抽牌数量
local pressDown = false --射击键是否按下

local attackNum = 1  --攻击数量
local extraAttackNum = 0 --卡牌加的攻击数量

local attackRange = 20 --攻击范围
local atkType = 1 --攻击方式种类
local heavyAtkType = 2 --重击攻击种类方式
local isSpecialAtk = false--是否特殊攻击
local specialCharge = 0 --特殊攻击充能
local specialType = 0

local monsterBubble = { --开局泡泡
  play = false; 
  timer = 0;
  stopTimer = 300;
  Tigger = false;
}
local maxCost = 4 --人物最大费用
local cost = 2    --当前费用
local costTimer = 0 --计算费用的帧率

local heavyCost = 2--蓄力攻击所需要的费用
local normalCost = 1 --普通攻击需要的费用

local isplay = true  --是否播放蓄力动画
local isPlaySound = {cardSelect = 0;} --是否播放声音

local newRoom = true --是否为新房间//用来每个房间新建刀的//

local ExhaustData = {}--消耗卡牌数据表
local ExhaustCardData = {} --消耗卡牌的数据表 卡牌数据

local DropCardAnimeTableData = {
} --抽卡动画效果表
local DropCardAnimeTempData = nil

local DropCardHitboxData = {}--抽卡临时存取卡牌表
local discardToHandAnimeTimer = 0 --弃牌堆到抽牌堆动画时间

local tempDropCardVar = 0 
local tempFirstDropCardVar = 0
--如果抽牌数量大于抽牌堆的卡的数量 就先把多余的卡牌的数量放到这个变量里 抽两段 保证动画效果成功执行

 

local resetDiscardToDropAnimeTableData = false --没用
local DiscardToDropAnimeTableDataIsSet = true --从弃牌堆到抽牌堆的动画是否播放完成

local isRangeAttack = false --是范围攻击吗

local DiscardTempCount = 0 --临时显示弃牌堆数量
local CardToDiscardCardData = {} --用掉的卡牌的动画效果数据表
local DropUiAnime = {Drop = 0;Discard = 0;DropFrame = 0;DiscardFrame = 0;}
local cardName = nil
local CanDrawCard = true

local ChooseCardsInfo = {} --清理房间完选择卡牌的表
local CardToDrawAnime = {}; --选择的卡牌进入抽牌堆

local swing = true   --播放挥动动画的变量
local swingNum = 0   --播放挥动动画变量的剩余时间
local swingDir = false  --攻击方向

local isPlaySwing = false --是否播放了挥动动画
local isSpike --攻击是否带有穿透效果

local Damagesource = nil --伤害来源
local isGetDamage  = false --是否收到伤害

local spikeDistance = 50 --穿透的怪物距离 默认为50

local airTable = {} --用来装剑气的table
local airType = 1  --剑气的类型

local notPress = true --是否按下右鍵
local isHandCardToUi = false
local heavyAtkMulti = 2 --易伤伤害倍数

local isBuyingItem = false --是否要开始买东西了

local kaka = nil --咔咔动画

local PowerFramePress = false
local heartEffectTimer = 0 --播放加血特效
local playerMaxCharge = 0 --角色的最大蓄力值
local head = Isaac.GetCostumeIdByPath("gfx/characters/Ironclad_Head.anm2") --人物的头
local headSprite = Sprite()
headSprite:Load("gfx/characters/Ironclad_Head.anm2", true)

local bookForm = 0 --书套效果
local monstro_lung = 0 --萌死戳的肺
local tearBlood = 0 --泪血症

local monster = nil
local monsterTimer = 0
local test = Sprite()
test:Load("gfx/extraCard/card.anm2",true)
local power = Sprite() --power能力
power:Load("gfx/power.anm2", true)
local ui = Sprite()
ui:Load("gfx/ui/ui.anm2",true)
local CardUi = Sprite()
CardUi:Load("gfx/extraCard/normal/Extra_Card.anm2",true)
local CardFrame = Sprite()
CardFrame:Load("gfx/extraCard/normal/Card_Frame.anm2",true)
local PowerFrame = Sprite()
PowerFrame:Load("gfx/powerNumber.anm2",true)
local ChargerBarUi = Sprite()
ChargerBarUi:Load("gfx/chargebar.anm2",true)
local CircleFrameUi = Sprite()
CircleFrameUi:Load("gfx/ui/circleFrame.anm2",true)
local smokeUi = Sprite()
smokeUi:Load("gfx/extraCard/normal/smoke.anm2",true)
local DropUi = Sprite()
DropUi:Load("gfx/extraCard/normal/DropUi.anm2",true)
local DiscardToDropUi = Sprite()
DiscardToDropUi:Load("gfx/extraCard/normal/DiscardToDrop.anm2",true)
local effect = Sprite()
effect:Load("gfx/effect.anm2",true)
local gainUi = Sprite()
gainUi:Load("gfx/ui/gainUi.anm2",true)
local GameStartUi = Sprite()
GameStartUi:Load("gfx/ui/gameStartUi.anm2",true)
local ShopUi = Sprite()
ShopUi:Load("gfx/modItem.anm2",true)
local targetUi = Sprite()
targetUi:Load("gfx/ui/target.anm2",true)

local target = true
local effectData = {} --用来装在人物头上显示的Buff
local TriggerStartReward = false
local GameStartOver = false
local GameStartUiChooseId = 0
local isGameStartUiGetRandom = false --游戏开始的选择画面是否get到了随机数
local GameStartUiRandomTable = {}  --存放游戏开始时随机数的表
local GameStartUiAnimeTimer = 150
local chooseCardId = 0 --当前选择卡牌的id
local monsterPos_X = -70 --怪物一开始的X坐标值

local MetallicizeCount = 0 --金属化数值

local cancelButton = false --选牌的取消按钮
local buyButtonSfx = false --买道具的买按钮
local buyCancelButtonSfx = false --买道具的取消按钮
local buyItemName = {}  --买道具时随机出来的道具名
local getItemName = false --是否获取了道具名

local uselessBaby = {
  8,163,167,100,322,95,267,268,67,384,431,435,472,519,273,360,275,
  }
local KeyBoard = {
  [1] = {key = Keyboard.KEY_1;isPress = false;isRelease = true;id = 1;};
  [2] = {key = Keyboard.KEY_2;isPress = false;isRelease = true;id = 2;};
  [3] = {key = Keyboard.KEY_3;isPress = false;isRelease = true;id = 3;};
  [4] = {key = Keyboard.KEY_4;isPress = false;isRelease = true;id = 4;};
  [5] = {key = Keyboard.KEY_5;isPress = false;isRelease = true;id = 5;};
  [6] = {key = Keyboard.KEY_6;isPress = false;isRelease = true;id = 6;};
}
local DiscardToDropAnimeTableData = {
  [1] = {id="1";pos = nil;startTimer = 0;delete = false};
  [2] = {id="2";pos = nil;startTimer = 3;delete = false};
  [3] = {id="3";pos = nil;startTimer = 7;delete = false};
  [4] = {id="4";pos = nil;startTimer = 14;delete = false};
}

local itemEffect = {
  fear = 0,
  slow = 0,
  fire = 0,
  poison = 0,
}

local PowerFrameTime = { --用来旋转能量条的参数
  inside1Time = 0;
  inside2Time = 0;
}
local ChargeBar = { --充能条属性
  finishedTimer = 0;
  DisappearTimer = 0;
}
local CircleFrame = { --攻击范围显示器
  Visible = false;
  Duration = 0;
}
local MoveButton = {
  --LU : LeftUp  左上角
  --RD : RightDown  右下角
  LU = Vector(10,195);
  RD = Vector(50,232);
  mouseIsOver = false;
  tempMousePos = Vector(0,0)
}
local GameStartUiFrame = {
  [1] = {center = Vector(-170,160),LU = Vector(52,152),RD = Vector(287,167),mouseIsOver = false};
  [2] = {center = Vector(-170,190),LU = Vector(52,182),RD = Vector(287,197),mouseIsOver = false};
  [3] = {center = Vector(-170,220),LU = Vector(52,212),RD = Vector(287,227),mouseIsOver = false};
}

local HitBox = { --卡槽碰撞箱
  [1] = {
    id = 1;
    LU = Vector(MoveButton.LU.X+50,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
  [2]  = {
    id = 2;
    LU = Vector(MoveButton.LU.X+50+35,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80+35,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
  [3]  = {
    id = 3;
    LU = Vector(MoveButton.LU.X+50+35*2,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80+35*2,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
  [4]  = {
    id = 4;
    LU = Vector(MoveButton.LU.X+50+35*3,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80+35*3,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
  [5]  = {
    id = 5;
    LU = Vector(MoveButton.LU.X+50+35*4,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80+35*4,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
  [6]  = {
    id = 6;
    LU = Vector(MoveButton.LU.X+50+35*5,MoveButton.LU.Y+0);
    RD = Vector(MoveButton.LU.X+80+35*5,MoveButton.LU.Y+45);
    HitBoxStayTime = 0;
  };
}
local ChooseCardHitBox = {
  [1] = {};
  [2] = {};
  [3] = {};
  [4] = {};
  [5] = {};
}
local HitBoxStayTime = {}
local Ironclad = { --人物的属性
Damage = 1.3;
TearHeight = 1;
MoveSpeed = -0.2;
Luck = 1;
MaxFireDelay = 5;
cost = 0;
}
local ExtraAttack = { --额外攻击的属性
}
local Card_Draw = {}    --抽牌堆
local Card_Hand = {}    --手牌
local Card_Discard = {} --弃牌堆

local playerPower = {  --人物的能力
 [1] =   {name = "dun";value = 1;visible = false};    --斗篷
 [2] = {name = "strength";value = 0;visible = false}; --力量
 [3] =    {name = "kunai";value = 0;visible = false}; --速度 //苦无
 [4] = {name = "shuriken";value = 0;visible = false}; --手里剑
 [5] = {name = "sunflower";value = 0;visible = false};--小花
 [6] =    {name = "yalin";value = 0;visible = false}; --哑铃
 [7] =    {name = "lishi";value = 0;visible = false}; --历史
 [8] =      {name = "pen";value = 0;visible = false}; --钢笔尖
 [9] = {name = "carddown";value = 0;visible = false}; --减少卡牌
 [10] = {name = "cardup";value = 0;visible = false};  --增加卡牌
 [11] = {name = "jinji";value = 0;visible = false};   --荆棘
 [12] = {name = "lingdong";value = 0;visible = false};--灵动
 [13] = {name = "xuruo";value = 0;visible = false};   --虚弱
 [14] = {name = "duofa";value = 0;visible = false};   --多发
 [15] = {name = "shuangjiegun";value = 0;visible = false}; --双截棍
 [16] = {name = "liuxue";value = "X";visible = false};  --流血
 [17] = {name = "kaka";value = "X";visible = false};    --卡卡
 [18] = {name = "bilei";value = "X";visible = false};   --壁垒
 [19] = {name = "flame";value = "X";visible = false};   --火焰屏障
 [20] = {name = "mental";value = 0; visible = false}; --金属化
 [21] = {name = "shibukedang"; value = 2;visible = false;}--势不可当
}

local Card_Type = { --卡牌内容
       --name:卡牌名称;   cost:费用;cardType : 卡牌类型;exhaust: 是否消耗;rarity :稀有度; used:是否已经使用
  [1] = {name = "Defend"; cost = 2; cardType = "skill"; exhaust = false ; rarity = "easy";used=false;}; --防御
  [2] = {name = "Bash";   cost = 2; cardType = "attack";exhaust = false ; rarity = "easy";used=false;}; --重锤
  [3] = {name = "Cleave"; cost = 2; cardType = "attack";exhaust = false ; rarity = "easy";used=false;}; -- 顺劈斩
  [4] = {name = "ClothesLine";cost = 3; cardType = "attack";exhaust = false ; rarity = "easy";used=false;}; --虚弱打击
  [5] = {name = "Flex";   cost = 2; cardType = "skill"; exhaust = false ; rarity = "easy";used=false;}; --灵活肌肉
  [6] = {name = "Iron Wave";cost = 3; cardType = "attack";exhaust = false ; rarity = "easy";used=false;}; -- 铁斩波
  [7] = {name = "Thunder Clap";cost = 2; cardType = "attack";exhaust = false ; rarity = "easy";used=false;}; --电击疗法
  [8] = {name = "Blood Letting";cost = 0; cardType = "skill";exhaust = false ; rarity = "easy";used=false;}; --嗜血
  [9] = {name = "Carnage";   cost = 4; cardType = "attack";exhaust = false  ; rarity = "normal";used=false;}; --残杀
  [10] = {name = "Entrench";   cost = 4; cardType = "skill";exhaust = false ; rarity = "normal";used=false;}; --护甲翻倍
  [11] = {name = "Inflame";   cost = 3; cardType = "power";exhaust = true ; rarity = "normal";used=false;}; --燃烧
  [12] = {name = "Flame Barrier";cost = 3; cardType = "skill";exhaust = false ; rarity = "normal";used=false;};--火焰屏障
  [13] = {name = "Hemokinesis";   cost = 1; cardType = "attack";exhaust = false ; rarity = "normal";used=false;};--血斩
  [14] = {name = "Infernal Blade";   cost = 4; cardType = "skill";exhaust = true ; rarity = "normal";used=false;};--地狱之刃
  [15] = {name = "Metallicize";   cost = 4; cardType = "power";exhaust = true ; rarity = "normal";used=false;};--金属化
  [16] = {name = "Power Through";   cost = 3; cardType = "skill";exhaust = false ; rarity = "normal";used=false;};--通电：获得两张伤口+护甲
  [17] = {name = "Pummel";   cost = 3; cardType = "attack";exhaust = false ; rarity = "normal";used=false;}; --连续拳
  [18] = {name = "Shock Wave";   cost = 4; cardType = "skill";exhaust = true ; rarity = "normal";used=false;}; --震荡波
  [19] = {name = "See Red";   cost = 0; cardType = "skill";exhaust = true ; rarity = "normal";used=false;};--加费
  [20] = {name = "Barricade";   cost = 6; cardType = "power";exhaust = true ; rarity = "hard";used=false;}; --壁垒
  [21] = {name = "Bludgeon";   cost = 6; cardType = "attack";exhaust = false ; rarity = "hard";used=false;};--重锤
  [22] = {name = "Brutality";   cost = 4; cardType = "power";exhaust = true ; rarity = "hard";used=false;};--残忍 受伤抽牌
  [23] = {name = "Double Tap";   cost = 3; cardType = "skill";exhaust = false ; rarity = "hard";used=false;};--双发
  [24] = {name = "Feed";   cost = 4; cardType = "attack";exhaust = false ; rarity = "hard";used=false;};--吃人！
  [25] = {name = "Immolate";   cost = 4; cardType = "skill";exhaust = false ; rarity = "hard";used=false;}; --焚烧
  [26] = {name = "Impervious";   cost = 3; cardType = "skill";exhaust = true ; rarity = "hard";used=false;}; --坚韧不拔
  [27] = {name = "juggernaut";   cost = 4; cardType = "power";exhaust = true ; rarity = "hard";used=false;}; --获得护盾造成伤害
  [28] = {name = "Limit Break";   cost = 6; cardType = "skill";exhaust = true ; rarity = "hard";used=false;};--突破上限
  [29] = {name = "Reaper";   cost = 5; cardType = "attack";exhaust = false ; rarity = "hard";used=false;}; --收割者
  [30] = {name = "Injury";   cost = 99; cardType = "curse";exhaust = false ; rarity = "curse";used=false;}; --受伤 占地方
  [31] = {name = "Pain";   cost = 99; cardType = "curse";exhaust = false ; rarity = "curse";used=false;}; --疼痛 用张牌掉血
  [32] = {name = "Decay";   cost = 99; cardType = "curse";exhaust = false ; rarity = "curse";used=false;}; --腐朽 回合结束掉血
  [33] = {name = "The Bomb";   cost = 3; cardType = "skill";exhaust = false ; rarity = "colorless";used=false;}; --炸弹
  [34] = {name = "Ritual Dagger";   cost = 2; cardType = "attack";exhaust = false ; rarity = "colorless";used=false;}; --仪式匕首
  [35] = {name = "Bandage";   cost = 3; cardType = "skill";exhaust = false ; rarity = "colorless";used=false;}; --绷带
  [36] = {name = "Whirlwind";   cost = -1; cardType = "attack";exhaust = false ; rarity = "normal";used=false;};--旋风斩
  [37] = {name = "Greed of Hand";   cost = 2; cardType = "attack";exhaust = false ; rarity = "colorless";used=false;}; --贪婪之手
  [38] = {name = "Mind Blast";   cost = 3; cardType = "attack";exhaust = false ; rarity = "colorless";used=false;}; --心灵震爆
  [39] = {name = "Dazed";   cost = 0; cardType = "skill";exhaust = true ; rarity = "status";used=false;}; --眩晕
  [40] = {name = "Burn";   cost = 99; cardType = "status";exhaust = false ; rarity = "status";used=false;}; --灼伤
  [41] = {name = "Slimed";   cost = 3; cardType = "skill";exhaust = true ; rarity = "status";used=false;}; --粘液
  [42] = {name = "Wound";   cost = 99; cardType = "status";exhaust = false ; rarity = "status";used=false;};--伤口

}
--[[卡牌的效果]]--

--[[卡牌的效果]]--
local Player_Card = {
  cardNum = 2; --每次抽取的卡牌数量
  isRoomNoEnemy = false;
  isTrigger = false;
}

-------------------一些变量↑------------------
local Item = {
  --黑星
  BlackStar = Isaac.GetItemIdByName("Black Star");
  --历石
  Calendar = Isaac.GetItemIdByName("Calendar");
  --药罐
  Cauldron = Isaac.GetItemIdByName("Cauldron");
  --十二面体
  Dodecahedron = Isaac.GetItemIdByName("Dodecahedron");
  --哑铃
  Kettlebell = Isaac.GetItemIdByName("Kettlebell");
  
  --弹珠
  Marble = Isaac.GetItemIdByName("Marble");
  --存钱罐
  Bank = Isaac.GetItemIdByName("Bank");
  
  --苦无
  Kunai = Isaac.GetItemIdByName("kunai");
  --手里剑
  Shuriken = Isaac.GetItemIdByName("shuriken");
  --纸蛙
  PaperFrog = Isaac.GetItemIdByName("paper Frog");
  --古钱币
  OldCoin = Isaac.GetItemIdByName("old Coin");
  --红头骨
  RedSkull = Isaac.GetItemIdByName("red Skull");
  --向日葵
  Sunflower = Isaac.GetItemIdByName("sunflower");
  --套娃
  Matryoshka = Isaac.GetItemIdByName("matryoshka");
  --粘土
  Clay = Isaac.GetItemIdByName("clay");
  --双截棍
  Nunchaku = Isaac.GetItemIdByName("nunchaku");
  --钢笔
  Pen = Isaac.GetItemIdByName("pen");
  --肉
  Meat = Isaac.GetItemIdByName("meat");
  --缩放仪
  Pantograph = Isaac.GetItemIdByName("pantograph");
  --灵外
  Ectoplasm = Isaac.GetItemIdByName("ectoplasm");
  --面具
  CultistMask = Isaac.GetItemIdByName("cultist Mask");
  --露水
  Sozu = Isaac.GetItemIdByName("sozu");
  --诅咒钥匙
  CursedKey = Isaac.GetItemIdByName("cursed Key");
  --碎皇冠
  crown = Isaac.GetItemIdByName("crown");
  --问号
  QuestionCard = Isaac.GetItemIdByName("question Card");
}
local ModItem = {
    --抽卡器
  GetCard = Isaac.GetItemIdByName("Get Cards");
  --燃烧之血
  BlackBlood = Isaac.GetItemIdByName("Burning Blood");
  
  BankUseless = Isaac.GetItemIdByName("Bank Useless");
  
  Kettlebellhappy = Isaac.GetItemIdByName("kettlebellhappy");
}
local direct = {
  left = false,
  right = false,
  up = false,
  down = false,
  }

local CollectibleOfAtkNum = {}
local atkAirAnm2 = "gfx/atkAir.anm2"
local swordAnm2 = "Sword.anm2"
local swordID = Isaac.GetEntityTypeByName("Knight Sword")   --背后的剑实体
local sound ={
  normal_attack = Isaac.GetSoundIdByName("normal attack"); --普通攻击音效
  heavy_attack = Isaac.GetSoundIdByName("heavy attack");   --重击的音效
  kaka = Isaac.GetSoundIdByName("kaka");  --咔咔！！
  power = Isaac.GetSoundIdByName("power");  --获得能力
  healing = Isaac.GetSoundIdByName("healing");--治疗
  exhaust = Isaac.GetSoundIdByName("exhaust");--卡牌消耗
  cardSelect = Isaac.GetSoundIdByName("cardSelect"); --选择卡牌的时候
  specialAtk = Isaac.GetSoundIdByName("specialAtk"); --特殊攻击音效
  gainDefense = Isaac.GetSoundIdByName("gainDefense");--获得护盾
  thunderClap = Isaac.GetSoundIdByName("thunderClap");
  bludgeon = Isaac.GetSoundIdByName("bludgeon");
  defenseBreak = Isaac.GetSoundIdByName("defenseBreak");
  monster = Isaac.GetSoundIdByName("monster");
  selectCard = Isaac.GetSoundIdByName("selectCard");
  mouseClick = Isaac.GetSoundIdByName("mouseClick");
}

local atk = {
  normal1 = Isaac.GetEntityTypeByName("atkDummy")   --剑气
  }
--[[############################################################]]--
--[[############################道具代码########################]]--
--[[############################################################]]--
local Chocolate = {
  Range = 0;
  Damage = 0;
  }
local BlackBlood = { --燃烧之血
  Tigger = false
}
local Meat = { --肉
  Tigger = false
}
local Calendar = { --历石
  frame = 300;  --10秒倒计时
  maxFrame = 300;
}
local Sunflower = { --太阳花
  frame = 150;  --5秒倒计时
  maxFrame = 150;
}
local BlackStar = { --黑星

  isSpawn = false; --是否生成
  Myseed = nil; --种子
}
local Matryoshka = { --套娃

  isSpawn = false; --是否生成
  Myseed = nil; --种子
}
local Marble = { --弹珠
  isSet = false
}
local RedSkull = { --红头骨
  isHalfHeart = false;
  isSetAnime = false;
}
local Kettlebell = {  --哑铃
  Times = 0
}
local OldCoin = { --古钱币
  itemsNum = 1;
  coinsNum = 30;
}
local Cauldron = { --药水罐
  itemsNum = 1
}
local CursedKey = {--诅咒钥匙
itemsNum = 1;
}
local Bank ={ --存钱罐
  tempCoins = 0;
  Tigger = false;
}
local Shuriken = { --手里剑
  atkTimes = 0; --攻击次数
  addTimes = 5; --增长次数
  damageUp = 0.2; --攻击力增长数值
}
local Kunai = { --苦无
  atkTimes = 0; --攻击次数
  addTimes = 5; --增长次数
  speedUp = 0.1; --移速增长数值
}
local Nunchaku = {
  atkTimes = 0; --攻击次数
  addTimes = 10; --增长次数
  energyUp = 3; --增加的费用
}
local Pen = {
  atkTimes = 1; --攻击次数
  addTimes = 10; --增长次数
}
local Ectoplasm = { --灵外
  money = 0; --拿了灵外之后的前
  setMoney = false
}
local Pantograph = { --缩放仪
  Tigger = false;
}
local CultistMask = { --咔咔！
Tigger = false;
play = false;
timer = 0;
}

--[[############################################################]]--
--[[############################使用卡牌效果####################]]--
--[[############################################################]]--

local isDelayAtk = false
local CardEffectData = {
  flexDamage = 0; --肌肉力量
  InflameDamage = 0; --燃烧力量
  FlameBarrier = false; --火焰屏障
  PummelAtknum = 0; --连续拳
  Barricade = false; -- 壁垒
  BarricadeCount = 0; --壁垒临时变量
  DoubleTap = 0 ;--双发
  juggernaut = false; --势不可当
  juggernautCount = 0;--势不可当临时变量
  limitBreak = 1;--突破上限倍数
  ritualDaggerCount = 1;
  WhirlwindCount = 0;
  hasPain = false;--手牌中有疼痛
  hasDecay = false;--手牌中有腐朽
  pain = false; --疼痛遍历时用的参数
  decay = false; -- 腐朽遍历时用的参数
  }
local CardEffect = {
  --防御
  ["Defend"] = function()
    local player = Isaac.GetPlayer(0)
    playerPower[1].value = playerPower[1].value + 1
    SFXManager():Play(sound.gainDefense,2,0,false,1.0)

    slay:addEffectData("defense",player)
  end
  ,
  --重击
  ["Bash"] = function()
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 2
  end
  ,
  --顺劈斩
  ["Cleave"] = function()
  isRangeAttack = true
  extraAttackNum = 100
  CircleFrame.Visible = true
  specialType = 5
  isSpecialAtk = true
end
,
  --虚弱打击
  ["ClothesLine"] = function()
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 3
  end
,
  --灵活肌肉
  ["Flex"] = function()
    local player = Isaac.GetPlayer(0)
    CardEffectData.flexDamage = CardEffectData.flexDamage + 2
    playerPower[2].value = playerPower[2].value + 2
    playerPower[2].visible = true
    SFXManager():Play(sound.power,2,0,false,1.0)
    slay:addEffectData("strength",player)
  end
,
  --铁斩波
  ["Iron Wave"] = function()
    isSpecialAtk = true
    specialType = 6
    CircleFrame.Visible = true
    isDelayAtk = true
  end
,
  ["Thunder Clap"] = function()--闪电
    isRangeAttack = true
  extraAttackNum = 100
  CircleFrame.Visible = true
  specialType = 7
  isSpecialAtk = true
end
,
  ["Blood Letting"] = function()--嗜血
    local player = Isaac.GetPlayer(0)
    player:AddHearts(-2)
    cost = cost + 4
    Isaac.Spawn(1000, 2, 0,player.Position + Vector(0,5) , Vector(0,0), player)
  end
,
  ["Carnage"] = function()--残杀
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 8
  end
,
  ["Entrench"] = function()--护甲翻倍
    local player = Isaac.GetPlayer(0)
    if playerPower[1].visible == true then
      playerPower[1].value = playerPower[1].value * 2
      SFXManager():Play(sound.gainDefense,2,0,false,1.0)
      slay:addEffectData("defense",player)
    end
  end
,
  ["Inflame"] = function()--燃烧
    local player = Isaac.GetPlayer(0)
      CardEffectData.InflameDamage = CardEffectData.InflameDamage + 1.5
      SFXManager():Play(sound.power,2,0,false,1.0)
      slay:addEffectData("strength",player)
  end
,
  ["Flame Barrier"] = function()--燃烧屏障
    local player = Isaac.GetPlayer(0)
    playerPower[1].value = playerPower[1].value + 2
    slay:addEffectData("defense",player)
    CardEffectData.FlameBarrier = true
    SFXManager():Play(sound.gainDefense,2,0,false,1.0)
    SFXManager():Play(sound.power,2,0,false,1.0)
  end
,
  ["Hemokinesis"] = function()--嗜血斩杀
    local player = Isaac.GetPlayer(0)
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 9
    player:AddHearts(-1)
  end
,
  ["Infernal Blade"] = function()--地狱之刃
    local player = Isaac.GetPlayer(0)
    local attackCard = {}
    for k ,v in pairs(Card_Type) do
      if v.cardType == "attack" then
        table.insert(attackCard,clone(v))
      end
    end
    for i = 1,2 do
      math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
      local rnd = math.random(#attackCard)
      slay:GainCard(clone(attackCard[rnd]))
    end
  end
,
  ["Metallicize"] = function()--金属化
    playerPower[20].value = playerPower[20].value + 1
    SFXManager():Play(sound.power,2,0,false,1.0)
    playerPower[20].visible = true
  end
,
  ["Power Through"] = function()--伤口 + 护盾
    local player = Isaac.GetPlayer(0)
    playerPower[1].value = playerPower[1].value + 4
    slay:addEffectData("defense",player)
    SFXManager():Play(sound.gainDefense,2,0,false,1.0)
    slay:GainCard(clone(Card_Type[42]))
    slay:GainCard(clone(Card_Type[42]))
  end
,
  ["Pummel"] = function()--连续拳
    local player = Isaac.GetPlayer(0)
    CardEffectData.PummelAtknum = 6
    isSpecialAtk = true
    CircleFrame.Visible = true
    specialType = 1
  end
,
  ["Shock Wave"] = function()--震荡波
    local player = Isaac.GetPlayer(0)
    local ent = Isaac.GetRoomEntities()

      for i = 1,#ent do
        if ent[i]:IsVulnerableEnemy() then
          if ent[i]:GetData()["heavyatk"] == nil then
            ent[i]:GetData()["heavyatk"] = 8
          else
            ent[i]:GetData()["heavyatk"] = ent[i]:GetData()["heavyatk"] + 10
          end
          slay:addEffectData("yishang",ent[i])
          ent[i]:AddSlowing(EntityRef(player),99999,1,Color(0.5,0.5,1,1,0,0,0))
        end
      end
  end
,
  ["See Red"] = function()--看见红色
    local player = Isaac.GetPlayer(0)
    cost = cost + 8
  end
,
  ["Barricade"] = function()--壁垒
    local player = Isaac.GetPlayer(0)
    CardEffectData.Barricade = true
    playerPower[18].visible = true
  end
,
  ["Bludgeon"] = function()--锤子
    local player = Isaac.GetPlayer(0)
    isSpecialAtk = true
    specialType = 10
    CircleFrame.Visible = true
    isDelayAtk = true
  end
,
  ["Brutality"] = function()--掉血多抽牌
    local player = Isaac.GetPlayer(0)
    player:AddMaxHearts(-6)
    playerPower[10].value = playerPower[10].value + 1
    playerPower[10].visible = true
    SFXManager():Play(sound.power,2,0,false,1.0)
    DrawCardNum = DrawCardNum + 1
    if DrawCardNum > 6 then
      DrawCardNum = 6
    end
  end
,
  ["Double Tap"] = function()--双发
    local player = Isaac.GetPlayer(0)
    SFXManager():Play(sound.power,2,0,false,1.0)
    CardEffectData.DoubleTap = 1
  end
,
  ["Feed"] = function()--吃人！
    local player = Isaac.GetPlayer(0)
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 11
  end
,
  ["Immolate"] = function()--烧人！
    local player = Isaac.GetPlayer(0)
    local ent = Isaac.GetRoomEntities()
    slay:GainCard(clone(Card_Type[40]))
    SFXManager():Play(sound.power,2,0,false,1.0)
      for i = 1,#ent do
        if ent[i]:IsVulnerableEnemy() then
         ent[i]:AddBurn(EntityRef(player),150,player.Damage)
         slay:addEffectData("burn",ent[i])
        end
      end
  end
,
  ["juggernaut"] = function()--势不可当
    local player = Isaac.GetPlayer(0)
    playerPower[21].visible = true
    playerPower[21].value = playerPower[21].value + 5
    CardEffectData .juggernaut = true
    SFXManager():Play(sound.power,2,0,false,1.0)
  end
,
  ["Limit Break"] = function()--突破上限
    local player = Isaac.GetPlayer(0)
    CardEffectData.limitBreak = CardEffectData.limitBreak * 2
    SFXManager():Play(sound.power,2,0,false,1.0)
    slay:addEffectData("strength",player)
  end
,
  ["Reaper"] = function()--死神
  isRangeAttack = true
  extraAttackNum = 100
  CircleFrame.Visible = true
  specialType = 12
  isSpecialAtk = true
  end
,
  ["The Bomb"] = function()--炸弹
  local player = Isaac.GetPlayer(0)
  player:FireBomb(player.Position,Vector(0,0))
  end
,
  ["Ritual Dagger"] = function()--献祭匕首
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 13
  end
,
  ["Bandage"] = function()--绷带
    local player = Isaac.GetPlayer(0)
    player:AddHearts(3)
    SFXManager():Play(sound.healing,5,0,false,1.0)
    heartEffectTimer = 30
  end
,
  ["Mind Blast"] = function()--心灵震爆
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 15
  end
,
  ["Whirlwind"] = function()--旋风斩
    local player = Isaac.GetPlayer(0)
    isRangeAttack = true
    extraAttackNum = 100
    CircleFrame.Visible = true
    specialType = 16
    isSpecialAtk = true
    CardEffectData.WhirlwindCount = cost - 1
    cost = 0
  end
,
  ["Impervious"] = function()--旋风斩
    local player = Isaac.GetPlayer(0)
    playerPower[1].value = playerPower[1].value + 5
    slay:addEffectData("defense",player)
    SFXManager():Play(sound.gainDefense,2,0,false,1.0)
  end
,
  ["Greed of Hand"] = function()--贪婪之手
    local player = Isaac.GetPlayer(0)
    CircleFrame.Visible = true
    isSpecialAtk = true
    specialType = 14
  end
,
}

--[[############################################################]]--
--[[############################使用卡牌效果####################]]--
--[[############################################################]]--


slay:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,function(_,_,caflag)
--道具更变属性
    local player = Isaac.GetPlayer(0)
    --红头骨
    if player:GetPlayerType() == IroncladID then
      if caflag ==CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + Ironclad.MoveSpeed
      end
      if caflag ==CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * Ironclad.Damage + CardEffectData.flexDamage + CardEffectData.InflameDamage
      end
      if caflag ==CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + Ironclad.Luck
      end
      if caflag ==CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight + Ironclad.TearHeight
      end
      if caflag ==CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay + Ironclad.MaxFireDelay
      end
    end
    --巧克力奶
    if player:HasCollectible(69) then
      if caflag == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight + 10
        player.TearHeight =  player.TearHeight - Chocolate.Range
      end
      if caflag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage / 4
        player.Damage = player.Damage + Chocolate.Damage
      end
    end
    --红头骨
    if player:HasCollectible(Item.RedSkull) and RedSkull.isHalfHeart and caflag == CacheFlag.CACHE_DAMAGE  then
        player.Damage = player.Damage * 2
    end
    --哑铃
    if Kettlebell.Times > 0 and caflag ==CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage +1.5 * Kettlebell.Times
    end
    --苦无
    local multi = math.floor(Kunai.atkTimes/Kunai.addTimes)
    if multi >0 and caflag ==CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed + Kunai.speedUp * multi
    end
    --手里剑
    multi = math.floor(Shuriken.atkTimes/Shuriken.addTimes)
    if multi >0 and caflag ==CacheFlag.CACHE_SPEED then
      player.Damage = player.Damage + Shuriken.damageUp * multi
    end
    if math.fmod(Pen.atkTimes,Pen.addTimes) == 0 and caflag ==CacheFlag.CACHE_SPEED  and player:HasCollectible(Item.Pen) then
      player.Damage = player.Damage*3
    end
    if caflag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * CardEffectData.limitBreak
      end

end)
local gameStartTimer = 0 --游戏开始初始化变量
local gameStartRender = false
function slay:GameUpdate()
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    local isHasMantle = player:GetEffects():HasCollectibleEffect(313)
    local ent = Isaac.GetRoomEntities()
    local EntityList = Isaac.GetRoomEntities()
    local damageFlag = player:GetLastDamageFlags()
  if player:GetPlayerType() == IroncladID then
    Damagesource = player:GetLastDamageSource();
    if player:GetHearts() == 0 and player:GetBoneHearts() == 0   then
      player:Die()
    end
    --刷新cacheFlag
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
    for k,v in pairs(uselessBaby) do
      if player:HasCollectible(v) then
        player:RemoveCollectible(v)
        slay:AddRandomAttributes()
      end
    end
    --受伤触发的
    if isGetDamage then
      isGetDamage = false
      if  Damagesource.Type >= 9 and Damagesource.Type ~= 33 and getRandom(20) then --被怪物打
          slay:GainCard(clone(Card_Type[42])) --伤口
      end
      if  Damagesource.Type == 20 or Damagesource.Type == 43 then --萌死戳
          slay:GainCard(clone(Card_Type[41])) --粘液
      end
      if  Damagesource.Type == 305 and  getRandom(50) then --小萌死戳
        slay:GainCard(clone(Card_Type[41])) --粘液
      end
       if  Damagesource.Type == 33 and  getRandom(50) then --火
         slay:GainCard(clone(Card_Type[40])) --灼烧
       end
       if damageFlag ==DamageFlag.DAMAGE_EXPLOSION and getRandom(50) then --爆炸
         slay:GainCard(clone(Card_Type[39])) --眩晕
       end
    end
    
 --[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓GET卡牌↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if room:GetType()==RoomType.ROOM_DEFAULT  and room:IsFirstEnemyDead() and room:IsClear() and room:IsFirstVisit() and Player_Card.isRoomNoEnemy and not Player_Card.isTrigger then --普通房间清理完毕
      if getRandom(30) then
        slay:ChooseCardUi(Player_Card.cardNum,"notBoss")
      end
      Player_Card.isTrigger = true
    end
    
    if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstEnemyDead()  and room:IsClear() and not Player_Card.isTrigger then --商店房间清理完毕
      if getRandom(50) then
        slay:ChooseCardUi(Player_Card.cardNum,"shop")
      else
        isBuyingItem = false
        getItemName = false
      end
      Player_Card.isTrigger = true
    end
    
    if room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit()  and room:IsClear() and not Player_Card.isTrigger then --宝箱房间清理完毕
      if getRandom(50) then
        slay:ChooseCardUi(Player_Card.cardNum,"treasure")
      end
      Player_Card.isTrigger = true
    end
    
    if room:GetType() == RoomType.ROOM_BOSS and room:IsFirstEnemyDead()  and room:IsClear() and room:IsFirstVisit() and not Player_Card.isTrigger then --Boss房间清理完毕
        slay:ChooseCardUi(Player_Card.cardNum,"boss")
        Player_Card.isTrigger = true
    end
    
    if room:GetType() == RoomType.ROOM_SUPERSECRET and room:IsClear() and room:IsFirstVisit() and not Player_Card.isTrigger then --进入隐藏
      if getRandom(50) then
        slay:ChooseCardUi(Player_Card.cardNum,"secret")
      end
      Player_Card.isTrigger = true
    end
    
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑GET卡牌↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓卡牌：火焰屏障↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--

    if CardEffectData.FlameBarrier then
      for i = 1,#EntityList do
        if EntityList[i]:IsVulnerableEnemy() and slay:CalculateDistance(EntityList[i].Position,player.Position)<50 and not EntityList[i]:HasEntityFlags(EntityFlag.FLAG_BURN) then
          EntityList[i]:AddBurn(EntityRef(player),60,player.Damage)
        end
      end
      playerPower[19].visible = true
    else
      playerPower[19].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑卡牌：火焰屏障↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓卡牌：势不可当↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--

    if CardEffectData.juggernaut  then
      if CardEffectData.juggernautCount ~= playerPower[1].value then
        if CardEffectData.juggernautCount < playerPower[1].value then
          for i = 1,#EntityList do
            if EntityList[i]:IsVulnerableEnemy() then
              EntityList[i]:TakeDamage(playerPower[21].value,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
              slay:spawnSwordAir(EntityList[i],1)
              SFXManager():Play(sound.normal_attack,1,0,false,1.0)
            end
          end
        end
         CardEffectData.juggernautCount = playerPower[1].value
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑卡牌：势不可当↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--


--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：灵外的固定钱↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Ectoplasm) then
      if Ectoplasm.setMoney == false then --刚拿到这个道具时
        Ectoplasm.money = player:GetNumCoins() --使临时变量钱变成当前的钱数
        Ectoplasm.setMoney = true
      end
      if Ectoplasm.money < player:GetNumCoins() then --如果捡到到钱了
        player:AddCoins(-player:GetNumCoins()+Ectoplasm.money) --就减少
        slay:addEffectData("lingwai",player)
      else
        Ectoplasm.money = player:GetNumCoins() --如果用钱了 就把变量变成用之后的钱
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：灵外的固定钱↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓增加盾牌↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--

    if playerPower[1].value > 1 and isHasMantle == false then
      player:GetEffects():AddCollectibleEffect(313,true)
      playerPower[1].value = playerPower[1].value - 1
    end
    if playerPower[1].value > 0 and isHasMantle then playerPower[1].visible = true else playerPower[1].visible = false end --如果没盾但是等于1 就不显示BUFF
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑增加盾牌↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：添水↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  if player:HasCollectible(Item.Sozu) then
    for i = 1,#ent do   --遍历实体
      if ent[i].Type == 5 and ent[i].Variant ==70 then --如果是药丸
        player:AddBlueSpider(ent[i].Position) --生成一个蓝蜘蛛
        ent[i]:Remove()  --删除药丸
      end
    end
  end

--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：添水↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓删除血掉落↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  if player:GetPlayerType() == IroncladID then --如果是铁血战士
    for i = 1,#ent do --遍历实体
      if ent[i].Type ==5 and ent[i].Variant == 10 then --判断 如果是心类掉落
        player:AddBlueSpider(ent[i].Position)
        ent[i]:Remove()  --删除血掉落
      end
    end
    if player:GetBlackHearts() > 1 or player:GetSoulHearts() > 1 then
      player:AddBlackHearts(-1)
      player:AddSoulHearts(-1)
      player:AddBlueSpider(player.Position)
      player:AddBlueSpider(player.Position)
    end

  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑删除血掉落↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：手里剑↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Shuriken)  then
      playerPower[4].visible = true
      playerPower[4].value = math.fmod(Shuriken.atkTimes,Shuriken.addTimes)
    else
      playerPower[4].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：手里剑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：多发↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if attackNum - extraAttackNum >1 then
      playerPower[14].visible = true
      playerPower[14].value = attackNum
    else
      playerPower[14].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：多发↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：苦无↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
   if player:HasCollectible(Item.Kunai)  then
      playerPower[3].visible = true
      playerPower[3].value = math.fmod(Kunai.atkTimes,Kunai.addTimes)
    else
      playerPower[3].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：苦无↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：双截棍↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Nunchaku)  then
      playerPower[15].visible = true
      playerPower[15].value = math.fmod(Nunchaku.atkTimes,Nunchaku.addTimes)
    else
      playerPower[15].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：双截棍↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：钢笔↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Pen)  then
      playerPower[8].visible = true
      playerPower[8].value = math.fmod(Pen.atkTimes,Pen.addTimes)
    else
      playerPower[8].visible = false
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：钢笔↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--


--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：存钱罐↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Bank) then
      if player:GetNumCoins() < Bank.tempCoins then --如果用钱了
        player:AnimateSad() --表情哭
        player:RemoveCollectible(Item.Bank) --删除之前的道具
        player:AddCollectible(ModItem.BankUseless,0,false) --给你一个灰色的道具
      else
        Bank.tempCoins = player:GetNumCoins()
        if room:IsFirstEnemyDead() and room:IsClear() and room:IsFirstVisit() and Bank.Tigger then --Bank.Tigger在new room中初始化
          local pos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
          Isaac.Spawn(5,20,2,pos,Vector(0,0), nil) --清理房间生成一个五块钱
          slay:addEffectData("Bank",player);
          SFXManager():Play(sound.power,3,0,false,1.0)
          Bank.Tigger = false
        end
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：存钱罐↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：药水罐↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  for i = Cauldron.itemsNum,player:GetCollectibleNum(Item.Cauldron) do
    for i = 1,13 do
        local pos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
        Isaac.Spawn(5,70,i,pos,Vector(0,0), nil)
    end
    Cauldron.itemsNum = Cauldron.itemsNum + 1
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：药水罐↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：诅咒钥匙↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  for i = CursedKey.itemsNum,player:GetCollectibleNum(Item.CursedKey) do
    local curseCard = {}
    for k ,v in pairs(Card_Type) do
      if v.cardType == "curse" then
        table.insert(curseCard,clone(v))
      end
    end
    math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
    local rnd = math.random(#curseCard)
    slay:GainCard(clone(curseCard[rnd]))
    rnd = math.random(#curseCard)
    slay:GainCard(clone(curseCard[rnd]))
    CursedKey.itemsNum = CursedKey.itemsNum + 1
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：诅咒钥匙↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：古钱币↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  for i = OldCoin.itemsNum,player:GetCollectibleNum(Item.OldCoin) do
    for i = 1,OldCoin.coinsNum do
        local pos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
        Isaac.Spawn(5,20,0,pos,Vector(0,0), nil)
    end
    OldCoin.itemsNum = OldCoin.itemsNum+1
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：古钱币↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：向日葵↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Sunflower) and not room:IsClear() then
      Sunflower.frame = Sunflower.frame - 1
      playerPower[5].value = math.floor(Sunflower.frame/30) --显示在人物底下的标识符
      playerPower[5].visible = true --使BUFF可见
    else
      playerPower[5].visible = false --没有怪物时不可见
    end
    if Sunflower.frame <= 0 then
      Sunflower.frame = Sunflower.maxFrame
      Isaac.Spawn(1000,48,0,player.Position+Vector(20,-6),Vector(0,0),nil) --生成电池特效
      SFXManager():Play(268,2,0,false,1) -- 播放音效
      cost = cost + 2
      slay:addEffectData("flower",player)
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：向日葵↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：缩放仪↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Pantograph) then
      if room:GetType() == RoomType.ROOM_BOSS and room:IsFirstVisit() and Pantograph.Tigger then --判断是否清理和第一次进入
        heartEffectTimer = 30
        SFXManager():Play(sound.healing,5,0,false,1.0)
        player:AddHearts(math.floor(player:GetMaxHearts()*0.3))
        Pantograph.Tigger = false
        slay:addEffectData("bossHeal",player)
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：缩放仪↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--
--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：红头骨↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
  RedSkull.isHalfHeart = player:GetHearts() <= player:GetMaxHearts()/2
  if player:HasCollectible(Item.RedSkull) then
    if RedSkull.isHalfHeart and not RedSkull.isSetAnime  then
       slay:addEffectData("skull",player)
       RedSkull.isSetAnime = true
       SFXManager():Play(sound.power,3,0,false,1.0)
    elseif not RedSkull.isHalfHeart and RedSkull.isSetAnime then
      RedSkull.isSetAnime = false
    end
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：红头骨↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：咔咔↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.CultistMask) then
      playerPower[17].visible = true
      if room:IsFirstVisit() and CultistMask.Tigger then --判断是否第一次进入
          SFXManager():Play(sound.kaka,5,0,false,1.0)
        CultistMask.Tigger = false
        kaka = Isaac.Spawn(atk.normal1, 0, 0, player.Position, Vector(0,0), player)
        kaka = kaka:ToNPC()
        kaka.GridCollisionClass = GridCollisionClass.COLLISION_NONE
        kaka:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        kaka.CanShutDoors = false
        local sprite = kaka:GetSprite()
        kaka.RenderZOffset = 999
        sprite:Load("gfx/kaka.anm2", true)
        sprite:Play("qipao")
        sprite:Render(player.Position, Vector(0,0), Vector(0,0))
        CultistMask.play = true
        CultistMask.timer = 90
        kaka.Color = Color(1,1,1,(40-CultistMask.timer)/10,0,0,0)
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：咔咔↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：鲸鱼↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if  monsterBubble.play == true and not monsterBubble.Tigger then
        local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))*2
        monsterBubble.Tigger = true
        monster = Isaac.Spawn(atk.normal1, 0, 0, player.Position, Vector(0,0), player)
        monster = monster:ToNPC()
        monster.GridCollisionClass = GridCollisionClass.COLLISION_NONE
        monster:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        monster.CanShutDoors = false
        local sprite = monster:GetSprite()
        monster.RenderZOffset = 999
        sprite:Load("gfx/monster.anm2", true)
        sprite:Play("qipao")
        sprite:Render(screenCenter+Vector(-monsterPos_X,-100), Vector(0,0), Vector(0,0))
        monsterBubble.play = true
        monsterBubble.timer = 90
        monster.Color = Color(1,1,1,(40-monsterBubble.timer)/10,0,0,0)
        if monsterTimer < 30 then
          SFXManager():Play(sound.monster,5,0,false,1.0)
        end
        monsterTimer = monsterTimer + 1
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：咔咔↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--


--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：补血之火↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(ModItem.BlackBlood) then
      if room:IsFirstEnemyDead() and room:IsClear() and Player_Card.isRoomNoEnemy and room:IsFirstVisit() and BlackBlood.Tigger then --判断是否清理和第一次进入
        player:AddHearts(1) --恢复最大血量的30%
        BlackBlood.Tigger = false
        heartEffectTimer = 30
        SFXManager():Play(sound.healing,5,0,false,1.0)
        slay:addEffectData("Fire",player)
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：补血之火↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：肉↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Meat) then
      if room:IsFirstEnemyDead() and room:IsClear() and Player_Card.isRoomNoEnemy and  room:IsFirstVisit() and Meat.Tigger and player:GetHearts() <= player:GetMaxHearts()/2 then --判断是否清理和第一次进入
        player:AddHearts(2)
        Meat.Tigger = false
        if not player:HasCollectible(ModItem.BlackBlood) then
          heartEffectTimer = 30
          slay:addEffectData("meat",player)
          SFXManager():Play(sound.healing,5,0,false,1.0)
        end
      end
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：肉↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：历石↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if player:HasCollectible(Item.Calendar) and not room:IsClear() then
      Calendar.frame = Calendar.frame - 1
      playerPower[7].value = math.floor(Calendar.frame/30)
      playerPower[7].visible = true
    else
      playerPower[7].visible = false
    end
    if Calendar.frame <= 0 then
      local ent = Isaac.GetRoomEntities()
      for i = 1,#ent do
        if ent[i]:IsVulnerableEnemy() then
          ent[i]:TakeDamage(player.Damage*5*slay:HeavyAtk(ent[i]),DamageFlag.DAMAGE_LASER,EntityRef(player),10) --给十倍面板的伤害值
          slay:spawnSwordAir(ent[i],3) --触发剑气
          slay:addEffectData("lishi",player);
          SFXManager():Play(sound.power,3,0,false,1.0)
          SFXManager():Play(sound.normal_attack,1,0,false,1.0)
        end
      end
      Calendar.frame = Calendar.maxFrame
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：历石↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--


--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：黑星↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
      if player:HasCollectible(Item.BlackStar) then
        local Roomtype = Game():GetRoom():GetType()
        if Roomtype == RoomType.ROOM_BOSS and room:IsClear() and room:IsFirstVisit() and not BlackStar.isSpawn then
            math.randomseed(Game():GetFrameCount())
            BlackStar.Myseed = math.random(-100000,100000)
            local ItemPool = Game():GetItemPool()--获取道具池
            local ItemPoolType = ItemPool:GetPoolForRoom(Roomtype,BlackStar.Myseed)--获取道具池类型
            local ItemType = ItemPool:GetCollectible(ItemPoolType,true,BlackStar.Myseed) --从道具池中取出道具
          Isaac.Spawn(5,100,ItemType,room:GetGridPosition(67),Vector(0,0), nil) --生成道具
          BlackStar.isSpawn = true
          slay:addEffectData("blackStar",player);
          SFXManager():Play(sound.power,3,0,false,1.0)
        end
      end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：黑星↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：套娃↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
      if player:HasCollectible(Item.Matryoshka) then
        local Roomtype = Game():GetRoom():GetType()
        if Roomtype == RoomType.ROOM_TREASURE and room:IsFirstVisit() and not Matryoshka.isSpawn then
            math.randomseed(Game():GetFrameCount())
            Matryoshka.Myseed = math.random(-100000,100000)
            local ItemPool = Game():GetItemPool()--获取道具池
            local pos = room:FindFreePickupSpawnPosition(room:GetGridPosition(69), 1, true)
            local ItemPoolType = ItemPool:GetPoolForRoom(Roomtype,Matryoshka.Myseed)--获取道具池类型
            local ItemType = ItemPool:GetCollectible(ItemPoolType,true,Matryoshka.Myseed) --从道具池中取出道具
            slay:addEffectData("taowa",player)
          Isaac.Spawn(5,100,ItemType,pos,Vector(0,0), nil) --生成道具
          Matryoshka.isSpawn = true
        end
      end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：套娃↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：弹珠袋↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--

  if player:HasCollectible(Item.Marble) then
    if not Marble.isSet and room:IsFirstVisit() then
      Marble.isSet = true
      local ent = Isaac.GetRoomEntities()
      for i = 1,#ent do
        if ent[i]:IsVulnerableEnemy() then
          ent[i]:GetData()["heavyatk"] = 2
          slay:addEffectData("yishang",ent[i])
        end
      end
      slay:addEffectData("marble",player)
      SFXManager():Play(sound.power,3,0,false,1.0)
    end
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：弹珠袋↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓如果游戏暂停了↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
   if not Game():IsPaused() then --如果游戏暂停了
     CardEffectData.BarricadeCount = playerPower[1].value
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑如果游戏暂停了↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--
--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓键盘检测↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--

for k ,v in pairs(KeyBoard) do
    if Input.IsButtonPressed(v.key, player.ControllerIndex) and player.ControlsEnabled and not Input.IsMouseBtnPressed(0) and CanDrawCard and DiscardToDropAnimeTableDataIsSet then
      v.isPress = true
      v.isRelease = false
    else
      v.isPress = false
    end
    if not v.isPress and not v.isRelease then
      chooseCardId = v.id
      v.isRelease = true
      if HitBox[chooseCardId].card ~= nil then
        slay:UseCard()
      end
    end
  end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑键盘检测↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓新一局初始化↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
    if Game():GetFrameCount()<=1 and newStart  then
      if player:GetPlayerType() == IroncladID then
        player:AddCollectible(ModItem.BlackBlood,0,false)
        player:AddCollectible(ModItem.GetCard, 1, false);
        player:AddNullCostume(head)
        Isaac.ExecuteCommand("debug 7") --伤害反馈!
        if debug then
          Isaac.ExecuteCommand("debug 8")
        end
        Kettlebell.Times = 0 --哑铃初始化
        OldCoin.itemsNum = 1 --古钱币
        Cauldron.itemsNum = 1 --药水罐
        newStart = false --新的一局变量 用于MC_NEW_START
        Bank.tempCoins = 0 --存钱罐硬币初始化
        Ironclad = { --人物的属性
          Damage = 1.3;
          TearHeight = 1;
          MoveSpeed = -0.2;
          Luck = 1;
          MaxFireDelay = 5;
          cost = 0;
          }
        CursedKey.itemsNum = 1 --诅咒钥匙初始化
        CardEffectData.InflameDamage = 0 --燃烧设置为0
        CardEffectData.Barricade = false; --壁垒
        CardEffectData.juggernaut = false --势不可当
        CardEffectData.juggernautCount = 0 --势不可当
        CardEffectData.limitBreak = 1--突破上限倍数
        CardEffectData.ritualDaggerCount = 1 --献祭匕首
        CardToDrawAnime = {}
        DrawCardNum = 3
        for i = 1,#playerPower do --所有能力初始化
          if i == 1 then
            playerPower[i].value = 1
          elseif playerPower[i].value ~= "X" then
            playerPower[i].value = 0
          end
          playerPower[i].visible = false
        end
        --所有卡牌初始化
        for i = 1,6 do
          HitBox[i].card = nil
        end
        Card_Hand = {}
        Card_Draw = {}
        Card_Discard = {}
        --卡牌添加
        --[[游戏开始时选择的选项初始化--]]
        TriggerStartReward = false
        GameStartOver = false
        GameStartUiChooseId = 0
        isGameStartUiGetRandom = false
        GameStartUiRandomTable = {}
        gameStartTimer = 0
        gameStartRender = false
        slay:GameStart() 
        GameStartUiFrame = {
        [1] = {center = Vector(-170,160),LU = Vector(52,152),RD = Vector(287,167),mouseIsOver = false};
        [2] = {center = Vector(-170,190),LU = Vector(52,182),RD = Vector(287,197),mouseIsOver = false};
        [3] = {center = Vector(-170,220),LU = Vector(52,212),RD = Vector(287,227),mouseIsOver = false};
        }
         GameStartUiAnimeTimer = 150
         monsterPos_X = -70 --怪物一开始的X坐标值
        --[[游戏开始时选择的选项初始化--]]
      end
    end
    if gameStartTimer < 60 then
      gameStartTimer = gameStartTimer +1
    elseif gameStartTimer == 60 then
      slay:GameStart()
      gameStartTimer = gameStartTimer +1
      gameStartRender = true
    end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑新一局初始化↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--
end
end
function slay:GameStart()
local player = Isaac.GetPlayer(0)
  player.ControlsEnabled = false
  
  if gameStartTimer > 30 then 
    slay:GainCard(clone(Card_Type[2]),60)
    slay:GainCard(clone(Card_Type[3]),60)
    slay:GainCard(clone(Card_Type[33]),60)
    slay:GainCard(clone(Card_Type[5]),60)
  else
    for i = 1 ,4 do
      slay:GainCard(clone(Card_Type[1]),60)
    end
  end
end

function slay:AddRandomAttributes()
  local attributes = {TearHeight= -5;Damage= 0.2;MaxFireDelay=-1;MoveSpeed=0.2;Luck=1}
  for k,v in pairs(attributes) do
    if getRandom(30) then
      Ironclad[k] = Ironclad[k] + v
    end
  end
end

function slay:GameStartRender()
  local player = Isaac.GetPlayer(0)
  if player:GetPlayerType() == IroncladID then
    local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))*2
    Isaac.RenderText("slay.command:"..tostring(slay.command),2500,30 , 1, 1, 1, 1)
    Isaac.RenderText("slay.AddRange:"..tostring(slay.AddRange),2500,40 , 1, 1, 1, 1)
    Isaac.RenderText("slay.NewRoom:"..tostring(slay.NewRoom),2500,50 , 1, 1, 1, 1)
    Isaac.RenderText("slay.NewStart:"..tostring(slay.NewStart),2500,60 , 1, 1, 1, 1)
    Isaac.RenderText("slay.CostTimer:"..tostring(slay.CostTimer),2500,70 , 1, 1, 1, 1)
    Isaac.RenderText("slay.SpawnSword:"..tostring(slay.SpawnSword),2500,80 , 1, 1, 1, 1)
    Isaac.RenderText("slay.ChangeFromItems:"..tostring(slay.ChangeFromItems),2500,90 , 1, 1, 1, 1)
    Isaac.RenderText("slay.PlayerToAttack:"..tostring(slay.PlayerToAttack),2500,100 , 1, 1, 1, 1)
    Isaac.RenderText("slay.ChooseCardUiRender:"..tostring(slay.ChooseCardUiRender),2500,110 , 1, 1, 1, 1)
    Isaac.RenderText("slay.GameStartRender:"..tostring(slay.GameStartRender),2500,120 , 1, 1, 1, 1)
    Isaac.RenderText("slay.DebugRender:"..tostring(slay.DebugRender),2500,130 , 1, 1, 1, 1)
    Isaac.RenderText("slay.GainCardRender:"..tostring(slay.GainCardRender),2500,140 , 1, 1, 1, 1)
    Isaac.RenderText("slay.EffectRender:"..tostring(slay.EffectRender),2500,150 , 1, 1, 1, 1)
    Isaac.RenderText("slay.BuyItemRender:"..tostring(slay.BuyItemRender),2500,160 , 1, 1, 1, 1)
    --[[抽取三个不相同的数值]]--  
    if not isGameStartUiGetRandom then
      for i = 1,3 do
        math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
        
        local rndnum = math.random(7)
        while isInArray(GameStartUiRandomTable,rndnum) do
          rndnum = math.random(7)
        end
          table.insert(GameStartUiRandomTable,rndnum)
      end
      isGameStartUiGetRandom = true
    end
    --[[抽取三个不相同的数值]]--
    
    if gameStartRender then
      player.ControlsEnabled = false
      local i = 0
      if not GameStartOver then
        if GameStartUiAnimeTimer >0 then
          GameStartUiAnimeTimer = GameStartUiAnimeTimer - 1
        end        
        if GameStartUiAnimeTimer < 130 then
          if GameStartUiFrame[1].center.X <170 then
            GameStartUiFrame[1].center = GameStartUiFrame[1].center + Vector(5,0)
          end
        end
        if GameStartUiAnimeTimer < 110 then
          if GameStartUiFrame[2].center.X <170 then
            GameStartUiFrame[2].center = GameStartUiFrame[2].center + Vector(5,0)
          end
        end
        if GameStartUiAnimeTimer < 90 then
          if GameStartUiFrame[3].center.X <170 then
            GameStartUiFrame[3].center = GameStartUiFrame[3].center + Vector(5,0)
          end
        else
          monsterPos_X = monsterPos_X + 2
        end
      else
        GameStartUiAnimeTimer = GameStartUiAnimeTimer + 1
        if GameStartUiAnimeTimer > 0 then
          if GameStartUiFrame[1].center.X >-170 then
            GameStartUiFrame[1].center = GameStartUiFrame[1].center - Vector(10,0)
          end
        end
        if GameStartUiAnimeTimer > 20 then
          if GameStartUiFrame[2].center.X >-170 then
            GameStartUiFrame[2].center = GameStartUiFrame[2].center - Vector(10,0)
          end
        end
        if GameStartUiAnimeTimer > 40 then
          if GameStartUiFrame[3].center.X >-170 then
            GameStartUiFrame[3].center = GameStartUiFrame[3].center - Vector(10,0)
          end
          monsterPos_X = monsterPos_X - 2
        end
        if GameStartUiAnimeTimer > 120 then
          gameStartRender = false
          TriggerStartReward = true
        end
      end
      for k ,v in pairs(GameStartUiFrame) do
        i = i + 1
        GameStartUi.Scale = Vector(0.3,0.3)
        if slay:IsMouseOnHitBox(v.LU,v.RD) and not GameStartOver and GameStartUiAnimeTimer<=0 then
          GameStartUi:SetFrame("buttonOn",0)
          GameStartUiChooseId = i
          if not v.mouseIsOver then
            v.mouseIsOver = true
            SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS,3,0,false,1.0)
          end
          --[[处理右键事件--]]
          if Input.IsMouseBtnPressed(0) then
          monsterBubble.play = true
          end
          if Input.IsMouseBtnPressed(1) and not Input.IsMouseBtnPressed(0) then
            if notPress then
              GameStartOver = true
              SFXManager():Play(sound.mouseClick,5,0,false,1.0)
            end
            notPress = false
          else
           notPress = true
          end
          --[[处理右键事件--]]
        else
          v.mouseIsOver = false
          GameStartUi:SetFrame("buttonOff",0)
        end
        GameStartUi:Render(v.center,Vector(0,0),Vector(0,0))
        GameStartUi:SetFrame(tostring(GameStartUiRandomTable[i]),0)
        GameStartUi:Render(v.center,Vector(0,0),Vector(0,0))
      end
      --[[生成怪物--]]
      GameStartUi:SetFrame("monster",0)
      GameStartUi:Render(screenCenter+Vector(-monsterPos_X,-100),Vector(0,0),Vector(0,0))
      --[[生成怪物--]]
    end
    if TriggerStartReward then
      player.ControlsEnabled = true
      TriggerStartReward = not TriggerStartReward
      if GameStartUiRandomTable[GameStartUiChooseId] == 1 then --随机获得一个遗物
        local _,item = slay:readRandomValueInTable(Item)
        Isaac.Spawn(5,100,item,player.Position,Vector(0,0),player)
        
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 2 then --随机获得一个汉奸卡牌
        local HardCard = {}
        for k ,v in pairs(Card_Type) do
          if v.rarity == "hard" then
            table.insert(HardCard,clone(v))
          end
        end
        math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
        local rnd = math.random(#HardCard)
        slay:GainCard(clone(HardCard[rnd]))
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 3 then --挑选一张稀有卡牌
        slay:ChooseCardUi(3,"normal")
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 4 then --能量上限+1
        Ironclad.cost = Ironclad.cost + 1
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 5 then --射程+5
        Ironclad.TearHeight = Ironclad.TearHeight - 5
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 6 then --攻击力+1
        Ironclad.Damage = Ironclad.Damage + 0.3
      elseif GameStartUiRandomTable[GameStartUiChooseId] == 7 then --延迟-1
        Ironclad.MaxFireDelay = Ironclad.MaxFireDelay - 2
      end
    end
  end
end
--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：哑铃↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
slay:AddCallback(ModCallbacks.MC_USE_ITEM,function(_,_)
  local player = Isaac.GetPlayer(0)
  if Kettlebell.Times < 3 then
     Kettlebell.Times = Kettlebell.Times + 1
     playerPower[6].value = playerPower[6].value +1
     playerPower[6].visible = true
  end

  if Kettlebell.Times == 3 then --使用三次后变成不可用的哑铃
    player:RemoveCollectible(Item.Kettlebell)
    player:AddCollectible(ModItem.Kettlebellhappy,0,false)
  end
  return true
end,Item.Kettlebell)
--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：抽卡器↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
local testVar = true
function slay:DrawCardItem()--使用抽卡器
  local player = Isaac.GetPlayer(0)
  local game = Game()
  if CanDrawCard and DiscardToDropAnimeTableDataIsSet then
    for i = 1,6 do    --弃牌动画
      if HitBox[i].card ~=nil then
        cardName = HitBox[i].card.name
        chooseCardId = i
        slay.CardToDiscardAnime()
      end
    end
    tempFirstDropCardVar = 0
    DiscardTempCount = 0 --临时弃牌数量
    slay:CardToDiscard(true,nil)--把全部卡牌推入弃牌堆
    isHandCardToUi = false
    slay:CardToHandAnime(DrawCardNum) --抽卡
  end
  return true
end

slay:AddCallback(ModCallbacks.MC_USE_ITEM,function(_,_)
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    --[[ playerPower[1].visible = true
     playerPower[2].visible = true
     playerPower[3].visible = true
     playerPower[4].visible = true
     playerPower[5].visible = true
     playerPower[6].visible = true
     playerPower[7].visible = true
     playerPower[8].visible = true
     playerPower[9].visible = true
     playerPower[10].visible = true
     playerPower[11].visible = true
     playerPower[12].visible = true
     playerPower[13].visible = true
     playerPower[14].visible = true
     playerPower[15].visible = true
     playerPower[16].visible = true
     playerPower[17].visible = true
     playerPower[18].visible = true--]]
      --[[for i = 553,586 do
        Isaac.Spawn(5,100,i,Game():GetRoom():FindFreePickupSpawnPosition(room:GetGridPosition(i-552, true),1, true),Vector(0,0), nil)
      end--]]
  return true
end,ModItem.Kettlebellhappy)
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：哑铃↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--

--[[↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓道具：粘土↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓]]--
function slay:GetDamage(entDamage,_2,damage,DamageFlag,_3,damageCountDown)--受伤触发
    local player = Isaac.GetPlayer(0)
    isGetDamage = true
    testStringVar = damageCountDown
    if player:HasCollectible(Item.Clay) then
      playerPower[1].value = playerPower[1].value + 1
      SFXManager():Play(sound.gainDefense,2,0,false,1.0)
      slay:addEffectData("defense",player)
    end
    
end
--[[↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑道具：粘土↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑]]--
slay:AddCallback(ModCallbacks.MC_POST_UPDATE,function(_,_)  --播放增加血量的特效 //比如燃烧之血 肉 缩放仪
  local player = Isaac.GetPlayer(0)
  if heartEffectTimer > 0 then
    if math.fmod(heartEffectTimer,2) == 0 then
      Isaac.Spawn(1000,49,0,player.Position+Vector(math.random(-50,50),math.random(-50,50)),Vector(0,0),nil)
    end
    heartEffectTimer = heartEffectTimer - 1
  end
end)
--[[############################################################]]--
--[[############################道具代码########################]]--
--[[############################################################]]--




function slay:NormalAttack(attType)--普通攻击
  local player = Isaac.GetPlayer(0)
  local EntityList = Isaac.GetRoomEntities()
  local EnemyList,EnemyDistanceList = slay:CountRoomIsVulnerableEnemy(EntityList)
  local EnemySortList = slay:SortEnemyList(EnemyList,EnemyDistanceList)
  local atkNum = attackNum
  local room = Game():GetRoom()
  if #EnemySortList ~=0 then
    if atkNum > #EnemySortList then
      atkNum = #EnemySortList
    end
    if attackNum > 1 and #EnemySortList == 1 and not isRangeAttack then  --如果拥有多发 并且只有一个敌人在范围内
      table.insert(ExtraAttack,{enemy = EnemySortList[1];attackNumber = attackNum - 1;attType = attType})
    end
    for i = 1,atkNum do
      slay:Attack(EnemySortList[i],attType)
    end
  else --房间没有怪物时
    if not isRangeAttack then
      slay:spawnSwordAirEffect(attType)
    else
      slay:spawnSwordAirEffect(attType)
    end
    SFXManager():Play(38,2,0,false,1.0)
  end
end


--[[多次攻击]]--
function slay:ExtraAttack()--额外攻击
  local i = 0
  for k,v in ipairs(ExtraAttack) do
    i = i + 1
    if v.attackNumber ~=0 and not(v.enemy:IsDead()) then
      slay:Attack(v.enemy,v.attType)
      v.attackNumber = v.attackNumber - 1
    else
      table.remove(ExtraAttack,i)
    end
  end
end

local ExtraTimer = 0
function slay:ExtraAttackTimer() --额外攻击的计时器
  if ExtraTimer == 7 then
    slay:ExtraAttack()
    ExtraTimer = 0
  else
    ExtraTimer = ExtraTimer +  1
  end
end
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.ExtraAttackTimer) --多次攻击触发器
--[[多次攻击]]--
local DelayAttackData = {}

function slay:DelayAttack() --延迟攻击
  local player = Isaac.GetPlayer(0)
  local i = 0
  for k,v in pairs(DelayAttackData) do
    i = i + 1
    if v.timer > 0 then
      v.timer = v.timer - 1
    else
      if v.attType == 6 then --铁斩波
        slay:AttackBack(5)
        v.enemy:TakeDamage(v.damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
        playerPower[1].value = playerPower[1].value + 1
        SFXManager():Play(sound.specialAtk,3,0,false,1.0)
        SFXManager():Play(sound.gainDefense,2,0,false,1.0)
        slay:addEffectData("defense",player)
        table.remove(DelayAttackData,i)
        Isaac.Spawn(1000, 2, 0, v.enemy.Position + Vector(0,5) , Vector(0,0), player)
      elseif v.attType == 10 then --铁斩波
        slay:AttackBack(15)
        v.damage = v.damage*5 + math.floor(v.enemy.MaxHitPoints*25)/100
        v.enemy:TakeDamage(v.damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
        SFXManager():Play(sound.bludgeon,3,0,false,1.0)
        table.remove(DelayAttackData,i)
      end
    end
  end
end
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.DelayAttack)
function slay:Attack(enemy,attType) --普通攻击  被其他函数调用
      local player = Isaac.GetPlayer(0)
      local damage = player.Damage
      local room = Game():GetRoom()
      local mpos = room:WorldToScreenPosition(Input.GetMousePosition(true))
      if type(enemy:GetData()["heavyatk"]) ~= type(nil) then
        if enemy:GetData()["heavyatk"] > 0 then --判断有没有重伤
          damage = damage * heavyAtkMulti
          enemy:GetData()["heavyatk"] = enemy:GetData()["heavyatk"] - 1
          if not isDelayAtk then Isaac.Spawn(1000, 2, 0, enemy.Position + Vector(0,5) , Vector(0,0), player) end
        else
          if not isDelayAtk then Isaac.Spawn(1000, 5 , 0, enemy.Position + Vector(0,5) , Vector(0,0), player) end
        end
      else
        enemy:GetData()["heavyatk"] = 0
      end

      if player:HasCollectible(132) then --煤块
        local coalDistance = slay:CalculateDistance(room:WorldToScreenPosition(enemy.Position),room:WorldToScreenPosition(player.Position)) / 40 - 0.5 --计算距离增加的伤害值
        if coalDistance <0 then --如果加的伤害为负数  则 不减少
          coalDistance = 0
        end
        damage = damage  + coalDistance --增加伤害
      end
      if (player:HasCollectible(254) or player:HasCollectible(154))and swingDir then
        damage = damage + 0.5
      end
        if attType == 1 then
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10) --普通攻击
          slay:AttackBack(3)
          slay:spawnSwordAir(enemy,airType)
          SFXManager():Play(sound.normal_attack,1,0,false,1.0)
          CardEffectData.PummelAtknum = 0 --连续拳取消

            --大火球 持续10帧
            if player:HasCollectible(118) and not player:HasCollectible(395) then --硫磺火
              slay:FireBrimstone(10,enemy.Position,damage)
            end
            if player:HasCollectible(149) then --吐根
              Isaac.Explode(enemy.Position,nil,damage) --产生爆炸
              Isaac.Explode(enemy.Position, nil, 0) --产生爆炸击退
            end
            if player:HasCollectible(395) then --科技X
              player:FireTechXLaser(enemy.Position,slay:CalculateVector(enemy.Position,player.Position)*(player.ShotSpeed*10),damage*3)
            end
        elseif attType == 2 then
          slay:AttackBack(8)
          enemy:TakeDamage(damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10) --重击
          slay:spawnSwordAir(enemy,attType)
          SFXManager():Play(sound.heavy_attack,1,0,false,1.0)
          enemy:GetData()["heavyatk"]= enemy:GetData()["heavyatk"] + 4
          slay:addEffectData("yishang",enemy)
          Isaac.Spawn(1000, 2, 0, enemy.Position + Vector(0,5) , Vector(0,0), player)
          if player:HasCollectible(118) and not player:HasCollectible(395) then --硫磺火
            --大火球 持续30帧
              slay:FireBrimstone(30,enemy.Position,damage)
          end
          if player:HasCollectible(399) then --黑圈
            local mawOfVoid = player:SpawnMawOfVoid(30)
          end
          if player:HasCollectible(149) then --吐根
              Isaac.Explode(enemy.Position,nil,damage) --产生爆炸
              Isaac.Explode(enemy.Position, nil, 0) --产生爆炸击退
          end
          if player:HasCollectible(395) then --科技X
            player:FireTechXLaser(enemy.Position,slay:CalculateVector(enemy.Position,player.Position)*(player.ShotSpeed*10),damage*5)
          end
        elseif attType == 3 then --虚弱打击
          slay:AttackBack(5)
          enemy:TakeDamage(damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,2)
          SFXManager():Play(sound.heavy_attack,2,0,false,1.0)
          enemy:AddSlowing(EntityRef(player),150,1,Color(0.5,0.5,1,1,0,0,0))

        elseif attType == 5 then --顺劈斩
          slay:AttackBack(4)
          enemy:TakeDamage(damage*1.5,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(player,5)
          SFXManager():Play(sound.specialAtk,2,0,false,1.0)

        elseif attType == 6 then--铁斩波
          local delayAtk = {attType = attType;timer = 12;enemy = enemy;damage = damage;}
          table.insert(DelayAttackData,clone(delayAtk))
          isDelayAtk = false
          slay:spawnSwordAir(enemy,6)

        elseif attType == 7 then--闪电
          slay:AttackBack(4)
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,7)
          SFXManager():Play(sound.thunderClap,2,0,false,1.0)
          enemy:GetData()["heavyatk"] = enemy:GetData()["heavyatk"] +2
          slay:addEffectData("yishang",enemy)
        elseif attType == 8 then--残杀
          slay:AttackBack(4)
          damage = damage*4 + math.floor(enemy.MaxHitPoints*150)/1000
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,2)
          SFXManager():Play(sound.heavy_attack,2,0,false,1.0)
        elseif attType == 9 then--嗜血斩杀
          slay:AttackBack(4)
          damage = damage*4
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,2)
          SFXManager():Play(sound.heavy_attack,2,0,false,1.0)
          Isaac.Spawn(1000, 2, 0, player.Position + Vector(0,5) , Vector(0,0), player)
        elseif attType == 10 then--重锤
          local delayAtk = {attType = attType;timer = 16;enemy = enemy;damage = damage;}
          table.insert(DelayAttackData,clone(delayAtk))
          isDelayAtk = false
          slay:spawnSwordAir(enemy,10)
        elseif attType == 11 then--吃人
          slay:AttackBack(4)
          enemy:TakeDamage(damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,2)
          SFXManager():Play(sound.heavy_attack,2,0,false,1.0)
          if damage > enemy.HitPoints then
            if  enemy:IsBoss() then
              player:AddMaxHearts(2)
            end
            for i=1,5 do
            for j = 1,5 do
              Isaac.Spawn(1000, 2, 0, enemy.Position + Vector(i,j) , Vector(0,0), player)
            end
            end
          end
        elseif attType == 12 then--死神
          slay:AttackBack(4)
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(enemy,2)
          for i=1,3 do
            for j = 1,3 do
              Isaac.Spawn(1000, 2, 0, enemy.Position + Vector(i,j) , Vector(0,0), player)
            end
          end
          player:AddHearts(1)
          SFXManager():Play(sound.specialAtk,2,0,false,1.0)
          SFXManager():Play(sound.healing,5,0,false,1.0)
        elseif attType == 13 then--献祭匕首
          slay:AttackBack(4)
          slay:spawnSwordAir(enemy,1)
          damage = damage * CardEffectData.ritualDaggerCount
          enemy:TakeDamage(damage,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          SFXManager():Play(sound.normal_attack,2,0,false,1.0)
          if damage > enemy.HitPoints then
            CardEffectData.ritualDaggerCount = CardEffectData.ritualDaggerCount  + 1
          end
        elseif attType == 14 then--贪婪之手
          slay:AttackBack(4)
          slay:spawnSwordAir(enemy,2)
          enemy:TakeDamage(damage*2,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          SFXManager():Play(sound.heavy_attack,2,0,false,1.0)
          if damage > enemy.HitPoints then
            Isaac.Spawn(5,20,2,enemy.Position,Vector(0,0),player)
          end
        elseif attType == 15 then--心灵震爆
          player:FireBrimstone(slay:CalculateVector(mpos,room:WorldToScreenPosition(player.Position)))
        elseif attType == 16 then--旋风斩
          slay:AttackBack(4)
          enemy:TakeDamage(damage*1.5,DamageFlag.DAMAGE_LASER,EntityRef(player),10)
          slay:spawnSwordAir(player,5)
          SFXManager():Play(sound.specialAtk,2,0,false,1.0)
          table.insert(ExtraAttack,{enemy = enemy;attackNumber = CardEffectData.WhirlwindCount ;attType = 5})
        end

        if player:HasCollectible(68) or player:HasCollectible(494) then --科技1
          --效果：在敌人身上射出一条激光线
          player:FireTechLaser(enemy.Position,LaserOffset.LASER_BRIMSTONE_OFFSET,enemy.Position - player.Position ,false,true)
        end

        if player:HasCollectible(52) then --婴儿博士
          player:FireBomb(enemy.Position,Vector(0,0))
        end
        if isSpike then --如果有穿透道具 那么就
          slay:spikeAtk(enemy,damage) --触发穿透
        end

        if player:HasCollectible(Item.Kunai)  then --苦无
          Kunai.atkTimes = Kunai.atkTimes + 1
          if math.fmod(Kunai.atkTimes,Kunai.addTimes) == 0 then
            slay:addEffectData("kunai",player)
            SFXManager():Play(sound.power,3,0,false,1.0)
          end
        end
        if player:HasCollectible(Item.Shuriken)  then--手里剑
          Shuriken.atkTimes = Shuriken.atkTimes + 1
          if math.fmod(Shuriken.atkTimes,Shuriken.addTimes) == 0 then
            slay:addEffectData("shuriken",player)
            SFXManager():Play(sound.power,3,0,false,1.0)
          end
        end
        if player:HasCollectible(Item.Pen)  then --钢笔
          Pen.atkTimes = Pen.atkTimes + 1
          if math.fmod(Pen.atkTimes,Pen.addTimes) == 0 then
            slay:addEffectData("pen",player)
            SFXManager():Play(sound.power,3,0,false,1.0)
          end
        end
        math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
        local rnd = math.random(100)
        if rnd<itemEffect.fear then
          enemy:AddFear(EntityRef(player),60)
        end
        rnd = math.random(100)
        if rnd<itemEffect.fire then
          enemy:AddBurn(EntityRef(player),30,damage)
        end
        rnd = math.random(100)
        if rnd<itemEffect.slow then
          enemy:AddSlowing(EntityRef(player),60,1,Color(0.5,0.5,1,1,0,0,0))
        end
        rnd = math.random(100)
        if rnd<itemEffect.poison then
          enemy:AddPoison(EntityRef(player),30,damage)
        end
        if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) then --猫套效果
          player:AddBlueFlies(1, player.Position,player) --生成一只蓝苍蝇
        end
        if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM) then --书套效果
          if math.random(1,3) == 1 then --1/3概率触发书套
            bookForm = 1
          else
            bookForm = 0
          end
        else
          bookForm = 0
        end
        if player:HasCollectible(229) then --萌死戳的肺
          monstro_lung = math.random(2,5)
        else
          monstro_lung = 0
        end
         if player:HasCollectible(531) then --萌死戳的肺
          tearBlood = math.random(2,5)
        else
          tearBlood = 0
        end
        if player:HasCollectible(Item.Nunchaku)  then --双截棍
          Nunchaku.atkTimes = Nunchaku.atkTimes + 1
          if math.fmod(Nunchaku.atkTimes,Nunchaku.addTimes) == 0 then
            cost = cost + Nunchaku.energyUp
            Isaac.Spawn(1000,48,0,player.Position+Vector(20,-6),Vector(0,0),nil) --生成电池特效
            SFXManager():Play(sound.power,3,0,false,1.0) --播放音效
          end
        end
end
function slay:SortEnemyList(EntityList,EnemyDistanceList)   --返回排序完毕的怪物table
  local temp
  --神奇的冒泡排序
  for i = 1,#EntityList - 1 do
    for j = 1,#EnemyDistanceList -i do
        if EnemyDistanceList[j] > EnemyDistanceList[j+1] then
          EnemyDistanceList[j],EnemyDistanceList[j+1] =EnemyDistanceList[j+1] ,EnemyDistanceList[j] --经典的冒泡排序思路
          EntityList[j],EntityList[j+1] = EntityList[j+1] ,EntityList[j]
        end
      end
  end
  return EntityList
end

function slay:CountRoomIsVulnerableEnemy(EntityList) --返回符合条件的怪物table，返回怪物对应位置table
  local EnemyList = {}
  local TempList = {}
  local EnemyDistance = {}
  local j = 1
  local player = Isaac.GetPlayer(0)
  local room = Game():GetRoom()
  local playerPos = room:WorldToScreenPosition(player.Position) --人物的位置
  local mousePos = Isaac.WorldToScreen(Input.GetMousePosition(true))
  for i = 1,#EntityList do  --找出房间所有可攻击的怪物
    if EntityList[i]:IsVulnerableEnemy() then
      table.insert(TempList,j,EntityList[i])
      j = j + 1
    end
  end

  j=1
  for i = 1,#TempList do
    local enemyPos = room:WorldToScreenPosition(TempList[i].Position) --怪物的位置
    local tempDistance = slay:CalculateDistance(enemyPos,playerPos)
    if  tempDistance < attackRange then
      tempDistance = slay:CalculateDistance(enemyPos,mousePos)
        if tempDistance < 20+attackNum*3 or isRangeAttack then
        table.insert(EnemyList,j,TempList[i])
        table.insert(EnemyDistance,j,tempDistance)
        j = j + 1
      end
    end
  end

  return EnemyList,EnemyDistance
end

function slay:CalculateDistance(enemyPos,playerPos) --计算两个实体之间的距离
  local player = Isaac.GetPlayer(0)
  local pos = enemyPos - playerPos
  --类型为WorldToScreenPosition
  local x = pos.X
  local y = pos.Y
  local distance  = math.sqrt(x*x+y*y) --人物到怪物之间的距离
  return distance
end

function slay:addEffectData(name,entity) --增加特效
  local tempTable = {name = name;Scale = 0.7;timer = 50;entity = entity;color = 1}
  table.insert(effectData,clone(tempTable))
end

function slay:EffectRender() --显示在人物头上的特效
  local i = 0
  for k,v in pairs(effectData) do
    i=i+1
    if v.timer > 0 then
      local entityPos =  Game():GetRoom():WorldToScreenPosition(v.entity.Position)
      v.timer = v.timer - 1
      effect.Scale = Vector(v.Scale,v.Scale)
      v.Scale = v.Scale + 0.004
      v.color = v.color - 0.015
      effect.Color = Color(1,1,1,v.color,0,0,0)
      effect:SetFrame(v.name,0)
      effect:Render(entityPos+Vector(-2.5,-20),Vector(0,0),Vector(0,0))
    else
      table.remove(effectData,i)
    end
  end
end



function slay:DebugRender() --Debug
  local room = Game():GetRoom()
  local EntityList = Isaac.GetRoomEntities()  --该房间当前实体table
  local EnemyList,DistanceList = slay:CountRoomIsVulnerableEnemy(EntityList)
  local SortEnemyList = slay:SortEnemyList(EnemyList,DistanceList)
  local player = Isaac.GetPlayer(0)
  local pos1 = room:WorldToScreenPosition(player.Position)
  local mpos = room:WorldToScreenPosition(Input.GetMousePosition(true))
  local RD = Isaac.WorldToRenderPosition(Vector(320,280)) * 2
  local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))
    --怪物BUFF
    local atkNum = attackNum
  if player:GetPlayerType() == IroncladID then
    --人物BUFF
    powerNum = 0
    powerNum2 = 0
      for i =1,#playerPower do
        if playerPower[i].visible ~= false then
            powerNum2 = powerNum2 +1

        end
      end

    for i =1,#playerPower do
      if playerPower[i].visible ~= false then
         pos = room:WorldToScreenPosition(player.Position)
         power:Play(playerPower[i].name)
         power:Render(Vector(pos.X-16+14*powerNum-powerNum2*5,pos.Y+7), Vector(0,0), Vector(0,0)) --人物BUFF显示的位置调整
         if playerPower[i].value ~= "X" then
           Isaac.RenderScaledText(tostring(playerPower[i].value),pos.X-13+14*powerNum-powerNum2*5,pos.Y+8,0.5,0.5,1,1,1,1)
         end
         powerNum = powerNum + 1
      end
    end
    if #SortEnemyList ~= 0 then
      if atkNum > #SortEnemyList then
        atkNum = #SortEnemyList
      end
      for i = 1,atkNum do
        pos = room:WorldToScreenPosition(SortEnemyList[i].Position)
          power:Play("sword")
          power:Render(pos+Vector(0,-50), Vector(0,0), Vector(0,0))
      end
    end

        if CultistMask.play  then
          if CultistMask.timer >= 30 then
            kaka.Color = Color(1,1,1,(100-CultistMask.timer)/10,0,0,0)
          elseif CultistMask.timer <= 10 then
            kaka.Color = Color(1,1,1,CultistMask.timer/10,0,0,0)
          end
          kaka.Position = player.Position
          if  CultistMask.timer > 0 then
            CultistMask.timer = CultistMask.timer - 1
          else
            kaka:Remove()
          end
        end
        if monster ~= nil then
          if monsterBubble.play  then
            if monsterBubble.timer >= 30 then
              monster.Color = Color(1,1,1,(100-monsterBubble.timer)/10,0,0,0)
            elseif CultistMask.timer <= 10 then
              monster.Color = Color(1,1,1,monsterBubble.timer/10,0,0,0)
            end
            monster.Position = RD+Vector(-monsterPos_X,-100) + Vector(50,130)
            if  monsterBubble.timer >= 0 then
              monsterBubble.timer = monsterBubble.timer - 1
            else
                monsterBubble.play = false
                monsterBubble.Tigger = false
                monsterBubble.timer = 0
                monster:Remove()
            end
          end
        end
         Isaac.RenderText("Personal Website:https://space.bilibili.com/206654168",1493,250 , 1, 1, 1, 1)
          
          -----------显示牌堆内容--------------------
         --Isaac.RenderText("ChooseCardsInfo:",50,130 , 1, 1, 1, 1)
          --[[for i = 1 ,#ChooseCardsInfo do
            Isaac.RenderText(tostring(i)..ChooseCardsInfo[i].name,50,130+i*10 , 1, 1, 1, 1)
          end
           
          Isaac.RenderText("Hand:",140,130 , 1, 1, 1, 1)
          for i = 1 ,#Card_Hand do
            Isaac.RenderText(tostring(i)..Card_Hand[i].name,140,130+i*10 , 1, 1, 1, 1)
          end

          Isaac.RenderText("Discard:",210,130 , 1, 1, 1, 1)
          for i = 1 ,#Card_Discard do
            Isaac.RenderText(tostring(i)..Card_Discard[i].name,210,130+i*10 , 1, 1, 1, 1)
          end--]]
          -----------显示牌堆内容--------------------

          -----------显示人物攻击范围--------------------
          --[[
          Isaac.RenderText("1",pos1.X + attackRange,pos1.Y, 1, 1, 1, 1)
          Isaac.RenderText("2",pos1.X - attackRange,pos1.Y, 1, 1, 1, 1)
          Isaac.RenderText("3",pos1.X,pos1.Y- attackRange, 1, 1, 1, 1)
          Isaac.RenderText("4",pos1.X,pos1.Y+ attackRange, 1, 1, 1, 1)
          --]]

          local CircleScale = (attackRange-68.25)*0.004

          --[[更改边框透明度--]]--
          if CircleFrame.Visible or CircleFrame.Duration > 0 or maxCharge > playerMaxCharge then
              local alphy =  CircleFrame.Duration/30 -- 透明度
              if CircleFrame.Visible or maxCharge > playerMaxCharge then alphy = 1 end

            CircleFrameUi:SetFrame("Circle",0)
            CircleFrameUi.Scale = Vector(0.26+CircleScale,0.26+CircleScale)
            CircleFrameUi.Color = Color(1,1,1,alphy,0,0,0)
            CircleFrameUi:Render(pos1,Vector(0,0),Vector(0,0))
            CircleFrame.Duration = CircleFrame.Duration - 1

          end

          --[[更改边框透明度]]--

          -----------显示人物攻击范围--------------
          --[[HitBox位置变动--]]
          for i = 1,6 do
              HitBox[i].LU = Vector(MoveButton.LU.X+50+35*(i-1),MoveButton.LU.Y+0);
              HitBox[i].RD = Vector(MoveButton.LU.X+80+35*(i-1),MoveButton.LU.Y+45);
          end


          --[[抽牌堆和弃牌堆]]--
          if DropUiAnime.Drop ~=0 then
            DropUiAnime.DropFrame = 15-DropUiAnime.Drop
            DropUiAnime.Drop = DropUiAnime.Drop - 1
          else
            DropUiAnime.DropFrame =0
          end

          if DropUiAnime.Discard ~=0 then
            DropUiAnime.DiscardFrame = 15-DropUiAnime.Discard
            DropUiAnime.Discard = DropUiAnime.Discard - 1
          else
            DropUiAnime.DiscardFrame =0
          end

          DropUi:SetFrame("DropAnime",DropUiAnime.DropFrame)
          DropUi.Scale = Vector(0.25,0.25)
          DropUi:Render(Vector(17,RD.Y-15),Vector(0,0),Vector(0,0))
          DropUi:SetFrame("DiscardAnime",DropUiAnime.DiscardFrame)
          DropUi:Render(RD+Vector(-19,-15),Vector(0,0),Vector(0,0))
          if string.len(tostring(#Card_Draw)) == 1 then
            Isaac.RenderScaledText(tostring(#Card_Draw),25,RD.Y-17.3,1,1,0.8,1,1,1)
          else
            Isaac.RenderScaledText(tostring(#Card_Draw),22,RD.Y-17.3,1,1,0.8,1,1,1)
          end
          if string.len(tostring(#Card_Discard+DiscardTempCount)) == 1 then
            Isaac.RenderScaledText(tostring(#Card_Discard+DiscardTempCount),RD.X-30,RD.Y-17,1,1,0.8,1,1,1)
          else
            Isaac.RenderScaledText(tostring(#Card_Discard+DiscardTempCount),RD.X-32.3,RD.Y-17,1,1,0.8,1,1,1)
          end
          --Isaac.RenderScaledText(tostring(#Card_Discard),1,1,1,1,0.8,1,1,1)
          --DropUi:SetFrame("Discard",0)

          --[[抽牌堆和弃牌堆]]--

          --[[把当前手牌数据给卡槽数据]]--
          if not isHandCardToUi then
            CardEffectData.pain = false
            CardEffectData.decay = false
            for i=1,6 do
              if Card_Hand[i]~=nil then
                HitBox[i].card = clone(Card_Hand[i])
                if HitBox[i].card.name == "Pain" then --如果手牌中有疼痛则把这个变量变成true
                  if CardEffectData.pain == false then
                    CardEffectData.pain = true
                  end
                end
              else
                HitBox[i].card = nil
              end
            end
            isHandCardToUi = true
          end

          if CardEffectData.decay then
            CardEffectData.hasDecay = true
          else
            CardEffectData.hasDecay = false
          end

          if CardEffectData.pain then
            CardEffectData.hasPain = true
          else
            CardEffectData.hasPain = false
          end

          --[[把当前手牌数据给卡槽数据]]--
          
          CardUi.Scale = Vector(1,1)
          CardUi.Rotation = 0
        --[[显示卡牌 以及根据卡牌类型生成边框]]--
        for k,v in pairs(HitBox) do
          if v.card ~=nil and v.card.used == false then
            CardUi.Color = Color(1,1,1,1,0,0,0)
            for i = 1,#EntityList do
              if (EntityList[i].Type ~= 1000 and EntityList[i].Type ~= 6618  and slay:IsEntityOnHitBox(EntityList[i],v.LU,v.RD)) or  slay:IsEntityOnHitBox(player,v.LU,v.RD) then
                CardUi.Color = Color(1,1,1,0.2,0,0,0)
              end
            end
            CardUi:SetFrame(v.card.name,0)
            CardUi:Render(v.LU+Vector(15.9,21),Vector(0,0),Vector(0,0))
            Isaac.RenderScaledText(tostring(v.id),v.LU.X+14,v.LU.Y+45,1,1,0.8,1,1,1)
           if slay:IsMouseOnHitBox(v.LU,v.RD) then
             if not v.mouseIsOver then
               v.mouseIsOver = true
               SFXManager():Play(sound.selectCard,2,0,false,1.0)
             end
             chooseCardId = v.id
             if v.card.cardType == "attack" then
                CardFrame:SetFrame("Attack",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              elseif v.card.cardType == "skill" then
                CardFrame:SetFrame("Skill",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              elseif v.card.cardType == "curse" or v.card.cardType == "status" then
                CardFrame:SetFrame("Curse",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              else
                CardFrame:SetFrame("Power",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              end
              if Input.IsMouseBtnPressed(1) and not Input.IsMouseBtnPressed(0) and not Game():IsPaused() and player.ControlsEnabled and CanDrawCard and DiscardToDropAnimeTableDataIsSet then
                if notPress then slay:UseCard(chooseCardId) end
                notPress = false
              else
                notPress = true
              end
              v.HitBoxStayTime = v.HitBoxStayTime + 1
              if v.HitBoxStayTime >=50 and v.card~=nil and room:IsClear() then
                CardUi:SetFrame(v.card.name,1)
                CardUi:Render(Vector(170,20),Vector(0,0),Vector(0,0))
              end
            else
              v.mouseIsOver = false
              v.HitBoxStayTime = 0
            end
          end
        end
        --[[显示卡牌 以及根据卡牌类型生成边框]]--

        --[[旋转计时器以及无能量时让能量显示器变灰色]]--
        if cost ~= 0 then
          if PowerFrameTime.inside1Time ~=360 then
            PowerFrameTime.inside1Time = PowerFrameTime.inside1Time +0.5
          else
            PowerFrameTime.inside1Time = 0
          end
          if PowerFrameTime.inside2Time ~=0 then
            PowerFrameTime.inside2Time = PowerFrameTime.inside2Time -0.5
          else
            PowerFrameTime.inside2Time = 360
          end
            PowerFrame.Color = Color(1,1,1,1,0,0,0)
        else
            PowerFrame.Color = Color(0.5,0.5,0.5,1,0,0,0)
        end
        --[[旋转计时器以及无能量时让能量显示器变灰色]]--

        --[[生成能量显示器  Rotation是为了旋转特效]]--
        PowerFrame.Rotation = 0
        PowerFrame:SetFrame("ouside2",0)
        PowerFrame:Render(MoveButton.LU+Vector(20,20),Vector(0,0),Vector(0,0))

        PowerFrame.Rotation = PowerFrameTime.inside2Time
        PowerFrame:SetFrame("inside1",0)
        PowerFrame:Render(MoveButton.LU+Vector(20,20),Vector(0,0),Vector(0,0))

        PowerFrame.Rotation = PowerFrameTime.inside1Time
        PowerFrame:SetFrame("inside2",0)
        PowerFrame:Render(MoveButton.LU+Vector(20,20),Vector(0,0),Vector(0,0))

        PowerFrame.Rotation = 0
        PowerFrame:SetFrame("outside1",0)
        PowerFrame:Render(MoveButton.LU+Vector(20,20),Vector(0,0),Vector(0,0))
        --[[生成能量显示器--]]

        --[[能量显示按住之后跟着鼠标移动--]]
        if Input.IsMouseBtnPressed(0) and slay:IsMouseOnHitBox(MoveButton.LU,MoveButton.RD) then
          if tempMousePos ~= mpos then
          MoveButton.LU =MoveButton.LU + (mpos - tempMousePos)
          MoveButton.RD =  MoveButton.LU + Vector(40,37)
          tempMousePos = mpos
          end
        elseif  slay:IsMouseOnHitBox(MoveButton.LU,MoveButton.RD) then
          tempMousePos = mpos
        end
        --[[能量显示按住之后跟着鼠标移动--]]

        --生成能量当前数值
        Isaac.RenderScaledText(tostring(cost).."/"..tostring(maxCost),MoveButton.LU.X+11,MoveButton.LU.Y+13,1,1,0.8,1,1,1)

        --[[鼠标指针更改]]--
      if not Input.IsMouseBtnPressed(0) then 
        --没按下鼠标的时候
        if not isSpecialAtk then
            ui:SetFrame("MouseRelese",0)
            ui:Render(mpos,Vector(0,0),Vector(0,0))
          --[[触发消失动画]]--
          if ChargeBar.putDown and ChargeBar.DisappearTimer ~= 6 then
            --没按下鼠标后并且触发了消失动画
            ChargerBarUi:SetFrame("Disappear",ChargeBar.DisappearTimer)
            ChargerBarUi:Render(mpos + Vector(17,10),Vector(0,0),Vector(0,0))
            ChargeBar.DisappearTimer = ChargeBar.DisappearTimer + 1
          elseif ChargeBar.DisappearTimer == 6 then
            ChargeBar.DisappearTimer = 0
            ChargeBar.putDown = false
          end
        else
          ui:SetFrame("Special",0)
          ui:Render(mpos,Vector(0,0),Vector(0,0))
        end
        --[[触发消失动画]]--
      else
        --按下后
        if not isSpecialAtk  then
          ui:SetFrame("MouseRelese",1)
          ui:Render(mpos,Vector(0,0),Vector(0,0))
          if player.ControlsEnabled and not Game():IsPaused() then
            if not (maxCharge > playerMaxCharge) and playerMaxCharge~=0  then
              --充能没满的时候
              ChargerBarUi:SetFrame("Charging",math.ceil(100*(maxCharge/(playerMaxCharge))))
              ChargerBarUi:Render(mpos + Vector(17,10),Vector(0,0),Vector(0,0))
            else
              --充能满的时候
              ChargerBarUi:SetFrame("Charged",math.ceil(ChargeBar.finishedTimer/2))
              if ChargeBar.finishedTimer ~=10 then
                ChargeBar.finishedTimer = ChargeBar.finishedTimer+1
              else
                ChargeBar.finishedTimer = 0
              end
              ChargerBarUi:Render(mpos + Vector(17,10),Vector(0,0),Vector(0,0))
            end
          end
        else
          ui:SetFrame("Special",1)
          ui:Render(mpos,Vector(0,0),Vector(0,0))
        end
      end

      --[[消耗卡牌的卡牌透明度改变]]--
      local i = 0
      for k,v in pairs(ExhaustCardData) do
        i = i + 1
        if v.pos == nil then
          v.pos = HitBox[v.num].LU
        end
        if v.Color == nil then
          v.Color = 1
        end
        v.Color = v.overTimer / 80
        if v.overTimer > 0 then
          CardUi:SetFrame(v.name,0)
          CardUi.Color = Color(1,1,1,v.Color,0,0,0)
          CardUi:Render(v.pos + Vector(15.9,21),Vector(0,0),Vector(0,0))
          v.overTimer = v.overTimer - 1
        else
          table.remove(ExhaustCardData,i)
        end
      end
      --[[消耗卡牌的卡牌透明度改变]]--

      --[[消耗卡牌的烟雾特效]]--
       i = 0
       for k,v in pairs(ExhaustData) do
         i=i+1
         if v.startTimer>0 then
           v.startTimer = v.startTimer - 1
         else
           if v.overTimer > 0 then
            if v.pos == nil then
               v.pos =  HitBox[v.num].LU + Vector(math.random(3,27),math.random(5,40))
            end
            if v.Scale < 0.35 then
              v.Scale = v.Scale + 0.02
            end
            v.upPos = v.upPos + 0.2
            if v.overTimer <= 25 then
              v.Color = v.Color - 0.04
            end
            smokeUi:SetFrame(v.id,0)
            smokeUi.Scale = Vector(v.Scale,v.Scale)
            smokeUi.Color = Color(1,1,1,v.Color,0,0,0)
            smokeUi:Render(v.pos - Vector(0,v.upPos),Vector(0,0),Vector(0,0))
            v.overTimer = v.overTimer - 1
           end
         end
       end
      --[[消耗卡牌的烟雾特效]]--
      CardUi.Color = Color(1,1,1,1,0,0,0)
      --[[清除Table里的元素]]--
     local isAllTrigger = true
        for k,v in pairs(ExhaustData) do
          if v.overTimer ~= 0 then
            isAllTrigger = false
            break
          end
        end
        if isAllTrigger then
          ExhaustData = {}
        end
      --[[清除Table里的元素]]--

      i = 0
      for k,v in pairs(CardToDiscardCardData) do
        i=i+1
        if v.pos == nil then
          v.pos = HitBox[v.id].LU
        end
         if v.startTimer > 0 then
           v.Scale = 1.3 - v.startTimer*0.03
           v.startTimer = v.startTimer - 1
           v.upPos = (v.startTimer-10)*2
         else
           if v.rotTimer > 0 then

               v.rot =  130 - v.rotTimer*13
               v.upPos = -20+(v.rotTimer-10)*2
               v.rotTimer = v.rotTimer-1
           else
            local dis = slay:CalculateDistance(v.pos,RD+Vector(0,v.id*2))
            if dis > 70 then
              v.nmsl = v.nmsl +1
              v.pos = v.pos - slay:CalculateVector(v.pos,RD+Vector(0,v.id*2))*(1+v.nmsl)
              if v.Scale >0.5 then
                v.Scale = v.Scale -0.1
              end
            else
              DropUiAnime.Discard = 15
              table.remove(CardToDiscardCardData,i)
            end
           end
         end
         if not v.used then
           CardUi:SetFrame(v.name,0)
           CardUi.Rotation = v.rot
           CardUi.Scale = Vector(v.Scale,v.Scale)
           CardUi:Render(v.pos+Vector(15.9,21)+Vector(0,v.upPos),Vector(0,0),Vector(0,0))
         end
      end

      for k,v in pairs(DropCardAnimeTableData) do
        --CardUi:SetFrame(v.card.name,0)

      end
      if tempDropCardVar >0 and discardToHandAnimeTimer ~= 50 then
        discardToHandAnimeTimer = 30
      end
      local DiscardToDropAnimeTableDataAllDelete = true

      if discardToHandAnimeTimer > 0 then
        i = 0
        for k,v in pairs(DiscardToDropAnimeTableData) do
          i = i + 1
          if v.startTimer >0 then
            v.startTimer = v.startTimer -1
          else
            if v.pos == nil then
              v.pos = RD+Vector(20,-30)
            end
            local temp = slay:CalculateDistance(v.pos,Vector(0,RD.Y))
            if temp > 129  then
              v.pos = v.pos - slay:CalculateVector(v.pos,Vector(10,RD.Y-30))*8
              DiscardToDropUi:SetFrame(v.id,0)
              DiscardToDropUi.Scale = Vector(0.1,0.1)
              DiscardToDropUi:Render(v.pos,Vector(0,0),Vector(0,0))
            else
              v.delete = true
            end
          end
        end
        discardToHandAnimeTimer = discardToHandAnimeTimer - 1
      end

      for k,v in pairs(DiscardToDropAnimeTableData) do
        if v.delete == false then
          DiscardToDropAnimeTableDataAllDelete = false
          break
        end
      end
      testVectorVar = DropUiAnime.Drop

      --准星
      if target then
        for i = 1,#EntityList do
          if EntityList[i]:IsVulnerableEnemy() then
            targetUi:SetFrame("Idle",0)
            targetUi.Scale = Vector(0.07,0.07)
            targetUi:Render(room:WorldToScreenPosition(EntityList[i].Position),Vector(0,0),Vector(0,0))
          end
        end
      end
      
      if DiscardToDropAnimeTableDataAllDelete and not DiscardToDropAnimeTableDataIsSet then
        DropUiAnime.Drop = 15
        slay:CardToDraw()
        tempFirstDropCardVar = #Card_Hand
        slay:CardToHandAnime(tempDropCardVar)
        tempDropCardVar = 0
        DiscardToDropAnimeTableDataIsSet = true
      end
      i=0
      CardUi.Rotation = 0
      for k ,v in pairs(DropCardAnimeTableData) do
        i = i + 1
          if v.pos == nil then
            v.pos = Vector(17,RD.Y-15)
          end
          if v.startTimer == nil then
            v.startTimer = i * 5
          end
          if v.Scale == nil then
            v.Scale = Vector(0,0)
          end
          if v.startTimer >0 then
            v.startTimer = v.startTimer -1
          else
            if v.card ~= nil then
              CardUi:SetFrame(v.card.name,0)
              CardUi.Scale = v.Scale
              if v.Scale.X < 1 then
                v.Scale = v.Scale + Vector(0.05,0.05)
              end
              CardUi:Render(v.pos,Vector(0,0),Vector(0,0))
              local tempDis = slay:CalculateDistance(v.pos,HitBox[i+tempFirstDropCardVar].LU+Vector(15.9,21))
              if tempDis > 8 then
                v.pos = v.pos - slay:CalculateVector(v.pos,HitBox[i+tempFirstDropCardVar].LU+Vector(15.9,21))*4
              else
                DropCardAnimeTempData = v.card
                slay:CardToHand()
                DropCardAnimeTableData[i].card = nil
              end
            end
          end
      end
      local IsDropCardAnimeTableDataClear = true
    for k ,v in pairs(DropCardAnimeTableData) do
      if v.card ~= nil then
        IsDropCardAnimeTableDataClear = false
      end
    end
    if IsDropCardAnimeTableDataClear then
      CanDrawCard = true
    else
      CanDrawCard = false
    end
    if #EntityList ~= 0 then
      for i =1, #EntityList do
        if EntityList[i]:GetData()["heavyatk"] == nil then
          EntityList[i]:GetData()["heavyatk"] = 0
        end
        if EntityList[i]:GetData()["heavyatk"] ~= 0 then--易伤效果
          pos = room:WorldToScreenPosition(EntityList[i].Position)
          power:Play("powers")
          power:Render(Vector(pos.X-10,pos.Y+7), Vector(0,0), Vector(0,0))
          Isaac.RenderScaledText(tostring(EntityList[i]:GetData()["heavyatk"]),pos.X-7,pos.Y+5,0.7,0.7,0.5,0.5,0.5,1)
        end
      end
    end
  end
end
function slay:AttackBack(repelNum) --击退
  local player = Isaac.GetPlayer(0)
  local EntityList = Isaac.GetRoomEntities()
  local EnemyList,EnemyDistanceList = slay:CountRoomIsVulnerableEnemy(EntityList) --判断
  local EnemySortList = slay:SortEnemyList(EnemyList,EnemyDistanceList)
  local atkNum = attackNum
  if #EnemySortList ~=0 then
    if atkNum > #EnemySortList then
      atkNum = #EnemySortList
    end
    for i = 1,atkNum do
      local pos = EnemySortList[i].Position
      local XPorN = slay:IsPositive(pos.X)
      local YPorN = slay:IsPositive(pos.Y)
      local backVector = slay:CalculateVector(EnemySortList[i].Position,player.Position)*repelNum --击退的方向
        --[//*如果是BOSS不触发击退*//]
        EnemySortList[i]:AddVelocity(backVector) --触发击退
    end
  end
end
function slay:IsPositive(num) --判断正负 正返回1 负返回-1
  local backNum --返回的数值
  if num >= 0 then backNum = 1
  else backNum = -1 end
  return backNum
end

function slay:PlayerToAttack()  --键盘控制打击
    local player = Isaac.GetPlayer(0)
    local tempRange = math.abs(player.TearHeight)
    local tempDamage = player.Damage
    local mpos = Input.GetMousePosition(true)
  if player:GetPlayerType() == IroncladID then
    playerMaxCharge = player.MaxFireDelay*maxChargeMulti
    if playerMaxCharge < 10 then
      playerMaxCharge = 10
    end

    if (Input.IsMouseBtnPressed(0)) then
      if not isSpecialAtk and player.ControlsEnabled then
        if maxCharge <= playerMaxCharge then
          maxCharge = maxCharge +1
          if player:HasCollectible(69) then    --巧克力奶 效果
            Chocolate.Range = maxCharge/playerMaxCharge * 40
            Chocolate.Damage = maxCharge/playerMaxCharge * 16
          end
        end
      else
        specialCharge = specialCharge + 1
      end

      pressDown = true
    else
      pressDown = false
      if player:HasCollectible(69) then  --清除巧克力奶的效果
        Chocolate.Range = 0
        Chocolate.Damage = 0
      end
    end

      if debug and (Input.IsMouseBtnPressed(2)) then
        player.Position = mpos
      end

      if player:HasCollectible(316) and maxCharge <= playerMaxCharge then
        attackNum = attackNum + math.floor(maxCharge/playerMaxCharge * 4)
      elseif player:HasCollectible(316) and maxCharge > playerMaxCharge then
        attackNum = attackNum + math.floor(maxCharge/playerMaxCharge * 1)
      end
      if  player.ControlsEnabled then
        if maxCharge>0 and not pressDown and maxCharge <= playerMaxCharge and cost >= 1 then  --发动普通攻击
          slay:NormalAttack(atkType)    --触发普通攻击
          cost = cost - normalCost      --减少能耗
          maxCharge = 0                 --最大充能减少
          swing = true                  --旋转吧！
          swingNum = 15                 --触发动画效果
          CircleFrame.Visible = false--关闭范围指示器
        elseif maxCharge > playerMaxCharge and not pressDown then --发动蓄力攻击
          slay:NormalAttack(heavyAtkType)--触发重击
          cost = cost - heavyCost       --减少能耗
          maxCharge = 0                 --最大充能减少
          swing = true                  --旋转吧！
          swingNum = 15                 --触发动画效果
          CircleFrame.Visible = false--关闭范围指示器
        elseif cost == 0 and not pressDown and maxCharge>0 then --没有蓄力时
          maxCharge = 0
        end
        if specialCharge > 0 and not pressDown then --特殊攻击//用卡牌
          slay:NormalAttack(specialType) --特殊攻击
          extraAttackNum = 0 --额外的攻击数量
          isSpecialAtk = false --是否为特殊攻击改为false
          swing = true               --旋转
          swingNum = 15                --旋转
          specialCharge = 0           --特殊攻击充能改为0
          isRangeAttack = false      --是否为范围攻击改成false
          CircleFrame.Visible = false--关闭范围指示器
        end
      end
      if swingNum > 0 then
        swingNum = swingNum -1
      end
    end
end


function slay:FireBrimstone(Timeout,ememypos,damage)--发射硫磺火
    local player = Isaac.GetPlayer(0)
    local bri = Isaac.Spawn(1000,113,0,ememypos-Vector(0,-5),(player.Velocity/3 + slay:CalculateVector(ememypos,player.Position))*3,player)
    bri = bri:ToEffect()
    bri.Timeout = Timeout
    bri.CollisionDamage = damage
    SFXManager():Play(7,1,0,false,1.0)
end

function slay:ExhaustCard(name)--消耗卡牌

  for i = 1,15 do
    local tempTable2 = {id=tostring(math.random(1,37));startTimer = math.random(1,30);overTimer = 100;num = chooseCardId;Scale = 0;Color=1;upPos=0; }
    table.insert(ExhaustData,tempTable2)
  end
  local tempTable = {}
  tempTable = {name = cardName;overTimer = 75;num = chooseCardId; }
  table.insert(ExhaustCardData,clone(tempTable))
  SFXManager():Play(sound.exhaust,2,0,false,1.0)
end



function slay:UseCard()--使用卡牌
  
  local card = HitBox[chooseCardId].card
  local cardType = card.cardType
  local isExhaust = card.exhaust
  local player = Isaac.GetPlayer(0)
  cardName = card.name
  if cost  >= card.cost and not isSpecialAtk then
    if CardEffectData.pain == true then
      player:AddHearts(-1)
      Isaac.Spawn(1000, 2, 0, player.Position + Vector(0,5) , Vector(0,0), player)
    end
    local cardFunction = CardEffect[card.name]
    if cardFunction then
      local tempResult = cardFunction()
    end
    cost = cost - card.cost
    if isExhaust then
      slay.ExhaustCard(cardName)
      HitBox[chooseCardId].card = nil
      Card_Hand[chooseCardId].used = true
    else
      if cardType == "curse" or cardType == "status" then
        --CardToDiscard(false,chooseCard) 废弃的代码 不要用！
        SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ ,1,0,false,1.0)
      elseif cardType =="skill" then
        slay.CardToDiscardAnime()
        HitBox[chooseCardId].card = nil
        DiscardTempCount = DiscardTempCount + 1
        SFXManager():Play(sound.cardSelect,2,0,false,1.0) --播放音效
        Card_Hand[chooseCardId].used = true
      elseif cardType == "attack" then
        slay.CardToDiscardAnime()
        HitBox[chooseCardId].card = nil
        DiscardTempCount = DiscardTempCount + 1
        SFXManager():Play(sound.cardSelect,2,0,false,1.0)
        CircleFrame.Visible = true
        Card_Hand[chooseCardId].used = true
      end
    end
    isHandCardToUi = true
  else

  end
end

function slay:GainCard(card,timer)--获得卡牌
  if timer == nil then timer = 10 end
  local tempTable = {card = clone(card);pos=nil;rot = 0;speed = 1;scale = 1;color = 1;timer = timer;stoptimer = 20;}
  table.insert(CardToDrawAnime,clone(tempTable))
  SFXManager():Play(sound.cardSelect,2,0,false,1.0)
  ChooseCardsInfo = {}
end
function slay:GainCardRender() --获得卡牌显示特效
  local player = Isaac.GetPlayer(0)
  local num = #CardToDrawAnime
  local drawCardPos = Isaac.WorldToRenderPosition(Vector(0,480)) + Vector(-30,0)
  if num ~= 0 then
    local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))
    local unitVector = Vector(70,0)
    local FirstVector = screenCenter - unitVector*((num-1)/2)
    local i = 0
    CardUi.Color = Color(1,1,1,1,0,0,0)
    CardUi.Scale = Vector(1,1)
    CardUi.Rotation = 0
    for k ,v in pairs(CardToDrawAnime) do
      i = i +1
      if v.pos == nil then
        v.pos = FirstVector + unitVector*(i-1) + Vector(0,-50)
      end
      CardUi.Scale = Vector(v.scale,v.scale)
      CardUi.Rotation = v.rot
      CardUi:SetFrame(v.card.name,0)
      CardUi:Render(v.pos,Vector(0,0),Vector(0,0))
      if  v.timer > 0 then
        if v.scale < 2 then
          v.scale = v.scale + 0.1
        end
        v.timer = v.timer - 1
      else
        if v.stoptimer <0 then
          if v.rot > -120 then
            v.rot = v.rot - 20
          end
          if slay:CalculateDistance(drawCardPos,v.pos) > 10 then
            v.pos = v.pos - slay:CalculateVector(v.pos,drawCardPos)*( 2 + v.speed)
            if v.scale > 0.2 then
              v.scale = v.scale - 0.09
            end
            v.speed = v.speed + 0.4
          else
            table.insert(Card_Draw,clone(v.card))
            table.remove(CardToDrawAnime,i)
            player.ControlsEnabled = true
            DropUiAnime.Drop = 15

          end
        else
          v.stoptimer = v.stoptimer - 1
        end
      end
    end
  end
end
function slay:BuyItemRender()
  local player = Isaac.GetPlayer(0)
  local room = Game():GetRoom()
  if not getItemName  then
    math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
    local rnd = math.random(29)
    local i = 0
    for k ,v in pairs(Item) do
      i = i + 1
      if i == rnd then
        buyItemName = {name = k;func = v;}
        getItemName = true
        break
      end
    end
  end
  if not isBuyingItem then
    local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))
    local buyButton = {Center = screenCenter - Vector(50,-40);LU = screenCenter - Vector(85,-25) ;RD = screenCenter - Vector(15,-55) }
    local cencelButton = {Center = screenCenter + Vector(50,42);LU = screenCenter + Vector(15,33) ;RD = screenCenter + Vector(85,57) }
    local itemButton = screenCenter - Vector(0,40)
    if buyItemName.name == nil then  end
    ShopUi:SetFrame(buyItemName.name,0)
    ShopUi:Render(itemButton,Vector(0,0),Vector(0,0))
    
    gainUi.Scale = Vector(0.3,0.3)
    if slay:IsMouseOnHitBox(buyButton.LU,buyButton.RD) then
      gainUi:SetFrame("buyOn",0)
      if not  buyButtonSfx then
        SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS,3,0,false,1.0)
        buyButtonSfx = true
      end
      if  Input.IsMouseBtnPressed(1) then
        if player:GetNumCoins() >=30 then
          Isaac.Spawn(5,100,buyItemName.func,room:GetGridPosition(67),Vector(0,0), nil) --生成道具
          player:AddCoins(-30)
        else
          player:AnimateSad()
        end
        isBuyingItem = true
        
        SFXManager():Play(sound.mouseClick,5,0,false,1.0)
      end
    else
      buyButtonSfx = false
      gainUi:SetFrame("buyOff",0)
    end
    gainUi:Render(buyButton.Center,Vector(0,0),Vector(0,0))
    
    if slay:IsMouseOnHitBox(cencelButton.LU,cencelButton.RD) then
      if  Input.IsMouseBtnPressed(1) then
        isBuyingItem = true
        SFXManager():Play(sound.mouseClick,5,0,false,1.0)
      end
      gainUi:SetFrame("buttonOn",0)
      if not  buyCancelButtonSfx then
        SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS,3,0,false,1.0)
        buyCancelButtonSfx = true
      end
    else
      buyCancelButtonSfx = false
      gainUi:SetFrame("buttonOff",0)
    end
    
    gainUi:Render(cencelButton.Center,Vector(0,0),Vector(0,0))
    gainUi:SetFrame("topShop",0)
    gainUi:Render(screenCenter - Vector(0,100),Vector(0,0),Vector(0,0))
    gainUi:SetFrame("coins",0)
    gainUi:Render(screenCenter+Vector(0,10),Vector(0,0),Vector(0,0))
  end
end

function slay:ChooseCardUiRender()--选择卡牌显示特效
  local num = #ChooseCardsInfo
  local player = Isaac.GetPlayer(0)
  if num ~=0 then
    local screenCenter = Isaac.WorldToRenderPosition(Vector(320,280))
    local unitVector = Vector(50,0)
    local FirstVector = screenCenter - unitVector*((num-1)/2)
    local buttonLU = screenCenter + Vector(-35,-15)
    local buttonRD = screenCenter - Vector(-35,-15)
    i= 0
    gainUi:SetFrame("top",0)
    gainUi.Scale = Vector(0.4,0.4)
    gainUi:Render(screenCenter+Vector(0,-100),Vector(0,0),Vector(0,0))
    gainUi.Scale = Vector(0.3,0.3)
    if not slay:IsMouseOnHitBox(buttonLU,buttonRD) then
      gainUi:SetFrame("buttonOff",0)
      cancelButton = false
    else
      if not  cancelButton then
        SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS,3,0,false,1.0)
        cancelButton = true
      end
      gainUi:SetFrame("buttonOn",0)
      if Input.IsMouseBtnPressed(1) then
        ChooseCardsInfo = {}
        player.ControlsEnabled = true
        for k,v in pairs(ChooseCardHitBox) do
          v.card = nil
        end
      end
    end
    gainUi:Render(screenCenter,Vector(0,0),Vector(0,0))
    for k,v in pairs(ChooseCardsInfo) do
      i =i+1
      ChooseCardHitBox[i].card = v
      ChooseCardHitBox[i].LU = FirstVector + unitVector*(i-1) - Vector(15,22.5) + Vector(0,-50)
      ChooseCardHitBox[i].RD = FirstVector + unitVector*(i-1) + Vector(15,22.5) + Vector(0,-50)
    end

            --[[把当前手牌数据给卡槽数据]]--
          CardUi.Color = Color(1,1,1,1,0,0,0)
          CardUi.Scale = Vector(1,1)
          CardUi.Rotation = 0
        --[[显示卡牌 以及根据卡牌类型生成边框]]--
        for k,v in pairs(ChooseCardHitBox) do
          if v.card ~=nil then
            if v.HitBoxStayTime == nil then
              v.HitBoxStayTime = 0
            end

            CardUi:SetFrame(v.card.name,0)
            CardUi:Render(v.LU+Vector(15.9,21),Vector(0,0),Vector(0,0))
          if slay:IsMouseOnHitBox(v.LU,v.RD) then
            if not v.mouseIsOver then
              v.mouseIsOver = true
              SFXManager():Play(sound.selectCard,2,0,false,1.0)
            end
             if v.card.cardType == "attack" then
                CardFrame:SetFrame("Attack",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              elseif v.card.cardType == "skill" then
                CardFrame:SetFrame("Skill",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              elseif v.card.cardType == "curse" or v.card.cardType == "status" then
                CardFrame:SetFrame("Curse",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              else
                CardFrame:SetFrame("Power",0)
                CardFrame:Render(v.LU,Vector(0,0),Vector(0,0))
              end
              if Input.IsMouseBtnPressed(1) and not Input.IsMouseBtnPressed(0) then
                if notPress then
                  slay:GainCard(clone(v.card))
                  for k,v in pairs(ChooseCardHitBox) do
                    v.card = nil
                  end
                end
                notPress = false
              else
                notPress = true
              end
              v.HitBoxStayTime = v.HitBoxStayTime + 1
            else
              v.HitBoxStayTime = 0
              v.mouseIsOver = false
            end
          end
        end

        for k,v in pairs(ChooseCardHitBox) do
          if v.HitBoxStayTime ~=nil then
            if v.HitBoxStayTime >=25 and v.card~=nil then
              CardUi:SetFrame(v.card.name,1)
              CardUi:Render(v.LU + Vector(30,-45),Vector(0,0),Vector(0,0))
            end
          end
        end
        --[[显示卡牌 以及根据卡牌类型生成边框]]--
  end
end


function slay:ChooseCardUi(num,roomType) --选择卡牌
    local easyCard,normalCard,hardCard,colorCard = {},{},{},{}
    local player = Isaac.GetPlayer(0)
    player.ControlsEnabled = false
    for k ,v in pairs(Card_Type) do
      if v.rarity == "easy" then
        table.insert(easyCard,clone(v))
      elseif v.rarity == "normal" then
        table.insert(normalCard,clone(v))
      elseif v.rarity == "hard" then
        table.insert(hardCard,clone(v))
      elseif v.rarity == "colorless" then
        table.insert(colorCard,clone(v))
      end
    end

    math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
    local easy,normal,hard,colorless = 0,0,0,0
    if roomType == "notBoss" then
      easy,normal,hard,colorless = 70,100,100,100
    elseif roomType == "boss" then
      easy,normal,hard = 0,80,100,100
    elseif roomType == "shop" then
      easy,normal,hard,colorless = 20,40,0,100
    elseif roomType == "treasure" then
      easy,normal,hard,colorless = 70,98,100,100
    elseif roomType == "secert" then
      easy,normal,hard,colorless = 40,100,100,100
    elseif roomType == "normal" then
      easy,normal,hard,colorless = 0,100,100,100
    end
    local tempTable = {}
    for i = 1,num do
      local rnd = math.random(100)
      if rnd < easy then
        tempTable = easyCard
      elseif rnd < normal then
        tempTable = normalCard
      elseif rnd < hard then
        tempTable = hardCard
      else
        tempTable = colorCard
      end
      local pos,v = slay:readRandomValueInTable(tempTable)
      table.insert(ChooseCardsInfo,clone(v))
      table.remove(tempTable,pos)
    end
end

function slay:CardToDiscardAnime() --卡牌进入弃牌堆动画
  local tempTable = {}
  SFXManager():Play(sound.cardSelect ,1,0,false,1.0)
  tempTable = {name = cardName;id = chooseCardId;Color = 1;rot = 0;pos = nil;startTimer = 10;rotTimer = 10;Sacal = 1;upPos = 0;nmsl = 0}
  table.insert(CardToDiscardCardData,clone(tempTable))
end

function slay:IsMouseOnHitBox(LU,RD) --鼠标是否在某个方块中
  local room = Game():GetRoom()
  local mousePos = room:WorldToScreenPosition(Input.GetMousePosition(true))
  if mousePos.X >= LU.X and mousePos.Y >= LU.Y and mousePos.X <= RD.X and mousePos.Y <= RD.Y then
    return true
  else
    return false
  end
end

function slay:IsEntityOnHitBox(entity,LU,RD) --实体是否在某个方块中
  local room = Game():GetRoom()
  local entityPos = room:WorldToScreenPosition(entity.Position)
  if entityPos.X >= LU.X and entityPos.Y >= LU.Y and entityPos.X <= RD.X and entityPos.Y <= RD.Y then
    return true
  else
    return false
  end
end

function slay:HeavyAtk(entity)--是否有易伤并减少易伤值
  if entity:GetData()["heavyatk"]~=nil then
    if entity:GetData()["heavyatk"] > 0 then
      entity:GetData()["heavyatk"] = entity:GetData()["heavyatk"] - 1
      return heavyAtkMulti --附带易伤
    else
      return 1 --如果附带了易伤但是小于1
    end
  else
    return 1 --如果没有附带易伤
  end
end
function slay:CalculateVector(pos1,pos2) --计算两个实体的Vector
  local vecX = pos1.X - pos2.X
  local vecY = pos1.Y - pos2.Y
  local vecTemp = nil
  if math.abs(vecX)>math.abs(vecY) then
    vecTemp = math.abs(vecX)
  else
    vecTemp = math.abs(vecY)
  end
  return Vector(vecX/vecTemp,vecY/vecTemp)
end

function slay:AddAtkNum(ItemID,atkNum) --判断增加攻击次数的一个小函数
  local player = Isaac.GetPlayer(0)
  local result = player:GetCollectibleNum(ItemID)
  return result * atkNum
end

function slay:spikeAtk(enemy,damage)--刺穿攻击 道具协同：例如 穿透眼泪 大眼等
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    local EntityList = Isaac.GetRoomEntities()
    local enemyPos1 = room:WorldToScreenPosition(enemy.Position)  --获得被攻击的怪物的位置
    local tempDistance,enemyPos2 --两者的距离和 另外一只的位置信息
    for i = 1,#EntityList do
      if EntityList[i]:IsVulnerableEnemy() then
        enemyPos2 = room:WorldToScreenPosition(EntityList[i].Position)
        tempDistance = slay:CalculateDistance(enemyPos1,enemyPos2) --获得两者的距离
        if tempDistance < spikeDistance and tempDistance ~= 0 then  --如果距离大于50 并且不是自身
          EntityList[i]:TakeDamage(damage*slay:HeavyAtk(EntityList[i]),DamageFlag.DAMAGE_LASER,EntityRef(player),10) --攻击
        end
      end
    end
end



function slay:readRandomValueInTable(Table)--随机从table中取一个元素
    math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
    local tmpKeyT={}
    local n=1
    for k in pairs(Table) do
        tmpKeyT[n]=k
        n=n+1
    end
    local num = math.random(1,n-1)
    return num,Table[tmpKeyT[num]]
    --第一个值：数组中的第几位元素 第二个值：元素
end


function clone(org) --克隆而不引用
    local function copy(org, res)
        for k,v in pairs(org) do
            if type(v) ~= "table" then
                res[k] = v;
            else
                res[k] = {};
                copy(v, res[k])
            end
        end
    end

    local res = {}
    copy(org, res)
    return res
end
function isInArray(t, val)
	for _, v in ipairs(t) do
		if v == val then
			return true
		end
	end
	return false
end
function getRandom(num)--num是百分之几的意思 30%就传入getRandom(30)
  math.randomseed(tonumber(tostring(Game():GetFrameCount()):reverse())+math.random(1,2000))
  local rnd = math.random(100)
    return rnd <=num
  end
function slay:CardAddToDraw(cardType,num) --新增加到牌库
  for i = 1,num do
    table.insert(Card_Draw,clone(Card_Type[cardType]))
  end
end

function slay:CardToHand() --抽牌

  table.insert(Card_Hand,clone(DropCardAnimeTempData)) --拷贝到手牌数组
  isHandCardToUi = false
end

 function slay:CardToHandAnime(num)--抽卡动画
  DropCardAnimeTableData = {
  [1] = {pos = nil;card = nil};
  [2] = {pos = nil;card = nil};
  [3] = {pos = nil;card = nil};
  [4] = {pos = nil;card = nil};
  [5] = {pos = nil;card = nil};
  [6] = {pos = nil;card = nil};

  }
  if num > #Card_Draw then
    tempDropCardVar = num - #Card_Draw
    num = #Card_Draw
    DiscardToDropAnimeTableDataIsSet = false
     DiscardToDropAnimeTableData = {
        [1] = {id="1";pos = nil;startTimer = 0;delete = false};
        [2] = {id="2";pos = nil;startTimer = 3;delete = false};
        [3] = {id="3";pos = nil;startTimer = 7;delete = false};
        [4] = {id="4";pos = nil;startTimer = 14;delete = false};
        }

  end

  for i = 1,num do
    local rnd,tempTable = slay:readRandomValueInTable(Card_Draw) --随机从抽牌堆数组取一张牌
    DropCardAnimeTableData[i].card = clone(tempTable) --拷贝到手牌数组
    table.remove(Card_Draw,rnd) --删除抽牌堆中的卡牌
  end
end

function slay:CardToDiscard(isAll,cardPosition) --把手牌移入弃牌堆 isAll：是否把手牌全部推入弃牌堆 cardPosition：卡牌在table中的位置
  local player = Isaac.GetPlayer(0)
  local damageTime = 0
  local burnTime = 0
  --[[计算手牌中的灼烧和腐朽的值]]--
  for i = #Card_Hand,1 ,-1 do
    if Card_Hand[i].used == false then
      damageTime = damageTime + 1
    end
    if Card_Hand[i].name == "Burn" then
      burnTime = burnTime + 1
    end
  end
  --[[计算手牌中的灼烧和腐朽的值]]--

  --[[给予灼烧伤害]]--
  if playerPower[1].value > 1  and burnTime > 0 then
    if playerPower[1].value > burnTime then
      playerPower[1].value = playerPower[1].value - burnTime
      burnTime = 0
    else
      burnTime = burnTime -  playerPower[1].value + 1
      playerPower[1].value = 1
    end
    SFXManager():Play(sound.defenseBreak,2,0,false,1.0)
    slay:spawnSwordAir(player,2)
  end
  for i=1,burnTime do
    Isaac.Spawn(1000, 2, 0, player.Position + Vector(0,5) , Vector(0,0), player)
    player:TakeDamage(1,DamageFlag.DAMAGE_IV_BAG,EntityRef(player),10)
    player:ResetDamageCooldown()
  end
--[[给予灼烧伤害]]--

    if isAll then --把全部手牌推入弃牌堆
      for i = #Card_Hand,1 ,-1 do
        --[[给予腐朽伤害]]--
        if Card_Hand[i].name == "Decay" then
          if playerPower[1].value > 1 and damageTime > 0 then
            if playerPower[1].value > damageTime then
              playerPower[1].value = playerPower[1].value - damageTime
              damageTime = 0
            else
              damageTime = damageTime -  playerPower[1].value + 1
              playerPower[1].value = 1
            end
            SFXManager():Play(sound.defenseBreak,2,0,false,1.0)
            slay:spawnSwordAir(player,2)
          end
          for i=1,damageTime do
            player:TakeDamage(1,DamageFlag.DAMAGE_IV_BAG,EntityRef(player),10)
            player:ResetDamageCooldown()
            Isaac.Spawn(1000, 2, 0, player.Position + Vector(0,5) , Vector(0,0), player)
          end
          --[[给予腐朽伤害]]--
        end
        if  Card_Hand[i].exhaust and Card_Hand[i].used == true  then
          player:AddBombs(0)
        else
          table.insert(Card_Discard,clone(Card_Hand[i]))
        end
        table.remove(Card_Hand,i)
      end
    else --把单个手牌丢入弃牌堆
      table.insert(Card_Discard,clone(Card_Hand[cardPosition]))
      table.remove(Card_Hand,cardPosition)
    end
end

function slay:CardToDraw() --从弃牌堆把所有牌推入抽牌堆
  for i = #Card_Discard,1,-1 do
    Card_Discard[i].used = false
    table.insert(Card_Draw,clone(Card_Discard[i]))
    table.remove(Card_Discard,i)
  end
end

function slay:ChangeFromItems()  --攻击效果随着道具改变
  local player = Isaac.GetPlayer(0)
  local level = Game():GetLevel()

  itemEffect.poison = 0
  itemEffect.fear = 0
  itemEffect.slow= 0
  itemEffect.fire = 0
  local poison  = {player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO), player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD),
                 player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC), player:HasCollectible(CollectibleType.COLLECTIBLE_SERPENTS_KISS),
                 player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID)}
               
  local fear = {player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON), player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER),
                 player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME)}
  
  local slow ={player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR), player:HasCollectible(CollectibleType.COLLECTIBLE_JUICY_SACK),
                 player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE), player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID),
                 player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT)}
  
  local fire = player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND)
  
  
  for i = 1,#poison do
    if poison[i] then
      itemEffect.poison = itemEffect.poison + 20
    end
  end
  for i = 1,#fear do
    if fear[i] then
      itemEffect.fear = itemEffect.fear + 20
    end
  end
  for i = 1,#slow do
    if slow[i] then
      itemEffect.slow = itemEffect.slow + 20
    end
  end
  if fire then
    itemEffect.fire = 100
  end
  --攻击的个数随着道具的增减变化
   attackNum = 1
    
   attackNum = attackNum + slay:AddAtkNum(245,1) + slay:AddAtkNum(2,2)+ slay:AddAtkNum(153,3)+slay:AddAtkNum(358,1)
   --攻击的个数随着道具的增减变化
   if player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY) then --宝宝套
      attackNum =attackNum + 2
   end
   attackNum = attackNum + bookForm + monstro_lung + tearBlood + extraAttackNum + CardEffectData.PummelAtknum + CardEffectData.DoubleTap
   --有硫磺火则减少最大充能数
   maxChargeMulti = 3
   if player:HasCollectible(118) then
      maxChargeMulti = 2
   end
    --有硫磺火则减少最大充能数

    --设置攻击距离
   if maxCharge < playerMaxCharge then
     attackRange = math.abs(player.TearHeight)*3
   elseif attackRange<200 then
     if not player:HasCollectible(69) then
      attackRange = math.abs(player.TearHeight)*6 --蓄力攻击无限距离
      if attackRange < 110 then
        attackRange = 110
      end
    else
      attackRange = math.abs(player.TearHeight)*3
    end
   end

   if attackRange < 40 then
     attackRange = 40 --攻击距离不得低于60
   end
    --设置攻击距离

   --是否有穿透攻击穿透攻击
   airType = 1 --剑气的类型
   isSpike = false
   spikeDistance = 50
      if player:HasCollectible(237) or --镰刀
         player:HasCollectible(533) or --三圣颂
         player:HasCollectible(306) or --射手座
         player:HasCollectible(48)  or --丘比特
         player:HasCollectible(169) or --独眼巨人
         player:HasCollectible(462) or--贝利尔之眼
         player:HasCollectible(336) or --烂洋葱
         player:HasCollectible(462) or --寄生虫
         player:HasCollectible(224) or --狗身
         player:HasCollectible(531) or --泪血症
         player:HasCollectible(229) then --萌死戳的肺
          airType = 4
          isSpike = true
          if player:HasCollectible(169) or player:HasCollectible(533) then
            spikeDistance = spikeDistance + 10 --大眼 触发攻击范围+10
            airType = 3
          end
          if player:HasCollectible(237) then
            spikeDistance = spikeDistance + 10 --有镰刀 触发攻击范围+10
            airType = 3
          end
      end
    --是否有穿透攻击穿透攻击

    --  增加费用
    maxCost = 3 + Ironclad.cost
  if player:HasCollectible(Item.Dodecahedron) then--12面体
    if player:GetHearts() == player:GetMaxHearts() then
      maxCost = maxCost + 2
    end
  end
  if player:HasCollectible(Item.Ectoplasm) then
    maxCost = maxCost + 2
  end
  if player:HasCollectible(Item.Sozu) then
    maxCost = maxCost + 2
  end
  if player:HasCollectible(Item.CursedKey) then
    maxCost = maxCost + 2
  end
  Player_Card.cardNum = 2--选牌数量
  if player:HasCollectible(Item.crown) then
    maxCost = maxCost + 2
    Player_Card.cardNum = Player_Card.cardNum - 1
  end
  if player:HasCollectible(Item.QuestionCard) then
      Player_Card.cardNum = Player_Card.cardNum + 1
  end
  heavyAtkMulti = 1.5
  if player:HasCollectible(Item.PaperFrog) then
    heavyAtkMulti = heavyAtkMulti + 0.75
  end
  if player:HasCollectible(69) then
    CircleFrame.Visible = true
  end
end

function slay:SwordFlowPlayer(sword)  --剑随着方向键改变方位
   local sprite = sword:GetSprite()
   local room = Game():GetRoom()
   local player = Isaac.GetPlayer(0)
   local pos1 = room:WorldToScreenPosition(player.Position)
   local mpos = room:WorldToScreenPosition(Input.GetMousePosition(true))
  sword = sword:ToNPC()
  sword.Position = Vector(player.Position.X, player.Position.Y)
  sword.Velocity = player.Velocity
  sword.SizeMulti = Vector(10,10)
  local direction =player:GetHeadDirection()
  sword.RenderZOffset = 0
      ---更改方向变量 随着方向键来变换
      local X = slay:CalculateVector(mpos,pos1).X
      local Y = slay:CalculateVector(mpos,pos1).Y
      ---如果没有挥动的时候更换位置
      if Y==1 and swingNum ==0 then
        sword.Position = Vector(player.Position.X, player.Position.Y-30)
      elseif Y==-1 and swingNum==0 then
        sword.Position = Vector(player.Position.X, player.Position.Y+10)
      elseif X==-1 and swingNum==0 then
        sword.Position = Vector(player.Position.X+40, player.Position.Y-10)
      elseif X==1 and swingNum==0 then
        sword.Position = Vector(player.Position.X-40, player.Position.Y-10)
      end
      ---如果有挥动的时候更换位置
      if swingNum > 0 then
        if Y==1 then
          sword.Position = Vector(player.Position.X, player.Position.Y-30)
        elseif Y==-1 then
          sword.Position = Vector(player.Position.X, player.Position.Y+10)
        elseif X==-1  then
          sword.Position = Vector(player.Position.X+40, player.Position.Y-10)
        elseif X==1 then
          sword.Position = Vector(player.Position.X-40, player.Position.Y-10)
        end
      end
    if maxCharge >playerMaxCharge and isplay then  --充能动画
      sprite:Load(swordAnm2,true)
      sprite:Play("MaxCharge")
      isplay = false
    elseif maxCharge > playerMaxCharge and  newRoom then --使新房间 也充能
      sprite:Load(swordAnm2,true)
      sprite:Play("MaxCharge")
      newRoom = false
    elseif maxCharge <= playerMaxCharge and not isplay then  --播放普通的动画
      sprite:Load(swordAnm2,true)
      sprite:Play("Idle")
      isplay = true
    end
    if maxCharge >playerMaxCharge  then
      if player:HasCollectible(118) then
        local bri = Isaac.Spawn(1000,111,0,sword.Position + Vector(math.random(-10,10),math.random(-80,20)),Vector(0,0),player)
        bri=bri:ToEffect()
        bri.MaxRadius = 1
        bri.MinRadius = 1
      end
    end
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------
    if swingNum >0 and swing then --播放挥舞动画
      sprite:Load(swordAnm2,true)
      if swingDir then
        sprite:Play("Swing")
        swingDir = false
      else
        sprite:Play("BackSwing")
        swingDir = true
      end
      swing = false
      isPlaySwing = false
    elseif swingNum <=0 and not isPlaySwing then --停止挥舞动画
      isplay = false
      isPlaySwing = true
    end
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------
end

function slay:SpawnSword() --生成剑
  local player = Isaac.GetPlayer(0)
    local room = Game():GetRoom()
    local roomFrames = room:GetFrameCount()
    if player:GetPlayerType() == IroncladID then
      if roomFrames == 1 then
        spawned = false
      end
     if not spawned then
        local sword = Isaac.Spawn(swordID, 0, 0, player.Position, Vector(0,0), player)
        sword = sword:ToNPC()
        sword.GridCollisionClass = GridCollisionClass.COLLISION_NONE
        sword:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sword.CanShutDoors = false
        spawned = true
        local sprite =sword:GetSprite()
        sprite:Load(swordAnm2,true)
        sprite:Play("Idle")
      end
    end
end

local deleteAirTime = 0
function slay:spawnSwordAir(entity,attType)--施放剑气
      local player = Isaac.GetPlayer(0)
    local sword = Isaac.Spawn(atk.normal1, 0, 0, entity.Position, Vector(0,0), player)
      sword = sword:ToNPC()
      sword.GridCollisionClass = GridCollisionClass.COLLISION_NONE
      sword:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
      sword.CanShutDoors = false
      local sprite = sword:GetSprite()
      sword.RenderZOffset = 999
      sprite:Load(atkAirAnm2,true)
      if attType ==1 or attType == 2 then
        sprite.Rotation = math.random(-180,180)
      end
      if attType == 1 then
        sprite:Play("idle")
      elseif attType == 2 then
        sprite:Play("heavy atk")
      elseif attType == 3 then
        sprite:Play("all atk")
      elseif attType == 4 then
        sprite:Play("all atk small")
      elseif attType == 5 then
        sprite:Play("rangeAttack")
      elseif attType == 6 then
        sprite:Play("ironWave")
      elseif attType == 7 then
         sprite:Play("thunderClap")
      elseif attType == 10 then
         sprite:Play("bludgeon")
      end
      table.insert(airTable,#airTable + 1,sword)
      deleteAirTime=30

--[[##############剑气颜色改变##############]]--、
    if (player:HasCollectible(254) or player:HasCollectible(154))and swingDir then  --血眼化学药品红
      sprite.Color = Color(1,0,0,1,100,0,0)
    end

    if player:HasCollectible(7)  or --荆棘头圈
       player:HasCollectible(80) or --血契
       player:HasCollectible(230) or--亚巴顿
       player:HasCollectible(183) or --牙签
       player:HasCollectible(138) --圣痕
       then
      sprite.Color = Color(1,0,0,1,100,0,0) --红
    end
    if player:HasCollectible(257) then  --火之意志
      sprite.Color = Color(1,0.5,0.08,1,100,50,8)
    end
     if player:HasCollectible(395) or  --科技X
        player:HasCollectible(118) then
        sprite.Color = Color(1,0,0,1,100,0,0) --红
      end
    if player:HasCollectible(6) and not player:HasCollectible(257)  then
      sprite.Color = Color(1,1,0,1,50,50,0) --第一名亮黄
    end

    if player:HasCollectible(132) then
      sprite.Color = Color(0.1,0.1,0.1,1,0,0,0) --煤块黑灰
    end
    if player:HasCollectible(149) and ((not player:HasCollectible(118)) or player:HasCollectible(395)) then
      sprite.Color = Color(0.6,0.3,0.1,1,60,30,0) ----土根绿
    end
end
function slay:spawnSwordAirEffect(attType)--施放剑气2
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    local mpos = Input.GetMousePosition(true)
    local pos1 = player.Position
    local playerPos = mpos
  --[[if direct.down then
    playerPos = Vector(pos1.X,pos1.Y + 60)
  elseif direct.up then
    playerPos = Vector(pos1.X,pos1.Y - 60)
  elseif direct.left then
    playerPos = Vector(pos1.X - 60,pos1.Y)
  elseif direct.right then
    playerPos = Vector(pos1.X + 60,pos1.Y)
  end--]]
  --以下的函数段你是看不懂的 他的作用是把斩在外边的剑气拉到攻击范围内
    if slay:CalculateDistance(room:WorldToScreenPosition(pos1),room:WorldToScreenPosition(playerPos)) > attackRange then
      while (slay:CalculateDistance(room:WorldToScreenPosition(pos1),room:WorldToScreenPosition(playerPos)) > attackRange) do
        playerPos = playerPos + slay:CalculateVector(pos1,playerPos)
        CircleFrame.Duration = 30
      end
    end
  local eff =nil;
  local sword = nil
  if not  isRangeAttack then
     sword = Isaac.Spawn(atk.normal1, 0, 0, playerPos , Vector(0,0), player)
     eff = Isaac.Spawn(1000, 113, 666, playerPos , Vector(0,0), player)  --生成一个类硫磺火实体
  else
     sword = Isaac.Spawn(atk.normal1, 0, 0, pos1 , Vector(0,0), player)
     eff = Isaac.Spawn(1000, 113, 666, pos1 , Vector(0,0), player)  --生成一个类硫磺火实体
  end

      eff = eff:ToEffect()
      eff.Size = 20 --没有人的时候砍得范围
      eff.CollisionDamage = 0.01  --伤害
      eff.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL  --所有伤害
      eff:ClearEntityFlags(EntityFlag.FLAG_APPEAR) --清除出生的气泡
      eff.Timeout = 3  --硫磺火持续时间
      sword = sword:ToNPC()
      sword:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
      sword.CanShutDoors = false  --不关门
      local sprite = sword:GetSprite()
      sword.RenderZOffset = 999
      sprite:Load(atkAirAnm2,true)
      if not isSpecialAtk then sprite.Rotation = math.random(-180,180) end
      sprite.Scale = Vector(1,1)
      if not isSpecialAtk then --不是特殊攻击
        if attType == 1 then --不蓄力
          if airType == 1 then
            sprite:Play("idle")
          elseif airType == 3 then
            sprite:Play("all atk")
          elseif airType == 4 then
            sprite:Play("all atk small")
          end
          if player:HasCollectible(118) and not player:HasCollectible(395) then --硫磺火
            slay:FireBrimstone(10,sword.Position,player.Damage)
          end
          if player:HasCollectible(395) then --科技X
            player:FireTechXLaser(sword.Position,slay:CalculateVector(sword.Position,player.Position)*(player.ShotSpeed*10)+player.Velocity*0.8,player.Damage*3)
          end
        elseif attType == 2 then --蓄力
          sprite:Play("heavy atk")
          if player:HasCollectible(118) and not player:HasCollectible(395) then --硫磺火
            slay:FireBrimstone(30,sword.Position,player.Damage)
          end
          if player:HasCollectible(395) then --科技X
            player:FireTechXLaser(sword.Position,slay:CalculateVector(sword.Position,player.Position)*(player.ShotSpeed*10)+player.Velocity*0.8,player.Damage*5)
          end
        end
        if player:HasCollectible(149) then --吐根
          Isaac.Explode(sword.Position,nil,player.Damage) --产生爆炸
          Isaac.Explode(sword.Position, nil, 0) --产生爆炸击退
        end
        if player:HasCollectible(68) or player:HasCollectible(494) then --科技1
          --效果：在敌人身上射出一条激光线
          player:FireTechLaser(sword.Position,LaserOffset.LASER_BRIMSTONE_OFFSET,sword.Position - player.Position ,false,true)
        end

        if player:HasCollectible(52) then
          player:FireBomb(sword.Position,slay:CalculateVector(sword.Position,player.Position)*(player.ShotSpeed*8)+player.Velocity)
        end
      else
        if attType ==5 then
          sprite:Play("rangeAttack")
        elseif attType == 3 or attType == 2 then
          sprite:Play("heavy atk")
        elseif attType == 6 then
          sprite:Play("ironWave")
        elseif attType == 7 then
          sprite:Play("thunderClap")
        elseif attType == 15 then
          player:FireBrimstone(slay:CalculateVector(room:WorldToScreenPosition(mpos),room:WorldToScreenPosition(player.Position)))
        end
      end
      table.insert(airTable,#airTable + 1,sword)
      deleteAirTime=30

--[[##############剑气颜色改变##############]]--、
    if (player:HasCollectible(254) or player:HasCollectible(154))and swingDir then  --血眼化学药品红
      sprite.Color = Color(1,0,0,1,100,0,0)
    end

    if player:HasCollectible(7)  or --荆棘头圈
       player:HasCollectible(80) or --血契
       player:HasCollectible(230) or--亚巴顿
       player:HasCollectible(183) or --牙签
       player:HasCollectible(138) --圣痕
       then
      sprite.Color = Color(1,0,0,1,100,0,0) --红
    end
    if player:HasCollectible(257) then  --火之意志
      sprite.Color = Color(1,0.5,0.08,1,100,50,8)
    end
     if player:HasCollectible(395) or  --科技X
        player:HasCollectible(118) then
        sprite.Color = Color(1,0,0,1,100,0,0) --红
      end
    if player:HasCollectible(6) and not player:HasCollectible(257)  then
      sprite.Color = Color(1,1,0,1,50,50,0) --第一名亮黄
    end

    if player:HasCollectible(132) then
      sprite.Color = Color(0.1,0.1,0.1,1,0,0,0) --煤块黑灰
    end
    if player:HasCollectible(149) and ((not player:HasCollectible(118)) or player:HasCollectible(395)) then
      sprite.Color = Color(0.6,0.3,0.1,1,60,30,0) ----土根绿
    end
end

function slay:CostTimer()--费用增加计时器
  local player = Isaac.GetPlayer(0)
  local extraTime = 2--额外增加的时间  用来平衡延迟太低攻速太快的问题
    if player.MaxFireDelay > 6 then
      extraTime = 2
    elseif player.MaxFireDelay >4 then
      extraTime = 3
    elseif player.MaxFireDelay == 1 then
      extraTime = 4
    end
    if cost < maxCost then
        if costTimer < player.MaxFireDelay + extraTime then
          costTimer = costTimer + 1
        else
          cost = cost + 1
          costTimer = 0
        end
    end
end
function slay:SelectAnim()
  local player = Isaac.GetPlayer(0)
  if deleteAirTime == 0 then
    for i = 1,#airTable do
        airTable[i]:Remove()
    end
    airTable = {}
  else
    deleteAirTime = deleteAirTime - 1
  end

end

function slay:NewRoom() --MC_POST_NEW_ROOM
local player = Isaac.GetPlayer(0)
local room = Game():GetRoom()
local timeCount = Game():GetFrameCount()
local Level = Game():GetLevel()
if player:GetPlayerType() == IroncladID then
    if cost > maxCost then --如果超过最大值 则取最大值
      cost = maxCost
    end
    isBuyingItem = true--厨房间就消失
    --新房间抽牌
    if room:IsFirstVisit() and timeCount >1 and Level:GetStartingRoomIndex() ~= Level:GetCurrentRoomIndex()  then
      slay:DrawCardItem()
    end
    --攻击牌初始化--
    specialType = 0
    CircleFrame.Visible = false
    isSpecialAtk = false
    isRangeAttack = false
    extraAttackNum = 0
    CardEffectData.PummelAtknum = 0
    CardEffectData.DoubleTap = 0
    playerPower[2].value = 0 --灵活肌肉清除
    playerPower[2].visible = false
    --攻击牌初始化--

    Marble.isSet = false --弹珠带初始化
    BlackStar.isSpawn = false --黑星生成初始化
    Matryoshka.isSpawn = false --套娃初始化
    newRoom = true --初始化剑的生成
    airTable = {} --初始化剑气table
    Calendar.frame = Calendar.maxFrame --初始化历石计时器
    Meat.Tigger = true --初始化肉
    BlackBlood.Tigger = true --初始化燃烧之血
    Pantograph.Tigger = true --初始化缩放仪
    CultistMask.Tigger = true --初始化咔咔
    Bank.Tigger = true   --初始化存钱罐
    Shuriken.atkTimes = 0   --初始化手里剑
    Kunai.atkTimes = 0   --初始化苦无
    Player_Card.isRoomNoEnemy = not room:IsClear()
    Player_Card.isTrigger = false;
  if (Level:GetStartingRoomIndex() == Level:GetCurrentRoomIndex()) and (Level:GetStage() < 2) then
        local stype = Level:GetStageType()
        if stype < 3 then
          local ffeffect = nil
          if stype == 0 then
            ffeffect = Isaac.Spawn (1000,1098456088,0,Vector(295,-25),Vector(0,0),player)
          else
            ffeffect = Isaac.Spawn (1000,123456789,0,Vector(295,-25),Vector(0,0),player)
            if stype == 2 then
              ffeffect.Color = Color(0.8,0.8,0.8,1,1,1,1)
            end
          end
          if getRandom(50) then
            local controlseffect = Isaac.Spawn (1000,1037569613,0,Vector(320,30),Vector(0,0),player):ToEffect()
            controlseffect.Color = Color(0.5,0.5,0.5,1,1,1,1)
          else
            local controlseffect = Isaac.Spawn (1000,1037569614,0,Vector(320,30),Vector(0,0),player):ToEffect()
            controlseffect.Color = Color(0.5,0.5,0.5,1,1,1,1)
          end
        end
      
  end
    if CardEffectData.Barricade and   playerPower[1].visible ~= false then
      playerPower[1].value  = CardEffectData.BarricadeCount + 1
    else
      playerPower[1].value = 1 --盾初始化为1
    end
    if  room:IsFirstVisit() then MetallicizeCount = MetallicizeCount + 1 end
    if MetallicizeCount >= 3 and timeCount>1   then --金属化生成护盾
      MetallicizeCount = MetallicizeCount - 3
      playerPower[1].value = playerPower[1].value + playerPower[20].value
    end

    CardEffectData.flexDamage = 0 --灵活肌漏
    CardEffectData.FlameBarrier = false --火焰父盾
  end
end

function slay:NewStart() --新一局
  local player = Isaac.GetPlayer(0)
    newStart = true
end

function slay:AddRange() --每下一层增加攻击距离
  local player = Isaac.GetPlayer(0)
  Ironclad.TearHeight = Ironclad.TearHeight - 1
  slay:CardToDiscard(true,nil)
  slay:CardToDraw()
  for i = #Card_Draw,1,-1 do
    if Card_Draw[i].cardType == "status"  then
      table.remove(Card_Draw,i)
    end
  end
  for i = 1,#HitBox do
    HitBox[i].card = nil
  end
  DiscardTempCount = 0
end

--[[
function slay:UpdateChronoscope() --copy from dio mod 从dio mod抄过来的 谢谢dio mod的作者 阿里嘎多
  local game = Game()
	local player = Isaac.GetPlayer(0)-- get player data
	local entities = Isaac.GetRoomEntities()
	if pause.Freeze == 1 then
        player.ControlsEnabled = true

		for i,v in pairs(entities) do
			if v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
        v:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
        if v.Type == EntityType.ENTITY_TEAR then
          local data = v:GetData()
          if data.Frozen then
            data.Frozen = nil
            tear = v:ToTear()
            entities[i].Velocity = data.StoredVel
            tear = entities[i]:ToTear()
            tear.FallingSpeed = data.StoredFall
            tear.FallingAcceleration = data.StoredAcc
          end
        elseif v.Type == EntityType.ENTITY_LASER then
          local data = v:GetData()
          data.Frozen = nil
        elseif v.Type == EntityType.ENTITY_KNIFE then
          local data = v:GetData()
          data.Frozen = nil
        end
      end
    end
    pause.Freeze = pause.Freeze - 1
	elseif pause.Freeze > 1 then
		game.TimeCounter = pause.savedTime
    player.ControlsEnabled = false
		for i,v in pairs(entities) do
				if entities[i].Type ~= EntityType.ENTITY_PROJECTILE then
          if not v:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
            entities[i]:AddEntityFlags(EntityFlag.FLAG_FREEZE)
          end
        end
				if entities[i].Type == EntityType.ENTITY_TEAR then
          local data = v:GetData()
					if not data.Frozen then
            if v.Velocity.X ~= 0 or v.Velocity.Y ~= 0 or not player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) or not player:HasCollectible(KnifeItem) then
              data.Frozen = true
              data.StoredVel = entities[i].Velocity
              local tear = entities[i]:ToTear()
              data.StoredFall = tear.FallingSpeed
              data.StoredAcc = tear.FallingAcceleration
            else
              local tear = entities[i]:ToTear()
              tear.FallingSpeed = 0
            end
					else
            local tear = entities[i]:ToTear()
						entities[i].Velocity = pause.zeroV
						tear.FallingAcceleration = -0.1
						tear.FallingSpeed = 0
					end
        elseif  entities[i].Type == EntityType.ENTITY_FAMILIAR then
          local data = v:GetData()
					if not data.Frozen then
              data.Frozen = true
              data.StoredPos = entities[i].Position
					end
				elseif entities[i].Type == EntityType.ENTITY_BOMBDROP then
					bomb = v:ToBomb()
					bomb:SetExplosionCountdown(2)
                    if v.Variant  == 4 then
                        bomb.Velocity = pause.zeroV
                    end
				elseif entities[i].Type == EntityType.ENTITY_LASER then
					if v.Variant ~= 2 then
            local laser = v:ToLaser()
            local data = v:GetData()
            if not data.Frozen and not laser:IsCircleLaser() then
              local newLaser = player:FireBrimstone(Vector.FromAngle(laser.StartAngleDegrees))
              newLaser.Position = laser.Position
              newLaser.DisableFollowParent = true
              local newData = newLaser:GetData()
              newData.Frozen = true
              laser.CollisionDamage = -100
              data.Frozen = true
              laser.DisableFollowParent = true
              laser.Visible = false
            end
            laser:SetTimeout(19)
          end
        elseif v.Type == EntityType.ENTITY_KNIFE then
          ---[[
          local data = v:GetData()
          local knife = v:ToKnife()
          if knife:IsFlying() then
            local number = 1
            local offset = 0
            local offset2 = 0
            local brimDamage = 0
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
              number = math.random(math.floor(3+knife.Charge*3),math.floor(4+knife.Charge*4))
              offset = math.random(-150,150)/10
              offset2 = math.random(-300,300)/1000
              brimDamage = 1.5
            end
            for i = 1,number do
              local newKnife = player:FireTear(knife.Position,pause.zeroV,false,true,false)
              local newData = newKnife:GetData()
              newData.Knife = true
              newKnife.TearFlags = 1<<1
              newKnife.Scale = 1
              newKnife:ResetSpriteScale()
              newKnife.FallingAcceleration = -0.1
              newKnife.FallingSpeed = 0
              newKnife.Height = -10
              pause.randomV.X = 0
              pause.randomV.Y = 1+offset2
              newKnife.Velocity = pause.randomV:Rotated(knife.Rotation-90+offset)*15*player.ShotSpeed
              newKnife.CollisionDamage = knife.Charge*(player.Damage)*(3-brimDamage)
              newKnife.GridCollisionClass = GridCollisionClass.COLLISION_NONE
              newKnife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

              newKnife.SpriteRotation = newKnife.Velocity:GetAngleDegrees()+90
              local sprite = newKnife:GetSprite()
              sprite:ReplaceSpritesheet(0,"gfx/tearKnife.png")
              sprite:LoadGraphics()

              knife:Reset()
              offset = math.random(-150,150)/10
              offset2 = math.random(-300,300)/1000
            end
          end

        end

		end
		pause.Freeze = math.max(0,pause.Freeze - 1)
	else
    for i,v in pairs(entities) do
      if v:GetData().Knife then
        for o,entity in pairs(entities) do
          if entity:IsVulnerableEnemy() and (not entity:GetData().Knife) and entity.Position:Distance(v.Position) < entity.Size + 7 then
            entity:TakeDamage(v.CollisionDamage,0,EntityRef(v),0)
          end
        end
        if player.Position:Distance(v.Position) > 1000 then
          v:Remove()
        end
      end
    end
  end
end


function slay:projectileUpdate(tear)
  if pause.Freeze == 1 then
    local data = tear:GetData()
    data.Frozen = false
    tear.Velocity = data.StoredVel
    tear.FallingSpeed = data.StoredFall
    tear.FallingAccel = data.StoredAcc
  elseif pause.Freeze > 1 then
    local data = tear:GetData()
    if not data.Frozen then
      data.Frozen = true
      data.StoredVel = tear.Velocity
      data.StoredFall = tear.FallingSpeed
      data.StoredAcc = tear.FallingAccel
    else
      tear.Velocity = pause.zeroV
      tear.FallingAccel = -0.1
      tear.FallingSpeed = 0
    end
  end
end]]--]]]]
--偷来的
function slay:WriteText(text, px, py, center, colr, colv, colb, cola)
	local	fontw = 6
	local	ch

	if sfont == nil then
		sfont = Sprite()
		sfont:Load("/gfx/ui/SinstharFonts.anm2",true)
		sfont:Play("Idle")
	end

	if center == true then
		px = px - ((string.len(text) * fontw) / 2) + (fontw/2)
	end

	sfont.Color = Color(colr,colv,colb,cola,0,0,0)

	for i=1, string.len(text) do
		ch = string.byte(text,i) - 32
		sfont:SetLayerFrame(0,ch)
		sfont:Render(Vector(px + ((i-1)*fontw), py), Vector(0,0), Vector(0,0))
	end
end

function slay:command(cmd, params)
  if cmd == "givecards" then
    if params ~= nil then
      slay:GainCard(clone(Card_Type[tonumber(params)]))
      Isaac.ConsoleOutput("GET:"..Card_Type[tonumber(params)].name  );
    end
  end
  
  if cmd == "costadd" then
    if params ~= nil then
      cost = cost + tonumber(params)
    end
  end
  
  if cmd == "cardsclear" then
      Card_Draw = {}
      Card_Hand = {}
      Card_Discard = {}
  end
  if cmd == "target" then
      target = not target
      Isaac.ConsoleOutput("target:"..tostring(target));
  end
end


slay:AddCallback(ModCallbacks.MC_EXECUTE_CMD, slay.command);
--slay:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, slay.projectileUpdate)
--slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.UpdateChronoscope)
slay:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, slay.AddRange) --每下一层增加攻击距离
slay:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, slay.NewRoom)--进入新房间
slay:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,slay.NewStart)--开始新一局

slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.CostTimer) --费用增加
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.SpawnSword) --生成刀
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.ChangeFromItems) --攻击随着道具改变
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.PlayerToAttack)--人物攻击
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.SelectAnim) --删除播放完毕的剑气
slay:AddCallback(ModCallbacks.MC_POST_UPDATE, slay.GameUpdate) --游戏内容

slay:AddCallback(ModCallbacks.MC_NPC_UPDATE, slay.SwordFlowPlayer,swordID)--刀跟随人物

slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.BuyItemRender) --效果显示
slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.ChooseCardUiRender) --选牌
slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.GameStartRender) --效果显示
slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.DebugRender) --debug
slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.EffectRender) --效果显示
slay:AddCallback(ModCallbacks.MC_POST_RENDER, slay.GainCardRender) --效果显示

slay:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, slay.GetDamage,EntityType.ENTITY_PLAYER) --效果显示

slay:AddCallback(ModCallbacks.MC_USE_ITEM, slay.DrawCardItem,ModItem.GetCard) --抽卡机
