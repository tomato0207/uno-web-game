import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const UnoApp());
}

class UnoApp extends StatelessWidget {
  const UnoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNO Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const UnoHomePage(),
    );
  }
}

class UnoHomePage extends StatefulWidget {
  const UnoHomePage({super.key});
  @override
  State<UnoHomePage> createState() => _UnoHomePageState();
}

class _UnoHomePageState extends State<UnoHomePage> {
  // --- 狀態變數 (State Variables) ---
  late WebSocketChannel channel;
  bool connected = false;
  String? roomId;
  List<String> hand = [];
  String topCard = '';
  String currentPlayer = '';
  String currentColor = '';
  String? loggedInUsername; 
  String playerId = ''; 
  Map<String, int> otherPlayers = {}; 
  int connectedPlayers = 0;
  bool canEndTurn = false; 
  bool gameStarted = false; 

  // 帳號/房間控制器
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final roomController = TextEditingController();

  // 靜態卡片寬高
  static const double cardWidth = 140.0;
  static const double cardHeight = 200.0;

  @override
  void dispose() {
    if (connected) channel.sink.close();
    usernameController.dispose();
    passwordController.dispose();
    roomController.dispose();
    super.dispose();
  }

  // --- 連線核心 ---
  void connect() {
    // Ngrok 地址每次重啟都會改變，需要同步替換！
    channel = WebSocketChannel.connect(Uri.parse('wss://bc9ff94e9952.ngrok-free.app/uno/game'));

    channel.stream.listen(
      (message) {
        try {
          final data = json.decode(message);
          setState(() {
            switch (data['action']) {
              case 'loginSuccess': 
                loggedInUsername = data['username'];
                usernameController.clear();
                passwordController.clear();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("登入成功！歡迎 ${loggedInUsername!}")));
                break;
              
              case 'joinedRoom':
              case 'roomCreated':
                roomId = data['roomId'];
                connectedPlayers = data['totalPlayers'] ?? 1;
                gameStarted = false;
                break;
              case 'initHand':
                hand = List<String>.from(data['hand']);
                playerId = loggedInUsername!; 
                topCard = data['topCard'];
                currentPlayer = data['currentPlayer'];
                currentColor = data['currentColor'];
                canEndTurn = false;
                gameStarted = true;
                break;

              case 'play':
                final String playerWhoPlayed = data['playerId'];
                if (playerWhoPlayed == loggedInUsername) hand.remove(data['card']);
                
                topCard = data['topCard'] ?? topCard;
                currentPlayer = data['nextPlayer'];
                currentColor = data['currentColor'] ?? currentColor;
                canEndTurn = false;
                otherPlayers[playerWhoPlayed] = data['handSize'];
                
                if (data['winner'] != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("玩家 ${data['winner']} 勝利！")));
                  gameStarted = false;
                }
                break;

              case 'draw':
                final String playerWhoDrew = data['playerId'];
                if (playerWhoDrew == loggedInUsername) {
                  if (data['drawnCard'] != null) hand.add(data['drawnCard']);
                  canEndTurn = true;
                }
                topCard = data['topCard'] ?? topCard;
                currentPlayer = data['nextPlayer'];
                currentColor = data['currentColor'] ?? currentColor;
                otherPlayers[playerWhoDrew] = data['handSize'];
                break;

              case 'punishUpdate':
                final String punishedId = data['punishedId'];
                final int newSize = data['newHandSize'];

                if (punishedId == loggedInUsername) {
                    final List<String> newCards = List<String>.from(data['newCards']);
                    hand.addAll(newCards);
                    canEndTurn = false;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("你被懲罰抽了 ${newCards.length} 張牌!")));
                } else {
                    otherPlayers[punishedId] = newSize;
                }
                break;

              case 'nextTurn':
                currentPlayer = data['nextPlayer'];
                canEndTurn = false;
                break;

              case 'updatePlayers':
                connectedPlayers = data['totalPlayers'];
                break;

              default:
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data.toString())));
                break;
            }
          });
        } catch (e) {
            final String errorMsg = message.toString();
            if (connected && errorMsg.contains("非法出牌")) {
                 setState(() { canEndTurn = true; }); 
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      },
      onError: (error) { setState(() { connected = false; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("連線錯誤: $error"))); }); },
      onDone: () { setState(() { connected = false; roomId = null; loggedInUsername = null; gameStarted = false; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("已與伺服器斷開連線"))); }); },
    );
    setState(() { connected = true; });
  }

  // --- 遊戲邏輯與操作 ---
  void register() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) return;
    final msg = {'action': 'register', 'username': usernameController.text, 'password': passwordController.text};
    channel.sink.add(json.encode(msg));
  }

  void login() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) return;
    final msg = {'action': 'login', 'username': usernameController.text, 'password': passwordController.text};
    channel.sink.add(json.encode(msg));
  }

  void createRoom() {
    if (roomController.text.isEmpty) return;
    final msg = {'action': 'createRoom', 'roomId': roomController.text};
    channel.sink.add(json.encode(msg));
  }

  void joinRoom() {
    if (roomController.text.isEmpty) return;
    final msg = {'action': 'joinRoom', 'roomId': roomController.text};
    channel.sink.add(json.encode(msg));
  }

  void startGame() {
    if (connectedPlayers < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("至少需要 2 名玩家才能開始遊戲")));
      return;
    }
    final msg = {'action': 'startGame', 'roomId': roomId};
    channel.sink.add(json.encode(msg));
  }

  void playCard(String card, {String? chosenColor}) {
    if (currentPlayer != loggedInUsername) return;

    setState(() { canEndTurn = false; });

    final msg = {'action': 'play', 'card': card, 'chosenColor': chosenColor, 'roomId': roomId};
    channel.sink.add(json.encode(msg));
  }

  void drawCard() {
    if (currentPlayer != loggedInUsername || canEndTurn) return;
    final msg = {'action': 'draw', 'roomId': roomId};
    channel.sink.add(json.encode(msg));
  }

  void endTurn() {
    if (currentPlayer != loggedInUsername || !canEndTurn) return; 
    final msg = {'action': 'endTurn', 'roomId': roomId};
    channel.sink.add(json.encode(msg));
  }

  // --- 判斷牌能否出 (前端驗證) ---
  bool canPlayCard(String card) {
    if (card.startsWith('W')) return true; 
    if (topCard.isEmpty) return true; 

    final String cardColor = card[0];
    final String activeColor = currentColor.isNotEmpty ? currentColor : topCard[0]; 
    final String cardValue = card.length > 1 ? card.substring(1) : '';
    final String topValue = topCard.length > 1 ? topCard.substring(1) : '';

    return cardColor == activeColor || cardValue == topValue; 
  }

  // --- UI 輔助函數 (圖片渲染和顏色) ---
  String getCardImagePath(String cardName) {
    if (cardName.isEmpty) return 'assets/cards/BACK.png'; 
    String formattedName = cardName.replaceAll('+', '_PLUS'); 
    return 'assets/cards/${formattedName}.png';
  }

  Widget _buildCardImage(String cardName, {bool isHand = false, bool isMyTurn = false}) {
      final String imagePath = getCardImagePath(cardName);
      
      // 如果是手牌且不是你的回合，則顯示牌背 (這個邏輯不再用於手牌區，而是用於頂牌區)
      // 如果是頂牌區，我們不需要顯示牌背
      
      return Padding(
        key: ValueKey(cardName), 
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Image.asset(
          imagePath,
          width: isHand ? cardWidth : cardWidth * 0.7, 
          height: isHand ? cardHeight : cardHeight * 0.7,
          fit: BoxFit.contain,
        ),
      );
  }

  Widget _buildTopCardWidget(String cardName) {
    // 頂牌永遠顯示卡面
    return _buildCardImage(cardName, isHand: false);
  }
  
  // 【新增】渲染對手牌背卡片的輔助函數
  Widget _buildOpponentCardBack() {
    // 對手牌的卡片尺寸可以小一些
    const double opponentCardWidth = 40.0;
    const double opponentCardHeight = 60.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Image.asset(
        getCardImagePath(''), // 使用空字串獲取牌背圖片
        width: opponentCardWidth, 
        height: opponentCardHeight,
        fit: BoxFit.contain,
      ),
    );
  }


  Color _getColorFromChar(String char) {
    switch (char) {
      case 'R': return Colors.red;
      case 'G': return Colors.green;
      case 'B': return Colors.blue;
      case 'Y': return Colors.yellow.shade800;
      case 'W': case 'w': return Colors.black;
      default: return Colors.grey;
    }
  }

  void _handleCardPress(BuildContext context, String card) {
    if (!canPlayCard(card)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("這張牌不能出！")));
      return;
    }

    if (card.startsWith('W')) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('選擇顏色'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['R', 'G', 'B', 'Y'].map((color) {
              return ElevatedButton(
                onPressed: () {
                  playCard(card, chosenColor: color);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _getColorFromChar(color)),
                child: Text(color, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      playCard(card);
    }
  }

  // --- UI 結構 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UNO Web (${loggedInUsername ?? "未登入"})')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: connected
            ? loggedInUsername == null
                ? buildAuthUI()
                : gameStarted
                    ? buildGameUI()
                    : buildRoomSelection()
            : Center(
                child: ElevatedButton(
                  onPressed: connect,
                  child: const Text('連線到後端'),
                ),
              ),
      ),
    );
  }

  Widget buildAuthUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('帳號登入/註冊', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Divider(),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(labelText: '用戶名 (將作為遊戲名稱)'),
        ),
        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: '密碼'),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(onPressed: register, child: const Text('註冊新帳號')),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: login, child: const Text('登入')),
          ],
        ),
      ],
    );
  }

  Widget buildRoomSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('歡迎，${loggedInUsername!}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        TextField(
          controller: roomController,
          decoration: const InputDecoration(labelText: '房間ID'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(onPressed: createRoom, child: const Text('創建房間')),
            const SizedBox(width: 10),
            ElevatedButton(onPressed: joinRoom, child: const Text('加入房間')),
          ],
        ),
        const SizedBox(height: 10),
        if(roomId != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('房間 ${roomId!}: 目前玩家數: $connectedPlayers'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: startGame,
                child: const Text('開始遊戲'),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildGameUI() {
    final bool isMyTurn = currentPlayer == loggedInUsername;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 頂部狀態列 (房間/回合資訊)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('房間: ${roomId ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              '輪到: ${currentPlayer == loggedInUsername ? '你 (自己)' : currentPlayer}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isMyTurn ? Colors.red : Colors.blueGrey,
              ),
            ),
          ],
        ),
        const Divider(),

        // 【新增】對手卡牌列 (Opponent Cards Row)
        const Text('對手卡牌:'),
        Container(
          height: 70, // 設定一個固定的高度給卡牌列
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: otherPlayers.entries.expand((entry) {
                final String opponentName = entry.key;
                final int handSize = entry.value;

                // 每個對手顯示他的名字和對應數量的牌背
                List<Widget> opponentWidgets = [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opponentName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: opponentName == currentPlayer ? FontWeight.bold : FontWeight.normal,
                            color: opponentName == currentPlayer ? Colors.orange : Colors.black87,
                          ),
                        ),
                        // 將牌背並排顯示
                        Container(
                          height: 40, // 限制牌背的高度，避免佔用太多空間
                          child: Row(
                            children: List.generate(handSize, (index) => _buildOpponentCardBack()),
                          ),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                ];
                return opponentWidgets;
              }).toList(),
            ),
          ),
        ),
        const Divider(),

        // 頂牌和當前顏色狀態
        Row(
          children: [
            const Text('頂牌: ', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTopCardWidget(topCard),
            const SizedBox(width: 20),
            const Text('當前顏色: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getColorFromChar(currentColor),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 抽牌和結束回合按鈕
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: isMyTurn && !canEndTurn ? drawCard : null,
              icon: const Icon(Icons.style),
              label: const Text('抽牌'),
            ),
            const SizedBox(width: 10),
            if (canEndTurn)
              ElevatedButton.icon(
                onPressed: isMyTurn ? endTurn : null,
                icon: const Icon(Icons.transit_enterexit),
                label: const Text('結束回合'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
        const Divider(),

        const Text('你的手牌:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        
        // 玩家手牌滑動區域
        Expanded(
          child: SingleChildScrollView( 
            scrollDirection: Axis.horizontal, 
            child: Row( 
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hand.map((card) {
                final bool playable = canPlayCard(card);
                return GestureDetector(
                  onTap: isMyTurn && playable ? () => _handleCardPress(context, card) : null,
                  child: Opacity(
                    opacity: isMyTurn ? (playable ? 1.0 : 0.4) : 0.6,
                    child: Tooltip(
                      message: card,
                      child: _buildCardImage(card, isHand: true, isMyTurn: isMyTurn),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}