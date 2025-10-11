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
  late WebSocketChannel channel;
  bool connected = false;
  String? roomId;
  List<String> hand = [];
  String topCard = '';
  String currentPlayer = '';
  String currentColor = '';
  String? loggedInUsername; // 儲存登入的用戶名作為玩家ID/Name
  String playerId = ''; 
  Map<String, int> otherPlayers = {}; 
  int connectedPlayers = 0;
  bool canEndTurn = false; 
  bool gameStarted = false; 

  // 帳號/房間控制器
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final roomController = TextEditingController();

  @override
  void dispose() {
    if (connected) channel.sink.close();
    usernameController.dispose();
    passwordController.dispose();
    roomController.dispose();
    super.dispose();
  }

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse('wss://e4eabe79bfab.ngrok-free.app/uno/game'));

    channel.stream.listen(
      (message) {
        final data = json.decode(message);
        setState(() {
          switch (data['action']) {
            case 'loginSuccess': // 處理登入成功
              loggedInUsername = data['username'];
              usernameController.clear();
              passwordController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("登入成功！歡迎 ${loggedInUsername!}")),
              );
              break;
            
            case 'joinedRoom':
            case 'roomCreated':
              roomId = data['roomId'];
              connectedPlayers = data['totalPlayers'] ?? 1;
              gameStarted = false;
              break;
            case 'initHand':
              hand = List<String>.from(data['hand']);
              playerId = loggedInUsername!; // 使用登入的用戶名作為玩家ID
              topCard = data['topCard'];
              currentPlayer = data['currentPlayer'];
              currentColor = data['currentColor'];
              canEndTurn = false;
              gameStarted = true;
              break;

            case 'play':
              final String playerWhoPlayed = data['playerId'];
              if (playerWhoPlayed == loggedInUsername) {
                hand.remove(data['card']);
              }
              topCard = data['topCard'] ?? topCard;
              currentPlayer = data['nextPlayer'];
              currentColor = data['currentColor'] ?? currentColor;
              canEndTurn = false;
              otherPlayers[playerWhoPlayed] = data['handSize'];
              if (data['winner'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("玩家 ${data['winner']} 勝利！")),
                );
                gameStarted = false;
              }
              break;

            case 'draw':
              final String playerWhoDrew = data['playerId'];
              if (playerWhoDrew == loggedInUsername) {
                if (data['drawnCard'] != null) {
                  hand.add(data['drawnCard']);
                }
                canEndTurn = true;
              }
              topCard = data['topCard'] ?? topCard;
              currentPlayer = data['nextPlayer'];
              currentColor = data['currentColor'] ?? currentColor;
              otherPlayers[playerWhoDrew] = data['handSize'];
              break;
            
            case 'punishUpdate': // 處理 +2/+4 懲罰
                final String punishedId = data['punishedId'];
                final int newSize = data['newHandSize'];

                if (punishedId == loggedInUsername) {
                    final List<String> newCards = List<String>.from(data['newCards']);
                    hand.addAll(newCards);
                    canEndTurn = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("你被懲罰抽了 ${newCards.length} 張牌!")),
                    );
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
              // 處理後端傳來的錯誤訊息 (例如 登入失敗, 用戶名已存在)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data.toString())),
              );
              break;
          }
        });
      },
      onError: (error) {
        setState(() {
          connected = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("連線錯誤: $error")),
          );
        });
      },
      onDone: () {
        setState(() {
          connected = false;
          roomId = null;
          loggedInUsername = null; 
          gameStarted = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("已與伺服器斷開連線")),
          );
        });
      },
    );
    setState(() {
      connected = true;
    });
  }

  // --- 帳號管理方法 ---
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
  // ----------------------

  void createRoom() {
    final msg = {'action': 'createRoom', 'roomId': roomController.text};
    channel.sink.add(json.encode(msg));
  }

  void joinRoom() {
    final msg = {'action': 'joinRoom', 'roomId': roomController.text};
    channel.sink.add(json.encode(msg));
  }

  void startGame() {
    if (connectedPlayers < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("至少需要 2 名玩家才能開始遊戲")),
      );
      return;
    }
    final msg = {'action': 'startGame', 'roomId': roomId};
    channel.sink.add(json.encode(msg));
  }

  void playCard(String card, {String? chosenColor}) {
    if (currentPlayer != loggedInUsername) return; 

    setState(() {
      canEndTurn = false;
    });

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

  // --- UI 結構 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UNO Web (${loggedInUsername ?? "未登入"})')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: connected
            ? loggedInUsername == null
                ? buildAuthUI()          // 步驟 1: 登入/註冊
                : gameStarted
                    ? buildGameUI()      // 步驟 3: 遊戲進行中
                    : buildRoomSelection() // 步驟 2: 房間選擇/等待
            : Center(
                child: ElevatedButton(
                  onPressed: connect,
                  child: const Text('連線到後端'),
                ),
              ),
      ),
    );
  }
  
  // 登入/註冊 UI
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
        Row(
          children: [
            const Text('頂牌: ', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCardWidget(topCard),
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
        Text(
          '其他玩家: ${otherPlayers.entries.map((e) => "${e.key}: ${e.value}張").join(", ")}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),

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
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: hand.map((card) {
              return ElevatedButton(
                onPressed: isMyTurn ? () => _handleCardPress(context, card) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorFromChar(card.substring(0, 1)),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 40),
                  elevation: isMyTurn ? 4 : 0, 
                ),
                child: Text(
                  card,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- 輔助方法 ---
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

  Widget _buildCardWidget(String card) {
    if (card.isEmpty) return const Text('N/A');
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getColorFromChar(card.substring(0, 1)),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        card,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleCardPress(BuildContext context, String card) {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorFromChar(color),
                ),
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
}