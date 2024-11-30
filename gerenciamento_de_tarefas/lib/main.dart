import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF003366), // Azul marinho escuro
        scaffoldBackgroundColor: Colors.grey[200], // Fundo cinza claro
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF003366), // Azul marinho escuro
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF003366)), // Azul marinho escuro
          ),
        ),
      ),
      home: LoginScreen(), // Tela inicial de login
    );
  }
}

// Função para validar a senha (mínimo de 5 caracteres)
bool _isPasswordValid(String password) {
  return password.length >= 5;
}

// Função para validar o formato do email com uma expressão regular
bool _isValidEmail(String email) {
  String pattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Regex simples para validação de email
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

// Tela de Cadastro
class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Função para salvar credenciais usando SharedPreferences
  _saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  // Função para registrar
  _register() {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Verificando se os campos estão preenchidos
    if (email.isNotEmpty && password.isNotEmpty) {
      // Validação do email e da senha
      if (!_isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, insira um email válido!')),
        );
      } else if (!_isPasswordValid(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A senha deve ter pelo menos 5 caracteres!')),
        );
      } else {
        _saveCredentials(email, password);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()), // Redireciona para o login
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Cadastrar'),
              style: ElevatedButton.styleFrom(primary: Color(0xFF003366)), // Azul marinho escuro
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de Login
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Função para carregar credenciais armazenadas
  Future<Map<String, String?>> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('email'),
      'password': prefs.getString('password'),
    };
  }

  // Função de login
  _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    Map<String, String?> credentials = await _loadCredentials();

    // Validação do email
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um email válido!')),
      );
    } else if (credentials['email'] == email && credentials['password'] == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskManager()), // Redireciona para o gerenciador de tarefas
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email ou senha incorretos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Entrar'),
              style: ElevatedButton.styleFrom(primary: Color(0xFF003366)), // Azul marinho escuro
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroScreen()), // Redireciona para a tela de cadastro
                );
              },
              child: Text('Não tem conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela do Gerenciador de Tarefas
class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  List<Map<String, Object>> _tasks = [];
  TextEditingController _taskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Função para carregar as tarefas salvas
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        _tasks = taskList.map((task) {
          var taskData = task.split(',');
          return {
            'task': taskData[0],
            'date': taskData[1],
            'isCompleted': taskData[2] == 'true',
          };
        }).toList();
      });
    }
  }

  // Função para salvar as tarefas
  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList = _tasks.map((task) {
      return '${task['task']},${task['date']},${task['isCompleted']}';
    }).toList();
    await prefs.setStringList('tasks', taskList);
  }

  // Função para adicionar tarefa
  void _addTask() {
    if (_taskController.text.isNotEmpty && _dateController.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'task': _taskController.text,
          'date': _dateController.text,
          'isCompleted': false,
        });
      });
      _taskController.clear();
      _dateController.clear();
      _saveTasks();
    }
  }

  // Função para alternar o status de completado
  void _toggleCompletion(int index) {
    setState(() {
      _tasks[index]['isCompleted'] = !(_tasks[index]['isCompleted'] as bool);
    });
    _saveTasks();
  }

  // Função para remover tarefa
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Tarefas'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()), // Redireciona para o login
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Nova Tarefa'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Data da Tarefa'),
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: Color(0xFF003366), // Azul marinho escuro
                        accentColor: Color(0xFF003366),
                        primaryTextTheme: TextTheme(
                          headline6: TextStyle(color: Color(0xFF003366)),
                        ),
                        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Adicionar Tarefa'),
              style: ElevatedButton.styleFrom(primary: Color(0xFF003366)), // Azul marinho escuro
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Checkbox(
                      value: _tasks[index]['isCompleted'] as bool,
                      onChanged: (bool? value) {
                        _toggleCompletion(index);
                      },
                    ),
                    title: Text(
                      _tasks[index]['task'] as String,
                      style: TextStyle(
                        color: (_tasks[index]['isCompleted'] as bool)
                            ? Colors.grey
                            : Colors.black,
                        decoration: (_tasks[index]['isCompleted'] as bool)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(_tasks[index]['date'] as String),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeTask(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
