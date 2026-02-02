import '../models/hexagram.dart';

// 8 Trigrams (Bagua) properties for composition
const Map<String, String> trigramNames = {
  '111': '乾', // Heaven
  '011': '兑', // Lake
  '101': '离', // Fire
  '001': '震', // Thunder
  '110': '巽', // Wind
  '010': '坎', // Water
  '100': '艮', // Mountain
  '000': '坤', // Earth
};

const Map<String, String> trigramMeanings = {
  '111': '天',
  '011': '泽',
  '101': '火',
  '001': '雷',
  '110': '风',
  '010': '水',
  '100': '山',
  '000': '地',
};

// Full 64 Hexagrams Data
// Binary key is from Bottom (index 0) to Top (index 5)
// But for string readability, let's keep it consistent: string index 0 is bottom line.
final List<Hexagram> allHexagrams = [
  const Hexagram(id: 1, binary: '111111', name: '乾', title: '乾为天', upperTrigram: '乾', lowerTrigram: '乾', description: '元亨利贞。天行健，君子以自强不息。', summary: '困龙得水，大吉之象。'),
  const Hexagram(id: 2, binary: '000000', name: '坤', title: '坤为地', upperTrigram: '坤', lowerTrigram: '坤', description: '元亨，利牝马之贞。地势坤，君子以厚德载物。', summary: '饿虎得食，大吉之象。'),
  const Hexagram(id: 3, binary: '100010', name: '屯', title: '水雷屯', upperTrigram: '坎', lowerTrigram: '震', description: '元亨利贞。勿用有筱，利建侯。', summary: '乱丝无头，中凶之象。'),
  const Hexagram(id: 4, binary: '010001', name: '蒙', title: '山水蒙', upperTrigram: '艮', lowerTrigram: '坎', description: '亨。匪我求童蒙，童蒙求我。初筮告，再三渎，渎则不告。利贞。', summary: '小鬼偷钱，中下之象。'),
  const Hexagram(id: 5, binary: '111010', name: '需', title: '水天需', upperTrigram: '坎', lowerTrigram: '乾', description: '有孚，光亨，贞吉。利涉大川。', summary: '明珠出土，中吉之象。'),
  const Hexagram(id: 6, binary: '010111', name: '讼', title: '天水讼', upperTrigram: '乾', lowerTrigram: '坎', description: '有孚，窒。惕中吉。终凶。利见大人，不利涉大川。', summary: '二人争路，中下之象。'),
  const Hexagram(id: 7, binary: '010000', name: '师', title: '地水师', upperTrigram: '坤', lowerTrigram: '坎', description: '贞，丈人，吉无咎。', summary: '马到成功，中上之象。'),
  const Hexagram(id: 8, binary: '000010', name: '比', title: '水地比', upperTrigram: '坎', lowerTrigram: '坤', description: '吉。原筮元永贞，无咎。不宁方来，后夫凶。', summary: '船得顺风，中吉之象。'),
  const Hexagram(id: 9, binary: '111011', name: '小畜', title: '风天小畜', upperTrigram: '巽', lowerTrigram: '乾', description: '亨。密云不雨，自我西郊。', summary: '密云不雨，中下之象。'),
  const Hexagram(id: 10, binary: '110111', name: '履', title: '天泽履', upperTrigram: '乾', lowerTrigram: '兑', description: '履虎尾，不咥人，亨。', summary: '凤鸣岐山，中上之象。'),
  const Hexagram(id: 11, binary: '111000', name: '泰', title: '地天泰', upperTrigram: '坤', lowerTrigram: '乾', description: '小往大来，吉亨。', summary: '喜报三元，大吉之象。'),
  const Hexagram(id: 12, binary: '000111', name: '否', title: '天地否', upperTrigram: '乾', lowerTrigram: '坤', description: '否之匪人，不利君子贞，大往小来。', summary: '虎落平阳，中凶之象。'),
  const Hexagram(id: 13, binary: '101111', name: '同人', title: '天火同人', upperTrigram: '乾', lowerTrigram: '离', description: '同人于野，亨。利涉大川，利君子贞。', summary: '仙人指路，中吉之象。'),
  const Hexagram(id: 14, binary: '111101', name: '大有', title: '火天大有', upperTrigram: '离', lowerTrigram: '乾', description: '元亨。', summary: '砍树摸雀，中上之象。'),
  const Hexagram(id: 15, binary: '001000', name: '谦', title: '地山谦', upperTrigram: '坤', lowerTrigram: '艮', description: '亨，君子有终。', summary: '二人分金，中吉之象。'),
  const Hexagram(id: 16, binary: '000100', name: '豫', title: '雷地豫', upperTrigram: '震', lowerTrigram: '坤', description: '利建侯行师。', summary: '青龙得位，中吉之象。'),
  const Hexagram(id: 17, binary: '100110', name: '随', title: '泽雷随', upperTrigram: '兑', lowerTrigram: '震', description: '元亨利贞，无咎。', summary: '推车靠崖，中下之象。'),
  const Hexagram(id: 18, binary: '011001', name: '蛊', title: '山风蛊', upperTrigram: '艮', lowerTrigram: '巽', description: '元亨，利涉大川。先甲三日，后甲三日。', summary: '推磨岔道，中下之象。'),
  const Hexagram(id: 19, binary: '110000', name: '临', title: '地泽临', upperTrigram: '坤', lowerTrigram: '兑', description: '元亨利贞。至于八月有凶。', summary: '发政施仁，中上之象。'),
  const Hexagram(id: 20, binary: '000011', name: '观', title: '风地观', upperTrigram: '巽', lowerTrigram: '坤', description: '盥而不荐，有孚颙若。', summary: '旱荷得水，中上之象。'),
  const Hexagram(id: 21, binary: '100101', name: '噬嗑', title: '火雷噬嗑', upperTrigram: '离', lowerTrigram: '震', description: '亨。利用狱。', summary: '饥人遇食，中吉之象。'),
  const Hexagram(id: 22, binary: '101001', name: '贲', title: '山火贲', upperTrigram: '艮', lowerTrigram: '离', description: '亨。小利有筱。', summary: '喜气盈门，中吉之象。'),
  const Hexagram(id: 23, binary: '000001', name: '剥', title: '山地剥', upperTrigram: '艮', lowerTrigram: '坤', description: '不利有筱。', summary: '莺鹊同林，中下之象。'),
  const Hexagram(id: 24, binary: '100000', name: '复', title: '地雷复', upperTrigram: '坤', lowerTrigram: '震', description: '亨。出入无疾，朋来无咎。反复其道，七日来复，利有筱。', summary: '夫妻反目，中下之象。'),
  const Hexagram(id: 25, binary: '100111', name: '无妄', title: '天雷无妄', upperTrigram: '乾', lowerTrigram: '震', description: '元亨利贞。其匪正有眚，不利有筱。', summary: '鸟被笼关，中下之象。'),
  const Hexagram(id: 26, binary: '111001', name: '大畜', title: '山天大畜', upperTrigram: '艮', lowerTrigram: '乾', description: '利贞，不家食吉，利涉大川。', summary: '阵势得开，中吉之象。'),
  const Hexagram(id: 27, binary: '100001', name: '颐', title: '山雷颐', upperTrigram: '艮', lowerTrigram: '震', description: '贞吉。观颐，自求口实。', summary: '渭水访贤，大吉之象。'),
  const Hexagram(id: 28, binary: '011110', name: '大过', title: '泽风大过', upperTrigram: '兑', lowerTrigram: '巽', description: '栋桡，利有筱，亨。', summary: '夜梦金银，中下之象。'),
  const Hexagram(id: 29, binary: '010010', name: '坎', title: '坎为水', upperTrigram: '坎', lowerTrigram: '坎', description: '习坎，有孚，维心亨，行有尚。', summary: '水底捞月，中凶之象。'),
  const Hexagram(id: 30, binary: '101101', name: '离', title: '离为火', upperTrigram: '离', lowerTrigram: '离', description: '利贞，亨。畜牝牛，吉。', summary: '天官赐福，中上之象。'),
  const Hexagram(id: 31, binary: '001110', name: '咸', title: '泽山咸', upperTrigram: '兑', lowerTrigram: '艮', description: '亨，利贞，取女吉。', summary: '萌芽出土，中吉之象。'),
  const Hexagram(id: 32, binary: '011100', name: '恒', title: '雷风恒', upperTrigram: '震', lowerTrigram: '巽', description: '亨，无咎，利贞，利有筱。', summary: '鱼来撞网，中吉之象。'),
  const Hexagram(id: 33, binary: '001111', name: '遁', title: '天山遁', upperTrigram: '乾', lowerTrigram: '艮', description: '亨，小利贞。', summary: '浓云蔽日，中下之象。'),
  const Hexagram(id: 34, binary: '111100', name: '大壮', title: '雷天大壮', upperTrigram: '震', lowerTrigram: '乾', description: '利贞。', summary: '工师得木，中吉之象。'),
  const Hexagram(id: 35, binary: '000101', name: '晋', title: '火地晋', upperTrigram: '离', lowerTrigram: '坤', description: '康侯用锡马蕃庶，昼日三接。', summary: '锄地得金，中吉之象。'),
  const Hexagram(id: 36, binary: '101000', name: '明夷', title: '地火明夷', upperTrigram: '坤', lowerTrigram: '离', description: '利艰贞。', summary: '过河拆桥，中下之象。'),
  const Hexagram(id: 37, binary: '101011', name: '家人', title: '风火家人', upperTrigram: '巽', lowerTrigram: '离', description: '利女贞。', summary: '镜里观花，中下之象。'),
  const Hexagram(id: 38, binary: '110101', name: '睽', title: '火泽睽', upperTrigram: '离', lowerTrigram: '兑', description: '小事吉。', summary: '太公避纣，中下之象。'),
  const Hexagram(id: 39, binary: '001010', name: '蹇', title: '水山蹇', upperTrigram: '坎', lowerTrigram: '艮', description: '利西南，不利东北；利见大人，贞吉。', summary: '雨雪载途，中凶之象。'),
  const Hexagram(id: 40, binary: '010100', name: '解', title: '雷水解', upperTrigram: '震', lowerTrigram: '坎', description: '利西南，无所往，其来复吉。有筱往，夙吉。', summary: '五关脱难，中吉之象。'),
  const Hexagram(id: 41, binary: '110001', name: '损', title: '山泽损', upperTrigram: '艮', lowerTrigram: '兑', description: '有孚，元吉，无咎，可贞，利有筱。曷之用，二簋可用享。', summary: '推车掉耳，中下之象。'),
  const Hexagram(id: 42, binary: '100011', name: '益', title: '风雷益', upperTrigram: '巽', lowerTrigram: '震', description: '利有筱，利涉大川。', summary: '枯木开花，中吉之象。'),
  const Hexagram(id: 43, binary: '111110', name: '夬', title: '泽天夬', upperTrigram: '兑', lowerTrigram: '乾', description: '扬于王庭，孚号，有厉，告自邑，不利即戎，利有筱。', summary: '游蜂脱网，中吉之象。'),
  const Hexagram(id: 44, binary: '011111', name: '姤', title: '天风姤', upperTrigram: '乾', lowerTrigram: '巽', description: '女壮，勿用取女。', summary: '他乡遇友，中上之象。'),
  const Hexagram(id: 45, binary: '000110', name: '萃', title: '泽地萃', upperTrigram: '兑', lowerTrigram: '坤', description: '亨。王假有庙，利见大人，亨，利贞。用大牲吉，利有筱。', summary: '鲤鱼化龙，中吉之象。'),
  const Hexagram(id: 46, binary: '011000', name: '升', title: '地风升', upperTrigram: '坤', lowerTrigram: '巽', description: '元亨，用见大人，勿恤，南征吉。', summary: '指日高升，中上之象。'),
  const Hexagram(id: 47, binary: '010110', name: '困', title: '泽水困', upperTrigram: '兑', lowerTrigram: '坎', description: '亨，贞，大人吉，无咎，有言不信。', summary: '撮杆抽梯，中凶之象。'),
  const Hexagram(id: 48, binary: '011010', name: '井', title: '水风井', upperTrigram: '坎', lowerTrigram: '巽', description: '改邑不改井，无丧无得，往来井井。', summary: '枯井生泉，中上之象。'),
  const Hexagram(id: 49, binary: '101110', name: '革', title: '泽火革', upperTrigram: '兑', lowerTrigram: '离', description: '已日乃孚，元亨利贞，悔亡。', summary: '旱苗得雨，中吉之象。'),
  const Hexagram(id: 50, binary: '011101', name: '鼎', title: '火风鼎', upperTrigram: '离', lowerTrigram: '巽', description: '元吉，亨。', summary: '渔翁得利，中吉之象。'),
  const Hexagram(id: 51, binary: '100100', name: '震', title: '震为雷', upperTrigram: '震', lowerTrigram: '震', description: '亨。震来虩虩，笑言哑哑。震惊百里，不丧匕鬯。', summary: '金钟夜撞，中吉之象。'),
  const Hexagram(id: 52, binary: '100100', name: '艮', title: '艮为山', upperTrigram: '艮', lowerTrigram: '艮', description: '艮其背，不获其身，行其庭，不见其人，无咎。', summary: '矮巴勾枣，中下之象。'),
  const Hexagram(id: 53, binary: '001011', name: '渐', title: '风山渐', upperTrigram: '巽', lowerTrigram: '艮', description: '女归吉，利贞。', summary: '俊鸟出笼，中吉之象。'),
  const Hexagram(id: 54, binary: '110100', name: '归妹', title: '雷泽归妹', upperTrigram: '震', lowerTrigram: '兑', description: '征凶，无筱。', summary: '缘木求鱼，中下之象。'),
  const Hexagram(id: 55, binary: '101100', name: '丰', title: '雷火丰', upperTrigram: '震', lowerTrigram: '离', description: '亨，王假之，勿忧，宜日中。', summary: '古镜重明，中吉之象。'),
  const Hexagram(id: 56, binary: '001101', name: '旅', title: '火山旅', upperTrigram: '离', lowerTrigram: '艮', description: '小亨，旅贞吉。', summary: '宿鸟焚巢，中凶之象。'),
  const Hexagram(id: 57, binary: '011011', name: '巽', title: '巽为风', upperTrigram: '巽', lowerTrigram: '巽', description: '小亨，利有筱，利见大人。', summary: '孤舟得水，中吉之象。'),
  const Hexagram(id: 58, binary: '110110', name: '兑', title: '兑为泽', upperTrigram: '兑', lowerTrigram: '兑', description: '亨，利贞。', summary: '趁水和泥，中吉之象。'),
  const Hexagram(id: 59, binary: '010011', name: '涣', title: '风水涣', upperTrigram: '巽', lowerTrigram: '坎', description: '亨。王假有庙，利涉大川，利贞。', summary: '隔河望金，中下之象。'),
  const Hexagram(id: 60, binary: '110010', name: '节', title: '水泽节', upperTrigram: '坎', lowerTrigram: '兑', description: '亨。苦节，不可贞。', summary: '斩将封神，中上之象。'),
  const Hexagram(id: 61, binary: '110011', name: '中孚', title: '风泽中孚', upperTrigram: '巽', lowerTrigram: '兑', description: '豚鱼，吉，利涉大川，利贞。', summary: '行走薄冰，中下之象。'),
  const Hexagram(id: 62, binary: '001100', name: '小过', title: '雷山小过', upperTrigram: '震', lowerTrigram: '艮', description: '亨，利贞。可小事，不可大事。飞鸟遗之音，不宜上，宜下，大吉。', summary: '急过独桥，中凶之象。'),
  const Hexagram(id: 63, binary: '101010', name: '既济', title: '水火既济', upperTrigram: '坎', lowerTrigram: '离', description: '亨，小利贞，初吉终乱。', summary: '金榜题名，中上之象。'),
  const Hexagram(id: 64, binary: '010101', name: '未济', title: '火水未济', upperTrigram: '离', lowerTrigram: '坎', description: '亨，小狐汔济，濡其尾，无筱。', summary: '太公钓鱼，中下之象。'),
];

// Helper to find Hexagram by binary string
Hexagram getHexagram(String binary) {
  return allHexagrams.firstWhere(
    (h) => h.binary == binary,
    orElse: () => allHexagrams[0], // Fallback to Qian
  );
}
