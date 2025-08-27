import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ---------------------------
// App Root = App run hole eikhan thke flutter MyApp ke run korbe.
// ---------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Group Expense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0FB9B1),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

// ---------------------------
// Models
// ---------------------------
enum Section { transport, meal, motel, others } //expense kothai kothai use hobe segula.

extension SectionX on Section {
  String get label {
    switch (this) {
      case Section.transport:
        return 'Transport';
      case Section.meal:      
        return 'Meal';
      case Section.motel:
        return 'Motel';
      case Section.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case Section.transport:
        return Icons.directions_bus;
      case Section.meal:
        return Icons.restaurant;   // extension diye icon + label set kora hoiche
      case Section.motel:
        return Icons.bed;
      case Section.others:
        return Icons.category;
    }
  }
}

class Member {
  final String id;
  final String name;       // group e ke ke member thakbe
  Member({required this.id, required this.name});
}

class Expense {
  final String id;
  final String title;
  final double amount;                //eikhane prottekh koroch er details ache. 
  final String payerId;
  final List<String> participantIds;
  final Section section;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.participantIds,
    required this.section,
    required this.createdAt,
  });
}

class AppState {
  final List<Member> members;
  final List<Expense> expenses;           //pora app er data (mamber+expense) ek jaigai rakha
  AppState({required this.members, required this.expenses});

  AppState copyWith({List<Member>? members, List<Expense>? expenses}) =>
      AppState(
          members: members ?? this.members,
          expenses: expenses ?? this.expenses);
}

// ---------------------------
// Home / state container
//mamber add and remove 
//expense add and remove
//balance summary show korbe.
// ---------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});        //homescreen main ui container
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppState state = AppState(members: [], expenses: []);
  int current = 0;

  void addMember(String name) {
    final m = Member(id: UniqueKey().toString(), name: name.trim());
    setState(() => state = state.copyWith(members: [...state.members, m]));
  }

  void removeMember(String id) {
    setState(() {
      state = state.copyWith(
        members: state.members.where((m) => m.id != id).toList(),
        expenses: state.expenses
            .where((e) => e.payerId != id && !e.participantIds.contains(id))
            .toList(),
      );
    });
  }

  void addExpense({
    required String title,
    required double amount,
    required String payerId,
    required List<String> participantIds,
    required Section section,
  }) {
    if (participantIds.isEmpty) return;
    final e = Expense(
      id: UniqueKey().toString(),
      title: title.trim(),
      amount: amount,
      payerId: payerId,
      participantIds: participantIds,
      section: section,
      createdAt: DateTime.now(),
    );
    setState(() => state = state.copyWith(expenses: [...state.expenses, e]));
  }

  void removeExpense(String id) {
    setState(() => state = state.copyWith(
        expenses: state.expenses.where((e) => e.id != id).toList()));
  }

  Map<String, double> balances() {
    final map = {for (final m in state.members) m.id: 0.0};
    for (final e in state.expenses) {
      if (e.participantIds.isEmpty) continue;
      final share = e.amount / e.participantIds.length;
      map[e.payerId] = (map[e.payerId] ?? 0) + e.amount;
      for (final pid in e.participantIds) {
        map[pid] = (map[pid] ?? 0) - share;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MembersPage(
        members: state.members,
        onAddMember: addMember,
        onRemoveMember: removeMember,
      ),
      ExpensesPage(
        members: state.members,
        expenses: state.expenses,
        onAddExpense: addExpense,
        onRemoveExpense: removeExpense,
      ),
      SummaryPage(
        members: state.members,
        expenses: state.expenses,
        balances: balances(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Group & Expense'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Chip(
                label: Text('${state.members.length} Members'),
                avatar: const Icon(Icons.group, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ),
          )
        ],
      ),
      body: pages[current],
      bottomNavigationBar: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: (i) => setState(() => current = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'Members'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Summary'),
        ],
      ),
    );
  }
}

// ---------------------------
// Members Page
// textfield diye new mamber add.
//list view diye member list show korbe.
//delet diye member remove. delet as a button.
// ---------------------------
class MembersPage extends StatefulWidget {
  final List<Member> members;
  final Function(String) onAddMember;
  final Function(String) onRemoveMember;

  const MembersPage({
    super.key,
    required this.members,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    hintText: "Enter member name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    widget.onAddMember(ctrl.text);
                    ctrl.clear();
                  }
                },
                child: const Text("Add"),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.members.length,
            itemBuilder: (context, i) {
              final m = widget.members[i];
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.onRemoveMember(m.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------
// Expenses Page
//Title, Amount

// Paid by (Dropdown)
// Section (Meal, Transport etc.)
// Participants (FilterChip select kore)
// sobar expense card show korbe.
// we can delete also....
// ---------------------------
class ExpensesPage extends StatefulWidget {
  final List<Member> members;
  final List<Expense> expenses;
  final Function({
    required String title,
    required double amount,
    required String payerId,
    required List<String> participantIds,
    required Section section,
  }) onAddExpense;
  final Function(String) onRemoveExpense;

  const ExpensesPage({
    super.key,
    required this.members,
    required this.expenses,
    required this.onAddExpense,
    required this.onRemoveExpense,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  Section section = Section.transport;
  String? payerId;
  final selectedParticipants = <String>{};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          title: const Text("Add Expense"),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Paid by"),
                    items: widget.members
                        .map((m) =>
                            DropdownMenuItem(value: m.id, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => payerId = v),
                  ),
                  DropdownButtonFormField<Section>(
                    decoration: const InputDecoration(labelText: "Section"),
                    value: section,
                    items: Section.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) => setState(() => section = v!),
                  ),
                  Wrap(
                    children: widget.members
                        .map((m) => FilterChip(
                              label: Text(m.name),
                              selected: selectedParticipants.contains(m.id),
                              onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    selectedParticipants.add(m.id);
                                  } else {
                                    selectedParticipants.remove(m.id);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty &&
                          amountCtrl.text.isNotEmpty &&
                          payerId != null) {
                        widget.onAddExpense(
                          title: titleCtrl.text,
                          amount: double.tryParse(amountCtrl.text) ?? 0,
                          payerId: payerId!,
                          participantIds: selectedParticipants.toList(),
                          section: section,
                        );
                        titleCtrl.clear();
                        amountCtrl.clear();
                        selectedParticipants.clear();
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.expenses.length,
            itemBuilder: (context, i) {
              final e = widget.expenses[i];
              final payer = widget.members
                  .firstWhere((m) => m.id == e.payerId,
                      orElse: () => Member(id: "", name: "Unknown"))
                  .name;
              return Card(
                child: ListTile(
                  leading: Icon(e.section.icon),
                  title: Text("${e.title} (${e.section.label})"),
                  subtitle: Text("Paid by $payer - ${_currency(e.amount)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.onRemoveExpense(e.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------
// Summary Page
// Prottek member koto debe/neybe show kore.
// Green = Profit (neyar taka ase)
// Red = Loss (deyar taka ase)
// ---------------------------
class SummaryPage extends StatelessWidget {
  final List<Member> members;
  final List<Expense> expenses;
  final Map<String, double> balances;

  const SummaryPage({
    super.key,
    required this.members,
    required this.expenses,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: members
          .map((m) => Card(
                child: ListTile(
                  title: Text(m.name),
                  trailing: Text(
                    _currency(balances[m.id] ?? 0),
                    style: TextStyle(
                      color: (balances[m.id] ?? 0) >= 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ---------------------------
// Currency helper
// ---------------------------
String _currency(double v, {String symbol = '৳', int decimals = 0}) {
  return '$symbol${v.toStringAsFixed(decimals)}';
}
