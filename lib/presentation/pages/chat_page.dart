import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';
import 'package:serviexpress_app/core/utils/alerts.dart';
import 'package:serviexpress_app/core/utils/loading_screen.dart';
import 'package:serviexpress_app/core/utils/result_state.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/models/message_model.dart';
import 'package:serviexpress_app/presentation/viewmodels/chat_view_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? userId;
  final clienteId = "ZlnQlK6kicZZBPMVdSso1XQPUfD2";
  bool _errorShown = false;

  late final String chatUid;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserId();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  String getSortedChatUid(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _getUserId() async {
    try {
      LoadingScreen.show(context);

      final id = await UserPreferences.getUserId();

      LoadingScreen.hide();

      setState(() {
        userId = id;
      });

      if (id == null && !_errorShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_errorShown) {
            _errorShown = true;
            Alerts.instance.showErrorAlert(
              context,
              "No se pudo obtener el ID del usuario.",
            );
          }
        });
      }
    } catch (e) {
      LoadingScreen.hide();
      setState(() {});
      if (!_errorShown) {
        _errorShown = true;
        Alerts.instance.showErrorAlert(
          context,
          "Ocurrió un error al obtener el ID: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final getMessages = ref.watch(
      chatMessagesProvider(getSortedChatUid(userId!, clienteId)),
    );

    ref.listen<ResultState>(chatViewModelProvider, (previous, next) {
      switch (next) {
        case Idle():
          LoadingScreen.hide();
          break;
        case Loading():
          LoadingScreen.show(context);
          break;
        case Success():
          LoadingScreen.hide();
          _messageController.clear();
          break;
        case Failure(:final error):
          LoadingScreen.hide();
          if (mounted) {
            Alerts.instance.showErrorAlert(context, error.message);
          }
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColor.bgChat,
      appBar: AppBar(
        backgroundColor: AppColor.bgChat,
        leading: IconButton(
          onPressed: () {},
          icon: Transform.translate(
            offset: const Offset(4, 0),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          style: IconButton.styleFrom(backgroundColor: AppColor.bgBack),
        ),
        title: const Text(
          "Fedor Kiryakov",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/ic_person.svg",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: getMessages.when(
                data: (messages) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.senderId == userId;
                      return isUser
                          ? _userMessage(message.content)
                          : _clientMessage(message.content);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  return const Center(
                    child: Text(
                      "Error al cargar los mensajes",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),

              /*child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _userMessage("Hi"),
                  _userMessage(
                    "Necesito un limpiador para mañana. Que limpie específicamente unas vitrinas.",
                  ),
                  _clientMessage("Sí, ¿de qué tamaños son aprox.?"),
                  _userMessage("1 metro"),
                  _clientMessage("Ya te envio la propuesta"),

                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.bgProp,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.only(top: 30, bottom: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Fedor ha creado una nueva propuesta. Revisala lo mas pronto",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.btnColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: const Text(
                              "Aceptar propuesta",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),*/
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              decoration: BoxDecoration(
                color: AppColor.bgContendeor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColor.bgShadow.withOpacity(0.3),
                    offset: const Offset(0, -4),
                    blurRadius: 6,
                    spreadRadius: 0.1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      minLines: 1,
                      style: const TextStyle(color: AppColor.txtMsg),
                      decoration: InputDecoration(
                        hintText: "Tu mensaje aquí",
                        hintStyle: const TextStyle(
                          color: AppColor.txtMsg,
                          fontSize: 17,
                        ),
                        filled: true,
                        fillColor: AppColor.bgLabel,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                "assets/icons/ic_camara.svg",
                                width: 30,
                                height: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final message = _messageController.text;
                                if (message.isEmpty) {
                                  Alerts.instance.showErrorAlert(
                                    context,
                                    "Escribe un mensaje.",
                                  );
                                  return;
                                }

                                final messageModel = MessageModel(
                                  senderId: userId!,
                                  receiverId: clienteId,
                                  content: message,
                                  timestamp: DateTime.now(),
                                );

                                await ref
                                    .read(chatViewModelProvider.notifier)
                                    .sendMessage(messageModel);
                              },
                              icon: SvgPicture.asset(
                                "assets/icons/ic_enviar.svg",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _userMessage(String text) {
  Color color = AppColor.bgMsgUser;
  return LayoutBuilder(
    builder: (context, constrains) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constrains.maxWidth * 0.8),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      );
    },
  );
}

Widget _clientMessage(String text) {
  Color color = AppColor.bgMsgClient;
  return LayoutBuilder(
    builder: (context, constraints) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      );
    },
  );
}
