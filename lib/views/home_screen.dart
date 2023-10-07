import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dictionary/services/auth_service.dart';
import 'package:dictionary/services/palavra_service.dart';
import 'package:dictionary/services/usuario_service.dart';
import 'package:dictionary/views/lista_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{

  late final TabController _tabController;
  late UsuarioService _usuarioService;
  final AuthService _authService = AuthService();
  final PalavraService _palavraService = PalavraService(FirebaseFirestore.instance.collection('listadepalavras'));
  PalavraService? _historicoService;
  PalavraService? _favoritasService;

  String? uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregaUsuario();
  }

  void _carregaUsuario() async{
    uid = await _authService.obterIdUsuarioLogado();
    _usuarioService = UsuarioService(uid!);
    _historicoService = PalavraService(FirebaseFirestore.instance.collection('usuarios').doc(uid!).collection("historico"));
    _favoritasService = PalavraService(FirebaseFirestore.instance.collection('usuarios').doc(uid!).collection("favoritas"));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dictionary"),
        bottom: TabBar(
          controller: _tabController,
          tabs:const <Widget> [
            Tab(
              text: "Word list",
            ),
            Tab(
              text: "History",
            ),
            Tab(
              text: "Favorites",
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: PalavrasListScreen(_palavraService),
          ),
          Center(
            child: _historicoService != null ? PalavrasListScreen(_historicoService!) : Container(),
          ),
          Center(
            child: _favoritasService != null ? PalavrasListScreen(_favoritasService!) : Container(),
          ),
        ],
      ),
    );
  }
}